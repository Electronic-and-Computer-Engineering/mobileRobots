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

## Next laboratory — Vehicle movement

The vehicle is **not** part of the current five-algorithm laboratory. The existing material remains available separately for the following laboratory: [08 Car in the maze](08_car_in_maze.md), `tasks/car_in_maze.m` and `experiments/experiment_car_maze.m`. This is a simple grid-path animation, **not** a physics-based CrazyCar simulator. The later motion-planning context is in [09 Vehicle outlook](09_crazycar_outlook.md).

**No additional written reports are specified by these Markdown chapters.** Be prepared to explain the algorithms and your code orally as required by the instructor.
