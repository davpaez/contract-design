classdef ContractStrategy < managers.Strategy
    % CONTRACTSTRATEGY Summary of this class goes here
    %   This strategy determines:
    %
    %   - contract duration
    %   - payment schedule
    %   - revenue rate function
    %   - performance threshold
    %   - penalty fee strategy (passed as argument)
    % 
    
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
            
            thisStrategy@managers.Strategy();
            
            import managers.*
            import behavior.agent.*
            
			% Set type action
			thisStrategy.typeAction = Action.CONTRACT_OFFER;
            
            % One decision variable: Time of volMaint, PerfGoal volMaint
            thisStrategy.setDecisionVars_Number(5);
            
            % Nature of decision vars
            thisStrategy.setDecisionVars_TypeInfo({ Information.CONTRACT_DURATION , ...
                Information.PAYMENT_SCHEDULE, ...
                Information.REVENUE_RATE_FUNC, ...
                Information.PERFORMANCE_THRESHOLD, ...
                Information.PENALTY_FEE_STRAT});
            
        end
    end
    
end