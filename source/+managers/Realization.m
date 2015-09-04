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
        infrastructure
        contract
        problem
        
        paymentSchedule % Payment schedule object
        demandHistory   % ObservationList object
        
        lastOperation % Last operation executed in realization
        
        fileInfo
        
        solver % Solver object
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Realization(progSet, prob)
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
                self: [class Realization] Realization object
        %}
        
            import entities.*
            import dataComponents.*
            import managers.*
            import utils.Solver
            
            % Get fileInfo handle
            self.fileInfo = progSet.returnItemSetting(ItemSetting.FILE_INFO);
            
            % Problem object
            self.problem = prob;
            
            % 
            self.demandHistory = ObservationList();

            % Intial payoffs
            % TODO Terminar schedule de pagos para contribuciones del
            % gobierno
            
            
            % Construction of principal, agent
            self.principal = Principal(progSet, self.problem);
            self.agent = Agent(progSet, self.problem);
            
            % Contruction of nature
            self.nature = Nature(progSet, self.problem);
            
            % Construction of infrastructure
            self.infrastructure = Infrastructure(progSet);
                        
            % Creation and distribution of contract
            con = self.principal.generateContract(progSet, self.infrastructure);
            
            self.contract = con;
            self.principal.receiveContract(con);
            self.agent.receiveContract(con);
            
            % Initial observation
            initObs = self.infrastructure.getObservation();
            
            % Realization schedule
            self.paymentSchedule = self.contract.paymentSchedule;
            
            % Construction of INIT event for principal and agent  
            initEventPrincipal = Event(self.time, Event.INIT, initObs, []);
            initEventAgent = Event(self.time, Event.INIT, initObs, []);
            
            % Registration of INIT events for principal and agent
            self.principal.registerEvent(initEventPrincipal);
            self.agent.registerEvent(initEventAgent);
            
            % Continuous solver object
            self.solver = Solver(progSet, self);
            
        end
        
        
		%% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************
        
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function setTime(self, time)
        %{
        * Updates time of the Realization object only
        
            Input
                time: [class double] New updated value of time
                
            Output
                None
        %}
        
            if time > self.time
                self.time = time;
            end
        end
        
        
        function updateTimeAll(self, newTime)
        %{
        * Updates time of ALL objects of model including Realization
        
            Input
                newTime: [class double] New updated value of time
                
            Output
                None
        %}
        
            self.setTime(newTime);
            
            self.agent.setTime(newTime);
            self.principal.setTime(newTime);
            self.nature.setTime(newTime);
        end
        
        
        function run(self)
        %{
        
            Input
                
            Output
                
        %}
            initialExecutionTime = clock;
            
            import entities.*
            import dataComponents.*
            
            contractDuration = self.contract.duration;
            
            % Build interaction
            
            while self.time < contractDuration
                
                % Returns earliest submitted operation
                operation = self.requestOperations();
                nextTransaction = self.paymentSchedule.getNextTransaction();
                
                earliestTime = getEarliestTime(operation, nextTransaction);
                
                if earliestTime >= contractDuration
                    break
                end
                
                if isempty(nextTransaction)
                    self.executeOperation(operation);
                else
                    if operation.time < nextTransaction.time
                        self.executeOperation(operation);
                    else
                        self.executePayment(nextTransaction);
                    end
                end
            end
            
            self.finishRealization();
        end
        
        
        function executeOperation(self, operation)
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
            
            % Check operation time makes sense
            assert(operation.time >= self.time)
            
            % Evolve the system up to the time of the operation to be
            % executed
            if ~isempty(self.lastOperation) && operation.time == self.lastOperation.time
                self.validateOperationAdjacency(operation);
            end
            
            if operation.time > self.time
                self.evolveContinuously(operation.time);
            end
            
            % Execute the operation (execute discrete action)
            switch operation.type
                case Operation.INSPECTION
                    [timeExecution , mandMaintFlag] = ...
                        self.executeInspection(operation);
                    self.principal.clearSubmittedOperation();
                    
                case Operation.VOL_MAINT
                    timeExecution = self.executeVolMaint(operation);
                    self.agent.clearSubmittedOperation();
                    
                case Operation.SHOCK
                    timeExecution = self.executeShock(operation);
                    self.nature.clearSubmittedOperation();
                    
            end
            
