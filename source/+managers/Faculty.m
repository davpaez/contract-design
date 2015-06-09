classdef Faculty < managers.ItemSetting
    
    properties (Constant, Hidden = true)
        % Faculties of players
        CONTRACT_OFFER  = 'CONTRACT_OFFER'
        INSPECTION      = 'INSPECTION'
        VOL_MAINT       = 'VOL_MAINT'
        MAND_MAINT      = 'MAND_MAINT'
        SHOCK           = 'SHOCK'
        PENALTY         = 'PENALTY'
        
        % Folders behavior
        folder_contractOffer    = 'behavior.principal.ContractOffer'
        folder_inspection       = 'behavior.principal.Inspection'
        folder_volMaint         = 'behavior.agent.VoluntaryMaint'
        folder_mandMaint        = 'behavior.agent.MandatoryMaint'
        folder_shock            = 'behavior.nature.Shock'
        folder_penalty          = 'behavior.principal.PenaltyFee'
    end
    
    properties (Hidden = true)
        lock = false
    end
    
    properties
        idFaculty       % String identifier of this faculty
        packageAddress  % String to folder with decision rules classes and custom strategies classes
        nameExecutor    % String identifier 
        decisionVars    % Cell (column cell) with ids for decision vars of this faculty
        
        decisionRuleList    % Cell with DecisionRule objects
        
        customStratList
        autoStratList
        
        selectedStrategy        % Selected strategy
    end
    
    methods (Static)
        
        function decVars = getInfoDecVars(typeFaculty)
        %{
        * 
            Input
                
            Output
                
        %}
            
            import managers.Faculty
            import managers.Information
            
            switch typeFaculty
                case Faculty.CONTRACT_OFFER
                    decVars = {Information.CONTRACT_DURATION; ...
                Information.PAYMENT_SCHEDULE; ...
                Information.REVENUE_RATE_FUNC; ...
                Information.PERFORMANCE_THRESHOLD; ...
                Information.FARE};
                    
                case Faculty.INSPECTION
                    decVars = {Information.TIME_INSPECTION};
                    
                case Faculty.VOL_MAINT
                    decVars = {Information.TIME_VOL_MAINT ; ...
                Information.PERF_VOL_MAINT };
                    
                case Faculty.MAND_MAINT
                    decVars = {Information.PERF_MAND_MAINT};
                    
                case Faculty.SHOCK
                    decVars = {Information.TIME_SHOCK ; ...
                Information.FORCE_SHOCK };
                    
                case Faculty.PENALTY
                    decVars = {Information.VALUE_PENALTY_FEE};
                    
                otherwise
                    error('Type is not valid')
            end
            
        end
        
        function msg = createEmptyMessage(theExecutor, typeFaculty)
            %TODONEXT
            
            import dataComponents.Message
            import managers.Faculty
            
            msg = Message(theExecutor);
            decVars = Faculty.getInfoDecVars(typeFaculty);
            msg.setTypeRequestedInfo(decVars);
            
        end
        
        
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Faculty(type)
        %{
        
            Input
                
            Output
                
        %}
            
            switch type
                case self.CONTRACT_OFFER
                    self.setFacultyContractOffer();
                    
                case self.INSPECTION
                    self.setFacultyInspection();
                    
                case self.VOL_MAINT
                    self.setFacultyVolMaint();
                    
                case self.MAND_MAINT
                    self.setFacultyMandMaint();
                    
                case self.SHOCK
                    self.setFacultyShock();
                    
                case self.PENALTY
                    self.setFacultyPenalty();
                    
                otherwise
                    error('Type is not valid')
            end
            
            self.getDecisionRuleAndCustomStratList();
            self.createStrategies();
            
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function getDecisionRuleAndCustomStratList(self)
        %{
        
            Input
                
            Output
                
        %}
            
            % Search for all DecisionRule classes of this type of faculty
            % and create a list containing one object for each of these
            % classes.
            
            spl = strsplit(self.packageAddress,'.');
            
            mainFolder = spl{1};
            playerFolder = spl{2};
            facultyFolder = spl{3};
            
            pathFolder = ['+',mainFolder,'\+',playerFolder,'\+',facultyFolder];
            
            queryRules = dir([pathFolder,'\Rule_*.m']);
            numRules = length(queryRules);
            
            queryStrats = dir([pathFolder,'\Strategy_*.m']);
            numStrats = length(queryStrats);
            
            listRules = cell(numRules,1);
            listStrats = cell(numStrats,1);
            
            for i = 1:numRules
                ruleName = queryRules(i).name;
                className = strrep(ruleName, '.m', '');
                listRules{i} = feval([self.packageAddress,'.',className]);
            end
            
            for i = 1:numStrats
                stratName = queryStrats(i).name;
                className = strrep(stratName, '.m', '');
                listStrats{i} = feval([self.packageAddress,'.',className], self);
            end
            
            self.decisionRuleList = listRules;
            self.customStratList = listStrats;
        end
        
        
        function strategies = createStrategies(self)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Strategy
            
            coverageMatrix = getCoverageMatrix(...
                self.decisionVars, ...
                self.decisionRuleList);
            
            % Returns cell with rule arrays
            vectors = getCombinations(coverageMatrix);
            ruleCombinations = self.getRuleCombinations(vectors);
            
            n = length(ruleCombinations);
            strategies = cell(n,1);
            for i=1:n
                s = Strategy(['auto_',i], self.decisionVars);
                s.setDecisionRuleList(ruleCombinations{i});
                strategies{i} = s;
            end
            
            self.autoStratList = strategies;
        end
        
        
        function combinationArray = getRuleCombinations(self, vectors)
        %{
        
            Input
                
            Output
                
        %}
            [numDecRules, numCombinations] = size(vectors);
            combinationArray = cell(0);

            for i=1:numCombinations
                ruleArray = cell(0);

                v = vectors(:,i);

                for j=1:numDecRules
                    if v(j) == true
                        ruleArray{end+1,1} = copy(self.decisionRuleList{j});
                    end
                end

                combinationArray{end+1,1} = ruleArray;
            end
        end
        
        
        function setFacultyContractOffer(self)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(self.lock == false, ...
            'The lock is on!')
            
			% Set idFaculty
			self.idFaculty = self.CONTRACT_OFFER;
            
            % Set folder behavior
            self.packageAddress = self.folder_contractOffer;
            
            % Set executor
            self.nameExecutor = Information.PRINCIPAL;
            
            % Nature of decision vars
            self.decisionVars = self.getInfoDecVars(self.idFaculty);
            
            self.lock = true;
        end
        
        
        function setFacultyInspection(self)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(self.lock == false, ...
            'The lock is on!')
            
			% Set idFaculty
			self.idFaculty = self.INSPECTION;
            
            % Set folder behavior
            self.packageAddress = self.folder_inspection;
            
            % Set executor
            self.nameExecutor = Information.PRINCIPAL;
            
            % Nature of decision vars
            self.decisionVars = self.getInfoDecVars(self.idFaculty);
            
            self.lock = true;
        end
        
        
        function setFacultyVolMaint(self)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(self.lock == false, ...
            'The lock is on!')
            
			% Set idFaculty
			self.idFaculty = self.VOL_MAINT;
            
            % Set folder behavior
            self.packageAddress = self.folder_volMaint;
            
            % Set executor
            self.nameExecutor = Information.AGENT;
            
            % Nature of decision vars
            self.decisionVars = self.getInfoDecVars(self.idFaculty);
            
            self.lock = true;
        end
        
        
        function setFacultyMandMaint(self)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(self.lock == false, ...
            'The lock is on!')
        
			% Set idFaculty
			self.idFaculty = self.MAND_MAINT;
            
            % Set folder behavior
            self.packageAddress = self.folder_mandMaint;
            
            % Set executor
            self.nameExecutor = Information.AGENT;
            
            % Nature of decision vars
            self.decisionVars = self.getInfoDecVars(self.idFaculty);
            
            self.lock = true;
        end
        
        
        function setFacultyShock(self)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(self.lock == false, ...
            'The lock is on!')
            
			% Set idFaculty
			self.idFaculty = self.SHOCK;
            
            % Set folder behavior
            self.packageAddress = self.folder_shock;
            
            % Set executor
            self.nameExecutor = Information.NATURE;
            
            % Nature of decision vars
            self.decisionVars = self.getInfoDecVars(self.idFaculty);
            
            self.lock = true;
        end
        
        
        function setFacultyPenalty(self)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(self.lock == false, ...
            'The lock is on!')
            
			% Set idFaculty
			self.idFaculty = self.PENALTY;
            
            % Set folder behavior
            self.packageAddress = self.folder_penalty;
            
            % Set executor
            self.nameExecutor = Information.COURT;
            
            % Nature of decision vars
            self.decisionVars = self.getInfoDecVars(self.idFaculty);
            
            self.lock = true;
        end
        
        
        function selectStrategy(self, idStrat)
        %{
        * Selects a strategy object
            
            Input
                idStrat: [string] Strategy identifier
            Output
                None
        %}
            
            if nargin < 2
                % When no id is provided
                if ~isempty(self.customStratList)
                    % Selects random object from custom strategy list
                    num = length(self.customStratList);
                    randomIndex = randi(num);
                    self.selectedStrategy = self.customStratList{randomIndex};
                else
                    % Selects random object from automatic strategy list
                    num = length(self.autoStratList);
                    randomIndex = randi(num);
                    self.selectedStrategy = self.autoStratList{randomIndex};
                end
            else
                % When id is provided: Selects from custom strategy list
                strat = returnStrategyByIndex(self.customStratList, idStrat);
                self.selectedStrategy = strat;
            end
        end
        
        
        function strat = getSelectedStrategy(self)
        %{
        * Retuns copy of selected strategy
            
            Input
                
            Output
                
        %}
            
            strat = copy(self.selectedStrategy);
            
        end
        
        
    end
