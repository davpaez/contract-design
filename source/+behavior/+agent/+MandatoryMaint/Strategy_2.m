classdef Strategy_2 < managers.MandMaintStrategy
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
        
        function thisStrategy = Strategy_2()
            
            thisStrategy@managers.MandMaintStrategy();
            
            import managers.*
            import behavior.agent.*
			
            % Set index
            thisStrategy.setIndex(2);
            
            % Create decision rule objects
            rule_2 = MandatoryMaint.Rule_2;
            
            % Initialize cell array of strategy objects
            thisStrategy.decisionRuleArray{1} = rule_2;
            
            % Populate parameters properties of rules implemented
            
        end
        
    end
    
end