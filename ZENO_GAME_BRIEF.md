# ZENO — Game Concept & LLM Development Brief

> Working title: **ZENO**
>
> Status: pre-production / 7-day vertical slice
>
> Development approach: **AI-assisted / vibe-coded**, with human direction over game feel, visual identity, scope and final decisions.

---

## 0. PURPOSE OF THIS DOCUMENT

This file is the **source of truth for AI agents working on the project**.

Any coding agent, design agent, level-design agent, art-direction agent or planning agent should read this document before proposing or implementing changes.

### Agent priority order

When making a decision, use this priority:

1. Preserve the core spatial mechanic.
2. Preserve game feel.
3. Preserve visual identity.
4. Keep the prototype small.
5. Prefer reusable systems over handcrafted content.
6. Avoid unnecessary complexity.
7. Never add systems only because they are common in games.

If an implementation conflicts with the core concept, the implementation must change.

---

# 1. HIGH-LEVEL CONCEPT

**ZENO** is an experimental spatial puzzle/exploration game inspired by **Zeno's paradoxes of motion**.

The player exists inside a circular or bounded world and attempts to reach its apparent edge.

However, approaching the edge does not behave normally.

As the player crosses spatial thresholds:

- the player may shrink;
- the world may expand;
- geometry may distort;
- previously distant objects may become reachable;
- previously reachable objects may move away;
- new structures may appear;
- old structures may change scale;
- traversal relationships may be rewritten.

The player is therefore not simply moving through space.

**Movement changes the rules and geometry of space itself.**

The world should feel reactive rather than psychedelic for its own sake.

---

# 2. CORE FANTASY

The fantasy is:

> "I am trying to reach the edge of a world that keeps redefining distance."

The emotional progression should roughly be:

1. Curiosity.
2. Confusion.
3. Recognition of a pattern.
4. Learning to manipulate the pattern.
5. Mastery.
6. Realization that reaching the edge may be mathematically impossible.
7. Discovery that the real goal may be to break, invert or exploit the rule.

---

# 3. CORE DESIGN PILLAR

## Movement is the puzzle.

Do NOT build the game around:

- combat;
- inventory management;
- crafting;
- dialogue trees;
- skill trees;
- traditional platforming;
- quest logs.

The player's main verbs should remain very small.

Initial target:

- Move.
- Look.
- Interact / collect.
- Possibly jump, only if required.
- Possibly activate one special world-manipulation ability later.

The complexity should come from **what movement does to the world**, not from complicated controls.

---

# 4. ZENO RULE

The primary conceptual sequence is:

```text
1
1/2
1/4
1/8
1/16
1/32
...
```

As the player approaches an apparent destination, they cross increasingly smaller logical intervals.

Each interval can trigger a new **world state**.

Example:

```text
Player moves toward boundary
        ↓
Crosses threshold
        ↓
Scale state changes
        ↓
World transforms
        ↓
Object relationships change
        ↓
Player reevaluates route
```

The mathematical concept does not need to be physically accurate.

It must be **perceptually coherent**.

The player should eventually understand:

> "Every time I make progress, the meaning of distance changes."

---

# 5. PRIMARY GAMEPLAY LOOP

```text
OBSERVE
↓
MOVE
↓
TRIGGER SPATIAL TRANSFORMATION
↓
NOTICE NEW POSSIBILITY
↓
COLLECT / ACTIVATE SOMETHING
↓
MOVE FORWARD OR BACKWARD
↓
TRIGGER ANOTHER TRANSFORMATION
↓
RECONFIGURE THE WORLD
↓
SOLVE OBJECTIVE
```

Important:

Backward movement must sometimes be strategically useful.

The game must teach the player that:

> Progress does not always mean moving toward the edge.

---

# 6. EXAMPLE PUZZLE

Initial state:

- Fragment A is visible but unreachable.
- Fragment B is behind the player.
- A gate exists near the edge.

### Sequence

```text
START
↓
Walk toward edge
↓
World expands
↓
Fragment A moves farther away
↓
Structure behind player shrinks
↓
Walk backward
↓
Reach Fragment B
↓
Collect Fragment B
↓
Fragment B alters next world transition
↓
Walk forward again
↓
World transforms differently
↓
Fragment A becomes reachable
↓
Collect Fragment A
↓
Gate changes state
```

