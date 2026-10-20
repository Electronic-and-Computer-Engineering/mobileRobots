function test_maze()
%TEST_MAZE  Check the two map generators.
%
%   The flood fill at the bottom deliberately uses no tool from the
%   toolbox, so this check stays independent of the searches.

fprintf('  test_maze\n');

h = 6;
w = 8;
M = maze_random(h, w, 42);

expect(isequal(size(M), [2*h+1, 2*w+1]), 'maze has size 2h+1 x 2w+1');
expect(all(M(1, :) == 1) && all(M(end, :) == 1), 'top and bottom are wall');
expect(all(M(:, 1) == 1) && all(M(:, end) == 1), 'left and right are wall');
expect(all(M(:) == 0 | M(:) == 1), 'the map contains only 0 and 1');

free = nnz(M == 0);
expect(free == 2*h*w - 1, 'perfect maze: 2hw-1 free cells, so no loops');

M2 = maze_random(h, w, 42);
expect(isequal(M, M2), 'same seed gives the same maze');
M3 = maze_random(h, w, 43);
expect(~isequal(M, M3), 'a different seed gives a different maze');

expect(local_all_reachable(M), 'every free cell is reachable from every other');

% ---- the open field with obstacles ------------------------------------
[Mo, s, t] = maze_obstacles(20, 30, 0.2, 7);
expect(isequal(size(Mo), [20 30]), 'obstacle field has the requested size');
expect(Mo(s) == 0 && Mo(t) == 0, 'start and goal are on free cells');
expect(s ~= t, 'start and goal are different');
expect(local_reachable_from(Mo, s, t), 'there is a path from s to t at all');

[Mo2, s2, t2] = maze_obstacles(20, 30, 0.2, 7);
expect(isequal(Mo, Mo2) && s == s2 && t == t2, 'same seed gives the same field');
end


% =======================================================================
function tf = local_all_reachable(M)
%LOCAL_ALL_REACHABLE  Flood fill starting at the first free cell.
free  = find(M == 0);
if isempty(frei)
    tf = false;
    return
end
tf = nnz(local_flood(M, frei(1))) == numel(frei);
end


function tf = local_reachable_from(M, s, t)
visited = local_flood(M, s);
tf = visited(t);
end


function visited = local_flood(M, start)
%LOCAL_FLOOD  Plain flood fill over the 4-neighbourhood.
[R, C]  = size(M);
visited = false(R, C);
stack  = start;
visited(start) = true;
while ~isempty(stack)
    i = stack(end);
    stack(end) = [];
    [r, c] = ind2sub([R, C], i);
    for d = [-1 0; 1 0; 0 -1; 0 1].'
        rr = r + d(1);
        cc = c + d(2);
        if rr < 1 || rr > R || cc < 1 || cc > C
            continue
        end
        if M(rr, cc) ~= 0 || visited(rr, cc)
            continue
        end
        visited(rr, cc) = true;
        stack(end + 1) = sub2ind([R, C], rr, cc);   %#ok<AGROW>
    end
end
end
