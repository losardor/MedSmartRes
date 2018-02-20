function [ disp, lost ] = SelfAvoiding( System, failedSet, averages, alpha )
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

if nnz(ismember(docs, failedSet))
    disp = 0;
    lost = sum([System.HCPs(:).patients]);
    return
end
A(:,failedSet) = 0;
%Matrix becomes row-stochastic
A = bsxfun(@rdivide,A',sum(A, 2)')';
A(isnan(A)) = 0;
if any(any(A))
    transport = makeTargetMatrix(A);
else
    disp = 0;
    lost = sum([System.HCPs(:).patients]);
    return
end
%Not all nodes are present because disconnected
failedNodes = find(ismember(docs, failedSet));
System.matrix = A;

for k = 1:averages
    
    DocPatients = [System.HCPs(:).patients];
    patients = struct();
    patients.origins = [];
    patients.displacements = [];
    patients.status = [];
    for i = failedNodes
        patients.origins = [patients.origins; ones(DocPatients(i), 1)*docs(i)];
        patients.displacements = [patients.displacements; zeros(DocPatients(i), 1)];
        patients.status = [patients.status, true(DocPatients(i), 1)];
    end
    patientTraj = patients.origins;
    lost = 0;
    
    while true
        %Timestep will go here
        if any(patients.status)
            break
        end
    end
        
         
end

