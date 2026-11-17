[GO BACK TO THE CRAZYFLIE SECTION](README.md)

# Crazyflie Python Cheat Sheet (cflib)

This document is a compact, structured reference for the **most-used** Crazyflie Python (`cflib`) commands.
It includes **what each command does**, **inputs + units**, and **minimal examples**.

## Table of Contents

- [Crazyflie Python Cheat Sheet (cflib)](#crazyflie-python-cheat-sheet-cflib)
  - [0) Fundamental Settings (Always the same)](#0-fundamental-settings-always-the-same)
    - [Imports (Standard)](#imports-standard)
    - [`cflib.crtp.init_drivers()`](#cflibcrtpinit_drivers)
    - [`SyncCrazyflie(URI, cf=Crazyflie(...))`](#synccrazyflieuris-cfcrazyflie)
  - [1) Commander (Flight Commands)](#1-commander-flight-commands)
    - [1.1 `send_setpoint(roll, pitch, yawrate, thrust)`](#11-send_setpointroll-pitch-yawrate-thrust)
    - [1.2 `send_hover_setpoint(vx, vy, yawrate, zDistance)`](#12-send_hover_setpointvx-vy-yawrate-zdistance)
    - [1.3 `send_stop_setpoint()`](#13-send_stop_setpoint)
  - [2) Parameter API (`cf.param.*`)](#2-parameter-api-cfparam)
    - [2.1 `set_value(name, value)`](#21-set_valuename-value)
    - [2.2 `get_value(name)`](#22-get_valuename)
  - [3) Brushless “Direct Motor” Override — `motorPowerSet.*`](#3-brushless-direct-motor-override--motorpowerset)
    - [3.1 Relevant parameters](#31-relevant-parameters)
    - [3.2 Robust pattern (proven in practice)](#32-robust-pattern-proven-in-practice)
  - [4) Logging (Telemetry) — `LogConfig` + `SyncLogger`](#4-logging-telemetry--logconfig--synclogger)
    - [4.1 Setup](#41-setup)
    - [4.2 `LogConfig(name, period_in_ms)`](#42-logconfigname-period_in_ms)
    - [4.3 `add_variable(varname, vartype)`](#43-add_variablevarname-vartype)
    - [4.4 `SyncLogger(scf, logconf)`](#44-syncloggerscf-logconf)
  - [5) MotionCommander (Comfortable motions)](#5-motioncommander-comfortable-motions)
    - [5.1 Import](#51-import)
    - [5.2 Constructor](#52-constructor)
    - [5.3 Typical methods (conceptual)](#53-typical-methods-conceptual)
  - [6) What students must understand (Inputs + Units)](#6-what-students-must-understand-inputs--units)
    - [6.1 `send_hover_setpoint(vx, vy, yawrate, z)`](#61-send_hover_setpointvx-vy-yawrate-z)
    - [6.2 `send_setpoint(roll, pitch, yawrate, thrust)`](#62-send_setpointroll-pitch-yawrate-thrust)
  - [7) (If available) Estimator + Flowdeck + Multiranger (Enable + Log)](#7-if-available-estimator--flowdeck--multiranger-enable--log)
    - [7.1 Enable Estimator (via parameters)](#71-enable-estimator-via-parameters)
    - [7.2 List available log variables (TOC) and filter (recommended)](#72-list-available-log-variables-toc-and-filter-recommended)
    - [7.3 Log `stateEstimate.*` (Estimator output)](#73-log-stateestimate-estimator-output)
    - [7.4 Log Multiranger distances (typical pattern)](#74-log-multiranger-distances-typical-pattern)
    - [7.5 Log Flowdeck optical flow (typical pattern)](#75-log-flowdeck-optical-flow-typical-pattern)
    - [7.6 Combined logger (Estimator + Range + Flow) in one stream](#76-combined-logger-estimator--range--flow-in-one-stream)

---

## 0) Fundamental Settings (Always the same)

### Imports (Standard)

```python
import time
import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
```
---

### `cflib.crtp.init_drivers()`

Initializes Crazyradio/USB drivers. Call **once** at program start.

```python
cflib.crtp.init_drivers()
```

---

### `SyncCrazyflie(URI, cf=Crazyflie(...))`

Synchronous connect/disconnect via context manager.

**Inputs**
- `URI` *(str)*: radio URI, e.g. `radio://0/80/2M/E7E7E7E701`
- `cf` *(Crazyflie)*: Crazyflie object, optional cache: `rw_cache="./cache"`

**Example**
```python
URI = "radio://0/80/2M/E7E7E7E701"

cflib.crtp.init_drivers()
with SyncCrazyflie(URI, cf=Crazyflie(rw_cache="./cache")) as scf:
    print("connected")
# leaving the block => disconnect happens automatically
```
---
## 1) Commander (Flight Commands)

Main entry:
```python
cmd = scf.cf.commander
```

---

### 1.1 `send_setpoint(roll, pitch, yawrate, thrust)`

Low-level **RPYT setpoint**. Very direct. Can work without decks (but **open-loop**, not precise).

**Inputs**
- `roll` *(float, deg)*: roll setpoint (typically degrees; often an angle, not rate)
- `pitch` *(float, deg)*: pitch setpoint (degrees)
- `yawrate` *(float, deg/s)*: yaw angular rate
- `thrust` *(int, raw)*: thrust command (typical rough range: `0 ... 60000`)

**Important**
- Must be sent **cyclically** (e.g. 50–100 Hz). A single call is not held.

**Example: 2 seconds “light thrust” (open-loop!)**
```python
import time
import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie

URI = "radio://0/80/2M/E7E7E7E701"

cflib.crtp.init_drivers()
with SyncCrazyflie(URI, cf=Crazyflie()) as scf:
    for _ in range(100):  # 100 * 0.02s = 2s at 50 Hz
        scf.cf.commander.send_setpoint(0.0, 0.0, 0.0, 20000)
        time.sleep(0.02)
    scf.cf.commander.send_stop_setpoint()
```

---

### 1.2 `send_hover_setpoint(vx, vy, yawrate, zDistance)`

High-level hover setpoint (**velocity + yawrate + height**).

**Inputs**
- `vx` *(float, m/s)*: forward/back velocity (sign depends on body frame)
- `vy` *(float, m/s)*: left/right velocity
- `yawrate` *(float, deg/s)*: yaw angular rate
- `zDistance` *(float, m)*: target height

**Important (for teaching)**
- Without height/position sensing, `zDistance` is not “magic” — height will **not** be stable.
- Must be sent **cyclically** (10–100 Hz). A single call is not held.

**Example: 3 seconds hover at 0.5 m (only meaningful with sensor/estimator)**
```python
import time
import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie

URI = "radio://0/33/2M/E7E7E7E7AA"

cflib.crtp.init_drivers()
with SyncCrazyflie(URI, cf=Crazyflie(rw_cache="./cache")) as scf:
    t0 = time.time()
    while time.time() - t0 < 3.0:
        scf.cf.commander.send_hover_setpoint(0.0, 0.0, 0.0, 0.5)
        time.sleep(0.05)  # 20 Hz
    scf.cf.commander.send_hover_setpoint(0.0, 0.0, 0.0, 0.0)
    time.sleep(0.2)
    scf.cf.commander.send_stop_setpoint()
```

---

### 1.3 `send_stop_setpoint()`

Stops setpoint streaming cleanly.

**Example**
```python
scf.cf.commander.send_stop_setpoint()
```

---

## 2) Parameter API (`cf.param.*`)

Used for modes, enables, and firmware parameters (e.g. `motorPowerSet.*`).

---

### 2.1 `set_value(name, value)`

**Inputs**
- `name` *(str)*: parameter name
- `value` *(str)*: value is always sent as a string

**Example**
```python
scf.cf.param.set_value("stabilizer.controller", "1")
```

---

### 2.2 `get_value(name)`

Returns current value as a **string**.

**Example**
```python
v = scf.cf.param.get_value("motorPowerSet.enable")
print(v)
```

---

## 3) Brushless “Direct Motor” Override — `motorPowerSet.*`

This is **not** a flight controller mode. It is a motor override (good for tests, dangerous with propellers).

### 3.1 Relevant parameters
- `motorPowerSet.m1..m4` *(int as string)*: motor values
- `motorPowerSet.enable` *(0/1)*: override on/off

### 3.2 Robust pattern (proven in practice)
(Set `m1..m4`, short pause, then `enable=1`; to stop: `m1..m4=0`, pause, then `enable=0`.)

```python
import time

def motor_override_start(scf, pwm=5000):
    scf.cf.param.set_value("motorPowerSet.m1", str(pwm))
    scf.cf.param.set_value("motorPowerSet.m2", str(pwm))
    scf.cf.param.set_value("motorPowerSet.m3", str(pwm))
    scf.cf.param.set_value("motorPowerSet.m4", str(pwm))
    time.sleep(0.5)
    scf.cf.param.set_value("motorPowerSet.enable", "1")

def motor_override_stop(scf):
    scf.cf.param.set_value("motorPowerSet.m1", "0")
    scf.cf.param.set_value("motorPowerSet.m2", "0")
    scf.cf.param.set_value("motorPowerSet.m3", "0")
    scf.cf.param.set_value("motorPowerSet.m4", "0")
    time.sleep(0.5)
    scf.cf.param.set_value("motorPowerSet.enable", "0")
```

---

## 4) Logging (Telemetry) — `LogConfig` + `SyncLogger`

**Typical use-cases**
- battery voltage (`pm.vbat`)
- estimated states (`stateEstimate.*`) (only if estimator active)
- sensor values (firmware-dependent)

### 4.1 Setup
```python
from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncLogger import SyncLogger
```

---

### 4.2 `LogConfig(name, period_in_ms)`

**Inputs**
- `name` *(str)*
- `period_in_ms` *(int)*: e.g. 100 for 10 Hz

---

### 4.3 `add_variable(varname, vartype)`

**Inputs**
- `varname` *(str)*: e.g. "pm.vbat"
- `vartype` *(str)*: often "float"

---

### 4.4 `SyncLogger(scf, logconf)`

Iterates log entries.

**Example: log battery for 2 seconds**
```python
import time
from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncLogger import SyncLogger

logconf = LogConfig(name="bat", period_in_ms=200)
logconf.add_variable("pm.vbat", "float")

t0 = time.time()
with SyncLogger(scf, logconf) as logger:
    for entry in logger:
        ts, data, _ = entry
        print("vbat:", data["pm.vbat"])
        if time.time() - t0 > 2.0:
            break
```

---

## 5) MotionCommander (Comfortable motions)

Very useful in teaching labs if **positioning support** exists (Flowdeck/estimator etc.).

### 5.1 Import
```python
from cflib.positioning.motion_commander import MotionCommander
```

### 5.2 Constructor
`MotionCommander(scf, default_height=...)`

**Inputs**
- `scf`: SyncCrazyflie handle
- `default_height` *(m)*: e.g. 0.5

### 5.3 Typical methods (conceptual)
- `take_off(...)`
- `land(...)`
- `forward(...)`, `back(...)`, `left(...)`, `right(...)`
- `turn_left(...)`, `turn_right(...)`

**Example (pattern)**
```python
import time
from cflib.positioning.motion_commander import MotionCommander

with MotionCommander(scf, default_height=0.5) as mc:
    time.sleep(1.0)       # hover
    mc.forward(0.3)       # API may interpret as distance in meters (version-dependent)
    mc.turn_left(90)      # degrees
    time.sleep(1.0)
# context exit -> often lands automatically (depending on demo/usage)
```

**Note**
Exact signatures can vary slightly with `cflib` versions; the above are the common patterns used in examples.

---

## 6) What students must understand (Inputs + Units)

### 6.1 `send_hover_setpoint(vx, vy, yawrate, z)`
- `vx`, `vy` are **m/s** (start small: 0.1–0.3)
- `yawrate` is **deg/s** (e.g. 20–60)
- `z` is **m** (e.g. 0.3–0.8 indoor)

### 6.2 `send_setpoint(roll, pitch, yawrate, thrust)`
- `roll`, `pitch` keep small (e.g. 0…10)
- `yawrate` is **deg/s**
- `thrust` is **raw**, must be found empirically (depends strongly on setup)

## 7) (If available) Estimator + Flowdeck + Multiranger (Enable + Log)

This section shows **minimal snippets** to:
- enable an estimator (e.g., Kalman) via parameters
- verify deck/sensor-related log variables exist
- log typical values from `stateEstimate.*`, Flowdeck, and Multiranger

> **Rule:** Do not guess variable names. If unsure, first list available log variables (TOC).

---

### 7.1 Enable Estimator (via parameters)

> The numeric values are **firmware-dependent**. If your firmware uses different mappings, set them in CFClient and only *read back* in Python.

```python
# Enable estimator + controller (values can differ by firmware build)
scf.cf.param.set_value("stabilizer.estimator", "2")    # often: Kalman
scf.cf.param.set_value("stabilizer.controller", "1")   # often: PID
time.sleep(0.5)

# Optional read-back
est = scf.cf.param.get_value("stabilizer.estimator")
ctl = scf.cf.param.get_value("stabilizer.controller")
print("estimator =", est, "controller =", ctl)
```

---

### 7.2 List available log variables (TOC) and filter (recommended)

Use this once to discover the **real** variable names on your firmware.

```python
def print_log_vars(scf, contains="range", limit=200):
    toc = scf.cf.log.toc.toc  # group -> vars
    n = 0
    for group, vars_dict in toc.items():
        for name in vars_dict.keys():
            full = f"{group}.{name}"
            if contains.lower() in full.lower():
                print(full)
                n += 1
                if n >= limit:
                    print("... truncated")
                    return

print_log_vars(scf, contains="stateEstimate")
print_log_vars(scf, contains="range")
print_log_vars(scf, contains="motion")
print_log_vars(scf, contains="flow")
```

---

### 7.3 Log `stateEstimate.*` (Estimator output)

```python
from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncLogger import SyncLogger

logconf = LogConfig(name="est", period_in_ms=50)  # 20 Hz
logconf.add_variable("stateEstimate.x", "float")
logconf.add_variable("stateEstimate.y", "float")
logconf.add_variable("stateEstimate.z", "float")
logconf.add_variable("stateEstimate.yaw", "float")

with SyncLogger(scf, logconf) as logger:
    for ts, data, _ in logger:
        x   = data["stateEstimate.x"]
        y   = data["stateEstimate.y"]
        z   = data["stateEstimate.z"]
        yaw = data["stateEstimate.yaw"]
        # use x,y,z,yaw in your logic here
        break
```

---

### 7.4 Log Multiranger distances (typical pattern)

> Variable names can differ. Confirm via TOC (7.2) before using.

Common patterns often include entries like:
- `range.front`, `range.back`, `range.left`, `range.right`, `range.up`, `range.down`
- or a single `range.zrange`

```python
logconf = LogConfig(name="mr", period_in_ms=100)  # 10 Hz

# Replace with the names that exist on YOUR firmware (use TOC first)
logconf.add_variable("range.front", "uint16_t")
logconf.add_variable("range.back", "uint16_t")
logconf.add_variable("range.left", "uint16_t")
logconf.add_variable("range.right", "uint16_t")
logconf.add_variable("range.up", "uint16_t")
logconf.add_variable("range.down", "uint16_t")

with SyncLogger(scf, logconf) as logger:
    for _, data, _ in logger:
        d_front = data["range.front"]
        d_left  = data["range.left"]
        d_right = data["range.right"]
        # units are typically millimeters (firmware-dependent)
        break
```

---

### 7.5 Log Flowdeck optical flow (typical pattern)

> Flowdeck variables differ across firmware. Confirm via TOC (7.2).
Typical groups/keywords to search: `"motion"`, `"flow"`, `"kalman"`, `"stateEstimate"`.

A common pattern is to log flow-derived motion deltas or velocity-like values.

```python
logconf = LogConfig(name="flow", period_in_ms=50)  # 20 Hz

# Replace with the names that exist on YOUR firmware (use TOC first)
logconf.add_variable("motion.deltaX", "int16_t")
logconf.add_variable("motion.deltaY", "int16_t")

with SyncLogger(scf, logconf) as logger:
    for _, data, _ in logger:
        dx = data["motion.deltaX"]
        dy = data["motion.deltaY"]
        # dx/dy are often in "flow ticks" or similar units (firmware-dependent)
        break
```

---

### 7.6 Combined logger (Estimator + Range + Flow) in one stream

> Only add variables that exist; otherwise the logger setup fails.

```python
logconf = LogConfig(name="combo", period_in_ms=50)  # 20 Hz

# estimator
logconf.add_variable("stateEstimate.x", "float")
logconf.add_variable("stateEstimate.y", "float")
logconf.add_variable("stateEstimate.z", "float")

# range (example)
logconf.add_variable("range.front", "uint16_t")
logconf.add_variable("range.left", "uint16_t")
logconf.add_variable("range.right", "uint16_t")

# flow (example)
logconf.add_variable("motion.deltaX", "int16_t")
logconf.add_variable("motion.deltaY", "int16_t")

with SyncLogger(scf, logconf) as logger:
    for _, data, _ in logger:
        z  = data["stateEstimate.z"]
        rf = data["range.front"]
        dx = data["motion.deltaX"]
        # use values here
        break
```
[GO BACK TO THE CRAZYFLIE SECTION](README.md)