classdef patient
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        doctor             %ID of the doctor the patient is at
        tried_docs = 0     %The number of times the patient looked for a doctor
        status 
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
        
        function self = settle(self, doc)
            self.status = 0;
            self.doctor = doc;
        end
        
        function self = lost(self)
            self.status = 2;
            self.doctor = 0;
        end
        
        function self = move(self, doc)
            self.tried_docs = self.tried_docs + 1;
            self.doctor = doc;
        end
    end
    
end

