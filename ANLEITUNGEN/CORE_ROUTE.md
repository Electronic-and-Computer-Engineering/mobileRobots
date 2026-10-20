[← Lab chapters](README.md) · [01 Toolbox →](01_basics.md)

# Guided route — three laboratory blocks

**Mobile Robots · FH JOANNEUM · MATLAB**

You may look up functions, read the detailed guides and use the collapsed hints. The purpose of the lab is to understand and implement the five algorithms and make an animated car move through a generated labyrinth **using your own path planner**.

Each activity follows the same sequence: **Open the named file → predict → run → change one parameter → explain → check**. There is no obligation to produce screenshots or separate written reports unless the instructor explicitly specifies this.

## Block 1 — Understand the tools; DFS and BFS

| Open in MATLAB | Guided focus | Suggested time |
|---|---|---:|
| `demos/demo_container.m` and `experiments/01_toolbox_experiments.m` | FIFO/LIFO, repeat a parameter experiment | 15 min |
| `demos/demo_graph.m`, `demos/demo_grid.m` | Neighbours, graph weights, cell indices | 15 min |
| `demos/demo_heuristic.m` and `demos/demo_maps.m` | A heuristic and a reproducible random map | 10 min |
| `tasks/dfs_graph.m` + [Chapter 02](02_depth_first.md) | Build DFS progressively; run `check_my_code('dfs')` | 45 min |
| `tasks/bfs_graph.m` + [Chapter 03](03_breadth_first.md) | Derive BFS from DFS; run `check_my_code('bfs')` | 25 min |

## Block 2 — Weighted planning, heuristics, A*

| Open in MATLAB | Guided focus | Suggested time |
|---|---|---:|
| `tasks/dijkstra_graph.m` + [Chapter 04](04_dijkstra.md) | Understand cost updates (`g`) and relaxation, then implement | 55 min |
| `tasks/greedy_graph.m` + [Chapter 05](05_greedy.md) | Prioritize by `h` rather than insertion order | 25 min |
| `tasks/astar_graph.m` + [Chapter 06](06_astar.md) | Prioritize by `g+h`; test with `h=0` | 40 min |

## Block 3 — Random maps and car animation

| Open in MATLAB | Guided focus | Suggested time |
|---|---|---:|
| `tools/search_student_grid.m` + `checks/check_student_grid.m` | Verify that the random-map test uses **your** algorithms | 20 min |
| `experiments/07_random_comparison.m` + [Chapter 07](07_comparison.md) | Compare costs and expansions on the same maps | 35 min |
| `demos/demo_car_visualization.m` | See the provided grid-car animation helper | 10 min |
| `tasks/car_in_maze.m` + [Chapter 08](08_car_in_maze.md) | Connect your planner and car animation | 35 min |
| `checks/check_car_maze.m` and `experiments/08_car_experiment.m` | Verify and explain the complete behaviour | 15 min |

## Only the intended final results

- The five working MATLAB algorithms under `tasks/` and your ability to explain them.
- The working `tasks/car_in_maze.m` application in which the visualized car follows the route your planner computed.

The instructor defines the specific assessment criteria. Additional parameter experiments, screenshots and written observations in the detailed guides are there to help you understand the code; they are not separate required submissions.

**Important:** the animated grid car is not a physically constrained CrazyCar simulation. [Vehicle-aware path planning](09_crazycar_outlook.md) is a later topic.
