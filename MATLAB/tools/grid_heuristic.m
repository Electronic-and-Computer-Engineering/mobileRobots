function hfun = grid_heuristic(name, R, C, t)
%GRID_HEURISTIC  Build an estimate of the remaining cost on a grid.
%
%   hfun = GRID_HEURISTIC(name, R, C, t) does NOT return a number. It
%   returns a FUNCTION, which you then ask per cell:
%
%       hfun = grid_heuristic('manhattan', R, C, t);   % build it
%       hfun(i)                                        % ask it
%
%   name is one of
%     'manhattan'   steps along rows and columns -- fits conn = 4
%     'octile'      allows diagonals              -- fits conn = 8
%     'euclid'      straight line                 -- always safe
%     'zero'        no estimate at all
%
%   An estimate never knows about obstacles. It only has to obey one
%   rule: NEVER ESTIMATE TOO HIGH. Too low only makes the search slower;
%   too high can make it walk past the cheapest route.
%
%   See also GRID_NEIGHBORS, PLOT_GRID.


[tr, tc] = ind2sub([R, C], t);

switch lower(name)
    case {'zero', 'null', 'dijkstra'}
        hfun = @(i) zeros(size(i));
    case 'manhattan'
        hfun = @(i) local_manhattan(i, R, C, tr, tc);
    case {'euclid', 'euclidean', 'euklid'}
        hfun = @(i) local_euclid(i, R, C, tr, tc);
    case {'octile', 'oktil'}
        hfun = @(i) local_octile(i, R, C, tr, tc);
    otherwise
        error('grid_heuristic:name', ...
            ['Unknown heuristic "%s". Allowed: manhattan, ', ...
             'octile, euclid, zero.'], name);
end
end

% -------------------------------------------------------------------------

function h = local_manhattan(i, R, C, tr, tc)
[r, c] = ind2sub([R, C], i);
h = abs(r - tr) + abs(c - tc);
end

function h = local_euclid(i, R, C, tr, tc)
[r, c] = ind2sub([R, C], i);
h = sqrt((r - tr).^2 + (c - tc).^2);
end

function h = local_octile(i, R, C, tr, tc)
[r, c] = ind2sub([R, C], i);
dr = abs(r - tr);
dc = abs(c - tc);
h  = max(dr, dc) + (sqrt(2) - 1) * min(dr, dc);
end
