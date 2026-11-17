function test_graph()
%TEST_GRAPH  Check the example graph, neighbour access and h.

fprintf('  test_graph\n');

G = graph_example();
W = G.W;
n = size(W, 1);

% ---- how the matrix is built ------------------------------------------
expect(n == 6, 'example graph has 6 nodes');
expect(isequal(W, W.'), 'cost matrix is symmetric (undirected)');
expect(all(diag(W) == 0), 'no self-loops on the diagonal');
expect(nnz(W) / 2 == 7, 'seven edges');
expect(all(W(W > 0) > 0), 'no edge weight is 0 or negative');
expect(G.s == 1 && G.t == 6, 'start A, goal F');

% ---- neighbours -------------------------------------------------------
[nb, w] = graph_neighbors(W, 1);
expect(isequal(nb, [2 3 4]), 'A has neighbours B C D');
expect(isequal(w, [1 1 6]), 'A: weights 1 1 6 -- A-D is the expensive edge');

[nb, w] = graph_neighbors(W, 6);
expect(isequal(nb, [4 5]), 'F has neighbours D E');
expect(isequal(w, [1 1]), 'F: weights 1 1');

[nb, ~] = graph_neighbors(W, 5);
expect(isequal(nb, [2 3 6]), 'E has neighbours B C F');
expect(issorted(nb), 'neighbours come out ascending -- that makes runs reproducible');

% ---- h: admissible and consistent -------------------------------------
% the true remaining costs to goal F, worked out by hand:
%   A=3  B=2  C=3  D=1  E=1  F=0
hStern = [3 2 3 1 1 0];
h      = G.h;

expect(numel(h) == n, 'h has one value per node');
expect(h(G.t) == 0, 'h at the goal is 0');
expect(all(h >= 0), 'h is never negative');
expect(all(h <= hStern + 1e-12), 'h is admissible: never estimates too high');

konsistent = true;
for u = 1:n
    [nb, w] = graph_neighbors(W, u);
    for k = 1:numel(nb)
        if h(u) > w(k) + h(nb(k)) + 1e-12
            konsistent = false;
        end
    end
end
expect(konsistent, 'h is consistent: h(u) <= w(u,v) + h(v) on every edge');

% ---- drawing positions ------------------------------------------------
expect(isequal(size(G.xy), [n 2]), 'every node has a drawing position');
expect(numel(G.names) == n, 'every node has a name');
end
