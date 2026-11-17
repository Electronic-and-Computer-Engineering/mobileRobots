%DEMO_MY_MOTION_SPACE  Draw YOUR motion space and YOUR neighbours.
%
%   demo_my_motion_space
%   demo_my_motion_space(pose)
%   demo_my_motion_space(pose, 'Track', 'crazycar', 'Depth', 3)
%
%   pose   [x y theta] to look from. Default: the start pose of the track.
%
%   Options:
%     'Track'  'oval' (default) or 'crazycar'
%     'Depth'  how many moves deep to fan out in the second figure
%              (default 3; 0 draws only the first figure)
%
%   WHY THIS EXISTS
%
%   CHECK_CAR_PRIMITIVES and CHECK_CAR_NEIGHBORS give you numbers. This
%   gives you the picture, and for a geometry exercise the picture is
%   usually faster: a fan that leans the wrong way, an arc that bends too
%   late, a neighbour sitting inside a wall -- you see all three in a
%   second and none of them in a table.
%
%   It draws YOUR tasks/car_primitives.m and YOUR tasks/car_neighbors.m.
%   If a file is still the skeleton it says so and stops.
%
%   WHAT TO LOOK FOR
%
%   Figure 1, the five moves from one pose:
%     - the fan should be symmetric about the car's own axis
%     - the pale bands are the area the body sweeps; nothing in them may
%       touch a wall, or that move must be rejected
%     - a move drawn in red was rejected by your CAR_NEIGHBORS. Check
%       that it really is blocked -- rejecting a free move is as wrong as
%       accepting a blocked one, and the search will simply never find
%       the route that needed it.
%
%   Figure 2, several moves deep:
%     - near a wall the fan should lean AWAY from it
%     - if the whole fan is rotated or scattered across the map, the
%       rotation in TODO 1 is wrong -- that is the classic one, and at
%       the start pose of the oval it hides, because sin(theta) is 0.
%
%   See also CAR_PRIMITIVES, CAR_NEIGHBORS, CHECK_CAR_PRIMITIVES.

function demo_my_motion_space(pose, varargin)

% Allow demo_my_motion_space('Track','crazycar') with no pose at all:
% without this the option name would be swallowed as the pose.
if nargin >= 1 && (ischar(pose) || isstring(pose))
    varargin = [{pose}, varargin];
    pose = [];
end

q = inputParser();
q.addParameter('Track', 'oval');
q.addParameter('Depth', 3);
q.parse(varargin{:});
o = q.Results;

P  = cc_params('Track', o.Track);
T  = cc_track(P);

% ---- your primitives --------------------------------------------------
try
    CM = cc_car_model(T, P);
catch err
    if any(strcmp(err.identifier, {'task:todo', 'cc_car_model:noPrimitives'}))
        fprintf('\n  tasks/car_primitives.m is still the skeleton, so there is\n');
        fprintf('  no motion space to draw yet. Work through step 5 of\n');
        fprintf('  ANLEITUNGEN/08_vehicle_neighbors.md first.\n\n');
        return
    end
    rethrow(err)
end

if nargin < 1 || isempty(pose)
    pose = P.start;
end
pose = pose(:).';

% ---- your neighbours --------------------------------------------------
haveNeighbors = true;
try
    [~, ~, reached] = car_neighbors(CM, pose);
catch err
    if strcmp(err.identifier, 'task:todo')
        haveNeighbors = false;
        reached = zeros(0,3);
        fprintf('\n  tasks/car_neighbors.m is still the skeleton. Drawing the\n');
        fprintf('  primitives only -- every move will be shown as allowed.\n\n');
    else
        rethrow(err)
    end
end

fprintf('\n  Pose (%.2f, %.2f) at %+.1f deg on the %s track\n', ...
    pose(1), pose(2), rad2deg(pose(3)), o.Track);

%% ===== figure 1: the five moves ======================================
figure('Name', 'Your motion space', 'Position', [60 80 1000 520]);
local_track(T, P);
hold on

nFree = 0;
for k = 1:numel(CM.prim)
    pts  = local_place(pose, CM.prim(k));
    kept = local_isKept(pts(end,:), reached, haveNeighbors);
    nFree = nFree + kept;
    col = [0.13 0.38 0.75];
    if ~kept, col = [0.75 0.12 0.18]; end

    for r = 1:size(pts,1)                       % the swept body
        out = cc_car_outline(struct('x',pts(r,1),'y',pts(r,2),'theta',pts(r,3)), P);
        patch(out(:,1), out(:,2), col, 'FaceAlpha', 0.10, 'EdgeColor', 'none');
    end
    plot([pose(1); pts(:,1)], [pose(2); pts(:,2)], '-', 'Color', col, 'LineWidth', 2.6);
    plot(pts(end,1), pts(end,2), 'o', 'MarkerSize', 8, ...
        'MarkerFaceColor', col, 'MarkerEdgeColor', 'w', 'LineWidth', 1.2);
    text(pts(end,1), pts(end,2), sprintf('  %+.0f\\circ', CM.prim(k).delta), ...
        'FontSize', 13, 'FontWeight', 'bold', 'Color', col);
end

