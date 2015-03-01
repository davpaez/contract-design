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
        utility             % Utilities vector for all realization of thisGameEvaluation
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
        
        %{
        
            Input
                
            Output
                
        %}
        function runGame(thisGame)
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
        
        function data = report(thisGame, hFigure)
        %{
        
            Input
                
            Output
                
        %}
            if length(thisGame.realizations) > 1
                data = thisGame.reportDispersion(hFigure);
            else
                data = thisGame.reportRealization(hFigure);
            end
        end
        
        
        function data = reportRealization(thisGame, hFigure)
        %{
        
            Input
                
            Output
                
        %}
            data = thisGame.realizations.report();
        end
        
        
        function reportDispersion(thisGame)
        %{
        
            Input
                
            Output
                
        %}
            thisGame.plotPathDispersion();
            thisGame.plotUtilityDispersion();
        end
        
        function plotUtilityDispersion(thisGame)
        %{
        
            Input
                
            Output
                
        %}
            numRlz = thisGame.numRealizations;
            
            ua = zeros(numRlz, 1);
            up = zeros(numRlz, 1);
            
            for i=1:numRlz
                utilVector = thisGame.realizations{i}.utilityPlayers();
                ua(i) = utilVector(1);
                up(i) = utilVector(2);
            end
            
            scatter(ua, up)
        end
        
        function plotPathDispersion(thisGame)
        %{
        
            Input
                
            Output
                
        %}
            rlzArray = thisGame.realizations;

            n_rlz = length(rlzArray);

            maxTime = 0;
            for i = 1:n_rlz
                st = rlzArray{i}.nature.infrastructure.history.getData();
                time{i} = st.time;
                perf{i} = st.value;
                len(i) = length(st.time);
                maxSpace(i) = max(diff(st.time));

                mt = st.time(end);
                if mt > maxTime
                    maxTime = mt;
                end
            end

            numberSections = floor(maxTime/max(maxSpace)); % Minimum number of divisions

            clear st mt i maxSpace

            minPerf = inf;
            interval = maxTime/numberSections;
            for i=1:numberSections
                lb = (interval)*(i-1);
                ub = (interval)*i;

                T(i) = (lb + ub)/2;
                P{i} = [];

                % Mean value for each section of each realization path
                meanPerfVector = zeros(n_rlz,1);
                for j=1:n_rlz
                    timeVector = time{j};
                    perfVector = perf{j};

                    idx = (timeVector>(lb) & timeVector<=ub);
                    clipTime = timeVector(idx);
                    clipPerf = perfVector(idx);
                    realInterv = max(clipTime)-min(clipTime);
                    if realInterv> 0
                        meanPerf = trapz(timeVector(idx),perfVector(idx))/(max(timeVector(idx))-min(timeVector(idx)));
                    else
                        meanPerf = mean(perfVector(idx));
                    end

                    if meanPerf < minPerf
                        minPerf = meanPerf;
                    end

                    meanPerfVector(j) = meanPerf;
                    assert(~isnan(meanPerf))
                end
                P{i} = meanPerfVector;
            end

            perfRange = 100-minPerf;
            nbins = 50;
            perfInterval = perfRange/nbins;
            edges = linspace(minPerf,100,nbins+1);

            sz = numberSections*n_rlz;
            t = zeros(sz,1);
            p = zeros(sz,1);
            cont = 1;
            m = zeros(nbins, numberSections);
            for i=1:numberSections
                for j=1:n_rlz
                    t(cont) = T(i);
                    p(cont) = P{i}(j);
                    cont = cont + 1;
                end

                % 
                frec = histcounts(P{i}, edges);
                prel = ((frec)/n_rlz)';
                assert((sum(prel)-1)<eps*4);
                m(:,i) = prel;
            end
            
            % Plotting figure
            
            figure
            imagesc([interval/2:interval:maxTime],[minPerf+perfInterval/2:perfInterval:100],m)
            h = colorbar;
            h.Label.String = 'Relative frequency';
            set(gca,'YDir','normal')
            xlabel('Time')
            ylabel('Perf')
        end
        
    end
    
end

%% Auxiliar functions

        %{
        
            Input
                
            Output
                
        %}
    function out1 = auxiliarFunction()

    end

