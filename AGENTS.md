# AGENTS.md — ZENO agent operating rules

Read in order:

1. `AXIOMATA.md`
2. `GAME_BRIEF.md`
3. relevant code
4. relevant tests/debug tooling

`AXIOMATA.md` is law.  
`GAME_BRIEF.md` is direction.  
This file is procedure.

## Prime directive

You are working on **ZENO**, not a generic puzzle game.

Before proposing or implementing a feature, ask:

> How does this interact with distance, scale, proportion, world state, topology, persistence or spatial transformation?

If the answer is weak, the feature probably does not belong.

## Stack

```text
Godot 4.x
GDScript
```

Prefer:

- small scripts;
- explicit responsibilities;
- composition;
- signals;
- Resources/data-driven configuration;
- deterministic systems;
- reusable scenes;
- debug visibility.

Avoid:

- god objects;
- giant manager scripts;
- deep inheritance trees;
- hidden side effects;
- excessive autoloads;
- premature frameworks;
- gameplay logic embedded in presentation;
- unrelated refactors.

## Canonical flow

```text
PLAYER MOVEMENT
↓
ZenoThresholdSystem
↓
WorldStateController
↓
TransformationDirector
↓
Geometry / Visuals / Audio / Interactables / Operators
```

Individual scene objects must not independently implement contradictory Zeno logic.

## Before coding

1. Read relevant docs.
2. Inspect current implementation.
3. Make the smallest change satisfying the task.
4. Preserve working behavior.
5. Avoid unrelated cleanup.
6. Prefer configuration over magic numbers.
7. Keep behavior deterministic when practical.
8. Preserve backward traversal.
9. Maintain debug visibility.
10. Test exact threshold boundaries and direction reversals.

## Suggested repository structure

```text
res://
├── scenes/
│   ├── player/
│   ├── world/
│   ├── interactables/
│   ├── operators/
│   ├── effects/
│   ├── ui/
│   └── debug/
├── scripts/
├── resources/
├── shaders/
├── materials/
├── audio/
├── assets/
├── tests/
└── docs/
```

## Signals

Prefer signals for loosely coupled reactions.

Conceptual examples:

```text
threshold_entered(index)
threshold_exited(index)
movement_direction_changed(direction)
world_state_changed(previous, current)
operator_activated(operator_id)
operator_expired(operator_id)
objective_changed(objective_id)
run_reset(seed)
```

## Operators

Operators should be data-driven where practical.

Potential categories:

```text
PRESERVE
INVERT
TRANSFER
BREAK
TEMPORAL_STATE
```

Potential fields:

```text
id
display_name
category
duration
target_type
affected_rule
parameters
visual_profile
audio_profile
conflicts
```

Do not implement Operators as arbitrary one-off hacks inside unrelated scene scripts.

## Puzzle agent rules

A valid puzzle should ideally require at least one of:

- approaching;
- retreating;
- revisiting a location in another state;
- manipulating scale;
- preserving a relation;
- violating a relation;
- exploiting state history;
- applying an Operator.

Preferred cognitive loop:

```text
OBSERVE
↓
HYPOTHESIZE
↓
MOVE
↓
WORLD REACTS
↓
REVISE
↓
DELIBERATELY MANIPULATE
↓
SOLVE
```

## Art agent rules

Visual transformation must communicate state.

Prefer meaningful deformation, scale shifts, recursion, controlled fog, negative space, strong silhouettes and state-linked materials.

Reject random glitch and decoration with no relation to mechanics.

## QA agent rules

Always test both forward and backward traversal.

Test:

- exact threshold entry/exit;
- oscillation around thresholds;
- rapid reversals;
- duplicate transitions;
- scaling/collision;
- Operator activation/expiration/conflicts;
- reset during transformations;
- same seed reproducibility;
- puzzle solvability;
- soft-locks.

## Debug requirements

Expose where useful:

```text
seed
current_state
previous_state
threshold_index
distance_to_center
normalized_edge_progress
movement_direction
player_scale
world_scale
active_operator
active_objective
```

## Rejection criteria

Question or reject work that becomes:

- generic combat;
- generic stamina;
- generic inventory;
- generic loot;
- generic crafting;
- arbitrary procedural noise;
- decorative shader demo;
- asset-pack showcase;
- generic power-up system.

## Final decision rule

When two implementations both work, prefer the one that makes the player think:

> Space itself is the machine I am operating.
