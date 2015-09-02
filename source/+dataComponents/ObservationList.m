%{
# PURPOSE

TODO

List properties are stored as column arrays.

%}

classdef ObservationList < matlab.mixin.Copyable
    
    properties (Constant, GetAccess = protected)
        BLOCKSIZE = 1000
        SLACK = 100
        JUMPBLOCKSIZE = 1000/5
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        pt                  % Pointer to last free position
        listSize
        listJumpsSize
        
    end
    
    properties (GetAccess = protected, SetAccess = protected)
        % Registered properties
        time
        value
        
        % Calculated properties
        cumsum
        area
        average
        meanvalue
        deviation
        
        % Auxiliary properties
        
        state           % Updated status of each table field
        
        jumpsindex      % Indices corresponding to all pre-jump indices
        jumpscounter = 0
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = ObservationList()
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            self.pt = 1;
            self.listSize = self.BLOCKSIZE;
            self.listJumpsSize = self.BLOCKSIZE/5;
            
            % Registered lists
            self.time = zeros(self.BLOCKSIZE,1);
            self.value = zeros(self.BLOCKSIZE,1);
            
            % Calculated lists                                Number
            self.cumsum = zeros(self.BLOCKSIZE,1);            %(1)
            self.area = zeros(self.BLOCKSIZE,1);              %(2)
            self.average = zeros(self.BLOCKSIZE,1);           %(3)
            self.meanvalue = zeros(self.BLOCKSIZE,1);         %(4)
            self.deviation = zeros(self.BLOCKSIZE,1);         %(5)
            
            % Update if more calculated lists are added!
            numberCalculatedLists = 5;
            
            % State list: Contains update status of calculated lists
            self.state = false(self.BLOCKSIZE, numberCalculatedLists);
            
            % Auxiliary lists
            self.jumpsindex = zeros(self.JUMPBLOCKSIZE, 1);
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
        
        
        function currentValue = getCurrentValue(self)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            currentValue = self.value(self.pt-1);
        end
        
        
        function val = getValue(self, id)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            val = self.value(id);
        end
        
        
        function st = getData(self, ids)
        %{
        * 
        
            Input
            
            Output
                
        %}
            self.computeLists();
            
            if nargin < 2
                lastValidIndex = self.pt - 1;
                ids = 1:lastValidIndex;
            end
            
            st = struct();
            
            % Registered lists
            st.time = self.time(ids);
            st.value = self.value(ids);
            
            % Calculated lists
            st.cumsum = self.cumsum(ids);
            st.area = self.area(ids);
            st.average = self.average(ids);
            st.meanvalue = self.meanvalue(ids);
            st.deviation = self.deviation(ids);
            
            % State list
            st.state = self.state(ids);
            
            % Auxiliary list
            if nargin == 1
                st.jumpsindex = self.jumpsindex(1:self.jumpscounter);
            end
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function pointer = register(self, time, value)
        %{
        * 
        
            Input
            
            Output
                
        %}
            for i=1:length(time)
                
                pointer = self.pt;
                lastEntry = pointer-1;

                if pointer > 1
                    % Checks validity of entry
                    assert(time(i) >= self.time(lastEntry), ...
                        'The time of observations must be non-decreasing.')
                    
                    % Check if first entry exists already
                    if self.time(lastEntry) == time(i) && self.value(lastEntry) == value(i)
                        continue
                    end
                    
                    % Registers if current entry creates a jump
                    if time(i) == self.time(lastEntry)
                        self.registerJump();
                    end
                end

                % Registers time and value
                self.time(pointer) = time(i);
                self.value(pointer) = value(i);

                % Makes arrays bigger if necessary
                if (pointer + self.SLACK) > self.listSize
                    self.extendArrays();
                end

                % Updates pointer
                self.pt = pointer + 1;

            end
        end
        
        
        function extendArrays(self)
        %{
        * Extends all arrays of thisObservation
        
            Input
            
            Output
                
        %}
            
            % Increments register or list size
            self.listSize = self.listSize + self.BLOCKSIZE;
            
            % Extends registers lists
            self.time(self.pt+1:self.listSize, :) = 0;
            self.value(self.pt+1:self.listSize, :) = 0;
            
            % Extends calculated lists
            self.cumsum(self.pt+1:self.listSize, :) = 0;
            self.area(self.pt+1:self.listSize, :) = 0;
            self.average(self.pt+1:self.listSize, :) = 0;
            self.meanvalue(self.pt+1:self.listSize, :) = 0;
            self.deviation(self.pt+1:self.listSize, :) = 0;
            
            % Extends state matrix for all lists (columns)
            self.state(self.pt+1:self.listSize, :) = false;
        end
        
        
        function extendJumpsArray(self)
        %{
        * Extends array of jumpsindex
        
            Input
            
            Output
                
        %}
            
            self.listJumpsSize = self.listJumpsSize + self.JUMPBLOCKSIZE;
            self.jumpsindex(self.jumpscounter+1:self.listJumpsSize, :) = 0;
        end
        
        
        function registerJump(self)
        %{
        * Register the index of the pre-jump observation in the jumpsIndex
        attribute of self. The index is assumed to be the index 
        previous to the pointer to the last free position (i.e.,  pt-1  )
        
            Input
            
            Output
                
        %}
            
            self.jumpscounter = self.jumpscounter + 1;
            
            % Registers the pre-jump index!
            self.jumpsindex(self.jumpscounter) = self.pt-1;
            
            if self.jumpscounter + (self.JUMPBLOCKSIZE/10) > self.listJumpsSize
                self.extendJumpsArray();
            end
        end
        
        
        function cumSumValue = getCumSum(self, index)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if nargin < 2
                index = inf;
            end
            
            stateColNumber = 1;
            
            lastValidIndex = self.pt-1;
            
            if index > lastValidIndex
                index = lastValidIndex;
            end
            
            if self.state(index,stateColNumber) == true
                cumSumValue = self.cumsum(index);
            else
                cumSumValue = sum(self.value(1:index));
                self.cumsum(index) = cumSumValue;
                self.state(index,stateColNumber) = true;
            end
        end
        
        
        function a = getArea(self, index)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if nargin < 2
                index = inf;
            end
            
            stateColNumber = 2;
            
            lastValidIndex = self.pt-1;
            
            if index > lastValidIndex
                index = lastValidIndex;
            end
            
            if self.state(index,stateColNumber) == true
                a = self.area(index);
            else
                if index == 1
                    a = 0;
                else
                    a = trapz(self.time(1:index), self.value(1:index));
                    self.area(index) = a;
                    self.state(index,stateColNumber) = true;
                end
            end
        end
        
        
        function av = getAverage(self, index)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if nargin < 2
                index = inf;
            end
            
            stateColNumber = 3;
            
            lastValidIndex = self.pt-1;
            
            if index > lastValidIndex
                index = lastValidIndex;
            end
            
            if self.state(index,stateColNumber) == true
                av = self.average(index);
            else
                av = mean(self.value(1:index));
                self.average(index) = av;
                self.state(index,stateColNumber) = true;
            end
        end
        
        
        function m = getMeanValue(self, index)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if nargin < 2
                index = inf;
            end
            
            stateColNumber = 4;
            
            lastValidIndex = self.pt-1;
            
            if index > lastValidIndex
                index = lastValidIndex;
            end
            
            if self.state(index,stateColNumber) == true
                m = self.meanvalue(index);
            else
                if index == 1
                    m = self.getValue(index);
                else
                    m = self.getArea(index)/(self.time(index)-self.time(1));
                end
                self.meanvalue(index) = m;
                self.state(index,stateColNumber) = true;
            end
        end
        
        
        function dev = getDeviation(self, index)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if nargin < 2
                index = inf;
            end
            
            stateColNumber = 5;
            
            lastValidIndex = self.pt-1;
            
            if index > lastValidIndex
                index = lastValidIndex;
            end
            
            if self.state(index,stateColNumber) == true
                dev = self.deviation(index);
            else
                dev = std(self.value(1:index));
                self.deviation(index) = dev;
                self.state(index,stateColNumber) = true;
            end
        end
        
        
        function computeLists(self)
            lastValidIndex = self.pt-1;
            
            for i=1:lastValidIndex
                self.getCumSum(i);
                self.getArea(i);
                self.getAverage(i);
                self.getMeanValue(i);
                self.getDeviation(i);
            end
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function l = getLength(self)
        %{
        * 
        
            Input
            
            Output
                
        %}
            l = self.pt - 1;
        end
        
        
        function [index, extra] = timeToIndex(self, time)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            index = find(self.time <= time, 1, 'last');
            assert(~isempty(index), 'No registry was found')
            
            extra = time - self.time(index);
        end
        
        
        function value = solveValue(self, time)
        %{
        * Gives the value associated with a time. 
        
            Input
            
            Output
                
        %}
            lastTime = self.time(self.pt-1);
            assert(time >= 0, 'Time queried must be non-negative')
            
            if time <= lastTime
                % Interpolate
                value = self.interpolate(time);
            else
                % Throw error
                error('Time queried is greater than the time of the last observation')
            end
            
        end
        
        function value = interpolate(self, time)
        %{
        * Iterpolates for given time. At jumps, it returns the post-jump
        value
        
            Input
            
            Output
                
        %}
            for i = 1:(self.pt-2)
                currentTime = self.time(i);
                nextTime = self.time(i+1);
                
                if currentTime <= time && time <= nextTime
                    
                    y0 = self.value(i);
                    y1 = self.value(i+1);
                    x0 = currentTime;
                    x1 = nextTime;
                    
                    if x0 == x1
                        value = y1;
                    else
                        value = y0 + (y1-y0)*(time-x0)/(x1-x0);
                    end
                    break
                end
            end
        end
        
        
        function sumValue = getSumBetween(self, indexFirst, indexLast)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            lastValidIndex = self.pt-1;
            
            assert( nargin == 3, 'The index arguments are required.')
            assert( indexFirst >= 1, 'First index must be greater or equal than 1.')
            assert( indexFirst < indexLast, 'Second index must be greater than first.')
            
            finalIndex = min(lastValidIndex,indexLast);
            
            sumValue = sum(self.value(indexFirst:finalIndex));
        end
        
        
        function st = getMeanValueHistory(self)
        %{
        * Returns a struct containing the fields time and meanValue
        
            Input
                None
            
            Output
                st: [class struct] 
        %}
            
            lastValidIndex = self.pt-1;
            
            st = struct();
            st.time = zeros(lastValidIndex,1);
            st.area = zeros(lastValidIndex,1);
            
            for i=1:lastValidIndex
                st.time(i) = self.time(i);
                st.meanvalue(i) = self.getMeanValue(i);
            end
        end
        

        function jumpPair = extractLastJumpPair(self, time)
        %{
        * Searches from tail to head looking for the first
        pair of values whose timestamp is less or equal than
        the time received as argument.

        Such a pair is called a jump pair.

            Input
                time: [class double]
            
            Output
                vector: [class Observation] Head of pair of linked (jump)
                    observations characterized because they share the same
                    time. It returns the observation pre-jump
        %}
            
            if nargin < 2
                time = inf;
            end
            
            % Default jump pair is an empty array
            jumpPair = [];
            
            % Maximum index of jumpsIndex list
            i = self.jumpscounter;
            
            while i >= 1
                
                origIndex = self.jumpsindex(i);
                timeJump = self.time(origIndex);
                
                if timeJump <= time
                    jumpPair = struct();
                    jumpPair.indexPreJump = origIndex;
                    jumpPair.time = timeJump;
                    jumpPair.valuePreJump = self.value(origIndex);
                    jumpPair.valuePostJump = self.value(origIndex+1);
                    break
                else
                    i = i-1;
                end
            end
            
        end
 
        
    end
end