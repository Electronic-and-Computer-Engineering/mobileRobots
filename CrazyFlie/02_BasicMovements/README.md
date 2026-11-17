[BACK TO THE CRAZYFLIE SECTION](../README.md) · [CHAPTER 1: SETUP](../01_Setup/README.md) · [CHEAT SHEET](../cfCmdCheatSheets.MD)

# 2 — Basic movements in Python

Chapter 1 ended with a drone that answers. This chapter makes it move, in
eight steps, each one a script you can run on its own.

The order is deliberate. Everything that can be checked without propellers is
checked without propellers, and the first flight happens only once the drone
has proved that it arms, that it accepts setpoints, and that it knows its own
height.

---

## Table of Contents

- [2 — Basic movements in Python](#2--basic-movements-in-python)
  - [2.1 Before you fly](#21-before-you-fly)
  - [2.2 Three ways to command a Crazyflie](#22-three-ways-to-command-a-crazyflie)
  - [2.3 Example 1: connect only](#23-example-1-connect-only)
  - [2.4 Arming: why the motors do not spin](#24-arming-why-the-motors-do-not-spin)
    - [2.4.1 The supervisor](#241-the-supervisor)
    - [2.4.2 Example 2: arm and disarm](#242-example-2-arm-and-disarm)
    - [2.4.3 What `motorPowerSet` really is](#243-what-motorpowerset-really-is)
  - [2.5 Your own small library: `cflab.py`](#25-your-own-small-library-cflabpy)
  - [2.6 Example 3: the thrust ramp, on the bench](#26-example-3-the-thrust-ramp-on-the-bench)
  - [2.7 Example 4: hover](#27-example-4-hover)
  - [2.8 Example 5: a square](#28-example-5-a-square)
  - [2.9 Example 6: yaw](#29-example-6-yaw)
  - [2.10 Example 7: logging what the drone believes](#210-example-7-logging-what-the-drone-believes)
  - [2.11 Example 8: the Push Demo](#211-example-8-the-push-demo)
  - [2.12 What changed against the old chapters 3 and 4](#212-what-changed-against-the-old-chapters-3-and-4)
  - [2.13 Troubleshooting](#213-troubleshooting)
  - [References](#references)

---

## 2.1 Before you fly

| Rule | Why |
| --- | --- |
| Propellers off for every bench test | a drone on a table with propellers on is a drone that will leave the table |
| Battery charged | a drone that refuses to arm is usually a drone with a tired battery |
| Drone level and still while it boots | the gyros calibrate at startup; move it and the estimate starts wrong |
| cfclient disconnected | one radio, one link — chapter 1, section 1.9 |
| Hand on the keyboard, `Ctrl+C` in reach | every script in this chapter stops the motors in its `finally` block |
| Nose pointing away from you | the blue LEDs are the tail; forward is away from them |

The drone spins its propellers **as soon as arming succeeds**, before any
thrust is commanded at all. That is normal — it is the idle speed, and it is
your confirmation that arming worked — but it is also the moment at which
fingers are nearest the props.

---

## 2.2 Three ways to command a Crazyflie

Nearly every mistake in the first lab session comes from mixing these three up.

| Command | Call | What it needs | What it controls |
| --- | --- | --- | --- |
| **RPYT setpoint** | `cf.commander.send_setpoint(roll, pitch, yawrate, thrust)` | nothing | attitude and raw thrust, open loop. No height control at all. |
| **Hover setpoint** | `cf.commander.send_hover_setpoint(vx, vy, yawrate, z)` | a height sensor, i.e. the Flow deck v2 | velocity in the body frame, and an absolute height in metres |
| **MotionCommander** | `with MotionCommander(scf) as mc: mc.forward(0.5)` | a positioning deck (Flow deck is enough) | the same thing, but it takes off and lands for you |

Each of them must be sent **repeatedly**, at about 10 to 100 Hz. The firmware
drops back to a safe state if the stream stops — that watchdog is a feature,
and `MotionCommander` keeps the stream alive in its own thread so you do not
have to.

Units, which the cheat sheet also lists: roll and pitch in degrees, yawrate in
degrees per second, thrust as an integer from 0 to 65535, velocities in metres
per second, height in metres.

---

## 2.3 Example 1: connect only

Nothing moves here. The script proves that the radio, the URI and the library
agree.

**`examples/01_connect.py`**

```python
"""Open a link to the drone, print what it says, close it again."""
import time

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie

URI = "radio://0/33/2M/E7E7E7E7AA"      # see chapter 1, section 1.7


def main():
    cflib.crtp.init_drivers()

    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache="./cache")) as scf:
        print("Connected to", URI)

        battery = scf.cf.param.get_value("pm.batteryLevel")
        print("Battery level:", battery, "%")

        time.sleep(2.0)

    print("Disconnected")


if __name__ == "__main__":
    main()
```

`rw_cache="./cache"` is worth keeping: the drone's parameter and log tables are
written there on the first connection, and every later connection is seconds
faster.

**TASK — Predict, then run:** change the last digit of the address in `URI`
and run it again. What does the failure look like, and how long does it take?
Knowing the shape of that error saves you later, because a wrong URI and a
drone that is switched off fail in exactly the same way.

---

## 2.4 Arming: why the motors do not spin

### 2.4.1 The supervisor

On the drone runs a small state machine, the **supervisor**. It decides
whether the motors may turn at all. Its state is a bit field, and these are
the bits that matter here:

| Bit | Name | Meaning |
| --- | --- | --- |
| 0 | can be armed | preflight checks passed, an arming request would be accepted |
| 1 | is armed | the motors may turn |
| 2 | is auto armed | the drone arms itself as soon as it can |
| 3 | can fly | ready to fly |
| 4 | is flying | it is in the air |
| 5 | is tumbled | it is upside down |
| 6 | is locked | it has to be restarted |
| 7 | is crashed | a crash was detected |

Bit 1 is the one that decides whether your script does anything at all. The
Crazyflie 2.1 Brushless waits for an arming request: without it the drone sits
there, perfectly connected, accepting every setpoint you send and turning none
of them into motion.

This is also why so much Crazyflie code found online appears to be missing a
step. It was written for the older brushed models, which have bit 2 set and
arm themselves as soon as the preflight checks pass. On those drones arming is
invisible. On this one it is a line you have to write.

Arming is not a safety feature to be circumvented. It is the switch, and in
Python it is one line:

```python
scf.cf.supervisor.send_arming_request(True)
```

### 2.4.2 Example 2: arm and disarm

Propellers off.

**`examples/02_arm_disarm.py`**

```python
"""Arm the drone, read the supervisor state, disarm again. PROPELLERS OFF."""
import time

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie

URI = "radio://0/33/2M/E7E7E7E7AA"


def show_state(scf, label):
    """Print every supervisor condition that is currently true."""
    states = scf.cf.supervisor.read_state_list()
    print(f"{label:9s} {states}")


def main():
    cflib.crtp.init_drivers()

    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache="./cache")) as scf:
        show_state(scf, "before:")

        if not scf.cf.supervisor.can_be_armed:
            print("The drone says it cannot be armed. Battery? Standing level?")

        scf.cf.supervisor.send_arming_request(True)
        time.sleep(0.5)
        show_state(scf, "armed:")
        print("is_armed =", scf.cf.supervisor.is_armed)

        time.sleep(3.0)

        scf.cf.supervisor.send_arming_request(False)
        time.sleep(0.5)
        show_state(scf, "after:")


if __name__ == "__main__":
    main()
```

What you should see: nothing for a moment, then the propellers start to idle,
then they stop again. The printed state list goes from `['Can be armed']` to
one that also contains `Is armed`.

Two honest caveats:

- `read_state_list()` and `is_armed` need a firmware new enough to speak CRTP
  version 12. On older firmware the library falls back to the legacy channel
  for the arming request itself, but the read-back returns nothing — the
  request still arrives, you just cannot confirm it in Python. Look at the
  motors instead.
- If `can_be_armed` stays false, no amount of requesting will help. Check
  battery, check that the drone is standing level and still, and look at the
  Console tab in cfclient.

### 2.4.3 What `motorPowerSet` really is

The old chapter started the motors like this:

```python
scf.cf.param.set_value("motorPowerSet.m1", "6000")   # ... m2, m3, m4
scf.cf.param.set_value("motorPowerSet.enable", "1")
```

That is not arming. It is the **motor power override**: a bench feature that
drives each motor at a fixed PWM value, past the stabilizer. While it is
enabled, the controller output is ignored — so a script that enables the
override and then streams RPYT setpoints has two sources fighting over the
motors, and the setpoints lose.

It has exactly one good use, and it is a useful one:

| Use it for | Do not use it for |
| --- | --- |
| checking that each motor runs, and which direction it turns, with the propellers off | arming, hovering, flying, or anything that should react to a setpoint |

Keep it in your toolbox for `m1` to `m4` one at a time, when you want to know
which arm is dead. Everything else in this chapter uses arming.

---

## 2.5 Your own small library: `cflab.py`

From here on, three things repeat in every script: the URI, the connection,
and the arming dance. They belong in one file next to the examples. This is
the same idea as the `cfMRB` folder in the old chapter — only the contents are
different, because arming replaced the override.

**`examples/cflab.py`**

```python
"""Shared helpers for the CrazyFlie lab. The URI lives here, and only here."""
import time

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie

URI = "radio://0/33/2M/E7E7E7E7AA"      # Crazyflie 2.1 Brushless, chapter 1


def link(uri=None):
    """Open a link. Use it as:  with cflab.link() as scf: ..."""
    cflib.crtp.init_drivers()
    return SyncCrazyflie(uri or URI, cf=Crazyflie(rw_cache="./cache"))


def arm(scf, timeout=3.0):
    """Request arming and wait for the drone to confirm it.

    Returns True if the drone reported itself armed. On firmware too old to
    report, it returns False although the request did go out -- watch the
    motors in that case.
    """
    scf.cf.supervisor.send_arming_request(True)
    deadline = time.time() + timeout
    while time.time() < deadline:
        if scf.cf.supervisor.is_armed:
            print("armed")
            return True
        time.sleep(0.1)
    print("not confirmed armed. State:", scf.cf.supervisor.read_state_list())
    return False


def disarm(scf):
    scf.cf.supervisor.send_arming_request(False)
    time.sleep(0.2)
    print("disarmed")


def unlock_thrust(scf):
    """Release the firmware's thrust lock.

    The first setpoint after connecting must carry thrust 0, otherwise the
    firmware keeps the motors locked and nothing you send afterwards has any
    effect.
    """
    scf.cf.commander.send_setpoint(0.0, 0.0, 0.0, 0)
    time.sleep(0.1)


def stop(scf):
    """Cut the setpoint stream, the way the firmware wants it cut."""
    scf.cf.commander.send_setpoint(0.0, 0.0, 0.0, 0)
    time.sleep(0.1)
    scf.cf.commander.send_stop_setpoint()
    scf.cf.commander.send_notify_setpoint_stop()


def has_deck(scf, name="bcFlow2"):
    """True if the named expansion deck was detected. bcFlow2, bcMultiranger."""
    try:
        return int(scf.cf.param.get_value(f"deck.{name}")) == 1
    except Exception:
        return False


def reset_estimator(scf):
    """Reset the Kalman estimator and let it settle. Do this before take-off."""
    scf.cf.param.set_value("kalman.resetEstimation", "1")
    time.sleep(0.1)
    scf.cf.param.set_value("kalman.resetEstimation", "0")
    time.sleep(2.0)
```

`cflab.py` sits in the same folder as the example scripts, which is why
`import cflab` works without any path handling: Python always puts the
running script's own folder on the import path.

---

## 2.6 Example 3: the thrust ramp, on the bench

**Propellers off. This example is a test, not a flight.**

It answers one question: does a commanded thrust reach the motors? An
open-loop thrust ramp cannot hold a height — there is no height feedback in it
— so flying it is pointless and dangerous. What it does prove is the whole
chain: arming, thrust lock released, setpoint stream alive, motors reacting.

**`examples/03_thrust_ramp.py`**

```python
"""Thrust ramp on the bench. PROPELLERS OFF."""
import time

import cflab

RATE_HZ = 50
DT = 1.0 / RATE_HZ

THRUST_START = 8000
THRUST_STEP = 2000
THRUST_MAX = 22000
HOLD_TIME = 1.0


def send_for(scf, roll, pitch, yawrate, thrust, seconds):
    """Send one setpoint repeatedly -- the firmware needs the stream."""
    for _ in range(int(seconds * RATE_HZ)):
        scf.cf.commander.send_setpoint(roll, pitch, yawrate, thrust)
        time.sleep(DT)


def ramp(scf):
    thrust = THRUST_START
    while thrust <= THRUST_MAX:
        print("thrust =", thrust)
        send_for(scf, 0.0, 0.0, 0.0, thrust, HOLD_TIME)
        thrust += THRUST_STEP

    thrust -= 2 * THRUST_STEP          # do not hold the top twice
    while thrust >= THRUST_START:
        print("thrust =", thrust)
        send_for(scf, 0.0, 0.0, 0.0, thrust, HOLD_TIME)
        thrust -= THRUST_STEP


def main():
    with cflab.link() as scf:
        try:
            cflab.unlock_thrust(scf)
            if not cflab.arm(scf):
                print("Not armed -- see section 2.4. Stopping.")
                return
            ramp(scf)
        except KeyboardInterrupt:
            print("\nstopped by hand")
        finally:
            cflab.stop(scf)
            cflab.disarm(scf)


if __name__ == "__main__":
    main()
```

Note the order, and keep it: **unlock, then arm, then stream**. The thrust
lock is released by a setpoint with thrust 0; if the first setpoint you ever
send carries thrust, the firmware ignores it and every later one too.

**TASK — Explain:** 22000 is well below what it takes to lift this drone off
a table. Why is that the right number for this example, and what would you
have to add to the script before raising it?

The answer is in the next section: height feedback. Not a bigger number.

---

## 2.7 Example 4: hover

From here on the Flow deck v2 is required. It measures height downwards and
optical flow sideways, which is what turns "20000 units of thrust" into "0.4
metres above the floor".

**`examples/04_hover.py`**

```python
"""Hover at a fixed height for a few seconds, then come down."""
import time

import cflab

HEIGHT = 0.4            # metres
HOVER_TIME = 5.0        # seconds
RATE_HZ = 50
DT = 1.0 / RATE_HZ


def hover(scf, height, seconds):
    for _ in range(int(seconds * RATE_HZ)):
        scf.cf.commander.send_hover_setpoint(0.0, 0.0, 0.0, height)
        time.sleep(DT)


def descend(scf, height, seconds=2.0):
    """Walk the commanded height down to the floor instead of cutting thrust."""
    steps = int(seconds * RATE_HZ)
    for k in range(steps):
        z = height * (1.0 - k / steps)
        scf.cf.commander.send_hover_setpoint(0.0, 0.0, 0.0, max(z, 0.05))
        time.sleep(DT)


def main():
    with cflab.link() as scf:
        if not cflab.has_deck(scf, "bcFlow2"):
            print("No Flow deck detected. This example needs it.")
            return

        cflab.reset_estimator(scf)
        cflab.unlock_thrust(scf)
        if not cflab.arm(scf):
            print("Not armed -- see section 2.4. Stopping.")
            return

        try:
            hover(scf, HEIGHT, HOVER_TIME)
            descend(scf, HEIGHT)
        except KeyboardInterrupt:
            print("\nstopped by hand")
        finally:
            cflab.stop(scf)
            cflab.disarm(scf)


if __name__ == "__main__":
    main()
```

Two details that are easy to skip and expensive to skip:

- **`reset_estimator` before take-off.** The Kalman filter starts with
  whatever it last believed. Reset it while the drone stands on the floor and
  zero is where it actually is.
- **A textured floor.** Optical flow needs something to look at. A clean white
  lab floor is the worst case; a carpet or a printed pattern is the best.

---

## 2.8 Example 5: a square

A hover setpoint takes a velocity in the **body frame**: `vx` is forward from
the drone's own nose, not towards one wall of the room. Without a yaw command
the nose keeps its heading, so a square flown with alternating `vx` and `vy`
comes out as a square on the floor.

**`examples/05_square.py`**

```python
"""Fly a square at constant height, using hover setpoints."""
import time

import cflab

HEIGHT = 0.4
SPEED = 0.3             # m/s
SIDE_TIME = 2.0         # s per side -> side length = SPEED * SIDE_TIME
RATE_HZ = 50
DT = 1.0 / RATE_HZ


def move(scf, vx, vy, seconds, height=HEIGHT):
    for _ in range(int(seconds * RATE_HZ)):
        scf.cf.commander.send_hover_setpoint(vx, vy, 0.0, height)
        time.sleep(DT)


def main():
    with cflab.link() as scf:
        if not cflab.has_deck(scf, "bcFlow2"):
            print("No Flow deck detected. This example needs it.")
            return

        cflab.reset_estimator(scf)
        cflab.unlock_thrust(scf)
        if not cflab.arm(scf):
            return

        try:
            move(scf, 0.0, 0.0, 2.0)            # climb and settle
            move(scf, SPEED, 0.0, SIDE_TIME)    # forward
            move(scf, 0.0, SPEED, SIDE_TIME)    # left
            move(scf, -SPEED, 0.0, SIDE_TIME)   # back
            move(scf, 0.0, -SPEED, SIDE_TIME)   # right
            move(scf, 0.0, 0.0, 1.0)            # settle
            for k in range(int(2.0 * RATE_HZ)): # down
                z = HEIGHT * (1.0 - k / (2.0 * RATE_HZ))
                scf.cf.commander.send_hover_setpoint(0.0, 0.0, 0.0, max(z, 0.05))
                time.sleep(DT)
        except KeyboardInterrupt:
            print("\nstopped by hand")
        finally:
            cflab.stop(scf)
            cflab.disarm(scf)


if __name__ == "__main__":
    main()
```

**TASK — Measure:** the square should be `SPEED * SIDE_TIME` metres on a side.
Mark the start position on the floor and measure how far from it the drone
lands. Repeat it three times. Where does the error come from, and does it grow
with each side?

The same script with `MotionCommander` is three lines shorter and takes off
and lands for you — see the cheat sheet, section 5. Write it that way once you
have seen what it does underneath.

---

## 2.9 Example 6: yaw

Yaw is the third argument of the hover setpoint, in degrees per second. The
drone turns on the spot; the height loop keeps doing its job while it does.

**`examples/06_yaw.py`**

```python
"""Turn on the spot: clockwise, then back."""
import time

import cflab

HEIGHT = 0.4
YAWRATE = 45.0          # deg/s, positive turns left
TURN_TIME = 2.0
RATE_HZ = 50
DT = 1.0 / RATE_HZ


def turn(scf, yawrate, seconds, height=HEIGHT):
    for _ in range(int(seconds * RATE_HZ)):
        scf.cf.commander.send_hover_setpoint(0.0, 0.0, yawrate, height)
        time.sleep(DT)


def main():
    with cflab.link() as scf:
        if not cflab.has_deck(scf, "bcFlow2"):
            print("No Flow deck detected. This example needs it.")
            return

        cflab.reset_estimator(scf)
        cflab.unlock_thrust(scf)
        if not cflab.arm(scf):
            return

        try:
            turn(scf, 0.0, 2.0)                 # climb and settle
            turn(scf, YAWRATE, TURN_TIME)       # one way
            turn(scf, 0.0, 1.0)
            turn(scf, -YAWRATE, TURN_TIME)      # and back
            turn(scf, 0.0, 1.0)
            for k in range(int(2.0 * RATE_HZ)):
                z = HEIGHT * (1.0 - k / (2.0 * RATE_HZ))
                scf.cf.commander.send_hover_setpoint(0.0, 0.0, 0.0, max(z, 0.05))
                time.sleep(DT)
        except KeyboardInterrupt:
            print("\nstopped by hand")
        finally:
            cflab.stop(scf)
            cflab.disarm(scf)


if __name__ == "__main__":
    main()
```

`YAWRATE * TURN_TIME` is 90 degrees with the values above. Turning and
translating at the same time is where the body frame stops being an academic
detail: `vx` follows the nose around.

---

## 2.10 Example 7: logging what the drone believes

Flying is only half of it. The other half is reading back what the drone
thinks is happening, which is what you will need for every later assignment.

A `LogConfig` is a named group of variables with a period. `SyncLogger` hands
them to you one packet at a time.

**`examples/07_log_estimator.py`**

```python
"""Read the state estimate for a few seconds. No flying, propellers off."""
import time

from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncLogger import SyncLogger

import cflab

DURATION = 5.0
PERIOD_MS = 50


def main():
    with cflab.link() as scf:
        logconf = LogConfig(name="state", period_in_ms=PERIOD_MS)
        logconf.add_variable("stateEstimate.x", "float")
        logconf.add_variable("stateEstimate.y", "float")
        logconf.add_variable("stateEstimate.z", "float")
        logconf.add_variable("stateEstimate.yaw", "float")

        last = None
        t0 = time.time()
        with SyncLogger(scf, logconf) as logger:
            for _, data, _ in logger:
                last = data
                print(f"x={data['stateEstimate.x']:+.3f}  "
                      f"y={data['stateEstimate.y']:+.3f}  "
                      f"z={data['stateEstimate.z']:+.3f}  "
                      f"yaw={data['stateEstimate.yaw']:+.1f}")
                if time.time() - t0 >= DURATION:
                    break

        print("last values:", last)


if __name__ == "__main__":
    main()
```

**Where the variable names come from.** Not from memory, and not from this
page: from the **Log TOC** tab in cfclient, on the drone you are holding. The
names differ between firmware builds — the motor group is called `motor` on
some builds and `motorPower` on others — and a name that does not exist raises
an exception when the log config starts.

**TASK — Run and move:** start the script and carry the drone, by hand, half a
metre to one side. Does `stateEstimate.x` follow? With and without the Flow
deck, and with the drone pointing in two different directions. What you are
looking at is the difference between an estimate and a measurement.

---

## 2.11 Example 8: the Push Demo

The last example is the one that makes the drone look alive. It needs the
**Multiranger deck** on top of the **Flow deck**: five more distance sensors,
four sideways and one up.

The idea is one line long: if something is close, move away from it. The
drone hovers, you walk a hand towards it, and it retreats — and because the
same hand held over the top sensor ends the demo, you can land it without
touching the keyboard.

This is also the first example that uses `MotionCommander`, which takes off
when the `with` block is entered and lands when it is left, and keeps the
setpoint stream alive in between.

**`examples/08_push_demo.py`**

```python
"""Push Demo: the drone keeps its distance. Flow deck + Multiranger needed.

Hold a hand over the top sensor to land.
"""
from cflib.positioning.motion_commander import MotionCommander
from cflib.utils.multiranger import Multiranger

import cflab

HEIGHT = 0.4            # m
SPEED = 0.3             # m/s, how fast it backs away
TRIGGER = 0.4           # m, closer than this counts as "something is there"


def velocity_from(distance_m, sign):
    """One sensor -> one velocity component. Nothing there: no contribution."""
    if distance_m is None or distance_m > TRIGGER:
        return 0.0
    return sign * SPEED


def is_blocked(distance_m, limit=0.2):
    return distance_m is not None and distance_m < limit


def main():
    with cflab.link() as scf:
        if not cflab.has_deck(scf, "bcFlow2"):
            print("No Flow deck detected. This example needs it.")
            return
        if not cflab.has_deck(scf, "bcMultiranger"):
            print("No Multiranger deck detected. This example needs it.")
            return

        cflab.reset_estimator(scf)
        if not cflab.arm(scf):
            print("Not armed -- see section 2.4. Stopping.")
            return

        try:
            with MotionCommander(scf, default_height=HEIGHT) as mc:
                with Multiranger(scf) as ranger:
                    print("Flying. Hold a hand over the top sensor to land.")
                    keep_flying = True
                    while keep_flying:
                        vx = velocity_from(ranger.front, -1.0) \
                             + velocity_from(ranger.back, +1.0)
                        vy = velocity_from(ranger.right, +1.0) \
                             + velocity_from(ranger.left, -1.0)

                        mc.start_linear_motion(vx, vy, 0.0)

                        if is_blocked(ranger.up):
                            keep_flying = False
            print("landed")
        except KeyboardInterrupt:
            print("\nstopped by hand")
        finally:
            cflab.disarm(scf)


if __name__ == "__main__":
    main()
```

How to read it:

| Sensor | Sees something | Drone does |
| --- | --- | --- |
| front | an obstacle ahead | moves back, `vx` negative |
| back | an obstacle behind | moves forward, `vx` positive |
| left | an obstacle on the left | moves right, `vy` negative |
| right | an obstacle on the right | moves left, `vy` positive |
| up | a hand above it | leaves the loop, `MotionCommander` lands |

`ranger.front` and its siblings are `None` until the first measurement
arrives, and `None` whenever a sensor reads nothing in range. That is why
every read goes through `velocity_from()` instead of a bare comparison — a
comparison against `None` is the single most common crash in this demo.

**TASK — Tune and explain:** raise `TRIGGER` to 0.8 m and fly it again in the
same space. The drone becomes nervous, sometimes it oscillates. Why? Describe
it in terms of the room's width, the trigger distance, and the fact that two
opposite sensors can both be triggered at once.

---

## 2.12 What changed against the old chapters 3 and 4

The old chapter worked on the day it was written, on one drone. These are the
places where it would mislead the next reader, and what this chapter does
instead.

| # | In the old chapter | Why it does not hold | Here |
| --- | --- | --- | --- |
| 1 | `cfMRB.start_motors(scf)` in 4.2 | the function is defined as `start_motors(scf, pwm)` — the call raises `TypeError` before anything happens | arming takes no argument |
| 2 | `motorPowerSet.*` described as a way around the safety that keeps the motors still | it is the motor power override, which bypasses the stabilizer; what keeps the motors still is that the drone is not armed | `cf.supervisor.send_arming_request(True)`, section 2.4 |
| 3 | the ramp enables the override **and** streams RPYT setpoints | while the override is on, setpoints are ignored; the two fight | arm, then stream |
| 4 | three different URI pairs, with `33` and `80` swapped between 3., 4.1 and 4.2 | each example addresses a different drone | the lab flies one kind of drone: one URI, written once in `cflab.py` |
| 5 | 4.5: `E7E7E7E7E7E7` and `E7E7E7E7E7AA` | twelve hex digits; a Crazyflie address has ten | corrected |
| 6 | "small pre-stream (helps some setups)" | it is not a workaround, it is the firmware thrust lock: the first setpoint must carry thrust 0 | `cflab.unlock_thrust()`, with the reason |
| 7 | 4.3 and 4.4 are checklists, and 4.4 is wrapped in a `python` code fence | nothing to run, and the whole checklist renders as a code block | runnable examples 05 and 06 |
| 8 | two sections numbered 4.2, two numbered 4.4 | the table of contents cannot link to both | renumbered |
| 9 | `[Our MRB CF Cheat Sheet](cfCmdCheatSheets.md)` | GitHub paths are case sensitive, the file is `cfCmdCheatSheets.MD` | fixed |
| 10 | open-loop RPYT to "hold 1 m or more" | an open-loop thrust ramp has no height feedback at all; it cannot hold any height | thrust ramp is a bench test; height comes from the Flow deck |
| 11 | `stabilizer.estimator = "2"`, `stabilizer.controller = "1"`, both inside a silent `try/except` | the numbers differ between firmware builds, and a swallowed exception leaves you believing it worked | the estimator is reset the documented way; decks are checked before use |
| 12 | no `reset_estimator` before flying | the estimate starts wherever it last was | `cflab.reset_estimator()` before every take-off |

Two of these are worth remembering beyond this lab: **a failure that is
silently caught is worse than a crash**, and **the same constant written in
three files will be three different constants by next week**.

---

## 2.13 Troubleshooting

| Symptom | First thing to check |
| --- | --- |
| Connects, but nothing moves | did it arm? Run `examples/02_arm_disarm.py` and watch the state list |
| Motors do not react to thrust | thrust lock: did the first setpoint carry thrust 0? `cflab.unlock_thrust()` |
| Arming is refused | battery, drone level and still, `supervisor.can_be_armed`, the Console tab |
| Armed, then disarms by itself | the setpoint stream stopped for too long, or the drone was picked up |
| Climbs to the ceiling | open-loop thrust, or a Flow deck looking at a floor with no texture |
| Drifts sideways while hovering | reset the estimator before take-off; check the Flow deck lens; textured floor |
| `None` compared to a float | a Multiranger value before the first measurement — see 2.11 |
| Log variable missing | look up the exact name in the Log TOC tab; it differs per firmware |
| Everything worked yesterday | different firmware on a different drone — chapter 1, section 1.6 |

---

## References

- Arming, and why this drone needs it:
  <https://www.bitcraze.io/documentation/repository/crazyflie-firmware/master/functional-areas/supervisor/arming/>
- The supervisor, its states and conditions:
  <https://www.bitcraze.io/documentation/repository/crazyflie-firmware/master/functional-areas/supervisor/>
- `Supervisor` class in cflib (`send_arming_request`, `is_armed`, `read_state_list`):
  <https://www.bitcraze.io/documentation/repository/crazyflie-lib-python/master/api/cflib/crazyflie/supervisor/>
- Commander API (`send_setpoint`, `send_hover_setpoint`, `send_stop_setpoint`):
  <https://www.bitcraze.io/documentation/repository/crazyflie-lib-python/master/api/cflib/crazyflie/commander/>
- MotionCommander:
  <https://www.bitcraze.io/documentation/repository/crazyflie-lib-python/master/api/cflib/positioning/motion_commander/>
- Step by step: connect, log, param:
  <https://www.bitcraze.io/documentation/repository/crazyflie-lib-python/master/user-guides/sbs_connect_log_param/>
- Step by step: motion commander:
  <https://www.bitcraze.io/documentation/repository/crazyflie-lib-python/master/user-guides/sbs_motion_commander/>
- The official multiranger push example:
  <https://github.com/bitcraze/crazyflie-lib-python/blob/master/examples/multiranger/multiranger_push.py>

---

Back: [1 — Setup](../01_Setup/README.md) · [Cheat sheet](../cfCmdCheatSheets.MD)
