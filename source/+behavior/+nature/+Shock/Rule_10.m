classdef Rule_10 < managers.DecisionRule
    %{
    Related player: Nature
    Related action: Shock
    Class name: Rule_10
    Index: 10
    Name: Lognormally distributed shock force
    ID: natureBehavior.shock.Rule_10
    Type of rule:
        * Insensitive
        * Stochastic
        * Absolute
    
    Parameters:
        * mu
        * cov
    
    Input:
        * 
    
    Output:
        * forceValue
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_1
    %}
    
    properties (Constant, Hidden = true)
        % Names or parameters in order
        M = 'mu'
        COV = 'cov'
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
        
        function thisRule = Rule_10()
            thisRule@managers.DecisionRule();
            
            import managers.*
            
            % Set index
            thisRule.setIndex(10);
            
            % Set name
            thisRule.setName('Lognormally distributed shock force');
            
            % One decision variable: Performance goal of shock
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.FORCE_SHOCK });
            
            % Set as a parametrized rule
            thisRule.setAsParametrized();
            
            % Set number or parameters
            thisRule.setParams_Number(2);
            
            % Set name of parameters
            thisRule.setParams_Name({ thisRule.M, thisRule.COV });
            
            % Set number set of parameters
            thisRule.setParams_NumberSet({ InputData.REAL , InputData.REAL })
            
            % Set upper and lower bounds for parameters
            thisRule.setParams_LowerBounds([  5 , 0.05 ]);
            thisRule.setParams_UpperBounds([100 , 1 ]);
            
            % Set as Non-adaptive
            thisRule.setTypeRule_Sensitivity(DecisionRule.SENSITIVE);
            
            % Set as Deterministic
            thisRule.setTypeRule_Determinacy(DecisionRule.STOCHASTIC);
			
            % Type of output produced by this rule
            thisRule.setTypeRule_Output({ DecisionRule.DELTA_VALUE });
			
			% Set default parameters value
			thisRule.setParams_Value( [10, 0.5] );
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
            
            m = thisRule.params_Value(1);
            cov = thisRule.params_Value(2);
            
            s = m*cov;
            v=s^2;
            
            mu = log(m^2/sqrt(v+m^2));
            sigma = sqrt(log(v/m^2 + 1));
            
            forceValue = lognrnd(mu,sigma);
            
            theMsg.submitResponse(Information.FORCE_SHOCK, forceValue);
            
        end
        
        
    end
    
end