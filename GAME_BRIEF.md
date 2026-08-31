# GAME BRIEF — ZENO

## Premise

ZENO is an experimental 3D spatial puzzle/exploration game where the player attempts to reach the apparent edge of a world that continuously redefines distance.

As the player crosses spatial thresholds, the world may expand, the player may shrink, geometry may transform, objects may become reachable or unreachable, and the meaning of the same location may change.

## Core fantasy

> I am trying to reach the edge of a world that keeps redefining distance.

## Core pillar

> Movement is the puzzle.

Avoid building the experience around combat, crafting, inventory management, generic skill trees or conventional quest structures.

## Zeno rule

Conceptual sequence:

```text
1
1/2
1/4
1/8
1/16
...
```

Crossing meaningful intervals changes the active world state.

```text
MOVE
↓
CROSS THRESHOLD
↓
CHANGE WORLD STATE
↓
CHANGE RELATIONSHIPS
↓
REASSESS ROUTE
```

## Core loop

```text
OBSERVE
↓
MOVE
↓
TRIGGER SPATIAL TRANSFORMATION
↓
NOTICE NEW POSSIBILITY
↓
INTERACT / COLLECT / ACTIVATE
↓
MOVE FORWARD OR BACKWARD
↓
TRIGGER ANOTHER TRANSFORMATION
↓
SOLVE
```

Backward movement must sometimes be progress.

## Operators

Operators are temporary amendments to spatial law, not generic power-ups.

Doctrine:

> First learn the invariant. Then break the invariant.

Initial concepts:

- Anchor — preserve a relation.
- Inverse — reverse a relation.
- Freeze Ratio — preserve the current proportion.
- Scale Theft — transfer scale between entities.
- Mirror — couple opposite transformations.
- Collapse — skip/compress intermediate Zeno states.
- Local Infinity — create a local recursive threshold system.
- Equalize — force equivalent relative scale.
- Residual State — preserve part of a previous state.
- State Recall — temporarily restore a previous state.

A valid Operator must answer:

1. What law exists?
2. What part becomes false?
3. What new relationship becomes possible?
4. How does the player perceive the violation?

## Domains, not levels

Avoid `LEVEL 1 / LEVEL 2 / LEVEL 3`.

Each Domain should be defined first by a spatial law, then by a visual form.

Examples:

- **The Void** — distance becomes unreliable.
- **The Garden** — growth is proportional to retreat.
- **The Machine** — crossed intervals recursively subdivide structure.
- **The Temple** — objects become architecture when relative scale crosses a threshold.

## Visual direction

Minimal, architectural, geometric, strange, sophisticated and causally surreal.

Avoid generic cyberpunk, random glitch, excessive neon, rainbow psychedelia and asset-pack identity.

Preferred identity:

```text
simple geometry
+
lighting
+
materials
+
shaders
+
fog
+
particles
+
scale
+
motion
```

## Architecture

Conceptual systems:

```text
PlayerController
ZenoThresholdSystem
WorldStateController
TransformationDirector
OperatorSystem
InteractableSystem
ObjectiveManager
ProceduralSpawner
SeedManager
VisualStateController
AudioStateController
```

Central rule:

> Do not let individual objects invent their own version of the Zeno rule.

## Vertical slice

Required:

- 1 player
- 1 Domain
- 1 bounded/circular environment
- 1 Zeno threshold system
- 3+ world states
- 3 interactables
- 1 spatial puzzle
- 1 completion condition
- 1 Operator
- deterministic seed
- reactive audio
- strong visual identity
- debug overlay
- standalone build

## North star

> Space itself is the machine I am operating.
