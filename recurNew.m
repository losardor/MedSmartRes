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
i = 47;
A = Adj( distnum == i, distnum == i );
number = numel(peterID(distnum == i));
docs = peterID(distnum == i);
syst = System(peterID(distnum == i), MP(distnum == i), SP(distnum == i), full(A), 'Sigma', 1);
for k = 1:numel(docs)-1
    for jk = 1:100
    failedNodes = randsample(1:numel(docs), k);
    [disp(k, jk),lost(k,jk)] = SelfAvoiding(syst, [failedNodes],100);
    end
end