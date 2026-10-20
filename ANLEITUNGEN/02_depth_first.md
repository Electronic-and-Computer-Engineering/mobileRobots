[← 01 Toolbox](01_basics.md) · **02 Depth-first search** · [03 BFS →](03_breadth_first.md)

# 02 — Build depth-first search (DFS)

**Block 1 · Guided MATLAB exercise**


> **Required activities:** Follow the steps marked **TASK** in order. Additional experiments are available for deeper investigation; they are not separate submissions. See [CORE_ROUTE.md](CORE_ROUTE.md).

## Goal

Implement a search that continues with the **most recently discovered node**. Use the `lifo` container from Chapter 01. It must return a valid route, its cost and the order in which nodes were expanded.

The aim is not to memorize DFS pseudocode. It is to assemble familiar helper functions into a working search and explain the behavior.

### File tour — before editing

**TASK — Required:** Open `tasks/dfs_graph.m` beside `demos/demo_pattern.m`. Identify OPEN, `seen`, `closed` and `par`, and explain what each variable stores before editing any TODO.

Open **`tasks/dfs_graph.m`** and keep **`demos/demo_pattern.m`** next to it. The demo already performs **reachability**; your task converts that same loop into a **goal-directed path search**.

| Existing element | Why the search needs it | How to inspect it |
|---|---|---|
| `OPEN` | Decide which discovered node to explore next | Recall your LIFO/FIFO experiment |
| `seen` | Prevent pushing the same node repeatedly | Trace what happens in a small cycle |
| `par(v)` | Remember how each node was reached | Reconstruct A–B–E–F from Chapter 01 |
| `closed`, `order` | Avoid repeated expansion and measure explored work | Read `st.order` after execution |
| Goal condition | Stop searching once the target is reached | Run once before and once after its insertion |

**Three local tests before the automated checker:** (1) start equals goal, (2) goal unreachable, (3) an ordinary graph with several branches. They separate termination, reachability and branch order. The automated checker does not replace your explanation of any of them.


## Step 1 — Trace a search by hand

**TASK — Step 1:** Trace the first expansions from A by hand using the given neighbour order and a LIFO stack. Predict which node is expanded next and when the search should terminate.

On the course graph (A–F), suppose neighbours are discovered in ascending node order: A sees B, C, D. You put them into a LIFO container in this order.

**TASK — Predict before MATLAB:**

1. **TASK:** Which node is removed next?
2. **TASK:** If your search encounters F, should it immediately stop? At what precise point in the loop?
3. **TASK:** How could the search later reconstruct the route without storing every partial route?

Now run:

```matlab
G = graph_example();
plot_graph(G, 'Title', 'DFS: predict the first expansions');
```

Mark the expected first three expanded nodes in your notes.

<details>
<summary>Show solution (after your own attempt)</summary>

The next node removed from the LIFO container is **D**, because A inserts B, C, D in that order and D was inserted last. The first three expanded nodes of the completed DFS (with a goal test) are **A, D, F**.

Stop when **F is removed from OPEN** (after checking that it is not a stale entry), not merely when F is first discovered. Store one predecessor per newly discovered node; `reconstruct_path` follows these predecessors backwards.

</details>


## Step 2 — Read the supplied skeleton

**TASK — Step 2:** Inspect the provided `dfs_graph.m` skeleton. Locate the container, neighbour loop, predecessor array and goal condition, and state what is still missing.

Open `tasks/dfs_graph.m`. Find these variables and write one phrase next to each:

| Variable | Your explanation |
|---|---|
| `OPEN` | |
| `seen` | |
| `closed` | |
| `par` | |
| `order` | |

<details>
<summary>Show solution (after your own attempt)</summary>

| Variable | Purpose |
|---|---|
| `OPEN` | Discovered nodes still waiting to be considered |
| `seen` | Marks nodes already inserted so DFS does not insert them repeatedly |
| `closed` | Marks nodes whose expansion has already been processed |
| `par` | Records the predecessor of each discovered node |
| `order` | Records the order of expansions for analysis and plotting |

The initial skeleton cannot continue from A because newly discovered neighbours are **not added to OPEN** and their predecessors are not recorded. In the task skeleton those are the missing actions in TODO 1.

</details>


Do **not** rewrite the complete function. You will complete its three TODO sections. The skeleton intentionally starts with a FIFO container, which does not implement DFS.

Temporarily remove only the initial `error('task:todo',...)` line. Run:

```matlab
[p, c, st] = dfs_graph(G.W, G.s, G.t)
```

**TASK — Explain:** Why does the incomplete search fail to reach the goal? Which information is missing inside its neighbour loop?

## Step 3 — Make the search discover nodes

**TASK — Step 3:** Complete `TODO 1` so new neighbours receive a predecessor and are pushed into OPEN. Run the graph example and explain how this allows the search to continue.

Complete `TODO 1` **without looking at the solution file**. Use the helper functions practiced in Chapter 01:

**Why this TODO exists:** Merely asking for neighbours does not make the search move anywhere. For each *new* neighbour the algorithm needs **two different records**: where it came from (`par`) and that it still needs processing (`OPEN`). Before editing, locate the two corresponding helper exercises from Chapter 01. Do not modify `graph_neighbors` or `open_push` themselves.


