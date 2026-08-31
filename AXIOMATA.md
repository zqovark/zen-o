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

- distance;
- scale;
- proportion;
- orientation;
- state;
- visibility;
- persistence;
- topology.

If the player can walk through a space and nothing about the relationship between things matters, that space is decorative.

The default question is:

> What does moving through this region do to the truth of the world?

---

## 2. First teach the invariant. Then violate it.

A broken rule has no meaning until the player has learned the rule.

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

ANCHOR means nothing until scaling has become inevitable.

INVERSE means nothing until direction has become meaningful.

COLLAPSE means nothing until the player understands that intermediate states should exist.

Never give the player an exception before they understand what it is excepting.

---

## 3. Transformation must be causally legible

The world may be strange.

It may not be arbitrary.

Bad transformation:

> I walked and random things happened.

Good transformation:

> When I crossed that distance, everything linked to this rule changed.

Better transformation:

> I know what will happen next, and I can use it.

Visual spectacle is subordinate to mechanical readability.

Confusion about the universe is desirable.

Confusion about whether the game is functioning is failure.

---

## 4. Distance is a relationship, not a measurement

Meters are implementation detail.

The player experiences distance through relationships.

An object can be reachable, receding, invariant, mirrored, recursive, anchored, larger than its location, smaller than its appearance, near in one state and unreachable in another.

No system should assume:

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

```text
same place
+
different world state
=
different possibility
```

Returning is not backtracking when space itself has changed.

---

## 6. The player operates laws, not switches

Weak:

> Press button → bridge appears.

Stronger:

> Anchor bridge → world scales → bridge preserves proportion → new route exists.

Weak:

> Collect key → door opens.

Stronger:

> Collect Operator → an invariant can now be broken → the door becomes reachable under a previously impossible state.

Prefer:

```text
PLAYER ACTION
↓
LAW MODIFICATION
↓
WORLD REINTERPRETATION
↓
NEW POSSIBILITY
```

over arbitrary scripted rewards.

---

## 7. Form follows law

Every Domain must derive its visual form from its governing spatial behavior.

Do not create:

> a forest map with ZENO mechanics.

Create:

> a law of growth expressed as a forest.

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

HUD, tutorial text and quest markers are temporary scaffolding.

The game must remain intelligible through:

- movement;
- geometry;
- relative size;
- rhythm;
- animation;
- light;
- sound;
- persistence;
- change.

A being that cannot read the language should still perceive:

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

Every Operator must answer:

```text
WHAT LAW EXISTS?
WHAT PART OF THAT LAW DOES THIS OPERATOR BREAK?
WHAT NEW RELATIONSHIP BECOMES POSSIBLE?
HOW DOES THE PLAYER PERCEIVE THAT VIOLATION?
```

Operators should feel like mathematical verbs.

```text
ANCHOR       preserve a relation
INVERSE      reverse a relation
MIRROR       couple opposite relations
COLLAPSE     remove an intermediate state
EQUALIZE     force equivalent scale
RECALL       restore a previous state
TRANSFER     move scale between entities
LOCAL_INFINITY instantiate recursion inside recursion
```

The best Operator creates situations that were logically impossible one moment earlier.

---

# The Domain doctrine

Every Domain requires one sentence defining its law.

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

If the Domain can only be described visually, it is not ready.

---

# The puzzle doctrine

Every puzzle should transform the player's understanding.

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

A strong puzzle teaches a reusable law.

A stronger puzzle later asks the player to break it.

---

# The visual doctrine

ZENO is not psychedelic by default.

It is **causally surreal**.

Prefer distortion caused by distance, repetition caused by recursion, scale shifts caused by thresholds, light responding to state, and geometry exposing hidden relations.

The player should think:

> Something changed according to a rule.

Not:

> The shader went crazy.

---

# The audio doctrine

Sound should expose invisible structure.

Audio may communicate:

- threshold proximity;
- scale;
- preserved state;
- recursion;
- inversion;
- instability;
- Operator activation.

Use silence deliberately.

---

# The code doctrine

Game logic must describe laws independently from presentation whenever possible.

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

Core systems:

```text
ZenoThresholdSystem
WorldStateController
OperatorSystem
TransformationDirector
ObjectiveGraph
```

feed:

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

## THE CORRIDOR
Space exists only to connect content.

## THE BUTTON
An interaction changes something without expressing a law.

## THE FIREWORK
A visual effect communicates spectacle but no state.

## THE KEY
An item exists only to satisfy an arbitrary lock.

## THE POWER-UP
An Operator becomes generic convenience.

## THE RANDOMIZER
Procedural generation rearranges positions without creating new relationships.

## THE LORE WALL
Text explains something the world should demonstrate.

## THE LEVEL
A Domain becomes disposable content completed once and abandoned.

## THE ASSET PACK
Purchased visual identity overrides the game's own grammar.

---

# The verdict scale

## AXIOM
Expresses ZENO's core grammar directly.

## PROOF
Valid idea, but its relationship to a spatial law must become clearer.

## EXCEPTION
Valuable specifically because it breaks an established rule.

## ORNAMENT
Atmospheric, but systemically weak. Keep only if it supports pacing/readability/identity.

## FOREIGN BODY
Belongs to another game. Remove it.

---

# The five questions

Before implementing anything significant:

1. **What law does this express?**
2. **How does the player discover that law without being told?**
3. **Can the player predict it after observing it?**
4. **Can this law later be manipulated or violated?**
5. **Would this still belong in ZENO if every texture were replaced by white material?**

---

# The blank-world test

Replace the game with:

```text
white floor
gray objects
black sky
```

Remove lore, music, particles, post-processing and expensive assets.

Does the interaction remain interesting?

Can the player still perceive cause, relation, transformation and possibility?

If no, return to the law.

---

# The impossible-place test

Ask of every important location:

> What can happen here that could not happen in ordinary Euclidean space?

ZENO's important places should feel impossible because their relationships are impossible, not merely because they look strange.

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
