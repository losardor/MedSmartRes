function  [] = TestDoc(Id)
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
[displ, lostl] = DistributePatients_capHard(n2, nDoc, 11, averages, 3, 0.15)

