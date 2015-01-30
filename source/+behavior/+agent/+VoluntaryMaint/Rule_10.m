classdef Rule_10 < managers.DecisionRule
    %{
    Related player: Agent
    Related action: Voluntary maintenance
    Class name: Rule_10
    Index: 10
    Name: Perfect Voluntary Maintenance
    ID: agentBehavior.voluntaryMaint.Rule_10
    Type of rule:
        * Sensitive
        * Deterministic
        * Absolute
    
    Parameters:
        * 
    
    Input:
        * maxPerf
    
    Output:
        * performanceGoal
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_1
        * Strategy_2
    %}
    
    properties (Constant, Hidden = true)
        % Names or parameters in order
        
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
            thisRule.setName('Perfect Voluntary Maintenance');

            % One decision variable: Performance goal of maintenance
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.PERF_VOL_MAINT });
            
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
        function mainAlgorithm(~, theMsg)
            import managers.Information
            
            maxPerf = theMsg.getExtraInfo(theMsg.MAX_PERF);
            theMsg.submitResponse(Information.PERF_VOL_MAINT, maxPerf);
            
        end
        
        
    end
    
end