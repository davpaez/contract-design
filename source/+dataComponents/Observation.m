classdef Observation < matlab.mixin.Copyable
    % 
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        time
        value
        
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function thisObs = Observation(t, v)
        %{
        * 
        
            Input
            
            Output
                
        %}
            thisObs.time = t;
            thisObs.value = v;

        end
        
        
    end
    
end