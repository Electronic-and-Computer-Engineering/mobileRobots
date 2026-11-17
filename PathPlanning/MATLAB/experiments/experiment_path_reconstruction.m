% EXPERIMENT_PATH_RECONSTRUCTION — Follow parents back from the goal.
% TASK: Predict the route before running the function.
clearvars
G=graph_example();
par=zeros(6,1);                  % par(v) = predecessor node of v.
par(2)=1;                       % B came from A.
par(5)=2;                       % E came from B.
par(6)=5;                       % F came from E.
[p,c]=reconstruct_path(par,G.s,G.t,G.W);
fprintf('Path: '); disp(p);
fprintf('Path cost: %g\n',c);

% TASK: Change the predecessors to create A-D-F (NOT an actual search).
par=zeros(6,1);
par(4)=1;
par(6)=4;
[p2,c2]=reconstruct_path(par,G.s,G.t,G.W);
fprintf('Alternative path: '); disp(p2);
fprintf('Alternative cost: %g\n',c2);
% CHECKPOINT: Why do algorithms store par(v) instead of only the path cost?
