[← 04 Dijkstra](04_dijkstra.md) · **05 Greedy best-first** · [06 A* →](06_astar.md)

# 05 — Greedy best-first: look toward the goal

**Block 2 · 25 min CORE / 40 min full version · Edit `tasks/greedy_graph.m`**


> **Compact CORE route (~25 min):** Core: Steps 1, 2 and 4. Optional: Step 3 (longer three-way comparison). See [CORE_ROUTE.md](CORE_ROUTE.md). The original detailed time estimates and exercises below are the **full** version, not required to fit the compact core time.

## Goal

Dijkstra selects the discovered node with the lowest known cost from the start. Greedy best-first chooses the node that **appears closest to the goal**, using the heuristic `h(v)`.

The goal of this chapter is to isolate the heuristic idea before combining it with Dijkstra in A*.

### File tour — deliberately ignore past cost

Open **`tasks/bfs_graph.m`** and **`tasks/greedy_graph.m`** together. You already know how to record predecessors and detect the goal. Only the rule for taking a candidate from OPEN is new.

In `demos/demo_heuristic.m` you learned that `h(v)` is a *number returned by a function or supplied as a vector*, not a true measured remaining distance. Greedy trusts that estimate completely. This makes it an excellent experiment in why **fast search** and **cheap routes** are different engineering goals.


## Step 1 — Predict the wrong decision (10 min)

The course graph has heuristic values:

```matlab
G = graph_example();
G.h
```

For A's neighbours B, C and D, record `h(B)`, `h(C)` and `h(D)` in your notes.

**Predict:** Which neighbour will Greedy expand next? What does Greedy *not* consider when making this choice? Does the expensive A–D edge change your prediction?

<details>
<summary>Show solution (after your own attempt)</summary>

The graph provides `h(B)=2`, `h(C)=3` and `h(D)=1`. Greedy selects **D**, because it has the smallest estimated remaining cost. Greedy **ignores accumulated travel cost** and therefore ignores the expensive A–D edge when choosing the next node. It later reaches F along A–D–F, which costs 7 instead of the available cost 3.

</details>


## Step 2 — Build Greedy from BFS (15 min)

Open `tasks/greedy_graph.m`. Start from your completed `bfs_graph.m` and retain its basic structure and first-visit handling.

**Why these changes?** FIFO cannot rank nodes by their distance estimate, so Greedy needs a **priority-based OPEN container**. The key must be specified on **every insertion**, including the start. The **path cost reported afterwards** still comes from the real edge weights — even though Greedy does not use them to select candidates.

**Pre-code reverse-engineering test:** Use your Chapter 01 `minkey` experiment to show how the same nodes `[2, 3, 4]` can be ordered differently by assigning priorities `[2, 3, 1]`. Only then update your Greedy code.


Make the two conceptual changes yourself:

1. OPEN must choose nodes by a numerical priority, not FIFO order.
2. The priority must depend on **the estimated remaining cost** of each node, both for the initial insertion and for each newly discovered neighbour.

Do **not** introduce `g`, relaxation or a sum of costs. This method deliberately knows nothing about what the route has cost so far.

```matlab
[p, c, st] = greedy_graph(G.W, G.s, G.t, G.h);
plot_graph(G, 'Expanded', st.order, 'Path', p, 'Title', 'My Greedy');
check_my_code('greedy')
```

**How to debug:** If the expansion trace looks like BFS, check the OPEN mode. If the route matches Dijkstra/A* on every test, inspect the key: Greedy must use **only `h`**, not `g+h`. The checker tests the algorithm's selection rule, not whether the found path happens to be inexpensive.


Expected course-graph outcome: Greedy selects A–D–F and returns cost 7 after three expansions, even though a route costing 3 exists.

## Step 3 — Same result, different reason (10 min)

Run the three searches on the same graph:

```matlab
[~, cDFS, sDFS] = dfs_graph(G.W, G.s, G.t);
[~, cGR,  sGR]  = greedy_graph(G.W, G.s, G.t, G.h);
[~, cDI,  sDI]  = dijkstra_graph(G.W, G.s, G.t);

[cDFS cGR cDI]
[sDFS.expansions sGR.expansions sDI.expansions]
```

**Answer:** DFS and Greedy can return the same path on this graph. Does that make them the same algorithm? Explain their completely different selection rules.

<details>
<summary>Show solution (after your own attempt)</summary>

No. **DFS** chooses the most recently discovered node using a LIFO container. **Greedy** chooses the node with the smallest heuristic value `h(v)` using a priority queue. Both happen to choose A–D–F on this example, but changing the graph, heuristic or insertion order can make their choices differ.

</details>


## Step 4 — First assessment (5 min)

Imagine this algorithm controlling a delivery robot. What is the practical trade-off between **search effort** and **driving distance**? Explain why Greedy may look impressive in a visualization while returning an unnecessarily expensive path.

<details>
<summary>Show solution (after your own attempt)</summary>

Greedy often expands comparatively few nodes, which can reduce planning effort, but it does **not guarantee a cheapest path**. A plot can show a narrow, goal-directed explored region while concealing a substantial increase in distance, time or energy of the final route. A proper evaluation must compare **both** search effort and actual route cost.

</details>


## Checkpoint

- [ ] `check_my_code('greedy')` passes.
- [ ] My implementation uses `h(v)` as its selection key.
- [ ] I can explain why Greedy is generally neither cost-optimal nor identical to DFS.

**Optional challenge:** Create a heuristic whose values favor B over D. Does Greedy's returned route change even though the graph remains identical?

**Next:** [06 — Combine g and h in A* →](06_astar.md)
