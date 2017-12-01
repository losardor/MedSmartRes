classdef doctor
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        patients
        mu
        sigma
        incoming
        neighbours
        arrivals
    end
    
    methods
        function self = set.id(self, idn)
            %id must be a positive integer
            if isnumeric(idn) && isscalar(idn) && ceil(idn) == floor(idn) && idn > 0
                self.id = idn;
            else
                error('invalid ID');
            end
        end
        
        function choice = choose(self)
            prob = (1/2)*(1+erf((self.mu-self.patients)/(self.sigma*sqrt(2))));
            choice = rand < prob;
        end
        
        function [self, patient] = accept(self, patient)
            self.patients = self.patients + 100;
            patient = patient.settle(self);
            patnum = find(self.arrivals == patient.id);
            self.arrivals(patnum) = [];
        end
        
        function self = recieving(self, patient)
            self.arrivals = [self.arrivals, patient];
        end
        
        function [network] = send(self, network, patient)
            if isempty(self.neighbours)
                network.patients(patient.id) = patient.lost;
            else
                if numel(self.neighbours) == 1
                    target = self.neighbours;
                else
                    try
                        target = randsample([self.neighbours], 1, true, network.matrix(self.id, self.neighbours));
                    catch
                        donald_duck = 0
                    end
                end
                if patient.tried_docs < 10
                    network.node(target) = network.node(target).recieving(patient.id);
                    network.patients(patient.id) = patient.move(target);
                    network.recieving(target) = true;
                else
                    network.patients(patient.id) = patient.lost;
                end
            end
            patnum = find(self.arrivals == patient.id);
            network.node(self.id).arrivals(patnum) = [];
        end
        
        function [network] = kill(self, network)
            if ~isempty(self.arrivals)
                pats = network.node(self.id).arrivals;
                for i = 1:numel(network.node(self.id).arrivals)
                    patid = pats(i);
                    pat = network.patients(patid);                
                    network = network.node(self.id).send(network, pat);
                end
            end
            network.recieving(self.id) = false;
            for i = 1:self.patients/100
                pat(i) = patient;
                pat(i).id = numel(network.patients)+i;
                pat(i).status = 1;
            end
            if isempty(network.patients)
                network.patients = pat;
            else
                network.patients = [network.patients , pat];
            end
            for i = 1:self.patients/100
                network = self.send(network, pat(i));
            end
            A = network.matrix;
            A(:,self.id) = 0;
            A=bsxfun(@rdivide,A',sum(A'))';
            A(isnan(A)) = 0;
            network.matrix = A;
            for j = 1:numel(network.node)
                network.node(j).neighbours = find(network.matrix(j,:));
            end
        end
                
    end
    
end

