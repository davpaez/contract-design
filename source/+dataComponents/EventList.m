classdef EventList < matlab.mixin.Copyable
    
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
        self object will temporarily store a structure of the
        information of the observation or payoff.
        
        These structures will remain there until the player owning
        self, registers the event. He has the responsability of
        replacing the structures with the indices or id of the observation
        and/or payoff as stored in his Observation and/or Payoff objects.
        
        %}
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function thisEventList = EventList()
        %{
        * 
		
            Input
                
            Output
                
        %}
            import dataComponents.Event
            
            thisEventList.listSize = thisEventList.BLOCKSIZE;
            thisEventList.pt = 1;
            
            % Registered lists
            thisEventList.time = zeros(thisEventList.BLOCKSIZE,1);
            thisEventList.type = cell(thisEventList.BLOCKSIZE,1);
            thisEventList.idObservation = cell(thisEventList.BLOCKSIZE,1);
            thisEventList.idPayoff = cell(thisEventList.BLOCKSIZE,1);
        end
        
        
		%% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************
		
		function currentTime = getCurrentTime(self)
        %{
        * 
		
            Input
                
            Output
                
        %}
			currentTime = self.time(self.pt-1);
        end
        
        
        function currentType = getCurrentType(self)
        %{
        *  
            Input
                
            Output
                
        %}
            currentType = self.type{self.pt-1};
        end
        
        
        function st = getData(self, ids)
        %{
        *  
            Input
                
            Output
                
        %}
            if nargin < 2
                lastValidIndex = self.pt - 1;
                ids = 1:lastValidIndex;
            end
            
            st = struct();
            
            st.time = self.time(ids);
            st.type = self.type(ids);
            st.idObservation = self.idObservation(ids);
            st.idPayoff = self.idPayoff(ids);
        end
		
		
        function st = getEventsOfType(self, type)
        %{
        *  
            Input
                
            Output
                
        %}
            assert(self.isValidType(type) ,...
                'The type entered as argument is not valid')
            
            ids = strcmp(self.type, type);
            if any(ids)
                st = self.getData(ids);
            else
                st = [];
            end
        end
        
        
        function st = getLastEventOfType(self, type)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            ids = find(strcmp(self.type, type), 1, 'last');
            if ~isempty(ids)
                st = self.getData(ids);
            else
                st = [];
            end
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function id = register(self, time, type, idObs, idPff)
        %{
        * 
        
            Input
                
            Output
                
        %}
            if self.pt > 1
                assert( time >= self.time(self.pt-1), ...
                     'The time of events must be non-decreasing.')
            end
            
            % Registers time, type, observation and payoff
            id = self.pt;
            self.time(id) = time;
            self.type{id} = type;
            self.idObservation{id} = idObs;
            self.idPayoff{id} = idPff;
            
            % Makes array bigger if necessary
            if self.pt + (self.BLOCKSIZE/10) > self.listSize
                self.extendArrays();
            end
            
            % Updates pointer
            self.pt = self.pt + 1;
        end
        
        
        function extendArrays(self)
        %{
        * 
        
            Input
                
            Output
                
        %}
            % Increments register or list size
            self.listSize = self.listSize + self.BLOCKSIZE;
            
            % Extends registers lists
            self.time(self.pt+1:self.listSize, :) = 0;
            self.type{self.listSize,1} = [];
            self.idObservation{self.listSize,1} = [];
            self.idPayoff{self.listSize,1} = [];
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function st = getMarkersInfo(self, type, theObs)
        %{
        * 
        
            Input
                
            Output
                
        %}
            st = self.getEventsOfType(type);
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