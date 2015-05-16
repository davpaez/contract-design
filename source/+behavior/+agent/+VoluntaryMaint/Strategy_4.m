classdef Strategy_4 < managers.Strategy
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
        
        function thisStrategy = Strategy_4(theFaculty)
            
            import managers.*
            import behavior.agent.*
			
            thisStrategy@managers.Strategy(theFaculty.decisionVars);
            
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