classdef Realization < matlab.mixin.Copyable
    %REALIZATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        
    end
    
    properties
        % ----------- %
        % Attributes
        % ----------- %
        time = 0
        
        printStatus = false
        
        % ----------- %
        % Objects
        % ----------- %
        principal
        agent
        nature
        contract
        problem
        
        fileInfo
        
        % Function handles
        fh = struct
    end
        
    %% Static methods
    methods (Static)
        
    end
    
    methods
        %% Constructor
        
        
        function thisRlz = Realization(progSet)
        %{
        * Constructor method of Realization class and builder of
        interactions
        
            Input
                principalProfile: [class struct] Contains data to build the
                principal object
                
                contract: [class Contract] Contract object
                
                naturalHazard: [class bool] Turns on and off the natural
                hazard induced by nature
                
                initialPerformance: [class double] performance V at time=0
                
            Output
                thisRlz: [class Realization] Realization object
        %}
        
            import entities.*
            import dataComponents.*
            import managers.*
            
            % Get fileInfo handle
            thisRlz.fileInfo = progSet.returnItemSetting(ItemSetting.FILE_INFO);
            
            % Creating local copies of 
            thisRlz.contract = Contract(progSet);
            thisRlz.problem = Problem(progSet);
            
            % Creating function handles
            thisRlz.fh.contEnvForce = progSet.returnItemSetting(ItemSetting.FILE_INFO);
            thisRlz.fh.demandRate = progSet.returnItemSetting(ItemSetting.FILE_INFO);
            thisRlz.fh.revenueRate = progSet.returnItemSetting(ItemSetting.FILE_INFO);
            thisRlz.fh.contResponse = progSet.returnItemSetting(ItemSetting.FILE_INFO);
            
            % Intial payoffs
            
                contractDuration = thisRlz.contract.getContractDuration();
                revenueFlowRate = thisRlz.contract.getRevenue() / contractDuration;
                
                % Payoffs principal
                % Government contributions
                prinPff = struct();
                prinPff.value = -thisRlz.contract.getContribution();
                prinPff.duration = 0;
                prinPff.type{1} = Payoff.CONTRIBUTION;
                
                % Revenue
                prinPff.value(end+1) = -revenueFlowRate;
                prinPff.duration(end+1) = contractDuration;
                prinPff.type{end+1} = Payoff.REVENUE;
                
                % Payoffs agent
                % Government contributions
                agPff = struct();
                agPff.value = thisRlz.contract.getContribution();
                agPff.duration = 0;
                agPff.type{1} = Payoff.CONTRIBUTION;
                
                % Revenue
                agPff.value(end+1) = revenueFlowRate;
                agPff.duration(end+1) = contractDuration;
                agPff.type{end+1} = Payoff.REVENUE;
                
                % Investment
                agPff.value(end+1) = -thisRlz.contract.getInvestment();
                agPff.duration(end+1) = 0;
                agPff.type{end+1} = Payoff.INVESTMENT;
            
            
            % Initial observation
            initObs = thisRlz.contract.getInitialPerfObs();
            
            
            % Construction of principal, agent and nature
            thisRlz.principal = Principal(  progSet, ...
                                                    thisRlz.contract, ...
                                                    thisRlz.problem     );
                                                
            thisRlz.agent = Agent(  progSet, ...
                                            thisRlz.contract, ...
                                            thisRlz.problem     );
                                        
            thisRlz.nature = Nature(progSet, ...
                                            thisRlz.contract);
            
            % Construction of INIT event structs for principal and agent            
            initEventPrincipal = struct();
            initEventPrincipal.time = 0;
            initEventPrincipal.type = Event.INIT;
            initEventPrincipal.obs = initObs;
            initEventPrincipal.pff = prinPff;
            
            initEventAgent = struct();
            initEventAgent.time = 0;
            initEventAgent.type = Event.INIT;
            initEventAgent.obs = initObs;
            initEventAgent.pff = agPff;
            
            % Registration of INIT events for principal and agent
            thisRlz.principal.registerEvent(initEventPrincipal);
            thisRlz.agent.registerEvent(initEventAgent);
            
        end
        
        
        function run(thisRlz)
        %{
        
            Input
                
            Output
                
        %}
            import entities.*
            import dataComponents.*
            
            contractDuration = thisRlz.contract.getContractDuration();
            
            % Build interaction
            
            while thisRlz.time < contractDuration
                
                thisRlz.fileInfo.printLog('   --------------------------------    \n\n');
                thisRlz.fileInfo.printLog(['Current model time before request: ',num2str(thisRlz.time),'\n']);
                
                % Returns earliest submitted operation
                operation = thisRlz.requestOperations();
                
                thisRlz.fileInfo.printLog('Operation requested and returned\n')
                
                if operation.time >= contractDuration
                    break
                end
                
                thisRlz.fileInfo.printLog( ...
                    ['Performance before operation execution ',num2str(thisRlz.nature.solvePerformanceForTime(operation.time)),'\n']);
                
                assert(operation.time > thisRlz.time)
                
                
                
                % Executes the earliest submitted operation
                thisRlz.executeOperation(operation);
                
                thisRlz.fileInfo.printLog( ...
                    ['Current model time after request: ',num2str(thisRlz.time),'\n\n']);
                thisRlz.fileInfo.printLog( ...
                    'Operation executed\n\n');
                thisRlz.fileInfo.printLog( ...
                    ['Performance after operation ',num2str(thisRlz.nature.getCurrentPerformance()),'\n\n'])
                
            end
            
            thisRlz.finishRealization();
        end
        
        
        %% Getter funcions
        
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        function time = getTime(thisRlz)
        %{
        * Returns the current time attribute of thisRlz
        
            Input
                None
                
            Output
                time: [class double] Value of time attribute of
                thisRlz
        %}
        
            time = thisRlz.time;
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------
        % ----------------------------------------------------------------
        
        
        function setTime(thisRlz, time)
        %{
        * Updates time of the Realization object only
        
            Input
                time: [class double] New updated value of time
                
            Output
                None
        %}
        
            if time > thisRlz.time
                thisRlz.time = time;
            end
        end
        
        
        function updateTimeAll(thisRlz, newTime)
        %{
        * Updates time of ALL objects of model including Realization
        
            Input
                newTime: [class double] New updated value of time
                
            Output
                None
        %}
        
            thisRlz.setTime(newTime);
            
            thisRlz.agent.setTime(newTime);
            thisRlz.principal.setTime(newTime);
            thisRlz.nature.setTime(newTime);
        end
        
        
        function executeOperation(thisRlz, operation)
        %{
        * Executes operation passed by argument
        %TODO Inform the strategies whether their last output was executed!
            Input
                operation: [class Operation] Operation to be executed
                
            Output
                None
        %}
        
            import dataComponents.Operation
            
            mandMaintFlag = false;
            
            % Evolve the system up to the time of the operation to be
            % executed
            thisRlz.evolveContinuously(operation.time);
            
            % Execute the operation (execute discrete action)
            
            switch operation.type
                case Operation.INSPECTION
                    [timeExecution , mandMaintFlag] = ...
                        thisRlz.executeInspection(operation);
                    
                case Operation.VOL_MAINT
                    timeExecution = thisRlz.executeVolMaint(operation);
                    
                case Operation.SHOCK
                    timeExecution = thisRlz.executeShock(operation);
            end
            
            % Update time for ALL entities
            thisRlz.updateTimeAll(timeExecution);
            
            if mandMaintFlag == true
                
                timeExecutionMandMaint = thisRlz.executeMandMaint();
                
                % Update time for ALL entities having executed the
                % mandatory maintenance
                thisRlz.updateTimeAll(timeExecutionMandMaint);
            end
        end
        
        
        function [timeExecution, mandMaintFlag] = executeInspection(thisRlz, operation)
        %{
        * Executes inspection operation object passed in argument
        
            Input
                operation: [class Operation] Operation to be executed
            Output
                timeExecution: [class double] Expected execution time of
                the generated inspection
        
                mandMaintFlag: [class boolean] True if the inspection
                triggered a mandatory maintenance, false otherwise.
        %}
        
            import dataComponents.Payoff
            import dataComponents.Observation
            import dataComponents.Event
            
            % Inform the Principal that this inspection operation was executed
            thisRlz.principal.confirmExecutionSubmittedOperation(operation);
            
            timeInspection = operation.time;
            mandMaintFlag = false;
            
            % Creates payoff struct for the Principal
            inspectionCost = thisRlz.principal.costSingleInspection;

            pffPrincipal = struct();
            pffPrincipal.value = -inspectionCost;
            pffPrincipal.type{1} = Payoff.INSPECTION;
            
            % Creates observation struct
            perf = thisRlz.nature.solvePerformanceForTime(timeInspection);

            obs = struct();
            obs.value = perf;
            
            % Normal inspection or detection
            perfThreshold = thisRlz.contract.getPerfThreshold();
            
            if perf >= perfThreshold  % It is a regular inspection
                
                % Inspection event for the principal
                inspectionEvent_Principal = struct();
                inspectionEvent_Principal.time = timeInspection;
                inspectionEvent_Principal.type = Event.INSPECTION;
                inspectionEvent_Principal.obs = obs;
                inspectionEvent_Principal.pff = pffPrincipal;
                
                thisRlz.principal.registerEvent(inspectionEvent_Principal);
                
                % Inspection event for the agent
                inspectionEvent_Agent = struct();
                inspectionEvent_Agent.time = timeInspection;
                inspectionEvent_Agent.type = Event.INSPECTION;
                inspectionEvent_Agent.obs = obs;
                
                % Register the event for the agent
                thisRlz.agent.registerEvent(inspectionEvent_Agent);
                
            else  % It is a detection
                import dataComponents.Message
                import managers.Information
                
                thisRlz.fileInfo.printLog('Violation detected: DETECTION EVENT\n')
                
                % Calculates penalty fee from contract
                msg = Message(thisRlz.principal);
                msg.setTypeRequestedInfo(Information.VALUE_PENALTY_FEE);
                msg.setExtraInfo(Message.TIME_DETECTION, timeInspection);
                
                thisRlz.contract.penaltyAction.decide(msg);
                
                penaltyFee = msg.getOutput(Information.VALUE_PENALTY_FEE);
                
                thisRlz.fileInfo.printLog(['Penalty imposed: ',num2str(penaltyFee),'\n'])
                
                % Appending the income (penalty fee) to the principal's
                % payoff struct
                pffPrincipal.value(end+1) = penaltyFee;
                pffPrincipal.type{end+1} = Payoff.PENALTY;
                
                
                % Creation payoff struct for the agent
                pffAgent = struct();
                pffAgent.value = -penaltyFee;
                pffAgent.type{1} = Payoff.PENALTY;
                
                % Creates and registers detection event for the principal
                detectionEvent_Principal = struct();
                detectionEvent_Principal.time = timeInspection;
                detectionEvent_Principal.type = Event.DETECTION;
                detectionEvent_Principal.obs = obs;
                detectionEvent_Principal.pff = pffPrincipal;
                
                thisRlz.principal.registerEvent(detectionEvent_Principal);
                
                % Creates and registers detection event for the agent
                detectionEvent_Agent = struct();
                detectionEvent_Agent.time = timeInspection;
                detectionEvent_Agent.type = Event.DETECTION;
                detectionEvent_Agent.obs = obs;
                detectionEvent_Agent.pff = pffAgent;
                
                thisRlz.agent.registerEvent(detectionEvent_Agent);
                
                mandMaintFlag = true;
            end
            
            timeExecution = timeInspection;
        end
        
        
        function timeExecution = executeVolMaint(thisRlz, operation)
        %{
        * 
        
            Input
                
            Output
                
        %}
        
            import dataComponents.Payoff
            import dataComponents.Observation
            import dataComponents.Event
            
            % Inform the Agent that this volMaint operation was executed
            thisRlz.agent.confirmExecutionSubmittedOperation(operation);
            
            timeVolMaint = operation.time;
            perfGoal = operation.perfGoal;
            
            perfBeforeMaint = thisRlz.nature.solvePerformanceForTime(timeVolMaint);
            
            % Creates observation struct before and after Maintenance
            obs = struct();
            obs.value = [perfBeforeMaint, perfGoal];
            
            % Creates the outcome payoff struct of the agent
            costMaintenance = thisRlz.agent.maintCostFunction(perfBeforeMaint, perfGoal);
            
            pffAgent = struct();
            pffAgent.value = -costMaintenance;
            pffAgent.type{1} = Payoff.MAINTENANCE;
            
            thisRlz.fileInfo.printLog(['Cost voluntary maintenance: ',num2str(costMaintenance),'\n'])
            
            % Applies maintenance operation to Infrastructure
            thisRlz.nature.applyOperation(operation);
            
            % Creates and registers voluntary maintenance event for the
            % agent
            volMaintEvent_Agent = struct();
            volMaintEvent_Agent.time = timeVolMaint;
            volMaintEvent_Agent.type = Event.VOL_MAINT;
            volMaintEvent_Agent.obs = obs;
            volMaintEvent_Agent.pff = pffAgent;
            
            thisRlz.agent.registerEvent(volMaintEvent_Agent);
            
            timeExecution = timeVolMaint;
            
        end
        
        
        function timeExecution = executeMandMaint(thisRlz)
        %{
        * 
        
            Input
                
            Output
                
        %}
        
            import dataComponents.Payoff
            import dataComponents.Observation
            import dataComponents.Operation
            import dataComponents.Event
            import dataComponents.Message
            import managers.Information
            
            thisRlz.fileInfo.printLog('MANDATORY MAINTENANCE:\n')
            
            timeDetection = thisRlz.principal.observation.getCurrentTime();
            perfDetection = thisRlz.principal.observation.getCurrentValue();
            
            maxPerf = thisRlz.nature.infrastructure.maxPerf;
            perfThreshold = thisRlz.contract.getPerfThreshold();
            
            % Strategy calculates performance goal
            msg = Message(thisRlz.agent);
            msg.setTypeRequestedInfo(Information.PERF_MAND_MAINT);
            msg.setExtraInfo(   Message.MAX_PERF, maxPerf, ...
                                Message.TIME_DETECTION, timeDetection, ...
                                Message.PERF_DETECTION, perfDetection);
            
            thisRlz.agent.mandMaintAction.decide(msg);
            
            deltaPerfAboveThreshold = msg.getOutput(Information.PERF_MAND_MAINT);
            
            assert(deltaPerfAboveThreshold >= 0, 'The value of deltaPerfAboveThreshold must be non-negative')
            
            perfGoal = perfThreshold + deltaPerfAboveThreshold;
            assert(perfGoal <= maxPerf, ...
                'The value of the performance goal must be within [nullPerf, maxPerf]')
            
            % Creates the outcome payoff object of the agent
            costMaintenance = thisRlz.agent.maintCostFunction(perfDetection, perfGoal);

            pffAgent = struct();
            pffAgent.value = -costMaintenance;
            pffAgent.type{1} = Payoff.MAINTENANCE;
            
            thisRlz.fileInfo.printLog(['Cost mandatory maintenance: ',num2str(costMaintenance),'\n'])
            
            % Creates maintenance operation object
            mandMaintOperation = Operation(timeDetection, Operation.MAND_MAINT, true, ...
                perfGoal);
            
            % Applies maintenance operation to Infrastructure
            thisRlz.nature.applyOperation(mandMaintOperation);
            
            % Creates observation objects (at current time) for the principal
            perfAfterMaint = thisRlz.nature.getCurrentPerformance();
            assert(perfAfterMaint == perfGoal, ...
                'The observed performance must be equal to the perfGoal of the applied mandatory maintenance operation');
            
            obs = struct();
            obs.value = perfAfterMaint;
            
            % Creates and registers mandatory maintenance event for the principal
            mandMaintEvent_Principal = struct();
            mandMaintEvent_Principal.time = timeDetection;
            mandMaintEvent_Principal.type = Event.MAND_MAINT;
            mandMaintEvent_Principal.obs = obs;
            
            thisRlz.principal.registerEvent(mandMaintEvent_Principal);
            
            % Creates and registers mandatory maintenance event for the
            % agent
            mandMaintEvent_Agent = struct();
            mandMaintEvent_Agent.time = timeDetection;
            mandMaintEvent_Agent.type = Event.MAND_MAINT;
            mandMaintEvent_Agent.obs = obs;
            mandMaintEvent_Agent.pff = pffAgent;
            
            thisRlz.agent.registerEvent(mandMaintEvent_Agent);
            
            timeExecution = timeDetection;
        end
        
        
        function timeExecution = executeShock(thisRlz, operation)
        %{
        * 
        
            Input
                
            Output
                
        %}
        
            import dataComponents.Observation
            import dataComponents.Event
            
            % Inform Nature that this shock operation was executed
            thisRlz.nature.confirmExecutionSubmittedOperation(operation);
            
            % Creates observation object
            perf = thisRlz.nature.solvePerformanceForTime(operation.time);
            
            obs = struct();
            obs.value = perf;
            
            % Applies shock operation to Infrastructure
            thisRlz.nature.applyOperation(operation);
            
            % Creates and registers shock event for the agent
            shockEvent = struct();
            shockEvent.time = operation.time;
            shockEvent.type = Event.SHOCK;
            shockEvent.obs = obs;
            
            thisRlz.agent.registerEvent(shockEvent);
            
            timeExecution = operation.time;
            
        end
        
        
        function validateOperation(thisRlz, operation)
        %{
        * 
        
            Input
                
            
            Output
                
        %}
            assert(operation.time > thisRlz.time, ...
                'This operation must have an execution time greater than the current time in the realization')
        end
        
        
        function evolveContinuously(thisRlz, tf)
        %{
        * 
        
            Input
                
            
            Output
                
        %}
            %import utils.ContinuousSolver
            
            fare = 72/10e7;
            
            %  ------ Differential equations for stocks -------
            
            contEnvForce = @CommonFnc.continuousEnvForce;
            contRespFun = @CommonFnc.continuousRespFunction;
            demand = @CommonFnc.demandFunction;
            revenue = @CommonFnc.revenueRate;

            v_f = @(t,v) contRespFun(   contEnvForce(t), ...
                                        demand(v, fare), ...
                                        v, ...
                                        t);

            d_f = @(v) demand(v, fare);

            ba_f = @(v) revenue(demand(v, fare), fare);

            fun = @(t,x) [  v_f(t,x(1)); ...
                            d_f(x(1));...
                            ba_f(x(1))];
            
            currentPerf = thisRlz.nature.infrastructure.getPerformance();
            initialDemand = 0;
            currentAgentBalance = -400;
            
            [t,x] = ode45(fun, [thisRlz.time, tf], [currentPerf; initialDemand; currentAgentBalance]);
            
            %error('hola')
        end
        
        
        function finishRealization(thisRlz)
        %{
        * 
        
            Input
                
            Output
               
            TODO: Make players finalize interaction via a process different
            from register a ficticious payoff.
        %}
        
            import dataComponents.Payoff
            import dataComponents.Event
            
            contractDuration = thisRlz.contract.getContractDuration();
            
            % Final (fictitious) payoff
            finalPff = struct();
            finalPff.value = 0;
            finalPff.duration = 0;
            finalPff.type{1} = Payoff.FINAL;
            
            % Final event
            finalEvent = struct();
            finalEvent.time = contractDuration;
            finalEvent.type = Event.FINAL;
            finalEvent.pff = finalPff;
            
            % Finalize history infrastructure
            thisRlz.nature.finalizeHistory(contractDuration);
            
            % Register FINAL event for Principal and Agent
            thisRlz.principal.registerEvent(finalEvent);
            thisRlz.agent.registerEvent(finalEvent);
            
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        
        function [ua, up] = utilityPlayers(thisRlz)
        %{
        * 
        
            Input
                None
            
            Output
                
        %}
            ua = thisRlz.agent.getUtility();
            up = thisRlz.principal.getUtility();
        end
        
        
        function earliestOp = requestOperations(thisRlz)
        %{
        * Requests players to submit their next action. Returns the
        player name and time of the earliest action submitted.
        
            Input
                None
            
            Output
                earliestOp: [class Operation] Operation object with earliest
                time
        %}
            currentPerf = thisRlz.nature.getCurrentPerformance();
            
            maxPerf = thisRlz.nature.infrastructure.maxPerf;
            nullPerf = thisRlz.nature.infrastructure.nullPerf;
            
            % Asking players to submit operations
            operationPrincipal = thisRlz.principal.submitOperation();
            thisRlz.validateOperation(operationPrincipal);
            
            copyInfra = copy(thisRlz.nature.infrastructure);
            operationAgent = thisRlz.agent.submitOperation(currentPerf, ...
                @thisRlz.solvePerformanceForTime, ...
                @thisRlz.solveTimeForPerformance, ...
                [nullPerf maxPerf], copyInfra);
            thisRlz.validateOperation(operationAgent);
            
            operationNature = thisRlz.nature.submitOperation();
            thisRlz.validateOperation(operationNature);
            
            earliestOp = returnEarliestOperation( operationPrincipal, ...
                                                  operationAgent, ...
                                                  operationNature );
            earliestOp.setAsPending();
        end
        
        
        function performance = solvePerformanceForTime(thisRlz, time)
        %{
        * Solves performance of infrastructure for a given time
        
            Input
                time: [class double] Time to solve performance for
                
            Output
                performance: [class double] Performance of infrastructure
                for a given time
        %}
            performance = thisRlz.nature.solvePerformanceForTime(time);
        end
        
        
        function time = solveTimeForPerformance(thisRlz, perf)
        %{
        * Solves time for a given infrastructure state
        
            Input
                performance: [class double] Performance of infrastructure
                for a given time
                
            Output
                time: [class double] Time to solve performance for
        %}
            time = thisRlz.nature.solveTimeForPerformance(perf);
        end
        
        
        function data = report(thisRlz)
        %{
        * 
        
            Input
                
            Output
                
        %}
            import dataComponents.Event
            
            [utilityAgent, utilityPrincipal] = thisRlz.utilityPlayers();
            contractDuration = thisRlz.contract.getContractDuration();
            
            data = struct(...
                'ua',                       utilityAgent, ...
                'up',                       utilityPrincipal, ...
                'contractDuration',         contractDuration, ...
                'threshold',                thisRlz.contract.getPerfThreshold(), ...
                'maxPerf',                  thisRlz.nature.infrastructure.maxPerf, ...
                'nullPerf',                 thisRlz.nature.infrastructure.nullPerf, ...
                'perfHistory' ,             thisRlz.nature.infrastructure.history.getData(), ...
                'inspectionMarker',         thisRlz.principal.eventList.getMarkersInfo(Event.INSPECTION, thisRlz.principal.observation), ...
                'detectionMarker',          thisRlz.principal.eventList.getMarkersInfo(Event.DETECTION, thisRlz.principal.observation), ...
                'volMaintMarker',           thisRlz.agent.eventList.getMarkersInfo(Event.VOL_MAINT, thisRlz.agent.observation), ...
                'shockMarker',              thisRlz.agent.eventList.getMarkersInfo(Event.SHOCK, thisRlz.agent.observation), ...
                'realPerfMeanValue',        thisRlz.nature.infrastructure.history.getMeanValueHistory(), ...
                'perceivedPerfMeanValue',   thisRlz.principal.observation.getMeanValueHistory(), ...
                'balP',                     thisRlz.principal.payoff.getBalanceHistory(contractDuration), ...
                'balA',                     thisRlz.agent.payoff.getBalanceHistory(contractDuration) );
        end
        
    end
    
end

%% Auxiliary functions


function [earliestOp, index] = returnEarliestOperation(opPrincipal, opAgent, opNature)
%{
* Returns the operation with earliest execution time

    Input
        opPrincipal: [class Operation]
        opAgent: [class Operation]
        opNature: [class Operation]

    Output
        earliestOp: [class Operation]
%}

    opArray = {opPrincipal, opAgent, opNature};
    timeArray = [opPrincipal.time, ...
        opAgent.time, ...
        opNature.time];
    
    [time, index] = min(timeArray);
    earliestOp = opArray{index};
end

