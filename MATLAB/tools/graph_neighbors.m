function [nb, w] = graph_neighbors(W, u)
%GRAPH_NEIGHBORS  The neighbours of one node, from the cost matrix.
%
%   [nb, w] = GRAPH_NEIGHBORS(W, u) returns the numbers of all nodes
%   joined to u by an edge, in ascending order, and what each of those
%   edges costs.
%
%   This is the ONLY question any search in this course asks the map.
%
%   W(u,v) == 0 means there is no edge. That is why no edge weight here
%   may ever be 0 -- a zero-cost edge could not be told apart from "no
%   edge".
%
%   The ascending order is not an accident: it makes the expansion order
%   reproducible and matches the alphabetical tie-break on the slides.
%
%   See also GRID_NEIGHBORS, GRAPH_EXAMPLE.


nb = find(W(u, :) > 0);
w  = W(u, nb);
end
