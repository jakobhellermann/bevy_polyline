# Bevy Polyline

[![crates.io](https://img.shields.io/crates/v/bevy_polyline)](https://crates.io/crates/bevy_polyline)
[![docs.rs](https://docs.rs/bevy_polyline/badge.svg)](https://docs.rs/bevy_polyline)
[![CI](https://github.com/ForesightMiningSoftwareCorporation/bevy_polyline/workflows/CI/badge.svg?branch=main)](https://github.com/ForesightMiningSoftwareCorporation/bevy_polyline/actions?query=workflow%3A%22CI%22+branch%3Amain)
[![Bevy tracking](https://img.shields.io/badge/Bevy%20tracking-main-lightblue)](https://github.com/bevyengine/bevy/blob/main/docs/plugins_guidelines.md#main-branch-tracking)

Bevy Polyline is a plugin for [Bevy Engine](https://bevyengine.org/) that adds instanced rendering of `Polyline`s. The plugin comes courtesy of Foresight Mining Software Corporation who sponsor its creation and maintenance.

![nbody demo](nbody.gif)

## Implementation

Bevy Polyline closely mimics the way `Mesh`es are rendered in Bevy. It works internally by passing a minimal Instance Buffer to the GPU, containing only the line segment endpoints and then completely determines all vertex positions within the vertex shader, such that the triangles form a line that is rotated around it's longitudinal axis to face towards the camera. The shader code is based on [this great tutorial by Rye Terrell](https://wwwtyro.net/2019/11/18/instanced-lines.html).

## Examples
There are two examples, linestrip demonstrates how to make a very basic static Polyline. nbody (shown in the above demo) demonstrates how to do updateable `Polyline`s, by changing the vertices of a `Polyline`.

# Usage
Usage of Bevy Polyline is quite simple. First add it to your `Cargo.toml`:

```toml
[dependencies]
bevy_polyline = "0.1"
```

You add it as a plugin to your app:
```rust
app.add_plugin(PolylinePlugin);
```

And then you can add some Polylines through PolylineBundle
```rust
fn my_system(
    mut commands: Commands,
    mut polylines: ResMut<Assets<Polyline>>,
    mut polyline_materials: ResMut<Assets<PolylineMaterial>>,
) {
    commands.spawn_bundle(PolylineBundle {
        polyline: polylines.add(Polyline {
            vertices: vec![
                Vec3::new(-0.5, -0.5, -0.5),
                Vec3::new(0.5, -0.5, -0.5),
                Vec3::new(0.5, 0.5, -0.5),
                Vec3::new(-0.5, 0.5, -0.5),
                Vec3::new(-0.5, 0.5, 0.5),
                Vec3::new(0.5, 0.5, 0.5),
                Vec3::new(0.5, -0.5, 0.5),
                Vec3::new(-0.5, -0.5, 0.5),
            ],
            ..Default::default()
        }),
        material: polyline_materials.add(PolylineMaterial {
            width: 3.0,
            color: Color::RED,
            perspective: false,
            ..Default::default()
        }),
        ..Default::default()
    });
}
```

## Transform
`Polyline`s respect positioning through `GlobalTransform`, so you can position them directly, or through the use of a `Transform` hierarchy.

## PolylineMaterial
Currently the main way of customizing a `Polyline` is by changing the `PolylineMaterial`, which, as can be seen above, has fields for `width`, `color` and `perspective`. `width` directly correlates to screen pixels in non-perspective mode. In `perspective` mode `width` gets divided by the w component of the homogeneous coordinate, meaning it corresponds to screen pixels at the near plane and becomes progressively smaller further away.

## Shaders
For more significant customization, you have to make a custom shader, although it's likely we'll add more shaders in the future. The current version only implements line strips (i.e. `PolyLine`s rendered as connected line segments) with no caps.

Due to the nature of its instanced rendering, Bevy Polyline comes with fairly specific shaders. You can still replace these with custom ones, but you will have to keep a good chunk of the shader in tact if you want to use Bevy Polyline's way of creating the line triangles.

## Aliasing/shimmering
Bevy Polyline does some work to reduce aliasing, by implementing the line thinness fade from https://acegikmo.com/shapes/docs/#anti-aliasing. But if your line segments are very short, you will still see shimmering, caused by triangles < 1 pixel in size. This can be reduced by only adding segments of a minimum length.

## Performance
Due to instancing, Bevy Polyline only makes one drawcall per `PolyLine`, one for the line segments ~~and one for the miter joins~~ (not currently enabled). We've tested the `nbody` demo at some 500 lines with 4096 segments being updated every frame (in addition to a 4th order Yoshida integrator for the nbody simulation) running at 60fps. There is still some room for performance optimization, particularly reducing to one drawcall per `Polyline` (depending on join and cap types) and more efficient updates of the instance buffer for updated lines.

# Bevy Version Support
We intend to track the `main` branch of Bevy. PRs supporting this are welcome!

|bevy|bevy_polyline|
|---|---|
|0.6|0.1|

# Community Support
If you want some help using this plugin, you can ask in the Bevy Discord at https://discord.gg/bevy.

# Special Thanks
Credit goes to [mtsr](https://github.com/mtsr) for the initial implementation of this plugin.

# License

bevy_polyline is free and open source! All code in this repository is dual-licensed under either:

* MIT License (LICENSE-MIT or http://opensource.org/licenses/MIT)
* Apache License, Version 2.0 (LICENSE-APACHE or http://www.apache.org/licenses/LICENSE-2.0)

at your option. This means you can select the license you prefer! This dual-licensing approach is the de-facto standard in the Rust ecosystem and there are very good reasons to include both.

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.

# Sponsors
The creation and maintenance of Bevy Polyline is sponsored by Foresight Mining Software Corporation.

<img src="https://user-images.githubusercontent.com/2632925/151242316-db3455d1-4934-4374-8369-1818daf512dd.png" alt="Foresight Mining Software Corporation" width="480">
