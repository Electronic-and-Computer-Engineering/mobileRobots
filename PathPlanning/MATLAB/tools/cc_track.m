function T = cc_track(P)
%CC_TRACK  The CrazyCar track, in the three resolutions the lab needs.
%
%   T = CC_TRACK()           uses the defaults from CC_PARAMS
%   T = CC_TRACK(P)          uses your own parameters
%
%   Returns a struct:
%     T.M         the PLANNING map for a point-sized planner:
%                 0 = free, 1 = blocked, walls grown by P.inflate.
%                 Row 1 is the TOP of the track (largest y), column 1 is
%                 the left edge (x = 0) -- the same way MATLAB shows an
%                 image, and the same way PLOT_GRID draws it.
%     T.Mraw      the same cells WITHOUT the inflation, for drawing
%     T.Mfine     the REAL walls at 1 cm. This is what decides whether
%                 the car has crashed.
%     T.Msafe     T.Mfine with P.safety added. This is what the pose
%                 planner is allowed to drive through.
%     T.cellSize  metres per cell of T.M
%     T.fineSize  metres per cell of T.Mfine and T.Msafe (0.01)
%     T.R, T.C    size of T.M        T.Rf, T.Cf  size of T.Mfine
%     T.start     [x y theta] start pose, in metres
%     T.s         start CELL of T.M (linear index)
%     T.cp        checkpoint cells of T.M, in lap order
%     T.P         the parameters used
%
%   WHY THREE MAPS AND NOT ONE
%
%   They answer three different questions and they are allowed to have
%   different answers.
%
%   T.M      "roughly, where may a point go?"  5 cm is plenty, and a
%            coarse map is what keeps the search fast.
%   T.Msafe  "may the CAR stand here?"  Checked against the car's real
%            rectangle, so the map itself must be sharp -- and with a
%            few centimetres of margin, because a planned route that
%            touches a wall leaves the controller no room at all.
%   T.Mfine  "has the car hit something?"  The truth, no margin. If the
%            crash test used the 5 cm map it would be wrong by up to
%            5 cm, and the car is 10.5 cm wide -- half the car.
%
%   A cell counts as BLOCKED if ANY pixel inside it is blocked. Never the
%   majority, never the average: a wall thinner than a cell must not
%   disappear, or the planner routes the car straight through it.
%
%   WHY THE WALLS OF T.M GROW
%   Chapters 01 to 08 treat the car as a POINT hopping from cell to cell.
%   A point passes 1 cm from a wall; a 22 by 10.5 cm car does not. Rather
%   than teach five algorithms about the car's shape, the shape is added
%   to the WALLS, once, here. That trick is called CONFIGURATION SPACE.
%   It works for the width. It does NOT work for the length -- which is
%   exactly what chapter 08 is about.
%
%   Only base MATLAB is used -- no Image Processing, Robotics or
%   Navigation Toolbox. The original createMapFromPic.m needs all three.
%
%   See also CC_PARAMS, CC_WORLD2GRID, CC_CAR_MODEL, CC_PLOT_TRACK.

if nargin < 1 || isempty(P)
    P = cc_params();
end

% ---- 1) the picture --------------------------------------------------
here    = fileparts(fileparts(mfilename('fullpath')));   % .../MATLAB
imgFile = fullfile(here, 'map', P.trackImage);
if ~exist(imgFile, 'file')
    error('cc_track:image', ...
        ['Cannot find the track picture at\n   %s\n' ...
         'Check P.track and P.trackImage. track.png belongs to the\n' ...
         'CrazyCar simulator; track_oval.png is made by CC_MAKE_OVAL.'], ...
        imgFile);
end

img = imread(imgFile);
if size(img, 3) == 3
    % Grey value by hand, so no Image Processing Toolbox is needed.
    grey = 0.2989 * double(img(:,:,1)) + ...
           0.5870 * double(img(:,:,2)) + ...
           0.1140 * double(img(:,:,3));
