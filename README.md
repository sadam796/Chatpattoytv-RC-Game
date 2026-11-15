# Chatpattoytv RC Game

Android-first realistic 3D RC monster-truck simulator built with Godot 4.

## Art direction — keep this fixed
- Premium, realistic RC off-road simulator presentation; never cartoon or toy-store styling.
- Original large-scale RC monster truck proportions: oversized tyres, visible long-travel suspension, rugged detailed shell. Inspired by the broad class of 8S RC trucks, without copying protected logos, names or exact body designs.
- Wide outdoor driving spaces with dirt trails, rocks, mountain silhouettes, forest edges, ramps, mud and water zones.
- Third-person chase camera and close bonnet camera.
- Minimal dark driving HUD with restrained warm accents, designed for landscape Android touch play.

## Project
- Engine: Godot 4.x
- Renderer: Mobile / GL Compatibility
- Main scene: `scenes/main.tscn`
- Vehicle: four-wheel-drive VehicleBody3D prototype with four independent VehicleWheel3D suspension nodes
- Controls: touch HUD plus keyboard controls for desktop testing

## Open and run
1. Install Godot 4.3 or newer.
2. Import this repository folder using `project.godot`.
3. Open `scenes/main.tscn` and press Play.
4. To build Android, install Godot Android export templates and configure an Android export preset.

## Controls
Touch: steering left/right, throttle, reverse, brake, camera toggle, reset.
Keyboard: W/up throttle, S/down brake (reverse when nearly stopped), A/D or arrows steer, C camera, R reset.

## Automated validation
GitHub Actions runs a headless Godot 4.3 project import/script check and launches the main scene briefly on pushes and pull requests. A green workflow is a basic engine validation only; it does not replace real Android device, driving-physics, graphics or performance testing.

## Development status
This is the initial playable foundation, not a finished commercial game. The current generated truck has a more detailed procedural body shell, fenders, glass, grille, wheel hubs, tread blocks and visible suspension props; the environment includes a dirt test arena, ramps, rocks, distant mountain forms and a forest edge. These are still procedural prototype assets, not final authored high-detail art. High-detail authored vehicle/environment art, advanced tyre-ground interaction, deformation, mud/water simulation, garage, upgrades, missions, audio, performance tuning and a signed Android APK are not yet complete. Do not treat this project as release-ready until it is tested in Godot and on Android devices.
