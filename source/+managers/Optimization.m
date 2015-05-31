classdef Optimization
    
    properties (Constant)
        
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        
        % ----------- %
        % Objects
        % ----------- %
        innerOptimization  % [class Optimization]
        
        outerProblem
        innerProblem
        realizationList
        
        
    end
    
    methods
        %% Constructor
        %{
        * Constructor of Optimization class
        
            Input
                pars: [class struct] Contiene todas los nombres y valores
                de los parámetros del problema de optimizacion
            
            Output
                thisOptimization: [class Optimization] Optimization object
                
        %}
        function self = Optimization(programSettings)
            
            
            
            
        end
        
        %% Getter functions
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        %{
        * This is an example of a comment for a method. Searches and 
        returns the cashflows belonging to certain type as defined by the 
        constant of the Agent class
        
            Input
                
            
            Output
                
        %}
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        
        function run(self)
            
        end
        
        function innerRun()
            
        end
        
        %{
        * Sets up the optimization problem using the genetic algorithm
        
            Input
                in1: [class string] 
            
            Output
                pars: [class struct] Problem parameters
                
                problem: [classs struct] Problem structure (ready for the
                optimizer)
        %}
        function problem = problemSetup(self, pars)
            nSim = pars.nSim;
            
            % Equality constraints
            
            
            % Bounds
            
            
            % Inequality constraints
            
            
            % Initial test values
            
            % Options settings
            
            % Defines problem
            
        end
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        %{
        * Returns problem structure of outer genetic algorithm (multi-
        objective)
        
            Input
                
            Output
                
        %}
        function outerProblem = returnOuterProblem(self)
            
            [indicesOuterVars, numOuterVars] = self.getNumberControlledVars(InputData.PRINCIPAL);
            
            % Row vector for lower and upper bounds
            lb = zeros(1, numOuterVars);
            ub = zeros(1, numOuterVars);
            IntCon = [];
            
            
            for i=1:numOuterVars
                k = indicesOuterVars(i);
                
                bounds = self(k).value_bounds;
                lb(i) = bounds(1);
                ub(i) = bounds(2);
                
                % Specify integer variables
                if self(k).isInteger()
                    IntCon(end+1) = i;
                end
                
                
            end
            
            MaxIter = self.returnInputDataObject(InputData.MAX_ITER).value;
            
            options = gaoptimset('Generations', MaxIter, ...
                                 'PlotFcns', @gaplotpareto , ...
                                 'PlotInterval', 10);
            
            outerProblem = struct();
            outerProblem.fitnessfcn = @(x) outerFitnessFunction(x, self);
            outerProblem.nvars = numOuterVars;
            outerProblem.Aineq = [];
            outerProblem.bineq = [];
            outerProblem.Aeq = [];
            outerProblem.beq = [];
            outerProblem.lb = lb;
            outerProblem.ub = ub;
            outerProblem.solver = 'gamultiobj';
            outerProblem.rngstate = [];
            outerProblem.options = options;
            
        end
        
        %{
        * Returns problem structure of inner genetic algorithm (single
        objective)
        
            Input
                
            Output
                
        %}
        function innerProblem = returnInnerProblem(self)
            
            import managers.ItemSetting
            
            [indicesInnerVars , numInnerVars] = self.getNumberControlledVars(ItemSetting.AGENT);
            
            % Row vector for lower and upper bounds
            lb = zeros(1, numInnerVars);
            ub = zeros(1, numInnerVars);
            IntCon = [];
            
            for i=1:numInnerVars
                k = indicesInnerVars(i);
                
                bounds = self(k).value_bounds;
                lb(i) = bounds(1);
                ub(i) = bounds(2);
                
                % Specify integer variables
                if thisInputdata(k).isInteger();
                    IntCon(end+1) = i;
                end
            end
            
            MaxIter = self.returnInputDataObject(ItemSetting.MAX_ITER).value;
            
            options = gaoptimset('Generations', MaxIter);
            
            innerProblem = struct();
            innerProblem.fitnessfcn = @(x) innerFitnessFunction(x, self);
            innerProblem.nvars = numInnerVars;
            innerProblem.Aineq = [];
            innerProblem.Bineq = [];
            innerProblem.Aeq = [];
            innerProblem.Beq = [];
            innerProblem.lb = lb;
            innerProblem.ub = ub;
            innerProblem.nonlcon = [];
            innerProblem.rngstate = [];
            innerProblem.intcon = IntCon;
            innerProblem.solver = 'ga';
            innerProblem.options = options;
            
            
        end
        
        function pop = createOuterPopulation(NVARS, FitnessFcn, options)
            
        end
        
    end
    
end