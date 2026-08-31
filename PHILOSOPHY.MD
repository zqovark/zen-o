# zen-o

# AXIOMATA — the design law for every ZENO world

*v0.1 doctrine. ZENO does not ask the player to cross space. It asks the player to understand what space believes about crossing.*

Most games treat distance as empty accounting.

Ten meters are ten meters.
A wall is a wall.
Near is near.
Far is far.

Nobody questions this because games inherited space from reality, then inherited the interface from other games.

ZENO inherits neither.

Every distance must earn its meaning.

Every transformation must reveal a law.

Every law must eventually admit the possibility of being broken.

The world is not scenery around the puzzle.

**The world is the puzzle.**

---

# The eight laws

## 1. Space is never neutral

In ZENO, movement cannot exist only to transport the player from one useful thing to another.

Every meaningful traversal must interact with at least one of:

* distance;
* scale;
* proportion;
* orientation;
* state;
* visibility;
* persistence;
* topology.

If the player can walk through a space and nothing about the relationship between things matters, that space is decorative.

Decorative space is allowed only when it prepares, contrasts or reveals mechanical space.

The default question is:

> What does moving through this region do to the truth of the world?

---

## 2. First teach the invariant. Then violate it.

A broken rule has no meaning until the player has learned the rule.

The player must first experience:

```text
THIS ALWAYS HAPPENS
```

Then understand:

```text
I CAN PREDICT THIS
```

Only then may the game reveal:

```text
EXCEPT HERE
```

Operators exist under this law.

ANCHOR means nothing until scaling has become inevitable.

INVERSE means nothing until direction has become meaningful.

COLLAPSE means nothing until the player understands that intermediate states should exist.

The sequence is sacred:

```text
OBSERVE
↓
RECOGNIZE
↓
PREDICT
↓
MANIPULATE
↓
VIOLATE
```

Never give the player an exception before they understand what it is excepting.

---

## 3. Transformation must be causally legible

The world may be strange.

It may not be arbitrary.

Every transformation should preserve enough causality that the player can form a hypothesis.

Bad transformation:

> I walked and random things happened.

Good transformation:

> When I crossed that distance, everything linked to this rule changed.

Better transformation:

> I know what will happen next, and I can use it.

Visual spectacle is subordinate to mechanical readability.

Shaders, particles, geometry deformation, audio and camera effects must reinforce the state transition.

They must never disguise the state transition.

Confusion about the universe is desirable.

Confusion about whether the game is functioning is failure.

---

## 4. Distance is a relationship, not a measurement

Meters are implementation detail.

The player experiences distance through relationships.

An object can be:

* reachable;
* receding;
* invariant;
* mirrored;
* recursive;
* anchored;
* larger than its location;
* smaller than its appearance;
* near in one state and unreachable in another.

Therefore no system should assume:

```text
distance = position_a.distance_to(position_b)
```

is sufficient to describe gameplay distance.

ZENO may distinguish between:

```text
physical_distance
perceived_distance
state_distance
topological_distance
interaction_distance
scale_distance
```

The numerical value is not the game.

The relationship is.

---

## 5. Backward is a direction, not a failure

Traditional games teach:

```text
forward = progress
backward = correction
```

ZENO rejects this.

Retreat must sometimes be the most intelligent possible move.

Returning to a previous location under a different state is not backtracking.

It is reinterpreting space.

Maps should be designed so that:

```text
same place
+
different world state
=
different possibility
```

If moving backward never creates information, opportunity or transformation, the spatial design is incomplete.

---

## 6. The player operates laws, not switches

A conventional puzzle switch changes an object.

A ZENO interaction should preferably change a relationship or a rule.

Weak:

> Press button → bridge appears.

Stronger:

> Anchor bridge → world scales → bridge preserves proportion → new route exists.

Weak:

> Collect key → door opens.

Stronger:

> Collect operator → an invariant can now be broken → the door becomes reachable under a previously impossible state.

