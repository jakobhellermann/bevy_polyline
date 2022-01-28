use bevy::{prelude::*, reflect::TypeUuid};
pub use material::PolylineMaterial;
use material::PolylineMaterialPlugin;
pub use polyline::Polyline;
use polyline::PolylineRenderPlugin;

pub mod material;
pub mod polyline;

pub const FRAG_SHADER_HANDLE: HandleUntyped =
    HandleUntyped::weak_from_u64(Shader::TYPE_UUID, 12823766040132746065);
pub const VERT_SHADER_HANDLE: HandleUntyped =
    HandleUntyped::weak_from_u64(Shader::TYPE_UUID, 10060193527938109963);

pub struct PolylinePlugin;

impl Plugin for PolylinePlugin {
    fn build(&self, app: &mut bevy::prelude::App) {
        let mut shaders = app.world.get_resource_mut::<Assets<Shader>>().unwrap();
        shaders.set_untracked(
            FRAG_SHADER_HANDLE,
            Shader::from_glsl(
                include_str!("shaders/polyline.frag"),
                naga::ShaderStage::Fragment,
            ),
        );
        shaders.set_untracked(
            VERT_SHADER_HANDLE,
            Shader::from_glsl(
                include_str!("shaders/polyline.vert"),
                naga::ShaderStage::Vertex,
            ),
        );
        app.add_plugin(PolylineRenderPlugin)
            .add_plugin(PolylineMaterialPlugin);
    }
}

#[derive(Bundle, Default)]
pub struct PolylineBundle {
    pub polyline: Polyline,
    pub material: Handle<PolylineMaterial>,
    pub transform: Transform,
    pub global_transform: GlobalTransform,
    /// User indication of whether an entity is visible
    pub visibility: Visibility,
    /// Algorithmically-computed indication of whether an entity is visible and should be extracted for rendering
    pub computed_visibility: ComputedVisibility,
}
