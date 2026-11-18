[← 08 The vehicle in the search](08_vehicle_neighbors.md) · **09 Practice circuit** · [10 CrazyCar track →](10_crazycar_track.md)

# 09 — A lap on the practice circuit

**Block 4 · Guided MATLAB exercise**


> **Required activities:** Follow the steps marked **TASK** in order. Additional experiments are available for deeper investigation; they are not separate submissions. See [CORE_ROUTE.md](CORE_ROUTE.md).

## Goal

Chapter 08 gave the search a vehicle. This chapter puts that vehicle on a closed circuit and asks it to come back to where it started — and then asks the question that has no single right answer:

**A route that keeps well away from the walls is safe and slow. A route that cuts close is quick and might not survive. Where do you put the line?**

You will first get a lap at all, then measure what the choice costs you.

The track is a plain oval. Nothing about it is difficult: every corner on it is wider than the car's 0.303 m turning circle. That is deliberate — on an easy track the only thing that can go wrong is your reasoning.

![the practice oval](figures/09_oval.png)

### File tour — from a list of poses to a lap time

**TASK — Required:** Open `experiments/experiment_oval_lap.m` and identify the five stages it runs through. For each, write down what comes in and what goes out.

| stage | in | out |
|---|---|---|
| `cc_lap_plan` | the car model | a list of **poses** |
| `cc_resample_path` | poses | points every 4 cm |
| `cc_speed_profile` | points | one target **speed** per point |
| `cc_pure_pursuit` | the route, the car's state | throttle and steering |
| `cc_simulate` | all of it | a **lap time**, or a crash |

Only the first stage uses your work from chapter 08. The other four are given, and chapter 10 is where you get to change them.


## Step 1 — A lap is not one search

**TASK — Step 1:** Explain why a lap cannot be planned as a single search from the start pose to the start pose, then run the planner and read the leg table.

```matlab
P  = cc_params('Track', 'oval');
T  = cc_track(P);
CM = cc_car_model(T, P);
[poses, info] = cc_lap_plan(CM);
```

**TASK — Predict:** Your A\* stops as soon as the goal is reached. If the start and the goal are the same pose, what route does it return?

<details>
<summary>Show solution (after your own attempt)</summary>

The empty route. The start is already within tolerance of the goal, so the search succeeds immediately having moved nowhere. Cost zero, and perfectly correct — it answered the question you asked.

A lap therefore has to be expressed as something A\* can actually optimise: a **chain of searches** through intermediate goals. `P.checkpoints` holds three of them on the oval, and the last leg returns to the start. Each leg begins in the pose the previous leg ended in.

The checkpoints also fix the **direction** of travel. Reverse their order and the car goes round the other way.

</details>

### What you should see

```
  leg 1 -> (2.90, 1.00):  13 poses, 1.48 m,    36 expansions
  leg 2 -> (1.60, 1.50):  14 poses, 1.66 m,    25 expansions
  leg 3 -> (0.30, 1.00):  14 poses, 1.60 m,    65 expansions
  leg 4 -> (1.60, 0.50):  14 poses, 1.67 m,    59 expansions
  LAP: 52 poses, 6.40 m, 185 expansions. Closes: yes
```

**TASK — Explain:** The four legs cost 6.40 m in total, but the geometric length of the route is 6.05 m. Where does the difference come from?

<details>
<summary>Show solution (after your own attempt)</summary>

`prim(k).cost = P.arc + P.wSteer * abs(steerLevel)`. Steering is charged a small surcharge — 2 cm of imaginary extra distance at full lock — so that between two routes of the same length, the search prefers the one that weaves less. The reported 6.40 m is the search **cost**; 6.05 m is the distance actually driven.

Setting `P.wSteer = 0` gives a route of the same length that zig-zags more, because nothing penalises a needless steering input any more.

</details>


## Step 2 — Drive it

**TASK — Step 2:** Run the full experiment and follow the route through all five stages.

```matlab
run('experiments/experiment_oval_lap.m')
```

```
  route length          6.05 m
  tightest bend         R = 0.296 m at (0.34, 0.99)
  slowest point         1.52 m/s
  fastest point         2.46 m/s   (top speed is 3.72)

  LAP TIME              4.40 s
  average speed         1.34 m/s
  top speed reached     1.69 m/s
  tyres at the limit in 0 of 111 steps
  worst tracking error  63 mm   (average 21 mm)
```

**TASK — Explain:** Two different ceilings are visible here, and it is worth separating them.

1. The profile never asks for more than **2.46 m/s**, although the car could do 3.72. Which line of `cc_speed_profile` decides that, and what would have to change about the *track* to lift it?
2. The car then never actually reaches even that: its top speed is **1.69 m/s**. The profile is not the reason. What is?

<details>
<summary>Show solution (after your own attempt)</summary>

**The first ceiling is grip.**

```matlab
vRef(turning) = min(o.VMax, sqrt(o.AyMax ./ kappa(turning)));
```

