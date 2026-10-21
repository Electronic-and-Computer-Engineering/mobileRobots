% EXPERIMENT_SEARCH_PATTERN — Recognise the shared search loop.
% TASK: First run demo_pattern, then inspect this small variant.
% It checks reachability; it does NOT yet reconstruct a goal path.
clearvars
M=zeros(3,4); M(2,2)=1;
s=sub2ind(size(M),1,1);
seen=false(numel(M),1);
OPEN=open_new('fifo');
seen(s)=true;
OPEN=open_push(OPEN,s);
order=[];
while ~open_isempty(OPEN)
    [OPEN,u]=open_pop(OPEN);      % CURRENT node to examine.
    order(end+1)=u; %#ok<AGROW>
    [nb,~]=grid_neighbors(M,u,4); % Valid neighbours from the map.
    for k=1:numel(nb)
        v=nb(k);
        if seen(v), continue; end
        seen(v)=true;            % Mark when discovered.
        OPEN=open_push(OPEN,v);  % Place new nodes into OPEN.
    end
end
fprintf('Expanded node IDs: '); disp(order);
fprintf('Reached %d of %d free cells\n',nnz(seen),nnz(M==0));
% TASK: Find (a) node extraction (b) neighbour query (c) duplicate check.
% OPTIONAL TASK: Change FIFO to LIFO. Does reachability change? Does order?
% CHECKPOINT: What must be added to find and return a start-to-goal path?
