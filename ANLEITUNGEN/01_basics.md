[← Overview](README.md) · **01 Toolbox** · [02 Depth-first search →](02_depth_first.md)

# 01 — Learn the tools before building a search algorithm

**Mobile Robots · FH JOANNEUM · MATLAB**

In this chapter you will **use** the provided functions rather than implement them. Each small experiment has one purpose. You can inspect the source code and look up any MATLAB command. Your goal is to understand what enters a function, what comes back, and why a search algorithm needs it.

**TASK — Setup:** Set MATLAB's *Current Folder* to `MATLAB/` and run:

```matlab
setup_path
check_tools
```

`check_tools` checks the *provided toolbox*, not your future algorithms. If it reports an error, correct the setup or ask for help before continuing.

**TASK — How to work:** Open the named `experiments/experiment_*.m` file in the MATLAB Editor. Use **Run** to execute it. For each experiment: **predict → run → change one thing → explain**. Never edit `tools/` or `demos/` for these exercises.

| First investigate | Then use it in |
|---|---|
| `open_new`, `open_push`, `open_pop`, `open_size`, `open_isempty` | All five algorithms |
| `graph_neighbors`, `reconstruct_path` | Searching a graph and returning a path |
| `sub2ind`, `ind2sub`, `grid_neighbors` | Planning on an occupancy grid |
| `grid_heuristic` | Greedy and A* |
| `maze_obstacles`, `maze_random`, the search loop | Random-map comparison |

## Activity 1A — Create and inspect OPEN

**File:** `experiments/experiment_open_fifo_lifo.m`  
**Optional demonstration:** `demos/demo_container.m`

An algorithm cannot process every known node at once. It stores discovered, not-yet-processed nodes in a container called **OPEN**.

Look at these five operations before using them:

| MATLAB call | What it means | What it returns |
|---|---|---|
| `OPEN = open_new('fifo')` | Create an empty FIFO container | A new `OPEN` value |
| `OPEN = open_push(OPEN,4)` | Insert node `4` | **Updated** `OPEN` |
| `[OPEN,u] = open_pop(OPEN)` | Remove the next node | **Updated** `OPEN`, removed node `u` |
| `open_size(OPEN)` | Count **waiting entries** | A number, such as `3` |
| `open_isempty(OPEN)` | Ask whether OPEN has no entries | Logical `true` (`1`) or `false` (`0`) |

**Important distinction:** `open_size(OPEN)` is a *course function* counting waiting entries. MATLAB's built-in `size(OPEN)` describes the dimensions of the MATLAB struct and is **not** the number of waiting nodes. You should not calculate that number from `OPEN.item`, `OPEN.n` or other internal fields either.

**TASK 1 — Predict:** What are `open_size(OPEN)` and `open_isempty(OPEN)` immediately after `open_new('fifo')`? What will they be after three pushes?

**TASK 2 — Run:** Open `experiment_open_fifo_lifo.m`, keep `mode = 'fifo'`, and execute the whole script. Read the output *after each push and pop*. Each inserted node increases the number of waiting entries by one; each removed node decreases it by one.

**TASK 3 — Compare two different kinds of *size*:** Read the line printing both `size(OPEN)` and `open_size(OPEN)`. Explain why the values differ. At the end of the script, compare MATLAB's `isempty(OPEN)` with the provided `open_isempty(OPEN)`.

**TASK 4 — Change one parameter:** Replace `'fifo'` with `'lifo'`. Do not change `nodes = [4 2 7]`. Predict and then compare the exit order.

<details>
<summary>Show solution — FIFO and LIFO</summary>

The empty container has size **0** and `open_isempty` returns **1** (`true`). After three pushes, the size is **3** and `open_isempty` is **0** (`false`). FIFO removes nodes **4, 2, 7**; LIFO removes **7, 2, 4**. After the final pop, the size is again **0**.

MATLAB sees `OPEN` as a **1×1 struct**, even if it contains no waiting entries: `size(OPEN)` remains `[1 1]`, and MATLAB's `isempty(OPEN)` is false. The provided `open_size(OPEN)` and `open_isempty(OPEN)` inspect the **waiting entries**, which is what the algorithms need.

Neither FIFO nor LIFO examines a distance or a cost. Only the insertion order matters.

</details>

