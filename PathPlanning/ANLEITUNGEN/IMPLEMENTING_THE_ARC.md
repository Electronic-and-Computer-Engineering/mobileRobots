[BACK TO CHAPTER 08](08_vehicle_neighbors.md) · [THE GUIDED ROUTE](CORE_ROUTE.md)

# Implementing the arc, statement by statement

This is the long version of step 5 of [chapter 08](08_vehicle_neighbors.md):
how one motion primitive is computed, what each statement is for, and the
numbers your own code has to reproduce.

It contains no solution code. It contains the **reasoning** and the **numbers**,
which is what you need to find your own mistake. If your loop produces the
tables below, your loop is right.

---

## Table of Contents

- [Implementing the arc, statement by statement](#implementing-the-arc-statement-by-statement)
  - [1. What one steering level gives you](#1-what-one-steering-level-gives-you)
  - [2. One step is four statements](#2-one-step-is-four-statements)
  - [3. The full trace at full lock](#3-the-full-trace-at-full-lock)
  - [4. The same arc at half lock](#4-the-same-arc-at-half-lock)
  - [5. Why the middle of the step](#5-why-the-middle-of-the-step)
  - [6. Why the car travels along theta plus beta](#6-why-the-car-travels-along-theta-plus-beta)
  - [7. What the loop leaves behind](#7-what-the-loop-leaves-behind)
  - [8. From a primitive to a neighbour](#8-from-a-primitive-to-a-neighbour)
  - [9. If a number does not match](#9-if-a-number-does-not-match)

---

## 1. What one steering level gives you

Three numbers come out of the steering angle, and none of them changes while the
arc is being walked. Compute them **once per level, before the loop**.

| | formula | at 100 % | at 50 % |
|---|---|---:|---:|
| the wheel angle | $\delta = \delta_{\max} u / 100$ | 22.00° | 11.00° |
| the side slip angle | $\beta = \arctan\!\left(\frac{l_r}{L}\tan\delta\right)$ | 0.19933 rad (11.42°) | 0.09689 rad (5.55°) |
| the turn per metre | $\dfrac{d\theta}{ds} = \dfrac{\cos\beta\,\tan\delta}{L} = \dfrac{1}{R}$ | 3.3002 rad/m | 1.6122 rad/m |
| the radius that is | $R = L / (\cos\beta\,\tan\delta)$ | 0.303 m | 0.620 m |

The arc is cut into `nSub = 4` steps of

$$
\Delta s = \frac{s}{n} = \frac{0.119}{4} = 0.02975\ \text{m}
$$

so **the turn of one step** is $\Delta s / R$, the same in every step:

| | at 100 % | at 50 % |
|---|---:|---:|
| $\Delta s / R$ | 0.09818 rad = 5.63° | 0.04796 rad = 2.75° |

That single number is the whole of the new $\theta$. Everything else in the loop
is bookkeeping.

---

## 2. One step is four statements

In this order, and the order is the point:

| | statement | what it is |
|---|---|---|
| 1 | `thMove` | the heading in the **middle** of this step: `th` plus **half** the step's turn |
| 2 | `th` | the heading at the **end** of this step: `th` plus the **whole** step's turn |
| 3 | `x` | move $\Delta s$ from where you are, in the direction $\theta_m + \beta$ |
| 4 | `y` | the same, with sine instead of cosine |

**Why that order.** Statement 2 overwrites `th`. If you advance it first, the
value statement 1 needed is gone, and you will be using the heading at the *end*
of the step to move through the *middle* of it. That is section 5, and it costs
5.81 mm per arc.

**Why `thMove` and not `th` in statements 3 and 4.** The position step is where
the heading is *used*; `th` is where it is *stored*. They are not the same thing
inside a step, because the car turns continuously while it moves.

Record the pose after every step — all four of them, not just the last. Chapter
08 step 6 tests the car's rectangle at each of them against the walls.

---

## 3. The full trace at full lock

$\delta = +22^\circ$, $\beta = 0.19933$, step turn 0.09818 rad. Start at the
origin, pointing along $+x$:

| after step | `thMove` | `th` | `x` | `y` |
|---|---:|---:|---:|---:|
| 1 | 0.04909 | 0.09818 | 0.02884 | 0.00731 |
| 2 | 0.14727 | 0.19636 | 0.05682 | 0.01742 |
| 3 | 0.24545 | 0.29454 | 0.08367 | 0.03022 |
| 4 | 0.34364 | 0.39273 | **0.10914** | **0.04559** |

The last row is the primitive: `dx = 0.10914`, `dy = 0.04559`,
`dth = 0.39273 rad = 22.502°`. It is the `+22.0` row of the table in chapter 08,
and `check_car_primitives` compares it against the simulator, which agrees to
**0.10 mm**.

Read the `th` column downwards: 0.09818, 0.19636, 0.29454, 0.39273 — four equal
additions of the same number. Read `thMove`: always exactly half a step behind.

---

## 4. The same arc at half lock

$\delta = +11^\circ$, $\beta = 0.09689$, step turn 0.04796 rad:

| after step | `thMove` | `th` | `x` | `y` |
|---|---:|---:|---:|---:|
| 1 | 0.02398 | 0.04796 | 0.02953 | 0.00359 |
| 2 | 0.07195 | 0.09593 | 0.05886 | 0.00859 |
| 3 | 0.11991 | 0.14389 | 0.08791 | 0.01499 |
| 4 | 0.16787 | 0.19186 | **0.11663** | **0.02277** |

Worth noticing: half the steering command gives almost exactly half the turn
(10.99° against 22.50°), but **not** half the sideways offset (2.28 cm against
4.56 cm — which is half, by accident of the small angles) and clearly **not**
half the distance in $x$. Arcs do not scale linearly, which is why they are
computed rather than interpolated.

The $0^\circ$ level needs no trace: $\beta = 0$, the turn is zero, and the
primitive is `dx = 0.119`, `dy = 0`, `dth = 0`.

---

## 5. Why the middle of the step

One sentence first, because it is not a numerical trick: **each step walks the
chord of a little arc, and the chord of a circular arc points exactly half the
arc's turn ahead of the tangent at its start.** The "heading in the middle" is
the direction of the straight line you are walking. Nothing more.

The heading changes *during* the step. Three choices exist for which heading to
move along, and they end in three different places:

| rule | heading used | end of the arc | off |
|---|---|---:|---:|
| start of step | $\theta_i$ | (0.11125, 0.04018) | 5.81 mm |
| **middle of step** | $\theta_i + \tfrac{1}{2}\Delta s/R$ | **(0.10914, 0.04559)** | — |
| end of step | $\theta_{i+1}$ | (0.10678, 0.05089) | 5.81 mm |

Start-of-step bends every arc too late, end-of-step bends it too early, and the
two errors are the same size in opposite directions. The middle cancels them to
first order: with only four steps it lands within 0.10 mm of the simulator,
which walks the same arc in about thirteen small steps of its own.

Note what the error is **not**: the heading comes out right in all three cases —
0.39273 rad, because that is four equal additions whatever you move along. Only
the position is wrong. A check that compares headings alone would pass.

**Could the loop be skipped altogether?** For this model, yes. Held steering
means a circle, and a circle has a closed form: after driving $s$ you have
turned $\theta = s/R$, and you sit one chord away from where you started,

$$
\Delta x = 2R\sin\frac{\theta}{2}\cos\!\left(\beta + \frac{\theta}{2}\right),
\qquad
\Delta y = 2R\sin\frac{\theta}{2}\sin\!\left(\beta + \frac{\theta}{2}\right)
$$

At full lock that gives (0.10910, 0.04557) — 0.11 mm from the simulator, where
the four midpoint steps land 0.13 mm from it. The closed form is marginally
*more* accurate, and it is one line.

Two things keep the loop in the exercise. **`pts`**: the collision test needs
poses *along* the arc, and four of them is what a 22 cm car on an 11.9 cm arc
needs — the loop produces them on the way. And **the circle is a convenience,
not a fact**: the servo takes 0.2 s to reach full lock, so the real arc starts
flatter than a circle. The moment anything changes during a move, the closed
form is gone and stepping is all that is left.

---

## 6. Why the car travels along theta plus beta

The reference point $(x, y)$ is the middle of the body, not the rear axle. The
middle of a steered car does not travel in the direction the car points; it
travels at the side slip angle $\beta$ to it.

Drop $\beta$ from the two position statements, and at full lock the arc ends at
(0.11589, 0.02353) — **23.07 mm** from where the car really goes, in the same
direction every time. The heading also drifts, to 22.956° instead of 22.502°,
because $\cos\beta$ is missing from the turn rate as well.

23 mm per 12 cm of driving is not a rounding error. It is half the car's width
by the end of a corner, and since it is systematic, no amount of margin
elsewhere compensates for it. `check_car_primitives` names this one as `beta`.

---

## 7. What the loop leaves behind

One entry per steering level:

| field | what it is | who uses it |
|---|---|---|
| `.delta` | the wheel angle in degrees | you, when reading output |
| `.dx .dy` | the end of the arc, in the car's own frame | `car_neighbors`, to place the move |
| `.dth` | the heading change | `car_neighbors`, added to $\theta$ |
| `.pts` | the four intermediate poses, same frame | `car_neighbors`, to test the swept body |
| `.len` | the arc length, `P.arc` | the search, as distance |
| `.cost` | `P.arc + P.wSteer * abs(level)` | the search, as priority |

`.cost` is not `.len`. The surcharge on steering is what makes the search prefer
the straighter of two routes of equal length — see chapter 09, where the lap
costs 6.40 m and measures 6.05 m.

---

## 8. From a primitive to a neighbour

The primitive is in the car's frame. At a pose $(x, y, \theta)$ it is turned and
shifted:

$$
\begin{pmatrix} x_{\mathrm{nb}} \\ y_{\mathrm{nb}} \end{pmatrix}
=
\begin{pmatrix} x \\ y \end{pmatrix}
+
\begin{pmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{pmatrix}
\begin{pmatrix} \Delta x_k \\ \Delta y_k \end{pmatrix},
\qquad
\theta_{\mathrm{nb}} = \theta + \Delta\theta_k
$$

Two poses, one move — the $+22^\circ$ primitive, `dx = 0.10914`,
`dy = 0.04559`:

| from | $\cos\theta$, $\sin\theta$ | with the rotation | without it |
|---|---|---|---|
| `[1.60 0.50 0]` | 1, 0 | (1.70914, 0.54559) | (1.70914, 0.54559) |
| `[2.90 1.00 pi/2]` | 0, 1 | **(2.85441, 1.10914)** | (3.00914, 1.04559) |

At the start pose the two agree exactly, because rotating by zero changes
nothing. At the second pose they are **17 cm apart, in different directions**.

That is the trap worth remembering: a neighbour function that forgets the
rotation passes every test taken at $\theta = 0$ and fails everywhere else. Test
at a pose where the car is not pointing along $+x$.

---

## 9. If a number does not match

| what you see | where to look |
|---|---|
| $\beta$ or $d\theta/ds$ already wrong | TODO 1 and TODO 2; check against section 1 before touching the loop |
| `th` right, `x` and `y` wrong | the direction of travel: $\theta_m + \beta$, not $\theta_m$ — section 6 |
| end of arc out by about 5.8 mm, heading right | the heading used in the position step — section 5 |
| end of arc out by about 23 mm, heading 22.956° | $\beta$ missing from the turn rate as well — section 6 |
| arc length right, the arc bends the wrong way | the sign of the steering level, or $\sin$ and $\cos$ swapped |
| everything right at the start pose, nonsense elsewhere | the rotation in `car_neighbors` — section 8 |
| `check_car_primitives` says `turn` | the arc turns by the wrong amount: TODO 2, or radians against degrees |
| `check_car_primitives` says `beta` | either the `+ beta` in the position step, or the midpoint rule |

---

[BACK TO CHAPTER 08](08_vehicle_neighbors.md)
