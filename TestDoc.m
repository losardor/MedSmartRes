function  [displ, lostl, closness, betweenness] = TestDoc(Id, cap)
%TESTDOC tests the dynamics on a single doctor
%   Just give the Id (peterID) of the doctor to test
load('Adj.mat')    
load('GDA_B.mat', 'vID')
load('GDA_B.mat', 'vFG')
load('GDA_B.mat', 'vBez')
x=cellfun(@str2double,vBez);
doc_map=ismember(vFG,[1,7,8]);
DataID = vID(doc_map);
peterID = 1:numel(vID);
peterID = peterID(doc_map)';
Adj = Adj(peterID, peterID);
distnum = x(doc_map);
load('patientNums.mat')
i = distnum(peterID == Id);
A = Adj( distnum == i, distnum == i );
number = numel(peterID(distnum == i));
docs = peterID(distnum == i);
n2 = network(number, MP(distnum == i), SP(distnum == i), full(A));
averages = 100;
nDoc = find(docs == Id);
A = n2.matrix;
A = A - diag(diag(A));
A = bsxfun(@rdivide,A',sum(A, 2)')';
A(isnan(A)) = 0;
B=1-A;
A(A~=0) = B(A~=0);
A = sparse(A);
addpath('/mnt/Tank/Matlbo_non_root/matlab_bgl/');
[d,~]=shortest_paths(A, nDoc);
d = d(d~=0 & ~isinf(d));
if isempty(d)
    closness = 0;
    betweenness = 0;
else
    closness = mean(1/d);
    bc = betweenness_centrality(A);
    betweenness = bc(nDoc);
end
displ = 0;
lostl = 0;

%[displ, lostl] = DistributePatients_capHard(n2, nDoc, 11, averages, 3, 0.15)
%[displ, lostl] = DistPat_capHardFix(n2, nDoc, 11, averages, cap, 0.15);

