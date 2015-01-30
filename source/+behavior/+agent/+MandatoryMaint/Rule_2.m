classdef Rule_2 < managers.DecisionRule
    %{
    Related player: Agent
    Related action: Mandatory maintenance
    Class name: Rule_2
    Index: 2
    Name: Minimum Mandatory Maintenance
    ID: agentBehavior.mandatoryMaint.Rule_2
    Type of rule:
        * Insensitive
        * Deterministic
        * Delta
    
    Parameters:
        * 
    
    Input:
        * 
    
    Output:
        * deltaPerfAboveThreshold
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_1
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
        
        function thisRule = Rule_2()
            thisRule@managers.DecisionRule();
            
            import managers.*
            
            % Set index
            thisRule.setIndex(2);
            
            % Set name
            thisRule.setName('Minimum Mandatory Maintenance');
			
            % One decision variable: PerfGoal mandatory maintenance
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.PERF_MAND_MAINT });
            
            % Set as Insensitive
            thisRule.setTypeRule_Sensitivity(DecisionRule.INSENSITIVE);
            
            % Set as Deterministic
            thisRule.setTypeRule_Determinacy(DecisionRule.DETERMINISTIC);

            % Type of output produced by this rule
            thisRule.setTypeRule_Output({ DecisionRule.DELTA_VALUE });
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
        * Minimum valid mandatory maintenance. This rule returns the minimum additional performance above the performance threshold. In other words, it causes the agent to maintain the system to a performance exactly equal to the performance threshold.
		
            Input
                theAgent: [class Agent] Agent object that is utilizing this strategy.
				
				inputStructInfo: [class struct] Structure created and passed by Realization which contains information that may be useful to calculate output of this rule.
            Output
                deltaPerfAboveThreshold: [class double] Real value representing the value of performance additional to the threshold to be exerted on the infrastructure system.
        %}
        function mainAlgorithm(~, theMsg)
            import managers.Information
            
            deltaPerfAboveThreshold = 0;
            theMsg.submitResponse(Information.PERF_MAND_MAINT, deltaPerfAboveThreshold);
            
        end
        
        
    end
    
end