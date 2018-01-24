% Using the hard version
function [ lost] = Recursive( i , alpha, capacity)
%RELAXATIONcURVE computes the number of patients that are lost in a
%district as a function of the number of unavailable doctors for a large
%number of removal combinations
%   Detailed explanation goes here
set(0, 'DefaultAxesFontSize',20, 'DefaultAxesLineWidth', 2.0);
set(0, 'DefaultTextFontSize',20, 'DefaultTextLineWidth',1.5);
set(0, 'DefaultLineLineWidth',1.5); 
%load data
load('Adj.mat', 'Adj') 
load('GDA_B.mat', 'vID')
load('GDA_B.mat', 'vFG')
load('GDA_B.mat', 'vBez')
load('patientNums.mat')

%construct vector with district for each doctor
x=cellfun(@str2double,vBez);
%construct logical vector masking out non primary HCPs
doc_map=ismember(vFG,[1,7,8]);
%DataID = vID(doc_map);
%Creat list of primary HCPs and their peterID
peterID = 1:numel(vID);
peterID = peterID(doc_map)';
%Limit the transport matrix to primary HCPs
Adj = Adj(peterID, peterID);
%List district of primary HCPs
distnum = x(doc_map);
%Limit matrix to that district
A = Adj( distnum == i, distnum == i );
%Assign all doctors their patient distribution
mean_patients = MP(distnum == i);
patient_std = SP(distnum == i);
%Compute number of HCPs in district
number = numel(peterID(distnum == i));
%Compute their IDs
docs = peterID(distnum == i);
%Create the network object on which the simulation runs
n = network(number, mean_patients, patient_std, full(A));
for k = 1:number-1
    for jk = 1:100
        failedNodes = randsample(1:number, k);
        [~, lost(k, jk)] = DistributePatients_capHard(n, failedNodes, 11, 5, capacity, alpha);
    end
end
end

