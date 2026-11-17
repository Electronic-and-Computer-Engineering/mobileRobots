[← 08 The vehicle in the search](08_vehicle_neighbors.md) · **Vehicle model review** · [Overview](README.md)

---

# Review of the CrazyCar vehicle model

**Subject:** `Electronic-and-Computer-Engineering/CrazyCarSim`, commit `1a56e26`
**Scope:** `+car/`, `+track/`, `+env/startup.m`, `+env/run_proc.m`
**Why:** the model is taken over for chapters 08 to 10, so it had to be
read line by line first.

Every claim below was checked numerically against a transcription of the
original code. Where a correction changes behaviour, the amount is stated.

---

## Summary

| # | File | What | Severity |
|---|---|---|---|
| 1 | `SteerServo_model.m` | `else if` instead of `elseif` — the servo stops responding | **severe** |
| 2 | `calcRotuPos.m` | the slip angle `beta` is computed as a no-op | moderate |
| 3 | `calcRotuPos.m` | the yaw-rate equation is missing its tangent | moderate |
| 4 | `calcRotuPos.m` / `plotCar.m` | three different vehicle lengths in one program | moderate |
| 5 | `calcRotuPos.m` | the grip limit is computed and never applied | moderate |
| 6 | `motor_model.m` | the resistance term is dimensionally inconsistent | **do not "fix" naively** |
| 7 | `createMapFromPic.m` | a uint8 image compared against 0.5 | minor |
| 8 | `createMapFromPic.m` | dead assignment | cosmetic |
| 9 | `createMapFromPic.m` | `robotics.BinaryOccupancyGrid` has been removed from MATLAB | portability |
| 10 | `lut_motor.mat` | the lookup table is redundant | simplification |

---

## 1. The steering freezes — `+car/SteerServo_model.m`, line 10

```matlab
 8  if ((des_steer_angle == 0) && (steer_angle < 0))
 9      des_steer_angle = zeroNoise;
10  else if ((des_steer_angle == 0) && (steer_angle > 0))
11      des_steer_angle = zeroNoise * -1;
12  end
13
14  if steer_angle < des_steer_angle
    ...
26  end
27
28  end
```

`else if` with a space is **not** `elseif`. It opens a *nested* `if`, which
the `end` on line 12 closes. The `end` on line 28 then closes the outer
`if` from line 8 — so the entire servo block, lines 14 to 26, sits inside
the **else branch**.

Written out, the structure is:

```matlab
if (des == 0 && steer < 0)
    des = zeroNoise;              % and nothing else happens
else
    if (des == 0 && steer > 0)
        des = -zeroNoise;
    end
    ... the servo actually moves ...
end
```

**Consequence:** whenever straight-ahead is commanded while the wheels are
turned **left**, the function returns `steer_angle` unchanged. The steering
freezes at its current left-hand angle and never comes back. The car
circles until it hits something.

The file still parses, because the block count is balanced and MATLAB
allows a function without a terminating `end`. Nothing warns.

**Corrected in** `tools/cc_step.m`, which has a plain `if / elseif / else`
and no nested block.

A second point: the `zeroNoise = 0.25` construction is meant to model a
servo that never sits perfectly straight, but it is implemented as a limit
cycle — commanded zero, the servo is told to aim for +0.25°, then −0.25°,
then +0.25° for ever. The port drops it; if a never-quite-straight servo is
wanted, it belongs in the *measurement* of the angle, not in the setpoint.

---

## 2. `beta` is a no-op — `+car/calcRotuPos.m`, line 8

```matlab
beta = atan(car_L/(car_L/tan(deg2rad(steer_deg))));
```

`car_L / (car_L / tan(x))` is `tan(x)`, so the line reads
`beta = atan(tan(δ))`, which is `δ`. Checked numerically for
δ = 0°, 1°, 5°, 11°, 22°: identical to within 1e-12. The only thing the
line does is avoid a division by zero at δ = 0, by accident
(`car_L/Inf = 0`).

