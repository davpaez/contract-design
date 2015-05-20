classdef Strategy_4 < managers.Strategy
	
    methods
        %% Constructor
        
        function thisStrategy = Strategy_4(theFaculty)
            
            import managers.*
            import behavior.agent.*
			
            id = 'Test_4';
            thisStrategy@managers.Strategy(id, theFaculty.decisionVars);
            
            % Create decision rule objects
            rule_4 = VoluntaryMaint.Rule_4();
            rule_10 = VoluntaryMaint.Rule_10();
            
            % Customize parameters properties of rules implemented
            
            
            % Initialize cell array of strategy objects
            thisStrategy.addDecisionRule(rule_4);
            thisStrategy.addDecisionRule(rule_10);
        end
        
    end
    
end