Cornering at speed $v$ on a bend of radius $R$ pulls the car sideways with $v^2/R$, and the tyres hold `P.ayMax = 7.85 m/s²`, so $v \le \sqrt{a_{y,\max}\,R}$. The tightest bend of this route has $R = 0.296$ m, which gives

$$
\sqrt{7.85 \cdot 0.296} \;=\; 1.52\ \text{m/s}
$$

exactly the "slowest point" the experiment reports. The backward braking pass then pulls the speeds *before* that bend down as well, which is why the car starts slowing long before it arrives — the same thing a driver does.

To lift this ceiling the track would need a straight long enough to accelerate along and a bend after it gentle enough not to demand braking first. On an oval 3.2 m long there is no such straight.

**The second ceiling is the controller.** `cc_pure_pursuit` is proportional: `throttle = kv * (vWant - v)`. To hold a speed it needs a speed *error*, so it always lags behind a rising target, and on a route where the target rises and falls every half second it never catches up. 2.46 m/s is what the plan permits; 1.69 m/s is what a lagging controller achieves.

That gap is 0.77 m/s of lap time left on the table, and `kv` is one of the eight values you get to raise in chapter 10.

</details>


## Step 3 — Take the speed profile away

**TASK — Step 3:** Ask for full speed everywhere and run the same route.

```matlab
XY = cc_resample_path(poses(:,1:2), 0.04);
vFlat = repmat(cc_top_speed(P), size(XY,1), 1);
log = cc_simulate(T, [XY, vFlat]);
fprintf('crashed: %d at (%.2f, %.2f) after %.2f s\n', ...
    log.crashed, log.crashAt(1), log.crashAt(2), log.t(end));
```

```
crashed: 1 at (2.64, 1.61) after 1.44 s
```

**TASK — Explain:** The route did not change by one millimetre, and the car has just driven off it. Say precisely what the search did and did not guarantee.

<details>
<summary>Show solution (after your own attempt)</summary>

The search guaranteed that a **geometric** path exists which the car's steering can produce and whose swept rectangle clears the walls. That is all. Remember the line from chapter 08:

$$
\frac{d\theta}{ds} \;=\; \frac{\cos\beta\,\tan\delta}{L}
$$

The speed cancelled, which is exactly why the search could ignore it — and exactly why it cannot have said anything about it. Speed enters only through grip, and grip is not a geometric property.

So a route from a pose search is a **shape**, and a shape is not a plan until somebody decides how fast to go round it. That decision is `cc_speed_profile`, and this is what it is worth: 4.40 s and a finished lap, against a crash after 1.44 s.

</details>


## Step 4 — The trade-off

Now the part with no right answer. `P.safety` is how far the planner keeps the car's rectangle away from every wall. Raise it and the route is pushed towards the middle of the corridor; lower it and the planner is allowed to cut.

Two numbers judge the result, and they do not agree:

- the **lap time**, which you want small;
- the **clearance**, the smallest gap between the car's body and a real wall over the whole lap, which you want large. `cc_clearance` measures it.

"It did not crash" is not the second number. Pass/fail tells you nothing until it is already too late: a lap that passed 11 mm from a wall did not crash, it got away with it.

**TASK — Step 4 — Predict first:** Write down, before measuring, what you expect the lap time and the clearance to do as `P.safety` goes from 0.02 m to 0.12 m. Commit to a direction for each.

```matlab
for saf = [0.00 0.02 0.03 0.04 0.05 0.07 0.08 0.10 0.12]
    P  = cc_params('Track', 'oval', 'safety', saf);
    T  = cc_track(P);
    CM = cc_car_model(T, P);
    try
        [poses, info] = cc_lap_plan(CM, 'Verbose', false);
    catch err
        fprintf('safety %.2f : %s\n', saf, err.message(1:min(40,end)));
        continue
    end
    XY   = cc_resample_path(poses(:,1:2), 0.04);
    vRef = cc_speed_profile(XY, P);
    log  = cc_simulate(T, [XY, vRef]);
    if log.crashed
        fprintf('safety %.2f : CRASH at (%.2f, %.2f)\n', saf, log.crashAt(1), log.crashAt(2));
    else
        fprintf('safety %.2f : %.2f s, clearance %4.1f mm, %3d expansions\n', ...
            saf, log.lapTime, 1000*cc_clearance(T, log), info.expansions);
    end
end
```

### What you should see

| `P.safety` | lap time | clearance | expansions |
|---|---|---|---|
| 0.00 m | **no route at all** | | |
| 0.02 m | **4.28 s** | 25.7 mm | 178 |
| 0.03 m | 4.40 s | **11.3 mm** | 167 |
| 0.04 m | 4.40 s | 39.4 mm | 194 |
| 0.05 m | 4.40 s | 39.4 mm | 185 |
| 0.07 m | 4.52 s | 44.1 mm | 143 |
| 0.08 m | 4.40 s | 50.6 mm | 161 |
| 0.10 m | **4.32 s** | **65.2 mm** | 160 |
| 0.12 m | 4.36 s | 80.8 mm | 131 |