out = cc_car_outline(struct('x',pose(1),'y',pose(2),'theta',pose(3)), P);
patch(out(:,1), out(:,2), [0.88 0.91 0.93], 'EdgeColor', 'k', 'LineWidth', 2.2);
plot(pose(1), pose(2), 'o', 'MarkerSize', 9, 'MarkerFaceColor', [0.12 0.48 0.31], ...
    'MarkerEdgeColor', 'k');

local_zoom(pose, 0.42, P);
title(sprintf('Your five moves: %d of %d accepted%s', nFree, numel(CM.prim), ...
    local_tag(haveNeighbors)));
hold off

fprintf('  %d of %d moves accepted\n', nFree, numel(CM.prim));

%% ===== figure 2: several moves deep ==================================
if o.Depth < 1 || ~haveNeighbors
    fprintf('\n');
    return
end

levels = {pose};
seen   = cc_pose_index(pose, CM);
segs   = {};
depth  = zeros(0,1);
for d = 1:o.Depth
    nxt = zeros(0,3);
    for i = 1:size(levels{end},1)
        p0 = levels{end}(i,:);
        [nb, ~, np] = car_neighbors(CM, p0);
        for j = 1:numel(nb)
            pts = local_place(p0, CM.prim(local_which(CM, p0, np(j,:))));
            segs{end+1}  = [p0; pts];          %#ok<AGROW>
            depth(end+1) = d;                  %#ok<AGROW>
            if ~ismember(nb(j), seen)
                seen(end+1) = nb(j);           %#ok<AGROW>
                nxt(end+1,:) = np(j,:);        %#ok<AGROW>
            end
        end
    end
    levels{end+1} = nxt;                       %#ok<AGROW>
    if isempty(nxt), break, end
end

shades = [0.66 0.82 0.88; 0.43 0.69 0.80; 0.24 0.52 0.70; 0.08 0.30 0.55];
figure('Name', 'Your reachable set', 'Position', [100 60 1000 520]);
local_track(T, P);
hold on
for s = 1:numel(segs)
    c = shades(min(depth(s), size(shades,1)), :);
    plot(segs{s}(:,1), segs{s}(:,2), '-', 'Color', c, 'LineWidth', 1.8);
end
patch(out(:,1), out(:,2), [0.88 0.91 0.93], 'EdgeColor', 'k', 'LineWidth', 2.2);
plot(pose(1), pose(2), 'o', 'MarkerSize', 9, 'MarkerFaceColor', [0.12 0.48 0.31], ...
    'MarkerEdgeColor', 'k');

total = 0;
for d = 2:numel(levels), total = total + size(levels{d},1); end
local_zoom(pose, 0.30 + 0.16*o.Depth, P);
title(sprintf('%d moves deep: %d reachable poses', o.Depth, total));
hold off

fprintf('  %d poses reachable within %d moves\n\n', total, o.Depth);
end

% -----------------------------------------------------------------------
function pts = local_place(pose, pr)
ct = cos(pose(3));  sn = sin(pose(3));
pts = [pose(1) + pr.pts(:,1)*ct - pr.pts(:,2)*sn, ...
       pose(2) + pr.pts(:,1)*sn + pr.pts(:,2)*ct, ...
       pose(3) + pr.pts(:,3)];
end

% -----------------------------------------------------------------------
function tf = local_isKept(endPose, reached, haveNeighbors)
%LOCAL_ISKEPT  Did the student's CAR_NEIGHBORS keep this move?
if ~haveNeighbors
    tf = true;
    return
end
if isempty(reached)
    tf = false;
    return
end
d = hypot(reached(:,1) - endPose(1), reached(:,2) - endPose(2));
tf = any(d < 1e-6);
end

% -----------------------------------------------------------------------
function k = local_which(CM, pose, endPose)
%LOCAL_WHICH  Which primitive produced this neighbour?
best = inf;  k = 1;
for i = 1:numel(CM.prim)
    pts = local_place(pose, CM.prim(i));
    d = hypot(pts(end,1) - endPose(1), pts(end,2) - endPose(2));
    if d < best, best = d; k = i; end
end
end

% -----------------------------------------------------------------------
function local_track(T, P)
img = ones(T.Rf, T.Cf, 3);
band = (T.Msafe ~= 0) & (T.Mfine == 0);
img(:,:,1) = img(:,:,1) - 0.13*band;
img(:,:,2) = img(:,:,2) - 0.07*band;
img(:,:,3) = img(:,:,3) - 0.03*band;
w = T.Mfine ~= 0;
wall = [0.063 0.129 0.169];
for i = 1:3
    img(:,:,i) = img(:,:,i) .* ~w + wall(i) * w;
end
image([T.fineSize/2, P.worldX - T.fineSize/2], ...
      [P.worldY - T.fineSize/2, T.fineSize/2], img);
set(gca, 'YDir', 'normal');
axis equal
axis([0 P.worldX 0 P.worldY])
xlabel('x [m]'); ylabel('y [m]');
end

% -----------------------------------------------------------------------
function local_zoom(pose, half, P)
ar = 1000/520;
cx = pose(1) + 0.35*half*cos(pose(3));
cy = pose(2) + 0.35*half*sin(pose(3));
xlim([max(0, cx - half*ar), min(P.worldX, cx + half*ar)]);
ylim([max(0, cy - half),    min(P.worldY, cy + half)]);
end

% -----------------------------------------------------------------------
function s = local_tag(haveNeighbors)
if haveNeighbors
    s = '';
else
    s = '  (car\_neighbors not written yet)';
end
end
