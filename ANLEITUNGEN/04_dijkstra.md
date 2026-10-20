[← 03 BFS](03_breadth_first.md) · **04 Dijkstra** · [05 Greedy →](05_greedy.md)

# 04 — Dijkstra: cheapest known route first

**Block 2 · 65 min CORE / 80 min full version · Edit `tasks/dijkstra_graph.m`**


> **Compact CORE route (~65 min):** Core: Steps 1–5, with a short demonstration of relaxation and stale entries. Optional: Step 6. See [CORE_ROUTE.md](CORE_ROUTE.md). The original detailed time estimates and exercises below are the **full** version, not required to fit the compact core time.

## Goal

BFS guarantees the fewest edges, not the smallest total cost. Dijkstra adds an explicit cost estimate **from the start to each discovered node** and updates it whenever a cheaper route is found.

In this chapter you will implement the most important new mechanism: **relaxation**.

### File tour — see where the new reasoning belongs

Open **`tasks/dijkstra_graph.m`** beside **`tasks/bfs_graph.m`**. Both have an OPEN loop and query neighbours, but a weighted planner must distinguish:

- **`g(v)`** — best cost *from start to v* known so far;
- **`w(k)`** — cost of one *new edge* `u → v`;
- **`par(v)`** — predecessor on the current best-known route;
- **OPEN key** — why the next node should be processed now.

Return briefly to `demos/demo_container.m`: try inserting the same node twice with different priorities. The duplicate-entry behaviour is **not an accident**; the relaxation mechanism may later improve a discovered route. Never replace Dijkstra's relaxation with a simple `seen` check.


## Step 1 — Understand `g` (15 min)

Let \(g(v)\) be the cost of the best route from start `s` to node `v` currently known to the algorithm. Initially:

\[
g(s)=0,\qquad g(v)=\infty\quad\text{for }v\ne s.
\]

Do this in MATLAB:

```matlab
G = graph_example();
g = inf(size(G.W,1),1);
g(G.s) = 0;
g
```

**On paper:** A has edges to B (cost 1), C (cost 1) and D (cost 6). What will the values of `g(B)`, `g(C)`, and `g(D)` be after expanding A once?

Update these three entries manually. Now suppose the path to E via B costs 2, while the path via C costs 3. Which parent should E remember? Why?

<details>
<summary>Show solution (after your own attempt)</summary>

After expanding A, the best-known costs are `g(B)=1`, `g(C)=1`, and `g(D)=6`. All other undiscovered nodes still have `Inf`.

For E, **B** should be the remembered predecessor because the route through B costs **2**, less than the **3** through C. The parent must correspond to the current best-known cost, not simply the first route inspected.

</details>


## Step 2 — Learn relaxation outside the algorithm (15 min)

Relaxation compares an already known route to `v` with a candidate route through `u`:

\[
g_{\mathrm{candidate}}=g(u)+w(u,v).
\]

Only if the candidate is cheaper do we update the best-known cost and predecessor.

**Small exercise:** Complete and run this experiment. Replace the missing condition with an actual MATLAB comparison.

```matlab
gU = 2;              % known cost to u
edgeCost = 1;        % cost u -> v
gV = 5;              % best route to v known before
candidate = gU + edgeCost;

% if ...      % Is the route through u better?
%     gV = candidate;
% end
```

Try `gV=5`, then `gV=2`, then `gV=Inf`. Predict in which cases the stored value changes.

**Explain:** Why do we initialize unknown distances to `Inf` rather than zero?

<details>
<summary>Show solution (after your own attempt)</summary>

The missing MATLAB test is `if candidate < gV` (followed by the update and `end`). With `candidate = 2+1 = 3`:

| Initial `gV` | Update? | New `gV` |
|---:|---|---:|
| 5 | Yes | 3 |
| 2 | No | 2 |
| `Inf` | Yes | 3 |

Initializing unexplored nodes to **`Inf`** ensures that the first finite candidate counts as an improvement. Initializing them to zero would prevent positive-cost routes from improving them.

</details>


## Step 3 — Turn the principle into Dijkstra (25 min)

Open `tasks/dijkstra_graph.m`. The outer loop and data structures are prepared, but the three TODOs in the neighbour loop are incomplete.

**What the TODOs contribute:** `TODO 1` *measures* the route via the current node; `TODO 2` *compares* it with the best value already stored; `TODO 3` *commits an improvement* by updating both cost and predecessor and scheduling the candidate. Without any one of these operations, the method no longer behaves like Dijkstra.

**Predict a failure:** What would happen if you always replaced `par(v)` but left `g(v)` unchanged? What if you updated `g(v)` but pushed a node with the **edge weight** rather than its **total accumulated cost**?

<details>
<summary>Diagnostic explanation (after your prediction)</summary>

