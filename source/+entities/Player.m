classdef Player < handle
    
    properties (Constant, Abstract=true)
        NAME
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        time = 0
        utilityFunction
        
        % ----------- %
        % Objects
        % ----------- %
        contract      % Instance of contract
        problem
        
        eventList      % Events known to Agent
        observationList     % % Observation object
        payoffList
        
        submittedOperation     % Operation object
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Player(problem)
        %{
        * 
        
            Input
                
            Output
                
        %}
            import dataComponents.EventList
            import dataComponents.PayoffList
            import dataComponents.ObservationList
            
            self.problem = problem;
            self.eventList = EventList();
            self.observationList = ObservationList();
            self.payoffList = PayoffList();
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function setTime(self, time)
        %{
        * Set new time for self and adds a PV snapshot
        
            Input
                time: [class double] New value of time
            
            Output
                None
        %}
            if time > self.time
                self.time = time;    % Updates time
            end
        end
        
        
        function receiveContract(self, con)
        %{
        
            Input
                
            Output
                
        %}
            self.contract = con;
        end
        
        
        function idObs = registerObservation(self, time, obs)
        %{
        * 
            Input
                obs: [lass struct] Structure with fields
                    
            
            Output
                None
        %}
            numObs = length(obs.value);
            idObs = zeros(1,numObs);
            for i=1:numObs
                idObs(i) = self.observationList.register(time, obs.value(i));
            end
        end
        
        
        function idPff = registerPayoff(self, time, value, type)
        %{
        * Append newPayoff to the payoff linked-list attribute of
        self
        
            Input
                newPayoff: [class Payoff] New payoff object to be appended
            
            Output
                None
        
        %}
            
            idPff = self.payoffList.registerFlow(time, value, type);
        end
        
        
        function registerEvent(self, evt)
        %{
        * Registers an Event object to the eventList attribute of
        self. After adding the event, the time of self is updated
        to the time of the event just added.
        
            Input
                oneEvent: [class Event] Event object to be added to the
                eventList attribute of self
            
            Output
                None
        %}
            import managers.Information
            
            % Input validation
            assert(~isempty(evt), ...
                'The event object passed as argument must not be empty')
            
            timeNewEvent = evt.time;
            
            % Register observation in self
            if ~isempty(evt.observation)
                idObs = self.registerObservation(timeNewEvent, evt.observation);
            else
                idObs = [];
            end
            
            % Register transaction in self
            if ~isempty(evt.transaction)
                [value, role] = evt.transaction.getPayoffValue(self);
                if ~isempty(role)
                    idPff = self.registerPayoff(timeNewEvent, value, evt.transaction.type);
                    evt.transaction.confirmExecutionBy(role);
                else
                    idPff = [];
                end
            else
                idPff = [];
            end
            
            % Register event
            self.eventList.register(timeNewEvent, evt.type, idObs, idPff);
            
			% Clear submitted operation
            %TODO clear submitted operation outside Player
% 			if ~isempty(self.submittedOperation) && self.submittedOperation.sensitive
% 				self.clearSubmittedOperation();
% 			end
			
			% Set time of player to the time of the newEvent
			self.setTime(timeNewEvent);
            
        end
        
        
        function confirmExecutionSubmittedOperation(self, operation)
        %{
        * 
            Input
                
            Output
                
        %}
            assert(~isempty(self.submittedOperation), ...
                'The attribute submitted operation should not be empty.')
            
            assert(self.submittedOperation.eq(operation), ...
                'The operation executed does not coincide with the operation submitted.')
            
            self.clearSubmittedOperation();
        end
        

        function setSubmittedOperation(self, operation)
        %{
        * 
            Input
                
            Output
                
        %}
            self.submittedOperation = operation;
        end
        
        
        function clearSubmittedOperation(self)
        %{
        * 
            Input
                
            Output
                
        %}
            self.submittedOperation = [];
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function u = getUtility(self)
        %{
        * 
            Input
                
            Output
                
        %}
            u = self.utilityFunction(self);
        end
        
        
        function answer = isPrincipal(self)
        %{
        * 
            Input
                
            Output
                
        %}
            import entities.Principal
            
            answer = isa(self, 'Principal');
        end
        
        
        function answer = isAgent(self)
        %{
        * 
            Input
                
            Output
                
        %}
            import entities.Agent
            
            answer = isa(self, 'Agent');
        end
        
        
    end
end