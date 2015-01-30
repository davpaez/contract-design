classdef Rule_2 < managers.DecisionRule
    %{
    Related player: Principal
    Related action: Inspection
    Class name: Rule_2
    Index: 2
    Name: Fixed inspection interval with random component
    ID: behavior.principal.inspection.Rule_2
    Type of rule:
        * Sensitive
        * Deterministic
        * Absolute
    
    Parameters:
        * inspectionTimeInterval
    
    Input:
        * timeLastInspection
        * currentTime
    
    Output:
        * timeNextInspection
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_2
    %}
    
    properties (Constant, Hidden = true)
        % Names or parameters in order
        INSPECTION_TIME_INTERVAL = 'inspectionTimeInterval'
    end
    
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
        
        function thisRule = Rule_2()
            thisRule@managers.DecisionRule();
            
            import managers.*
            
            % Set index
            thisRule.setIndex(2);
            
            % Set name
            thisRule.setName('Fixed inspection interval with random component');
            
            % One decision variable: Time of inspection
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.TIME_INSPECTION });
            
            % Set as a parametrized rule
            thisRule.setAsParametrized();
            
            % Set number or parameters
            thisRule.setParams_Number(1);
            
            % Set name of parameters
            thisRule.setParams_Name({ thisRule.INSPECTION_TIME_INTERVAL });
            
            % Set number set of parameters
            thisRule.setParams_NumberSet({ InputData.REAL })
            
            % Set upper and lower bounds for parameters
            thisRule.setParams_LowerBounds([ 0.05 ]);
            thisRule.setParams_UpperBounds([ 5 ]);
            
			% Set default parameters value
			thisRule.setParams_Value( [2] );
			
            % Set as Non-adaptive
            thisRule.setTypeRule_Sensitivity(DecisionRule.SENSITIVE);
            
            % Set as Deterministic
            thisRule.setTypeRule_Determinacy(DecisionRule.DETERMINISTIC);
			
            % Type of output produced by this rule
            thisRule.setTypeRule_Output({ DecisionRule.ABSOLUTE_VALUE });
        end
        
        %% Getter functions
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        
        
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        %{
        
            Input
                
            Output
                
        %}
        function timeNextInspection = mainAlgorithm(thisRule, theMsg)
            import dataComponents.Event
            import managers.Information
            
            thePrincipal = theMsg.getExecutor();
            
            timeInterval = thisRule.params_Value + rand*1.5 ;
            
            inspEvent = thePrincipal.eventList.getLastEventOfType(Event.INSPECTION);
			if ~isempty(inspEvent)
				lastInspectionTime = inspEvent.time;
			else
				lastInspectionTime = 0;
			end
            
            timeNextInspection = lastInspectionTime + timeInterval;
            
            if timeNextInspection <= thePrincipal.time
                timeNextInspection = thePrincipal.time + 0.05;
            end
            
            theMsg.submitResponse(Information.TIME_INSPECTION, timeNextInspection);
            
        end
        
    end
    
end