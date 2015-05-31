classdef TypedClass < handle
    
    properties (SetAccess = protected, Hidden = true)
        listTypes
    end
    
    methods
        
        
        function self = TypedClass(list)
            self.listTypes = list;
        end
        
        
        function answer = isValidType(self, str)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            answer = any(strcmp(self.listTypes, str));
            
        end
        
        
    end
    
end