This is the target style of puzzle.

The player solves **relationships between states**, not conventional locked-door puzzles.

---

# 7. WORLD STATE MODEL

Avoid continuous arbitrary chaos.

World transformations should be understandable enough for players to learn them.

Use discrete or semi-discrete states.

Example:

```text
Scale State 0
Scale State 1
Scale State 2
Scale State 3
Scale State 4
...
```

Possible state variables:

```text
world_scale
player_scale
geometry_variant
object_visibility
object_scale
object_position
gravity
fog_density
audio_state
color_state
shader_intensity
spawn_seed
```

Different maps can assign different behavior to the same state system.

---

# 8. REPLAYABILITY

Randomizing object locations alone is NOT enough.

Replayability should come from randomized or recombined **relationships**.

Potential run variables:

```text
MAP SEED

+

WORLD RULE SET

+

OBJECTIVE SET

+

OBJECT DEPENDENCIES

+

SPATIAL EVENTS

+

VISUAL VARIATIONS
```

Example:

```text
Run A:
Approach → world expands
Retreat → world rotates
Fragment A → freezes scale
Fragment B → reveals hidden geometry

Run B:
Approach → player shrinks
Retreat → objects grow
Fragment A → reverses thresholds
Fragment B → duplicates anchor points
```

The long-term design can become a spatial puzzle roguelite.

The 7-day prototype does NOT need full roguelite systems.

---

# 9. MAPS, NOT LEVELS

Avoid presentation such as:

```text
LEVEL 1
LEVEL 2
LEVEL 3
```

Use persistent or revisitable spatial domains.

Possible terminology:

- Domains
- Spheres
- Chambers
- Fragments
- Fields
- Paradoxes
- Regions
- Spaces

Example world structure:

```text
                 [VOID]
                   ○

      [GARDEN] ○   ●   ○ [MACHINE]

               ○       ○
            [FLESH] [TEMPLE]
```

The center can eventually become a hub.

Each domain should be defined by a **spatial rule**, not simply a visual theme.

---

# 10. POSSIBLE DOMAINS

These are future ideas, not requirements for the first prototype.

## THE VOID

Core idea:

Distance itself becomes unreliable.

Visuals:

- minimal;
- large negative space;
- sparse geometry;
- extreme depth cues;
- distant structures.

---

## THE GARDEN

Core idea:

Organic structures react to distance.

Possible behavior:

- plants grow when the player retreats;
- roots create paths;
- flowers act as anchors;
- geometry appears alive without becoming horror.

---

## THE MACHINE

Core idea:

Space subdivides mathematically.

Possible behavior:

- recursive architecture;
- modular mechanical structures;
- repeating geometry;
- impossible machinery.

---

## THE TEMPLE

Core idea:

Scale creates monumentality.

Possible behavior:

- a tiny object at one state becomes architecture at another;
- statues become rooms;
- glyphs become paths.

---

## THE FLESH

Potential later experimental domain.

Core idea:

Organic spatial transformation.

Constraint:

Avoid generic body-horror aesthetics unless explicitly chosen later.

---

# 11. VISUAL DIRECTION

Target:

**minimal, strange, sophisticated, reactive, architectural.**

Avoid:

- generic cyberpunk;
- generic synthwave;
- excessive neon;
- rainbow psychedelic effects;
- cheap glitch effects;
- generic liminal-space imitation;
- generic sci-fi Asset Store appearance.

Desired qualities:

- strong silhouettes;
- large areas of negative space;
- dramatic scale;
- controlled palette;
- geometric repetition;
- subtle surrealism;
- high contrast where useful;
- motion that responds to player movement.

The environment should feel like an **intelligent spatial system**.

---

# 12. VISUAL TRANSFORMATION PRINCIPLES

World changes should have visual causality.

When possible:

```text
player action
→ visual anticipation
→ transformation
→ stable new state
```

Avoid completely random visual noise.

Useful techniques:

- dynamic scale;
- shader deformation;
- procedural material parameters;
- fog changes;
- FOV changes;
- object interpolation;
- geometry morphing;
- procedural repetition;
- recursive shapes;
- particle movement;
- audio-reactive environmental response;
- controlled post-processing.

---

# 13. ASSET STRATEGY

Purchased or free assets are allowed.

Prefer assets that support the game's identity rather than dictate it.