else
    grey = double(img);
end
blockedPx = grey < 128;    % dark = wall. createMapFromPic.m compares a
                           % 0..255 image against 0.5, so it only ever
                           % finds pixels that are EXACTLY black.

% ---- 2) the three resolutions ----------------------------------------
cs = P.cellSize;
C  = round(P.worldX / cs);
R  = round(P.worldY / cs);
Mraw = local_coarsen(blockedPx, R, C);

fineSize = 0.01;
Rf = round(P.worldY / fineSize);
Cf = round(P.worldX / fineSize);
Mfine = local_coarsen(blockedPx, Rf, Cf);

% ---- 3) grow the walls -----------------------------------------------
M     = local_grow(Mraw,  P.inflate, cs);
Msafe = local_grow(Mfine, P.safety,  fineSize);

T.M        = double(M);
T.Mraw     = double(Mraw);
T.Mfine    = double(Mfine);
T.Msafe    = double(Msafe);
T.cellSize = cs;
T.fineSize = fineSize;
T.R        = R;   T.C  = C;
T.Rf       = Rf;  T.Cf = Cf;
T.start    = P.start;
T.P        = P;

% ---- the cells a point planner needs ---------------------------------
T.s = cc_world2grid(P.start(1), P.start(2), T);
if T.M(T.s) ~= 0
    error('cc_track:start', ...
        ['The start pose (%.2f, %.2f) is inside an inflated wall.\n' ...
         'Reduce P.inflate or P.cellSize.'], P.start(1), P.start(2));
end

T.cp = zeros(size(P.checkpoints, 1), 1);
for q = 1:numel(T.cp)
    T.cp(q) = cc_world2grid(P.checkpoints(q,1), P.checkpoints(q,2), T);
    if T.M(T.cp(q)) ~= 0
        error('cc_track:checkpoint', ...
            'Checkpoint %d at (%.2f, %.2f) is inside an inflated wall.', ...
            q, P.checkpoints(q,1), P.checkpoints(q,2));
    end
end
end

% -----------------------------------------------------------------------
function M = local_coarsen(px, R, C)
%LOCAL_COARSEN  Group pixels into cells. A cell is blocked if ANY pixel is.
%
%   Done by labelling each pixel row and column with the cell it belongs
%   to, then marking the cell of every blocked pixel. One pass over the
%   blocked pixels, and no loop over the 192000 cells of the 1 cm map.
[Hp, Wp] = size(px);
rowEdge = round(linspace(0, Hp, R + 1));
colEdge = round(linspace(0, Wp, C + 1));

rowOf = zeros(Hp, 1);
for i = 1:R
    rowOf(rowEdge(i)+1 : rowEdge(i+1)) = i;
end
colOf = zeros(Wp, 1);
for j = 1:C
    colOf(colEdge(j)+1 : colEdge(j+1)) = j;
end

[pr, pc] = find(px);
M = false(R, C);
if ~isempty(pr)
    M(sub2ind([R C], rowOf(pr), colOf(pc))) = true;
end
end

% -----------------------------------------------------------------------
function M = local_grow(M0, radius, cellSize)
%LOCAL_GROW  Grow every wall by `radius` metres, in a disc, not a square.
if radius <= 0
    M = M0;
    return
end
k = ceil(radius / cellSize);
[dr, dc] = meshgrid(-k:k, -k:k);
keep = (dr.^2 + dc.^2) * cellSize^2 <= radius^2 + eps;
dr = dr(keep);
dc = dc(keep);

[R, C]   = size(M0);
[wr, wc] = find(M0);
M = M0;
for q = 1:numel(dr)
    rr = wr + dr(q);
    cc = wc + dc(q);
    ok = rr >= 1 & rr <= R & cc >= 1 & cc <= C;
    M(sub2ind([R C], rr(ok), cc(ok))) = true;
end
end
