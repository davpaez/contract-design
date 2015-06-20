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
        problem         %[class Problem] It is common for all realizations
        
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
            
            self.problem = Problem(self.programSettings);

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
            %p = ProgressBar(n);
            
            progSet = self.programSettings;
            prob = self.problem;
            
            parfor i=1:n
                currentRealz = Realization(progSet, prob);
                currentRealz.run();
                r{i} = currentRealz;
                %parfor_progress;
                %p.progress();
                 
            end
            %parfor_progress(0);
            %p.stop();
            
            self.realizations = r;
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
            data = self.realizations{1}.report();
        end
        
        
        function data = reportDispersion(self)
        %{
        
            Input
                
            Output
                
        %}
            n = self.numRealizations;
            
            data = cell(n,1);
            
            for i = 1:n
                data{i} = self.realizations{i}.report();
            end
                
        end
        
    end
    
end