**CHECKPOINT:** Explain the difference between *creating* OPEN, *inserting* a node and *removing* a node. Why must we test `open_isempty` before calling `open_pop`?

## Activity 1B — Understand the return value of `open_push`

**File:** `experiments/experiment_open_return_values.m`

Here you investigate a MATLAB programming rule that is essential for every later algorithm.

```matlab
OPEN = open_push(OPEN, 2);   % keep the modified container
open_push(OPEN, 2);          % returned result is NOT saved
```

**TASK 1 — Predict:** In the first example, nodes `1`, `2`, `3` are inserted correctly. In a second example, node `2` is inserted **without** `OPEN =`. How many nodes will remain in OPEN?

**TASK 2 — Run:** Open and run `experiment_open_return_values.m`. Compare Case A and Case B, especially the value reported by `open_size` and the returned node IDs.

**TASK 3 — Correct:** Restore `OPEN =` for the missing assignment in Case B. Run again. Both cases should now produce the same result.

<details>
<summary>Show explanation — why `OPEN =` matters</summary>

`open_push` returns a **new updated value**. MATLAB does not automatically replace the variable in your workspace when the function is called without an assignment. Case A contains **1, 2, 3**; Case B contains only **1, 3** until you correct the line.

Likewise, after `[OPEN,u] = open_pop(OPEN)`, `u` contains the selected node while `OPEN` holds the remaining entries. Omitting the first output would mean that the caller does not retain the updated container.

</details>

**CHECKPOINT:** In your own words, explain what each side of `[OPEN,u] = open_pop(OPEN)` represents.

## Activity 1C — Select the smallest priority (`minkey`)

**File:** `experiments/experiment_open_priority.m`

FIFO and LIFO use insertion order. Dijkstra, Greedy and A* instead need to select a node according to a **numerical priority**. Our container supports this with the mode **`'minkey'`**.

```matlab
OPEN = open_new('minkey');
OPEN = open_push(OPEN, 5, 10);   % node 5, priority 10
OPEN = open_push(OPEN, 2,  3);   % node 2, priority 3
OPEN = open_push(OPEN, 7,  6);   % node 7, priority 6
[OPEN, u, key] = open_pop(OPEN);
```

The **second** argument of `open_push` identifies a node. The **third** is its numerical priority. `open_pop` can return the selected priority as an optional third output `key`.

**TASK 1 — Predict:** Which node is returned first, and what is its key? Predict the complete removal sequence.

**TASK 2 — Run:** Open `experiment_open_priority.m` and execute it. Compare the printed node IDs **and priorities** with your prediction.

**TASK 3 — Modify:** Change **only** node 5's priority from `10` to `1`. Explain why the result changes even though the insertion order stays the same.

**OPTIONAL TASK — Reverse engineering:** The experiment also inserts node 4 twice, with different priorities. Use `open_size` and the two calls to `open_pop` to determine whether the second insertion replaces the first one.

<details>
<summary>Show solution — priorities and duplicates</summary>

Initially the removal order is node **2** (key 3), then **7** (key 6), then **5** (key 10). After changing node 5's key to 1, **5** is selected first. With `minkey`, the **smallest priority** wins.

In this supplied implementation, a repeated node ID is **not replaced**: the two entries remain in OPEN, and `open_size` counts both. Dijkstra and A* handle outdated entries in their algorithmic logic.

</details>

**CHECKPOINT:** Which mode is used by DFS, BFS, Dijkstra, Greedy and A*? Explain why the numerical key has **no selection role** in the FIFO and LIFO modes.

## Activity 2 — Ask a graph for neighbours and costs

**File:** `experiments/experiment_graph_neighbors.m`  
**Demonstration:** `demos/demo_graph.m`

The graph-search algorithm only needs to know which nodes can be reached from the current node and what a step costs.

![The course graph](figures/00_graph.png)

**TASK 1 — Inspect:** Run `demo_graph` once and locate the direct edge **A–D**, whose cost is **6**.

**TASK 2 — Run:** Open `experiment_graph_neighbors.m`. Inspect `[nb,w] = graph_neighbors(G.W,u)`, run the file with `u = 1` (node A), and read the pairs in the output. `nb(k)` and `w(k)` describe **the same edge**.