- Remember the predecessor of a newly discovered neighbour.
- Add the neighbour to OPEN.

**TASK — Predict:** With the deliberately incorrect FIFO setting, what order do you expect the first expansions to follow?

<details>
<summary>Show solution (after your own attempt)</summary>

With FIFO and neighbours visited in ascending order, the completed neighbour-discovery logic expands **A, B, C, D, E, F** on the course graph (when the goal test is active). FIFO processes earlier discoveries before later ones, producing breadth-first behaviour. This is intentionally **not** DFS.

</details>


Run your code and inspect `st.order`. Compare it with your prediction.

If the program does not reach the goal, inspect whether `OPEN` is updated using the returned value of `open_push`.

## Step 4 — Make it depth-first

**TASK — Step 4:** Complete `TODO 2` by selecting the LIFO mode. Compare the expansion order before and after the change and explain why this implements depth-first behaviour.

Complete `TODO 2` by selecting the correct container mode.

**Why this TODO exists:** A reachability loop becomes **depth-first** only because of the rule for choosing the next node. Compare the expansion trace **before** changing the mode and **after**. If nothing changes, verify which `dfs_graph` MATLAB runs with `which dfs_graph`.


Run the same graph again and compare its expansion order with Step 3.

**Explain in two sentences:** Why can changing the container alter the exploration dramatically even though the neighbour function and the map are unchanged?

<details>
<summary>Show solution (after your own attempt)</summary>

The container controls **which discovered node is expanded next**, so it determines the order in which unexplored branches are considered. LIFO dives down the newest branch, whereas FIFO processes earlier-discovered nodes and expands the graph layer by layer.

</details>


## Step 5 — Stop at the goal and validate

**TASK — Step 5:** Complete `TODO 3` so the search stops when the goal is removed from OPEN. Run `check_my_code('dfs')`, inspect the returned path and cost, and explain any failed test.

Complete `TODO 3`: stop when the node **removed from OPEN** is the goal.

**Why this TODO exists:** Without a goal test, the routine can keep exploring after it has already found the destination. A goal test is not the same as adding neighbours or reconstructing a route: it decides **when searching may terminate**.


```matlab
[p, c, st] = dfs_graph(G.W, G.s, G.t);
plot_graph(G, 'Expanded', st.order, 'Path', p, 'Title', 'My DFS');
check_my_code('dfs')
```

**What the checker tests:** Not only the course graph, but also special cases such as `s == t` and an unreachable goal. If it fails, first inspect `st.order` and `par`, then compare to the failing case. A green checker verifies selected outputs; it does **not** mean DFS produces a shortest or cheapest route.

<details>
<summary>Diagnostic hints (open only if your test fails)</summary>

- Search ends after expanding only A: confirm that `open_push` is **assigned back** to `OPEN`.
- Expansion order looks like BFS: the OPEN mode is probably still `'fifo'`.
- Correct nodes but wrong reconstructed route: verify whether `par(v)` records the node **u that discovered v**, not vice versa.
- Path found but code explores further: check that the goal test occurs immediately after a valid node is removed from OPEN.

</details>


**Reference outcome for this deterministic six-node graph:** A–D–F, cost 7, three expansions. If your result differs, check the order of neighbour insertion, goal test and parent assignment.

**Do not stop with a green test:** Explain why a route costing 3 also exists, yet DFS returns a cost of 7.

<details>
<summary>Show solution (after your own attempt)</summary>

DFS does not use weights when choosing its next node. Its LIFO order leads it along **A–D–F**, costing `6+1=7`, although **A–B–E–F** costs only `1+1+1=3`. DFS guarantees neither minimum cost nor, in general, the fewest edges.

</details>


## Step 6 — One small experiment

**TASK — Step 6:** Change only the weight of edge A–D in a temporary graph. Run your DFS again and explain why its selected route can remain unchanged although its cost changes.

Create a modified graph:

```matlab
W2 = G.W;
W2(1,4) = 2;
W2(4,1) = 2;
[p2, c2, st2] = dfs_graph(W2, G.s, G.t);
```

Does DFS explore the graph differently? Does the reported cost change? What does this tell you about whether DFS *uses* edge costs during its decisions?

<details>
<summary>Show solution (after your own attempt)</summary>

Changing A–D from weight 6 to weight 2 keeps the graph topology and neighbour order unchanged. Therefore **DFS expands the same nodes and returns the same route** (A–D–F), but its computed route cost decreases from **7 to 3**. Edge weights affect the reported cost, not DFS's node-selection decisions.

</details>


## Checkpoint

**TASK — Required:** Confirm the algorithm returns a legal route and that you can explain OPEN, `seen`, `closed`, `par` and the reason DFS does not guarantee minimum cost.

- [ ] My file passes `check_my_code('dfs')`.
- [ ] I can explain the different roles of `seen`, `closed` and `par`.
- [ ] I know when a node is added to OPEN and when it is expanded.
- [ ] I can explain why DFS is not generally optimal.

**Optional challenge:** Change the neighbour iteration order in a temporary copy. Predict whether the route or the expansion order changes. Restore the original afterward.

**Next:** [03 — Derive BFS →](03_breadth_first.md)
