function [ ] = distNet(  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

load('Adj.mat')    
load('GDA_B.mat', 'vID')
load('GDA_B.mat', 'vFG')
load('GDA_B.mat', 'vBez')
x=cellfun(@str2double,vBez);
doc_map=ismember(vFG,[1,7,8]);
doctor_db = table();
doctor_db.DataID = vID(doc_map);
peterID = 1:numel(vID);
doctor_db.peterID = peterID(doc_map)';
Adj = Adj(doctor_db.peterID, doctor_db.peterID);
doctor_db.mean_patients = zeros(size(doctor_db.peterID));
doctor_db.patient_std = zeros(size(doctor_db.peterID));
doctor_db.distnum = x(doc_map);
%think of way to assign this
doctor_db.inDegree = zeros(size(doctor_db.peterID));
doctor_db.outDegree = zeros(size(doctor_db.peterID));
doctor_db.rescaledOutDegree = zeros(size(doctor_db.peterID));
doctor_db.rescaledInDegree= zeros(size(doctor_db.peterID));
doctor_db.clusteringCoeff = zeros(size(doctor_db.peterID));
doctor_db.betweennes = zeros(size(doctor_db.peterID));
doctor_db.mean_disp = zeros(size(doctor_db.peterID));
doctor_db.mean_losts = zeros(size(doctor_db.peterID));
doctor_db.avoidable = zeros(size(doctor_db.peterID));
doctor_db.adverse = zeros(size(doctor_db.peterID));
doctor_db.complications = zeros(size(doctor_db.peterID));

load('patientNums.mat')
doctor_db.mean_patients = MP;
doctor_db.patient_std = SP;

for i = 1:121
    A = Adj( doctor_db.distnum == i, doctor_db.distnum == i );
    %Threshold cut of
    %A(A<10) = 0;
    [avgDegree, ~]=erdosValues(double(A>0));
    addpath('/mnt/Tank/Matlbo_non_root/matlab_bgl/');
    indeg = sum(logical(A));
    outdeg = sum(logical(A), 2);
    doctor_db.clusteringCoeff(doctor_db.distnum == i) = clustering_coefficients((double(A>0)));
    doctor_db.betweennes(doctor_db.distnum == i) = betweenness_centrality((double(A>0)));
    doctor_db.inDegree(doctor_db.distnum == i) = indeg';
    doctor_db.rescaledInDegree(doctor_db.distnum == i) = 2*indeg'/avgDegree;
    doctor_db.outDegree(doctor_db.distnum == i) = outdeg;
    doctor_db.rescaledOutDegree(doctor_db.distnum == i) = 2*outdeg/avgDegree;
    number = numel(doctor_db.peterID(doctor_db.distnum == i));
    docs = doctor_db.peterID(doctor_db.distnum == i);
    n2 = network(number, doctor_db.mean_patients(doctor_db.distnum == i), doctor_db.patient_std(doctor_db.distnum == i), full(A));
    averages = 100;
    for j = 1:number
        [displ, lostl] = DistributePatients(n2, j, 11, averages);
        doctor_db.mean_disp(doctor_db.peterID == docs(j)) = displ;
        doctor_db.mean_losts(doctor_db.peterID == docs(j)) = lostl;
        save('doc_db.mat', 'doctor_db');
    end
end

end

