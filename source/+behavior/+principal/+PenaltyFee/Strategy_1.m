classdef Strategy_1 < managers.Strategy
    
    methods
        %% Constructor
        
        function thisStrategy = Strategy_1(theFaculty)
            
            import managers.*
            import behavior.principal.*
            
            id = 'Fixed';
            thisStrategy@managers.Strategy(id, theFaculty.decisionVars);
            
            % Create decision rule objects
            rule_1 = PenaltyFee.Rule_1();
            
            % Customize parameters properties of rules implemented
            
            
            % Initialize cell array of strategy objects
            thisStrategy.addDecisionRule(rule_1);
        end
        
    end
    
end