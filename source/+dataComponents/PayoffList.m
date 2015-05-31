classdef PayoffList < matlab.mixin.Copyable & managers.TypedClass
    
    properties (Constant, GetAccess = protected)
        % Properties of payoff list
        BLOCKSIZE = 100
        JUMPBLOCKSIZE = 100/5
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        pt                  % Pointer to last free position
        listSize
        listJumpsSize
        
        discRate
        % ----------- %
        % Objects
        % ----------- %
        
    end
    
    properties (GetAccess = protected, SetAccess = protected)
        % Registered properties
        time
        value
        duration
        type
        
        % Calculated properties
        balance
        
        % Auxiliary properties
        
        state       % Updated status of each table field
        
        jumpsIndex  % Indices corresponding to all pre-jump indices
        jumpsCounter = 0
    end
    
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = PayoffList(discountRate)
        %{
        * 
        
            Input
                
            Output
                
        %}
            import dataComponents.Transaction
            
            listTypes = {Transaction.CONTRIBUTION, ...
                Transaction.INVESTMENT, ...
                Transaction.MAINTENANCE, ...
                Transaction.INSPECTION, ...
                Transaction.PENALTY, ...
                Transaction.FINAL };
            
        
            self@managers.TypedClass(listTypes);
            
            self.pt = 1;
            self.listSize = self.BLOCKSIZE;
            self.listJumpsSize = self.BLOCKSIZE/5;
            self.discRate = discountRate;
            
            % Registered lists
            self.time = zeros(self.BLOCKSIZE,1);
            self.value = zeros(self.BLOCKSIZE,1);
            self.duration = zeros(self.BLOCKSIZE,1);
            self.type = cell(self.BLOCKSIZE,1);
            
            % Calculated lists                                      Number
            self.balance = zeros(self.BLOCKSIZE,1);            %(1)
            
            % Update if more calculated lists are added!
            numberCalculatedLists = 1;
            
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
            st.duration = self.duration(ids);
            st.type = self.type(ids);
            st.balance = self.balance(ids);
            
            st.state = self.state(ids);
            
            if nargin == 1
                st.jumpsIndex = self.jumpsIndex(1:self.jumpsCounter);
            end
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function id = register(self, time, value, type)
        %{
        * 
        
            Input
                
            Output
                
        %}
            % Check validity of arguments
            
            if self.pt > 1
                assert(time >= self.time(self.pt-1), ...
                    'The time of observations must be non-decreasing.')
                if time == self.time(self.pt-1)
                    self.registerJump();
                end
            end
            
            
            % Validate type
            assert(self.isValidType(type) ,...
                'The type entered as argument is not valid')
            
            % Registers time, value, type, duration
            id = self.pt;
            self.time(id) = time;
            self.value(id) = value;
            self.type{id} = type;
            %self.duration(id) = dur; % Duration will possibly be
            %deprecated
            
            % Makes arrays bigger if necessary
            if self.pt + (self.BLOCKSIZE/10) > self.listSize
                self.extendArrays();
            end
            
            % Updates pointer
            self.pt = self.pt + 1;
        end
        
        
        function extendArrays(self)
        %{
        * Sets all measures out-of-date
        
            Input
                payoff
            Output
                
        %}
            % Increments list size
            self.listSize = self.listSize + self.BLOCKSIZE;
            
            % Extends registers lists
            self.time(self.pt+1:self.listSize, :) = 0;
            self.value(self.pt+1:self.listSize, :) = 0;
            self.type{self.listSize,1} = [];
            self.duration(self.pt+1:self.listSize, :) = 0;
            
            % Extends calculated lists
            self.balance(self.pt+1:self.listSize, :) = 0;
            
            % Extends state matrix for all lists (columns)
            self.state(self.pt+1:self.listSize, :) = false;
        end
        
        
        function extendJumpsArray(self)
        %{
        * 
        
            Input
                
            Output
                
        %}
            self.listJumpsSize = self.listJumpsSize + self.JUMPBLOCKSIZE;
            self.jumpsIndex(self.jumpsCounter+1:self.listJumpsSize, :) = 0;
        end
        
        
        function registerJump(self)
        %{
        * 
        
            Input
                
            Output
                
        %}
            self.jumpsCounter = self.jumpsCounter + 1;
            
            % Register the pre-jump index!
            self.jumpsIndex(self.jumpsCounter) = self.pt - 1;
            
            if self.jumpsCounter + (self.JUMPBLOCKSIZE/10) > self.listJumpsSize
                self.extendJumpsArray();
            end
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function val = getBalancePostFlow(thisPayoff, id)
        %{
        * 
        
            Input
                
            Output
                
        %}
            if nargin < 2
                id = thisPayoff.pt - 1;
            end
            
            if thisPayoff.duration(id) == 0
                val = thisPayoff.getBalancePreFlow('index',id) + thisPayoff.value(id);
            else
                val = thisPayoff.getBalancePreFlow('index',id);
            end
        end
        
        
        function balValue = getBalancePreFlow(thisPayoff, varargin)
        %{
        * 
        
            Input
                
            Output
                
        %}
            positionStruct = struct();
            
            if nargin < 2
                index = thisPayoff.pt - 1;
                positionStruct.index = index;
            else
                assert(length(varargin) == 2, 'Two arguments were expected')
                
                if strcmp(varargin{1},'index')
                    index = varargin{2};
                    assert(index >= 1,'Index must be greater or equal than 1')
                    positionStruct.index = index;
                    
                elseif strcmp(varargin{1},'time')
                    time = varargin{2};
                    assert(time >= 0 , 'Time must be non-negative')
                    index = thisPayoff.timeToIndex(time);
                    
                    positionStruct.index = index;
                    positionStruct.time = time;
                else
                    error('Unexpected arguments')
                end
            end
            
            stateColNumber = 1;
            
            % If balance value is already updated
            if thisPayoff.state(index, stateColNumber) == true
                balValue = thisPayoff.balance(index);
            else
                balValue = thisPayoff.calculateBalance(positionStruct);
                thisPayoff.balance(index) = balValue;
                thisPayoff.state(index, stateColNumber) = true;
            end
            
        end
        
        
        function balValue = calculateBalance(thisPayoff, positionStruct)
        %{
        * Calculate balance NOT including the value of the position
        specified (whether index or time)
        
            Input
                
            Output
                
        %}
            logicalTest = isfield(positionStruct, 'index') || isfield(positionStruct, 'time');
            assert( logicalTest, 'Either "index" or "time" must be specified')
            
            % If index is specified but time is not
            if isfield(positionStruct, 'index') && ~isfield(positionStruct, 'time')
                index = positionStruct.index;
                time = thisPayoff.time(index);
            
            % If index is specified and time is too
            elseif isfield(positionStruct, 'index') && isfield(positionStruct, 'time')
                time = positionStruct.time;
                index = positionStruct.index;
            else
                error('This should not happen')
            end

            valInst = 0;  % Sum of instantaneous flows
            valDist = 0;  % Sum of distributed flows
            
            for i=1:index-1
                % If instantaneous flow
                if thisPayoff.duration(i) == 0
                    
                    deltaTime = time - thisPayoff.time(i);
                    fv = futureValueFlow(thisPayoff.value(i), deltaTime, thisPayoff.discRate);
                    valInst = valInst + fv;
                    
                else % If distributed flow
                    
                    ti = thisPayoff.time(i);        % Initial time of flow
                    dur = thisPayoff.duration(i);   % Duration of flow
                    tf = min(time, ti+dur);         % Upper bound for integral
                    effDur = tf-ti;                 % Effective duration of flow
                    
                    cmltFv = futureValueContFlow(thisPayoff.value(i), 0, effDur, thisPayoff.discRate);
                    
                    if tf < time
                        extraTime = time - tf;
                        cmltFv = futureValueFlow(cmltFv, extraTime, thisPayoff.discRate);
                    end
                    
                    valDist = valDist + cmltFv;
                end
            end
            balValue = valInst + valDist;
        end
        

        function answer = isType(thisPayoff, type, id)
        %{
        
            Input
                
            Output
                
        %}
            answer =  strcmp(type, thisPayoff.type{id});
        end
        
        
        function st = returnPayoffsOfType(self, type)
        %{
        * 
        
            Input
                
            Output
                
            % TODO This method generates some error
        %}
            assert(self.isValidType(type), 'The type is not valid')
            
            lastValidIndex = self.pt - 1;
            
            % Cell array of strings type
            stringCell = self.type(1:lastValidIndex);
            
            % Boolean indices
            ids = strcmp(type, stringCell);
            
            % Call getData for boolean indices
            st = self.getData(ids);
        end
        
        
        function presentValue = getNPV(self, tm)
        %{
        *Calculates and returns the NPV of the linked-list of payoffs up
        until (and including) thisPayoff
        
            Input
                None
            Output
                PresentValue: [class double] Present value caltulated in
                time t = 0
        %}
            
            t = max(self.time + self.duration);
            deltaTime = tm - t;
            
            if deltaTime > 0
                postFlowBalance = self.getBalancePostFlow();
                currentBalance = futureValueFlow(postFlowBalance, deltaTime, self.discRate);
            elseif deltaTime == 0
                currentBalance = self.getBalancePostFlow();
            else
                error('This should not happen')
            end
            
            presentValue = presentValueFlow(currentBalance, tm, self.discRate);
        end
        
        
        function st = getBalanceHistory(self, finalTime)
        %{
        * 
        
            Input
            
            Output
                
        %}
            lastValidIndex = self.pt - 1;
            st = struct();
            cont = 0;
            
            for i=1:lastValidIndex
                
                balBefore = self.getBalancePreFlow('index',i);
                
                if i==1 || ~ismember(i-1, self.jumpsIndex)
                    % Point before flow (jump)
                    cont = cont + 1;
                    st.time(cont) = self.time(i);
                    st.balance(cont) = balBefore;
                end
                
                if self.duration(i) == 0
                    % Point after flow (jump)
                    cont = cont + 1;
                    st.time(cont) = self.time(i);
                    st.balance(cont) = balBefore + self.value(i);
                end
            end
            
            %{
            remainingTime = finalTime - st.time(cont);
            
            if remainingTime > 0
                prevBal = st.balance(cont);
                
                cont = cont + 1;
                
                st.time(cont) = finalTime;
                st.balance(cont) = futureValueFlow(prevBal, remainingTime, thisPayoff.discRate);
            end
            %}
        end
        
        
    end
end

%% ::::::::::::::::::    Auxiliary functions    :::::::::::::::::::
% *****************************************************************

function value = futureValueContFlow(flow, ti, tf, discRate)
%{
* 

    Input

    Output

%}

value = flow/discRate * (exp(discRate*tf)-exp(discRate*ti));

end


function value = presentValueFlow(futureValue, futureTime, discRate)
%{
* 

    Input

    Output

%}

value = futureValue*exp(-discRate*futureTime);

end


function value = futureValueFlow(presentValue, futureTime, discRate)
%{
* 

    Input

    Output

%}

value = presentValue*exp(discRate*futureTime);

end
