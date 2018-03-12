
function [ ] = distNetSA(  )
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
doctor_db.inDegree = zeros(size(doctor_db.peterID));
doctor_db.outDegree = zeros(size(doctor_db.peterID));
doctor_db.inweight = zeros(size(doctor_db.peterID));
doctor_db.outweight = zeros(size(doctor_db.peterID));
doctor_db.rescaledOutDegree = zeros(size(doctor_db.peterID));
doctor_db.rescaledInDegree= zeros(size(doctor_db.peterID));
doctor_db.clusteringCoeff = zeros(size(doctor_db.peterID));
doctor_db.betweennes = zeros(size(doctor_db.peterID));
doctor_db.WeightedBetweennes = zeros(size(doctor_db.peterID));
doctor_db.closeness = zeros(size(doctor_db.peterID));
doctor_db.mean_disp = zeros(size(doctor_db.peterID));
doctor_db.mean_losts = zeros(size(doctor_db.peterID));

load('patientNums.mat')
doctor_db.mean_patients = MP;
doctor_db.patient_std = SP;

for i = 1:121
    i
    A = Adj( doctor_db.distnum == i, doctor_db.distnum == i );
    [avgDegree, ~]=erdosValues(double(A>0));
    addpath('/mnt/Tank/Matlbo_non_root/matlab_bgl/');
    indeg = sum(logical(A));
    outdeg = sum(logical(A), 2);
    doctor_db.clusteringCoeff(doctor_db.distnum == i) = clustering_coefficients((double(A>0)));
    doctor_db.betweennes(doctor_db.distnum == i) = betweenness_centrality((double(A>0)));
    A1 = A - diag(diag(A));
    A1 = bsxfun(@rdivide,A1',sum(A1, 2)')';
    A1(isnan(A1)) = 0;
    B=1-A1;
    A1(A1~=0) = B(A1~=0);
    A1 = sparse(A1);
    doctor_db.WeightedBetweennes(doctor_db.distnum == i) = betweenness_centrality(A1);
    doctor_db.inDegree(doctor_db.distnum == i) = indeg';
    doctor_db.rescaledInDegree(doctor_db.distnum == i) = 2*indeg'/avgDegree;
    doctor_db.outDegree(doctor_db.distnum == i) = outdeg;
    doctor_db.rescaledOutDegree(doctor_db.distnum == i) = 2*outdeg/avgDegree;
    doctor_db.inweight(doctor_db.distnum == i) = sum(A)';
    doctor_db.outweight(doctor_db.distnum == i) = sum(A,2);
    number = numel(doctor_db.peterID(doctor_db.distnum == i));
    docs = doctor_db.peterID(doctor_db.distnum == i);
    closeness = zeros(number, 1);
    for k=1:number
        [d,~] = shortest_paths(A, k);
        d = d(d~=0 & ~isinf(d));
        if ~isempty(d)
            closeness(k) = mean(1/d);
        end
    end
    doctor_db.closeness(doctor_db.distnum == i) = closeness;
    
    averages = 100;
    syst = System(peterID(doctor_db.distnum == i), MP(doctor_db.distnum == i), SP(doctor_db.distnum == i), full(A), 'Sigma', 3);
    for j = 1:numel(docs)
        [displ, lostl] = NNSelfAvoiding(syst, j, averages, 11, 0.15);
        doctor_db.mean_disp(doctor_db.peterID == docs(j)) = displ;
        doctor_db.mean_losts(doctor_db.peterID == docs(j)) = lostl;
    end
    save('doc_dbSA.mat', 'doctor_db');
end

end