Good purchases:

- shaders;
- materials;
- VFX;
- particles;
- sky systems;
- sound libraries;
- abstract textures;
- modular geometry;
- procedural tools.

Use caution with:

- complete environment packs;
- fully themed sci-fi cities;
- recognizable asset-store architecture;
- assets that force the project into another game's visual language.

Goal:

> Buy primitives and systems, not identity.

---

# 14. AUDIO DIRECTION

Audio is important because scale changes should be felt before they are fully understood.

Potential techniques:

- pitch shifting with scale;
- granular stretching;
- low-frequency ambience;
- reverb changing with perceived world size;
- motifs recurring at altered speed;
- sounds moving between near/far states;
- spatial audio anchors.

Each threshold can have a subtle sonic signature.

Avoid constant loud effects.

Silence and sparse ambience are useful.

---

# 15. UI PRINCIPLES

UI should be extremely minimal.

Avoid:

- standard quest markers;
- minimap;
- conventional HUD;
- floating objective arrows;
- inventory grids.

Potential subtle indicator:

```text
1
1/2
1/4
1/8
1/16
...
```

The sequence may gradually appear as the player understands the system.

The game should initially allow the player to **discover the rule before explaining it**.

---

# 16. NARRATIVE PRINCIPLE

Narrative should emerge from the spatial rule.

Do not write a large lore document before the core mechanic works.

Potential long-term premise:

> The player believes the objective is to reach the edge.

But:

```text
90%
95%
97.5%
98.75%
99.375%
...
```

The player can always get closer.

Never arrive.

The real objective may eventually become:

> Break the rule.

Possible narrative themes:

- infinity;
- asymptotic progress;
- obsession;
- unreachable goals;
- recursion;
- limits;
- perception;
- continuity;
- mathematical reality versus human intuition.

Narrative must remain secondary to gameplay during the prototype.

---

# 17. FIRST PROTOTYPE — DEFINITION

The first prototype is NOT the full game.

Target:

> A polished 10-minute vertical slice that proves moving through the world is interesting.

Required:

```text
1 controllable player

1 domain

1 circular / bounded environment

1 Zeno threshold system

3+ world states

3 interactable / collectible objects

1 small spatial puzzle

1 completion condition

1 procedural or randomized element

basic sound

strong visual treatment
```

---

# 18. FIRST PROTOTYPE — NON-GOALS

Do NOT implement during the initial 7-day slice unless absolutely necessary:

- multiplayer;
- online services;
- accounts;
- save cloud;
- achievements;
- crafting;
- inventory system;
- skill tree;
- combat;
- enemies;
- complex NPCs;
- dialogue system;
- procedural infinite world;
- ten maps;
- full roguelite progression;
- large narrative campaign;
- cosmetics;
- monetization;
- leaderboard.

---

# 19. RECOMMENDED SYSTEM ARCHITECTURE

Exact names can change based on engine.

Conceptual modules:

```text
PlayerController

WorldStateController

ZenoThresholdSystem

WorldScaleController

TransformationDirector

InteractableSystem

ObjectiveManager

ProceduralSpawner

SeedManager

VisualStateController

AudioStateController

GameSessionManager
```

---

# 20. RESPONSIBILITIES

## PlayerController

Responsible for:

- movement;
- camera;
- interactions;
- player-local state.

Must NOT own global world transformation logic.

---

## ZenoThresholdSystem

Responsible for detecting conceptual progress toward or away from the boundary.

Example outputs:

```text
current_threshold
previous_threshold
movement_direction
normalized_edge_progress
```

Should emit events.

Example:

```text
OnThresholdEntered(3)
OnThresholdExited(3)
OnDirectionChanged(TowardCenter)
```

---

## WorldStateController

Single source of truth for current spatial state.

Example:

```text
state_index = 3
world_scale = 8.0
player_scale = 0.5
geometry_variant = B
```

Other systems react to this state.

---

## TransformationDirector

Coordinates transitions between world states.

It should control timing rather than letting every object independently animate itself.

Responsibilities:

- transition duration;
- interpolation;
- sequencing;
- transition lock;
- visual synchronization;
- event dispatch.

---

## InteractableSystem

Generic base for:

- fragments;
- anchors;
- switches;
- modifiers;
- artifacts.

Interactables should be able to react to world state.

Example:

