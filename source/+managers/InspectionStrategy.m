classdef InspectionStrategy < managers.Strategy
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
        
        function thisStrategy = InspectionStrategy()
            
            thisStrategy@managers.Strategy();
            
            import managers.*
            import behavior.principal.*
            
			% Set type action
			thisStrategy.typeAction = Action.INSPECTION;
            
            % One decision variable: Time of inspection
            thisStrategy.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisStrategy.setDecisionVars_TypeInfo({ Information.TIME_INSPECTION });
            
        end
        
    end
    
end