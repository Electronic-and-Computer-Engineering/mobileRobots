function demo_maps()
%DEMO_MAPS  The two kinds of map, and why the course uses both.
%
%   Usage:  demo_maps
%
%   Verifies: maze_random, maze_obstacles, plot_grid.

clc
fprintf('\n============================================================\n');
fprintf(' DEMO -- the two map generators\n');
fprintf('============================================================\n');

% ---------------------------------------------------------------- 1
fprintf('\n------------------------------------------------------------\n');
fprintf(' 1) maze_random -- narrow corridors\n');
fprintf('------------------------------------------------------------\n');
h = 10;
w = 15;
M = maze_random(h, w, 42);
sM = sub2ind(size(M), 2, 2);
tM = sub2ind(size(M), 2*h, 2*w);

fprintf('\n    M = maze_random(%d, %d, 42);\n\n', h, w);
fprintf('    size(M)        = %d x %d     (= 2h+1 by 2w+1)\n', size(M, 1), size(M, 2));
fprintf('    free cells     = %d          (= 2*h*w - 1, always)\n', nnz(M == 0));
fprintf('    walls          = %d\n', nnz(M ~= 0));
fprintf('\n    Between any two free cells there is EXACTLY ONE route. No\n');
fprintf('    loops, no walled-off pockets. That is what "perfect" means.\n');
fprintf('    The seed makes it repeatable -- same seed, same maze.\n');

figure('Name', 'demo_maps: maze_random');
plot_grid(M, 'Start', sM, 'Goal', tM, 'Title', 'maze\_random(10, 15, 42)');

% ---------------------------------------------------------------- 2
fprintf('\n------------------------------------------------------------\n');
fprintf(' 2) maze_obstacles -- an open field\n');
fprintf('------------------------------------------------------------\n');
[Mo, so, to] = maze_obstacles(30, 40, 0.25, 7);
fprintf('\n    [Mo, s, t] = maze_obstacles(30, 40, 0.25, 7);\n\n');
fprintf('    size(Mo)       = %d x %d\n', size(Mo, 1), size(Mo, 2));
fprintf('    free cells     = %d\n', nnz(Mo == 0));
fprintf('    start s        = %d, goal t = %d  (both guaranteed free and\n', so, to);
fprintf('                                     guaranteed connected)\n');

figure('Name', 'demo_maps: maze_obstacles');
plot_grid(Mo, 'Start', so, 'Goal', to, 'Title', 'maze\_obstacles(30, 40, 0.25, 7)');

fprintf('\n------------------------------------------------------------\n');
fprintf(' Why both?\n');
fprintf('------------------------------------------------------------\n');
fprintf('\n    In the narrow maze an estimate barely helps: the walls force\n');
fprintf('    detours it cannot see, so almost every cell gets expanded\n');
fprintf('    anyway. That is NOT a bug in your code.\n');
fprintf('\n    On the open field the estimate helps a lot. You will run the\n');
fprintf('    same search on both and compare the coloured area -- that\n');
fprintf('    contrast is the whole point of chapter 07.\n\n');
end
