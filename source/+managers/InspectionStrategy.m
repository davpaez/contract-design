classdef InspectionStrategy < managers.Strategy
    
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
        
        function self = InspectionStrategy()
            
            self@managers.Strategy();
            
            import managers.*
            import behavior.principal.*
            
			% Set type action
			self.typeAction = Action.INSPECTION;
            
            % One decision variable: Time of inspection
            self.setDecisionVars_Number(1);
            
            % Nature of decision vars
            self.setDecisionVars_TypeInfo({ Information.TIME_INSPECTION });
            
        end
        
    end
    
end