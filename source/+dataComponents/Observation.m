classdef Observation < matlab.mixin.Copyable
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        time
        value
        
    end
    
    methods
        %% Constructor
        
        function thisObs = Observation(t, v)
        %{
        * 
        
            Input
            
            Output
                
        %}
            thisObs.time = t;
            thisObs.value = v;

        end
            
        
        %% Getter functions

        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        
        

        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------

        
    end
    
end