end


%% ::::::::::::::::::    Auxiliary functions    :::::::::::::::::::
% *****************************************************************

function C = getCoverageMatrix(decVars, ruleList)
%{
* 
    Input

    Output

%}

numDecRules = length(ruleList);
numDecVars = length(decVars);

C = zeros(numDecVars, numDecRules);

n = length(ruleList);

for i=1:n
    rule = ruleList{i};
    v = rule.getCoverage(decVars); % Returns logical column vector
    C(:,i) = v;
end

end


function sols = getCombinations(A)
%{
* 
    Input
        A: [boolean] Coverate matrix of size [numDecVars, numDecRules]

    Output

%}

% Remove combinations 
sumFilas = sum(A,2);
ix = find(sumFilas == 0);
if ~isempty(ix)
    error('There is at least one rule that does not cover any dec var')
    A(ix,:) = [];
end

% Multiplicity of decision variables covered
mdv = sum(A,1);

assert(all(mdv > 0), ...
    'At least one decision variable is not produced by any rule')

[numDecVars, numDecRules] = size(A);

% Matrix X: Possible vectors x
numPossible = 2^(numDecRules);
X = (dec2bin(0:numPossible-1) == '1')';

% Column vector b
b = ones(numDecVars,1);
sols = [];

for i=1:numPossible
    x = X(:,i);
    b_test = A * x;
    if all(b == b_test)
        sols(:,end+1) = x;
    end
end

%TODO Report or warn decision rules that were not part of a solution

end


function strat = returnStrategyByIndex(stratArray, id)
%{
* Returns strategy object whose id matches the id passed as argument
    Input

    Output

%}

strat = [];

for i=1:length(stratArray)
    currentStrat = stratArray{i};
    if strcmp(id, currentStrat.id)
        strat = currentStrat;
        break
    end
end

assert(~isempty(strat), ...
    'There are no strategies that coincide with the index specified')
end