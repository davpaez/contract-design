classdef Strategy_1 < managers.MandMaintStrategy
    
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
        
        function thisStrategy = Strategy_1()
            
            thisStrategy@managers.MandMaintStrategy();
            
            import managers.*
            import behavior.agent.*
			
            % Set index
            thisStrategy.setIndex(1);
            
            % Create decision rule objects
            rule_1 = MandatoryMaint.Rule_1();
            
            % Initialize cell array of strategy objects
            thisStrategy.decisionRuleArray{1} = rule_1;
            
            % Populate parameters properties of rules implemented
            
        end
        
    end
    
end