Whenever possible, design interactions as:

```text
PLAYER ACTION
↓
LAW MODIFICATION
↓
WORLD REINTERPRETATION
↓
NEW POSSIBILITY
```

not:

```text
PLAYER ACTION
↓
SCRIPTED REWARD
```

---

## 7. Form follows law

Every Domain must derive its visual form from its governing spatial behavior.

Do not create:

> a forest map with ZENO mechanics.

Create:

> a law of growth expressed as a forest.

Do not create:

> a machine map with recursive decoration.

Create:

> a recursive law whose most natural visual body is machinery.

A Domain is not:

```text
THEME
+
PUZZLE
```

It is:

```text
LAW
↓
GEOMETRY
↓
MOTION
↓
MATERIAL
↓
AUDIO
↓
PUZZLE
```

The law comes first.

The aesthetic is its physical consequence.

---

## 8. The world must survive its own interface

HUD, tutorial text, quest markers and explanatory prose are temporary scaffolding.

The game must remain intelligible through:

* movement;
* geometry;
* relative size;
* rhythm;
* animation;
* light;
* sound;
* persistence;
* change.

If removing the explanatory text destroys the mechanic, the mechanic is under-communicated.

A being that cannot read the language should still be able to perceive:

```text
THIS IS STABLE

THIS IS CHANGING

THESE TWO THINGS ARE LINKED

THIS ACTION CAUSED THAT

THIS REGION OBEYS A DIFFERENT LAW
```

Words may clarify.

Words must not carry the entire system.

---

# The Operator doctrine

Operators are not powers.

They are temporary amendments to reality.

Every Operator must answer four questions:

```text
WHAT LAW EXISTS?

WHAT PART OF THAT LAW DOES THIS OPERATOR BREAK?

WHAT NEW RELATIONSHIP BECOMES POSSIBLE?

HOW DOES THE PLAYER PERCEIVE THAT VIOLATION?
```

If an Operator only makes traversal easier, it is probably not an Operator.

If it could be described as:

* dash;
* speed boost;
* double jump;
* teleport;
* damage buff;

without mentioning a spatial law, reject or redesign it.

Operators should feel like mathematical verbs.

Examples:

```text
ANCHOR
preserve a relation

INVERSE
reverse a relation

MIRROR
couple opposite relations

COLLAPSE
remove an intermediate state

EQUALIZE
force equivalent scale

RECALL
restore a previous state

TRANSFER
move scale from one entity to another

LOCAL INFINITY
instantiate recursion inside recursion
```

The best Operator creates situations that were logically impossible one moment earlier.

---

# The Domain doctrine

Every Domain requires one sentence that defines its law.

Examples:

```text
THE VOID

Distance increases as certainty decreases.
```

```text
THE GARDEN

Growth is proportional to retreat.
```

```text
THE MACHINE

Every crossed interval recursively subdivides structure.
```

```text
THE TEMPLE

Objects become architecture when their relative scale crosses a threshold.
```

If the Domain can only be described visually:

> dark temple with surreal geometry

it is not ready.

The Domain must first exist as a rule.

---

# The puzzle doctrine

Every puzzle should contain a transformation in the player's understanding.

Ideal structure:

```text
OBSERVATION
↓
ASSUMPTION
↓
CONTRADICTION
↓
PATTERN
↓
PREDICTION
↓
DELIBERATE ACTION
↓
VIOLATION OR EXPLOIT
↓
RESOLUTION
```

The player should not merely discover what button to press.

They should discover what is true.

Then use that truth.

A strong puzzle teaches a reusable law.

A stronger puzzle later asks the player to break that law.

---

# The visual doctrine

ZENO is not psychedelic by default.

It is **causally surreal**.

Every distortion should imply structure.

Prefer:

* deformation caused by distance;
* repetition caused by recursion;
* scale shifts caused by thresholds;
* light responding to state;
* materials preserving or violating continuity;
* geometry exposing hidden relations.

