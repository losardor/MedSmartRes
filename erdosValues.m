function [ avgDegree, clusteringCoeff ] = erdosValues( Adj )
%ERDOSVALUES calculates average degree and clustering coefficient for a
%erdos-renyi network of probability p=present-links/possible-links.
%   The calculation is performed on the undirected and unweighted version
%   of the matrix

N=numel(Adj(1,:));
Adj=logical(Adj);
Adj=Adj|Adj';
Adj=Adj-diag(diag(Adj));
links=sum(sum(Adj))/2;
p=links/(N*(N-1));
avgDegree=(N-1)*p;
clusteringCoeff=p;
end

