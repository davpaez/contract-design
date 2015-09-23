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
        
        function self = Observation(t, v)
        %{
        * 
        
            Input
            
            Output
                
        %}
            self.time = t;
            self.value = v;

        end
        
        
    end
    
end