classdef Player < handle
    
    properties (Constant)
        
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
        %% Constructor
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function thisPlayer = Player(problem)
            import dataComponents.EventList
            import dataComponents.PayoffList
            import dataComponents.ObservationList
            
            thisPlayer.problem = problem;
            thisPlayer.eventList = EventList();
            thisPlayer.observationList = ObservationList();
            thisPlayer.payoffList = PayoffList(problem.discountRate);
        end
        
        %% Getter functions
        
        %%
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        %{
        * Returns value of time attribute
        
            Input
                None
            
            Output
                time: [class double] Value of time attribute of thisPlayer
        %}
        function time = getTime(thisPlayer)
            time = thisPlayer.time;
        end
        
        
        function receiveContract(thisPlayer, con)
            thisPlayer.contract = con;
        end
        
        %%
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        
        %{
        * Set new time for thisPlayer and adds a PV snapshot
        
            Input
                time: [class double] New value of time
            
            Output
                None
        %}
        function setTime(thisPlayer, time)
            if time > thisPlayer.time
                thisPlayer.time = time;    % Updates time
            end
        end
        
        
        %{
        * 
            Input
                obs: [lass struct] Structure with fields
                    
            
            Output
                None
        %}
        function idObs = registerObservation(thisPlayer, time, obs)
            numObs = length(obs.value);
            idObs = zeros(1,numObs);
            for i=1:numObs
                idObs(i) = thisPlayer.observationList.register(time, obs.value(i));
            end
        end
        
        
        %{
        * Append newPayoff to the payoff linked-list attribute of
        thisPlayer
        
            Input
                newPayoff: [class Payoff] New payoff object to be appended
            
            Output
                None
        
        register(thisPayoff, time, value, type, varargin)
        %}
        function idPff = registerPayoff(thisPlayer, time, pff)
            
            numPff = length(pff.value);
            idPff = zeros(1,numPff);
            
            for i=1:numPff
                idPff(i) = thisPlayer.payoffList.register(  time, ...
                    pff.value(i), ...
                    pff.type{i});
            end
        end
        
        
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
        function registerEvent(thisPlayer, evt)
            
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
            assert(~isempty(thisPlayer.submittedOperation), ...
                'The attribute submitted operation should not be empty.')
            
            assert(thisPlayer.submittedOperation.eq(operation), ...
                'The operation executed does not coincide with the operation submitted.')
            
            thisPlayer.clearSubmittedOperation();
            
        end
        
        %{
        
            Input
                
            Output
                
        %}
        function setSubmittedOperation(thisPlayer, operation)
            thisPlayer.submittedOperation = operation;
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function clearSubmittedOperation(thisPlayer)
            thisPlayer.submittedOperation = [];
        end
        
        %%
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        function u = getUtility(thisPlayer)
            u = thisPlayer.utilityFunction(thisPlayer);
        end
        
        function answer = isPrincipal(thisPlayer)
            import entities.Principal
            
            answer = isa(thisPlayer, 'Principal');
        end
        
        function answer = isAgent(thisPlayer)
            import entities.Agent
            
            answer = isa(thisPlayer, 'Agent');
        end
        
    end
    
end

%% Auxiliar functions

    %{
    * Description of the auxiliar function
    
        Input

        Output

    %}