The variable name gives the intention away. In a bicycle model referred to
the **middle** of the car, `beta` is the body **slip angle**:

```
beta = atan( (l_r / L) * tan(delta) )
```

With `l_r = L/2` and δ = 22° that is 11.4°, not 22°.

**Corrected in** `tools/cc_step.m`:

```matlab
beta = atan((P.lr / P.L) * tan(d));
```

and it is now actually used, in the position update:
`x = x + v*cos(theta + beta)*dt`.

---

## 3. The yaw rate is missing its tangent — `+car/calcRotuPos.m`, line 9

```matlab
theta = theta_old + beta*(speed_v/(car_L))*step_s;
```

The bicycle model needs `theta_dot = v * tan(delta) / L`. With `beta == δ`
(finding 2), the line computes `v * δ / L` — the small-angle
approximation, applied at angles that are not small.

| δ | as coded | correct | error |
|---|---|---|---|
| 5° | 0.6233 rad/s | 0.6249 rad/s | −0.25 % |
| 11° | 1.3713 rad/s | 1.3884 rad/s | −1.23 % |
| 22° | 2.7427 rad/s | 2.8859 rad/s | **−4.96 %** |

(at v = 1 m/s). The tightest turn therefore comes out as
`L/δ = 0.365 m` instead of `L/tan(δ) = 0.347 m` — the simulated car turns
about 5 % worse than the real one.

**Corrected in** `tools/cc_step.m`:

```matlab
yawRate = (st.v / P.L) * cos(beta) * tan(d);
```

---

## 4. Three vehicle lengths — `calcRotuPos.m` against `plotCar.m`

| source | value | what it is |
|---|---|---|
| `calcRotuPos.m` line 4 | `car_L = 0.14` | used as the **wheelbase** |
| `plotCar.m` line 4 | `22 * 0.01` = 0.22 m | the **body length** that is drawn |
| `plotCar.m` lines 20-23 | front wheel at x = +0.07, rear at x = −0.05 | **wheelbase 0.12 m** |

A bicycle model needs the **wheelbase** — the distance between the axles —
because that is what sets the turning radius. The body length decides
whether you hit a wall. They are different quantities used in different
places, and 0.14 m is neither of them.

**Corrected in** `tools/cc_params.m`: `P.L = 0.12`, `P.lr = 0.06`,
`P.bodyL = 0.22`, `P.bodyW = 0.105`, each with the line of the original it
came from. With the wheelbase corrected and the tangent restored, the
tightest radius of the reference point is **0.303 m**.

The same inconsistency affects the reference point. `plotCar.m` rotates the
body about `pos`, which sits 0.05 m ahead of the rear axle — essentially
the wheelbase midpoint. The rear-axle kinematics of `calcRotuPos.m` are
integrated at that point, a 5 cm mismatch on a 22 cm car. The port uses the
midpoint model consistently, which is what the `beta` of finding 2 was
reaching for.

---

## 5. The grip limit is dead code — `+car/calcRotuPos.m`, lines 11-17

```matlab
turnRadius = car_L / sin(theta-theta_old);
Fr_cc = carData.m_cc * 9.81 * carData.c_r * 4;
F_cen = (carData.m_cc*speed_v.^2) / turnRadius;   % Centrifugal force

%     if (F_cen > Fr_cc)
%         disp('hey')
%     end
```

Both forces are computed, the comparison is commented out, and neither
value is used afterwards. **The simulated car corners at any speed at
all.** On a track whose tightest corner allows 1.54 m/s against a top speed
of 3.72, that is not a detail.

`turnRadius` is also wrong in its own right: `car_L / sin(Δθ)` is not a
radius — the radius is `L / tan(δ)`, or `v / θ̇`. And when the car drives
straight, `Δθ = 0` gives `turnRadius = Inf`; `F_cen` then happens to come
out 0, so nothing is noticed.

**Corrected in** `tools/cc_step.m`: the limit is real.

