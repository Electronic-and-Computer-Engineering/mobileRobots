function demo_graph()
%DEMO_GRAPH  See the course graph, and what graph_neighbors returns.
%
%   Usage:  demo_graph
%
%   Verifies: graph_example, graph_neighbors, reconstruct_path, plot_graph.

clc
G = graph_example();
n = numel(G.names);

fprintf('\n============================================================\n');
fprintf(' DEMO -- the graph\n');
fprintf('============================================================\n');

fprintf('\n Nodes are numbers in the code, not letters:  ');
for u = 1:n
    fprintf('%s=%d  ', G.names{u}, u);
end
fprintf('\n Start %s (%d), goal %s (%d)\n', G.names{G.s}, G.s, G.names{G.t}, G.t);

figure('Name', 'demo_graph: the course graph');
plot_graph(G, 'Title', 'The course graph -- watch the edge A-D');
fprintf('\n A window opened. The number on each edge is what it costs.\n');
fprintf(' A-D costs 6 while everything else costs 1 or 2. That edge is\n');
fprintf(' the trap the whole course is built around.\n');

fprintf('\n------------------------------------------------------------\n');
fprintf(' graph_neighbors -- the only question a search ever asks\n');
fprintf('------------------------------------------------------------\n');
fprintf('\n    [nb, w] = graph_neighbors(G.W, u)\n\n');
for u = 1:n
    [nb, w] = graph_neighbors(G.W, u);
    fprintf('    u = %d (%s):   nb = [', u, G.names{u});
    fprintf(' %d', nb);
    fprintf(' ]   w = [');
    fprintf(' %g', w);
    fprintf(' ]\n');
end
fprintf('\n    Compare that with the matrix: it is just row u with the\n');
fprintf('    zeros removed. A zero means NO EDGE, not a free edge.\n');

fprintf('\n------------------------------------------------------------\n');
fprintf(' par and reconstruct_path -- how the path comes back\n');
fprintf('------------------------------------------------------------\n');
par = [0 1 1 1 2 5];
fprintf('\n    Suppose a search left this behind:\n');
fprintf('    par = [');
fprintf(' %d', par);
fprintf(' ]\n\n');
for v = 1:n
    if par(v) == 0
        fprintf('      par(%d)=%d   %s was never reached (or is the start)\n', ...
            v, par(v), G.names{v});
    else
        fprintf('      par(%d)=%d   we reached %s coming from %s\n', ...
            v, par(v), G.names{v}, G.names{par(v)});
    end
end
[p, c] = reconstruct_path(par, G.s, G.t, G.W);
fprintf('\n    [path, cost] = reconstruct_path(par, %d, %d, G.W)\n', G.s, G.t);
fprintf('    path = [');
fprintf(' %d', p);
fprintf(' ]   that is  %s', G.names{p(1)});
for k = 2:numel(p)
    fprintf(' - %s', G.names{p(k)});
end
fprintf('\n    cost = %g\n', c);

figure('Name', 'demo_graph: a path drawn on the graph');
plot_graph(G, 'Path', p, 'Title', 'The same path, drawn');
fprintf('\n    Second window: the path as a thick line. Read it backwards\n');
fprintf('    from F and you get exactly the par chain above.\n');

fprintf('\n    And when nothing was found:\n');
[pEmpty, cEmpty] = reconstruct_path(zeros(1, n), G.s, G.t, G.W);
fprintf('      path = [] (empty),  cost = %g\n', cEmpty);
fprintf('      -> test it with isempty(path), never with cost == 0.\n');
if isempty(pEmpty)
    fprintf('      -> isempty(path) is true here.\n');
end
fprintf('\n');
end
