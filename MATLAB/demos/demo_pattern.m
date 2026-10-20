function demo_pattern()
%DEMO_PATTERN  The loop that every search in this course is built on.
%
%   Usage:  demo_pattern
%
%   This demo solves a DIFFERENT problem than path planning: which cells
%   can be reached from the start at all? No goal, no path, no costs.
%   But it uses exactly the loop you need in chapters 02 to 06.
%
%   Read the ten numbered lines twice before you move on.
%
%   Verifies: open_new, open_push, open_pop, grid_neighbors, plot_grid.

clc
M = [0 0 0 0 0 0 0
     0 0 1 1 1 0 0
     0 0 1 0 1 0 0
     0 0 1 1 1 0 0
     0 0 0 0 0 0 0];
[R, C] = size(M);
s = sub2ind([R C], 1, 1);

fprintf('\n============================================================\n');
fprintf(' DEMO -- the pattern\n');
fprintf('============================================================\n');
fprintf('\n The map. Note the walled-in cell in the middle:\n\n');
for r = 1:R
    fprintf('    ');
    fprintf('%2d', M(r, :));
    fprintf('\n');
end
fprintf('\n Start is (1,1), cell %d.\n', s);

% =======================================================================
%  THE PATTERN -- this loop is the same in every search
% =======================================================================

n     = numel(M);
seen  = false(n, 1);
order = zeros(1, 0);

OPEN    = open_new('fifo');          % 1. make the container
seen(s) = true;                      % 2. mark the start as seen
OPEN    = open_push(OPEN, s);        % 3. put the start in

while ~open_isempty(OPEN)            % 4. while something is left
    [OPEN, u] = open_pop(OPEN);      % 5. take one out

    order(end + 1) = u;              %#ok<AGROW>  just for the record

    nb = grid_neighbors(M, u, 4);    % 6. get its neighbours
    for k = 1:numel(nb)              % 7. one at a time
        v = nb(k);
        if seen(v)                   % 8. known already? skip it
            continue
        end
        seen(v) = true;              % 9. remember it
        OPEN    = open_push(OPEN, v);% 10. and put it in
    end
end

% =======================================================================

fprintf('\n------------------------------------------------------------\n');
fprintf(' What came out\n');
fprintf('------------------------------------------------------------\n');
fprintf('\n    cells in total:     %d\n', n);
fprintf('    of those free:      %d\n', nnz(M == 0));
fprintf('    of those reached:   %d\n', numel(order));
fprintf('    NOT reachable:      %d\n', nnz(M == 0) - numel(order));

missed = find(M(:) == 0 & ~seen);
for k = 1:numel(missed)
    [r, c] = ind2sub([R C], missed(k));
    fprintf('\n    Cell %d = (%d,%d) is free, but completely walled in.\n', ...
        missed(k), r, c);
end

fprintf('\n    The first twelve cells, in the order they came out:\n    ');
fprintf('%d ', order(1:min(12, numel(order))));
fprintf('...\n');

figure('Name', 'demo_pattern: what the loop reached');
plot_grid(M, 'Expanded', order, 'Start', s, ...
    'Title', 'Everything coloured in was reached -- the pocket stays white');
fprintf('\n    A window opened. Colour means reached; light colours came\n');
fprintf('    out early, strong colours late. The walled-in cell stays\n');
fprintf('    white. That colouring is exactly how you will compare the\n');
fprintf('    five algorithms later.\n');

% ---------------------------------------------------------------- transfer
fprintf('\n------------------------------------------------------------\n');
fprintf(' And now the transfer\n');
fprintf('------------------------------------------------------------\n');
fprintf('\n    Those ten numbered lines are the whole pattern. Your search\n');
fprintf('    algorithms are the same thing plus three additions:\n\n');
fprintf('    (a) a GOAL to stop at\n');
fprintf('           if u == t, break, end          right after line 5\n\n');
fprintf('    (b) par, so the way back can be traced\n');
fprintf('           par(v) = u;                    right before line 10\n');
fprintf('           at the end: reconstruct_path(par, s, t, W)\n\n');
fprintf('    (c) from chapter 05 on, costs: g, the relaxation, and a key\n');
fprintf('        when pushing.\n\n');
fprintf('    Line 1 decides WHICH algorithm it becomes. Nothing else\n');
fprintf('    changes.\n\n');
end
