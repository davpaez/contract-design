classdef Strategy_1 < managers.Strategy
	
    methods
        %% Constructor
        
        function thisStrategy = Strategy_1(theFaculty)
            
            import managers.*
            import behavior.agent.*
			
            id = 'Test_1';
            thisStrategy@managers.Strategy(id, theFaculty.decisionVars);
            
            % Create decision rule objects
            rule_1 = VoluntaryMaint.Rule_1();
            rule_10 = VoluntaryMaint.Rule_10();
            
            % Customize parameters properties of rules implemented
            
            
            % Initialize cell array of strategy objects
            thisStrategy.addDecisionRule(rule_1);
            thisStrategy.addDecisionRule(rule_10);
        end
        
    end
    
end