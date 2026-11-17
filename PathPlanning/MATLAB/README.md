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

**Vehicle laboratory (chapters 08 to 10):** the CrazyCar itself, ported from `Electronic-and-Computer-Engineering/CrazyCarSim` and corrected — see [VEHICLE_MODEL_REVIEW.md](../ANLEITUNGEN/VEHICLE_MODEL_REVIEW.md). **No toolbox is required**; the original needs five.

```matlab
demo_cc_track          % the track, its three maps, metres to cells
demo_cc_vehicle        % top speed, dead band, turning circle, grip
demo_cc_primitives     % the five moves, measured by driving the simulator
demo_my_motion_space   % the same five, from YOUR code, drawn
```

**You write two files, and both are about the motion space.** The simulator, the controller, the search and the collision test are all given.

```matlab
%   tasks/car_primitives.m   the five moves, computed from the bicycle model
check_car_primitives       % compares your formula with the simulator

%   tasks/car_neighbors.m    those moves placed at the car's pose, tested
check_car_neighbors         % as a rectangle against the real walls

run('experiments/experiment_oval_lap.m')       % chapter 09: practice track
run('experiments/experiment_cc_lap.m')         % chapter 10: the real one
run('experiments/experiment_cc_tuning.m')      % chapter 10: tune it yourself
```

Optional, if you want the whole chain: `tasks/astar_car.m` is your `astar_graph` over poses, checked by `check_car_plan` and used via `cc_lap_plan(CM, 'Planner', @astar_car)`.

| file | what it is |
|---|---|
| `tools/cc_params.m` | every vehicle, track and search constant, in one place |
| `tools/cc_track.m` | a track picture → three occupancy maps (plan, safety, collision) |
| `tools/cc_step.m` | one 1/25 s step of the car: servo, motor, bicycle model, grip |
| `tasks/car_primitives.m` | **YOUR EXERCISE: the motion space, driven out of the simulator** |
| `tools/cc_primitives_probe.m` | the same five moves, measured by driving the simulator -- the referee for yours |
| `tools/cc_car_model.m` | collects the primitives and the pose space |
| `tasks/car_neighbors.m` | **YOUR EXERCISE: those moves as a neighbour function** — this is what replaces `graph_neighbors` |
| `tools/cc_pose_free.m` | does the car's whole rectangle fit at this pose? |
| `tools/cc_search_car.m` | A* over poses — your `astar_graph`, given back to you |
| `tools/cc_make_oval.m` | draws the practice track, and shows how to draw your own |
| `tools/cc_pose_index.m` | a pose gets a node number so `closed` can work |
| `tools/cc_lap_plan.m` | a lap as a chain of searches through checkpoints |
| `tools/cc_speed_profile.m` | curvature → grip limit → braking, backwards along the route |
| `tools/cc_pure_pursuit.m` | route → throttle and steering, in percent |
| `tools/cc_simulate.m` | the closed loop, 25 Hz, with collision and lap timing |
| `tools/cc_clearance.m` | how close the body came to a wall — the honest safety number |
| `tools/cc_tuning_defaults.m` | the eight values you may tune, and what each one costs |
| `tools/cc_scorecard.m` | one setting → lap time, clearance and grip reserve |
| `tools/cc_plot_track.m`, `cc_animate_lap.m` | drawing and replay |

Two tracks: `cc_params('Track','oval')` is the practice loop (`map/track_oval.png`, made by `cc_make_oval`), `cc_params()` is the real one. `map/track.png` is a copy from CrazyCarSim (GPLv3, attribution required).

**Folder roles:** `tasks/` = edit; `experiments/` = inspect and change parameters; `demos/` = run and inspect; `tools/` = provided and unchanged; `checks/` = self-tests; `solutions/` = instructor reference only (not included with student package).
