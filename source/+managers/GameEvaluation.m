classdef GameEvaluation < handle
    %GAMEEVALUATION Class responsible for decoding the inputDataArray
    % object into parameter values to construct each realization
    
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
        
        
        function self = GameEvaluation(progSet)
        % It is the responsibility of this class to construct all objects
        % that are passed as argument to each realization constructor.
        % The reason is that these objects are the same for all realization
        % objects.
            
            import managers.ItemSetting
            import dataComponents.*
            
            self.programSettings = copy(progSet);
            
            nrealiz = progSet.returnItemSetting(ItemSetting.NUM_REALIZ);
            self.numRealizations = nrealiz.value;

        end
        
        
        %% Getter functions
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        

        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        

        function runGame(self)
        %{
        
            Input
                
            Output
                
        %}
            
            import managers.Realization
            import utils.*
            
            % Run num_realiz realizations of the game
            r = cell(self.numRealizations, 1);
            n = self.numRealizations;
            
            %parfor_progress(N);
            p = ProgressBar(n);
            
            progSet = self.programSettings;
            tic
            parfor i=1:n
                r{i} = Realization(progSet);
                r{i}.run()
                %parfor_progress;
                p.progress();
                 
            end
            %parfor_progress(0);
            p.stop();
            
            self.realizations = r;
            toc
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        function data = report(self)
        %{
        
            Input
                
            Output
                
        %}
            
            if length(self.realizations) > 1
                data = self.reportDispersion();
            else
                data = self.reportRealization();
            end
        end
        
        
        function data = reportRealization(self)
        %{
        
            Input
                
            Output
                
        %}
            data = self.realizations.report();
        end
        
        
        function data = reportDispersion(self)
        %{
        
            Input
                
            Output
                
        %}
            n = self.numRealizations;
            ua = zeros(n, 1);
            up = zeros(n, 1);
            
            for i = 1:n
                [ua(i) up(i)] = self.realizations{i}.utilityPlayers();
            end
            
            data = struct('ua', ua, ...
                'up', up );
                
        end
        
    end
    
end