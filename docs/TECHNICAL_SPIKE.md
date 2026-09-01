# First playable technical spike

## Spatial law

The player's physical radial position selects one of four deterministic states.
The state is not stored by environment objects and transformations never multiply
their prior result.

| State | Entry progress | Near radius / scale | Mid radius / scale | Outer radius / scale |
| --- | ---: | ---: | ---: | ---: |
| 0 | start | 1.00 / 1.00 | 1.00 / 1.00 | 1.00 / 1.00 |
| 1 | 0.500 | 0.96 / 1.16 | 1.05 / 0.92 | 1.12 / 1.05 |
| 2 | 0.750 | 0.90 / 1.34 | 1.11 / 0.82 | 1.20 / 1.10 |
| 3 | 0.875 | 0.84 / 1.54 | 1.18 / 0.72 | 1.28 / 1.16 |

The outer wall is both visible and collidable. Its collision moves with its
presentation. Near landmarks respond in the opposite direction, making a uniform
scene-scale interpretation impossible.

## Runtime flow

```text
PlayerController
  movement only
        ↓ position sample
ZenoThresholdSystem
  radial progress, direction, threshold crossings, hysteresis
        ↓ entered/exited signals
WorldStateController
  authoritative current and previous state
        ↓ world_state_changed signal
TransformationDirector
  interpolates every layer toward explicit state targets
        ↓
TestArena geometry and collision
```

The director snapshots only the start of the current visual interpolation. Every
target is recomputed from each object's immutable `base_position` and `base_scale`.
Reversal during a transition is smooth, and completing any state returns the exact
same configuration without transform drift.

## Boundary behavior

Forward crossings are inclusive: arriving exactly at a threshold enters it once.
Reverse crossings use a small configurable hysteresis band (`0.008` normalized
progress) so standing or oscillating at a boundary cannot spam transitions.

## Debugging

The overlay exposes state, threshold, distance, normalized progress, radial
movement direction, player position, outer radius ratio, and transition activity.
`F3` toggles both the overlay and threshold rings.
