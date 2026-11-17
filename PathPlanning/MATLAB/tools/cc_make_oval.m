function cc_make_oval(outFile)
%CC_MAKE_OVAL  Draw the practice track, so you can draw your own.
%
%   cc_make_oval                      rewrites map/track_oval.png
%   cc_make_oval('map/mine.png')      somewhere else
%
%   The practice track is a stadium: two straights 1.60 m long joined by
%   two half circles, with the lane 0.50 m wide and its centreline
%   0.50 m from the circle centres.
%
%   WHY THOSE NUMBERS
%   The car's tightest possible radius is 0.303 m (see DEMO_CC_VEHICLE).
%   A centreline radius of 0.50 m is comfortably above it, so every
%   corner here can be driven at full lock with room to spare. Nothing
%   about this track is meant to be hard: it is for getting your code
%   working before the real track starts having opinions.
%
%   MAKING YOUR OWN TRACK
%   Any black-and-white picture works. Black is wall, white is free,
%   1000 pixels to the metre. Draw one in any paint program, save it
%   into map/, and tell CC_PARAMS about it:
%
%       P = cc_params('trackImage', 'mine.png', ...
%                     'worldX', 4.0, 'worldY', 2.5, ...
%                     'start', [0.5 0.5 0], ...
%                     'checkpoints', [3.5 0.5; 3.5 2.0; 0.5 2.0]);
%       T = cc_track(P);
%       figure; cc_plot_track(T, 'Safety', true)
%
%   Check the picture before you plan on it: CC_TRACK will refuse a
%   start or a checkpoint that lands inside a wall, and a lane narrower
%   than about 0.30 m leaves the car nowhere to go.
%
%   See also CC_PARAMS, CC_TRACK, CC_PLOT_TRACK.

if nargin < 1 || isempty(outFile)
    here    = fileparts(fileparts(mfilename('fullpath')));   % .../MATLAB
    outFile = fullfile(here, 'map', 'track_oval.png');
end

% ---- the shape, in metres --------------------------------------------
worldX = 3.20;
worldY = 2.00;
cx1    = 0.80;    % centre of the left half circle
cx2    = 2.40;    % centre of the right half circle
cy     = 1.00;
rIn    = 0.25;    % inner edge of the lane, from those centres
rOut   = 0.75;    % outer edge

% ---- one pixel per millimetre ----------------------------------------
W = round(worldX * 1000);
H = round(worldY * 1000);

x = ((1:W) - 0.5) / 1000;                 % pixel centres, in metres
y = ((1:H) - 0.5) / 1000;
[X, Yrow] = meshgrid(x, y);
Y = worldY - Yrow;                        % row 1 is the TOP of the picture

% Distance to the centreline of a stadium: clamp x into the straight part
% and measure from there. Two lines, and it is exact.
xc = min(max(X, cx1), cx2);
d  = hypot(X - xc, Y - cy);

free = (d >= rIn) & (d <= rOut);

imwrite(uint8(255 * free), outFile);

fprintf('\n  wrote %s\n', outFile);
fprintf('    %d x %d pixels = %.2f m x %.2f m at 1000 px/m\n', W, H, worldX, worldY);
fprintf('    lane %.2f m wide, centreline radius %.2f m in the corners\n', ...
    rOut - rIn, (rIn + rOut)/2);
fprintf('    lap along the centreline: %.3f m\n\n', ...
    2*(cx2 - cx1) + 2*pi*(rIn + rOut)/2);
end
