[← 08 Car in the maze](08_car_in_maze.md) · [Course overview](README.md)

# 09 — Outlook: from grid route to CrazyCar lap time

**Follow-up lab concept · Not included in the three path-planning blocks**

## Why this is a different problem

A shortest-distance path solves a geometric problem. A fast CrazyCar lap must also respect **steering, minimum turning radius, velocity and acceleration**.

A line that cuts tightly through a corner can be shorter but require a very low speed. A longer and smoother line may produce a lower lap time.

Thus:

\[
\min\ \text{path length}\quad \neq\quad
\min\ \text{lap time},
\]

in general.

## Suggested progression

### Phase 1 — Drive an existing path

The students take a feasible route returned by A*, map its points to the simulator's track coordinates, and drive it with a **given** controller and conservative constant speed. The instructor must first provide the simulator interface and clarify its coordinate systems, control inputs and collision model.

Questions: Does the simulated car follow cell-center waypoints exactly? What happens at sharp corners? Why is collision-free grid movement not sufficient to ensure a driveable car path?

<details>
<summary>Show solution (after your own attempt)</summary>

**Expected discussion, not a simulator-specific prediction:** A real or simulated car with steering constraints generally cannot follow a route of abrupt right-angle direction changes exactly at nonzero speed. Sharp corners may require braking, may exceed the available turning curvature, or may cause the vehicle to leave the safe corridor. Grid connectivity alone checks free cells; it does **not** guarantee that the vehicle's continuous trajectory or body footprint stays collision-free.

The exact behaviour depends on the CrazyCar simulator and controller, which are not specified in this package.

</details>


### Phase 2 — Generate a smoother reference line

Use interpolation or a smoothing procedure to create a continuous geometric reference. Preserve collision clearance: a smoothed curve can cross a wall even if its original grid route does not.

A suitable objective may combine distance, curvature and safety clearance, but **the weights must be defined**; do not assume minimizing geometric curvature always minimizes lap time.

### Phase 3 — Add vehicle dynamics and timing

A simple kinematic bicycle model is a reasonable first step:

\[
\dot x=v\cos\psi,\qquad
\dot y=v\sin\psi,\qquad
\dot\psi=\frac{v}{L}\tan\delta,\qquad
\dot v=a.
\]

Here \(L\) is the wheelbase, \(\delta\) the steering angle, \(a\) the longitudinal acceleration, and \(\psi\) the heading angle.

One simplified lateral-acceleration constraint is

\[
v^2|\kappa|\le a_{y,\max},
\]

where \(\kappa\) is path curvature. It leads to a local speed bound for \(|\kappa|>0\):

\[
v\le \sqrt{\frac{a_{y,\max}}{|\kappa|}}.
\]

This is only a **first approximation**. Steering dynamics, tire grip, braking, acceleration, discretization and simulator-specific limitations may also matter.

### Phase 4 — Optimize lap time

With distance along the path denoted by \(s\), a continuous lap time can be written formally as

\[
T=\int_0^{S}\frac{1}{v(s)}\,\mathrm ds,
\]

for a traversed path of length \(S\) and positive speed along the motion. The optimization then chooses a geometrically feasible line and a velocity profile to reduce \(T\) while satisfying track boundaries and vehicle constraints.

**Possible approaches to investigate later:** a graph search over discretized vehicle states, trajectory optimization, or model-predictive control. These are *not* implemented by the present pathplanning toolkit.

## What needs to be specified before developing this lab?

- Simulator name/version and callable MATLAB/Python API.
- Track geometry, start/finish representation and units.
- Which signals can be commanded: steering angle, steering rate, acceleration, wheel speeds or something else?
- Vehicle parameters and collision constraints.
- Whether the objective is a one-shot planned route, a fastest open-loop trajectory or closed-loop lap control.

No simulator integration is claimed in this package: the uploaded MATLAB project contains graph and grid planning utilities, but does not provide a documented CrazyCar simulator interface.
