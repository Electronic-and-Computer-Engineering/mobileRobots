function G = graph_example()
%GRAPH_EXAMPLE  The six-node graph used throughout the course.
%
%   G = GRAPH_EXAMPLE() returns a struct with
%
%     G.W      6x6 cost matrix. W(u,v) is what the edge u->v costs.
%              A 0 means there is no edge at all.
%     G.s      start node, 1 (called A on the slides)
%     G.t      goal node,  6 (called F)
%     G.h      one estimate per node of the remaining cost to the goal
%     G.names  {'A'..'F'}, for printing only
%     G.xy     drawing positions, used by PLOT_GRAPH
%
%   Watch the edge A-D: it costs 6 while every other edge costs 1 or 2.
%   That is the trap the whole course is built around.
%
%   See also GRAPH_NEIGHBORS, PLOT_GRAPH.


G.names = {'A', 'B', 'C', 'D', 'E', 'F'};
n = numel(G.names);

% Edge list: [from, to, weight]. The graph is undirected, so the
% matrix below is filled symmetrically.
edges = [ ...
    1 2 1    % A-B
    1 3 1    % A-C
    1 4 6    % A-D   <- the expensive shortcut
    2 5 1    % B-E
    3 5 2    % C-E
    4 6 1    % D-F
    5 6 1];  % E-F

G.W = zeros(n, n);
for k = 1:size(edges, 1)
    i = edges(k, 1);
    j = edges(k, 2);
    w = edges(k, 3);
    G.W(i, j) = w;
    G.W(j, i) = w;
end

% Heuristik: geschaetzte Restkosten bis F. Hier zufaellig exakt gleich den
% true remaining costs -- admissible and consistent. Greedy still walks
% into the trap, because it ignores what the trip has cost so far.
%          A  B  C  D  E  F
G.h    = [ 3  2  3  1  1  0];

G.s    = 1;   % start A
G.t    = 6;   % goal  F

% drawing positions only (order A B C D E F)
G.xy = [ ...
    0.87 2.55
    2.92 4.01
    2.92 2.55
    4.28 0.64
    5.28 3.28
    7.43 2.55];
end
