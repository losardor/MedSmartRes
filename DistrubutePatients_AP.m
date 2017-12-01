function [ allottedPats, allottedstd ] = DistrubutePatients_AP( N, failedNode, maxSteps, averages )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%Count doctors
numberDocs = numel(N.node);
%Create a dynamic variable for the matrix
A = N.matrix;
%Remove self loops
A = A - diag(diag(A));
%Create list of nodes
nodes = 1:numberDocs;
%remove disconnected
nodes = nodes(any(A) | any(A'));
%If the node is a disconnected one all patients will be lost immediatelly
if nnz(ismember(find(~(any(A) | any(A'))), failedNode))
    looking = sum(N.node(failedNode).mu);
    allottedPats = ones(1, 12)*(sum([N.node(:).mu])-looking)/sum([N.node(:).mu]);
    allottedstd = zeros(1,12);
    return
end
%Create a vector of patients looking for a doctor as a function of time
looking = zeros(averages, maxSteps);
%Remove incoming links to removed doctor
A(:,failedNode) = 0;
%Row normalise A so what whe now see is the prDistrubutePatients_APobability of selecting a
%given outgoing link
A = bsxfun(@rdivide,A',sum(A, 2)')';
%Set 0/0 fractions to 0
A(isnan(A)) = 0;
%Compute a matrix in the form specified in end comments
transport = makeTargetMatrix(A);
%Run iterations
for j = 1:averages
    %Start counting time
    time = 1;
    %initialize patient numbers according to normal distrubutions
    DocPatients = ones(1, numberDocs);
    mu = ones(1,numberDocs);
    sigma = ones(1,numberDocs);
    for i = 1:numel(nodes)
        mu(i) = N.node(nodes(i)).mu;
        sigma(i) = N.node(nodes(i)).sigma;
    end
    DocPatients = round(mvnrnd(mu, sigma, 1));
    DocPatients(DocPatients < 1) = 1;
    
    %Remove failed doctors and create displacing patients.
    %Failed doctors have no incoming links but they keep their outgoing.
    patients = struct();
    patients.origins = [];
    patients.displacements = [];
    patients.status = [];
    i = find(ismember(nodes,failedNode));
    looking(j, 1) = DocPatients(i);
    patients.origins = [patients.origins; ones(DocPatients(i), 1)*nodes(i)];
    patients.displacements = [patients.displacements; zeros(DocPatients(i), 1)];
    patients.status = [patients.status; true(DocPatients(i), 1)];
    
    patients.status = logical(patients.status);
    patients.lost = 0;
    
    %Perform initial time step
    %Assign each displacing patient a target doctor. Because of how sub2ind
    %works the case of 1 patient must be separated out
    if numel(patients.status) == 1
        targets = transport(randi(numberDocs, 1), patients.origins);
    else
        targets = transport(sub2ind(size(transport), patients.origins(patients.status),randi(numberDocs, nnz(patients.status),1)));
    end
    %I the target is 0, i.e. there was no outgoing link, the patient is
    %lost
    patients.status(patients.status) = logical(targets);
    patients.lost = patients.lost + nnz( ~targets);
    patients.displacements(patients.status) = patients.displacements(patients.status)+1;
    
    
    while any(patients.status)
        time = time + 1;
        looking(j, time) = looking(j, time-1);
        %Compute the number of patients doctors are willing to accept
        intake = normrnd(0,1, numberDocs, 1);
        intake = intake.*sigma' + mu';
        intake(ismember(nodes,failedNode)) = 0;
        intake(intake < DocPatients') = 0;
        intake(intake>DocPatients') = intake(intake>DocPatients')-DocPatients(intake>DocPatients')';
        %update the patients position
        patients.origin(patients.status) = targets(targets>0);
        %Check which patients are accepted
        for i = 1:numberDocs
            
            if logical(intake(i))
                %Determin which patients are at the given doc
                presentPats = find(patients.origin == i); % slow
                presentPats = presentPats(patients.status(presentPats));
                %If the number of present patients are more than what the
                %doctor is willing to accept the ones that are accepted
                %must be computed, otherwhise all are accepted
                if numel(presentPats) > intake(i)
                    %Randomly select the patients to be accepted
                    kept = randsample(presentPats, floor(intake(i)), false);
                    patients.status(kept) = false;
                    intake(i) = numel(kept);
                else
                    patients.status(presentPats) = false;
                    intake(i) = numel(presentPats);
                end
            end
            %Update patient numbers
            DocPatients(i) = DocPatients(i) + intake(i);
            looking(j, time) = looking(j, time)-intake(i);
        end
        patients.status(patients.displacements >= maxSteps) = false;
        %Compute new targets
        if numel(patients.status) == 1
            targets = transport(randi(numberDocs, 1), patients.origins);
        else
            targets = transport(sub2ind(size(transport), patients.origins(patients.status), randi(numberDocs, nnz(patients.status),1)));
        end
        %like in firt step
        patients.status(patients.status) = logical(targets);
        patients.lost = patients.lost + nnz( ~targets);

        patients.displacements(patients.status) = patients.displacements(patients.status)+1;
    end
    %Add up patients that lost faith
    patients.lost = patients.lost + numel(patients.displacements(patients.displacements > maxSteps));
    patients.matrix = A;    
end
allottedPats = (ones(size(mean(looking)))*sum([N.node(:).mu])-mean(looking))./(ones(size(mean(looking)))*sum([N.node(:).mu]));
allottedstd  = std(looking)./(ones(size(mean(looking)))*sum([N.node(:).mu]));
end