The path reconstructed from `par` must correspond to the currently best-known cost `g`. Updating them inconsistently can produce a path that does not match the ranking values. Using a *single edge weight* as the priority makes the algorithm select locally cheap steps rather than cheapest **known total routes**.

</details>


Complete them in this order:

1. Determine the candidate cost to neighbour `v` via expanded node `u`.
2. Decide whether that candidate is an improvement.
3. Only when it is better, update **both** the known cost and the predecessor, and add `v` to OPEN with the appropriate priority.

**Do not copy a complete solution from the instructions.** Derive each required expression from the formula above and from your priority-queue exercise in Chapter 01.

Then run:

```matlab
G = graph_example();
[p, c, st] = dijkstra_graph(G.W, G.s, G.t);
st.order
plot_graph(G, 'Expanded', st.order, 'Path', p, ...
              'Values', st.g, 'Label', 'g', 'Title', 'My Dijkstra');
```

Expected conceptual result: Dijkstra avoids the expensive A–D shortcut and finds A–B–E–F for a cost of 3. With the supplied deterministic priority queue, it expands five nodes.

## Step 4 — Why can a node enter OPEN twice? (10 min)

Dijkstra may discover a node along an expensive route and later find a cheaper route to that same node.

**Investigate:**

1. Why must a candidate be allowed into OPEN even if the node was discovered earlier?
2. What can happen to the older, more expensive OPEN entry?
3. Which line in your code ensures that already finished nodes are not expanded again?

Demonstrate duplicate priorities using `open_new('minkey')`, two `open_push` calls for the same node and `open_pop`. This is an OPEN-container exercise, **not** a reason to edit the helper.

<details>
<summary>Show solution (after your own attempt)</summary>

A node may be reached first by an expensive route and later by a cheaper one. The new, cheaper entry is inserted with a lower key. A previously inserted entry is then **stale**; in the supplied pattern, `if closed(u), continue, end` prevents an already finalized node from being expanded again.

For example, pushing node `5` with priority 9 and then with priority 3 makes the **priority-3 entry** come out first. Neither push automatically deletes the other entry.

</details>


**Important:** For nonnegative edge weights Dijkstra can finalize a node when it is removed with the smallest cost. A standard Dijkstra implementation does not work in the same way with negative edges.

## Step 5 — Verify and separate edges from costs (10 min)

```matlab
check_my_code('dijkstra')
```

**Why run a test after the six-node example?** A program that finds cost 3 on this one graph may still be wrong if it updates a neighbour **only on first discovery**. The checker includes additional graphs intended to expose such errors. If a check fails, inspect each relaxation event: `u`, `v`, `g(u)`, `w(k)`, old `g(v)`, candidate and the choice to update or reject.

```matlab
[M, s, t] = maze_obstacles(12, 16, 0.20, 7);
[~, c4] = search_student_grid(M, s, t, 'dijkstra', 'Conn', 4);
[~, c8] = search_student_grid(M, s, t, 'dijkstra', 'Conn', 8);
fprintf('4-neighbour cost: %.3f\n8-neighbour cost: %.3f\n', c4, c8);
```

Explain why a diagonal step costs `sqrt(2)` rather than 1. Why is a simple comparison of the number of edges no longer sufficient?

<details>
<summary>Show solution (after your own attempt)</summary>

For unit square cells, moving horizontally or vertically travels a distance of **1 cell**, while moving diagonally travels `sqrt(1²+1²) = sqrt(2)` by Pythagoras. Thus edges have unequal costs in an 8-neighbour grid, so counting edges alone no longer determines the cheapest route. Dijkstra accumulates the actual weights.

</details>


## Step 6 — Explain your algorithm (5 min)

Without reading your source code, answer:

- What determines the next node taken from OPEN?
- Under which condition may `par(v)` change?
- How does Dijkstra differ from BFS?

<details>
<summary>Show solution (after your own attempt)</summary>

- Dijkstra takes from OPEN the node with the **smallest current accumulated cost `g`**.
- `par(v)` changes when a newly considered route to `v` is **strictly cheaper** than its current best-known route.
- BFS processes **hop-count layers** and does not compare edge weights; Dijkstra performs relaxation and sorts by accumulated cost.

</details>


## Checkpoint

- [ ] `check_my_code('dijkstra')` passes.
- [ ] I can write the relaxation inequality from memory and explain it.
- [ ] I know why a closed-node check is needed with repeated OPEN entries.
- [ ] I can distinguish a priority `g(v)` from an edge cost `w(u,v)`.

**Optional challenge:** Intentionally replace the relaxation test with a first-visit test in a temporary copy. Run `check_my_code('dijkstra')`. Find a case where the wrong implementation returns a more expensive path, then restore your correct code.

**Next:** [05 — Greedy best-first →](05_greedy.md)
