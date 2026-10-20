function plot_graph(G, varargin)
%PLOT_GRAPH  Draw the example graph, with a search and a path on top.
%
%   PLOT_GRAPH(G) draws the nodes of G, the edges between them, and what
%   each edge costs.
%
%   PLOT_GRAPH(G, 'Name', value, ...) understands:
%       'Expanded'   nodes the search took out of OPEN, in order; they
%                    are filled in and numbered 1, 2, 3 ...
%       'Path'       nodes of the final path, drawn as a thick line
%       'Values'     one number per node, printed under it (g, h, f ...)
%       'Label'      what that number is called, e.g. 'g'
%       'Title'      a title
%
%   This is the graph version of PLOT_GRID. Use it to see the same thing
%   on six nodes that you later see on a map with thousands of cells:
%   which nodes a search actually touched, and in which order.
%
%   Example:
%       G = graph_example();
%       [p, c, st] = dijkstra_graph(G.W, G.s, G.t);
%       plot_graph(G, 'Expanded', st.order, 'Path', p, 'Title', 'Dijkstra');
%
%   See also GRAPH_EXAMPLE, PLOT_GRID.

p = inputParser();
p.addParameter('Expanded', []);
p.addParameter('Path',     []);
p.addParameter('Values',   []);
p.addParameter('Label',    '');
p.addParameter('Title',    '');
p.parse(varargin{:});
a = p.Results;

xy = G.xy;
n  = size(xy, 1);

TEAL = [0.29 0.64 0.69];
DARK = [0.04 0.36 0.46];
WARN = [0.75 0.29 0.12];
GREY = [0.55 0.55 0.55];

cla
hold on
axis equal
axis off

% 1) edges, with their cost in the middle
for u = 1:n
    for v = u+1:n
        if G.W(u, v) <= 0
            continue
        end
        plot(xy([u v], 1), xy([u v], 2), '-', 'Color', [0.72 0.76 0.78], ...
            'LineWidth', 1.5);
        mx = mean(xy([u v], 1));
        my = mean(xy([u v], 2));
        text(mx, my, sprintf(' %g ', G.W(u, v)), 'FontSize', 9, ...
            'Color', GREY, 'HorizontalAlignment', 'center', ...
            'BackgroundColor', [1 1 1]);
    end
end

% 2) the path on top, thick
if ~isempty(a.Path) && numel(a.Path) > 1
    plot(xy(a.Path, 1), xy(a.Path, 2), '-', 'Color', WARN, 'LineWidth', 3);
end

% 3) the nodes
ex = a.Expanded(:).';
for u = 1:n
    k = find(ex == u, 1);
    if isempty(k)
        face = [1 1 1];
        tcol = [0.1 0.1 0.1];
    else
        face = TEAL;
        tcol = [1 1 1];
    end
    plot(xy(u, 1), xy(u, 2), 'o', 'MarkerSize', 26, 'LineWidth', 2, ...
        'MarkerEdgeColor', DARK, 'MarkerFaceColor', face);
    text(xy(u, 1), xy(u, 2), G.names{u}, 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', 'FontSize', 12, 'FontWeight', 'bold', ...
        'Color', tcol);

    % the order it was expanded in, as a small number above the node
    if ~isempty(k)
        text(xy(u, 1), xy(u, 2) + 0.42, sprintf('%d', k), ...
            'HorizontalAlignment', 'center', 'FontSize', 10, ...
            'FontWeight', 'bold', 'Color', DARK);
    end

    % a value under the node
    if ~isempty(a.Values)
        val = a.Values(u);
        if isinf(val)
            txt = 'inf';
        else
            txt = sprintf('%g', val);
        end
        if ~isempty(a.Label)
            txt = sprintf('%s=%s', a.Label, txt);
        end
        text(xy(u, 1), xy(u, 2) - 0.45, txt, ...
            'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', DARK);
    end
end

% 4) start and goal get a word, so nobody has to guess
text(xy(G.s, 1), xy(G.s, 2) + 0.72, 'START', 'HorizontalAlignment', 'center', ...
    'FontSize', 9, 'FontWeight', 'bold', 'Color', DARK);
text(xy(G.t, 1), xy(G.t, 2) + 0.72, 'GOAL', 'HorizontalAlignment', 'center', ...
    'FontSize', 9, 'FontWeight', 'bold', 'Color', WARN);

if ~isempty(a.Title)
    title(a.Title, 'FontWeight', 'normal');
end
xlim([min(xy(:,1)) - 1, max(xy(:,1)) + 1]);
ylim([min(xy(:,2)) - 1, max(xy(:,2)) + 1]);
hold off
end
