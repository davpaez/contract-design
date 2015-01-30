classdef Player < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        time = 0
        
        % ----------- %
        % Objects
        % ----------- %
        contract      % Instance of contract
        problem
        eventList      % Events known to Agent
        observation     % % Observation object
        payoff
        
        submittedOperation     % Operation object
    end
    
    methods
        %% Constructor
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function thisPlayer = Player(contract, problem)
            import dataComponents.Event
            import dataComponents.Payoff
            import dataComponents.Observation
            
            thisPlayer.contract = contract;
            thisPlayer.problem = problem;
            thisPlayer.eventList = Event();
            thisPlayer.observation = Observation();
            thisPlayer.payoff = Payoff(problem.discountRate);
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
                idObs(i) = thisPlayer.observation.register(time, obs.value(i));
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
            
            if isfield(pff,'duration')
                for i=1:numPff
                    idPff(i) = thisPlayer.payoff.register(  time, ...
                                                            pff.value(i), ...
                                                            pff.type{i}, ...
                                                            pff.duration(i));
                end
            else
                for i=1:numPff
                    idPff(i) = thisPlayer.payoff.register(  time, ...
                                                            pff.value(i), ...
                                                            pff.type{i});
                end
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
            % Input validation
            assert(~isempty(evt), ...
                'The event object passed as argument must not be empty')
            
            timeNewEvent = evt.time;
            
            idObs = [];
            idPff = [];
            
            % Register observation in thisPlayer
            if isfield(evt, 'obs')
                assert(~isempty(evt.obs), 'The field "obs" cannot be empty.')
                idObs = thisPlayer.registerObservation(timeNewEvent, evt.obs);
            end
            
            % Register payoff in thisPlayer
            if isfield(evt, 'pff')
                assert(~isempty(evt.pff), 'The field "pff" cannot be empty.')
                idPff = thisPlayer.registerPayoff(timeNewEvent, evt.pff);
            end
            
            % Register event
            assert(isfield(evt,'type') && ~isempty(evt.type), ...
                'The field "type" is not well specified.')
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
        
        
    end
    
end

%% Auxiliar functions

    %{
    * Description of the auxiliar function
    
        Input

        Output

    %}

