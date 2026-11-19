[← Lab chapters](README.md) · [Start with the toolbox →](01_basics.md)

# Guided route — Path Planning

**Mobile Robots · FH JOANNEUM · MATLAB**

The instructor sets the final assessment requirements. You may look up MATLAB documentation, inspect provided helper functions and consult the expandable answers. **TASK** tells you exactly what to try. The small experiments support understanding and do **not** require separate written submissions.

In MATLAB, first set the Current Folder to `MATLAB/`, then run:

```matlab
setup_path
check_tools
```

## Part A — Learn the tools

**TASK — Start with [01 Toolbox](01_basics.md):** Open the following files in sequence. For each, predict the output, run, modify one parameter and explain what changed.

| Experiment file | **TASK — What to investigate** |
|---|---|
| `experiments/experiment_open_fifo_lifo.m` | **TASK:** Create OPEN, insert nodes, inspect `open_size` and `open_isempty`, remove nodes; compare FIFO and LIFO. |
| `experiments/experiment_open_return_values.m` | **TASK:** Compare correct and omitted `OPEN =` assignment; explain the returned value of `open_push`. |
| `experiments/experiment_open_priority.m` | **TASK:** Use `minkey` with explicit numeric priorities and inspect the optional key output of `open_pop`. |
| `experiments/experiment_graph_neighbors.m` | **TASK:** Query neighbour IDs and their paired edge costs. |
| `experiments/experiment_path_reconstruction.m` | **TASK:** Rebuild a path from `par` and change its predecessor chain. |
| `experiments/experiment_grid_indexing.m` | **TASK:** Convert between matrix coordinates and scalar node IDs. |
| `experiments/experiment_grid_neighbors.m` | **TASK:** Compare 4/8 neighbourhoods and permitted diagonal movements. |
| `experiments/experiment_heuristics.m` | **TASK:** Call a function handle `hfun` and compare distance estimates. |
| `experiments/experiment_random_maps.m` | **TASK:** Generate reproducible obstacle maps using seeds. |
| `experiments/experiment_search_pattern.m` | **TASK:** Recognise the shared OPEN/expand/neighbour search loop. |

## Part B — Build five algorithms

| Algorithm chapter | **TASK — Implementation** |
|---|---|
| [02 DFS](02_depth_first.md) | **TASK:** Complete `tasks/dfs_graph.m`, explain LIFO, use `check_my_code('dfs')`. |
| [03 BFS](03_breadth_first.md) | **TASK:** Derive `tasks/bfs_graph.m` from DFS using FIFO; test it. |
| [04 Dijkstra](04_dijkstra.md) | **TASK:** Complete `tasks/dijkstra_graph.m` with `g`, relaxation and priority-based OPEN. |
| [05 Greedy](05_greedy.md) | **TASK:** Complete `tasks/greedy_graph.m` using only the estimate `h` for node selection. |
| [06 A*](06_astar.md) | **TASK:** Extend Dijkstra to `f=g+h` in `tasks/astar_graph.m`; explain its decisions. |

## Part C — Apply and compare your algorithms

**TASK — [07 Comparison](07_comparison.md):** Run `check_my_code`, `check_student_grid`, and `experiments/experiment_random_comparison.m`. Keep the map and start/goal identical for all methods. Explain differences in path costs and expansions. The adapter `search_student_grid` uses your algorithms, not the independent reference planner.

## Part D — The vehicle laboratory

The vehicle is **not** part of the five-algorithm laboratory above. It is the next lab block, and it uses the algorithms you have just written: nothing in `tasks/dfs_graph.m` to `tasks/astar_graph.m` changes. What changes is the one function all five of them call to ask where they may go next.

**TASK — [08 The vehicle, and the moves it can make](08_vehicle_neighbors.md):** One calculation and one function. The calculation: given a pose, a steering command and a distance, where does the car end up and which way does it point? Complete **`tasks/car_primitives.m`** — the five moves — then plot them and watch sixteen full-lock moves close a circle. Put the body on top (`cc_pose_free`), and complete **`tasks/car_neighbors.m`**, which places the moves at the car's actual pose and tests the whole swept rectangle. Check with `check_car_primitives` and `check_car_neighbors`. The step-by-step version of the calculation is [IMPLEMENTING_THE_ARC.md](IMPLEMENTING_THE_ARC.md). You do not write the simulator, the controller, the search or the collision test.

**TASK — [09 A lap on the practice circuit](09_practice_circuit.md):** Run `experiments/experiment_oval_lap.m`: plan a lap on the oval with your own neighbour function, drive it, look at the plot. Then the one knob that matters — sweep `P.safety`, the margin the walls are inflated by, and face the trade-off between lap time and the smallest gap to a wall. Choose a value and defend it in three sentences.

**TASK — [10 The CrazyCar track](10_crazycar_track.md):** The original track, with the same code. Plan and drive a lap, find why one leg costs more than half the search, then plan the same lap as if the car were a point (`experiments/experiment_cc_point_vs_model.m`) and watch it crash — inflating the walls pays for the car's width, never for its length. Finally measure how narrow the usable margin window is here compared with the oval, and hand in a plot of your lap with three sentences.

*Optional, and only if you want more:* [APPENDIX_going_further.md](APPENDIX_going_further.md) — the four wheels the model replaces, the servo, the grip limit, why one move is 0.119 m, and the controller tuning bench. And `tasks/astar_car.m`, the pose search itself: your `astar_graph` with four lines changed, tested by `check_car_plan`.

**No additional written reports are specified by these Markdown chapters.** Be prepared to explain the algorithms and your code orally as required by the instructor.
