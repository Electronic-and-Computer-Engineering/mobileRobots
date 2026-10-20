[← 06 A*](06_astar.md) · **07 Comparison** · [08 Car in the maze →](08_car_in_maze.md)

# 07 — Compare your algorithms on random maps

**Block 3 · 110 min CORE / 180 min full version · Experiments and analysis**


> **Compact CORE route (~110 min):** Core: initial checks, short integration check, Experiments 2, 3 (use the **prepared** `experiments/07_random_comparison.m` with `seeds = 1:4`) and 5. Optional: Experiment 4 and the extended 8-seed analysis. See [CORE_ROUTE.md](CORE_ROUTE.md). The original detailed time estimates and exercises below are the **full** version, not required to fit the compact core time.

## Objective

Five algorithms may all find a route, but they optimize different objectives and perform different amounts of work. In this session you will test your **own code**, not a separate reference implementation, on maps that were not used for development.

Your conclusions must be supported by *repeatable measurements*, not by choosing one favorable screenshot.

### File tour — what is running, and how can you prove it?

Start with **`tasks/astar_graph.m`** (your algorithm), then inspect **`tools/grid_to_graph.m`** (representation conversion) and **`tools/search_student_grid.m`** (adapter). The adapter prepares a sparse graph from `M`, builds an appropriate heuristic when required, and calls your student function.

`checks/check_student_grid.m` validates **integration**, not the theoretical quality of every planner. `checks/check_my_code.m` tests individual algorithm behaviour; `check_tools` validates the unchanged toolbox. Open the check files to see what is **actually checked** before interpreting a passing result.

For one experiment, make a deliberate, reversible change to your own algorithm (as instructed below) and verify the adapter reacts. Afterwards **remove the change** and rerun the test. This is a form of black-box dependency testing: it answers, *which implementation does this call actually execute?*


## What must be ready?

Run:

```matlab
setup_path
check_my_code
check_student_grid
which dfs_graph
which search_student_grid
```

All five search implementations should pass. `dfs_graph` must point to your `tasks/` folder. The new `search_student_grid` must point to `tools/`.

### A fair measurement needs a definition

**Test strategy for this block:**

1. **Correctness first:** Do the output nodes form a legal path? Is its reported cost equal to the sum of the edges? Is the goal reached?
2. **Fair comparison second:** Hold the generated map, endpoints, movement model and seed fixed when switching algorithms.
3. **Performance third:** Compare path cost, number of expanded nodes and search time as **different quantities**. Use several seeds and report preparation time separately.
4. **Conclusions last:** An individual winner on one random map is an observation, not an algorithmic guarantee.


- **Cost:** sum of actual edge weights on the returned path.
- **Steps:** `numel(path)-1` for a nonempty path; this is **not** the same as cost on a weighted graph.
- **Expansions:** number of nodes actually taken out of OPEN and processed (`stats.expansions`).
- **Search time:** `stats.searchTime` from the adapter, in seconds. It excludes construction of the graph and heuristic. Do not compare wall-clock time measured around plotting commands.
- **Preparation time:** `stats.preparationTime`, reported separately, includes building the sparse cost matrix and heuristic vector.

The expansion count is a useful machine-independent measure of search work, but fewer expansions do **not** automatically imply lower computation time. Priority-queue operations also cost time.

## Experiment 1 — Prove it runs your code (25 min)

In Chapters 02–06 you wrote functions such as `astar_graph(W,s,t,h)`. A grid is represented differently, by a binary matrix `M`. To reuse your code, the helper `grid_to_graph` creates a **sparse weighted adjacency matrix**:

```matlab
M = [0 0 0 0;
     0 1 0 0;
     0 0 0 0];
W4 = grid_to_graph(M, 4, false);
W8 = grid_to_graph(M, 8, false);

nnz(W4)
nnz(W8)
```

**Before running:** Predict whether `nnz(W8)` is at least as large as `nnz(W4)`. Explain what the nonzero entries mean. Why are there far fewer nonzero entries than `numel(M)^2`?

<details>
<summary>Show solution (after your own attempt)</summary>

`nnz(W8) ≥ nnz(W4)`: every legal four-neighbour edge is also a legal eight-neighbour edge. A nonzero element `W(u,v)` stores the **cost of an allowed directed traversal** from `u` to `v`; the undirected grid graph is represented symmetrically. Each free cell has at most eight neighbouring cells rather than edges to every grid cell, making `W` **sparse**.

