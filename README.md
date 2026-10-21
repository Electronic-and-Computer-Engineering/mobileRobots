# Mobile Robots — Path Planning MATLAB course

**FH JOANNEUM · guided code exercises and Markdown instructions**

The folder is deliberately divided into **ANLEITUNGEN** (readable tasks and explanations) and **MATLAB** (runnable code). The provided toolbox is not part of the student implementation assignment.

```text
MobileRobots_PathPlanning/
├── README.md
├── ANLEITUNGEN/
│   ├── CORE_ROUTE.md                  guided sequence and clearly labelled TASKs
│   ├── 01_basics.md                   explanation of supplied functions
│   ├── 02_depth_first.md ... 06_astar.md
│   ├── 07_comparison.md              random-map evaluation
│   ├── 08_car_in_maze.md              following laboratory, not this one
│   ├── 09_crazycar_outlook.md         future vehicle-motion model
│   └── figures/
└── MATLAB/
    ├── setup_path.m, check_tools.m
    ├── tasks/                        five search algorithms (+ later car task)
    ├── experiments/                  independent experiment_*.m scripts
    ├── demos/                        supplied examples
    ├── tools/                        supplied functions: do not edit
    ├── checks/, toolchecks/
    └── solutions/                    instructor version ONLY
```

## Start

**TASK:** Set MATLAB's Current Folder to `MATLAB/`, then run:

```matlab
setup_path
check_tools
```

Open [CORE_ROUTE.md](ANLEITUNGEN/CORE_ROUTE.md), then [01_basics.md](ANLEITUNGEN/01_basics.md). Individual scripts are small and independent; their filenames start with `experiment_` rather than numbers.

## Intended learning sequence

**Current laboratory:** Learn supplied functions, implement DFS, BFS, Dijkstra, Greedy and A*, compare your own code on several maps and be able to **explain your decisions and code orally**.

**Following laboratory:** Apply planning to an animated vehicle in a maze. The included small MATLAB animation is **not** an actual CrazyCar dynamics simulator; steering angle and speed dynamics require the later vehicle model and simulator integration.

The instructor defines the precise assessment requirements. Experiment results, screenshots and Markdown explanations are learning aids, not separately specified submissions.

## Testing and validation

The user has successfully run `check_tools` with **79 checks passed** on their MATLAB installation for the corrected toolbox. The newly structured experiment scripts have been checked for references and syntax structure, but have **not been executed in MATLAB** here. Run them on the lab machine before class.
