function test_path()
%TEST_PATH  Check reconstruct_path -- walking back through par.

fprintf('  test_path\n');

G = graph_example();
W = G.W;

% par as it looks after a run that found A - B - E - F
par = [0 1 1 1 2 5];

[p, c] = reconstruct_path(par, 1, 6, W);
expect(isequal(p, [1 2 5 6]), 'path A - B - E - F is traced back correctly');
expect(abs(c - 3) < 1e-12, 'that path costs 3');

[p2, c2] = reconstruct_path(par, 1, 4, W);
expect(isequal(p2, [1 4]), 'goal D: path A - D');
expect(abs(c2 - 6) < 1e-12, 'A - D costs 6');

% ---- without W, steps are counted instead of cost ---------------------
[~, cSchritte] = reconstruct_path(par, 1, 6);
expect(cSchritte == 3, 'without W reconstruct_path counts steps (3)');

% ---- start equals goal ------------------------------------------------
[p3, c3] = reconstruct_path(par, 1, 1, W);
expect(isequal(p3, 1), 'start equals goal: the path is just the start node');
expect(c3 == 0, 'start equals goal: cost 0');

% ---- no path ----------------------------------------------------------
parLeer = zeros(1, 6);
[p4, c4] = reconstruct_path(parLeer, 1, 6, W);
expect(isempty(p4), 'no path: empty result');
expect(isinf(c4), 'no path: cost is infinite');
expect(~isequal(p4, 0), 'no path is NOT the same as a path of length 0');

% ---- a broken par is detected instead of looping forever --------------
parZyklus = [0 3 2 0 0 0];   % 2 points at 3, 3 points back at 2
fehlerKam = false;
try
    reconstruct_path(parZyklus, 1, 2, W);
catch
    fehlerKam = true;
end
expect(fehlerKam, 'a cycle in par is reported instead of hanging');
end
