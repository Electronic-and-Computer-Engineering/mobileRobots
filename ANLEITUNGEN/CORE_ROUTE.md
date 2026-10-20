[← Lab chapters](README.md) · [01 Toolbox →](01_basics.md)

# Guided route — Path Planning Lab

**Mobile Robots · FH JOANNEUM · MATLAB**

Work through the sections in order. You may consult any provided documentation, demonstration, source code or expandable explanation. **TASK** identifies what you must actively do. Explanations and additional experiments help you learn; they are not separate submissions.

For each task: **open the named file → predict → run → modify one input → explain what changed → test.**

## Block 1 — Toolbox, DFS and BFS

| File to open | **TASK — What you do** |
|---|---|
| `demos/demo_container.m` and `experiments/01_toolbox_experiments.m` | **TASK:** Test FIFO, LIFO and `minkey`; predict the extraction order and explain the result. |
| `demos/demo_graph.m`, `demos/demo_grid.m` | **TASK:** Retrieve neighbours and costs; convert grid coordinates and investigate legal movements. |
| `demos/demo_heuristic.m`, `demos/demo_maps.m` | **TASK:** Change a heuristic or map seed and interpret the observed result. |
| `tasks/dfs_graph.m` + [Chapter 02](02_depth_first.md) | **TASK:** Implement DFS using your toolbox knowledge; validate it with `check_my_code('dfs')`. |
| `tasks/bfs_graph.m` + [Chapter 03](03_breadth_first.md) | **TASK:** Derive BFS by changing the container behaviour; explain the difference from DFS and run `check_my_code('bfs')`. |

<<<<<<< HEAD
## Block 2 — Dijkstra, Greedy, A*

| File to open | **TASK — What you do** |
|---|---|
| `tasks/dijkstra_graph.m` + [Chapter 04](04_dijkstra.md) | **TASK:** Implement cumulative costs and relaxation; show why a cheaper route replaces a previous one. |
| `tasks/greedy_graph.m` + [Chapter 05](05_greedy.md) | **TASK:** Use the heuristic `h` to choose the next node; explain the consequences of ignoring path costs. |
| `tasks/astar_graph.m` + [Chapter 06](06_astar.md) | **TASK:** Implement `f=g+h`, compare with Dijkstra at `h=0` and verify your implementation. |
=======
## Block 2 — Weighted planning, heuristics, A*
>>>>>>> 0560121560e8eb57743c188eaa5f058215af8d19

## Block 3 — Random maps and car in the maze

<<<<<<< HEAD
| File to open | **TASK — What you do** |
|---|---|
| `tools/search_student_grid.m` and `checks/check_student_grid.m` | **TASK:** Verify that the grid adapter calls your own search implementations. |
| `experiments/07_random_comparison.m` + [Chapter 07](07_comparison.md) | **TASK:** Run the five planners on the same reproducible maps and explain differences in route cost, expansions and runtime. |
| `demos/demo_car_visualization.m` | **TASK:** Inspect and run the supplied animation; identify its inputs and its limits. |
| `tasks/car_in_maze.m` + [Chapter 08](08_car_in_maze.md) | **TASK:** Connect your own planner to the car animation and handle unreachable goals safely. |
| `checks/check_car_maze.m`, `experiments/08_car_experiment.m` | **TASK:** Verify the integrated result and demonstrate the car following a route found by your planner. |

## What counts as the final result
=======
## Block 3 — Random maps and car animation
>>>>>>> 0560121560e8eb57743c188eaa5f058215af8d19

**TASK — Algorithms:** Implement DFS, BFS, Dijkstra, Greedy Best-First and A* in the provided `tasks/` files. Be able to explain what each algorithm does and why it chooses its next node.

<<<<<<< HEAD
**TASK — Car in the maze:** Complete `tasks/car_in_maze.m` so the visible car follows the path returned by your own planner. Be able to explain the separation between planning and animation.

The instructor sets the actual assessment requirements. Checkpoints, parameter variations, screenshots and questions are learning aids rather than additional compulsory submissions.
=======
## Only the intended final results
>>>>>>> 0560121560e8eb57743c188eaa5f058215af8d19

**Scope:** The moving car is a grid animation, not the CrazyCar simulator with steering angle, acceleration and physically feasible driving. [Vehicle-motion outlook](09_crazycar_outlook.md) is a separate later topic.
