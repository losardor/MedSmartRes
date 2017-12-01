function [ Allotted, er ] = RelaxationCurve( ID )
%RELAXATIONcURVE computes the number of patients that have access to a HCP
%as a function of time
%   Detailed explanation goes here

%load data
load('/mnt/Tank/Matlab_work/Data/Adj.mat', 'Adj') 
load('/mnt/Tank/Matlab_work/Data/GDA_B.mat', 'vID')
load('/mnt/Tank/Matlab_work/Data/GDA_B.mat', 'vFG')
load('/mnt/Tank/Matlab_work/Data/GDA_B.mat', 'vBez')
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
%Create logical vector that selects the doctor to be removed
point = peterID == ID;
if ~ nnz(point) > 1
    error('multiple maches for given ID');
end
%Select distric of the doctor to be removed
i = distnum(point);
%Limit matrix to that district
A = Adj( distnum == i, distnum == i );
%Assign all doctors their patient distribution
mean_patients = MP(distnum == i);
patient_std = SP(distnum == i);
%add path where the scripts for the dynamics are contained
addpath('/mnt/Tank/Matlab_work/Cascades/No_capacity');
%Compute number of HCPs in district
number = numel(peterID(distnum == i));
%Compute their IDs
docs = peterID(distnum == i);
%Create the network object on which the simulation runs
n = network(number, mean_patients, patient_std, full(A));
averages = 100;
%Run the dynamics
[Allotted, er] = DistrubutePatients_AP(n, find(docs == ID, 1), 11, averages);

end