```text
Visible only in State 2
Collectible only in State 3
Position variant changes in State 4
```

---

## ObjectiveManager

Tracks the current puzzle objective.

Prototype example:

```text
Collect Fragment A
Collect Fragment B
Activate Anchor
Reach Exit
```

Avoid hardcoding progression directly into scene objects.

---

## ProceduralSpawner

Prototype responsibility:

Randomize a limited number of safe variables.

Example:

- choose one of N spawn points;
- choose objective order;
- choose one environmental variant.

Do NOT attempt fully procedural level generation in week one.

---

## SeedManager

Stores run seed.

Goal:

Same seed → same prototype configuration.

Useful for:

- debugging;
- sharing interesting runs;
- deterministic testing.

---

## VisualStateController

Controls:

- materials;
- fog;
- post processing;
- environmental visual parameters;
- shader intensity;
- lighting transitions.

---

## AudioStateController

Controls:

- ambience;
- transition sounds;
- pitch;
- filtering;
- reverb;
- state-specific audio parameters.

---

# 21. EVENT-DRIVEN FLOW

Prefer:

```text
Player moves
↓
ZenoThresholdSystem detects threshold
↓
WorldStateController changes state
↓
TransformationDirector starts transition
↓
Visual / Audio / Geometry systems react
↓
Objective state reevaluated
```

Avoid deeply coupling player movement directly to individual objects.

---

# 22. DATA-DRIVEN DESIGN

Whenever possible, world states should be data.

Example conceptual structure:

```yaml
state: 3

player_scale: 0.50
world_scale: 4.0

fog:
  density: 0.15

geometry:
  variant: recursive_a

audio:
  pitch: 0.85

objects:
  fragment_a:
    visible: true

  fragment_b:
    visible: false
```

The actual implementation format depends on engine.

Data-driven configuration is strongly preferred because AI agents can iterate safely without rewriting core logic.

---

# 23. RANDOMIZATION RULE

Randomness must preserve solvability.

Never randomize arbitrary positions without validating paths.

Preferred strategy for prototype:

```text
Hand-authored valid slots
+
Random selection among valid slots
```

Example:

```text
Fragment A possible locations:
A1
A2
A3

Fragment B possible locations:
B1
B2

Exit possible states:
State 3
State 4
```

All supported combinations must be solvable.

---

# 24. GAME FEEL REQUIREMENTS

Movement should feel good even in an empty room.

Before adding content, validate:

- acceleration;
- deceleration;
- camera sensitivity;
- FOV;
- collision;
- step handling;
- motion smoothing;
- threshold transition smoothness.

Avoid using screen shake as a substitute for feedback.

---

# 25. PLAYER COMPREHENSION

The player should initially be confused about **why** things happen, but not confused about **whether their input worked**.

Good confusion:

> "Why did the tower become huge?"

Bad confusion:

> "Did the game bug?"

World transitions therefore require consistent visual and audio language.

---

# 26. SUCCESS CRITERIA FOR THE CORE MECHANIC

The prototype succeeds if a new player eventually discovers:

1. Movement changes the world.
2. Moving backward can be useful.
3. The same location can have different meanings at different scales.
4. Objects can be manipulated indirectly through movement.
5. The edge cannot be approached normally.

Ideal player reaction:

> "Oh. I understand what the game wants me to think about."

---

# 27. FAILURE CONDITIONS

The prototype is failing if:

- transformations feel random;
- the player cannot predict anything;
- visuals obscure navigation;
- the puzzle could work identically without the Zeno mechanic;
- the world transformation is only cosmetic;
- movement is tedious;
- randomization creates impossible runs;
- the game feels like an asset pack demo.

---

# 28. 7-DAY DEVELOPMENT PLAN

## DAY 1 — CORE MOVEMENT + TEST ARENA

Build:

- project;
- player controller;
- camera;
- circular arena;
- visible boundary;
- debug UI;
- basic interaction system.

Goal:

Movement feels acceptable.

---

## DAY 2 — ZENO SYSTEM

Build:

- threshold calculation;
- world-state transitions;
- player/world scaling;
- forward/backward detection;
- debug visualization.

Goal:

Walking toward and away from the boundary visibly changes the world.

---

## DAY 3 — FIRST REAL PUZZLE

Build:

