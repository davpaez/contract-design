classdef Rule_1 < managers.DecisionRule
    %{
    Related player: Nature
    Related action: Shock
    Class name: Rule_1
    Index: 1
    Name: Stochastic exponentially distributed intervals
    ID: natureBehavior.shock.Rule_1
    Type of rule:
        * Sensitive
        * Stochastic
        * Absolute
    
    Parameters:
        * lambda
    
    Input:
        * currentTime
    
    Output:
        * timeNextShock
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_1
    %}
    
    properties (Constant, Hidden = true)
        % Names or parameters in order
        LAMBDA = 'lambda'
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
            thisRule.setName('Stochastic exponentially distributed intervals');
			
            % One decision variable: Time of shock
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.TIME_SHOCK });
            
            % Set as a parametrized rule
            thisRule.setAsParametrized();
            
            % Set number or parameters
            thisRule.setParams_Number(1);
            
            % Set name of parameters
            thisRule.setParams_Name({ thisRule.LAMBDA });
            
            % Set number set of parameters
            thisRule.setParams_NumberSet({ InputData.REAL })
            
            % Set upper and lower bounds for parameters
            assumedMaxContractDuration = 100;
            % Maximum mu so that before t=tm a shock must have
            % occurred with 95% probability
            minLambda = -(log(1-0.95)) / assumedMaxContractDuration;
			maxLambda = 2;
            thisRule.setParams_LowerBounds([ minLambda ]);
            thisRule.setParams_UpperBounds([ maxLambda ]);
            
			% Set default parameters value
			thisRule.setParams_Value( [0.5] );
			
            % Set as Non-adaptive
            thisRule.setTypeRule_Sensitivity(DecisionRule.INSENSITIVE);
            
            % Set as Deterministic
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
            import managers.Information
            
            lambda = thisRule.params_Value;
            
            timeInterval = - (1/lambda)*log(1-rand);
            
            % Due to memorylessness of the exponential distribution, the
            % last shock time is not necessary
            theNature = theMsg.getExecutor();
            timeNextShock = theNature.time + timeInterval;
            theMsg.submitResponse(Information.TIME_SHOCK, timeNextShock);

        end
        
        
    end
    
end