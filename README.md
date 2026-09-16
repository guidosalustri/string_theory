# String Theory

> [!TIP]
> **[Download the Windows build](https://drive.google.com/drive/folders/1YpS6nY7ej0Vf_0qD2wnZ66WQ_0eMDCPw)**
> · [Publication (DiVA)](https://uu.diva-portal.org/smash/record.jsf?pid=diva2%3A1965699)

An action-puzzle top-down 2D space game built in Godot 4. Each level is one of the
twelve zodiac constellations, and the goal is to draw it by connecting its stars.

![String Theory](https://guidosalustri.github.io/assets/images/st_game.png)

Shown at the **Gotland Game Conference**, where it ran on the seven levels under
`lvls/ggc/`; the remaining constellations in `lvls/after_ggc/` were built afterwards.

## Details

| | |
|:--|:--|
| **Scale** | 58 GDScript files, ~3,250 lines of project code, 19 levels |
| **Systems** | Orbital attach/detach physics, energy economy, obstacle types (black holes, asteroids, path and spinner hazards), stopwatch scoring |
| **Interface** | Main menu, options, pause, level selector, tutorial dialogue, cutscenes, shader-driven speedometer and fuel gauges |
| **Online** | Cloud leaderboard through the SilentWolf service, with asynchronous score submission and retrieval |
| **Reuse** | Camera behaviour via the `phantom_camera` addon; leaderboard backend via `silent_wolf`. Both are third-party and live under `addons/` |

## Telemetry

The game was instrumented to support research.

`DataCollection` is an abstract base declaring the full logging interface, with a typed
event taxonomy — ship attach/detach, aim quality, level start and completion, level and
game quit with cause, fuel exhaustion, continuous position, and player death broken into
six distinct causes (black hole, asteroid, star collision, overcharge, out of fuel,
stray). Two subclasses implement it: `DataCollectionImpl`, which writes tagged CSV rows,
and `DataCollectionDummy`, which no-ops every call. `GameManager` swaps the
implementation at runtime, so telemetry can be switched off without any call site
knowing or changing.

Details that mattered for the data being usable:

- Timestamps come from a stopwatch that **pauses with the game**, so timings measure
  play rather than wall clock
- Every write is flushed immediately, so a crash mid-session doesn't cost the run
- Log paths resolve differently for standalone builds and editor runs, so exported
  builds handed to participants write somewhere findable
- Aim quality is recorded as the dot product between the ship's velocity and the
  intended vector on ejection — a continuous measure rather than hit or miss

Logging calls are distributed across the ship, level, pause menu, main menu and game
manager, so failure and quit events are captured wherever they actually originate.

The resulting logs were analysed into per-level behavioural heatmaps:

![Heatmap of the Leo level](https://guidosalustri.github.io/assets/images/st_heatmap.png)

This fed a publication examining how in-game behaviour varies with players'
self-reported intrinsic motivations and challenge-type preferences.

## Built with

`Godot 4` `GDScript` · two-person team

## Status

Currently being reworked. The focus is game flow — pacing matters disproportionately in
a game built around frustration — alongside a full visual redo.

