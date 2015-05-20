classdef TypedClass < handle
    
    properties (SetAccess = protected, Hidden = true)
        listTypes
    end
    
    methods
        
        
        function thisTypedClass = TypedClass(list)
            thisTypedClass.listTypes = list;
        end
        
        
        function answer = isValidType(thisTypedClass, str)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            answer = any(strcmp(thisTypedClass.listTypes, str));
            
        end
        
        
    end
    
end