**TASK 3 — Change:** Set `u = 5` (node E). Predict its neighbours before executing. Then change the weight A–D from 6 to 2 in the **copy** `W2` and compare the outputs. The original graph remains unchanged.

<details>
<summary>Show solution — neighbours</summary>

From A: neighbours `2, 3, 4` (B, C, D) with weights `1, 1, 6`. From E: neighbours `2, 3, 6` (B, C, F), with weights `1, 2, 1`. Lowering A–D's cost changes the corresponding **weight**, not the neighbour list. The cost matrix is symmetric because this is an undirected graph.

</details>

**CHECKPOINT:** What does `W(u,v) = 0` mean in this course's adjacency matrix? Why are `[nb,w]` two vectors rather than one?

## Activity 3 — Recover a route from predecessor information

**File:** `experiments/experiment_path_reconstruction.m`  
**Demonstration:** `demos/demo_graph.m`

A search records where it came from. The vector `par` stores a node's predecessor: `par(5) = 2` means **E was reached from B**.

**TASK 1 — Predict:** Given `par(2)=1`, `par(5)=2` and `par(6)=5`, follow the predecessors **backwards** from F. Write down the path A→F and calculate its edge cost from the graph.

**TASK 2 — Run:** Open and execute `experiment_path_reconstruction.m`; compare your prediction with `reconstruct_path`.

**TASK 3 — Modify:** Change the chain to A–D–F. Explain why the route can be reconstructed without executing a search algorithm again.

<details>
<summary>Show solution — parent chain</summary>

Following `F ← E ← B ← A` gives **A–B–E–F** and cost **3**. A–D–F costs **7**. The predecessor array stores the history needed to reconstruct a path after the search has finished; it does not need to store a complete candidate route at each node.

</details>

**CHECKPOINT:** When a search discovers an unexplored neighbour `v` from `u`, what should `par(v)` contain?

## Activity 4A — Convert grid coordinates to node IDs

**File:** `experiments/experiment_grid_indexing.m`  
**Demonstration:** `demos/demo_grid.m`

The grid is a MATLAB matrix. Coordinates are given as `(row,column)`, but graph-search functions work with a single node ID. MATLAB assigns matrix indices **column by column**.

**TASK 1 — Predict:** In a matrix with **3 rows and 4 columns**, what is the linear index of cell `(2,3)`?

**TASK 2 — Run:** Execute `experiment_grid_indexing.m`. Read the displayed matrix of linear indices. Compare `sub2ind` (coordinates → ID) with `ind2sub` (ID → coordinates).

**TASK 3 — Modify:** Change only the row coordinate from 2 to 1. Predict the resulting node ID before running again.

<details>
<summary>Show solution — indexing</summary>

For a grid with 3 rows, `(2,3)` has index `2 + (3-1)·3 = 8`. Changing the row to 1 gives index **7**. Every move by one column changes the linear index by the **number of rows**, not by the number of columns.

</details>

## Activity 4B — Check which grid moves are legal

**File:** `experiments/experiment_grid_neighbors.m`  
**Demonstration:** `demos/demo_grid.m`

`grid_neighbors(M,u,conn,allowCornerCut)` filters out map borders and obstacles. It returns **reachable** cell IDs and their edge costs.

**TASK 1 — Run:** Use `conn = 4`. Inspect the output as `[row,column,cost]` and locate the allowed neighbouring cells in the matrix.

**TASK 2 — Modify:** Change `conn` to `8`. Explain which diagonal moves have been added and why they cost `sqrt(2)` rather than `1`.

**TASK 3 — Investigate:** Run the second part of the script with a deliberately blocked corner. Compare `allowCornerCut = false` with `true` and explain the difference.

<details>
<summary>Show solution — movement</summary>

For the initial map and current cell `(2,3)`, the legal 4-neighbours are `(1,3)`, `(3,3)` and `(2,4)` with cost 1; `(2,2)` is blocked. Legal diagonals in the example add `(1,4)` and `(3,4)` with cost `sqrt(2)`. In the corner example, the cell `(1,1)` is free, but moving diagonally to it from `(2,2)` passes between blocked orthogonal cells. The default `false` correctly rejects this step.

</details>

**CHECKPOINT:** Why is a plotted line between two free cells not necessarily a legal physical movement?

## Activity 5 — Understand the heuristic

