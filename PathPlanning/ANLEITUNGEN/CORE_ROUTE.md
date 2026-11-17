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

**TASK — [08 The vehicle in the search](08_vehicle_neighbors.md):** Meet the vehicle and the kinematic bicycle model. Derive the turning per metre driven, \(d\theta/ds = \cos\beta\tan\delta/L\), and see why the speed cancels out of it. Then complete **`tasks/car_primitives.m`** — the car's five moves, computed from the model — and **`tasks/car_neighbors.m`**, which places those moves at the car's actual pose and tests the whole swept rectangle against the walls. Check with `check_car_primitives` and `check_car_neighbors`. Read [VEHICLE_MODEL_REVIEW.md](VEHICLE_MODEL_REVIEW.md) afterwards. You do not write the simulator, the controller, the search or the collision test; those are given.

**TASK — [09 Practice circuit](09_practice_circuit.md):** Run `experiments/experiment_oval_lap.m` and follow the route through the chain: search → resample → speed profile → controller → lap time. Take the speed profile away once and watch the car crash on a route that did not change. Then sweep `P.safety` and face the trade-off: a route that keeps away from the walls is safe and slow, a route that cuts close is quick and might not survive. Choose a value and defend it in three sentences.

**TASK — [10 The CrazyCar track](10_crazycar_track.md):** The original track. Plan and drive a lap, find why one leg costs more than half the search, and measure how narrow the usable margin window is here compared with the oval. Then the final exercise: `experiments/experiment_cc_tuning.m`, where you tune eight values yourself against three numbers that will not all improve at once — lap time, the smallest gap to a wall, and how much grip the setup can lose before the lap fails. Meet one of the two targets on both tracks and write down what you bought and what you paid.

*Optional:* `tasks/astar_car.m` is the pose search itself — your `astar_graph` with four lines changed. `check_car_plan` tests it.

**No additional written reports are specified by these Markdown chapters.** Be prepared to explain the algorithms and your code orally as required by the instructor.
