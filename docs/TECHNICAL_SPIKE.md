# First playable technical spike

## Spatial law

The player's physical radial position selects one of four deterministic states.
The state is not stored by environment objects and transformations never multiply
their prior result.

| State | Entry progress | Near radius / scale | Mid radius / scale | Outer radius / scale |
| --- | ---: | ---: | ---: | ---: |
| 0 | start | 1.00 / 1.00 | 1.00 / 1.00 | 1.00 / 1.00 |
| 1 | 0.500 | 0.92 / 1.25 | 1.07 / 0.86 | 1.12 / 1.05 |
| 2 | 0.750 | 0.82 / 1.52 | 1.16 / 0.70 | 1.20 / 1.10 |
| 3 | 0.875 | 0.70 / 1.88 | 1.28 / 0.54 | 1.28 / 1.16 |

The outer wall is both visible and collidable. Its collision moves with its
presentation. Near landmarks respond in the opposite direction, making a uniform
scene-scale interpretation impossible.

## Perceptual playground

The primitive arena is composed as three recognizable visual layers:

- **Near:** four asymmetric cyan monolith clusters on diagonal rays. They move
  inward and grow, becoming more dominant even as the player moves away from the
  center.
- **Mid:** three repeated violet gates along each cardinal ray. Their open travel
  lanes remain safe while their radial gaps expand and the structures shrink.
- **Outer:** a continuous low wall with eight tall amber teeth. The skyline makes
  the wall's outward movement and exact reverse restoration easy to compare.

Four faint fixed floor diameters and the invariant gold center beacon provide
Euclidean references without taking ownership of the spatial law.

Three understated floor seams mark the existing threshold radii. Crossing a
seam produces a short geometric pulse, directional tone, and `1.1°` FOV response
while the actual near/mid/outer geometry resolves. These cues contain no state
logic and cannot affect collision or target transforms; they make the movement
cause readable before debug UI is needed.

The player now begins on the puzzle's `22.5°` radial axis looking directly at
the impossible gate/receiver relationship. The ANCHOR pickup and reusable route
lie on the exact opposite `202.5°` axis, so turning and retreating reveals the
next possibility rather than another stretch of empty arena. Movement speed is
`5.2 m/s`, allowing the `0.56 s` transition to resolve between the two closest
thresholds during ordinary forward movement.

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
  resolves global profiles plus the optional ANCHOR exception
        ↓
