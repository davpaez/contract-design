classdef Payoff < matlab.mixin.Copyable & managers.TypedClass
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Hidden = true)
        
        % Types of cash flow/actions
        REVENUE = 'REVENUE'
        CONTRIBUTION = 'CONTRIBUTION'
        INVESTMENT = 'INVESTMENT'
        MAINTENANCE = 'MAINTENANCE'
        INSPECTION = 'INSPECTION'
        PENALTY = 'PENALTY'
        FINAL = 'FINAL'
    end
    
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
        %% Constructor
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function thisPff = Payoff(discountRate)
            
            import dataComponents.Payoff
            
            listTypes = {Payoff.REVENUE, ...
                Payoff.CONTRIBUTION, ...
                Payoff.INVESTMENT, ...
                Payoff.MAINTENANCE, ...
                Payoff.INSPECTION, ...
                Payoff.PENALTY, ...
                Payoff.FINAL };
            
        
            thisPff@managers.TypedClass(listTypes);
            
            thisPff.pt = 1;
            thisPff.listSize = thisPff.BLOCKSIZE;
            thisPff.listJumpsSize = thisPff.BLOCKSIZE/5;
            thisPff.discRate = discountRate;
            
            % Registered lists
            thisPff.time = zeros(thisPff.BLOCKSIZE,1);
            thisPff.value = zeros(thisPff.BLOCKSIZE,1);
            thisPff.duration = zeros(thisPff.BLOCKSIZE,1);
            thisPff.type = cell(thisPff.BLOCKSIZE,1);
            
            % Calculated lists                                      Number
            thisPff.balance = zeros(thisPff.BLOCKSIZE,1);            %(1)
            
            % Update if more calculated lists are added!
            numberCalculatedLists = 1;
            
            % State list: Contains update status of calculated lists
            thisPff.state = false(thisPff.BLOCKSIZE, numberCalculatedLists);
            
            % Auxiliary lists
            thisPff.jumpsIndex = zeros(thisPff.JUMPBLOCKSIZE, 1);
        end
            
        
        %% Getter functions
        
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        %{
        * 
        
            Input
            
            Output
                
        %}
        function currentTime = getCurrentTime(thisPff)
            currentTime = thisPff.time(thisPff.pt-1);
        end
        
        
        %{
        * 
        
            Input
            
            Output
                
        %}
        function currentValue = getCurrentValue(thisPff)
            currentValue = thisPff.value(thisPff.pt-1);
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function st = getData(thisPff, ids)
            if nargin < 2
                lastValidIndex = thisPff.pt - 1;
                ids = 1:lastValidIndex;
            end
            
            st = struct();
            
            st.time = thisPff.time(ids);
            st.value = thisPff.value(ids);
            st.duration = thisPff.duration(ids);
            st.type = thisPff.type(ids);
            st.balance = thisPff.balance(ids);
            
            st.state = thisPff.state(ids);
            
            if nargin == 1
                st.jumpsIndex = thisPff.jumpsIndex(1:thisPff.jumpsCounter);
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
        function id = register(thisPff, time, value, type, varargin)
            
            % Check validity of arguments
            
            if thisPff.pt > 1
                assert(time >= thisPff.time(thisPff.pt-1), ...
                    'The time of observations must be non-decreasing.')
                if time == thisPff.time(thisPff.pt-1)
                    thisPff.registerJump();
                end
            end
            
            if isempty(varargin)
                dur = 0;
            else
                assert(length(varargin) == 1, 'Wrong number of parameters varargin.')
                dur = varargin{1};   % Final time of flow
                assert(dur >= 0 , 'Duration must be non-negative')
            end
            
            % Validate type
            assert(thisPff.isValidType(type) ,...
                'The type entered as argument is not valid')
            
            % Registers time, value, type, duration
            id = thisPff.pt;
            thisPff.time(id) = time;
            thisPff.value(id) = value;
            thisPff.type{id} = type;
            thisPff.duration(id) = dur;
            
            % Makes arrays bigger if necessary
            if thisPff.pt + (thisPff.BLOCKSIZE/10) > thisPff.listSize
                thisPff.extendArrays();
            end
            
            % Updates pointer
            thisPff.pt = thisPff.pt + 1;
        end
        
        
        %{
        * Sets all measures out-of-date
        
            Input
                payoff
            Output
                
        %}
        function extendArrays(thisPff)
            
            % Increments list size
            thisPff.listSize = thisPff.listSize + thisPff.BLOCKSIZE;
            
            % Extends registers lists
            thisPff.time(thisPff.pt+1:thisPff.listSize, :) = 0;
            thisPff.value(thisPff.pt+1:thisPff.listSize, :) = 0;
            thisPff.type{thisPff.listSize,1} = [];
            thisPff.duration(thisPff.pt+1:thisPff.listSize, :) = 0;
            
            % Extends calculated lists
            thisPff.balance(thisPff.pt+1:thisPff.listSize, :) = 0;
            
            % Extends state matrix for all lists (columns)
            thisPff.state(thisPff.pt+1:thisPff.listSize, :) = false;
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function extendJumpsArray(thisPff)
            thisPff.listJumpsSize = thisPff.listJumpsSize + thisPff.JUMPBLOCKSIZE;
            thisPff.jumpsIndex(thisPff.jumpsCounter+1:thisPff.listJumpsSize, :) = 0;
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function registerJump(thisPff)
            
            thisPff.jumpsCounter = thisPff.jumpsCounter + 1;
            
            % Register the pre-jump index!
            thisPff.jumpsIndex(thisPff.jumpsCounter) = thisPff.pt - 1;
            
            if thisPff.jumpsCounter + (thisPff.JUMPBLOCKSIZE/10) > thisPff.listJumpsSize
                thisPff.extendJumpsArray();
            end
        end
        
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function val = getBalancePostFlow(thisPayoff, id)
            if nargin < 2
                id = thisPayoff.pt - 1;
            end
            
            if thisPayoff.duration(id) == 0
                val = thisPayoff.getBalancePreFlow('index',id) + thisPayoff.value(id);
            else
                val = thisPayoff.getBalancePreFlow('index',id);
            end
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function balValue = getBalancePreFlow(thisPayoff, varargin)
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
        
        
        %{
        * Calculate balance NOT including the value of the position
        specified (whether index or time)
        
            Input
                
            Output
                
        %}
        function balValue = calculateBalance(thisPayoff, positionStruct)
            
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
        
        
        %{
        
            Input
                
            Output
                
        %}
        function answer = isType(thisPayoff, type, id)
            answer =  strcmp(type, thisPayoff.type{id});
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        % TODO This method generates some error
        function st = returnPayoffsOfType(thisPff, type)
            import dataComponents.Payoff
            
            assert(thisPff.isValidType(type), 'The type is not valid')
            
            lastValidIndex = thisPff.pt - 1;
            
            % Cell array of strings type
            stringCell = thisPff.type(1:lastValidIndex);
            
            % Boolean indices
            ids = strcmp(type, stringCell);
            
            % Call getData for boolean indices
            st = thisPff.getData(ids);
        end
        
        
        %{
        *Calculates and returns the NPV of the linked-list of payoffs up
        until (and including) thisPayoff
        
            Input
                None
            Output
                PresentValue: [class double] Present value caltulated in
                time t = 0
        %}
        function presentValue = getNPV(thisPff, tm)
            
            t = max(thisPff.time + thisPff.duration);
            deltaTime = tm - t;
            
            if deltaTime > 0
                postFlowBalance = thisPff.getBalancePostFlow();
                currentBalance = futureValueFlow(postFlowBalance, deltaTime, thisPff.discRate);
            elseif deltaTime == 0
                currentBalance = thisPff.getBalancePostFlow();
            else
                error('This should not happen')
            end
            
            presentValue = presentValueFlow(currentBalance, tm, thisPff.discRate);
        end
        
        
        %{
        * 
        
            Input
            
            Output
                
        %}
        function st = getBalanceHistory(thisPff, finalTime)
            
            lastValidIndex = thisPff.pt - 1;
            st = struct();
            cont = 0;
            
            for i=1:lastValidIndex
                
                balBefore = thisPff.getBalancePreFlow('index',i);
                
                if i==1 || ~ismember(i-1, thisPff.jumpsIndex)
                    % Point before flow (jump)
                    cont = cont + 1;
                    st.time(cont) = thisPff.time(i);
                    st.balance(cont) = balBefore;
                end
                
                if thisPff.duration(i) == 0
                    % Point after flow (jump)
                    cont = cont + 1;
                    st.time(cont) = thisPff.time(i);
                    st.balance(cont) = balBefore + thisPff.value(i);
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


%{
* 

    Input

    Output

%}
function value = futureValueContFlow(flow, ti, tf, discRate)

value = flow/discRate * (exp(discRate*tf)-exp(discRate*ti));

end


%{
* 

    Input

    Output

%}
function value = presentValueFlow(futureValue, futureTime, discRate)

value = futureValue*exp(-discRate*futureTime);

end


%{
* 

    Input

    Output

%}
function value = futureValueFlow(presentValue, futureTime, discRate)

value = presentValue*exp(discRate*futureTime);

end
