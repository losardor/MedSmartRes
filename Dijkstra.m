function [ dist ] = Dijkstra( A )
%DIJKSTRA Calculate the minimum distance using DijKstra's Algorithm
%   Description: Given the weighted adjacency matrix of a graph this
%   function computes the sortest path from each node to all other nodes.

L = numel(A(1,:));
for k = 1:L
    minDis = Inf(L,1);
    S = k;
    T = 1:L;
    T(T==k) = [];
    dist(A(k,:),k)=A(k,:);
    while any(dist(:,k)~=inf)
        [~,j] = min(dist(:,k));
        T(T==j)= [];
        S = [S,j];
        if isempty(T)
            break
        end
        for i = T
            if f(i) > f(j)+A(j,i)
                f(i) = f(j)+A(j,i);
                J(i) = j;
            end
        end
    end
        
end

