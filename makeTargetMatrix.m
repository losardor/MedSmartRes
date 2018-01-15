function [ target ] = makeTargetMatrix( Adj, prec )
%UNTITLED Comuputes the target matix
%   The target matrix is a matrix with elements that are nodes on a network
%   Each row contains possible neighbours in a number proportional to the
%   strength of the link to said neighbours
%   The prec input must be and integer and if 1 the target matrix is square
%   otherwise it will be N x prec*N.

numberDocs = numel(Adj(:,1));
target = zeros(numberDocs, prec*numberDocs);

for i = 1:numberDocs
    K = 1;
    if any(Adj(i,:))
        neighs = find(Adj(i,:));
        %create a vector with norm 1 (the sum) equal to the width of the
        %matrix. This will determine how many entries will contain a
        %certain target index
        probs_nr = Adj(i,neighs)*2*numberDocs/sum(Adj(i,neighs));
        probs_r = floor(probs_nr);
        differ = probs_nr-probs_r;
        [~, idx] = sort(differ, 'descend');
        for j = 1:round(sum(differ))
            probs_r(idx(int64(j))) = probs_r(idx(int64(j))) +1;
        end
        for k = 1:numel(probs_r)
            target(i,K:(K+probs_r(k)-1)) = neighs(k);
            K = K + probs_r(k);
        end
    else
        target(i,:) = 0;
    end

end