```matlab
ay = abs(st.v * yawRate);
if ay > P.ayMax && ay > 0
    yawRate  = yawRate * (P.ayMax / ay);   % the car runs wide
    slipping = true;
end
```

`P.ayMax = 0.8 * 9.81 = 7.85 m/s²` is an assumption (rubber on a smooth
floor), not a measurement. **It should be measured on the real car before
any lap time is quoted to three decimals.** Everything else in the port is
taken from the original; this one number is not.

---

## 6. The resistance term — `+car/motor_model.m`, line 80

### Read it before changing it

```matlab
Fa_cc = (air_dens * A * c_alpha * vel_in^2)/2;
b     = (Fr_cc + Fa_cc);       % Ns / m
vel_out = vel_in + (-b/m_cc) * step_s * vel_in + (F_eng / m_cc) * step_s;
```

`Fr_cc = m*g*c_r = 0.3444` is a **force in newtons**. `Fa_cc` is a force in
newtons. But `b` is then multiplied by `step_s` *and* by `vel_in`, so the
deceleration it produces is `b*v/m` — newtons per kilogram times metres per
second. The comment on the line even says `Ns/m`, which is the unit of a
damping coefficient, not of a force.

The practical effect: rolling resistance is correct at exactly 1 m/s and
wrong everywhere else.

| v | deceleration as coded | dimensionally correct | factor |
|---|---|---|---|
| 0.5 m/s | 0.287 m/s² | 0.575 m/s² | 0.50 |
| 1.0 m/s | 0.578 m/s² | 0.578 m/s² | 1.00 |
| 2.0 m/s | 1.178 m/s² | 0.589 m/s² | 2.00 |
| 3.0 m/s | 1.822 m/s² | 0.607 m/s² | 3.00 |

### Why it must not simply be "fixed"

Replace the term with a constant rolling-resistance force and keep every
other parameter, and the model gives a **top speed of 14.2 m/s = 51 km/h**
for a 0.6 kg indoor RC car. The parameters were identified *around* this
term. The arithmetic is not a slip of the pen; it is load-bearing.

### What was done instead

The term is **kept, and named correctly**. Written as a viscous damping
coefficient `d_roll` in N·s/m, the same arithmetic is dimensionally
consistent and nothing about the car's behaviour changes:

```matlab
P.dRoll = P.mass * 9.81 * P.cRoll;   % N*s/m  (= 0.3444)
...
Froll = P.dRoll * st.v;
```

The drag term **was** corrected, because it was wrong in a way that does
not carry calibration: the original leaves it proportional to `v³` rather
than `v²`, and at 2 m/s it contributes 0.009 N against 0.344 N of rolling
resistance — too small to have been fitted to anything.

```matlab
Fdrag = 0.5 * P.rhoAir * P.area * P.cDrag * st.v * abs(st.v);
```

### What that costs

Steady-state speed against the original `lut_motor.mat`:

| V | corrected model | original LUT | difference |
|---|---|---|---|
| 1.5 | 1.414 m/s | 1.404 m/s | +0.7 % |
| 2.0 | 1.880 | 1.859 | +1.1 % |
| 3.0 | 2.806 | 2.731 | +2.7 % |
| 4.0 | **3.722** | **3.544** | **+5.0 %** |

So the corrected car is 5 % faster at full throttle, and the whole of that
5 % is the drag fix. Everything below three quarters throttle agrees to
within 3 %.

> **If the 3.544 m/s figure has been validated against the real car**, then
> `P.cDrag` should be re-identified rather than the drag term reverted:
> `cDrag = 0.44` was only ever fitted through a `v³` law.

---

## 7-9. The map — `+track/createMapFromPic.m`

**7.** Line 11: `bwimage = grayimage < 0.5`. `grayimage` comes from
`rgb2gray` and is **uint8**, 0…255. The comparison therefore only ever
finds pixels that are *exactly* black. On `map/track.png` that happens to
be almost all of them (the image is 12 % pure black and 88 % pure white),
so it works — until `imresize` on line 9 interpolates the wall edges to
intermediate greys, and those stop being walls. Walls come out about one
pixel thin. Feed it a JPEG or a hand-drawn map and the whole track
disappears. The port uses `< 128`.

