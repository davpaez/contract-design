classdef Rule_2 < managers.DecisionRule
    %{
    Related player: Agent
    Related action: Voluntary maintenance
    Class name: Rule_2
    Index: 2
    Name: Stochastic exponentially distributed intervals
    ID: agentBehavior.voluntaryMaint.Rule_2
    Type of rule:
        * Sensitive
        * Stochastic
        * Absolute
    
    Parameters:
        * lambda
    
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
        * Strategy_2
    %}
    
    properties (Constant, Hidden = true)
        % Names or parameters in order
        LAMBDA = 'lambda'       % Scale parameter of exp distribution; lambda = 1/mu
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
            thisRule.setName('Stochastic exponentially distributed intervals');
            
            % One decision variable: Time of inspection
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.TIME_VOL_MAINT });
            
            % Set as a parametrized rule
            thisRule.setAsParametrized();
            
            % Set number or parameters
            thisRule.setParams_Number(1);
            
            % Set name of parameters
            thisRule.setParams_Name({ thisRule.LAMBDA });
            
            % Set number set of parameters
            thisRule.setParams_NumberSet({ InputData.REAL })
            
            % Set upper and lower bounds for parameters
            maxInterval = 10;
            % Maximum mu so that a voluntary maintenance must have
            % occurred with 95% probability before an inteval of maxInterval
            minLambda = -(log(1-0.95)) / maxInterval;
			maxLambda = 2;
			
            thisRule.setParams_LowerBounds([ minLambda ]);
            thisRule.setParams_UpperBounds([ maxLambda ]);
            
			% Set default parameters value
			thisRule.setParams_Value( [1.5] );
            
            % Set as Non-adaptive
			thisRule.setTypeRule_Sensitivity(DecisionRule.SENSITIVE);
            
            % Set as Stochastic
            thisRule.setTypeRule_Determinacy(DecisionRule.STOCHASTIC);
			
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
            
            lambda = thisRule.params_Value;
            timeInterval = - (1/lambda)*log(1-rand);
            
            volMaintEvent = theAgent.eventList.getLastEventOfType(Event.VOL_MAINT);
            if ~isempty(volMaintEvent)
                lastVolMaintTime = volMaintEvent.time;
            else
                lastVolMaintTime = 0;
            end
            
            timeNextVolMaint = lastVolMaintTime + timeInterval;
            
            if timeNextVolMaint < theAgent.time
                timeNextVolMaint = theAgent.time + 0.01;
            end
            
            theMsg.submitResponse(Information.TIME_VOL_MAINT, timeNextVolMaint);
            
        end
        
    end
    
end