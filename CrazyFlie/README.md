[BACK TO THE REPOSITORY](../README.md) · [CHEAT SHEET](cfCmdCheatSheets.MD)

# CrazyFlie — the Python part of the lab

Up to here the course planned paths for a car, in MATLAB
([PathPlanning](../PathPlanning/ANLEITUNGEN/README.md)). This section leaves
the simulation and the car behind: the vehicle is a Crazyflie, the language is
Python, and the thing that goes wrong is no longer a search that fails but a
motor that does not spin.

Two chapters, in this order.

| Chapter | What it does | What you have at the end |
| --- | --- | --- |
| [1 — Setup](01_Setup/README.md) | Python, cflib, the Crazyradio, the Bitcraze GUI, flashing, the radio URI | a drone that answers |
| [2 — Basic movements](02_BasicMovements/README.md) | connect, arm, thrust, hover, square, yaw, logging, and the Push Demo | a drone that flies a programmed path and keeps its distance |

Everything in chapter 2 assumes chapter 1 worked. If a script cannot connect,
the answer is in chapter 1, not in the script.

## The drone

| Drone | URI | What to know about it |
| --- | --- | --- |
| Crazyflie 2.1 Brushless | `radio://0/33/2M/E7E7E7E7AA` | it has to be armed before a motor turns, and it idles its propellers as soon as it is armed |

Arming is the subject of chapter 2, section 2.4, and it is the first thing to
check whenever a script connects and nothing happens. Most Crazyflie code you
will find on the internet was written for the older brushed models, which arm
themselves — that code connects fine here and then does nothing.

## Layout

```text
CrazyFlie/
├── README.md                     this page
├── 01_Setup/README.md            chapter 1
├── 02_BasicMovements/README.md   chapter 2
└── examples/
    ├── cflab.py                  the shared helpers (URI, arming, decks)
    ├── 01_connect.py
    ├── 02_arm_disarm.py
    ├── 03_thrust_ramp.py         propellers off
    ├── 04_hover.py               Flow deck
    ├── 05_square.py              Flow deck
    ├── 06_yaw.py                 Flow deck
    ├── 07_log_estimator.py
    └── 08_push_demo.py           Flow deck + Multiranger
```

The scripts under `examples/` are the same code that is printed in chapter 2 —
they are extracted from it, so the page and the files cannot drift apart. Run
them from this folder:

```bash
python examples/01_connect.py
```

## House rules

- Propellers off for everything that does not have to fly.
- cfclient and Python never hold the radio at the same time.
- The URI is written once, in `examples/cflab.py`. Not in eight scripts.
- Look a log variable up in the Log TOC tab before you type it into Python.
