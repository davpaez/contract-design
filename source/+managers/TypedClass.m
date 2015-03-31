classdef TypedClass < handle
    %TYPEDCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
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