**8.** Lines 21-22 assign `grayimage` twice; the first assignment
(`imcomplement`) is dead.

**9.** `robotics.BinaryOccupancyGrid` has been removed from current MATLAB
(the replacement is `binaryOccupancyMap` in the Navigation Toolbox). The
port uses neither: `tools/cc_track.m` builds the grid with base MATLAB
only, so the lab needs no toolbox at all.

A separate point about coarsening. `imresize` with the default bilinear
filter **averages** pixels; a wall thinner than the target cell can average
away and disappear. For an occupancy map the safe rule is *a cell is
blocked if any pixel in it is blocked*, which is what `cc_track.m` does.

---

## 10. `lut_motor.mat` is redundant

`+car/createMotor_lut.m` shows how the table was made: by running
`motor_model` to steady state for each voltage. So the LUT **is** the fixed
point of the model it is used inside. `motor_model` then compares the
current wheel speed against the LUT and quadruples the resistance when it
overshoots — which only re-asserts the steady state the model would have
reached anyway.

In a dimensionally consistent model the dynamics converge to that same
speed on their own, so the table, the `n_v` comparison and the four-way
branch all disappear. `tools/cc_top_speed.m` solves the steady state as the
quadratic equation it is, and agrees with the LUT (table in finding 6).

---

## What was carried over unchanged

So that the lab stays faithful to the hardware:

| quantity | value | source |
|---|---|---|
| motor resistance | 0.55 Ω | `motor_model.m` |
| motor constant | 0.002753408439503 | `motor_model.m` |
| gear ratio | 5.2727 | `motor_model.m` |
| wheel radius | 18 mm, dynamic 0.98× | `motor_model.m` |
| mass | 0.6 kg | `motor_model.m` |
| rolling resistance coefficient | 0.05851 | `motor_model.m` |
| frontal area, drag coefficient | 0.0084 m², 0.44 | `motor_model.m` |
| voltage at 100 % | 4 V | `percToCar.m` |
| motor dead band | 1.11 V | `motor_model.m` |
| steering limit | 22° | `percToCar.m` |
| servo rate | 22° in 0.2 s | `SteerServo_model.m` |
| step rate | 25 Hz | `startup.m` |
| track picture and scale | `map/track.png`, 1000 px/m | `startup.m` |
| start pose | x = 3.5, y = 0.6, θ = 0 | `startup.m` |
| finish line | x ∈ (3.0, 3.5), y ∈ (0, 0.76) | `startup.m`, `SimTimingSystem.m` |

---

## Licence

CrazyCarSim is GPLv3 with an attribution requirement. `MATLAB/map/track.png`
is a copy of `map/track.png` from that project, and `tools/cc_step.m`,
`tools/cc_params.m` and `tools/cc_track.m` are derived from `+car/` and
`+track/`. Both repositories belong to the same organisation, so this is an
internal matter — but if any of it is published separately, the attribution
and the licence travel with it.

---

## Not reviewed

`+car/IRSensorSim.m`, `+env/SimTimingSystem.m`, `+serialCmd/`,
`+algorithm/` and the App Designer interface were read but not checked in
detail: the path-planning lab uses none of them. Two things were noticed in
passing and are worth a look by someone who does use them.

* `IRSensorSim.m` adds noise with `rand(1)*2*noise - noise` three times,
  drawing a fresh number each time — correct, but note the sensors are
  called with `noiseInM = 0` in `run_proc.m`, so the noise model is never
  exercised.
* `SimTimingSystem.m` accumulates `data.LapTime` in several branches and
  resets it in two of them. The CCW and CW branches are near-duplicates
  with different comparison directions; a single parametrised gate test
  would be easier to trust.

---

[← 08 The vehicle in the search](08_vehicle_neighbors.md) · **Vehicle model review** · [Overview](README.md)
