classdef network
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        node
        matrix
        patients
        recieving
        
    end
    
    methods
        function self = network(N, mu, sigma, matrix)
            if N ~= numel(mu)
                error('The number of nodes and the numboer of mus must coincide')
            end
            if N~= numel(sigma)
                error('The number of nodes and the number of sigmas must coincide')
            end
            if N ~= numel(matrix(1,:)) | numel(matrix(1,:)) ~= numel(matrix(:,1))
                error('the matrix must be an NxN matrix');
            end
            for i = 1:N
                n(i) = doctor;
                n(i).id = i;
                n(i).mu = mu(i);
                n(i).sigma = (sigma(i));   
                n(i).neighbours = find(matrix(i, :));
            end
            self.node = n;
            self.matrix = matrix;
            self.recieving = false(N,1);
           
        end
        
        function doc = pick_doc(self)
            doc = randsample([self.node(self.recieving).id], 1, true);
        end
    end
    
end

