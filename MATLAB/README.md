# MATLAB workspace

**TASK — MATLAB setup:** Set MATLAB Current Folder to this `MATLAB/` directory, run `setup_path` and `check_tools`, then edit only the files in `tasks/` as directed by the Markdown chapters.

Open **this `MATLAB/` folder as your MATLAB Current Folder**. The documents are one level above, in `ANLEITUNGEN/`.

```matlab
setup_path
check_tools
which dfs_graph
```

The last command must resolve to `tasks/dfs_graph.m`. The student functions are intentionally incomplete until you implement them.

## Directory map

| Folder | Purpose |
|---|---|
| `tasks/` | **Your work**: DFS, BFS, Dijkstra, Greedy, A*, car-in-maze |
| `tools/` | Provided neighbour functions, containers, heuristics, map generators, drawing, grid adapter and animation |
| `demos/` | Small runnable examples showing provided tools |
| `experiments/` | Editable parameter experiments and random-map comparison |
| `checks/` | `check_my_code`, `check_student_grid`, `check_car_maze` |
| `toolchecks/` | Unit checks for the supplied base toolbox |
| `solutions/` | Instructor-only reference implementations (if included in your version) |

## Recommended calls (in this order)

```matlab
setup_path
check_tools
run('experiments/01_toolbox_experiments.m')
check_my_code('dfs')        % after completing tasks/dfs_graph.m
check_my_code('bfs')        % after completing tasks/bfs_graph.m
check_my_code('dijkstra')
check_my_code('greedy')
check_my_code('astar')
check_student_grid          % after all five algorithms are ready
run('experiments/07_random_comparison.m')
check_car_maze              % after completing tasks/car_in_maze.m
run('experiments/08_car_experiment.m')
```

`search_grid` is a separately implemented **reference** solver. Use `search_student_grid` to execute **your own** algorithms on occupancy grids.

The car animation does not model steering, speed, tire forces or vehicle footprint. It merely displays a car-shaped object following a computed grid route.
