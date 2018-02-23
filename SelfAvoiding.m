function [ disp, lost ] = SelfAvoiding( System, failedSet, averages)
%SELFaVOIDING computes the number of lost patients and the mean number of
%steps each patient (whos original HCP is unavailable) necessary to find a
%new one. Patients diffuse along self avoiding random walks with
%teleportation
%   -The system is composed by a weighted directed edge list reppresented as
%   a matrix (-System.martix), a gaussian distribution of contacts for each HCP, i.e node,
%   reppresented as a mean and standard deviation (-System.HCP.mu, -System.HCP.sigma)
%
%   -failedSet containes the set of indexes corresponding to the nodes that
%   are currently unavailable, i.e. the orgin points of the random walks.
%   
%   averages is a positive integer containing the required size of the
%   statistical sample over which to average results.
%
%
%   -alpha is the probability that the patient's trajectory will procede to
%   a random node he has not yet visited regardless of the available links
%   of the node he is currently inhabiting.

A = System.matrix;
docs = [System.HCPs(:).id];

if ~nnz(ismember(docs, failedSet))
    disp = 0;
    lost = sum([System.HCPs(:).patients]);
    return
end
A(:,failedSet) = 0;
%Matrix becomes row-stochastic
A = bsxfun(@rdivide,A',sum(A, 2)')';
A(isnan(A)) = 0;
if ~any(any(A))
    disp = 0;
    lost = sum([System.HCPs(:).patients]);
    return
end
%Not all nodes are present because disconnected
failedNodes = find(ismember(docs, failedSet));
System.matrix = A;

for k = 1:averages
    CurSyst = System;
    DocPatients = [CurSyst.HCPs(:).patients];
    patients = struct();
    patients.origins = [];
    patients.displacements = [];
    patients.status = [];
    for i = failedNodes
        patients.origins = [patients.origins; ones(DocPatients(i), 1)*i];
        patients.displacements = [patients.displacements; ones(DocPatients(i), 1)];
        patients.status = [patients.status; true(DocPatients(i), 1)];
    end
    
    patientTraj = zeros(numel(patients.status), numel(docs));
    parfor j = 1:numel(patients.status)
        trj = docs(destroy(A, patients.origins(i)))
        patientTraj(j,:) = [trj, docs(~ismember(docs, trj))];
    end
    j = 1;
    while j<numel(docs)
        j = j +1;
        for i = 1:numel(docs)
            
            if CurSyst.HCPs(i).mu+CurSyst.HCPs(i).capacity-CurSyst.HCPs(i).patients > 0
                atdoc = find(patientTraj(:,j)==docs(i));
                incoming = numel(atdoc);
                if incoming < CurSyst.HCPs(i).mu+CurSyst.HCPs(i).capacity-CurSyst.HCPs(i).patients
                    CurSyst.HCPs(i).patients = CurSyst.HCPs(i).patients+incoming;
                    patients.status(atdoc) = false;
                    patientTraj(atdoc, j:end) =  docs(i);
                else
                    nr_kept = floor(CurSyst.HCPs(i).mu+CurSyst.HCPs(i).capacity-CurSyst.HCPs(i).patients);
                    CurSyst.HCPs(i).patients = CurSyst.HCPs(i).mu+CurSyst.HCPs(i).capacity;
                    kept = randsample(atdoc, nr_kept, false);
                    patientTraj(kept, j:end) = docs(i);
                    patients.status(kept) = false;
                    patients.displacements(atdoc(~ismember(atdoc, kept))) = patients.displacements(atdoc(~ismember(atdoc, kept))) +1;
                end
            else
                patients.displacements(patientTraj(:,j) == docs(i)) = patients.displacements(patientTraj(:,j) == docs(i)) + 1;
            end               
        end
        
        if ~any(patients.status)
            break
        end
    end 
    lost(k) = nnz(patients.status);
    displacements(k) = mean(patients.displacements);
end
lost = mean(lost);
disp = mean(displacements);
end
