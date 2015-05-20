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
        
        function thisObs = ObservationList()
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            thisObs.pt = 1;
            thisObs.listSize = thisObs.BLOCKSIZE;
            thisObs.listJumpsSize = thisObs.BLOCKSIZE/5;
            
            % Registered lists
            thisObs.time = zeros(thisObs.BLOCKSIZE,1);
            thisObs.value = zeros(thisObs.BLOCKSIZE,1);
            
            % Calculated lists                                     Number
            thisObs.cumSum = zeros(thisObs.BLOCKSIZE,1);            %(1)
            thisObs.area = zeros(thisObs.BLOCKSIZE,1);              %(2)
            thisObs.average = zeros(thisObs.BLOCKSIZE,1);           %(3)
            thisObs.meanValue = zeros(thisObs.BLOCKSIZE,1);         %(4)
            thisObs.deviation = zeros(thisObs.BLOCKSIZE,1);         %(5)
            
            % Update if more calculated lists are added!
            numberCalculatedLists = 5;
            
            % State list: Contains update status of calculated lists
            thisObs.state = false(thisObs.BLOCKSIZE, numberCalculatedLists);
            
            % Auxiliary lists
            thisObs.jumpsIndex = zeros(thisObs.JUMPBLOCKSIZE, 1);
        end
        
        
		%% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************
        
        function currentTime = getCurrentTime(thisObs)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            currentTime = thisObs.time(thisObs.pt-1);
        end
        
        
        function currentValue = getCurrentValue(thisObs)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            currentValue = thisObs.value(thisObs.pt-1);
        end
        
        
        function val = getValue(thisObs, id)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            val = thisObs.value(id);
        end
        
        
        function st = getData(thisObs, ids)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if nargin < 2
                lastValidIndex = thisObs.pt - 1;
                ids = 1:lastValidIndex;
            end
            
            st = struct();
            
            st.time = thisObs.time(ids);
            st.value = thisObs.value(ids);
            st.cumSum = thisObs.cumSum(ids);
            st.area = thisObs.area(ids);
            st.average = thisObs.average(ids);
            st.meanValue = thisObs.meanValue(ids);
            st.deviation = thisObs.deviation(ids);
            
            st.state = thisObs.state(ids);
            
            if nargin == 1
                st.jumpsIndex = thisObs.jumpsIndex(1:thisObs.jumpsCounter);
            end
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function pointer = register(thisObs, time, value)
        %{
        * 
        
            Input
            
            Output
                
        %}
            pointer = thisObs.pt;
            lastEntry = pointer-1;
            
            if pointer > 1
                % Checks validity of entry
                assert(time >= thisObs.time(lastEntry), ...
                    'The time of observations must be non-decreasing.')
                
                % Registers if current entry creates a jump
                if time == thisObs.time(lastEntry)
                    thisObs.registerJump();
                end
            end
            
            % Registers time and value
            thisObs.time(pointer) = time;
            thisObs.value(pointer) = value;
            
            % Makes arrays bigger if necessary
            if (pointer + thisObs.SLACK) > thisObs.listSize
                thisObs.extendArrays();
            end
            
            % Updates pointer
            thisObs.pt = pointer + 1;
        end
        
        
        function extendArrays(thisObs)
        %{
        * Extends all arrays of thisObservation
        
            Input
            
            Output
                
        %}
            
            % Increments register or list size
            thisObs.listSize = thisObs.listSize + thisObs.BLOCKSIZE;
            
            % Extends registers lists
            thisObs.time(thisObs.pt+1:thisObs.listSize, :) = 0;
            thisObs.value(thisObs.pt+1:thisObs.listSize, :) = 0;
            
            % Extends calculated lists
            thisObs.cumSum(thisObs.pt+1:thisObs.listSize, :) = 0;
            thisObs.area(thisObs.pt+1:thisObs.listSize, :) = 0;
            thisObs.average(thisObs.pt+1:thisObs.listSize, :) = 0;
            thisObs.meanValue(thisObs.pt+1:thisObs.listSize, :) = 0;
            thisObs.deviation(thisObs.pt+1:thisObs.listSize, :) = 0;
            
            % Extends state matrix for all lists (columns)
            thisObs.state(thisObs.pt+1:thisObs.listSize, :) = false;
        end
        
        
        function extendJumpsArray(thisObs)
        %{
        * Extends array of jumpsIndex
        
            Input
            
            Output
                
        %}
            
            thisObs.listJumpsSize = thisObs.listJumpsSize + thisObs.JUMPBLOCKSIZE;
            thisObs.jumpsIndex(thisObs.jumpsCounter+1:thisObs.listJumpsSize, :) = 0;
        end
        
        
        function registerJump(thisObs)
        %{
        * Register the index of the pre-jump observation in the jumpsIndex
        attribute of thisObs. The index is assumed to be the index 
        previous to the pointer to the last free position (i.e.,  pt-1  )
        
            Input
            
            Output
                
        %}
            
            thisObs.jumpsCounter = thisObs.jumpsCounter + 1;
            
            % Registers the pre-jump index!
            thisObs.jumpsIndex(thisObs.jumpsCounter) = thisObs.pt-1;
            
            if thisObs.jumpsCounter + (thisObs.JUMPBLOCKSIZE/10) > thisObs.listJumpsSize
                thisObs.extendJumpsArray();
            end
        end
        
        
        function cumSumValue = getCumSum(thisObs, index)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if nargin < 2
                index = inf;
            end
            
            stateColNumber = 1;
            
            lastValidIndex = thisObs.pt-1;
            
            if index > lastValidIndex
                index = lastValidIndex;
            end
            
            if thisObs.state(index,stateColNumber) == true
                cumSumValue = thisObs.cumSum(index);
            else
                cumSumValue = sum(thisObs.value(1:index));
                thisObs.cumSum(index) = cumSumValue;
                thisObs.state(index,stateColNumber) = true;
            end
        end
        
        
        function a = getArea(thisObs, index)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if nargin < 2
                index = inf;
            end
            
            stateColNumber = 2;
            
            lastValidIndex = thisObs.pt-1;
            
            if index > lastValidIndex
                index = lastValidIndex;
            end
            
            if thisObs.state(index,stateColNumber) == true
                a = thisObs.area(index);
            else
                if index == 1
                    a = 0;
                else
                    a = trapz(thisObs.time(1:index), thisObs.value(1:index));
                    thisObs.area(index) = a;
                    thisObs.state(index,stateColNumber) = true;
                end
            end
        end
        
        
        function av = getAverage(thisObs, index)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if nargin < 2
                index = inf;
            end
            
            stateColNumber = 3;
            
            lastValidIndex = thisObs.pt-1;
            
            if index > lastValidIndex
                index = lastValidIndex;
            end
            
            if thisObs.state(index,stateColNumber) == true
                av = thisObs.average(index);
            else
                av = mean(thisObs.value(1:index));
                thisObs.average(index) = av;
                thisObs.state(index,stateColNumber) = true;
            end
        end
        
        
        function m = getMeanValue(thisObs, index)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if nargin < 2
                index = inf;
            end
            
            stateColNumber = 4;
            
            lastValidIndex = thisObs.pt-1;
            
            if index > lastValidIndex
                index = lastValidIndex;
            end
            
            if thisObs.state(index,stateColNumber) == true
                m = thisObs.meanValue(index);
            else
                if index == 1
                    m = thisObs.getValue(index);
                else
                    m = thisObs.getArea(index)/(thisObs.time(index)-thisObs.time(1));
                end
                thisObs.meanValue(index) = m;
                thisObs.state(index,stateColNumber) = true;
            end
        end
        
        
        function dev = getDeviation(thisObs, index)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if nargin < 2
                index = inf;
            end
            
            stateColNumber = 5;
            
            lastValidIndex = thisObs.pt-1;
            
            if index > lastValidIndex
                index = lastValidIndex;
            end
            
            if thisObs.state(index,stateColNumber) == true
                dev = thisObs.deviation(index);
            else
                dev = std(thisObs.value(1:index));
                thisObs.deviation(index) = dev;
                thisObs.state(index,stateColNumber) = true;
            end
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function l = getLength(thisObs)
        %{
        * 
        
            Input
            
            Output
                
        %}
            l = thisObs.pt - 1;
        end
        
        
        function [index, extra] = timeToIndex(thisobs, time)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            index = find(thisobs.time <= time, 1, 'last');
            assert(~isempty(index), 'No registry was found')
            
            extra = time - thisobs.time(index);
        end
        
        
        function sumValue = getSumBetween(thisObs, indexFirst, indexLast)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            lastValidIndex = thisObs.pt-1;
            
            assert( nargin == 3, 'The index arguments are required.')
            assert( indexFirst >= 1, 'First index must be greater or equal than 1.')
            assert( indexFirst < indexLast, 'Second index must be greater than first.')
            
            finalIndex = min(lastValidIndex,indexLast);
            
            sumValue = sum(thisObs.value(indexFirst:finalIndex));
        end
        
        
        function st = getMeanValueHistory(thisObs)
        %{
        * Returns a struct containing the fields time and meanValue
        
            Input
                None
            
            Output
                st: [class struct] 
        %}
            
            lastValidIndex = thisObs.pt-1;
            
            st = struct();
            st.time = zeros(lastValidIndex,1);
            st.area = zeros(lastValidIndex,1);
            
            for i=1:lastValidIndex
                st.time(i) = thisObs.time(i);
                st.meanValue(i) = thisObs.getMeanValue(i);
            end
        end
        

        function jumpPair = extractLastJumpPair(thisObs, time)
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
            i = thisObs.jumpsCounter;
            
            while i >= 1
                
                origIndex = thisObs.jumpsIndex(i);
                timeJump = thisObs.time(origIndex);
                
                if timeJump <= time
                    jumpPair = struct();
                    jumpPair.indexPreJump = origIndex;
                    jumpPair.time = timeJump;
                    jumpPair.valuePreJump = thisObs.value(origIndex);
                    jumpPair.valuePostJump = thisObs.value(origIndex+1);
                    break
                else
                    i = i-1;
                end
            end
            
        end
        
        
        function value = interpolate(thisObs, time)
        %{
        * 
        
            Input
            
            Output
                
        %}
            lastEntry = thisObs.pt - 1;
            
            t = thisObs.time(1:lastEntry);
            v = thisObs.value(1:lastEntry);
            %TODO Do not use interp1. It does not work because the time
            %vector is not strict monotonically increasing
            value = interp1(t, v, time);
        end
        
        
    end
end