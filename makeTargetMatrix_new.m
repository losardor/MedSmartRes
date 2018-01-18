function [ target ] = makeTargetMatrix_new( Adj)
%UNTITLED Comuputes the target matix
%   The target matrix is a matrix with elements that are nodes on a network
%   Each row contains possible neighbours in a number proportional to the
%   strength of the link to said neighbours


numberDocs = numel(Adj(:,1));
probs_ur = struct();
neighs = struct();
big = 0;
for i = 1:numberDocs

    if any(Adj(i,:))
        neighs(i).vals = find(Adj(i,:));
        %create a vector with norm 1 (the sum) equal to the width of the
        %matrix. This will determine how many entries will contain a
        %certain target index
        probs_nr = Adj(i,neighs(i).vals)*numberDocs/sum(Adj(i,neighs(i).vals));
        probs_ur(i).vals = ceil(probs_nr);
        if big < sum(probs_ur(i).vals)
            big = sum(probs_ur(i).vals);
        end
    end
end
target = zeros(numberDocs, big);
for i = 1:numberDocs
    K=1;
    if any(Adj(i,:))
        for k = 1:numel(probs_ur(i).vals)
            target(i,K:(K+probs_ur(i).vals(k)-1)) = neighs(i).vals(k);
            K = K + probs_ur(i).vals(k);
        end
        target(target(i,:) == 0)=randsample(target(target(i,:)>0),nnz(~target(i,:)), true);
    else
        target(i,:) = 0;
    end
end
