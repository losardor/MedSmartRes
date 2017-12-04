function [ target ] = makeTargetMatrix( Adj )
%UNTITLED Comuputes the target matix
%   The target matrix is a matrix with elements that are nodes on a network
%   Each row contains possible neighbours in a number proportional to the
%   strength of the link to said neighbours

numberDocs = numel(Adj(:,1));
target = zeros(numberDocs, numberDocs);

for i = 1:numberDocs
    K = 1;
    if any(Adj(i,:))
        neighs = find(Adj(i,:));
        probs_nr = Adj(i,neighs)*numberDocs/sum(Adj(i,neighs));
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

