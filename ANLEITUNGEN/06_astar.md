[← 05 Greedy](05_greedy.md) · **06 A*** · [07 Comparison →](07_comparison.md)

# 06 — A*: combine travelled cost and remaining estimate

**Block 2 · 45 min CORE / 60 min full version · Edit `tasks/astar_graph.m`**


> **Compact CORE route (~45 min):** Core: Steps 1, 2, 3 and 5. Optional: Step 4 (invalid heuristic experiment). See [CORE_ROUTE.md](CORE_ROUTE.md). The original detailed time estimates and exercises below are the **full** version, not required to fit the compact core time.

## Goal

Dijkstra uses `g(v)`, the best cost known from the start. Greedy uses `h(v)`, an estimate to the goal. A* combines both:

\[
f(v)=g(v)+h(v).
\]

Implement A* using your Dijkstra search as the starting point, then test when and why the method is optimal.

### File tour — one key connects three algorithms

Open **`tasks/dijkstra_graph.m`** and **`tasks/astar_graph.m`** side by side. Keep Dijkstra's relaxation intact: the actual cost `g` still matters. Your task is to change what priority OPEN assigns to a discovered node.

| Algorithm | OPEN priority | Why |
|---|---|---|
| Dijkstra | `g(v)` | Prefer the cheapest known route from start |
| Greedy | `h(v)` | Prefer the node that looks nearest to the goal |
| A* | `g(v) + h(v)` | Balance actual cost so far and predicted cost ahead |

Before editing, identify **every** call to `open_push`: do not forget the first insertion of the start node. A single incorrect key can silently change node order while still returning a plausible path.


## Step 1 — Choose a node on paper (10 min)

Use the course graph. After expanding A, its neighbours have these known costs:

| Node | `g(v)` | `h(v)` from the provided graph | `f(v)` (complete) |
|---|---:|---:|---:|
| B | 1 | 2 | |
| C | 1 | 3 | |
| D | 6 | 1 | |

**Before coding:** Complete the final column. Which node would Dijkstra select? Which would Greedy select? Which would A* select?

Explain why A* does not fall for the attractive-looking but expensive A–D route.

<details>
<summary>Show solution (after your own attempt)</summary>

| Node | `g(v)` | `h(v)` | `f(v)=g(v)+h(v)` |
|---|---:|---:|---:|
| B | 1 | 2 | **3** |
| C | 1 | 3 | **4** |
| D | 6 | 1 | **7** |

- **Dijkstra** picks B or C next because their `g` values tie at 1; in the supplied implementation B wins the tie.
- **Greedy** picks D because `h(D)=1` is the smallest heuristic.
- **A\*** picks B because `f(B)=3` is smallest.

A* accounts for the **actual cost of getting to D**, so the tempting heuristic value does not conceal the expensive A–D connection.

</details>


## Step 2 — Construct A* (20 min)

Open `tasks/astar_graph.m` and copy your completed `dijkstra_graph.m` into it.

**Why retain relaxation?** Two different routes can lead to the same candidate node. `g(v)` and `par(v)` must still record the best of those routes. The heuristic affects **which candidate is explored first**, not the way we compare actual route costs.

**Reverse-engineering challenge:** In a temporary copy, change **only** the priority to `h(v)`. What algorithm have you accidentally created? Restore `g+h`, then try `h=0` later in Step 3 and predict what algorithm reappears.
 Update the function signature to accept `h`.

Keep Dijkstra's **relaxation** unchanged. Modify only the node priority so that it includes the known cost and heuristic estimate. Find **every** place where a node enters OPEN; your key must be used consistently.

```matlab
G = graph_example();
[p, c, st] = astar_graph(G.W, G.s, G.t, G.h);
plot_graph(G, 'Expanded', st.order, 'Path', p, 'Title', 'My A*');
check_my_code('astar')
```

**What a green test does not prove:** A* must use a suitable heuristic to preserve its optimality guarantee. The supplied grid setup uses consistent distance heuristics for its intended movement model. Test both `h=0` and the deliberately excessive `hBad` below: they expose different parts of the algorithm's behaviour.

**Debug order:** Check (1) all `open_push` calls use the same priority formula, (2) relaxation still updates `g` and `par`, (3) closed entries are handled correctly, (4) the heuristic matches the movement model.


For the supplied deterministic graph, A* should return A–B–E–F, cost 3, after four expansions.