Avoid visual noise that cannot be interpreted.

The player should be able to look at a transformation and think:

> Something changed according to a rule.

Not:

> The shader went crazy.

---

# The audio doctrine

Sound should expose invisible structure.

Audio may communicate:

* threshold proximity;
* scale;
* preserved state;
* recursion;
* inversion;
* instability;
* Operator activation.

A transition should often be audible before it is intellectually understood.

Use silence deliberately.

The universe does not need to constantly announce itself.

---

# The code doctrine

Game logic must describe laws independently from presentation whenever possible.

A shader must not secretly determine puzzle logic.

A mesh animation must not secretly determine world state.

A visual node must not become the source of truth for scale rules.

Prefer:

```text
RULE
↓
STATE
↓
TRANSFORMATION
↓
PRESENTATION
```

not:

```text
VISUAL EFFECT
↓
GAMEPLAY SIDE EFFECT
```

Core systems should remain understandable without rendering.

The intended separation is:

```text
ZenoThresholdSystem
WorldStateController
OperatorSystem
TransformationDirector
ObjectiveGraph
```

feeding:

```text
Geometry
Shaders
Audio
Animation
UI
```

The universe should remain logically valid even with every material replaced by gray.

---

# The anti-patterns

Reject or question any feature that becomes:

## THE CORRIDOR

Space exists only to connect content.

## THE BUTTON

An interaction changes something without expressing a law.

## THE FIREWORK

A visual effect communicates spectacle but no state.

## THE KEY

An item exists only to satisfy an arbitrary lock.

## THE POWER-UP

An Operator becomes a generic convenience ability.

## THE RANDOMIZER

Procedural generation rearranges positions without creating new relationships.

## THE LORE WALL

Text explains something the world itself should demonstrate.

## THE LEVEL

A Domain becomes disposable content completed once and abandoned.

## THE ASSET PACK

Purchased visual identity overrides the game's own grammar.

---

# The verdict scale

Every proposed mechanic, map, puzzle, Operator or visual system receives one verdict.

## AXIOM

The idea expresses ZENO's core grammar directly.

Keep and deepen it.

## PROOF

The idea is valid, but its relationship to a spatial law must become clearer.

Refine it.

## EXCEPTION

The idea is valuable specifically because it breaks an established rule.

Use carefully and only after the invariant is learned.

## ORNAMENT

The idea adds atmosphere but little systemic meaning.

Keep only if it supports pacing, readability or identity.

## FOREIGN BODY

The idea belongs to another game.

Remove it.

---

# The five questions

Before implementing anything significant, ask:

1. **What law does this express?**
2. **How does the player discover that law without being told?**
3. **Can the player predict its behavior after observing it?**
4. **Can this law later be manipulated or violated?**
5. **Would this feature still belong in ZENO if every texture were replaced by white material?**

If those questions have no good answers, stop.

Do not implement yet.

---

# The blank-world test

Replace the entire game visually with:

```text
white floor
gray objects
black sky
```

Remove:

* lore;
* music;
* particles;
* post-processing;
* expensive assets.

Does the interaction remain interesting?

Can the player still perceive:

```text
cause
relation
transformation
possibility
```

If no, the mechanic is being carried by presentation.

Return to the law.

---

# The impossible-place test

Ask of every important location:

> What can happen here that could not happen in ordinary Euclidean space?

If the answer is nothing, the location must justify itself through preparation, contrast or recovery.

ZENO's most important places should feel impossible not because they look strange, but because their relationships cannot exist under ordinary assumptions.

---

# The final law

The player begins by thinking:

> I move through the world.

Then:

> My movement changes the world.

Then:

> The world follows laws.

Then:

> I can operate those laws.

Then:

> Laws are only stable until I find an exception.

ZENO is complete when the player stops thinking of space as a place.

And starts thinking of it as a system.
