classdef EventList < matlab.mixin.Copyable
    %EVENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, GetAccess = protected)
        BLOCKSIZE = 100
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        pt                  % Pointer to last free position
        listSize
    end
    
    properties (GetAccess = protected, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        time
        type    % Types of events
        
        
        % ID of related observation within the observation
        % object of the entity owning this event
        idObservation
        
        % ID of related payoff within the payoff
        % object of the entity owning this event
        idPayoff
        
        %{
        Explanation:
        The attributes idObservation and idPayoff at the creation of 
        thisEvent object will temporarily store a structure of the
        information of the observation or payoff.
        
        These structures will remain there until the player owning
        thisEvent, registers the event. He has the responsability of
        replacing the structures with the indices or id of the observation
        and/or payoff as stored in his Observation and/or Payoff objects.
        
        %}
    end
    
    
    methods
        %% Constructor
        
        
        %{
        * 
		
            Input
                
            Output
                
        %}
        function thisEventList = EventList()
            
            import dataComponents.Event
            
            thisEventList.listSize = thisEventList.BLOCKSIZE;
            thisEventList.pt = 1;
            
            % Registered lists
            thisEventList.time = zeros(thisEventList.BLOCKSIZE,1);
            thisEventList.type = cell(thisEventList.BLOCKSIZE,1);
            thisEventList.idObservation = cell(thisEventList.BLOCKSIZE,1);
            thisEventList.idPayoff = cell(thisEventList.BLOCKSIZE,1);
        end
        
        %% Getter funcions
        
        
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
		
        %{
        * 
		
            Input
                
            Output
                
        %}
		function currentTime = getCurrentTime(thisEvent)
			currentTime = thisEvent.time(thisEvent.pt-1);
        end
        
        
        %{
        *  
            Input
                
            Output
                
        %}
        function currentType = getCurrentType(thisEvent)
            currentType = thisEvent.type{thisEvent.pt-1};
        end
        
        
        %{
        *  
            Input
                
            Output
                
        %}
        function st = getData(thisEvent, ids)
            if nargin < 2
                lastValidIndex = thisEvent.pt - 1;
                ids = 1:lastValidIndex;
            end
            
            st = struct();
            
            st.time = thisEvent.time(ids);
            st.type = thisEvent.type(ids);
            st.idObservation = thisEvent.idObservation(ids);
            st.idPayoff = thisEvent.idPayoff(ids);
        end
		  
		
        %{
        *  
            Input
                
            Output
                
        %}
        function st = getEventsOfType(thisEvent, type)
            assert(thisEvent.isValidType(type) ,...
                'The type entered as argument is not valid')
            
            ids = strcmp(thisEvent.type, type);
            if any(ids)
                st = thisEvent.getData(ids);
            else
                st = [];
            end
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function st = getLastEventOfType(thisEvent, type)
            assert(thisEvent.isValidType(type) ,...
                'The type entered as argument is not valid')
            
            ids = find(strcmp(thisEvent.type, type), 1, 'last');
            if ~isempty(ids)
                st = thisEvent.getData(ids);
            else
                st = [];
            end
        end
			
            
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------
        % ----------------------------------------------------------------
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function id = register(thisEvent, time, type, idObs, idPff)
            
            if thisEvent.pt > 1
                assert( time >= thisEvent.time(thisEvent.pt-1), ...
                     'The time of events must be non-decreasing.')
            end
            assert(thisEvent.isValidType(type) ,...
                'The type entered as argument is not valid')
            
            % Registers time, type, observation and payoff
            id = thisEvent.pt;
            thisEvent.time(id) = time;
            thisEvent.type{id} = type;
            thisEvent.idObservation{id} = idObs;
            thisEvent.idPayoff{id} = idPff;
            
            % Makes array bigger if necessary
            if thisEvent.pt + (thisEvent.BLOCKSIZE/10) > thisEvent.listSize
                thisEvent.extendArrays();
            end
            
            % Updates pointer
            thisEvent.pt = thisEvent.pt + 1;
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function extendArrays(thisEvent)
            % Increments register or list size
            thisEvent.listSize = thisEvent.listSize + thisEvent.BLOCKSIZE;
            
            % Extends registers lists
            thisEvent.time(thisEvent.pt+1:thisEvent.listSize, :) = 0;
            thisEvent.type{thisEvent.listSize,1} = [];
            thisEvent.idObservation{thisEvent.listSize,1} = [];
            thisEvent.idPayoff{thisEvent.listSize,1} = [];
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        function st = getMarkersInfo(thisEvent, type, theObs)
            st = thisEvent.getEventsOfType(type);
            if ~isempty(st)
                numEvents = length(st.time);
                st.value = zeros(numEvents,1);
                
                for i=1:numEvents
                    st.idObservation{i} = st.idObservation{i}(1);
                    st.value(i) = theObs.getValue(st.idObservation{i});
                end
            end
        end
		

		
    end
end