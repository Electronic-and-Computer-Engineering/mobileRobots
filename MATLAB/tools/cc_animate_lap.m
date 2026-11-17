function cc_animate_lap(T, log, varargin)
%CC_ANIMATE_LAP  Watch the lap being driven.
%
%   CC_ANIMATE_LAP(T, log)
%   CC_ANIMATE_LAP(T, log, 'Speed', 2, 'Route', ref)
%
%   T      the track from CC_TRACK
%   log    the result of CC_SIMULATE
%
%   Options:
%     'Speed'  playback factor (1 = real time, 2 = twice as fast)
%     'Route'  the planned route to draw underneath
%     'Every'  draw every n-th step (default 1)
%
%   The title counts the seconds and shows the speed, so you can see
%   where the car brakes. Watch the body, not the line: the line goes
%   through corners that the body has to swing into.
%
%   See also CC_SIMULATE, CC_PLOT_TRACK.

q = inputParser();
q.addParameter('Speed', 2);
q.addParameter('Route', []);
q.addParameter('Every', 1);
q.parse(varargin{:});
o = q.Results;

P = log.P;

figure('Name', 'CrazyCar lap');
cc_plot_track(T, 'Route', o.Route, 'Title', 'CrazyCar lap');
hold on

trace = plot(NaN, NaN, '-', 'Color', [0.91 0.40 0.24], 'LineWidth', 2);
body  = plot(NaN, NaN, '-', 'Color', [0.06 0.24 0.33], 'LineWidth', 1.8);
nose  = plot(NaN, NaN, '-', 'Color', [0.91 0.40 0.24], 'LineWidth', 3);

for k = 1:o.Every:numel(log.t)
    st.x = log.x(k);  st.y = log.y(k);  st.theta = log.theta(k);
    out  = cc_car_outline(st, P);

    set(trace, 'XData', log.x(1:k), 'YData', log.y(1:k));
    set(body,  'XData', out(:,1),   'YData', out(:,2));
    set(nose,  'XData', out(1:2,1), 'YData', out(1:2,2));

    title(sprintf('t = %5.2f s    v = %4.2f m/s    steering = %+5.1f deg%s', ...
        log.t(k), log.v(k), log.delta(k), ...
        local_slip(log.slipping(k))));

    drawnow
    pause(o.Every * P.dt / max(o.Speed, 0.01));
end

if log.crashed
    plot(log.crashAt(1), log.crashAt(2), 'x', 'Color', [0.75 0.12 0.18], ...
        'MarkerSize', 18, 'LineWidth', 3);
    title(sprintf('CRASH at (%.2f, %.2f) after %.2f s', ...
        log.crashAt(1), log.crashAt(2), log.t(end)));
elseif log.finished
    title(sprintf('Lap completed in %.2f s', log.lapTime));
end
hold off
end

% -----------------------------------------------------------------------
function s = local_slip(tf)
if tf
    s = '    SLIDING';
else
    s = '';
end
end
