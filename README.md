# ZENO

Experimental 3D spatial puzzle/exploration game built with **Godot 4 + GDScript**.

ZENO is inspired by Zeno's paradoxes of motion. The player tries to reach the apparent edge of a world whose proportions, scale, geometry and object relationships change as traversal progresses.

> Movement is not merely traversal. Movement changes what space means.

## Read first

- `AXIOMATA.md` — design law: what is allowed to be ZENO.
- `GAME_BRIEF.md` — product/gameplay direction.
- `AGENTS.md` — operational rules for AI agents.
- `ZENO_GAME_BRIEF.md` — long-form source of truth.

## Stack

- Godot 4.x
- GDScript
- Git
- AI-assisted development

## Current milestone

The repository contains the first playable technical spike. It tests one rule:

> Crossing an invisible radial threshold changes the relative meaning of distance.

Walk away from the gold center marker. At 50%, 75%, and 87.5% conceptual
progress, nearby references move inward and grow while mid and outer geometry
recede at different rates. Turn around to restore the states in reverse.

## Run

1. Open this directory in Godot 4.x.
2. Run the project (`F6`/`F5`; the main scene is configured).
3. Use `WASD` to move and the mouse to look.
4. Press `Esc` to release/recapture the mouse and `F3` to toggle diagnostics.

Headless threshold validation:

```bash
godot --headless --path . --script res://tests/test_threshold_system.gd
```

See `docs/TECHNICAL_SPIKE.md` for the state profiles and architecture.

## North star

> Space itself is the machine I am operating.
