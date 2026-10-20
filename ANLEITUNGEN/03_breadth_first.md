[← 02 DFS](02_depth_first.md) · **03 Breadth-first search** · [04 Dijkstra →](04_dijkstra.md)

# 03 — Derive breadth-first search (BFS)

**Block 1 · 25 min CORE / 35 min full version · Edit `tasks/bfs_graph.m`**


> **Compact CORE route (~25 min):** Core: Steps 1–3. Optional: Step 4 (additional grid test). See [CORE_ROUTE.md](CORE_ROUTE.md). The original detailed time estimates and exercises below are the **full** version, not required to fit the compact core time.

## Goal

Create BFS from your completed DFS. The central experiment is to change **how OPEN chooses the next node**, without changing the rest of the search.

BFS returns a path with the fewest **edges** in an unweighted graph. That is not necessarily the minimum-cost path in a weighted graph.

### File tour and experiment

**Open:** `tasks/dfs_graph.m` (your working DFS) **beside** `tasks/bfs_graph.m` (the new file). Before changing anything, find the line that constructs OPEN. All other components — neighbour queries, `seen`, `par`, goal test — already serve the same purpose.

**Why not write BFS from scratch?** The exercise isolates one design choice: the data structure controls the search order. To verify that claim, first predict the traces on paper, then compare both algorithms on **the same map and start/goal**. A different map would not be a fair test of the one-line change.


## Step 1 — Predict before coding (8 min)

On the same graph, consider A's neighbours B, C and D.

1. With LIFO, which node is examined next?
2. With FIFO, which node is examined next?
3. In what order will BFS visit nodes at distance one edge and distance two edges from A?

Draw the first two BFS layers in your notes. Do not inspect the expected numerical result yet.

<details>
<summary>Show solution (after your own attempt)</summary>

With LIFO, A's most recently inserted neighbour **D** is removed next. With FIFO, **B** is removed next.

BFS layers from A on the course graph:

- **Layer 0:** A
- **Layer 1 (one edge):** B, C, D
- **Layer 2 (two edges):** E, F

With ascending neighbour order, the expansion order is **A, B, C, D, E, F**. BFS is optimal in the number of edges, regardless of their individual weights.

</details>


## Step 2 — Derive the algorithm (12 min)

Open `tasks/bfs_graph.m` and copy your completed `dfs_graph.m` into it, adjusting the function name to `bfs_graph`.

Change the **one** container mode that makes the search breadth-first. Do not add relaxation or use edge weights to prioritize nodes.

```matlab
G = graph_example();
[pB, cB, stB] = bfs_graph(G.W, G.s, G.t);
[pD, cD, stD] = dfs_graph(G.W, G.s, G.t);

fprintf('DFS: cost %g, expanded %d\n', cD, stD.expansions);
fprintf('BFS: cost %g, expanded %d\n', cB, stB.expansions);
```

Compare `stD.order` and `stB.order` with your prediction. Then run:

```matlab
check_my_code('bfs')
```

**Test interpretation:** On the tiny course graph DFS and BFS can coincidentally return the **same** path. The checker verifies BFS behaviour beyond this one coincidence; the expansion trace and the **hop-count guarantee** explain what is different. If the test fails, compare the two source files and ensure the function name matches `bfs_graph.m`.


**Reference outcome for the course graph:** Both can return A–D–F with cost 7, but DFS expands three nodes and BFS six. The important result is the **guarantee**, not a lucky match on one graph.

## Step 3 — Find the counterexample (8 min)

Calculate the costs of these two routes using the edges of `G.W`:

- A–D–F
- A–B–E–F

Complete the statement:

> BFS chooses the path with the fewest ______. It minimizes the sum of edge costs only when ______.

**Question:** Why would it be incorrect to report BFS as an optimal planner for arbitrary travel times or energy costs?

<details>
<summary>Show solution (after your own attempt)</summary>

- **A–D–F:** `6+1 = 7`, using **2 edges**.
- **A–B–E–F:** `1+1+1 = 3`, using **3 edges**.

Complete the statement: BFS chooses the path with the fewest **edges (steps)**. It minimizes total path cost only when **every edge has the same cost**.

If edge weights represent travel time or energy, fewer edges may be much more expensive, so BFS is not generally cost-optimal.

</details>


## Step 4 — Use a small grid (7 min)

Now let your **own** implementation plan on a grid via the provided adapter:

**Why this new file matters:** Your `bfs_graph.m` expects a weighted adjacency matrix, but a labyrinth is represented by the binary occupancy matrix `M`. The adapter `tools/search_student_grid.m` converts the representation and **calls your `bfs_graph.m`**. It does not replace the student algorithm. Confirm this with `which bfs_graph` before drawing a conclusion from the plot.

**Small parameter experiment:** Keep the map seed fixed and compare `Conn=4` and `Conn=8`. Observe the number of steps, the computed cost and the shape of the path. Predict why the algorithm still minimizes **edge count**, even when diagonals have a different length.


```matlab
[M, s, t] = maze_obstacles(12, 16, 0.20, 7);
[p, c, st] = search_student_grid(M, s, t, 'bfs', 'Conn', 4);
figure
plot_grid(M, 'Expanded', st.order, 'Path', p, ...
          'Start', s, 'Goal', t, 'Title', 'My BFS');
```

The adapter converts the grid to a sparse graph and calls **your `bfs_graph`**. It does not implement BFS for you. You will examine this conversion in Chapter 07.

Describe the expanded area: does BFS focus only toward the goal or explore all directions?

<details>
<summary>Show solution (after your own attempt)</summary>

BFS expands outward from the start in increasing **number of steps**, not according to the direction of the goal. The explored area therefore resembles a growing wave and can include many cells that are farther away from the goal. Exact counts depend on the generated grid, but the principle does not.

</details>


## Checkpoint

- [ ] `check_my_code('bfs')` passes.
- [ ] I can identify the one difference between DFS and BFS in my source code.
- [ ] I can distinguish fewest steps from minimum accumulated cost.
- [ ] My own BFS produced a valid path on a grid.

**End of Block 1:** Save `dfs_graph.m`, `bfs_graph.m` and your short written explanations.

**Next:** [04 — Dijkstra and relaxation →](04_dijkstra.md)
