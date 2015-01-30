classdef Strategy_3 < managers.InspectionStrategy
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
            
            thisStrategy@managers.InspectionStrategy();
            
            import managers.*
            import behavior.principal.*
			
            % Set index
            thisStrategy.setIndex(3);
            
            % Create decision rule objects
            rule_3 = Inspection.Rule_3();
            
            % Initialize cell array of decision rule objects
            thisStrategy.decisionRuleArray{1} = rule_3;
            
            % Populate parameters properties of rules implemented
            
        end
        
    end
    
end