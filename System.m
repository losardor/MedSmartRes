classdef System
    %SYSTEM This class defines the health-care system on the scale defined
    %by the user
    %
    
    properties
        HCPs
        matrix
        capacityType
        capacity
    end
    
    methods
        function self = System(IDs, mu, sigma, matrix, capacityType, capacity)
            N = numel(IDs);
            if N ~= numel(mu)
                error('The number of nodes and the number of means must coincide')
            end
            if N~= numel(sigma)
                error('The number of nodes and the number of sigmas must coincide')
            end
            if N ~= numel(matrix(1,:)) | numel(matrix(1,:)) ~= numel(matrix(:,1))
                error('the matrix must be an NxN matrix');
            end
            
            if nargin == 4
                self.capacityType = 'Sigma';
                self.capacity = 3;
            elseif nargin < 4
                error(message('Not enough inputs for class type System'));
            elseif nargin == 5
                error(message('Capcity must be defined. See documentation for details'));
            else
                self.capacityType = capacityType;
                self.capacity = capacity;
            end
            if capacity < 0
                error(message('Capacity must be positive'));
            end
            if strcmp(capacityType, 'Sigma')
                cap = capacity*sigma;
            elseif strcmp(capacityType, 'Percentage')
                cap = mu*capacity;
            else
                error(message('Capacity Type not defined'))
            end
            %remove self loops
            matrix = matrix - diag(diag(matrix));
            nodes = 1:N;
            %remove disconnected nodes
            nodes = nodes(any(matrix) | any(matrix'));
            matrix = matrix(nodes, nodes);
            self.matrix = matrix;
            n = HCP.empty;
            for i = nodes
                n(end+1) = HCP(mu(i), sigma(i), cap(i));
                n(end).id = i;
                n(end).peterID = IDs(i);
            end
            self.HCPs = n;
        end
    end
    
end