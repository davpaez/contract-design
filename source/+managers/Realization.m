classdef Realization < matlab.mixin.Copyable
    
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
        
        paymentSchedule % Payment schedule object
        
        fileInfo
        
        % Function handles
        fh = struct
    end
        
    %% Static methods
    methods (Static)
        
    end
    
    methods
        %% Constructor
        
        
        function self = Realization(progSet)
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
            self.fileInfo = progSet.returnItemSetting(ItemSetting.FILE_INFO);
            
            % Problem object
            self.problem = Problem(progSet);
            

            % Intial payoffs
            % TODO Terminar schedule de pagos para contribuciones del
            % gobierno
            
            
            % Construction of principal, agent
            self.principal = Principal(progSet, self.problem);
            self.agent = Agent(progSet, self.problem);
                        
            % Creation and distribution of contract
            con = self.principal.generateContract(progSet);
            
            self.contract = con;
            self.principal.receiveContract(con);
            self.agent.receiveContract(con);
            
            % Creating function handles
            %{
            thisRlz.fh.contEnvForce = progSet.returnItemSetting(ItemSetting.FILE_INFO);
            thisRlz.fh.demandRate = progSet.returnItemSetting(ItemSetting.FILE_INFO);
            thisRlz.fh.revenueRate = progSet.returnItemSetting(ItemSetting.FILE_INFO);
            thisRlz.fh.contResponse = progSet.returnItemSetting(ItemSetting.CONT_RESP_FNC);
            %}
            
            % Contruction of nature
            self.nature = Nature(progSet);
            
            % Initial observation
            initObs = self.nature.infrastructure.getObservation();
            
            % Realization schedule
            self.paymentSchedule = self.contract.paymentSchedule;
            
            % Construction of INIT event structs for principal and agent  
            initEventPrincipal = Event(self.time, Event.INIT, initObs, []);
            initEventAgent = Event(self.time, Event.INIT, initObs, []);
            
            % Registration of INIT events for principal and agent
            self.principal.registerEvent(initEventPrincipal);
            self.agent.registerEvent(initEventAgent);
            
        end
        
        
        function run(self)
        %{
        
            Input
                
            Output
                
        %}
            import entities.*
            import dataComponents.*
            
            contractDuration = self.contract.contractDuration;
            
            % Build interaction
            
            while self.time < contractDuration
                
                % Returns earliest submitted operation
                operation = self.requestOperations();
                nextTransaction = self.paymentSchedule.getNextTransaction();
                
                if operation.time >= contractDuration && nextTransaction.time >= contractDuration
                    break
                end
                
                if operation.time < nextTransaction.time
                    
                    assert(operation.time >= self.time)
                    
                    % Executes the earliest submitted operation
                    self.executeOperation(operation);                    
                else
                    
                    self.executePayment(nextTransaction);
                end
            end
            
            self.finishRealization();
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
            import dataComponents.Transaction
            
            mandMaintFlag = false;
            
            % Evolve the system up to the time of the operation to be
            % executed
            if operation.time > thisRlz.time
                thisRlz.evolveContinuously(operation.time);
            end
            
            % Execute the operation (execute discrete action)
            if isa(operation, 'Operation')
                
                switch operation.type
                    case Operation.INSPECTION
                        [timeExecution , mandMaintFlag] = ...
                            thisRlz.executeInspection(operation);
                        
                    case Operation.VOL_MAINT
                        timeExecution = thisRlz.executeVolMaint(operation);
                        
                    case Operation.SHOCK
                        timeExecution = thisRlz.executeShock(operation);
                        
                end
                
            elseif isa(operation, 'Transaction')
                
                timeExecution = thisRlz.executePayment(operation);
                
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
        
        
        function [timeExecution, mandMaintFlag] = executeInspection(self, operation)
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
        
            import dataComponents.Transaction
            import dataComponents.Observation
            import dataComponents.Event
            
            % Inform the Principal that this inspection operation was executed
            self.principal.confirmExecutionSubmittedOperation(operation);
            
            timeInspection = operation.time;
            mandMaintFlag = false;
            
            % Creates payoff struct for the Principal
            inspectionCost = self.principal.costSingleInspection;
            
            tran = Transaction(...
                timeInspection, ...
                inspectionCost, ...
                Transaction.INSPECTION);
            
            % Creates observation struct
            perf = self.nature.solvePerformanceForTime(timeInspection);
            
            obs = Observation(timeInspection, perf);
            
            % Normal inspection or detection
            if perf >= self.contract.perfThreshold  % It is a regular inspection
                
                % Inspection event
                inspectionEvent = Event(...
                    timeInspection, ...
                    Event.INSPECTION, ...
                    obs, ...
                    tran);
                
                % Register event for principal and agent
                self.principal.registerEvent(inspectionEvent);
                self.agent.registerEvent(inspectionEvent);
                
            else  % It is a detection
                import dataComponents.Message
                import managers.Information
                
                % Calculates penalty fee from contract
                msg = Message(self.principal);
                msg.setTypeRequestedInfo(Information.VALUE_PENALTY_FEE);
                msg.setExtraInfo(Message.TIME_DETECTION, timeInspection);
                
                self.contract.penaltyAction.decide(msg);
                
                penaltyFee = msg.getOutput(Information.VALUE_PENALTY_FEE);
                
                % Appending the income (penalty fee) to the principal's
                % payoff struct
                
                %TODONEXT: How to add two transactions into an event?
                pffPrincipal.value(end+1) = penaltyFee;
                pffPrincipal.type{end+1} = Transaction.PENALTY;
                
                penaltyTran = Transaction(...
                    timeInspection, ...
                    penaltyFee, ...
                    Transaction.PENALTY);
                
                % Creates and registers detection event for the principal
                detectionEvent = Event(...
                    timeInspection, ...
                    Event.DETECTION, ...
                    obs, ...
                    penaltyTran);
                
                % Registers detection event for the principal and agent
                self.principal.registerEvent(detectionEvent);
                self.agent.registerEvent(detectionEvent);
                
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
        
            import dataComponents.Transaction
            import dataComponents.Observation
            import dataComponents.Event
            
            % Inform the Agent that this volMaint operation was executed
            thisRlz.agent.confirmExecutionSubmittedOperation(operation);
            
            timeVolMaint = operation.time;
            perfGoal = operation.perfGoal;
            
            perfBeforeMaint = thisRlz.nature.solvePerformanceForTime(timeVolMaint);
            
            % Creates observation object before and after Maintenance
            obs = Observation(timeVolMaint, [perfBeforeMaint, perfGoal]);
            
            % Creates the outcome payoff struct of the agent
            costMaintenance = thisRlz.agent.maintCostFunction(perfBeforeMaint, perfGoal);
            
            maintTransaction = Transaction(...
                timeVolMaint, ...
                costMaintenance, ...
                Transaction.MAINTENANCE);
            
            % Applies maintenance operation to Infrastructure
            thisRlz.nature.applyOperation(operation);
            
            % Creates and registers voluntary maintenance event for the
            % agent
            volMaintEvent_Agent = Event(...
                timeVolMaint, ...
                Event.VOL_MAINT, ...
                obs, ...
                maintTransaction);
            
            thisRlz.agent.registerEvent(volMaintEvent_Agent);
            
            timeExecution = timeVolMaint;
        end
        
        
        function timeExecution = executeMandMaint(thisRlz)
        %{
        * 
        
            Input
                
            Output
                
        %}
        
            import dataComponents.Transaction
            import dataComponents.Observation
            import dataComponents.Operation
            import dataComponents.Event
            import dataComponents.Message
            import managers.Information
            
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
            pffAgent.type{1} = Transaction.MAINTENANCE;
            
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
            perfBeforeShock = thisRlz.nature.solvePerformanceForTime(operation.time);
            
            obs = Observation(...
                operation.time, ...
                perfBeforeShock);
            
            % Applies shock operation to Infrastructure
            thisRlz.nature.applyOperation(operation);
            
            % Creates and registers shock event for the agent
            shockEvent = Event(...
                operation.time, ...
                Event.SHOCK, ...
                obs, ...
                []);
            
            thisRlz.agent.registerEvent(shockEvent);
            
            timeExecution = operation.time;
            
        end
        
        
        function timeExecution = executePayment(thisRlz, transaction)
        %{
        * 

            Input

            Output

        %}
            import dataComponents.Event
            
            assert(thisRlz.time == transaction.time)
            
            [emitter, receiver] = transaction.returnEmitterReceiver(thisRlz.principal, thisRlz.agent);
            
            ev = Event(transaction.time, Event.CONTRIBUTION, [], transaction);
            
            % Emitter end receiver register the event
            if ~isempty(emitter)
                emitter.registerEvent(ev);
            end
            
            if ~isempty(receiver)
                receiver.registerEvent(ev);
            end
            
        end
        
        
        function validateOperation(thisRlz, operation)
        %{
        * 
        
            Input
                
            
            Output
                
        %}
            assert(operation.time >= thisRlz.time, ...
                'This operation must have an execution time greater or equal than the current time in the realization')
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
            
            % Performance rate function
            v_f = @(t,v) contRespFun(contEnvForce(t), ...
                demand(v, fare), ...
                v, ...
                t);
            
            % Demand rate function
            d_f = @(v) demand(v, fare);
            
            % Agent's balance rate function
            ba_f = @(v) revenue(demand(v, fare), fare);
            
            fun = @(t,x) [v_f(t,x(1));  d_f(x(1)); ba_f(x(1))];
            
            currentPerf = thisRlz.nature.infrastructure.getPerformance();
            initialDemand = 0; %TODO Current value of demand
            currentAgentBalance = -400; % TODO Current agent's balance
            
            [t,x] = ode45(fun, [thisRlz.time, tf], [currentPerf; initialDemand; currentAgentBalance]);
            
            perf = x(:,1);
            demand = x(:,2);
            agentBalance = x(:,3);
            
            thisRlz.nature.infrastructure.evolve(t, perf);
        end
        
        
        function finishRealization(thisRlz)
        %{
        * 
        
            Input
                
            Output
               
            TODO: Make players finalize interaction via a process different
            from register a ficticious payoff.
        %}
        
            import dataComponents.Transaction
            import dataComponents.Event
            
            contractDuration = thisRlz.contract.getContractDuration();
            
            % Final (fictitious) payoff
            finalPff = struct();
            finalPff.value = 0;
            finalPff.duration = 0;
            finalPff.type{1} = Transaction.FINAL;
            
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
        
        
        function [emitter, receiver] = getEmitterReceiver(thisRlz, transaction)
            import managers.Information
            
            if strcmp(transaction.emitter, Information.PRINCIPAL)
                emitter = thisRlz.principal;
            elseif strcmp(transaction.emitter, Information.AGENT)
                emitter = thisRlz.agent;
            else
                error('Emitter should be either PRINCIPAL or AGENT')
            end
            
            
            if strcmp(transaction.receiver, Information.PRINCIPAL)
                receiver = thisRlz.principal;
            elseif strcmp(transaction.receiver, Information.AGENT)
                receiver = thisRlz.agent;
            else
                error('Receiver should be either PRINCIPAL or AGENT')
            end
            
        end
        
        
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
            %earliestOp.setAsPending();
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

