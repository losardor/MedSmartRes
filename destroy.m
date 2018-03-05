function seq = destroy(A, i, failedNodes)
if ismember(i, failedNodes)
    failedNodes(failedNodes == i) = [];
end
N = numel(A(1,:));
nodes = 1:N;
strt = nodes(i);
nodes(failedNodes) = [];
A(failedNodes,:) = [];
A(:,failedNodes) = [];
N = numel(A(1,:));
i = find(nodes == strt);
seq = [];
for k = 1:N-1
    seq(end+1) = nodes(i);
    nodes(i) = [];
    prob = A(i,:);
    prob(i) = [];
    if any(prob)
        j = randsample(numel(prob), 1, true, prob);
    else
        j = randsample(numel(nodes), 1);
    end
    A(i,:)=[];
    A(:,i)=[];
    i=j;
end
end