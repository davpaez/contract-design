classdef ContractStrategy < managers.Strategy
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
		
        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
    
    methods
        
        % Constructor
        
        function thisStrategy = ContractStrategy()
        %{
        * This strategy determines:
            - contract duration
            - performance threshold
            - payment schedule
            - revenue rate function
            
            Input
                
            Output
                
        %}
            thisStrategy@managers.Strategy();
            
            import managers.*
            import behavior.agent.*
            
			% Set type action
			thisStrategy.typeAction = Action.CONTRACT_OFFER;
            
            % One decision variable: Time of volMaint, PerfGoal volMaint
            thisStrategy.setDecisionVars_Number(4);
            
            % Nature of decision vars
            thisStrategy.setDecisionVars_TypeInfo({ Information.CONTRACT_DURATION , ...
                Information.PERFORMANCE_THRESHOLD
                Information.PAYMENT_SCHEDULE, ...
                Information.REVENUE_RATE_FUNC});
            
        end
    end
    
end