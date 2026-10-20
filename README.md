# Mobile Robots — MATLAB Path Planning

**FH JOANNEUM · Complete guided lab package (English lab instructions)**

The files are deliberately separated into **learning material** and **runnable MATLAB code**.

```text
MobileRobots_PathPlanning/
│  README.md                  ← this overview
├─ ANLEITUNGEN/
│  ├─ README.md               ← index to the nine Markdown chapters
│  ├─ CORE_ROUTE.md           ← short guided path through 3 lab blocks
│  ├─ 01_basics.md            ← inspect and experiment with supplied tools
│  ├─ 02_depth_first.md       ← DFS
│  ├─ 03_breadth_first.md     ← BFS
│  ├─ 04_dijkstra.md          ← Dijkstra
│  ├─ 05_greedy.md            ← Greedy Best-First
│  ├─ 06_astar.md             ← A*
│  ├─ 07_comparison.md        ← compare YOUR code in random maps
│  ├─ 08_car_in_maze.md       ← car visualization through a labyrinth
│  ├─ 09_crazycar_outlook.md  ← later vehicle-motion planning
│  └─ figures/                ← images used by the Markdown documents
└─ MATLAB/
   ├─ README.md               ← how to run MATLAB files
   ├─ setup_path.m
   ├─ check_tools.m
   ├─ tasks/                  ← student implementations, 6 files
   ├─ demos/                  ← supplied function examples
   ├─ experiments/            ← parameter and comparison experiments
   ├─ tools/                  ← supplied helper functions
   ├─ checks/                 ← automatic self-tests
   ├─ toolchecks/             ← basic toolbox checks
   └─ solutions/              ← instructor reference, teacher version only
```

## Start

1. Read [the guided route](ANLEITUNGEN/CORE_ROUTE.md).
2. In MATLAB set your **Current Folder** to `MATLAB/` (not the outer package folder).
3. Run `setup_path` and `check_tools`.
4. Follow the detailed [Markdown chapters](ANLEITUNGEN/README.md) if you need explanations, worked examples, or help with debugging.

## Final outcomes

The instructor defines the exact assessment requirements. The intended final results are your own five MATLAB graph-search algorithms, the ability to explain their decision processes, and an animated car travelling through a maze along a path **computed by your own planner**. The Markdown tasks and small experiments are for learning; no separate reports or compulsory intermediate hand-ins are imposed by this package.

## What 'car in maze' currently means

The MATLAB code visualizes a small top-down car shape following discrete grid cells. It does **not** contain or claim to reproduce a CrazyCar simulator with steering angle, velocity dynamics, collision footprint or time-optimal driving. A verified simulator API would be needed for that later extension.

## Reliability

The package was assembled from the previously supplied MATLAB course and guided Markdown instructions, plus a small grid-car demonstration. Files, internal links and ZIP integrity were checked. **MATLAB execution was not verified** in this environment; run the tests on your teaching computer before distributing the package.
