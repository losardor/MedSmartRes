function [ disp, lost ] = NNSelfAvoiding( System, failedSet, averages, maxSteps, alpha)




A = System.matrix;
docs = [System.HCPs(:).id];
for i = docs
    doc2ind(i) = find(docs == i);
end
active_nodes = docs(~ismember(docs, failedSet));
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
else
    transport = makeTargetMatrix(A);
end
N = numel(transport(1,:));
failedNodes = docs(find(ismember(docs, failedSet)));
System.matrix = A;
for k = 1:averages
    CurSyst = System;
    DocPatients = [CurSyst.HCPs(:).patients];
    patients = struct();
    patients.origins = [];
    patients.displacements = [];
    patients.status = [];
    patients.lost = 0;
    for i = failedNodes
        patients.origins = [patients.origins; ones(DocPatients(doc2ind(i)), 1)*i];
        patients.displacements = [patients.displacements; ones(DocPatients(doc2ind(i)), 1)];
        patients.status = logical([patients.status; true(DocPatients(doc2ind(i)), 1)]);
    end
    
        %Perform initial time step
    if numel(patients.status) == 1
        targets = docs(transport(doc2ind(patients.origins), randi(N, 1)));
    else
        targets = transport(sub2ind(size(transport), doc2ind(patients.origins(patients.status))', randi(numel(docs), nnz(patients.status),1)));
        targets(targets>0) = docs(targets(targets>0));
        telep_prob = rand(size(targets));
        targets(telep_prob < alpha) = randsample(active_nodes, nnz(telep_prob < alpha), true);
       
    end
    
    patients.status(patients.status) = logical(targets);
    patients.lost = patients.lost + nnz( ~targets);
    patients.displacements(patients.status) = patients.displacements(patients.status)+1;
    
    
    %FOLLOWING TIME STEPS
    while any(patients.status)

        patients.origins(patients.status) = targets(targets>0);
        
        for i = 1:numel(docs)
            intake = CurSyst.HCPs(i).mu+CurSyst.HCPs(i).capacity-CurSyst.HCPs(i).patients ;
            if intake < 0
                intake = 0;
            end
            
            if logical(intake)
                presentPats = find(patients.origins == i); %
                presentPats = presentPats(patients.status(presentPats));
                if numel(presentPats) > intake
                    try
                        kept = randsample(presentPats, floor(intake), false);
                    catch
                        wtf =0
                    end
                    patients.status(kept) = false;
                    intake = numel(kept);
                else
                    patients.status(presentPats) = false;
                    intake = numel(presentPats);
                end
            end
            
            DocPatients(i) = DocPatients(i) + intake;
        end
        patients.status(patients.displacements > maxSteps) = false;
        
        if numel(patients.status) == 1
            targets = docs(transport(doc2ind(patients.origins), randi(numel(docs), 1)));
        else
            targets = transport(sub2ind(size(transport), doc2ind(patients.origins(patients.status))', randi(numel(docs), nnz(patients.status),1)));
            targets(targets>0) = docs(targets(targets>0));
            telep_prob = rand(size(targets));
            targets(telep_prob < alpha) = randsample(active_nodes, nnz(telep_prob < alpha), true);
        end
        
    patients.status(patients.status) = logical(targets);
    patients.lost = patients.lost + nnz( ~targets);
    patients.displacements(patients.status) = patients.displacements(patients.status)+1;
    
    
   
    
    %UPDATE DATA
    patients.lost = patients.lost + numel(patients.displacements(patients.displacements > maxSteps));
    patients.matrix = A;
    a =patients.displacements;
    disp2(k) = sum(a)/numel(a);
    stdD2(k) = std(a);
    lost2(k) = patients.lost;
end
disp = mean(disp2);
lost = mean(lost2);
end
