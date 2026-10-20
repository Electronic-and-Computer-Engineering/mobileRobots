function [path, cost, stats] = dijkstra_graph(W, s, t)
%DIJKSTRA_GRAPH  TASK 4 -- Dijkstra.
%
%   From here on there is arithmetic. Two things come in:
%
%     g(v)         what the best route to v found so far costs
%     relaxation   is going through u cheaper than what we knew?
%
%   That is why the seen array is gone: a node MAY enter OPEN again when
%   a cheaper route to it turns up. And that is why the line
%   "if closed(u)" now really matters -- the same node can sit in OPEN
%   several times and only the first one out counts.
%
%   Target:  A - B - E - F, cost 3, 5 expansions.
%            D stays in OPEN with g = 6 and is never taken out.
%
%   Check:   check_my_code('dijkstra')

error('task:todo', 'Task 4 not started -- delete this line and begin.');

n      = size(W, 1);
g      = inf(n, 1);       % no route known yet
g(s)   = 0;               % the start costs nothing
par    = zeros(n, 1);
closed = false(n, 1);
order  = zeros(1, 0);

OPEN = open_new('minkey');
OPEN = open_push(OPEN, s, g(s));

while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);
    if closed(u)
        continue
    end
    closed(u)      = true;
    order(end + 1) = u;   %#ok<AGROW>
    trace_step(numel(order), u);
    if u == t
        break
    end

    [nb, w] = graph_neighbors(W, u);
    for k = 1:numel(nb)
        v = nb(k);
        if closed(v)
            continue
        end

        % TODO 1 -- What does the route to v cost if we go through u?
        %           Available: g(u) and w(k).
        gNew = inf;

        % TODO 2 -- Is that better than what we already knew about v?
        if false

            % TODO 3 -- three lines:
            %             - store the new value in g(v)
            %             - set par(v)
            %             - push v with the right key
            %               ( open_push(OPEN, v, <key>) )

        end
    end
end

[path, cost]     = reconstruct_path(par, s, t, W);
stats.expansions = numel(order);
stats.order      = order;
stats.g          = g;
end
