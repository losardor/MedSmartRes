classdef HCP
    %HCP is a class defining an HCP giving him an ID and basic properties
    %   -The id is a number from 1 to N number of HCPs in the System
    %   -mu is the mean number of patients contacted in the defined time
    %   period
    %   -sigma is the standard deviation of the previous distribution
    %   -capacity is the number of patients the HCP can take in addition to
    %   his mean
    %   -patients is the number of patients currently being treated by the
    %   HCP
    %   -kill outputs the number of patients currently present since they
    %   will need to find a new HCP
    
    properties
        id
        mu
        sigma
        capacity
        patients
        peterID
    end
    
    methods
        function self = HCP(mu, sigma, capacity)
            self.mu = mu;
            self.sigma = sigma;
            self.capacity = capacity;
            self.patients = mu;
        end
        
        function self = set.id(self, idn)
            %id must be a positive integer
            if isnumeric(idn) && isscalar(idn) && ceil(idn) == floor(idn) && idn > 0
                self.id = idn;
            else
                error('invalid ID');
            end
        end
                
    end
    
end

