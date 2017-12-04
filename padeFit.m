load('GDA_B.mat', 'vID')
load('GDA_B.mat', 'vFG')
load('GDA_B.mat', 'vBez')
doc_map=ismember(vFG,[1,7,8]);
peterID = 1:numel(vID);
peterID = peterID(doc_map)';
param = table();
param.peterID = peterID;
param.p1 = zeros(size(peterID));
param.p2 = zeros(size(peterID));
param.q1 = zeros(size(peterID));
warning off
for i = peterID(1:10)'
    [val, er] = RelaxationCurve(i);
    fict = fit(linspace(1, numel(val), numel(val))', val', 'rat11');
    param.p1(param.peterID == i) = fict.p1;
    param.p2(param.peterID == i) = fict.p2;
    param.q1(param.peterID == i) = fict.q1;
end
warning on
    