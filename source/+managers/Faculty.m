classdef Faculty < managers.ItemSetting
    % 
    
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
        
        strategyList
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
                    decVars = {Information.CONTRACT_DURATION ; ...
                Information.PERFORMANCE_THRESHOLD ;
                Information.PAYMENT_SCHEDULE; ...
                Information.REVENUE_RATE_FUNC};
                    
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
        
        
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function thisFaculty = Faculty(type)
        %{
        
            Input
                
            Output
                
        %}
            
            switch type
                case thisFaculty.CONTRACT_OFFER
                    thisFaculty.setFacultyContractOffer();
                    
                case thisFaculty.INSPECTION
                    thisFaculty.setFacultyInspection();
                    
                case thisFaculty.VOL_MAINT
                    thisFaculty.setFacultyVolMaint();
                    
                case thisFaculty.MAND_MAINT
                    thisFaculty.setFacultyMandMaint();
                    
                case thisFaculty.SHOCK
                    thisFaculty.setFacultyShock();
                    
                case thisFaculty.PENALTY
                    thisFaculty.setFacultyPenalty();
                    
                otherwise
                    error('Type is not valid')
            end
            
            thisFaculty.getDecisionRuleAndCustomStratList();
            thisFaculty.createStrategies();
            
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function getDecisionRuleAndCustomStratList(thisFaculty)
        %{
        
            Input
                
            Output
                
        %}
            
            % Search for all DecisionRule classes of this type of faculty
            % and create a list containing one object for each of these
            % classes.
            
            spl = strsplit(thisFaculty.packageAddress,'.');
            
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
                listRules{i} = feval([thisFaculty.packageAddress,'.',className]);
            end
            
            %TODONEXT
            
            for i = 1:numStrats
                stratName = queryStrats(i).name;
                className = strrep(stratName, '.m', '');
                listStrats{i} = feval([thisFaculty.packageAddress,'.',className]);
            end
            
            thisFaculty.decisionRuleList = listRules;
            thisFaculty.customStratList = listStrats;
        end
        
        
        function strategies = createStrategies(thisFaculty)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Strategy
            
            coverageMatrix = getCoverageMatrix(...
                thisFaculty.decisionVars, ...
                thisFaculty.decisionRuleList);
            
            % Returns cell with rule arrays
            vectors = getCombinations(coverageMatrix);
            ruleCombinations = thisFaculty.getRuleCombinations(vectors);
            
            n = length(ruleCombinations);
            strategies = cell(n,1);
            for i=1:n
                s = Strategy(thisFaculty.decisionVars);
                s.setDecisionRuleList(ruleCombinations{i});
                strategies{i} = s;
            end
            
            thisFaculty.strategyList = strategies;
        end
        
        
        function combinationArray = getRuleCombinations(thisFaculty, vectors)
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
                        ruleArray{end+1,1} = copy(thisFaculty.decisionRuleList{j});
                    end
                end

                combinationArray{end+1,1} = ruleArray;
            end
        end
        
        
        function setFacultyContractOffer(thisFaculty)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(thisFaculty.lock == false, ...
            'The lock is on!')
            
			% Set idFaculty
			thisFaculty.idFaculty = thisFaculty.CONTRACT_OFFER;
            
            % Set folder behavior
            thisFaculty.packageAddress = thisFaculty.folder_contractOffer;
            
            % Set executor
            thisFaculty.nameExecutor = Information.PRINCIPAL;
            
            % Nature of decision vars
            thisFaculty.decisionVars = thisFaculty.getInfoDecVars(thisFaculty.idFaculty);
            
            thisFaculty.lock = true;
        end
        
        
        function setFacultyInspection(thisFaculty)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(thisFaculty.lock == false, ...
            'The lock is on!')
            
			% Set idFaculty
			thisFaculty.idFaculty = thisFaculty.INSPECTION;
            
            % Set folder behavior
            thisFaculty.packageAddress = thisFaculty.folder_inspection;
            
            % Set executor
            thisFaculty.nameExecutor = Information.PRINCIPAL;
            
            % Nature of decision vars
            thisFaculty.decisionVars = thisFaculty.getInfoDecVars(thisFaculty.idFaculty);
            
            thisFaculty.lock = true;
        end
        
        
        function setFacultyVolMaint(thisFaculty)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(thisFaculty.lock == false, ...
            'The lock is on!')
            
			% Set idFaculty
			thisFaculty.idFaculty = thisFaculty.VOL_MAINT;
            
            % Set folder behavior
            thisFaculty.packageAddress = thisFaculty.folder_volMaint;
            
            % Set executor
            thisFaculty.nameExecutor = Information.AGENT;
            
            % Nature of decision vars
            thisFaculty.decisionVars = thisFaculty.getInfoDecVars(thisFaculty.idFaculty);
            
            thisFaculty.lock = true;
        end
        
        
        function setFacultyMandMaint(thisFaculty)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(thisFaculty.lock == false, ...
            'The lock is on!')
        
			% Set idFaculty
			thisFaculty.idFaculty = thisFaculty.MAND_MAINT;
            
            % Set folder behavior
            thisFaculty.packageAddress = thisFaculty.folder_mandMaint;
            
            % Set executor
            thisFaculty.nameExecutor = Information.AGENT;
            
            % Nature of decision vars
            thisFaculty.decisionVars = thisFaculty.getInfoDecVars(thisFaculty.idFaculty);
            
            thisFaculty.lock = true;
        end
        
        
        function setFacultyShock(thisFaculty)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(thisFaculty.lock == false, ...
            'The lock is on!')
            
			% Set idFaculty
			thisFaculty.idFaculty = thisFaculty.SHOCK;
            
            % Set folder behavior
            thisFaculty.packageAddress = thisFaculty.folder_shock;
            
            % Set executor
            thisFaculty.nameExecutor = Information.NATURE;
            
            % Nature of decision vars
            thisFaculty.decisionVars = thisFaculty.getInfoDecVars(thisFaculty.idFaculty);
            
            thisFaculty.lock = true;
        end
        
        
        function setFacultyPenalty(thisFaculty)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            assert(thisFaculty.lock == false, ...
            'The lock is on!')
            
			% Set idFaculty
			thisFaculty.idFaculty = thisFaculty.PENALTY;
            
            % Set folder behavior
            thisFaculty.packageAddress = thisFaculty.folder_penalty;
            
            % Set executor
            thisFaculty.nameExecutor = Information.COURT;
            
            % Nature of decision vars
            thisFaculty.decisionVars = thisFaculty.getInfoDecVars(thisFaculty.idFaculty);
            
            thisFaculty.lock = true;
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

C = zeros(numDecRules, numDecVars);

n = length(ruleList);

for i=1:n
    rule = ruleList{i};
    v = rule.getCoverage(decVars); % Returns logical column vector
    C(:,i) = v;
end

end


function sols = getCombinations(C)
%{
* 
    Input

    Output

%}

% Remove combinations 
sumFilas = sum(C,2);
ix = find(sumFilas == 0);
if ~isempty(ix)
    error('There is at least one rule that does not cover any dec var')
    C(ix,:) = [];
end

% Multiplicity of decision variables covered
mdv = sum(C,1);

assert(all(mdv > 0), ...
    'At least one decision variable is not produced by any rule')

[numDecRules, numDecVars] = size(C);

% Matriz A is transpose of matrix C
A = C';

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

