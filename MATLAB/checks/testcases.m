function F = testcases()
%TESTCASES  The cases every solution is checked against.
%
%   For each case the expected result of ALL FIVE methods is stored.
%   That lets the checker say more than "wrong": it can say "that is the
%   result of a different method -- you probably built X instead of Y".
%
%   Every number here was computed, not guessed.
%
%   Fields per case:
%     W, s, t      the graph and the job
%     h            estimate towards that goal (admissible and consistent)
%     exp.<name>   {path, cost, expansions}
%     text         label for the output
%
%   See also CHECK_MY_CODE.

G1 = graph_example();
W1 = G1.W;

% ---- a second graph, seven nodes, a different shape -------------------
n2 = 7;
e2 = [1 2 4; 1 3 1; 3 4 1; 2 4 1; 2 5 3; 4 5 5; 5 7 1; 4 6 2; 6 7 2];
W2 = zeros(n2, n2);
for k = 1:size(e2, 1)
    W2(e2(k,1), e2(k,2)) = e2(k,3);
    W2(e2(k,2), e2(k,1)) = e2(k,3);
end

F = struct([]);
i = 0;

% ---- case 1: the course graph, A -> F ---------------------------------
i = i + 1;
F(i).text = 'course graph, A -> F';
F(i).W = W1;  F(i).s = 1;  F(i).t = 6;
F(i).h = [3 2 3 1 1 0];
F(i).exp.dfs      = {[1 4 6],   7, 3};
F(i).exp.bfs      = {[1 4 6],   7, 6};
F(i).exp.greedy   = {[1 4 6],   7, 3};
F(i).exp.dijkstra = {[1 2 5 6], 3, 5};
F(i).exp.astar    = {[1 2 5 6], 3, 4};

% ---- case 2: same graph, goal D ---------------------------------------
%  The direct edge A-D costs 6, the detour A-B-E-F-D only 4.
i = i + 1;
F(i).text = 'course graph, A -> D (the expensive edge is a trap)';
F(i).W = W1;  F(i).s = 1;  F(i).t = 4;
F(i).h = [4 3 4 0 2 1];
F(i).exp.dfs      = {[1 4],       6, 2};
F(i).exp.bfs      = {[1 4],       6, 4};
F(i).exp.greedy   = {[1 4],       6, 2};
F(i).exp.dijkstra = {[1 2 5 6 4], 4, 6};
F(i).exp.astar    = {[1 2 5 6 4], 4, 5};

% ---- case 3: a different start ----------------------------------------
i = i + 1;
F(i).text = 'course graph, C -> F';
F(i).W = W1;  F(i).s = 3;  F(i).t = 6;
F(i).h = [3 2 3 1 1 0];
F(i).exp.dfs      = {[3 5 6], 3, 3};
F(i).exp.bfs      = {[3 5 6], 3, 6};
F(i).exp.greedy   = {[3 5 6], 3, 3};
F(i).exp.dijkstra = {[3 5 6], 3, 5};
F(i).exp.astar    = {[3 5 6], 3, 3};

% ---- case 4: a completely different graph -----------------------------
%  Catches solutions that were tuned to the course graph. Leaving out
%  the relaxation in Dijkstra still gives the right answer on the course
%  graph -- it only shows up here.
i = i + 1;
F(i).text = 'second graph, seven nodes, A -> G';
F(i).W = W2;  F(i).s = 1;  F(i).t = 7;
F(i).h = [6 4 5 4 1 2 0];
F(i).exp.dfs      = {[1 3 4 6 7], 6, 5};
F(i).exp.bfs      = {[1 2 5 7],   8, 7};
F(i).exp.greedy   = {[1 2 5 7],   8, 4};
F(i).exp.dijkstra = {[1 3 4 6 7], 6, 7};
F(i).exp.astar    = {[1 3 4 6 7], 6, 5};

% ---- case 5: start is already the goal --------------------------------
i = i + 1;
F(i).text = 'special case: start is already the goal';
F(i).W = W1;  F(i).s = 1;  F(i).t = 1;
F(i).h = [0 1 1 4 2 3];
for name = {'dfs', 'bfs', 'greedy', 'dijkstra', 'astar'}
    F(i).exp.(name{1}) = {1, 0, 1};
end

% ---- case 6: the goal cannot be reached -------------------------------
%  Node 7 has no edge at all.
W3 = zeros(7, 7);
W3(1:6, 1:6) = W1;
i = i + 1;
F(i).text = 'special case: the goal cannot be reached';
F(i).W = W3;  F(i).s = 1;  F(i).t = 7;
F(i).h = [0 0 0 0 0 0 0];
for name = {'dfs', 'bfs', 'greedy', 'dijkstra', 'astar'}
    F(i).exp.(name{1}) = {[], inf, 6};
end
end
