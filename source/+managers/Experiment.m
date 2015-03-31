classdef Experiment < managers.TypedClass
    %EXPERIMENT Summary of this class goes here
    %   Detailed explanation goes here
    
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
        %% Constructor
        
        function thisEx = Experiment(progSet)
            import managers.*
            import dataComponents.*
            
            listTypes = {  Experiment.SING, ...
                Experiment.DISP, ...
                Experiment.SENS, ...
                Experiment.OPT};
            
            thisEx@managers.TypedClass(listTypes);
            
            disp('Creating Experiment object:')
            
            tp = progSet.returnItemSetting(ItemSetting.TYPE_EXP).value;
            assert(thisEx.isValidType(tp), ...
                'The type entered as argument is not valid');
            
            thisEx.programSettings = progSet;
            
            % Type of experiment
            thisEx.typeExp = tp;
            
            % Call customized constructors
            switch tp
                case Experiment.SING
                    thisEx.single();
                
                case Experiment.DISP
                    thisEx.dispersion();
                
                case Experiment.SENS
                    thisEx.sensitivity();
                    
                case Experiment.OPT
                    thisEx.optimization();
            end
        end
        
        
        function single(thisEx)
            import managers.*
            
            thisEx.gameEvals = GameEvaluation(thisEx.programSettings);
            disp('    Game evaluation object created')
        end
        
        
        function dispersion(thisEx)
            import managers.*
            
            thisEx.gameEvals = GameEvaluation(thisEx.programSettings);
            disp('    Game evaluation object created')
        end
        
        
        function sensitivity(thisEx)
        end
        
        
        function optimization(thisEx)
        end
        
        %% General methods
        
        function run(thisEx)
            import managers.*
            
            % Load experiment's file info
            fi = thisEx.programSettings.returnItemSetting(ItemSetting.FILE_INFO);
            fi.createOutputFolder();
            
            % Open log file (if necessary)
            fi.openLogFile();
            
            % Type of experiment
            tp = thisEx.typeExp;
            
            switch tp
                case Experiment.SING
                    thisEx.runSingle();
                
                case Experiment.DISP
                    thisEx.runDispersion();
                
                case Experiment.SENS
                    thisEx.runSensitivity();
                    
                case Experiment.OPT
                    thisEx.runOptimization();
            end
            
            % Close log file (if necessary)
            fi.closeLogFile();
            
            fi.showLogFile();
        end
        
        function data = report(thisEx)
            import managers.*
            
            % Type of experiment
            tp = thisEx.typeExp;
            
            switch tp
                case Experiment.SING
                    data = thisEx.reportSingle();
                
                case Experiment.DISP
                    data = thisEx.reportDispersion();
                
                case Experiment.SENS
                    thisEx.reportSensitivity();
                    
                case Experiment.OPT
                    thisEx.reportOptimization();
            end
        end
        
        %% Runners
        
        function runSingle(thisEx)
            import managers.*
            
            r = Realization(thisEx.programSettings);
            r.run()
            
            thisEx.gameEvals = r;
        end
        
        
        function runDispersion(thisEx)
            
            thisEx.gameEvals.runGame();
        end
        
        
        function runSensitivity(thisEx)
            
        end
        
        
        function runOptimization(thisEx)
            
        end
        
        %% Reporters
        
        function data = reportSingle(thisEx)
            data = thisEx.gameEvals.report();
        end
        
        
        function data = reportDispersion(thisEx)
            data = thisEx.gameEvals.report();
        end
        
        
        function reportSensitivity(thisEx)
            
        end
        
        
        function reportOptimization(thisEx)
            
        end
        
    end
    
end