- 3 interactables;
- state-dependent visibility;
- state-dependent reachability;
- objective logic;
- completion state.

Goal:

Create one puzzle that requires both forward and backward movement.

---

## DAY 4 — ART DIRECTION

Replace prototype look with a coherent visual identity.

Add:

- materials;
- lighting;
- fog;
- shaders;
- environmental geometry;
- transition effects.

Goal:

A screenshot should already look like a recognizable game.

---

## DAY 5 — AUDIO + REACTIVITY

Add:

- ambient layer;
- threshold sounds;
- environmental audio;
- scale-reactive audio;
- visual/audio synchronization.

Goal:

World transformation feels physical.

---

## DAY 6 — REPLAYABILITY

Add limited procedural variation:

- deterministic seed;
- randomized valid spawn slots;
- randomized puzzle dependency or transformation modifier;
- reset/new-run flow.

Goal:

Two runs should not be completely identical.

---

## DAY 7 — POLISH

Do NOT add major systems.

Focus only on:

- bugs;
- game feel;
- transitions;
- onboarding;
- performance;
- visual consistency;
- audio balance;
- build/package;
- first 10-minute experience.

Goal:

A playable vertical slice.

---

# 29. AGENT WORKFLOW

Agents should work in isolated responsibilities.

Suggested roles:

```text
GAMEPLAY AGENT
Core movement and interaction.

SPATIAL SYSTEMS AGENT
Zeno thresholds and world states.

PUZZLE DESIGN AGENT
Creates puzzles using spatial transformations.

PROCEDURAL AGENT
Seeds, variation and valid randomization.

ART DIRECTION AGENT
Visual language, shaders, materials and composition.

AUDIO AGENT
Adaptive audio system and sound direction.

QA AGENT
Tests state transitions, edge cases and solvability.

ARCHITECTURE AGENT
Reviews coupling, maintainability and system boundaries.
```

One agent may perform multiple roles.

---

# 30. INSTRUCTIONS FOR CODING AGENTS

Before modifying code:

1. Read this document.
2. Inspect existing architecture.
3. Identify the smallest system that satisfies the request.
4. Preserve existing working behavior.
5. Avoid unrelated refactors.
6. Prefer configurable values over magic numbers.
7. Keep gameplay systems deterministic when possible.
8. Document new public interfaces.
9. Add debug tooling for spatial systems.
10. Test backward traversal, not only forward traversal.

When uncertain:

> favor the simplest implementation that preserves the core mechanic.

---

# 31. INSTRUCTIONS FOR DESIGN AGENTS

Do NOT propose mechanics solely because they are common or commercially successful.

Every proposed mechanic should answer:

```text
How does this interact with changing distance, scale, space or world state?
```

If the answer is:

> "It doesn't."

The mechanic probably does not belong in the prototype.

---

# 32. INSTRUCTIONS FOR ART AGENTS

Every visual recommendation should consider:

- readability;
- scale;
- state transitions;
- negative space;
- silhouettes;
- transformation potential.

Avoid decoration that does not reinforce the spatial concept.

Prioritize visual systems that can produce many states from few assets.

---

# 33. INSTRUCTIONS FOR PUZZLE AGENTS

A valid ZENO puzzle should ideally require at least one of:

- approaching something;
- retreating from something;
- changing scale intentionally;
- revisiting the same location in another state;
- manipulating one object indirectly through another state;
- exploiting a transformation rule.

Preferred pattern:

```text
Observation
→ hypothesis
→ movement
→ world reaction
→ revised hypothesis
→ deliberate manipulation
→ solution
```

---

# 34. QA CHECKLIST

For every puzzle/state combination verify:

### Movement

- [ ] Forward movement works.
- [ ] Backward movement works.
- [ ] Threshold crossing cannot soft-lock the player.
- [ ] Player cannot fall outside the playable world unexpectedly.
- [ ] Scale changes do not break collision.

### State

- [ ] State transitions happen exactly once per crossing.
- [ ] Rapid threshold crossing does not corrupt state.
- [ ] Reversing direction behaves correctly.
- [ ] Reset returns to deterministic initial state.

### Objects

- [ ] Required objects remain obtainable.
- [ ] Object transforms do not place them inside geometry.
- [ ] Objects cannot be collected twice unless intended.
- [ ] State-dependent objects correctly restore previous states.

### Procedural Generation

