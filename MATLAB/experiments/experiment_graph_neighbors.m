% EXPERIMENT_GRAPH_NEIGHBORS — What can I reach directly from node A?
% TASK: Run and compare [nb,w] with the graph drawing.
clearvars
G=graph_example();
u=1;                                 % TASK: Change to 5 (E).
[nb,w]=graph_neighbors(G.W,u);
fprintf('Neighbours [node, edge cost] from node %d:\n',u);
disp([nb(:) w(:)]);
figure; plot_graph(G,'Title','Graph with edges and costs');

% TASK: Change the A-D cost in a COPY of the graph, in BOTH directions.
W2=G.W;
W2(1,4)=2;
W2(4,1)=2;
[nb2,w2]=graph_neighbors(W2,1);
fprintf('After reducing A-D cost:\n'); disp([nb2(:) w2(:)]);
% CHECKPOINT: Does changing an edge weight change its neighbour ID?