The actual nonzero counts follow from the small test grid and can be verified by running the two commands.

</details>


For a free cell, test that the graph and grid agree:

```matlab
u = sub2ind(size(M), 2, 3);
[ng, wg] = graph_neighbors(W4, u);
[nm, wm] = grid_neighbors(M, u, 4);

sort(ng)
sort(nm)
```

The order of neighbours may differ because the sparse-graph interface returns sorted node indices. The *sets* and matched costs must agree.

Now run:

```matlab
[M, s, t] = maze_obstacles(20, 30, 0.20, 7);
[p, c, st] = search_student_grid(M, s, t, 'astar');
figure
plot_grid(M, 'Path', p, 'Expanded', st.order, ...
          'Start', s, 'Goal', t, 'Title', 'My A* on an obstacle field');
```

**Verification:** Temporarily insert an `error('student:test', ...)` at the beginning of **your** `astar_graph.m`. Confirm that `search_student_grid(...,'astar')` now reports that error, then remove it. This establishes that your version is actually executed.

> Note: This conversion is a **teaching adapter**. On very large grids, an implicit neighbour function that does not build an explicit graph is usually preferable. The implementation deliberately preserves the existing student task interfaces, not maximum scalability.

## Experiment 2 — One map, five searches (40 min)

Use **one identical map, start and goal** for all methods. First predict which methods should be cost-optimal in a 4-neighbour grid where every move costs 1.

<details>
<summary>Show solution (after your own attempt)</summary>

With 4-neighbour moves costing 1, **BFS, Dijkstra and A\*** are guaranteed to return a minimum-cost path for the supplied graph model and consistent Manhattan heuristic. **DFS and Greedy** might return one but have no such guarantee.

The graph can contain several distinct routes with the same minimum cost, so equally optimal algorithms need not return the **identical node sequence**.

</details>


```matlab
[M, s, t] = maze_obstacles(30, 40, 0.25, 7);
methods = {'dfs', 'bfs', 'greedy', 'dijkstra', 'astar'};

figure('Position', [100 100 1500 430]);
for k = 1:numel(methods)
    method = methods{k};
    [p, c, st] = search_student_grid(M, s, t, method, 'Conn', 4);

    subplot(1, numel(methods), k)
    plot_grid(M, 'Expanded', st.order, 'Path', p, ...
        'Start', s, 'Goal', t, ...
        'Title', sprintf('%s: cost %.0f, %d expanded', ...
                         method, c, st.expansions));
    fprintf('%-9s cost %8.3f, expansions %5d, search %8.3f ms\n', ...
        method, c, st.expansions, 1000*st.searchTime);
end
```

Fill the table using your actual outputs:

| Search | Path cost | Steps | Expansions | Search time (ms) |
|---|---:|---:|---:|---:|
| DFS | | | | |
| BFS | | | | |
| Greedy | | | | |
| Dijkstra | | | | |
| A* | | | | |

**Explain:**

1. Which searches found a minimum-cost path on this map, and which ones were guaranteed to do so for this map type?
2. Compare Dijkstra with A*: were their costs equal? Did they expand the same nodes?
3. Which search used the fewest expansions? Does that prove it is the best overall method?
4. How can different methods return an equal-cost but not necessarily identical path?

<details>
<summary>Show solution (after your own attempt)</summary>

**Expected reasoning (not fixed numeric results):**

1. For unit-cost four-neighbour grids, BFS, Dijkstra and correctly implemented A* are guaranteed to be cost-optimal; DFS and Greedy may be optimal on an individual map only by coincidence.
2. Dijkstra and A* should produce **equal optimal costs** under the stated conditions. Their expansion patterns generally differ, because A* uses goal information.
3. A small expansion count alone does **not** prove superiority: one must also consider route cost, program runtime and memory.
4. Two or more geometrically different paths can have the same sum of edge costs; neighbour order and tie-breaking can determine which one is returned.

Record exact values from **your own** run.

</details>


## Experiment 3 — A single seed is not evidence (55 min)

**Before executing the long loop:** Inspect the variables `densities`, `seeds` and `methods`. Predict how many planner runs the nested loops make, including the additional Dijkstra reference call per map. Change `seeds` temporarily to `1:2` to validate the output-table structure, then restore `1:8` for the actual experiment.

