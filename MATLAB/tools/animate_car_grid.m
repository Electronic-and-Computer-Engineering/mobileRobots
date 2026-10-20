function animate_car_grid(M, path, varargin)
%ANIMATE_CAR_GRID Show a simplified top-down car following a grid path.
%
%   animate_car_grid(M, path)
%   animate_car_grid(M, path, 'StepPause', 0.05)
%
%   M: occupancy grid, 0 = free, nonzero = obstacle
%   path: legal consecutive linear grid indices (as returned by a planner)
%   StepPause: seconds between grid cells (visual playback, NOT a speed model)
%
%   The displayed rectangle points in the direction of movement. This is
%   an ANIMATION OF A GRID PATH, not a CrazyCar steering/speed simulation.
%   The vehicle is treated as a point for collision checking: footprint,
%   turning radius and motion dynamics are NOT modelled here.
%
%   See also SEARCH_STUDENT_GRID, PLOT_GRID, CAR_IN_MAZE.

p = inputParser();
p.addParameter('StepPause', 0.05);
p.parse(varargin{:});
delay = p.Results.StepPause;
if ~isscalar(delay) || ~isnumeric(delay) || ~isfinite(delay) || delay < 0
    error('animate_car_grid:delay', 'StepPause must be a nonnegative finite number.');
end
if ~ismatrix(M) || isempty(M)
    error('animate_car_grid:map','M must be a nonempty 2D map.');
end
if isempty(path)
    error('animate_car_grid:empty','The provided path is empty.');
end
if ~isnumeric(path) || ~isvector(path) || any(~isfinite(path)) || ...
        any(path ~= fix(path)) || any(path < 1) || any(path > numel(M))
    error('animate_car_grid:path','Path must contain valid linear cell indices.');
end
path = path(:).';
if any(M(path) ~= 0)
    error('animate_car_grid:collision','The path contains occupied cells.');
end
[r, c] = ind2sub(size(M), path);
if numel(path) > 1
    dr = diff(r); dc = diff(c);
    if any(max(abs(dr),abs(dc)) > 1 | (dr == 0 & dc == 0))
        error('animate_car_grid:jump','Two consecutive path cells are not adjacent.');
    end
end

figure('Name','Car follows a planned grid route');
plot_grid(M, 'Path',path, 'Start',path(1),'Goal',path(end), ...
    'Title','Grid-based car animation (not vehicle dynamics)');
hold on
% Body polygon and a short line marking the front of the car.
hCar = patch(NaN,NaN,[0.06 0.44 0.59], 'EdgeColor',[0.05 0.15 0.20], ...
    'LineWidth',1.3);
hFront = plot(NaN,NaN,'-', 'Color',[0.93 0.40 0.20], 'LineWidth',2.4);

for k = 1:numel(path)
    if numel(path) == 1
        direction = [1, 0];
    elseif k < numel(path)
        direction = [c(k+1)-c(k), r(k+1)-r(k)];
    else
        direction = [c(k)-c(k-1), r(k)-r(k-1)];
    end
    direction = direction / norm(direction);
    sideways = [-direction(2), direction(1)];
    center = [c(k), r(k)];
    front = center + 0.34*direction;
    rear  = center - 0.34*direction;
    corners = [front+0.22*sideways;
               front-0.22*sideways;
               rear-0.22*sideways;
               rear+0.22*sideways];
    set(hCar,'XData',corners(:,1),'YData',corners(:,2));
    f1 = front + 0.20*sideways;
    f2 = front - 0.20*sideways;
    set(hFront,'XData',[f1(1),f2(1)],'YData',[f1(2),f2(2)]);
    drawnow;
    if delay > 0, pause(delay); end
end
hold off
end
