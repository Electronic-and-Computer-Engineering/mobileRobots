function test_grid()
%TEST_GRID  Check grid neighbours and the heuristics.

fprintf('  test_grid\n');

M = zeros(3, 3);            % alles frei
mitte = sub2ind([3 3], 2, 2);
ecke  = sub2ind([3 3], 1, 1);

% ---- the 4-neighbourhood ----------------------------------------------
[nb, w] = grid_neighbors(M, mitte, 4);
expect(numel(nb) == 4, 'conn 4: the middle cell has four neighbours');
expect(all(abs(w - 1) < 1e-12), 'conn 4: every step costs 1');

[nb, ~] = grid_neighbors(M, ecke, 4);
expect(numel(nb) == 2, 'conn 4: the corner has two neighbours (border handled)');

% ---- the 8-neighbourhood ----------------------------------------------
[nb, w] = grid_neighbors(M, mitte, 8);
expect(numel(nb) == 8, 'conn 8: the middle cell has eight neighbours');
expect(sum(abs(w - 1) < 1e-12) == 4, 'conn 8: four straight steps cost 1');
expect(sum(abs(w - sqrt(2)) < 1e-12) == 4, 'conn 8: four diagonal steps cost sqrt(2)');

% ---- obstacles --------------------------------------------------------
Mh = zeros(3, 3);
Mh(1, 2) = 1;
[nb, ~] = grid_neighbors(Mh, mitte, 4);
expect(~any(nb == sub2ind([3 3], 1, 2)), 'obstacle cells are never returned');
expect(numel(nb) == 3, 'one obstacle removes exactly one neighbour');

% ---- corner cutting ---------------------------------------------------
Mc = zeros(3, 3);
Mc(1, 2) = 1;      % oben
Mc(2, 1) = 1;      % links
diagonale = sub2ind([3 3], 1, 1);

[nb, ~] = grid_neighbors(Mc, mitte, 8, false);
expect(~any(nb == diagonale), ...
    'corner cutting off: the diagonal between two walls is blocked');

[nb, ~] = grid_neighbors(Mc, mitte, 8, true);
expect(any(nb == diagonale), ...
    'corner cutting on: the same diagonal is allowed');

% only one of the two in-between cells blocked -> still refused
Mc2 = zeros(3, 3);
Mc2(1, 2) = 1;
[nb, ~] = grid_neighbors(Mc2, mitte, 8, false);
expect(~any(nb == diagonale), ...
    'one blocked in-between cell is enough to block the diagonal');

% ---- being a neighbour goes both ways ---------------------------------
Mr = zeros(4, 5);
Mr(2, 3) = 1;
Mr(3, 4) = 1;
symmetrisch = true;
for i = 1:numel(Mr)
    if Mr(i) ~= 0
        continue
    end
    nbi = grid_neighbors(Mr, i, 8, false);
    for j = nbi
        if ~any(grid_neighbors(Mr, j, 8, false) == i)
            symmetrisch = false;
        end
    end
end
expect(symmetrisch, 'if v is a neighbour of u then u is one of v');

% ---- heuristics -------------------------------------------------------
R = 3; C = 3;
t = sub2ind([R C], 3, 3);
start = sub2ind([R C], 1, 1);

hMan = grid_heuristic('manhattan', R, C, t);
hOct = grid_heuristic('octile',    R, C, t);
hEuk = grid_heuristic('euclid',    R, C, t);
hNul = grid_heuristic('zero',      R, C, t);

expect(abs(hMan(start) - 4) < 1e-12, 'manhattan from (1,1) to (3,3) is 4');
expect(abs(hOct(start) - 2 * sqrt(2)) < 1e-12, 'octile from (1,1) to (3,3) is 2*sqrt(2)');
expect(abs(hEuk(start) - sqrt(8)) < 1e-12, 'euclid from (1,1) to (3,3) is sqrt(8)');
expect(hNul(start) == 0, 'the zero heuristic estimates 0 everywhere');
expect(hMan(t) == 0 && hOct(t) == 0 && hEuk(t) == 0, 'at the goal every heuristic estimates 0');

% h has to work on a vector too, the search calls it column-wise
alle = (1:numel(zeros(R, C))).';
expect(numel(hMan(alle)) == R * C, 'the heuristic also takes a vector of cell indices');

% on a conn-4 grid manhattan is exactly the true distance
expect(all(hOct(alle) <= hMan(alle) + 1e-12), ...
    'octile never estimates higher than manhattan');
expect(all(hEuk(alle) <= hOct(alle) + 1e-12), ...
    'euclid never estimates higher than octile');

fehlerKam = false;
try
    grid_heuristic('luftlinie', R, C, t);
catch
    fehlerKam = true;
end
expect(fehlerKam, 'an unknown heuristic name is refused');
end
