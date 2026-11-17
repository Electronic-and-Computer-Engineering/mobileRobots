# Mobile Robots — the lab

**FH JOANNEUM** · Dipl.-Ing. Florian Mayer, BSc

Two halves, one question: how does a vehicle work out where to go, and how
does it then actually get there?

The first half answers it in simulation, with a car that cannot turn on the
spot. The second half answers it on hardware that falls out of the air if you
get it wrong.

| Part | Language | What you build | Start here |
| --- | --- | --- | --- |
| [**PathPlanning**](PathPlanning/ANLEITUNGEN/README.md) | MATLAB | five search algorithms, written by you, and then a car with real dimensions driven through them | [PathPlanning/ANLEITUNGEN/README.md](PathPlanning/ANLEITUNGEN/README.md) |
| [**CrazyFlie**](CrazyFlie/README.md) | Python | a drone that connects, arms, hovers, flies a programmed path and keeps its distance | [CrazyFlie/README.md](CrazyFlie/README.md) |

Do them in that order. The drone half assumes you already know what a
neighbour, a cost and a free cell are, because you wrote them yourself.

---

## The arc of the course

**PathPlanning, chapters 01 to 07 — the algorithms.** One loop, five
behaviours. Depth-first, breadth-first, Dijkstra, greedy best-first and A\*
differ in one line: which node comes out of OPEN next. You implement each one
and compare them on maps that were not used to develop them.

**PathPlanning, chapters 08 to 10 — the vehicle.** A cell is replaced by a
pose, and a step by an arc that a 22 cm car can actually drive. You derive the
motion space from the bicycle model, build it into your own neighbour
function, prove it on a practice oval, and then face the CrazyCar track, where
the trade-off between not crashing and being quick has to be tuned against
three numbers that disagree with each other.

**CrazyFlie, chapters 1 and 2 — the real thing.** Setup first: Python, the
radio, the Bitcraze GUI, firmware, the URI. Then eight examples, from a link
that opens to a drone that backs away from your hand. Here the motion space is
not a model any more. It is physics, and the obstacles are measured rather
than stored in a map.

---

## What is in the repository

```text
.
├── README.md                       this page
├── PathPlanning/
│   ├── ANLEITUNGEN/                chapters 01 to 10, the guided route, figures
│   └── MATLAB/                     tasks/, tools/, demos/, experiments/, checks/, map/
└── CrazyFlie/
    ├── README.md                   the drone section, and its house rules
    ├── 01_Setup/                   software, radio, GUI, firmware, URI
    ├── 02_BasicMovements/          connect, arm, hover, square, yaw, log, push demo
    └── examples/                   the eight scripts, plus cflab.py
```

---

## What you need

**For PathPlanning**

| | |
| --- | --- |
| MATLAB | no toolboxes beyond base MATLAB |
| First command | `setup_path` in `PathPlanning/MATLAB`, then `check_tools` |

**For CrazyFlie**

| | |
| --- | --- |
| Python | 3.10 or newer, in a virtual environment |
| Packages | `cflib`, and `cfclient` for the GUI |
| Hardware | Crazyflie 2.1 Brushless, Crazyradio, Flow deck v2, Multiranger deck |
| First command | `python examples/01_connect.py` in `CrazyFlie` |

The setup chapter walks through all of it:
[CrazyFlie/01_Setup/README.md](CrazyFlie/01_Setup/README.md).

---

## How the two halves fit together

The vocabulary carries over, and it is worth noticing where it stops carrying.

| In MATLAB | On the drone |
| --- | --- |
| a node is a cell, then a pose `(x, y, θ)` | a pose is what the estimator believes, and it drifts |
| neighbours come from five stored arcs | neighbours are whatever the drone can actually fly in the next tenth of a second |
| an obstacle is a cell in a map you were given | an obstacle is a distance a sensor reported a moment ago, or `None` |
| the safety margin is a number you tune | the safety margin is how far you stand from the propellers |
| a crash costs a re-run | a crash costs a propeller |

The Push Demo at the end of the drone half is the smallest planner in the
course: one step deep, no map, no cost function. Watch it fail in a narrow
corridor, then think back to chapter 10, where the same problem was solved
with a map, a model and a search.

---

## House rules

- The chapters are the assignment. The **TASK** blocks are where the work is;
  everything else is there so the tasks can be done.
- The MATLAB `tools/` functions are given and are not to be modified. Your
  code goes in `tasks/`.
- On the drone: propellers off for everything that does not have to fly, and
  cfclient and Python never hold the radio at the same time.
- Solutions are not in this repository.

---

## Assessment

The instructor sets the learning objectives. The predictions, the optional
investigations and the collapsed answers in the chapters are there to prepare
you for explaining your own implementation **orally**. They are not extra
assignments to hand in.
