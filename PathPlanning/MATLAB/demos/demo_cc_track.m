%DEMO_CC_TRACK  The track, its three maps, and how metres become cells.
%
%   demo_cc_track
%
%   See also CC_TRACK, CC_WORLD2GRID, CC_GRID2WORLD, CC_PLOT_TRACK.

clc
P = cc_params();
T = cc_track(P);

fprintf('\n============ The track ============\n\n');
fprintf('  Size                 %.2f m by %.2f m\n', P.worldX, P.worldY);
fprintf('  Planning map  T.M    %d x %d cells of %.0f cm   (%d free of %d)\n', ...
    T.R, T.C, T.cellSize*100, sum(T.M(:) == 0), numel(T.M));
fprintf('  Collision map T.Mfine %d x %d cells of %.0f cm\n', ...
    T.Rf, T.Cf, T.fineSize*100);
fprintf('  Walls of T.M grown by %.4f m (half the car width plus a margin)\n', P.inflate);
fprintf('  Walls of T.Msafe grown by %.2f m (the pose planner''s margin)\n', P.safety);

fprintf('\n============ Metres to cells, and back ============\n\n');
[idx, r, c] = cc_world2grid(P.start(1), P.start(2), T);
[xb, yb]    = cc_grid2world(idx, T);
fprintf('  start pose    (%.3f, %.3f) m\n', P.start(1), P.start(2));
fprintf('  is cell       row %d, column %d  ->  linear index %d\n', r, c, idx);
fprintf('  whose centre  (%.3f, %.3f) m\n', xb, yb);
fprintf('\n  >> You do not get the same point back. A cell covers an area;\n');
fprintf('     the best it can tell you is where the middle of it is.\n');
fprintf('     Half a cell is %.1f cm. The car is %.1f cm wide.\n', ...
    T.cellSize/2*100, P.bodyW*100);

fprintf('\n  Row 1 is the TOP of the track, but y is measured from the\n');
fprintf('  BOTTOM, so the row number runs the other way:\n');
for yy = [0.2 0.6 1.5 2.5]
    [~, rr] = cc_world2grid(3.0, yy, T);
    fprintf('     y = %.1f m  ->  row %2d\n', yy, rr);
end

fprintf('\n============ Where the lap goes ============\n\n');
fprintf('  start       (%.2f, %.2f) m, pointing %+.0f deg\n', ...
    P.start(1), P.start(2), rad2deg(P.start(3)));
for q = 1:size(P.checkpoints,1)
    fprintf('  CP%d         (%.2f, %.2f) m\n', q, P.checkpoints(q,1), P.checkpoints(q,2));
end
fprintf('  finish line x = %.2f m, between y = %.2f and %.2f\n', ...
    P.finishX, P.finishY(1), P.finishY(2));

figure('Name','The CrazyCar track','Position',[80 80 1100 520]);
cc_plot_track(T, 'Safety', true, ...
    'Title', 'CrazyCar track: walls, safety band, start, checkpoints, finish line');

figure('Name','The planning map','Position',[120 120 1100 520]);
plot_grid(T.M, 'Start', T.s, 'Title', ...
    sprintf('T.M -- what a POINT planner sees (%.0f cm cells, walls grown by %.1f cm)', ...
    T.cellSize*100, P.inflate*100));

fprintf('\n  Two figures: the real track, and what the point planner sees.\n');
fprintf('  Compare the corners. The grown walls have rounded them off --\n');
fprintf('  that rounding IS the car''s width, moved onto the wall.\n\n');
