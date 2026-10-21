# MATLAB files — quick start

**TASK:** In MATLAB set the Current Folder to **this `MATLAB/` folder**. Run:

```matlab
setup_path
check_tools
```

**TASK — First investigate OPEN:** Open `experiments/experiment_open_fifo_lifo.m`. Run the script, change `'fifo'` to `'lifo'`, and then continue to `experiment_open_return_values.m` and `experiment_open_priority.m`. All scripts are self-contained; there is no dependency on a previous MATLAB workspace.

**TASK — Continue with basics:** Open [01_basics.md](../ANLEITUNGEN/01_basics.md) and run the individual experiment scripts in the sequence given there. The `demos/` files provide additional working examples. Leave `tools/` unchanged.

**TASK — Develop five planners:** Complete the incomplete `tasks/*_graph.m` functions and test each with:

```matlab
check_my_code('dfs')
check_my_code('bfs')
check_my_code('dijkstra')
check_my_code('greedy')
check_my_code('astar')
check_student_grid
run('experiments/experiment_random_comparison.m')
```

`check_tools` checks the provided functions; `check_my_code` tests each student implementation; `check_student_grid` checks the integration that calls **your** algorithms on occupancy grids. `search_grid` is an independent reference solver.

**Following laboratory only:** `tasks/car_in_maze.m`, `check_car_maze`, and `experiments/experiment_car_maze.m`. The basic car symbol follows a calculated grid route; it is not a physical steering model.

**Folder roles:** `tasks/` = edit; `experiments/` = inspect and change parameters; `demos/` = run and inspect; `tools/` = provided and unchanged; `checks/` = self-tests; `solutions/` = instructor reference only (not included with student package).
