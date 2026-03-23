use aviutl2::anyhow;
use saver::SaverFilter;

mod saver;

static EDIT_HANDLE: aviutl2::generic::GlobalEditHandle = aviutl2::generic::GlobalEditHandle::new();

#[aviutl2::plugin(GenericPlugin)]
struct PortedTimTester {
    saver: aviutl2::generic::SubPlugin<SaverFilter>,
    thread_handle: Option<std::thread::JoinHandle<()>>,
}

impl aviutl2::generic::GenericPlugin for PortedTimTester {
    fn new(info: aviutl2::AviUtl2Info) -> aviutl2::AnyResult<Self> {
        aviutl2::tracing_subscriber::fmt()
            .with_max_level(aviutl2::tracing::Level::TRACE)
            .event_format(aviutl2::logger::AviUtl2Formatter)
            .with_writer(aviutl2::logger::AviUtl2LogWriter)
            .init();
        Ok(Self {
            saver: aviutl2::generic::SubPlugin::new_filter_plugin(&info)?,
            thread_handle: None,
        })
    }

    fn plugin_info(&self) -> aviutl2::generic::GenericPluginTable {
        aviutl2::generic::GenericPluginTable {
            name: "Ported Tim Tester".to_string(),
            information: "Tester".to_string(),
        }
    }

    fn register(&mut self, registry: &mut aviutl2::generic::HostAppHandle) {
        EDIT_HANDLE.init(registry.create_edit_handle());
        registry.register_filter_plugin(&self.saver);
        self.thread_handle = Some(std::thread::spawn(run_server));
    }
}

fn delete_all_objects() -> anyhow::Result<()> {
    EDIT_HANDLE.call_edit_section(|e| {
        for layer in e.layers() {
            for (_, object) in layer.objects() {
                e.delete_object(&object)?;
            }
        }

        anyhow::Ok(())
    })??;

    Ok(())
}

#[derive(Debug, serde::Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
enum ParameterValue {
    Scalar { value: String },
    Ease { start: String, end: String },
}

fn run_object(
    name: String,
    length: usize,
    parameters: std::collections::HashMap<String, ParameterValue>,
) -> anyhow::Result<u64> {
    delete_all_objects()?;

    EDIT_HANDLE.call_edit_section(|e| {
        let object = e.create_object(&name, 0, 0, Some(length))?;
        for (key, value) in parameters {
            e.set_object_effect_item(
                &object,
                &name,
                0,
                &key,
                &match value {
                    ParameterValue::Scalar { value } => value.to_string(),
                    ParameterValue::Ease { start, end } => {
                        format!("{start},{end},直線移動,0")
                    }
                },
            )?;
        }

        let nonce = rand::random::<u64>() % 10000;
        let alias = format!(
            r"
[Object]
frame=0,{}
[Object.0]
effect.name=フィルタオブジェクト
[Object.1]
effect.name=Saver
Nonce={}
",
            length, nonce
        );
        e.create_object_from_alias(&alias, 1, 0, 0)?;

        anyhow::Ok(nonce)
    })?
}

fn run_effect(
    source_path: String,
    name: String,
    length: usize,
    parameters: std::collections::HashMap<String, ParameterValue>,
) -> anyhow::Result<u64> {
    delete_all_objects()?;

    EDIT_HANDLE.call_edit_section(|e| {
        let image = e.create_object(&name, 0, 0, Some(length))?;
        e.set_object_effect_item(&image, "画像ファイル", 0, "ファイル", &source_path)?;

        let effect_object = e.create_object(&name, 1, 0, Some(length))?;
        for (key, value) in parameters {
            e.set_object_effect_item(
                &effect_object,
                &name,
                0,
                &key,
                &match value {
                    ParameterValue::Scalar { value } => value.to_string(),
                    ParameterValue::Ease { start, end } => {
                        format!("{start},{end},直線移動,0")
                    }
                },
            )?;
        }

        let nonce = rand::random::<u64>() % 10000;
        let alias = format!(
            r"
[Object]
frame=0,{}
[Object.0]
effect.name=フィルタオブジェクト
[Object.1]
effect.name=Saver
Nonce={}
",
            length, nonce
        );
        e.create_object_from_alias(&alias, 2, 0, 0)?;

        anyhow::Ok(nonce)
    })?
}

fn quit() {
    std::process::exit(0);
}

#[derive(serde::Deserialize)]
struct RunObjectRequest {
    name: String,
    length: usize,
    #[serde(default)]
    parameters: std::collections::HashMap<String, ParameterValue>,
}

#[derive(serde::Deserialize)]
struct RunEffectRequest {
    source_path: String,
    name: String,
    length: usize,
    #[serde(default)]
    parameters: std::collections::HashMap<String, ParameterValue>,
}

fn run_server() {
    while !EDIT_HANDLE.is_ready() {
        std::thread::sleep(std::time::Duration::from_millis(100));
    }
    let server = tiny_http::Server::http("127.0.0.1:52000").expect("Failed to start HTTP server");
    aviutl2::tracing::info!("HTTP server listening on 127.0.0.1:52000");

    for mut request in server.incoming_requests() {
        let url = request.url().to_string();
        let method = request.method().clone();

        if method != tiny_http::Method::Post {
            let response =
                tiny_http::Response::from_string("Method Not Allowed").with_status_code(405);
            let _ = request.respond(response);
            continue;
        }

        let mut body = String::new();
        if request.as_reader().read_to_string(&mut body).is_err() {
            let response = tiny_http::Response::from_string("Bad Request").with_status_code(400);
            let _ = request.respond(response);
            continue;
        }

        let response = match url.as_str() {
            "/run_object" => match serde_json::from_str::<RunObjectRequest>(&body) {
                Ok(req) => match run_object(req.name, req.length, req.parameters) {
                    Ok(nonce) => {
                        tiny_http::Response::from_string(nonce.to_string()).with_status_code(200)
                    }
                    Err(e) => tiny_http::Response::from_string(e.to_string()).with_status_code(500),
                },
                Err(e) => tiny_http::Response::from_string(e.to_string()).with_status_code(400),
            },
            "/run_effect" => match serde_json::from_str::<RunEffectRequest>(&body) {
                Ok(req) => {
                    match run_effect(req.source_path, req.name, req.length, req.parameters) {
                        Ok(nonce) => tiny_http::Response::from_string(nonce.to_string())
                            .with_status_code(200),
                        Err(e) => {
                            tiny_http::Response::from_string(e.to_string()).with_status_code(500)
                        }
                    }
                }
                Err(e) => tiny_http::Response::from_string(e.to_string()).with_status_code(400),
            },
            "/quit" => {
                let response = tiny_http::Response::from_string("OK").with_status_code(200);
                let _ = request.respond(response);
                quit();
                return;
            }
            _ => tiny_http::Response::from_string("Not Found").with_status_code(404),
        };

        let _ = request.respond(response);
    }
}

aviutl2::register_generic_plugin!(PortedTimTester);
