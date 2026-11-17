function [path, cost, stats] = dfs_graph(W, s, t)
%DFS_GRAPH  TASK 1 -- depth-first search.
%
%   The skeleton below is complete and runs. Three places are missing,
%   all marked TODO. Do them in order and RUN IT after each one.
%
%   How to run it:
%       G = graph_example();
%       [p, c, st] = dfs_graph(G.W, G.s, G.t)
%
%   Target:  A - D - F, cost 7, 3 expansions.
%
%   Check:   check_my_code('dfs')
%
%   See also OPEN_NEW, GRAPH_NEIGHBORS, RECONSTRUCT_PATH.

error('task:todo', 'Task 1 not started -- delete this line and begin.');

n      = size(W, 1);
par    = zeros(n, 1);     % par(v): which node did we come from to reach v
seen   = false(n, 1);     % already put into OPEN once?
closed = false(n, 1);     % neighbours already looked at?
order  = zeros(1, 0);     % which nodes came out, in order

% TODO 2 -- Which container belongs to depth-first search?
%           'lifo' = last in, first out
%           'fifo' = first in, first out
%           (Do TODO 1 first. The wrong one is deliberately here.)
OPEN = open_new('fifo');

seen(s) = true;
OPEN    = open_push(OPEN, s);

while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);

    % A stale entry? Skip it. (In this pattern the line never fires,
    % because seen already prevents duplicates. It is here so the loop
    % stays unchanged when you move to task 4, where it is essential.)
    if closed(u)
        continue
    end
    closed(u)      = true;
    order(end + 1) = u;   %#ok<AGROW>
    trace_step(numel(order), u);

    % TODO 3 -- When are we done? Replace false by the condition.
    if false
        break
    end

    nb = graph_neighbors(W, u);
    for k = 1:numel(nb)
        v = nb(k);
        if seen(v) || closed(v)
            continue
        end

        % TODO 1 -- Two lines are missing here:
        %             - remember that we reached v coming from u
        %             - put v into OPEN  (open_push)
        seen(v) = true;
    end
end

[path, cost]     = reconstruct_path(par, s, t, W);
stats.expansions = numel(order);
stats.order      = order;
end
