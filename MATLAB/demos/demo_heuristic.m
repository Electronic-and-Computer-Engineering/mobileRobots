function demo_heuristic()
%DEMO_HEURISTIC  See what an estimate looks like over a whole map.
%
%   Usage:  demo_heuristic
%
%   Verifies: grid_heuristic, and the one rule it has to obey.

clc
M = zeros(6, 9);
M(2:4, 4) = 1;          % a short wall, so the estimate can be seen lying
[R, C] = size(M);
t = sub2ind([R C], 6, 9);
s = sub2ind([R C], 1, 1);

fprintf('\n============================================================\n');
fprintf(' DEMO -- the estimate h\n');
fprintf('============================================================\n');
fprintf('\n An estimate answers: how far is it from here to the goal?\n');
fprintf(' It does NOT know about obstacles. It only has to obey one\n');
fprintf(' rule: NEVER ESTIMATE TOO HIGH.\n');

fprintf('\n------------------------------------------------------------\n');
fprintf(' 1) Two steps: build it, then ask it\n');
fprintf('------------------------------------------------------------\n');
fprintf('\n    hfun = grid_heuristic(''manhattan'', %d, %d, %d);   %% build\n', R, C, t);
fprintf('    hfun(%d)                                      %% ask\n', s);
hman = grid_heuristic('manhattan', R, C, t);
fprintf('\n    hfun(%d)  = %g      (top-left corner)\n', s, hman(s));
fprintf('    hfun(%d) = %g      (the goal itself)\n', t, hman(t));
fprintf('\n    grid_heuristic gives you a FUNCTION, not a number. That is\n');
fprintf('    the one thing people trip over here.\n');

fprintf('\n------------------------------------------------------------\n');
fprintf(' 2) The same estimate over the whole map\n');
fprintf('------------------------------------------------------------\n');
hgrid = zeros(R, C);
for i = 1:numel(M)
    hgrid(i) = hman(i);
end
figure('Name', 'demo_heuristic: manhattan');
plot_grid(M, 'Values', hgrid, 'Format', '%d', 'Start', s, 'Goal', t, ...
    'Title', 'manhattan: steps to the goal if nothing were in the way');
fprintf('\n    A window opened with the estimate written into every cell.\n');
fprintf('    Look at the cells just left of the wall: the estimate there\n');
fprintf('    is small, but the real route has to go round. The estimate\n');
fprintf('    is allowed to be wrong in that direction -- too LOW is fine.\n');

fprintf('\n------------------------------------------------------------\n');
fprintf(' 3) Four estimates, same cell\n');
fprintf('------------------------------------------------------------\n');
names = {'manhattan', 'octile', 'euclid', 'zero'};
what  = {'fits conn = 4', 'fits conn = 8', 'straight line, always safe', ...
         'no estimate at all'};
fprintf('\n    %-12s %10s   %s\n', 'name', 'h(start)', 'what it is for');
fprintf('    %-12s %10s   %s\n', '----', '--------', '--------------');
for k = 1:numel(names)
    hf = grid_heuristic(names{k}, R, C, t);
    fprintf('    %-12s %10.4f   %s\n', names{k}, hf(s), what{k});
end
fprintf('\n    The bigger the estimate, the harder it steers the search --\n');
fprintf('    as long as it does not go too high. zero steers not at all,\n');
fprintf('    which is exactly what turns A* back into Dijkstra.\n');

hoct = grid_heuristic('octile', R, C, t);
hog  = zeros(R, C);
for i = 1:numel(M)
    hog(i) = hoct(i);
end
figure('Name', 'demo_heuristic: octile');
plot_grid(M, 'Values', hog, 'Format', '%.1f', 'Start', s, 'Goal', t, ...
    'Title', 'octile: lower everywhere, because diagonals are allowed');
fprintf('\n    Second window: the same map with octile. Every number is\n');
fprintf('    smaller than before, because diagonal steps are shorter.\n');
fprintf('    Both are safe on a conn-8 grid; manhattan would NOT be.\n\n');
end
