function cc_plot_track(T, varargin)
%CC_PLOT_TRACK  Draw the track, a route, and where the car really went.
%
%   CC_PLOT_TRACK(T)
%   CC_PLOT_TRACK(T, 'Name', value, ...) understands:
%       'Route'    the planned route, N-by-2 or N-by-3 (poses)
%       'Driven'   the log from CC_SIMULATE, or an N-by-3 [x y theta]
%       'Cars'     how many car outlines to draw along 'Driven' (default 24)
%       'Expanded' poses the search took out of OPEN, N-by-3
%       'Crash'    [x y] to mark with a cross
%       'Safety'   true: show the safety band the pose planner keeps
%       'Title'    a title
%
%   THE CAR OUTLINES ARE THE POINT OF THIS FUNCTION. A line through the
%   middle of the track always looks fine. Draw the car's rectangle every
%   few tenths of a second and you see what the line does not show: how
%   close the corners come, where the body hangs into the inside of a
%   bend, and whether the route was ever driveable at all.
%
%   See also CC_TRACK, CC_SIMULATE, CC_ANIMATE_LAP, PLOT_GRID.

p = inputParser();
p.addParameter('Route',    []);
p.addParameter('Driven',   []);
p.addParameter('Cars',     24);
p.addParameter('Expanded', []);
p.addParameter('Crash',    []);
p.addParameter('Safety',   false);
p.addParameter('Title',    '');
p.parse(varargin{:});
a = p.Results;

P = T.P;

% ---- the track --------------------------------------------------------
img = ones(T.Rf, T.Cf, 3);
if a.Safety
    band = T.Msafe ~= 0 & T.Mfine == 0;
    img(:,:,1) = 1 - 0.14*band;
    img(:,:,2) = 1 - 0.08*band;
    img(:,:,3) = 1 - 0.04*band;
end
wall = T.Mfine ~= 0;
img(:,:,1) = img(:,:,1) .* ~wall + 0.063*wall;
img(:,:,2) = img(:,:,2) .* ~wall + 0.129*wall;
img(:,:,3) = img(:,:,3) .* ~wall + 0.169*wall;

image([T.fineSize/2, P.worldX - T.fineSize/2], ...
      [P.worldY - T.fineSize/2, T.fineSize/2], img);
set(gca, 'YDir', 'normal');
axis equal
axis([0 P.worldX 0 P.worldY])
hold on
xlabel('x [m]')
ylabel('y [m]')

% ---- expanded poses ---------------------------------------------------
if ~isempty(a.Expanded)
    plot(a.Expanded(:,1), a.Expanded(:,2), '.', ...
        'Color', [0.55 0.75 0.85], 'MarkerSize', 4);
end

% ---- the planned route ------------------------------------------------
if ~isempty(a.Route)
    plot(a.Route(:,1), a.Route(:,2), '-', ...
        'Color', [0.13 0.38 0.75], 'LineWidth', 1.6);
end

% ---- where the car went ----------------------------------------------
if ~isempty(a.Driven)
    if isstruct(a.Driven)
        D = [a.Driven.x(:), a.Driven.y(:), a.Driven.theta(:)];
        if isempty(a.Crash) && a.Driven.crashed
            a.Crash = a.Driven.crashAt;
        end
    else
        D = a.Driven;
    end
    plot(D(:,1), D(:,2), '-', 'Color', [0.91 0.40 0.24], 'LineWidth', 2.2);

    if a.Cars > 0 && size(D,2) >= 3
        step = max(1, round(size(D,1) / a.Cars));
        for k = 1:step:size(D,1)
            st.x = D(k,1);  st.y = D(k,2);  st.theta = D(k,3);
            out = cc_car_outline(st, P);
            plot(out(:,1), out(:,2), '-', ...
                'Color', [0.91 0.40 0.24], 'LineWidth', 1.0);
        end
    end
end

% ---- start, checkpoints, finish line ---------------------------------
plot(P.start(1), P.start(2), 'o', 'MarkerSize', 9, ...
    'MarkerFaceColor', [0.12 0.48 0.31], 'MarkerEdgeColor', 'k');
plot(P.checkpoints(:,1), P.checkpoints(:,2), 's', 'MarkerSize', 7, ...
    'MarkerFaceColor', [0.98 0.80 0.25], 'MarkerEdgeColor', 'k');
for q = 1:size(P.checkpoints,1)
    text(P.checkpoints(q,1)+0.06, P.checkpoints(q,2)+0.06, ...
        sprintf('CP%d', q), 'FontWeight', 'bold', 'FontSize', 9);
end
plot([P.finishX P.finishX], P.finishY, '-', ...
    'Color', [0.55 0.10 0.15], 'LineWidth', 2);

% ---- the crash --------------------------------------------------------
if ~isempty(a.Crash) && all(isfinite(a.Crash))
    plot(a.Crash(1), a.Crash(2), 'x', 'Color', [0.75 0.12 0.18], ...
        'MarkerSize', 16, 'LineWidth', 3);
end

if ~isempty(a.Title)
    title(a.Title)
end
hold off
end
