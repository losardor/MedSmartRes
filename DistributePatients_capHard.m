function [ disp, lost ] = DistributePatients_capHard( N, failedNodes, maxSteps, averages, capacity, alpha )
%DISTRIBUTEpATIENTS Computes the mean number of diplacements per patient
%and the total number of lost patients after the removal of a set of
%doctors
%   The doctors are removed simultaneously and the results are averaged
%   over "averages" number of runs. Once the time starts redistribution is
%   synchronus.
%   Inputs:
%   N is an object reppresenting the network of doctors and patients before
%   the removal
%   failedNodes is a vector containint the Ids of removed nodes of the
%   network
%   maxSteps is the number of times patients are willing to displace in
%   order to find a new HCP
%   averages is the number of times the simulation will run the scenario
%   before averaging the results in the output


%SETUP

%Clean the network by removing self loops, disconnected doctors and
%rownormalising the transport matrix
numberDocs = numel(N.node);
A = N.matrix;
A = A - diag(diag(A));

nodes = 1:numberDocs;
nodes = nodes(any(A) | any(A'));

numberDocs = numel(nodes);
if nnz(ismember(find(~(any(A) | any(A'))), failedNodes))
    disp = 0;
    lost =  sum([N.node(failedNodes).mu]);
    return
end
active_nodes = nodes(~ismember(nodes, failedNodes));
A(:,failedNodes) = 0;
A = bsxfun(@rdivide,A',sum(A, 2)')';
A(isnan(A)) = 0;
if any(any(A))
    transport = makeTargetMatrix_new(A);
else
    lost = sum([N.node(:).mu]);
    disp = 0;
    return
end
time = [];

%ITERATED PART
for j = 1:averages
    tic
    %INITIALIZE DOCTORS AND PATIENTS
    
    DocPatients = ones(1, numberDocs);
    mu = ones(1,numberDocs);
    sigma = ones(1,numberDocs);
    
    for i = 1:numel(nodes)
        mu(i) = N.node(nodes(i)).mu;
        sigma(i) = N.node(nodes(i)).sigma;
    end
    DocPatients = floor(mu);
    %round(mvnrnd(mu, sigma, 1));
    
    DocPatients(DocPatients < 1) = 1;
    
    %Remove failed doctors and create displacing patients.
    %Failed doctors have no incoming links but they keep their outgoing.
    patients = struct();
    patients.origins = [];
    patients.displacements = [];
    patients.status = [];
        for i = find(ismember(nodes,failedNodes))
            patients.origins = [patients.origins; ones(DocPatients(i), 1)*nodes(i)];
            patients.displacements = [patients.displacements; zeros(DocPatients(i), 1)];
            patients.status = [patients.status; true(DocPatients(i), 1)];
        end
    patientTraj = patients.origins;
    patients.status = logical(patients.status);
    patients.lost = 0;
    
    %BEGIN DIFFUSION
    
    %Perform initial time step
    if numel(patients.status) == 1
        targets = transport(randi(numberDocs, 1), patients.origins);
    else
        targets = transport(sub2ind(size(transport), patients.origins(patients.status),randi(numberDocs, nnz(patients.status),1)));
        telep_prob = rand(size(targets));
        targets(telep_prob < alpha) = randsample(active_nodes, nnz(telep_prob < alpha), true);
    end
    
    patients.status(patients.status) = logical(targets);
    patients.lost = patients.lost + nnz( ~targets);
    patients.displacements(patients.status) = patients.displacements(patients.status)+1;
    
    
    %FOLLOWING TIME STEPS
    while any(patients.status)

        intake = sigma'*capacity + mu' - DocPatients';
        intake(ismember(nodes,failedNodes)) = 0;
        intake(intake < 0) = 0;
        patients.origins(patients.status) = targets(targets>0);
        
        for i = 1:numberDocs
            
            if logical(intake(i))
                presentPats = find(patients.origins == i); %
                presentPats = presentPats(patients.status(presentPats));
                if numel(presentPats) > intake(i)
                    kept = randsample(presentPats, floor(intake(i)), false);
                    patients.status(kept) = false;
                    intake(i) = numel(kept);
                else
                    patients.status(presentPats) = false;
                    intake(i) = numel(presentPats);
                end
            end
            
            DocPatients(i) = DocPatients(i) + intake(i);
        end
        patients.status(patients.displacements > maxSteps) = false;
        
        if numel(patients.status) == 1
            targets = transport(randi(numberDocs, 1), patients.origins);
        else
            targets = transport(sub2ind(size(transport), patients.origins(patients.status), randi(numberDocs, nnz(patients.status),1)));
            telep_prob = rand(size(targets));
            targets(telep_prob < alpha) = randsample(active_nodes, nnz(telep_prob < alpha), true);
        end
        
        patients.status(patients.status) = logical(targets);
        patients.lost = patients.lost + nnz( ~targets);
        patients.displacements(patients.status) = patients.displacements(patients.status)+1;
        patientTraj = [patientTraj, patients.origins];
    end
    
    %UPDATE DATA
    patients.lost = patients.lost + numel(patients.displacements(patients.displacements > maxSteps));
    patients.matrix = A;
    a =patients.displacements;
    disp2(j) = sum(a)/numel(a);
    stdD2(j) = std(a);
    lost2(j) = patients.lost;
    time = [time, toc];
end

%PREPARE OUTPUT 
disp = mean(disp2);
lost = mean(lost2);
end