<details>
<summary>Show solution (after your own attempt)</summary>

Two densities and eight seeds produce **16 maps**. Five methods are measured per map, so the result table has **80 algorithm runs (80 rows)**. Additionally, the script obtains one separate Dijkstra reference cost per map, bringing the total to **96 planner calls**. With `seeds = 1:2`, it would produce 4 maps, 20 rows and 24 planner calls.

</details>


Run multiple independent, reproducible obstacle fields. Use **two obstacle densities** and **eight seeds** per density. The generator ensures a 4-connected route from start to goal; it may reject and retry unsuitable random maps internally.

```matlab
densities = [0.15, 0.25];
seeds = 1:8;
methods = {'dijkstra', 'dfs', 'bfs', 'greedy', 'astar'};

rows = {};
for density = densities
    for seed = seeds
        [M, s, t] = maze_obstacles(30, 40, density, seed);

        % Dijkstra provides a reference optimal cost on this graph.
        [~, cref] = search_student_grid(M, s, t, 'dijkstra');

        for k = 1:numel(methods)
            [p, c, st] = search_student_grid(M, s, t, methods{k});
            rows(end+1,:) = {density, seed, methods{k}, ...
                             c, numel(p)-1, st.expansions, ...
                             1000*st.searchTime, c/cref}; %#ok<AGROW>
        end
    end
end

results = cell2table(rows, 'VariableNames', ...
    {'Density','Seed','Method','Cost','Steps','Expansions', ...
     'TimeMs','CostRatio'});
results(1:min(10,height(results)),:)
```

`CostRatio = cost / cref` compares route quality to Dijkstra on **the same map**. A ratio of 1 indicates an optimal cost; greater than 1 means that the method selected a more expensive route. For these generated maps `cref` is positive and finite.

Complete this summary for each density:

| Density | Method | Mean cost ratio | Mean expansions | Median search time (ms) |
|---|---|---:|---:|---:|
| 0.15 | DFS | | | |
| 0.15 | BFS | | | |
| 0.15 | Dijkstra | | | |
| 0.15 | Greedy | | | |
| 0.15 | A* | | | |
| 0.25 | DFS | | | |
| 0.25 | BFS | | | |
| 0.25 | Dijkstra | | | |
| 0.25 | Greedy | | | |
| 0.25 | A* | | | |

Here is one way to calculate the summary without extra toolboxes:

```matlab
for density = densities
    for k = 1:numel(methods)
        idx = results.Density == density & ...
              strcmp(results.Method, methods{k});
        fprintf('%.2f %-9s ratio %.3f, expansions %.1f, median %.3f ms\n', ...
            density, methods{k}, mean(results.CostRatio(idx)), ...
            mean(results.Expansions(idx)), median(results.TimeMs(idx)));
    end
end
```

**Analysis questions:**

- Do conclusions from one obstacle field survive across all 16 fields?
- Does A* always expand fewer nodes than Dijkstra in your measurements? If not, inspect tied priorities and particular map structures before drawing a general conclusion.
- What does increased obstacle density do to the effectiveness of a distance-based heuristic?
- What additional repetitions would be needed before claiming a reliable runtime advantage rather than a single timing coincidence?

<details>
<summary>Show solution (after your own attempt)</summary>

**Interpretation guide:**

- A single favourable example is not enough to establish an algorithm's typical behaviour. Compare results by method **and** obstacle density.
- A* with a suitable heuristic often expands fewer nodes than Dijkstra, but there is no universal strict improvement in every finite test case. With `h=0` they use the same selection key.
- More obstacles can force detours that geometric heuristics cannot foresee; the measured impact is **data-dependent**, not necessarily monotonic.
- Runtime comparisons should use additional seeds and repeated timings under controlled conditions, ideally reporting distributions rather than one timing per map.

Do **not** invent averages or timings in the completed table; they must come from the experiment.

</details>


Do not present these 16 maps as a formal statistical performance study. They are a **controlled laboratory experiment** that supports a reasoned comparison.

## Experiment 4 — Change the question, not just the map (35 min)

### A. Perfect maze: one route

