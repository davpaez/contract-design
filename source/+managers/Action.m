classdef Action < managers.ItemSetting & managers.TypedClass
    %TODO Will be deprecated
    
    properties (Constant, Hidden = true)
        % Types of actions
        CONTRACT_OFFER  = 'behavior.principal.contractOffer'
        INSPECTION  = 'behavior.principal.inspection.'
        VOL_MAINT   = 'behavior.agent.voluntaryMaint.'
        MAND_MAINT  = 'behavior.agent.mandatoryMaint.'
        SHOCK       = 'behavior.nature.shock.'
        PENALTY     = 'behavior.principal.penaltyFee.'
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        actionType
        nameExecutor
        indexSelectedStrategy
        strats_Number
        
        determinedAction
        
        proactive

        % ----------- %
        % Objects
        % ----------- %
        strategy
    end
    
    methods (Static)
        
        function answer = isValidExecutor(nameExecutor)
        %{
        
            Input
                
            Output
                
        %}
            import managers.Action
            
            answer = false;
            validExecutors = {  Action.PRINCIPAL, ...
                Action.AGENT, ...
                Action.NATURE};
            
            nExecutors = length(validExecutors);
            
            for i=1:nExecutors
                currentExec = validExecutors{i};
                
                if strcmp(currentExec, nameExecutor);
                    answer = true;
                    break
                end
            end
        end
        
        
    end
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
        %{
        
            Input
                
            Output
                
        %}
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            cpObj.strategy = copy(obj.strategy);
        end
        
        
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Action(type, nameExecutor)
        %{
        
            Input
                
            Output
                
        %}
            import managers.Action
            
            listTypes = {Action.CONTRACT_OFFER, ...
                Action.INSPECTION, ...
                Action.VOL_MAINT, ...
                Action.MAND_MAINT, ...
                Action.SHOCK, ...
                Action.PENALTY};
            
            self@managers.TypedClass(listTypes);
            
            self@managers.ItemSetting();
            
            assert(self.isValidType(type), ...
                'The type entered as argument is not valid');
            
            assert(Action.isValidExecutor(nameExecutor), ...
                'The name of executor entered as argument is not valid');
            
            
            
            self.actionType = type;
            self.nameExecutor = nameExecutor;
            
            self.proactive = self.isProactive();
            
        end
        
        
        %% ::::::::::::::::::::    Getter methods    ::::::::::::::::::::::
        % *****************************************************************
        
        function answer = get.determinedAction(self)
        %{
        
            Input
                
            Output
                
        %}
            
            answer = false;
            
            % Check that a selected strategy exists
            if ~isempty(self.strategy)
                % Check that the strategy selected is determined
                if self.strategy.determinedStrategy
                    answer = true;
                end
            end
        end
        
        
		%% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************
        
        function ca = returnCopy(self)
        %{
        
            Input
                
            Output
                
        %}
            ca = copy(self);
        end
        
        
        function index = getIndexSelectedStrategy(self)
        %{
        
            Input
                
            Output
                
        %}
            index = self.indexSelectedStrategy;
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function selectStrategy(self, index)
        %{
        
            Input
                
            Output
                
        %}
            stratArray = returnStrategyArray(self.actionType);
            
            self.strats_Number = length(stratArray);
            
            self.strategy = returnStrategyByIndex(stratArray, index);
            self.indexSelectedStrategy = index;
        end
        
        
        function setParamsValue_Random(self)
        %{
        
            Input
                
            Output
                
        %}
            assert(~isempty(self.indexSelectedStrategy), ...
                ['No strategy index has been specified for this action, identified as ',self.identifier])
            
            self.strategy.setParamsValue_Random();
            
        end
        
        
        function setParamsValue_UserInput(self)
        %{
        
            Input
                
            Output
                
        %}
            assert(~isempty(self.indexSelectedStrategy), ...
                ['No strategy index has been specified for this action, identified as ',self.identifier])
            
            self.strategy.setParamsValue_UserInput();
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function decide(self, theMsg)
        %{
        
            Input
                
            Output
                
        %}
            assert(self.determinedAction, ...
                'The strategy must be determined before it can be executed');
            
            self.strategy.decide(theMsg);
            
            if self.isProactive()
                theExecutor = theMsg.getExecutor();
                currentTime = theExecutor.time;
                containsTime = ~cellfun(@isempty,strfind(theMsg.typeRequestedInfo,'TIME'));
                
                assert(sum(containsTime) <= 1)
                
                timeOutput = theMsg.valuesResponse{containsTime};
                
                assert(timeOutput > currentTime, ...
                    'Proactive actions must return a time greater than the current time.')
            end
        end
        
        
        function checkValidity(self)
        %{
        
            Input
                
            Output
                
        %}
        %TODO
            assert(self.determined, ...
                            'This itemSetting must be determined')
        end
        
        
        function answer = isProactive(self)
        %{
        
            Input
                
            Output
                
        %}
            if ~isempty(self.proactive)
                answer = self.proactive;
            else
                proactiveTypes = {  self.INSPECTION, ...
                                    self.VOL_MAINT, ...
                                    self.SHOCK};
                if ismember(self.actionType, proactiveTypes)
                    answer = true;
                else
                    answer = false;
                end
            end
        end
        
        
        function answer = isSensitive(self)
        %{
        
            Input
                
            Output
                
        %}
            answer = self.strategy.isSensitive();
        end
        
        
    end
end


%% ::::::::::::::::::    Auxiliary functions    :::::::::::::::::::
% *****************************************************************

function strategyArray = returnStrategyArray(typeAction)
%{
    * Search the appropriate folder corresponding to the type of action
    queried. Creates the strategy objects and forms a cell array of
    strategy objects

        Input
            typeAction: [class string]
        Output
            strategyArray: (cell array)[class Strategy]
%}

strategyArray = {};

behaviorFile = what('+behavior');

for i = 1:length(behaviorFile.packages)
    playerName = behaviorFile.packages{i};
    playerFile = what(['+behavior/+',playerName]);
    
    for j=1:length(playerFile.packages)
        actionName = playerFile.packages{j};
        query = dir(['+behavior/+',playerName,'/+',actionName,'/','*Strategy_*.m']);
        
        if ~isempty(query)
            numberStrategies = length(query);
            for k=1:numberStrategies
                spl = strsplit(query(k).name,'.m');
                className = spl{1};
                currentStrategy = feval(['behavior.',playerName,'.',...
                    actionName,'.',className]);
                typeCurrent = currentStrategy.getTypeAction();
                
                if strcmp(typeCurrent, typeAction)
                    strategyArray{k} = currentStrategy;
                end
            end
        end
    end
end

assert(~isempty(strategyArray), ...
    'There are no strategies that coincide with the type of action specified.')
end