**Explain:** Which node does Dijkstra expand that A* does not have to expand on this example?

<details>
<summary>Show solution (after your own attempt)</summary>

Dijkstra expands **C** before reaching F, because C still has a low accumulated cost. A* prioritizes the promising route through B and E toward F, so C remains in OPEN. On the given graph Dijkstra expands five nodes while A* expands four.

</details>


## Step 3 — Remove the heuristic (10 min)

Predict what happens if `h(v)=0` for all nodes. Then verify:

```matlab
[p0, c0, st0] = astar_graph(G.W, G.s, G.t, zeros(6,1));
[pD, cD, stD] = dijkstra_graph(G.W, G.s, G.t);

[c0 cD]
[st0.expansions stD.expansions]
```

**Answer:** Is Dijkstra a special case of A*? Explain it from the selection function rather than from this single output.

<details>
<summary>Show solution (after your own attempt)</summary>

Yes. A* chooses nodes using `f(v)=g(v)+h(v)`. Setting **`h(v)=0` for every node** makes `f(v)=g(v)`, exactly Dijkstra's selection rule. With matching tie-handling, the searches behave identically.

</details>


## Step 4 — Deliberately use a bad heuristic (10 min)

An admissible heuristic satisfies \(h(v)\le h^*(v)\), where \(h^*(v)\) is the true minimum remaining cost. On our grid with the usual Manhattan or Octile estimates, the heuristics are also **consistent**, which is important for our particular A* implementation: nodes are closed permanently and not reopened.

Test this deliberately excessive estimate:

```matlab
hBad = [3 8 8 1 1 0]';
[pBad, cBad] = astar_graph(G.W, G.s, G.t, hBad);
[pBad, cBad]
```

The expected cost on the course graph is 7 instead of 3. Find the particular comparison of `f` values that produces this result.

<details>
<summary>Show solution (after your own attempt)</summary>

With `hBad = [3 8 8 1 1 0]`, expanding A gives:

- B: `f(B)=1+8=9`
- C: `f(C)=1+8=9`
- D: `f(D)=6+1=7`

A* therefore expands **D**, then can reach F for total cost 7 before exploring B or C. The new estimate overestimates the true remaining cost from B and C, so the optimality guarantee is lost.

</details>


**Critical distinction:** An inadmissible heuristic *can* lead to a worse route; it does not have to fail on every map. A* also requires appropriate handling of inconsistent heuristics if closed nodes are never reopened.

## Step 5 — Bring your own A* onto a grid (10 min)

```matlab
[M, s, t] = maze_obstacles(20, 30, 0.20, 7);
[pD, cD, sD] = search_student_grid(M, s, t, 'dijkstra');
[pA, cA, sA] = search_student_grid(M, s, t, 'astar');

figure
subplot(1,2,1)
plot_grid(M, 'Expanded', sD.order, 'Path', pD, ...
          'Start', s, 'Goal', t, 'Title', 'My Dijkstra');
subplot(1,2,2)
plot_grid(M, 'Expanded', sA.order, 'Path', pA, ...
          'Start', s, 'Goal', t, 'Title', 'My A*');

fprintf('Dijkstra cost %.3f, expansions %d\n', cD, sD.expansions);
fprintf('A*       cost %.3f, expansions %d\n', cA, sA.expansions);
```

These results come from your own implementations, not the original prewritten `search_grid` routine. If the paths have the same cost but different shapes, consider equally optimal alternatives and tie-breaking before calling one result wrong.

**Explain:** What information enables A* to avoid searching parts of the map that Dijkstra examines?

<details>
<summary>Show solution (after your own attempt)</summary>

Dijkstra prioritizes only **known cost from the start**. A* adds an **estimate of remaining cost toward the goal**, so candidates far away from useful goal-directed routes can have larger `f` values and remain unexpanded. This may reduce search work while retaining optimality for an appropriate consistent heuristic, but the reduction depends on the map and tie-breaking.

</details>


## Checkpoint

- [ ] `check_my_code('astar')` passes.
- [ ] I can derive `f = g + h` and explain every term.
- [ ] I can explain why `h = 0` reproduces Dijkstra's selection rule.
- [ ] I know that heuristic quality affects expansions and that an unsuitable heuristic may break optimality.
- [ ] I can run my Dijkstra and A* on a new grid.

**End of Block 2:** Save all five completed `*_graph.m` files.

**Next:** [07 — Compare your algorithms on random maps →](07_comparison.md)