```matlab
M2 = maze_random(10, 15, 42);
s2 = sub2ind(size(M2), 2, 2);
t2 = sub2ind(size(M2), 20, 30);
for k = 1:numel(methods)
    [p, c, st] = search_student_grid(M2, s2, t2, methods{k}, 'Conn', 4);
    fprintf('%-9s cost %6.1f, expanded %4d\n', ...
        methods{k}, c, st.expansions);
end
```

**Why are all valid path costs equal on this map?** Which performance quantities can still differ?

<details>
<summary>Show solution (after your own attempt)</summary>

A perfect maze is a **tree of passages**, so there is only one simple route between start and goal. In a four-neighbour unit-cost representation, every algorithm finding a valid route therefore obtains **the same cost**. The algorithms may still differ in **node expansions, OPEN size, execution time** and exploration order.

</details>


### B. Eight neighbours: different edge weights

Return to the obstacle field. Use `Conn = 8` with corner cutting disabled. Compare BFS and Dijkstra:

```matlab
[pB, cB] = search_student_grid(M, s, t, 'bfs', 'Conn', 8);
[pD, cD] = search_student_grid(M, s, t, 'dijkstra', 'Conn', 8);
fprintf('BFS:      %d steps, cost %.3f\n', numel(pB)-1, cB);
fprintf('Dijkstra: %d steps, cost %.3f\n', numel(pD)-1, cD);
```

**Is a path with fewer edges necessarily cheaper?** Why did changing only the neighbourhood model change the answer to that question?

<details>
<summary>Show solution (after your own attempt)</summary>

**No.** In an eight-neighbour grid, orthogonal moves cost `1` while diagonal moves cost `sqrt(2)`. A route with fewer edges can therefore have a **higher total weight**. Changing the neighbourhood model adds diagonal connections and weights without moving any obstacles. BFS still minimizes hops; Dijkstra minimizes their weighted sum.

</details>


### C. Deliberately invalid A* heuristic

Compare two heuristics on an 8-neighbour grid:

```matlab
[~, cO, stO] = search_student_grid(M, s, t, 'astar', ...
    'Conn', 8, 'Heuristic', 'octile');
[~, cM, stM] = search_student_grid(M, s, t, 'astar', ...
    'Conn', 8, 'Heuristic', 'manhattan');

fprintf('Octile:    cost %.3f, expansions %d\n', cO, stO.expansions);
fprintf('Manhattan: cost %.3f, expansions %d\n', cM, stM.expansions);
```

For diagonal movement at cost `sqrt(2)`, Manhattan can overestimate the remaining cost. It therefore does not give this A* implementation the normal optimality guarantee. **Do not assume this particular map must show a worse path**. Explain why a method can violate a correctness condition yet happen to return the optimum on a given instance.

<details>
<summary>Show solution (after your own attempt)</summary>

For a target one diagonal step away, the true remaining cost is `sqrt(2)≈1.414`, but Manhattan predicts **2**, which is an overestimate. That makes the admissibility condition fail. A failed sufficient condition removes the *guarantee*; it does not imply an incorrect answer on every map. Some search orders still happen to find the optimum. Compare the costs against Dijkstra before asserting an error.

</details>


## Experiment 5 — Engineering conclusion (15 min)

Select an algorithm for each scenario and justify the decision in two or three sentences:

1. A robot moves on an unweighted four-neighbour grid; distance in steps is the only criterion.
2. A robot moves on a weighted map with nonnegative travel costs; no reliable heuristic is available.
3. A robot must find a good route rapidly on a large map with a consistent, informative heuristic.
4. A robot needs a route quickly, and the quality of that route can be sacrificed if necessary.

**Final question:** Does a minimum-distance grid path guarantee a minimum-time route for a vehicle with a turning radius and limited acceleration? Why not?

<details>
<summary>Show solution (after your own attempt)</summary>

No. Grid search optimizes the sum of specified **edge costs**, here geometric distance, while a car must respect steering curvature and speed limits and may need to brake for tight corners. A slightly longer but smoother route can be faster. Minimum-time planning requires an objective involving **time** and a feasible vehicle motion model, not distance alone.

</details>


## Wrap-up: What should you be able to explain?

Compare your own implementations on the same map and be ready to explain the different selection rules, path costs and expansion counts. Plots and tables are tools for reasoning, **not additional required submissions** in this package. Your instructor determines the formal assessment.

The subsequent vehicle task connects your own planner to an animated car in a labyrinth.

---

[Next: 08 — Car in the maze →](08_car_in_maze.md)
