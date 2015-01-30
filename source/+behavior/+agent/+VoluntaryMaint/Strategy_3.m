classdef Strategy_3 < managers.VolMaintStrategy
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
        
        function thisStrategy = Strategy_3()
            
            thisStrategy@managers.VolMaintStrategy();
            
            import managers.*
            import behavior.agent.*
			
            % Set index
            thisStrategy.setIndex(3);
            
            % Create decision rule objects
            rule_3 = VoluntaryMaint.Rule_3();
            rule_10 = VoluntaryMaint.Rule_10();
            
            % Initialize cell array of strategy objects
            thisStrategy.decisionRuleArray{1} = rule_3;
            thisStrategy.decisionRuleArray{2} = rule_10;
            
            % Populate parameters properties of rules implemented
            
        end
        
    end
    
end