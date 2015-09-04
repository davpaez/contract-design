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
            import managers.DataStructure
            
            data = DataStructure();
            
            n = self.numRealizations;
            
            dataRealization = cell(n,1);
            realz = self.realizations;
            
            parfor i = 1:n
                r = realz{i};
                d = r.report();
                dataRealization{i} = d;
            end
            
            ua_vector = zeros(n,1);
            ppmv_vector = zeros(n,1);
            balp_vector = zeros(n,1);
            up_vector = zeros(n,1);
            for i=1:n
                ua_vector(i) = dataRealization{i}.getValue('ua');
                ppmv_vector(i) = dataRealization{i}.getValue('perceivedPerfMeanValue').meanvalue(end);
                balp_vector(i) = dataRealization{i}.getValue('balP').balance(end);
                up_vector(i) = dataRealization{i}.getValue('up');
            end
            
            ua_mean = mean(ua_vector);
            ua_cov = abs(std(ua_vector)/ua_mean);
            ppmv_mean = mean(ppmv_vector);
            balp_mean = mean(balp_vector);
            up_mean = mean(up_vector);
            up_cov = abs(std(up_vector)/up_mean);
            
            data.addEntry('ua_vector', 'Vector agent utility', ua_vector);
            data.addEntry('up_vector', 'Vector principal utility', up_vector);
            data.addEntry('ua_mean', 'Mean agent utility', ua_mean);
            data.addEntry('up_mean', 'Mean principal utility', up_mean);
            data.addEntry('ua_cov', 'COV agent utility', ua_cov);
            data.addEntry('up_cov', 'COV principal utility', up_cov);
            data.addEntry('ppmv', 'Perceived performance mean value', ppmv_mean);
            data.addEntry('balp_mean', 'Mean principal balance', balp_mean);
            data.addEntry('data_rlz', 'Data realizations', dataRealization);
        end
        
    end
    
end