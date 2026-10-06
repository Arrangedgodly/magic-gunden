# Magic Gunden

**Build a gem trail. Line up a capture. Turn it into ammunition.**

Magic Gunden is a Godot arcade survival game that combines continuous, grid-based movement with four-direction shooting. Collect gems behind you, guide that trail onto moving capture zones, then release it. Correctly placed gems become ammunition and score; gems released outside the zones become slimes.

![Magic Gunden's main menu](docs/images/magic-gunden-menu.png)

*The original Godot game's main menu, captured from the source revision documented below.*

## The risk is in the release

1. **Move and collect.** Pick a direction and keep moving through the arena, gathering a trailing chain of gems.
2. **Line up the trail.** Bring the gems over capture zones before those zones relocate.
3. **Release.** Gems on the zones earn ammunition and score. Off-zone gems create enemies.
4. **Survive.** Aim independently, spend your ammunition, and avoid enemies, your own trail, and the arena boundary.

Successive gems captured in one release increase the score earned. Capturing at least six gems in a release triggers one random powerup spawn request; an exact twelve-gem capture triggers a second. Placement can fail when no valid location is found.

## Learn the loop in the tutorial

![The opening tutorial state](docs/images/magic-gunden-tutorial-opening.png)

*The tutorial's opening state. This capture does not demonstrate a completed capture, combat encounter, or tutorial playthrough.*

The guided tutorial introduces movement, collecting, capture zones, the penalty for misplaced gems, aiming, shooting, and Stomp. Skip it during the tutorial with T / B / Circle, or replay it from Options.

## Default controls

Movement and aiming are separate. The inspected controls do not use mouse aiming.

| Action | Keyboard | Controller |
| --- | --- | --- |
| Move | W / A / S / D | Left stick or D-pad |
| Aim | Arrow keys | Right stick or corresponding face buttons |
| Shoot | Space | Right shoulder or right trigger |
| Release gem trail | E | Left shoulder or left trigger |
| Pause / menu | Escape | Start / Menu |
| Skip tutorial | T | B / Circle |

Movement continues after choosing a direction, and immediate reversal is prevented. Change bindings in **Options → Edit Controls**. Controller-aware prompts and touch controls are implemented in the source; this README does not claim a completed controller or mobile test pass.

## Powerups and progress

The active powerup set contains **13 types**:

| Powerups | Powerups |
| --- | --- |
| Stomp | Magnet |
| Pierce | Ricochet |
| Poison | Auto Aim |
| Flames | Free Ammo |
| Ice | Time Pause |
| Grenade | Four-Way Shot |
| Laser | |

Jump assets and code exist but are disabled in the active registration, so Jump is not part of the current playable powerup set.

The project also includes High Scores and Achievements menus, twenty achievement resources, saved settings, and statistics for score, slimes killed, gems captured, survival time, and killstreak. Individual achievement unlocks have not all been exercised during this documentation pass.

**Known score-saving issue:** `score_manager.gd` calculates personal-best values in `high_scores`, then saves the current-run `saved_game` object instead. Persisted personal bests should not be assumed reliable until that is corrected. This README update does not change game behavior.

## Adjust the game

![Magic Gunden's options menu](docs/images/magic-gunden-options.png)

*The options screen at its default 80% music and sound-effect levels.*

Options provides music and sound-effect volume controls, control remapping, tutorial replay, and reset controls. The game includes pause, restart, and return-to-menu flows, along with animated menus and pixel-art effects.

## Run from source

The project declares **Godot 4.5** and uses GDScript. Its renderer setting is OpenGL Compatibility. There is no npm or .NET build step.

Many PNG assets are stored with **Git LFS**. Downloading only pointer files will leave the artwork unavailable.

```bash
git lfs install
git clone https://github.com/Arrangedgodly/magic-gunden.git
cd magic-gunden
git lfs pull
```

Open `project.godot` in Godot, allow the assets to import, then run the project with **F5**. The configured entry scene is `scenes/splash_screen.tscn`.

Export presets exist for Linux, Web, Windows, and Android. These presets are not downloadable releases or proof that each target currently exports successfully. Exports require the corresponding Godot templates and, where applicable, a platform toolchain.

## Where to look in the project

| Path | Responsibility |
| --- | --- |
| `project.godot` | Project configuration and default input bindings. |
| `scripts/player.gd` | Player movement, aiming, and firing behavior. |
| `scripts/managers/trail_manager.gd` | Gem trail, capture resolution, penalties, and rewards. |
| `scripts/managers/powerup_manager.gd` | Active powerup registration and management. |
| `scripts/tutorial/hint_label.gd` | Control glyphs and inline tutorial illustrations. |
| `scripts/tutorial/tutorial.gd` / `scripts/tutorial/steps/` | Tutorial progression and lesson content. |
| `scripts/menus/controls_menu.gd` | Control-remapping interface. |
| `scenes/menus/credits.tscn` | In-game art, audio, font, and shader credits. |
| `export_presets.cfg` | Checked-in target export configurations. |

This is the original Godot project. [Magic Gunden Redux](https://github.com/Arrangedgodly/magic-gunden-redux) is a separate implementation with its own controls and setup.

## Verification scope

The three screenshots are authentic, unscaled **1280 × 800** captures from source commit `e1c6c5382504dbdbc482473d42d7c97dc38ff924`, opened with **Godot 4.7.2** in an isolated save environment. Import and capture commands exited successfully, with resource-cleanup warnings reported at capture exit. The configured target version remains Godot 4.5.

This pass observed the menu, tutorial opening, and options screen. It did not exercise movement, capture, shooting, controller/touch input, achievements, or exports. Gameplay descriptions above come from the inspected source, not a completed playtest. No automated test or CI setup was found at that revision.

## Credits and licensing

The repository's [MIT license](LICENSE) retains **© 2024 Noasey**. Bundled assets have their own terms and credits; the code license does not make all art or audio MIT-licensed.

- Particle FX includes a Creative Commons Attribution 4.0 license with credit to **Raphael Hatencia / RagnaPixel Studio**.
- Kenney Input Prompts includes a **CC0** license.
- The Nature Landscapes pack points to [Craftpix's license terms](https://craftpix.net/file-licenses/).
- Preserve the individual asset license files and the complete [in-game credits](scenes/menus/credits.tscn), including the listed art, font, audio, and shader contributors.
