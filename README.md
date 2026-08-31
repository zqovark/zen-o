# ZENO

Minimal Godot 4 vertical-slice prototype for an AI-assisted spatial puzzle game where **movement changes world state**.

## What this prototype includes

- Playable `Main.tscn` scene that launches directly from `project.godot`
- First-person movement + look + interaction (`WASD`, mouse, `E`, `Space`)
- `ZenoThresholdSystem` that reacts to forward/backward traversal from world center
- `WorldStateController` with reversible state progression (0..3)
- `TransformationDirector` that scales the world per state
- State-driven interactables: `Fragment A`, `Fragment B`, `Anchor`, `Exit`
- One Operator (`Anchor`) plus a rule-breaking behavior after collecting `Fragment B` (next forward state advances extra)
- Deterministic `SeedManager` + constrained authored-slot randomization for fragments
- Debug overlay showing seed, state, threshold, direction, distance, edge progress, world scale, active operator, objective

## Scene / script layout

- `scenes/game/Main.tscn`
- `scripts/player/player_controller.gd`
- `scripts/systems/*.gd`
- `scripts/interactables/state_interactable.gd`
- `scripts/debug/debug_overlay.gd`

## Notes

This is intentionally a small, explicit prototype focused on proving the core question:

> Can one Zeno-like spatial rule produce satisfying movement-driven puzzle behavior?
