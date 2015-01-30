classdef ShockStrategy < managers.Strategy
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
		
        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
    
    methods
        %% Constructor
        
        function thisStrategy = ShockStrategy()
            
            thisStrategy@managers.Strategy();
            
            import managers.*
            import behavior.nature.*
            
			% Set type action
			thisStrategy.typeAction = Action.SHOCK;
            
            % One decision variable: Time of shock, Force Value
            thisStrategy.setDecisionVars_Number(2);
            
            % Nature of decision vars
            thisStrategy.setDecisionVars_TypeInfo({ Information.TIME_SHOCK , Information.FORCE_SHOCK });
            
        end
        
    end
    
end