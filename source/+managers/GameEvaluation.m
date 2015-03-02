classdef GameEvaluation < handle
    %GAMEEVALUATION Class responsible for decoding the inputDataArray
    % object into parameter values to construct each realization
    %   Detailed explanation goes here
    
    properties (Constant)
        
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        numRealizations
        
        % ----------- %
        % Objects
        % ----------- %
        programSettings
        realizations
        
    end
    
    methods
        %% Constructor
        
        
        function thisGame = GameEvaluation(progSet)
        % It is the responsibility of this class to construct all objects
        % that are passed as argument to each realization constructor.
        % The reason is that these objects are the same for all realization
        % objects.
            
            import managers.ItemSetting
            import dataComponents.*
            
            thisGame.programSettings = copy(progSet);
            
            nrealiz = progSet.returnItemSetting(ItemSetting.NUM_REALIZ);
            thisGame.numRealizations = nrealiz.value;

        end
        
        
        %% Getter functions
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        

        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        

        function runGame(thisGame)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Realization
            import utils.*
            
            % Run num_realiz realizations of the game
            r = cell(thisGame.numRealizations, 1);
            n = thisGame.numRealizations;
            
            %parfor_progress(N);
            p = ProgressBar(n);
            
            progSet = thisGame.programSettings;
            tic
            parfor i=1:n
                r{i} = Realization(progSet);
                r{i}.run()
                %parfor_progress;
                p.progress();
                 
            end
            %parfor_progress(0);
            p.stop();
            
            thisGame.realizations = r;
            toc
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        function data = report(thisGame)
        %{
        
            Input
                
            Output
                
        %}
            
            if length(thisGame.realizations) > 1
                data = thisGame.reportDispersion();
            else
                data = thisGame.reportRealization();
            end
        end
        
        
        function data = reportRealization(thisGame)
        %{
        
            Input
                
            Output
                
        %}
            data = thisGame.realizations.report();
        end
        
        
        function data = reportDispersion(thisGame)
        %{
        
            Input
                
            Output
                
        %}
            n = thisGame.numRealizations;
            ua = zeros(n, 1);
            up = zeros(n, 1);
            
            for i = 1:n
                [ua(i) up(i)] = thisGame.realizations{i}.utilityPlayers();
            end
            
            data = struct('ua', ua, ...
                'up', up );
                
        end
        
    end
    
end