- [ ] Same seed reproduces same run.
- [ ] All valid seeds remain solvable.
- [ ] No objective spawns outside reachable states.

### Presentation

- [ ] Player understands when a transformation occurred.
- [ ] Transition does not look like a rendering bug.
- [ ] Visual effects do not hide critical objects.

---

# 35. DEBUG REQUIREMENTS

Spatial systems must be inspectable.

Debug overlay should ideally expose:

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
active_objective
```

Optional:

Render threshold rings in debug mode.

---

# 36. FIRST TECHNICAL SPIKE

Before building the whole prototype, prove this:

```text
A player walks toward the edge of a circle.

At 50% apparent progress:
the world changes scale.

The player continues.

At the next threshold:
the world changes again.

The player turns around.

Crossing the thresholds backward restores or changes the world coherently.
```

If this interaction is not satisfying, stop adding content and improve it.

---

# 37. MVP PUZZLE SPEC

Prototype objects:

```text
ANCHOR
FRAGMENT A
FRAGMENT B
EXIT
```

Suggested logic:

```text
State 0:
Fragment A visible but unreachable.
Fragment B hidden.
Exit locked.

State 1:
Fragment A moves farther away.
Fragment B becomes visible behind player.

State 2:
Fragment B becomes reachable.

Collect Fragment B:
Next forward transformation becomes modified.

Modified State 1:
Fragment A becomes reachable.

Collect Fragment A:
Anchor activates.

Activate Anchor:
Exit becomes stable.

Reach Exit:
Prototype complete.
```

This is only a starting implementation.

Iterate based on play feel.

---

# 38. POTENTIAL LONG-TERM META

Do not implement yet.

Possible later structure:

```text
Choose Domain
↓
Generate Seed
↓
Enter Spatial Puzzle Run
↓
Collect Fragments
↓
Discover Rule Modifier
↓
Complete / Break Domain
↓
Return to Hub
↓
Unlock new paradox interactions
```

---

# 39. POSSIBLE RULE MODIFIERS

Future examples:

```text
INVERT
Forward behaves like backward.

ANCHOR
One object ignores world scaling.

MIRROR
Two regions transform oppositely.

FREEZE
One state variable stops changing.

ECHO
Previous state briefly remains visible.

RECURSE
Geometry repeats within itself.

PHASE
Objects exist only between thresholds.
```

---

# 40. DESIGN NORTH STAR

When choosing between two implementations, prefer the one that makes the player think:

> "Space itself is the machine I am operating."

That is the core identity of ZENO.

---

# 41. CURRENT PROJECT QUESTION

The immediate development question is NOT:

> How do we build the entire game?

It is:

> Can one spatial rule based on Zeno's paradox produce ten minutes of satisfying exploration and puzzle-solving?

Everything in the first week should exist to answer that question.

---

# 42. DEFINITION OF DONE — WEEK ONE

The first week is complete when:

- [ ] The game launches into a playable environment.
- [ ] Movement feels intentional.
- [ ] The player can approach and retreat from the edge.
- [ ] At least three spatial states exist.
- [ ] The world transforms clearly between those states.
- [ ] At least one puzzle requires manipulating those states.
- [ ] Backtracking is mechanically meaningful.
- [ ] A run can be completed.
- [ ] At least one aspect of the run changes between seeds.
- [ ] Visual identity is coherent.
- [ ] Audio reacts to world state.
- [ ] Debug information exists.
- [ ] A standalone build can be played without the editor.

---

# 43. FUTURE QUESTIONS

Do not block prototype development on these.

Later decisions:

- engine;
- final title;
- first-person vs third-person;
- exact visual palette;
- narrative framing;
- number of domains;
- persistence;
- progression system;
- degree of procedural generation;
- commercial release strategy;
- Steam integration;
- achievements;
- controller support;
- accessibility options;
- save system.

---

# 44. FINAL AGENT DIRECTIVE

You are working on **ZENO**, not a generic puzzle game.

Before proposing a feature, ask:

1. Does it strengthen the relationship between movement and world transformation?
2. Does it make spatial reasoning more interesting?
3. Can it be implemented without bloating the 7-day prototype?
4. Does it reinforce the game's visual and conceptual identity?

If the answer is no, omit it.

The first goal is not content volume.

The first goal is to make **crossing one invisible line in space feel profound**.