**TASK — Explain:** Almost certainly your prediction was "more margin, safer and slower". The table says otherwise twice over. Explain both anomalies:

1. `0.03` is **worse than `0.02` on both counts** — slower *and* closer to the wall.
2. `0.10` is **better than `0.05` on both counts** — faster *and* with 26 mm more room.

<details>
<summary>Show solution (after your own attempt)</summary>

The mistake in the prediction is treating `P.safety` as if it moved one fixed route nearer to or further from the walls. It does not. It changes **which route the search finds at all** — a different sequence of poses, with different curvature.

**0.10 is faster than 0.05** because the extra margin squeezes the route towards the middle of the corridor, and the middle of a bend is the line with the *largest radius*. A larger radius means a higher grip-limited speed, $v \le \sqrt{a_{y,\max}\,R}$. The constraint bought speed. That is not a general law — it is a property of a corridor wide enough that centring the route makes it rounder.

**0.03 is worse than 0.02** because both are below the point where the margin binds anywhere useful, so the two routes differ almost arbitrarily: a few poses chosen differently by the tie-breaking in OPEN. With no margin to speak of, nothing is steering the search towards a sensible line, and 11.3 mm is what you get by accident.

The lesson is the one worth taking to the real track: **below some value the margin is not protecting you, it is just noise; above it, the margin is choosing your racing line.** Which is why the useful question is never "is the margin big enough" but "which route does this margin produce".

</details>

### Step 4b — And the surprise at zero

**TASK — Explain:** With `P.safety = 0` the planner has *more* free space than in any other row, and it fails to find a lap at all. Find out why, by printing the heading the car arrives at each checkpoint with.

```matlab
for saf = [0.00 0.02 0.05]
    P = cc_params('Track','oval','safety',saf);
    CM = cc_car_model(cc_track(P), P);
    pose = P.start;
    fprintf('safety %.2f:', saf);
    goals = [P.checkpoints; P.start(1), P.start(2)];
    for k = 1:size(goals,1)
        lp = cc_search_car(CM, pose, goals(k,:), P.cpTol);
        if isempty(lp), fprintf('  leg %d FAILS\n', k); break, end
        pose = lp(end,:);
        fprintf('  CP%d at %+6.1f deg', k, mod(rad2deg(pose(3)),360));
    end
    fprintf('\n');
end
```

```
safety 0.00:  CP1 at  +56.0 deg  CP2 at +179.0 deg  CP3 at +212.0 deg  leg 4 FAILS
safety 0.02:  CP1 at  +56.0 deg  CP2 at +179.0 deg  CP3 at +222.9 deg  CP4 at +357.4 deg
safety 0.05:  CP1 at  +56.0 deg  CP2 at +179.5 deg  CP3 at +235.5 deg  CP4 at +348.0 deg
```

<details>
<summary>Show solution (after your own attempt)</summary>

A checkpoint fixes a **place**, not a pose: the search stops as soon as it is within `P.cpTol` of it, whatever direction the car happens to be pointing. The next leg then has to start from exactly that heading.

With no margin the first three legs are free to take a tighter line, and the car reaches CP3 pointing **212°** instead of 222.9° or 235.5°. From 212°, with five forward arcs and no reverse gear, there is no sequence that gets back to the start inside the corridor. The planner is not wrong; the car is genuinely stuck.

This is the thing that makes a pose search different from everything in chapters 02 to 06. In a grid search the state you arrive in is just a cell, and arriving is arriving. Here, **the state you arrive in is part of the problem you leave for the next leg** — and a route that is locally optimal can be globally impossible.

A planner that wanted to avoid this would have to search the legs together rather than one after another, or constrain the arrival heading at each checkpoint. Both cost a great deal more than the lap is worth at this stage, which is why the lab does the cheap thing and the margin quietly fixes it.

</details>

### Step 4c — Choose, and defend it

**TASK — Required:** Pick the value of `P.safety` you would use on this track and write **three sentences** justifying it: what you optimised for, what you gave up, and what measurement would change your mind.

There is no expected answer. 0.10 is defensible on the numbers; so is 0.05 on the grounds that 0.10 happening to be faster is luck that will not transfer. Saying so *is* the answer.


## Checkpoint

**TASK — Required:** Confirm the lap closes and explain each of the five stages without looking at the code.

- [ ] `experiment_oval_lap.m` gives a lap that closes.
- [ ] I can say why a lap needs checkpoints and what reversing their order does.
- [ ] I can say what the pose search guarantees and what it does not.
- [ ] I measured the margin sweep and can explain at least one of the two anomalies.
- [ ] I have chosen a margin and written down what I gave up for it.

**Optional challenge:** Set `P.wSteer = 0` and plan again. Compare the route length, the number of poses and the clearance with the default. Explain why a route of the same length can be worse to drive.

**Next:** [10 — The CrazyCar track →](10_crazycar_track.md)
