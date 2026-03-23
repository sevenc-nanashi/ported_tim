use aviutl2::filter::{FilterConfigItemSliceExt, FilterConfigItems};

#[aviutl2::plugin(FilterPlugin)]
pub struct SaverFilter {}

#[aviutl2::filter::filter_config_items]
struct Config {
    #[track(name = "Nonce", step = 1.0, range=0..=10000, default = 0)]
    nonce: usize,
}

impl aviutl2::filter::FilterPlugin for SaverFilter {
    fn new(_info: aviutl2::AviUtl2Info) -> aviutl2::AnyResult<Self> {
        Ok(Self {})
    }

    fn plugin_info(&self) -> aviutl2::filter::FilterPluginTable {
        aviutl2::filter::FilterPluginTable {
            name: "Saver".to_string(),
            label: None,
            information: "Saves the current frame as a PNG file.".to_string(),
            flags: aviutl2::bitflag!(aviutl2::filter::FilterPluginFlags {
                video: true,
                as_filter: true
            }),
            config_items: Config::to_config_items(),
        }
    }
    fn proc_video(
        &self,
        config: &[aviutl2::filter::FilterConfigItem],
        video: &mut aviutl2::filter::FilterProcVideo,
    ) -> aviutl2::AnyResult<()> {
        let config = config.to_struct::<Config>();
        let mut frame: Vec<u8> =
            vec![0; (video.video_object.width * video.video_object.height * 4) as usize];
        video.get_image_data(&mut frame);

        let path = format!("frame_{:04}.png", config.nonce);
        let target = process_path::get_executable_path()
            .unwrap()
            .with_file_name("frames")
            .join(path);
        std::fs::create_dir_all(target.parent().unwrap())?;
        let image =
            image::RgbaImage::from_raw(video.video_object.width, video.video_object.height, frame)
                .unwrap();
        image.save(&target)?;
        aviutl2::tracing::info!("Saved to {:?}", target);
        Ok(())
    }
}