TestArena geometry and collision
```

The director snapshots only the start of the current visual interpolation. Every
target is recomputed from each object's immutable `base_position` and `base_scale`.
Reversal during a transition is smooth, and completing any state returns the exact
same configuration without transform drift.

Moving `AnimatableBody3D` transforms are resolved in `_physics_process` with
their automatic `sync_to_physics` restoration disabled. This keeps visible
geometry and collision on the same interpolated transform.

## ANCHOR puzzle loop

ANCHOR preserves one eligible target's discrete state relation. Applying it does
not modify world state, the four state profiles, `base_position`, or `base_scale`.
The director substitutes the target's saved state profile while every normal
object continues resolving from the active world profile.

Single-active-anchor semantics are used. Applying ANCHOR to another target would
release the previous target. Re-applying it to the current target replaces the
saved state relation, allowing recovery from a wrong-state experiment without a
restart.

The puzzle uses an intentionally impossible normal alignment:

- The eligible gate is a mid-layer object at base radius `17.0`. Its State-1
  radius is `17.0 × 1.07 = 18.19`.
- The Fragment receiver is an outer-layer object at base radius `15.158333`.
  Its State-2 radius is `15.158333 × 1.20 ≈ 18.19`.
- Normal State 2 places the gate at `19.72`, leaving the receiver misaligned.
- ANCHOR allows the gate's State-1 relation and the receiver's State-2 relation
  to coexist. Only this cross-state alignment stabilizes the Fragment.

The explicit objective flow is:

```text
LEARN_LAW
→ DISCOVER_ANCHOR
→ ANCHOR_TARGET
→ REACH_FRAGMENT
→ ANCHOR_ROUTE
→ TRAVERSE_ROUTE
→ REACH_EXIT
→ RUN_COMPLETE
```

Reaching State 3 once activates the previously dormant ANCHOR object behind the
center. This requires the complete four-state law to be experienced before its
exception is available and makes the first retreat purposeful. A brief geometric
and light expansion makes the newly active object perceptible without naming its
function in UI.

After acquisition, the eligible gate gains one cyan relation ring. Applying
ANCHOR replaces that with two gold invariant rings. When the world changes away
from the saved state, a short translucent echo occupies the gate's deterministic
unanchored destination and a thin trace connects it to the preserved gate. This
echo is presentation-only: it is not registered with the arena, has no collision,
and never participates in target resolution.

Successful cross-state alignment gives the Fragment two geometric stability
rings. Collection does not operate a door. Instead, it makes three previously
dormant outer-boundary shutters eligible for the same ANCHOR amendment.

## Reusable ANCHOR route

Three ordinary outer-wall segments at indices `21`, `27`, and `33` are presented
by anchorable collision shutters. While unanchored, each shutter uses the same
outer-layer profile as its surrounding wall and fills its opening in every
state. All three become eligible together after Fragment collection. Only the
middle lane, at `202.5°`, leads to the Exit pocket; the other two terminate in
readable closed pockets and remain safe reversible experiments.

Each shutter has a visible inward relation rail and interaction handle. The
State-1 handle is approximately `3.76` metres beyond the player's inward
threshold limit, inside the `4.5` metre interaction range. The State-0 handle is
approximately `7.5` metres away and cannot be captured from State 0. This makes
State 1 the earliest physically available preservation point without a UI rule.

The boundary opening is only useful in State 3:

- State-1 ANCHOR places the shutter centre at radius `31.36`.
- The State-3 wall opening reaches radius `35.84`.
- Accounting for shutter and wall depth leaves approximately `2.38` metres of
  radial clearance.
- A State-2 capture leaves approximately `0.06` metres, below the explicit
  `1.0` metre passage requirement and physically too narrow for traversal.

The intended sequence therefore requires retreat from the Fragment's State 2
configuration to State 1, reassignment of the single active anchor, and forward
crossings through States 2 and 3. The preserved shutter stays behind while the
wall moves outward, producing an opening that cannot exist under one normal
world profile. Crossing the opened pocket activates the Exit; reaching the
Fragment alone does not.

Small generated tones distinguish reveal, acquisition, application, resistance,
collection, activation, and completion. Route shutters reuse the same cyan
eligible ring, paired gold invariant rings, and translucent deterministic
relation echo as the first gate.

## Boundary behavior

Forward crossings are inclusive: arriving exactly at a threshold enters it once.
Reverse crossings use a small configurable hysteresis band (`0.008` normalized
progress) so standing or oscillating at a boundary cannot spam transitions.

## Debugging

The overlay exposes state, threshold, distance, normalized progress, radial
movement direction, player position, outer radius ratio, and transition activity.
`F3` toggles both the overlay and threshold rings. Diagnostics are hidden by
default so a blind run cannot read the objective or alignment solution from UI.
A controls-only hint fades after 8.5 seconds; the reticle remains available.

`F4` cycles a translucent visual-only target preview through States 0, 1, 2, 3,
then off. Preview meshes have no collision and never write to runtime transforms.

The overlay includes all near/mid/outer target ratios and linear transition
progress. Transition duration is `0.56` seconds and uses quintic easing, removing
the visible acceleration corners of cubic smoothstep while still resolving
before the closest outer thresholds at normal speed.

It also exposes ANCHOR acquisition/activity/target/state, objective state,
alignment error, Fragment status, route eligibility, physical clearance,
crossing status, Exit status, and the currently aimed interaction. The crosshair
turns amber only when the aimed object can currently accept interaction.

## 5–10 minute manual playtest — no solution

Controls: `WASD` move, mouse look, `E` interact, `R` restart, `Esc` release the
mouse. Leave F3/F4 diagnostics enabled only if you need to diagnose a problem.

1. Establish how the cyan, violet, and outer-wall references respond while
   moving outward through all four states.
2. Inspect the distinct gate and the nearby receiver/Fragment arrangement.
3. Look back toward and beyond the gold center; investigate any presentation
   change you notice.
4. Experiment with ANCHOR and movement until the Fragment stabilizes.
5. Collect the Fragment and inspect what changes at the outer boundary.
6. Reuse ANCHOR and movement until a physical route exists, then complete the
   run. Press `R` afterward to verify a clean restart.

Answer:

1. Did you understand what ANCHOR changed?
2. Did the anchored gate visibly disobey the rest of the world?
3. Did ANCHOR feel like breaking a learned rule rather than using a key?
4. Was the solution derived through spatial reasoning rather than guessing?
5. Did backward movement remain meaningful?
6. Did reassigning ANCHOR feel like applying a reusable law rather than finding
   another key?

## Spoiler — intended solution

1. Walk outward until State 3. Observe the full spatial law and that the special
   gate and violet receiver do not align; this also activates the ANCHOR pickup
   behind the center.
2. Retreat through the previous states and acquire the glowing ANCHOR object with
   `E` beyond the gold center.
3. Return outward to State 1. Aim at either illuminated side of the eligible gate
   and press `E`. Its gold invariant ring indicates the saved State-1 relation.
4. Continue into State 2. The receiver moves to the gate while the anchored gate
   resists the transition. The Fragment becomes bright and stable.
5. Aim through the center of the gate and press `E` to collect the Fragment.
6. Turn toward the three cyan shutter handles on the opposite side of the arena.
   The middle lane is identified spatially by concentric rings in its outer
   pocket; the flanking pockets terminate blankly.
7. Retreat into State 1 and apply ANCHOR to that middle shutter's inward handle.
   This releases the first gate and preserves the shutter at radius `31.36`.
8. Move outward through States 2 and 3. Go around the parked shutter and through
   the opening left behind when the boundary recedes.
9. Crossing into the pocket activates the green Exit. Aim at it and press `E`.
