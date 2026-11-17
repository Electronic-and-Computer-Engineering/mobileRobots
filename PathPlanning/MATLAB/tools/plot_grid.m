function plot_grid(M, varargin)
%PLOT_GRID  Draw an occupancy grid, with a search and a path on top.
%
%   PLOT_GRID(M) draws the grid: free cells white, obstacles dark.
%
%   PLOT_GRID(M, 'Name', value, ...) understands:
%       'Expanded'   cells the search took out of OPEN (linear indices),
%                    drawn in cyan; later ones get stronger colour
%       'Path'       cells of the final path, drawn as a line
%       'Start'      start cell (linear index), drawn as a circle
%       'Goal'       goal cell  (linear index), drawn as a square
%       'Mark'       cells to outline, e.g. the neighbours of one cell
%       'Values'     one number per cell, printed into the cells; pass a
%                    matrix the size of M, or a vector of numel(M)
%       'Format'     printf format for those numbers (default '%g')
%       'Title'      a title
%       'Fade'       true (default): early expansions lighter than late
%
%   COLOURING THE EXPANDED CELLS IS THE WHOLE POINT. You see at a glance
%   whether a search spread out as a circle around the start or ran as a
%   narrow corridor towards the goal. Two searches can return the very
%   same path and still look completely different here.
%
%   Example:
%       [p, c, st] = astar_grid(M, s, t);
%       plot_grid(M, 'Expanded', st.order, 'Path', p, ...
%                    'Start', s, 'Goal', t, 'Title', 'A*');
%
%   See also GRID_NEIGHBORS, PLOT_GRAPH, MAZE_RANDOM.

p = inputParser();
p.addParameter('Expanded', []);
p.addParameter('Path',     []);
p.addParameter('Start',    []);
p.addParameter('Goal',     []);
p.addParameter('Mark',     []);
p.addParameter('Values',   []);
p.addParameter('Format',   '%g');
p.addParameter('Title',    '');
p.addParameter('Fade',     true);
p.parse(varargin{:});
a = p.Results;

[R, C] = size(M);

% Build the RGB image channel by channel. More robust than juggling
% colormaps, and every colour stays readable in the source.
chR = ones(R, C);
chG = ones(R, C);
chB = ones(R, C);

% 1) expanded cells in cyan, later expansions stronger
if ~isempty(a.Expanded)
    ex = a.Expanded(:).';
    ne = numel(ex);
    for k = 1:ne
        if a.Fade && ne > 1
            s = 0.25 + 0.75 * (k - 1) / (ne - 1);
        else
            s = 1;
        end
        i = ex(k);
        chR(i) = 1 - 0.96 * s;
        chG(i) = 1 - 0.36 * s;
        chB(i) = 1 - 0.23 * s;
    end
end

% 2) obstacles last, so nothing covers them
obst = (M ~= 0);
chR(obst) = 0.063;
chG(obst) = 0.129;
chB(obst) = 0.169;

image(cat(3, chR, chG, chB));
axis equal tight
set(gca, 'YDir', 'reverse', 'XTick', [], 'YTick', []);
hold on

% thin grid lines only on small maps, otherwise it turns to mush
if R <= 40 && C <= 40
    for r = 0.5:1:(R + 0.5)
        plot([0.5, C + 0.5], [r, r], 'Color', [0.78 0.82 0.85], 'LineWidth', 0.5);
    end
    for c = 0.5:1:(C + 0.5)
        plot([c, c], [0.5, R + 0.5], 'Color', [0.78 0.82 0.85], 'LineWidth', 0.5);
    end
end

% numbers inside the cells
if ~isempty(a.Values)
    V = a.Values;
    if isvector(V) && numel(V) == R * C
        V = reshape(V, R, C);
    end
    for r = 1:R
        for c = 1:C
            if M(r, c) ~= 0
                continue
            end
            txt = sprintf(a.Format, V(r, c));
            if ~isempty(a.Expanded) && any(a.Expanded(:) == sub2ind([R C], r, c))
                col = [1 1 1];
            else
                col = [0.15 0.18 0.20];
            end
            text(c, r, txt, 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'FontSize', 9, 'Color', col);
        end
    end
end

% outlined cells, e.g. the neighbours of one cell
if ~isempty(a.Mark)
    [mr, mc] = ind2sub([R, C], a.Mark(:).');
    for k = 1:numel(mr)
        rectangle('Position', [mc(k) - 0.5, mr(k) - 0.5, 1, 1], ...
            'EdgeColor', [0.91 0.40 0.24], 'LineWidth', 2.5);
    end
end

% the path, as a line through the cell centres
if ~isempty(a.Path)
    [pr, pc] = ind2sub([R, C], a.Path(:).');
    plot(pc, pr, '-', 'Color', [0.91 0.40 0.24], 'LineWidth', 2.5);
end

if ~isempty(a.Start)
    [sr, sc] = ind2sub([R, C], a.Start);
    plot(sc, sr, 'o', 'MarkerSize', 9, 'LineWidth', 2, ...
        'MarkerEdgeColor', [0.04 0.13 0.17], 'MarkerFaceColor', [1 1 1]);
end
if ~isempty(a.Goal)
    [gr, gc] = ind2sub([R, C], a.Goal);
    plot(gc, gr, 's', 'MarkerSize', 10, 'LineWidth', 2, ...
        'MarkerEdgeColor', [0.75 0.29 0.12], 'MarkerFaceColor', [0.91 0.40 0.24]);
end

if ~isempty(a.Title)
    title(a.Title, 'FontWeight', 'normal');
end
hold off
end
