function W = grid_to_graph(M, conn, allowCornerCut)
%GRID_TO_GRAPH  Convert a small occupancy grid to a sparse cost matrix.
%
%   W = GRID_TO_GRAPH(M, conn, allowCornerCut)
%
%   M              0 = free, nonzero = obstacle
%   conn           4 (default) or 8 neighbours
%   allowCornerCut false (default): diagonals may not cut wall corners
%
%   W is SPARSE: W(u,v)>0 is the cost of a legal move u->v.
%   Linear node indices are exactly MATLAB's linear indices into M.
%   This teaching adapter lets the students run their own *_graph.m on
%   grids without re-implementing all five algorithms. For very large
%   maps an implicit grid-neighbour interface is more efficient.

if nargin < 2 || isempty(conn), conn = 4; end
if nargin < 3 || isempty(allowCornerCut), allowCornerCut = false; end
if ~ismatrix(M) || isempty(M)
    error('grid_to_graph:map', 'M must be a non-empty 2-D grid.');
end
if conn ~= 4 && conn ~= 8
    error('grid_to_graph:conn', 'conn must be 4 or 8.');
end

free = find(M == 0);
n = numel(M);
maxEdges = conn * numel(free);
rows = zeros(maxEdges, 1);
cols = zeros(maxEdges, 1);
weights = zeros(maxEdges, 1);
count = 0;

for idx = 1:numel(free)
    u = free(idx);
    [nb, w] = grid_neighbors(M, u, conn, allowCornerCut);
    m = numel(nb);
    if m == 0, continue; end
    pos = count + (1:m);
    rows(pos) = u;
    cols(pos) = nb;
    weights(pos) = w;
    count = count + m;
end

W = sparse(rows(1:count), cols(1:count), weights(1:count), n, n);
end
