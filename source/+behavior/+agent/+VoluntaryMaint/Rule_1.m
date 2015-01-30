classdef Rule_1 < managers.DecisionRule
    %{
    Related player: Agent
    Related action: Voluntary maintenance
    Class name: Rule_1
    Index: 1
    Name: Fixed Maintenance Interval by Parameter
    ID: agentBehavior.voluntaryMaint.Rule_1
    Type of rule:
        * Sensitive
        * Deterministic
        * Absolute
    
    Parameters:
        * maintenanceTimeInterval
    
    Input:
        * timeLastVolMaint
        * currentTime
    
    Output:
        * timeNextMaintenance
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_1
    %}
    
    properties (Constant, Hidden = true)
        % Names or parameters in order
        MAINTENANCE_TIME_INTERVAL = 'maintenanceTimeInterval'
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
        
        function thisRule = Rule_1()
            thisRule@managers.DecisionRule();
            
            import managers.*
            
            % Set index
            thisRule.setIndex(1);
            
            % Set name
            thisRule.setName('Fixed Maintenance Interval by Parameter');

            % One decision variable: Time of voluntary maintenance
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.TIME_VOL_MAINT });
            
            % Set as a parametrized rule
            thisRule.setAsParametrized();
            
            % Set number or parameters
            thisRule.setParams_Number(1);
            
            % Set name of parameters
            thisRule.setParams_Name({ thisRule.MAINTENANCE_TIME_INTERVAL });
            
            % Set number set of parameters
            thisRule.setParams_NumberSet({ InputData.REAL })
            
            % Set upper and lower bounds for parameters
            thisRule.setParams_LowerBounds([ 0.05 ]);
            thisRule.setParams_UpperBounds([ 8 ]);
            
            % Set default parameters value
            thisRule.setParams_Value(0.85);
            
            % Set as Sensitive
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
        function mainAlgorithm(thisRule, theMsg)
            import dataComponents.Event
            import managers.Information
            
            theAgent = theMsg.getExecutor();
            
            timeInterval = thisRule.params_Value;
            
            lastMaintEvent = theAgent.eventList.getLastEventOfType(Event.VOL_MAINT);
            
            if ~isempty(lastMaintEvent)
                lastMaintenanceTime = lastMaintEvent.time;
            else
                lastMaintenanceTime = 0;
            end

            
            timeNextVolMaint = lastMaintenanceTime + timeInterval;
            
            if timeNextVolMaint <= theAgent.time
                timeNextVolMaint = theAgent.time + 0.01;
            end
            
            theMsg.submitResponse(Information.TIME_VOL_MAINT, timeNextVolMaint);
        end
        
        
    end
    
end