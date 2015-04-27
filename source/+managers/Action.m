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
    
    properties (Dependent)
        
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
        %% Constructor
        
        
        function thisAction = Action(type, nameExecutor)
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
            
            thisAction@managers.TypedClass(listTypes);
            
            thisAction@managers.ItemSetting();
            
            assert(thisAction.isValidType(type), ...
                'The type entered as argument is not valid');
            
            assert(Action.isValidExecutor(nameExecutor), ...
                'The name of executor entered as argument is not valid');
            
            
            
            thisAction.actionType = type;
            thisAction.nameExecutor = nameExecutor;
            
            thisAction.proactive = thisAction.isProactive();
            
        end
        
        
        %% Getter functions
        
        
        function answer = get.determinedAction(thisAction)
        %{
        
            Input
                
            Output
                
        %}
            
            answer = false;
            
            % Check that a selected strategy exists
            if ~isempty(thisAction.strategy)
                % Check that the strategy selected is determined
                if thisAction.strategy.determinedStrategy
                    answer = true;
                end
            end
        end
        
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        function ca = returnCopy(thisAction)
        %{
        
            Input
                
            Output
                
        %}
            ca = copy(thisAction);
        end
        
        
        function index = getIndexSelectedStrategy(thisAction)
        %{
        
            Input
                
            Output
                
        %}
            index = thisAction.indexSelectedStrategy;
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------
        % ----------------------------------------------------------------
        
        
        function selectStrategy(thisAction, index)
        %{
        
            Input
                
            Output
                
        %}
            stratArray = returnStrategyArray(thisAction.actionType);
            
            thisAction.strats_Number = length(stratArray);
            
            thisAction.strategy = returnStrategyByIndex(stratArray, index);
            thisAction.indexSelectedStrategy = index;
        end
        
        
        function setParamsValue_Random(thisAction)
        %{
        
            Input
                
            Output
                
        %}
            assert(~isempty(thisAction.indexSelectedStrategy), ...
                ['No strategy index has been specified for this action, identified as ',thisAction.identifier])
            
            thisAction.strategy.setParamsValue_Random();
            
        end
        
        
        function setParamsValue_UserInput(thisAction)
        %{
        
            Input
                
            Output
                
        %}
            assert(~isempty(thisAction.indexSelectedStrategy), ...
                ['No strategy index has been specified for this action, identified as ',thisAction.identifier])
            
            thisAction.strategy.setParamsValue_UserInput();
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        
        function decide(thisAction, theMsg)
        %{
        
            Input
                
            Output
                
        %}
            assert(thisAction.determinedAction, ...
                'The strategy must be determined before it can be executed');
            
            thisAction.strategy.decide(theMsg);
            
            if thisAction.isProactive()
                theExecutor = theMsg.getExecutor();
                currentTime = theExecutor.time;
                containsTime = ~cellfun(@isempty,strfind(theMsg.typeRequestedInfo,'TIME'));
                
                assert(sum(containsTime) <= 1)
                
                timeOutput = theMsg.valuesResponse{containsTime};
                
                assert(timeOutput > currentTime, ...
                    'Proactive actions must return a time greater than the current time.')
            end
        end
        
        
        function checkValidity(thisAction)
        %{
        
            Input
                
            Output
                
        %}
        %TODO
            assert(thisAction.determined, ...
                            'This itemSetting must be determined')
        end
        
        
        function answer = isProactive(thisAction)
        %{
        
            Input
                
            Output
                
        %}
            if ~isempty(thisAction.proactive)
                answer = thisAction.proactive;
            else
                proactiveTypes = {  thisAction.INSPECTION, ...
                                    thisAction.VOL_MAINT, ...
                                    thisAction.SHOCK};
                if ismember(thisAction.actionType, proactiveTypes)
                    answer = true;
                else
                    answer = false;
                end
            end
        end
        
        
        function answer = isSensitive(thisAction)
        %{
        
            Input
                
            Output
                
        %}
            answer = thisAction.strategy.isSensitive();
        end
        
        
    end
    
end

%% Auxiliar functions


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

    
    function strat = returnStrategyByIndex(stratArray, index)
    %{
    *
        Input

        Output

    %}
        strat = [];

        for i=1:length(stratArray)
            currentStrat = stratArray{i};
            if index == currentStrat.index
                strat = currentStrat;
                break
            end
        end

        assert(~isempty(strat), ...
            'There are no strategies that coincide with the index specified')
    end
