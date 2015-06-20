%{
# PURPOSE

TODO

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
        cumSum
        area
        average
        meanValue
        deviation
        
        % Auxiliary properties
        
        state           % Updated status of each table field
        
        jumpsIndex      % Indices corresponding to all pre-jump indices
        jumpsCounter = 0
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
            
            % Calculated lists                                     Number
            self.cumSum = zeros(self.BLOCKSIZE,1);            %(1)
            self.area = zeros(self.BLOCKSIZE,1);              %(2)
            self.average = zeros(self.BLOCKSIZE,1);           %(3)
            self.meanValue = zeros(self.BLOCKSIZE,1);         %(4)
            self.deviation = zeros(self.BLOCKSIZE,1);         %(5)
            
            % Update if more calculated lists are added!
            numberCalculatedLists = 5;
            
            % State list: Contains update status of calculated lists
            self.state = false(self.BLOCKSIZE, numberCalculatedLists);
            
            % Auxiliary lists
            self.jumpsIndex = zeros(self.JUMPBLOCKSIZE, 1);
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
            
            if nargin < 2
                lastValidIndex = self.pt - 1;
                ids = 1:lastValidIndex;
            end
            
            st = struct();
            
            st.time = self.time(ids);
            st.value = self.value(ids);
            st.cumSum = self.cumSum(ids);
            st.area = self.area(ids);
            st.average = self.average(ids);
            st.meanValue = self.meanValue(ids);
            st.deviation = self.deviation(ids);
            
            st.state = self.state(ids);
            
            if nargin == 1
                st.jumpsIndex = self.jumpsIndex(1:self.jumpsCounter);
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
            pointer = self.pt;
            lastEntry = pointer-1;
            
            if pointer > 1
                % Checks validity of entry
                assert(time >= self.time(lastEntry), ...
                    'The time of observations must be non-decreasing.')
                
                % Registers if current entry creates a jump
                if time == self.time(lastEntry)
                    self.registerJump();
                end
            end
            
            % Registers time and value
            self.time(pointer) = time;
            self.value(pointer) = value;
            
            % Makes arrays bigger if necessary
            if (pointer + self.SLACK) > self.listSize
                self.extendArrays();
            end
            
            % Updates pointer
            self.pt = pointer + 1;
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
            self.cumSum(self.pt+1:self.listSize, :) = 0;
            self.area(self.pt+1:self.listSize, :) = 0;
            self.average(self.pt+1:self.listSize, :) = 0;
            self.meanValue(self.pt+1:self.listSize, :) = 0;
            self.deviation(self.pt+1:self.listSize, :) = 0;
            
            % Extends state matrix for all lists (columns)
            self.state(self.pt+1:self.listSize, :) = false;
        end
        
        
        function extendJumpsArray(self)
        %{
        * Extends array of jumpsIndex
        
            Input
            
            Output
                
        %}
            
            self.listJumpsSize = self.listJumpsSize + self.JUMPBLOCKSIZE;
            self.jumpsIndex(self.jumpsCounter+1:self.listJumpsSize, :) = 0;
        end
        
        
        function registerJump(self)
        %{
        * Register the index of the pre-jump observation in the jumpsIndex
        attribute of self. The index is assumed to be the index 
        previous to the pointer to the last free position (i.e.,  pt-1  )
        
            Input
            
            Output
                
        %}
            
            self.jumpsCounter = self.jumpsCounter + 1;
            
            % Registers the pre-jump index!
            self.jumpsIndex(self.jumpsCounter) = self.pt-1;
            
            if self.jumpsCounter + (self.JUMPBLOCKSIZE/10) > self.listJumpsSize
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
                cumSumValue = self.cumSum(index);
            else
                cumSumValue = sum(self.value(1:index));
                self.cumSum(index) = cumSumValue;
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
                m = self.meanValue(index);
            else
                if index == 1
                    m = self.getValue(index);
                else
                    m = self.getArea(index)/(self.time(index)-self.time(1));
                end
                self.meanValue(index) = m;
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
                st.meanValue(i) = self.getMeanValue(i);
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
            i = self.jumpsCounter;
            
            while i >= 1
                
                origIndex = self.jumpsIndex(i);
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
        
        
        function value = interpolate(self, time)
        %{
        * 
        
            Input
            
            Output
                
        %}
            lastEntry = self.pt - 1;
            
            t = self.time(1:lastEntry);
            v = self.value(1:lastEntry);
            %TODO Do not use interp1. It does not work because the time
            %vector is not strict monotonically increasing
            value = interp1(t, v, time);
        end
        
        
    end
end