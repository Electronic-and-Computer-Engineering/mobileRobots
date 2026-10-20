% 01_TOOLBOX_EXPERIMENTS  Student sandbox for Chapter 01.
% Open the matching demo file in a second tab; run one %% section at a time.
% Predict -> Run -> Modify ONE parameter -> Explain the observation.
% Do not edit files inside tools/ or overwrite the demos.

%% Activity 1 -- Container behaviour (see demos/demo_container.m)
% First change only 'fifo' to 'lifo'. Later try 'minkey' with numeric keys.
OPEN = open_new('fifo');
nodes = [4 2 7];
out = [];
for k = 1:numel(nodes)
    OPEN = open_push(OPEN, nodes(k));
end
while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);
    out(end+1) = u; %#ok<AGROW>
end
disp('Activity 1: removal order'); disp(out);
% TODO: Repeat with 'minkey' and own priorities using open_push(OPEN,v,key).
% TODO: Try the same node twice with different keys. What does open_size say?

%% Activity 2 -- Graph neighbours and edge weights (see demos/demo_graph.m)
G = graph_example();
u = G.s;                      % Change to 5 (node E).
[nb, w] = graph_neighbors(G.W, u);
disp('Activity 2: neighbours'); disp([nb(:), w(:)]);
% TODO: Inspect row G.W(u,:) and explain zeros.
% TODO: Change W2(1,4) and W2(4,1) in a COPY, then query again.

%% Activity 3 -- Reconstruct a path (see demos/demo_graph.m)
G = graph_example();
par = zeros(size(G.W,1),1);
par(2) = 1; par(5) = 2; par(6) = 5;
[p, cost] = reconstruct_path(par, G.s, G.t, G.W);
disp('Activity 3: [path, cost]'); disp(p); disp(cost);
% TODO: Change only par to represent A-D-F. Predict the cost first.
% TODO: Test start == goal and an unreachable goal.

%% Activity 4 -- Grid indices and neighbourhoods (see demos/demo_grid.m)
M = [0 0 0 0; 0 1 0 0; 0 0 0 0];
u = sub2ind(size(M),2,3);
[r,c] = ind2sub(size(M),u);
conn = 4;                      % Change to 8.
[nb, w] = grid_neighbors(M,u,conn);
disp('Activity 4: [index, row, col]'); disp([u r c]);
disp('Activity 4: [neighbour, cost]'); disp([nb(:), w(:)]);
% TODO: For each neighbour, translate its index back to (row,column).
% TODO: Test corner cutting with grid_neighbors(M,u,8,true).

%% Activity 5 -- Which heuristic fits which movement? (see demos/demo_heuristic.m)
R = 5; C = 6;
t = sub2ind([R C],4,5);
u = sub2ind([R C],2,2);
kind = 'manhattan';            % Try 'octile', 'euclid', and 'zero'.
hfun = grid_heuristic(kind,R,C,t);
fprintf('Activity 5: h(u) = %.6g; h(goal) = %.6g\n',hfun(u),hfun(t));
% TODO: Change ONLY the goal and predict the effect on h(u).
% TODO: Explain why adding an obstacle would not change this output.

%% Activity 6 -- Controlled random maps (see demos/demo_maps.m)
seed = 7;                     % Keep fixed for reproducibility, then change.
density = 0.25;               % Try 0.15 and 0.30 with same seed.
[M,s,t] = maze_obstacles(15,20,density,seed);
fprintf('Activity 6: size %dx%d, free cells %d\n', ...
    size(M,1),size(M,2),nnz(M==0));
figure; plot_grid(M,'Start',s,'Goal',t,'Title','My obstacle field');
% TODO: Repeat with same seed. Compare M arrays via isequal(M,M2).
% TODO: Run demo_pattern and mark the 10 common search-loop operations.