%             operation.type
%             operation.time
%             disp('')
            
            % Update time for ALL entities
            self.updateTimeAll(timeExecution);
            
            if mandMaintFlag == true
                
                timeExecutionMandMaint = self.executeMandMaint();
                
                % Update time for ALL entities having executed the
                % mandatory maintenance
                self.updateTimeAll(timeExecutionMandMaint);
            end
            
            self.lastOperation = operation;
        end
        
        
        function validateOperationAdjacency(self, operation)
            import dataComponents.Operation
            
            if ~isempty(self.lastOperation)
                if self.lastOperation.isType(Operation.INSPECTION)
                    test1 = operation.isType(Operation.MAND_MAINT);
                    test2 = operation.isType(Operation.SHOCK);
                    assert(test1 || test2)
                elseif self.lastOperation.isType(Operation.VOL_MAINT)
                    assert(operation.isType(Operation.SHOCK))
                elseif self.lastOperation.isType(Operation.MAND_MAINT)
                    assert(operation.isType(Operation.SHOCK))
                elseif self.lastOperation.isType(Operation.SHOCK)
                    error('No operation can follow a shock immediately')
                else
                    error('This line should never be reached')
                end
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
            perf = self.infrastructure.getPerformance();
            
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
                import managers.Faculty
                
                % Calculates penalty fee from contract
                msg = Faculty.createEmptyMessage(self.principal, Faculty.PENALTY);
                msg.setExtraInfo(Message.TIME_DETECTION, timeInspection);
                
                self.contract.penaltyStrategy.decide(msg);
                
                penaltyFee = msg.getOutput(Information.VALUE_PENALTY_FEE);
                
                % Appending the income (penalty fee) to the principal's
                % payoff struct
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
        
        
        function timeExecution = executeVolMaint(self, operation)
        %{
        * 
        
            Input
                
            Output
                
        %}
        
            import dataComponents.Transaction
            import dataComponents.Observation
            import dataComponents.Event
            
            timeVolMaint = operation.time;
            perfGoal = operation.perfGoal;
            
            perfBeforeMaint = self.infrastructure.getPerformance();
            
            % Creates observation object before and after Maintenance
            obs = Observation(timeVolMaint, [perfBeforeMaint, perfGoal]);
            
            % Creates the outcome payoff struct of the agent
            costMaintenance = self.agent.maintCostFunction(perfBeforeMaint, perfGoal);
            
            maintTransaction = Transaction(...
                timeVolMaint, ...
                costMaintenance, ...
                Transaction.MAINTENANCE);
            
            % Applies maintenance operation to Infrastructure
            self.nature.applyOperation(operation, self.infrastructure);
            
            % Creates and registers voluntary maintenance event for the
            % agent
            volMaintEvent_Agent = Event(...
                timeVolMaint, ...
                Event.VOL_MAINT, ...
                obs, ...
                maintTransaction);
            
            self.agent.registerEvent(volMaintEvent_Agent);
            
            timeExecution = timeVolMaint;
            
            % Inform the Agent that this volMaint operation was executed
            self.agent.confirmExecutionSubmittedOperation(operation);
        end
        
        
        function timeExecution = executeMandMaint(self)
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
            import managers.Faculty
            
            timeDetection = self.principal.observationList.getCurrentTime();
            perfDetection = self.principal.observationList.getCurrentValue();
            
            maxPerf = self.infrastructure.maxPerf;
            perfThreshold = self.contract.perfThreshold;
            
            % Strategy calculates performance goal
            msg = Faculty.createEmptyMessage(self.agent, Faculty.MAND_MAINT);
            msg.setExtraInfo(   Message.MAX_PERF, maxPerf, ...
                                Message.TIME_DETECTION, timeDetection, ...
                                Message.PERF_DETECTION, perfDetection);
            
            self.agent.mandMaintStrategy.decide(msg);
            
            deltaPerfAboveThreshold = msg.getOutput(Information.PERF_MAND_MAINT);
            
            assert(deltaPerfAboveThreshold >= 0, 'The value of deltaPerfAboveThreshold must be non-negative')
            
            perfGoal = perfThreshold + deltaPerfAboveThreshold;
            assert(perfGoal <= maxPerf, ...
                'The value of the performance goal must be within [nullPerf, maxPerf]')
            
            % Creates the outcome payoff object of the agent
            costMaintenance = self.agent.maintCostFunction(perfDetection, perfGoal);
            
            % Creates maintenance operation object
            mandMaintOperation = Operation(timeDetection, Operation.MAND_MAINT, true, ...
                perfGoal);
            
            % Applies maintenance operation to Infrastructure
            self.nature.applyOperation(mandMaintOperation, self.infrastructure);
            
            % Creates observation objects (at current time) for the principal
            perfAfterMaint = self.infrastructure.getPerformance();
            assert(perfAfterMaint == perfGoal, ...
                'The observed performance must be equal to the perfGoal of the applied mandatory maintenance operation');
            
            % Creates observation object before and after Maintenance
            obs = Observation(timeDetection, [perfDetection, perfGoal]);
            
            % Creates transaction object for concept of mandatory maint
            trn = Transaction( timeDetection, ...
                costMaintenance, ...
                Transaction.MAINTENANCE);
            
            % Creates and registers mandatory maintenance event for the
            % principal and agent
            mandMaintEvent = Event(...
                timeDetection, ...
                Event.MAND_MAINT, ...
                obs, ...
                trn);
            
            self.principal.registerEvent(mandMaintEvent);
            self.agent.registerEvent(mandMaintEvent);
            
            timeExecution = timeDetection;
        end
        
        
        function timeExecution = executeShock(self, operation)
        %{
        * 
        
            Input
                
            Output
                
        %}
        
            import dataComponents.Observation
            import dataComponents.Event
            
            % Inform Nature that this shock operation was executed
            self.nature.confirmExecutionSubmittedOperation(operation);
            
            % Creates observation object
            perfBeforeShock = self.infrastructure.getPerformance();
            
            obs = Observation(...
                operation.time, ...
                perfBeforeShock);
            
            % Applies shock operation to Infrastructure
            self.nature.applyOperation(operation, self.infrastructure);
            
            % Creates and registers shock event for the agent
            shockEvent = Event(...
                operation.time, ...
                Event.SHOCK, ...
                obs, ...
                []);
            
            self.agent.registerEvent(shockEvent);
            
            timeExecution = operation.time;
            
        end
        
        
        function executePayment(self, transaction)
        %{
        * 

            Input

            Output

        %}
            import dataComponents.Event
            
            % Evolve the system up to the time of the operation to be
            % executed
            
            re = 1e-8;
            if transaction.time > self.time + re
                self.evolveContinuously(transaction.time);
            end
            
            assert(self.time == transaction.time)
            
            [emitter, receiver] = transaction.returnEmitterReceiver(self.principal, self.agent);
            
            ev = Event(transaction.time, Event.CONTRIBUTION, [], transaction);
            
            % Emitter end receiver register the event
            if ~isempty(emitter)
                emitter.registerEvent(ev);
            end
            
            if ~isempty(receiver)
                receiver.registerEvent(ev);
            end
            
        end
        
        
        function validateOperation(self, operation)
        %{
        * 
        
            Input
                
            
            Output
                
        %}
            assert(operation.time >= self.time, ...
                'This operation must have an execution time greater or equal than the current time in the realization')
        end
        
        
        function evolveContinuously(self, tf)
        %{
        * 
            
            Input
            
            Output
            
        %}
            
            currentPerf = self.infrastructure.getPerformance();
            currentAgentBalance = self.agent.payoffList.getBalance(); % Current agent's balance
            
            [t, y] = self.solver.solveFutureState(self.time, tf, [currentPerf; currentAgentBalance]);
            
            perf = y(:,1);
            agentBalance = y(:,2);
            
            demHist = self.solver.demandFnc(perf);
            
            self.demandHistory.register(t, demHist);
            self.agent.evolve(t, agentBalance);
            self.infrastructure.evolve(t, perf);
            
            self.updateTimeAll(tf);
        end
        
        
        function finishRealization(self)
        %{
        * 
        
            Input
                
            Output
               
            TODO: Make players finalize interaction via a process different
            from register a ficticious payoff.
        %}
        
            import dataComponents.Transaction
            import dataComponents.Event
            
            contractDuration = self.contract.duration;
            
            % Evolve until contract duration
            self.evolveContinuously(contractDuration);
            
            % Set time for all
            self.updateTimeAll(contractDuration);
            
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function [emitter, receiver] = getEmitterReceiver(self, transaction)
            import managers.Information
            
            if strcmp(transaction.emitter, Information.PRINCIPAL)
                emitter = self.principal;
            elseif strcmp(transaction.emitter, Information.AGENT)
                emitter = self.agent;
            else
                error('Emitter should be either PRINCIPAL or AGENT')
            end
            
            
            if strcmp(transaction.receiver, Information.PRINCIPAL)
                receiver = self.principal;
            elseif strcmp(transaction.receiver, Information.AGENT)
                receiver = self.agent;
            else
                error('Receiver should be either PRINCIPAL or AGENT')
            end
            
        end
        
        
        function [ua, up] = utilityPlayers(self)
        %{
        * 
        
            Input
                None
            
            Output
                
        %}
            ua = self.agent.getUtility();
            up = self.principal.getUtility();
        end
        
        
        function earliestOp = requestOperations(self)
        %{
        * Requests players to submit their next action. Returns the
        player name and time of the earliest action submitted.
        
            Input
                None
            
            Output
                earliestOp: [class Operation] Operation object with earliest
                time
        %}
            currentPerf = self.infrastructure.getPerformance();
            
            maxPerf = self.infrastructure.maxPerf;
            nullPerf = self.infrastructure.nullPerf;
            
            % Asking players to submit operations
            operationPrincipal = self.principal.submitOperation();
            self.validateOperation(operationPrincipal);
            
            operationAgent = self.agent.submitOperation(self.solver, self.infrastructure);
            self.validateOperation(operationAgent);
            
            operationNature = self.nature.submitOperation();
            self.validateOperation(operationNature);
            
            earliestOp = returnEarliestOperation( operationPrincipal, ...
                                                  operationAgent, ...
                                                  operationNature );
            %earliestOp.setAsPending();
        end
        
        
        function performance = solvePerformanceForTime(self, time)
        %{
        * Solves performance of infrastructure for a given time
        
            Input
                time: [class double] Time to solve performance for
                
            Output
                performance: [class double] Performance of infrastructure
                for a given time
        %}
            performance = self.nature.solvePerformanceForTime(time);
        end
        
        
        function time = solveTimeForPerformance(self, perf)
        %{
        * Solves time for a given infrastructure state
        
            Input
                performance: [class double] Performance of infrastructure
                for a given time
                
            Output
                time: [class double] Time to solve performance for
        %}
            time = self.nature.solveTimeForPerformance(perf);
        end
        
        
        function data = report(self)
        %{
        * 
        
            Input
                
            Output
                
        %}
            import dataComponents.Event
            import dataComponents.Transaction
            import managers.DataRealization
            
            [utilityAgent, utilityPrincipal] = self.utilityPlayers();
            contractDuration = self.contract.duration;
            perfThreshold = self.contract.perfThreshold;
            inspection_markers = self.principal.eventList.getMarkersInfo(Event.INSPECTION, self.principal.observationList);
            detection_markers = self.principal.eventList.getMarkersInfo(Event.DETECTION, self.principal.observationList);
            
            data = DataRealization();
            
            if ~isempty(inspection_markers)
                num_insp_noviol = length(inspection_markers.time);
            else
                num_insp_noviol = 0;
            end
            
            if ~isempty(detection_markers)
                num_detections = length(detection_markers.time);
            else
                num_detections = 0;
            end
            
            total_inspections = num_insp_noviol + num_detections;
            
            violationRatio = num_detections / total_inspections;
            
            data = DataRealization();
            
            % Double values
            data.addEntry('ua', 'Agent''s utility', utilityAgent);
            data.addEntry('up', 'Principal''s utility', utilityPrincipal);
            data.addEntry('contractDuration', 'Contract duration', contractDuration);
            data.addEntry('threshold', 'Contract duration', perfThreshold);
            data.addEntry('maxPerf', 'Maximum performance', self.infrastructure.maxPerf);
            data.addEntry('nullPerf', 'Null performance', self.infrastructure.nullPerf);
            data.addEntry('numInspNoViol', 'Insp. without violation', num_insp_noviol);
            data.addEntry('numDetections', 'Insp. with violation', num_detections);
            data.addEntry('numInspections', 'Total inspections', total_inspections);
            data.addEntry('violationRatio', 'Observed violation ratio', violationRatio);
            
            % Struct values
            data.addEntry('perfHistory', 'Performance history', self.infrastructure.history.getData());
            data.addEntry('inspectionMarker', 'Time and perf when inspections occurred', inspection_markers);
            data.addEntry('detectionMarker', 'Time and perf when detections occurred', detection_markers);
            data.addEntry('volMaintMarker', 'Time and perf when vol maints occurred', self.agent.eventList.getMarkersInfo(Event.VOL_MAINT, self.agent.observationList));
            data.addEntry('shockMarker', 'Time and perf when shocks occurred', self.agent.eventList.getMarkersInfo(Event.SHOCK, self.agent.observationList));
            data.addEntry('realPerfMeanValue', 'History of actual perf mean value', self.infrastructure.history.getMeanValueHistory());
            data.addEntry('perceivedPerfMeanValue', 'History of perceived perf mean value', self.principal.observationList.getMeanValueHistory());
            data.addEntry('balA', 'Agent''s balance', self.agent.payoffList.getBalanceHistory());
            data.addEntry('balP', 'Principal''s balance', self.principal.payoffList.getBalanceHistory());
            data.addEntry('jumpsMaint', 'Time and balance just before a jump due to maint', self.agent.payoffList.returnPayoffsOfType(Transaction.MAINTENANCE));
            data.addEntry('jumpsContrib', 'Time and balance just before a jump due to flow', self.agent.payoffList.returnPayoffsOfType(Transaction.CONTRIBUTION));
            data.addEntry('jumpsPenalties', 'Time and balance just before a jump due to a penalty', self.agent.payoffList.returnPayoffsOfType(Transaction.PENALTY));
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


function time = getEarliestTime(operation, transaction)
if isempty(transaction)
    time = operation.time;
else
    if transaction.time <= operation.time
        time = transaction.time;
    else
        time = operation.time;
    end
end
end