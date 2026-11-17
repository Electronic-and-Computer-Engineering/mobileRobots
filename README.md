# Mobile Robots — MATLAB lab instructions

**FH JOANNEUM**

**TASK — Start here:** Open [CORE_ROUTE.md](ANLEITUNGEN/CORE_ROUTE.md) and follow the individually labelled **TASK** instructions. Every MATLAB experiment has its own descriptive `.m` file under `../MATLAB/experiments/`. Do not change the provided `tools/` functions.

| Chapter | What you learn or build | MATLAB starting point |
|---|---|---|
| [01 Toolbox](ANLEITUNGEN/01_basics.md) | OPEN, graph, grids, estimates and maps | `experiments/experiment_open_fifo_lifo.m` |
| [02 DFS](ANLEITUNGEN/02_depth_first.md) | LIFO-based graph search | `tasks/dfs_graph.m` |
| [03 BFS](ANLEITUNGEN/03_breadth_first.md) | FIFO-based graph search | `tasks/bfs_graph.m` |
| [04 Dijkstra](ANLEITUNGEN/04_dijkstra.md) | Costs and relaxation | `tasks/dijkstra_graph.m` |
| [05 Greedy](ANLEITUNGEN/05_greedy.md) | Priority from heuristic | `tasks/greedy_graph.m` |
| [06 A*](ANLEITUNGEN/06_astar.md) | Priority from `g+h` | `tasks/astar_graph.m` |
| [07 Comparison](ANLEITUNGEN/07_comparison.md) | Your algorithms on random maps | `experiments/experiment_random_comparison.m` |
| [08 The vehicle in the search](ANLEITUNGEN/08_vehicle_neighbors.md) | The vehicle model, and building its motion space into your neighbour function | `tasks/car_primitives.m`, `tasks/car_neighbors.m` |
| [09 Practice circuit](ANLEITUNGEN/09_practice_circuit.md) | A lap on the test oval, then the trade-off between not crashing and a better path | `experiments/experiment_oval_lap.m` |
| [10 The CrazyCar track](ANLEITUNGEN/10_crazycar_track.md) | The original track, and tuning it yourself against three numbers | `experiments/experiment_cc_tuning.m` |

**Assessment:** The instructor sets the learning objectives. The Markdown predictions, optional investigations and collapsed answers help prepare for explaining your implementation **orally**; they are not additional assignments to submit.
