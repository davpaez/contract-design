classdef Rule_4 < managers.DecisionRule
    %{
    Related player: Agent
    Related action: Voluntary maintenance
    Class name: Rule_4
    Index: 4
    Name: Prediction time before inspection
    ID: agentBehavior.voluntaryMaint.Rule_4
    Type of rule:
        * Sensitive
        * Deterministic
        * Absolute
    
    Parameters:
        * 
    
    Input:
        * pastInspectionTimes
        * currentTime
    
    Output:
        * timeNextMaintenance
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_4
    %}
    
    properties (Constant, Hidden = true)
        % Names or parameters in order
        
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        finalMaint = false
        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
    
    methods
        %% Constructor
        
        function thisRule = Rule_4()
            thisRule@managers.DecisionRule();
            
            import managers.*
            
            % Set index
            thisRule.setIndex(4);
            
            % Set name
            thisRule.setName('Prediction time before inspection');
            
            % One decision variable: Time of voluntary maintenance
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.TIME_VOL_MAINT });
            
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
            import dataComponents.Message
            
            %TODO Improve bugs
            %TODO Figure out the conditions that a rule must have to not
            %make the program cycle indefinitely
            
            theAgent = theMsg.getExecutor();
            contractDuration = theAgent.contract.duration;
            solver = theMsg.getExtraInfo(Message.SOLVER);
            perfThreshold = theAgent.contract.perfThreshold;
            currentPerf = solver.realization.infrastructure.getPerformance();
            
            isViolating = currentPerf < perfThreshold;
            
            inspEvents = theAgent.eventList.getEventsOfType(Event.INSPECTION);
            
            if isempty(inspEvents) || length(inspEvents.time) < 3
                if isViolating
                    timeNextVolMaint = theAgent.time + 0.1;
                else
                    try
                        timeNextVolMaint = solver.solveTime(perfThreshold);
                    catch
                        timeNextVolMaint = theAgent.time + 0.1;
                    end
                end
            else
                
                interval = mean(diff(inspEvents.time));
                
                guessNextInspection = inspEvents.time(end) + interval;
                if guessNextInspection < contractDuration
                    guessInspectionTimes = guessNextInspection:interval:contractDuration;
                else
                    guessInspectionTimes = [];
                end
                
                index = [];
                for i=1:length(guessInspectionTimes) %
                    perf = solver.solvePerformance(guessInspectionTimes(i));
                    if perf < perfThreshold
                        index = i;
                        break
                    end
                end
                
                if isempty(index)
                    timeNextVolMaint = contractDuration;
                else
                    timeNextVolMaint = guessInspectionTimes(index) - 0.2;
                end
                
                if timeNextVolMaint <= theAgent.time
                    if isViolating
                        timeNextVolMaint = theAgent.time + 0.1;
                    else
                        try
                            timeNextVolMaint = solver.solveTime(perfThreshold);
                        catch
                            timeNextVolMaint = theAgent.time + 0.1;
                        end
                    end
                end
                
%                 timeLastInsp = inspEvents.time(end);
%                 lastVolMaintEvent = theAgent.eventList.getLastEventOfType(Event.VOL_MAINT);
            end
            
                
            if timeNextVolMaint <= theAgent.time
                timeNextVolMaint = theAgent.time + 0.1;
            end
            
            if abs(timeNextVolMaint - theAgent.time) < 1e-3
                timeNextVolMaint = theAgent.time + 0.1;
            end
            
            theMsg.submitResponse(Information.TIME_VOL_MAINT, timeNextVolMaint);
            
        end
        
        
    end
    
end