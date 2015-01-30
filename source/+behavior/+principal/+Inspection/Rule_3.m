classdef Rule_3 < managers.DecisionRule
    %{
    Related player: Principal
    Related action: Inspection
    Class name: Rule_3
    Index: 3
    Name: Stochastic exponentially distributed intervals
    ID: behavior.principal.inspection.Rule_3
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
        * timeNextInspection
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_3
    %}
    
    properties (Constant, Hidden = true)
        % Names or parameters in order
        LAMBDA = 'lambda'       % Scale parameter of exp distribution; lambda = 1/mu
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        lastInspectionTime
        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
    
    methods
        %% Constructor
        
        function thisRule = Rule_3()
            thisRule@managers.DecisionRule();
            
            import managers.*
            
            % Set index
            thisRule.setIndex(3);
            
            % One decision variable: Time of inspection
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.TIME_INSPECTION });
            
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
            % Maximum mu so that an inspection must have
            % occurred with 95% probability before an inteval of maxInterval
            minLambda = -(log(1-0.95)) / maxInterval;
			maxLambda = 10;
			
            thisRule.setParams_LowerBounds([ minLambda ]);
            thisRule.setParams_UpperBounds([ maxLambda ]);
            
            % Set as Non-adaptive
            thisRule.setTypeRule_Sensitivity(DecisionRule.SENSITIVE);
            
            % Set as Stochastic
            thisRule.setTypeRule_Determinacy(DecisionRule.STOCHASTIC);
			
            % Type of output produced by this rule
            thisRule.setTypeRule_Output({ DecisionRule.ABSOLUTE_VALUE });
			
			% Set default parameters value
			thisRule.setParams_Value( [0.5] );
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
            import managers.Information
            
            thePrincipal = theMsg.getExecutor();
            
            lambda = thisRule.params_Value;
            
            timeInterval = - (1/lambda)*log(1-rand);
            
            if isempty(thisRule.lastInspectionTime)
                lastInspTime = thePrincipal.observation.getCurrentTime();
                if ~isempty(lastInspTime)
                    thisRule.lastInspectionTime = lastInspTime;
                else
                    thisRule.lastInspectionTime = 0;
                end
            end
			
            timeNextInspection = thisRule.lastInspectionTime + timeInterval;
            
            if timeNextInspection < thePrincipal.time
                timeNextInspection = thePrincipal.time;
            end
            
            thisRule.lastInspectionTime = timeNextInspection;
            
            theMsg.submitResponse(Information.TIME_INSPECTION, timeNextInspection);
            
        end
        
    end
end