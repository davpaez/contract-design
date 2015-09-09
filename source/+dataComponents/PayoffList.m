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
        
        % ----------- %
        % Objects
        % ----------- %
        
    end
    
    properties (GetAccess = protected, SetAccess = protected)
        % Registered property arrays
        time
        balance
        valueFlow
        type
        
        % Calculated
        
        
        % Auxiliary properties
        
        state       % Updated status of each table field
        
        jumpsIndex  % Indices corresponding to all pre-jump indices
        jumpsCounter = 0
    end
    
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = PayoffList()
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
            
            % Registered lists
            self.time = zeros(self.BLOCKSIZE,1);
            self.valueFlow = zeros(self.BLOCKSIZE,1);
            self.type = cell(self.BLOCKSIZE,1);
            
            % Calculated lists                                      Number
            self.balance = zeros(self.BLOCKSIZE,1);            %(1)
            
            % Update if more calculated lists are added!
            numberCalculatedLists = 1;
            
            % State list: Contains update status of calculated lists
            self.state = false(self.BLOCKSIZE, numberCalculatedLists);
            
            % Auxiliary lists
            self.jumpsIndex = zeros(self.JUMPBLOCKSIZE, 1);
            
            % Initialize payoff list
            self.registerBalance(0, 0);
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
        
        
        function currentValue = getBalance(self)
        %{
        * 
        
            Input
                
            Output
                
        %}
            currentValue = self.balance(self.pt-1);
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
            st.balance = self.balance(ids);
            st.valueFlow = self.valueFlow(ids);
            st.type = self.type(ids);
            
            st.state = self.state(ids);
            
            if nargin == 1
                st.jumpsIndex = self.jumpsIndex(1:self.jumpsCounter);
            end
        end
        
        
        function st = getBalanceHistory(self)
            
             st = struct();
             
             st.time = self.time(1:self.pt-1);
             st.balance = self.balance(1:self.pt-1);
        end
        
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function id = registerFlow(self, time, value, type)
        %{
        * Registers instantaneous (jump) flow
        
            Input
                
            Output
                
        %}
            
            assert(time >= self.time(self.pt-1), ...
                'The jump must accur just after last payoff, but at the same numeric time.')
            
            % Validate type
            assert(self.isValidType(type) ,...
                'The type entered as argument is not valid')
            
            id = self.pt-1;
            if time > self.time(id)
                self.registerBalance(time, self.balance(id));
            end
            
            % Registers jump
            self.registerJump();
            
            % Registers time, value, type
            if self.time(self.pt-1) < time
                id = self.pt;
                self.time(id) = time;
                self.valueFlow(id) = value;
                self.balance(id) = self.balance(self.pt-1);
                self.type{id} = type;
            else
                id = self.pt-1;
                self.valueFlow(id) = value;
                self.type{id} = type;
            end
            
            self.registerBalance(time, self.balance(self.pt-1) + value);
        end
        
        
        function id = registerBalance(self, time, value)
        %{
        * Registers balance values to the balance history
        
            Input
                
            Output
                
        %}
            
            % Registers balance
            n = length(time);
            
            for i=1:n
                
                id = self.pt;
                
                if self.pt > 1
                    if time(i) == self.time(id-1) && value(i) == self.balance(id-1)
                        continue
                    end
                end
                
                self.time(id) = time(i);
                self.balance(id) = value(i);
                
                % Makes arrays bigger if necessary
                if self.pt + (self.BLOCKSIZE/10) > self.listSize
                    self.extendArrays();
                end

                % Updates pointer
                self.pt = self.pt + 1;
                
            end
            
            
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
            self.balance(self.pt+1:self.listSize, :) = 0;
            self.valueFlow(self.pt+1:self.listSize, :) = 0;
            self.type{self.listSize,:} = []; % This is ok!
            
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
            self.jumpsIndex(self.jumpsCounter) = self.pt;
            
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
            
            val = thisPayoff.getBalancePreFlow('index', id) + thisPayoff.valueFlow(id);

        end
        
        
        function balValue = getBalancePreFlow(thisPayoff, varargin)
        %{
        * %TODO Fix this method
        
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
        
        
        function presentValue = getNPV(self)
        %{
        * 
        
            Input
            
            Output
                
        %}
            %TODO
        end
        
        
        function data = getDataJumps(self)
            data = self.getData(self.jumpsIndex(1:self.jumpsCounter));
        end
        
        function plot(self)
            x = self.time(1:self.pt-1);
            y = self.balance(1:self.pt-1);
            
            figure
            plot(x, y, '-o')
            xlabel('Time')
        end
        
    end
end