classdef Player < handle
    % 
    
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
        
        function thisPlayer = Player(problem)
        %{
        * 
        
            Input
                
            Output
                
        %}
            import dataComponents.EventList
            import dataComponents.PayoffList
            import dataComponents.ObservationList
            
            thisPlayer.problem = problem;
            thisPlayer.eventList = EventList();
            thisPlayer.observationList = ObservationList();
            thisPlayer.payoffList = PayoffList(problem.discountRate);
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function setTime(thisPlayer, time)
        %{
        * Set new time for thisPlayer and adds a PV snapshot
        
            Input
                time: [class double] New value of time
            
            Output
                None
        %}
            if time > thisPlayer.time
                thisPlayer.time = time;    % Updates time
            end
        end
        
        
        function receiveContract(thisPlayer, con)
        %{
        
            Input
                
            Output
                
        %}
            thisPlayer.contract = con;
        end
        
        
        function idObs = registerObservation(thisPlayer, time, obs)
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
                idObs(i) = thisPlayer.observationList.register(time, obs.value(i));
            end
        end
        
        
        function idPff = registerPayoff(thisPlayer, time, pff)
        %{
        * Append newPayoff to the payoff linked-list attribute of
        thisPlayer
        
            Input
                newPayoff: [class Payoff] New payoff object to be appended
            
            Output
                None
        
        %}
            numPff = length(pff.value);
            idPff = zeros(1,numPff);
            
            for i=1:numPff
                idPff(i) = thisPlayer.payoffList.register(  time, ...
                    pff.value(i), ...
                    pff.type{i});
            end
        end
        
        
        function registerEvent(thisPlayer, evt)
        %{
        * Registers an Event object to the eventList attribute of
        thisPlayer. After adding the event, the time of thisPlayer is updated
        to the time of the event just added.
        
            Input
                oneEvent: [class Event] Event object to be added to the
                eventList attribute of thisPlayer
            
            Output
                None
        %}
            import managers.Information
            
            % Input validation
            assert(~isempty(evt), ...
                'The event object passed as argument must not be empty')
            
            timeNewEvent = evt.time;
            
            % Register observation in thisPlayer
            if ~isempty(evt.observation)
                idObs = thisPlayer.registerObservation(timeNewEvent, evt.observation);
            else
                idObs = [];
            end
            
            % Register transaction in thisPlayer
            if ~isempty(evt.transaction)
                [value, role] = evt.transaction.getPayoffValue(thisPlayer);
                idPff = thisPlayer.registerPayoff(timeNewEvent, value);
                evt.transaction.confirmExecutionBy(role);
            else
                idPff = [];
            end
            
            % Register event
            thisPlayer.eventList.register(timeNewEvent, evt.type, idObs, idPff);
            
			% Clear submitted operation
			if ~isempty(thisPlayer.submittedOperation) && thisPlayer.submittedOperation.sensitive
				thisPlayer.clearSubmittedOperation();
			end
			
			% Set time of player to the time of the newEvent
			thisPlayer.setTime(timeNewEvent);
            
        end
        
        
        function confirmExecutionSubmittedOperation(thisPlayer, operation)
        %{
        * 
            Input
                
            Output
                
        %}
            assert(~isempty(thisPlayer.submittedOperation), ...
                'The attribute submitted operation should not be empty.')
            
            assert(thisPlayer.submittedOperation.eq(operation), ...
                'The operation executed does not coincide with the operation submitted.')
            
            thisPlayer.clearSubmittedOperation();
        end
        

        function setSubmittedOperation(thisPlayer, operation)
        %{
        * 
            Input
                
            Output
                
        %}
            thisPlayer.submittedOperation = operation;
        end
        
        
        function clearSubmittedOperation(thisPlayer)
        %{
        * 
            Input
                
            Output
                
        %}
            thisPlayer.submittedOperation = [];
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function u = getUtility(thisPlayer)
        %{
        * 
            Input
                
            Output
                
        %}
            u = thisPlayer.utilityFunction(thisPlayer);
        end
        
        
        function answer = isPrincipal(thisPlayer)
        %{
        * 
            Input
                
            Output
                
        %}
            import entities.Principal
            
            answer = isa(thisPlayer, 'Principal');
        end
        
        
        function answer = isAgent(thisPlayer)
        %{
        * 
            Input
                
            Output
                
        %}
            import entities.Agent
            
            answer = isa(thisPlayer, 'Agent');
        end
        
        
    end
end