**File:** `experiments/experiment_heuristics.m`  
**Demonstration:** `demos/demo_heuristic.m`

A heuristic estimates the remaining distance **without searching around obstacles**. The expression `hfun = grid_heuristic(...)` creates a **function handle**; `hfun(u)` evaluates that function at one cell.

**TASK 1 — Predict:** Cell `u=(2,2)`, goal `t=(4,5)`. What is the Manhattan distance if only horizontal and vertical moves are allowed?

**TASK 2 — Run:** Execute `experiment_heuristics.m` and inspect `hfun(u)` and `hfun(t)`.

**TASK 3 — Modify:** Change only the name to `'octile'`, `'euclid'` and `'zero'`, one at a time. Then change only the goal and predict the effect.

<details>
<summary>Show solution — estimates</summary>

The row difference is 2, the column difference is 3. Manhattan is **5**, Octile is **1 + 2·sqrt(2) ≈ 3.828**, Euclidean is **sqrt(13) ≈ 3.606**, and `'zero'` returns **0**. Each gives **0 at the goal**. None of these built-in geometric heuristics inspects walls or obstacles. For 4-neighbour unit-cost movement use Manhattan; for 8-neighbour movement with diagonal cost `sqrt(2)`, Octile is a suitable estimate.

</details>

**CHECKPOINT:** Why is `g(v)` (cost already travelled) different from `h(v)` (estimated cost still ahead)?

## Activity 6 — Build reproducible random maps

**File:** `experiments/experiment_random_maps.m`  
**Demonstration:** `demos/demo_maps.m`

A random seed makes experiments reproducible. It lets all five algorithms solve **the same** map, so differences come from the algorithms rather than the test environment.

**TASK 1 — Run:** Execute `experiment_random_maps.m`. Explain the results of `isequal(M1,M2)` when both maps use the same seed.

**TASK 2 — Modify:** Change only the seed for the third map. Inspect whether the map changes.

**OPTIONAL TASK:** Change obstacle density, or compare the field to a perfect maze created by `maze_random`.

<details>
<summary>Show solution — seeds</summary>

The same seed and parameters reproduce the same map (`isequal` returns true). A different seed normally generates a different map. A perfect maze has a unique simple route between connected cells; an obstacle field may provide multiple routes.

</details>

## Activity 7 — Recognise the loop used by every planner

**File:** `experiments/experiment_search_pattern.m`  
**Demonstration:** `demos/demo_pattern.m`

The loop repeatedly (1) removes a node from OPEN, (2) queries neighbours, and (3) inserts newly discovered nodes. This first example explores **reachability**, not yet the route to a goal.

**TASK 1 — Observe:** Run `demo_pattern` once, then open `experiment_search_pattern.m`.

**TASK 2 — Find:** Identify the exact line that selects the next node, the line that obtains its neighbours, and the line that prevents a node being inserted repeatedly.

**TASK 3 — Run:** Execute `experiment_search_pattern.m` and inspect the number of reachable free cells.

**OPTIONAL TASK:** Change the mode from `'fifo'` to `'lifo'`. Does the *order* change? Does the set of *reachable* cells change?

<details>
<summary>Show explanation — the bridge to DFS and BFS</summary>

`open_pop` chooses the current node, `grid_neighbors` returns valid neighbours, and `seen` prevents repeatedly inserting already discovered nodes. On this finite example, both FIFO and LIFO reach the same free cells, possibly in a different order. To return a route to a particular goal, a search additionally needs a **goal check**, **predecessor assignments** (`par(v)=u`) and **path reconstruction**. Later, weighted searches also need cost updates (relaxation).

</details>

## Before you continue

**TASK — Self-check:** You should be able to explain these calls without reading the answer:

```matlab
OPEN = open_new('fifo');
OPEN = open_push(OPEN,3);
n = open_size(OPEN);
empty = open_isempty(OPEN);
[OPEN,u] = open_pop(OPEN);
```

What does each line return or change? Why does a Dijkstra queue use `'minkey'` instead? Why does a grid search require `grid_neighbors`?

**No separate written hand-in is required for these experiments.** Their purpose is to prepare you to implement and explain the algorithms. The instructor determines the assessment requirements.

**Next:** [02 — Depth-first search →](02_depth_first.md)
