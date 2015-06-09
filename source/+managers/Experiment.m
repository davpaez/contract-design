classdef Experiment < managers.TypedClass
    % 
    
    properties (Constant, Hidden = true)
        % Types of experiments
        SING = 'SING'   % Single realization of a game
        DISP = 'DISP'   % Many realizations of the same game (same parameters)
        SENS = 'SENS'   % Many realizations of a games where parameters are varied
        OPT = 'OPT'     % Optimization of objective function by changing game parameters
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        typeExp
        
        % ----------- %
        % Objects
        % ----------- %
        gameEvals
        programSettings
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Experiment(progSet)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.*
            import dataComponents.*
            
            listTypes = {  Experiment.SING, ...
                Experiment.DISP, ...
                Experiment.SENS, ...
                Experiment.OPT};
            
            self@managers.TypedClass(listTypes);
            
            disp('Creating Experiment object:')
            
            tp = progSet.returnItemSetting(ItemSetting.TYPE_EXP).value;
            assert(self.isValidType(tp), ...
                'The type entered as argument is not valid');
            
            self.programSettings = progSet;
            
            % Type of experiment
            self.typeExp = tp;
            
            % Call customized constructors
            switch tp
                case Experiment.SING
                    self.single();
                
                case Experiment.DISP
                    self.dispersion();
                
                case Experiment.SENS
                    self.sensitivity();
                    
                case Experiment.OPT
                    self.optimization();
            end
        end
        
        
        function single(self)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.*
            
            self.gameEvals = GameEvaluation(self.programSettings);
            disp('    Game evaluation object created')
        end
        
        
        function dispersion(self)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.*
            
            self.gameEvals = GameEvaluation(self.programSettings);
            disp('    Game evaluation object created')
        end
        
        
        function sensitivity(self)
        %{
        * 
            Input
                
            Output
                
        %}
            
        end
        
        
        function optimization(self)
        %{
        * 
            Input
                
            Output
                
        %}
            
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function run(self)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.*
            
            % Load experiment's file info
            fi = self.programSettings.returnItemSetting(ItemSetting.FILE_INFO);
            fi.createOutputFolder();
            
            % Open log file (if necessary)
            fi.openLogFile();
            
            % Type of experiment
            tp = self.typeExp;
            
            switch tp
                case Experiment.SING
                    self.runSingle();
                
                case Experiment.DISP
                    self.runDispersion();
                
                case Experiment.SENS
                    self.runSensitivity();
                    
                case Experiment.OPT
                    self.runOptimization();
            end
            
            % Close log file (if necessary)
            fi.closeLogFile();
            
            fi.showLogFile();
        end
        
        
        function data = report(self)
            import managers.*
            
            % Type of experiment
            tp = self.typeExp;
            
            switch tp
                case Experiment.SING
                    data = self.reportSingle();
                
                case Experiment.DISP
                    data = self.reportDispersion();
                
                case Experiment.SENS
                    self.reportSensitivity();
                    
                case Experiment.OPT
                    self.reportOptimization();
            end
        end
        
        
        function runSingle(self)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.*
            import dataComponents.*
            
            prob = Problem(self.programSettings);
            r = Realization(self.programSettings, prob);
            r.run()
            
            self.gameEvals = r;
        end
        
        
        function runDispersion(self)
        %{
        * 
            Input
                
            Output
                
        %}
            self.gameEvals.runGame();
        end
        
        
        function runSensitivity(self)
        %{
        * 
            Input
                
            Output
                
        %}
            
        end
        
        
        function runOptimization(self)
        %{
        * 
            Input
                
            Output
                
        %}
            
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function data = reportSingle(self)
        %{
        * 
            Input
                
            Output
                
        %}
            data = self.gameEvals.report();
        end
        
        
        function data = reportDispersion(self)
        %{
        * 
            Input
                
            Output
                
        %}
            data = self.gameEvals.report();
        end
        
        
        function reportSensitivity(self)
        %{
        * 
            Input
                
            Output
                
        %}
            
        end
        
        
        function reportOptimization(self)
        %{
        * 
            Input
                
            Output
                
        %}
            
        end
        
        
    end
end