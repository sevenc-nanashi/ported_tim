#![allow(clippy::too_many_arguments)]
use aviutl2::module::ScriptModuleFunctions;

mod alpha;
mod burning;
mod color;
mod cracked_glass;
mod custom_flare;
mod extbuffer;
mod familiar;
mod filter;
mod framing;
mod lineextra;
mod linefill;
mod mmdcam;
mod polcon;
mod rbwgra;
mod rgline;
mod rndblur;
mod rotblur;
mod sketch;

#[aviutl2::plugin(ScriptModule)]
struct PortedTimMod2 {}

impl aviutl2::module::ScriptModule for PortedTimMod2 {
    fn new(_info: aviutl2::AviUtl2Info) -> aviutl2::AnyResult<Self> {
        Ok(Self {})
    }

    fn plugin_info(&self) -> aviutl2::module::ScriptModuleTable {
        aviutl2::module::ScriptModuleTable {
            information: "ported_tim.mod2".into(),
            functions: Self::functions(),
        }
    }
}

impl ScriptModuleFunctions for PortedTimMod2 {
    fn functions() -> Vec<aviutl2::module::ModuleFunction> {
        let mut functions = Vec::new();
        functions.extend(alpha::AlphaModule::functions());
        functions.extend(burning::BurningModule::functions());
        functions.extend(color::ColorModule::functions());
        functions.extend(cracked_glass::CrackedGlassModule::functions());
        functions.extend(custom_flare::CustomFlareModule::functions());
        functions.extend(extbuffer::ExtbufferModule::functions());
        functions.extend(familiar::FamiliarModule::functions());
        functions.extend(filter::FilterModule::functions());
        functions.extend(framing::FramingModule::functions());
        functions.extend(lineextra::LineExtraModule::functions());
        functions.extend(linefill::LineFillModule::functions());
        functions.extend(mmdcam::MmdCamModule::functions());
        functions.extend(polcon::PolConModule::functions());
        functions.extend(rbwgra::RbwGraModule::functions());
        functions.extend(rgline::RgLineModule::functions());
        functions.extend(rndblur::RandomBlurModule::functions());
        functions.extend(rotblur::RotBlurModule::functions());
        functions.extend(sketch::SketchModule::functions());
        functions
    }
}

aviutl2::register_script_module!(PortedTimMod2);
