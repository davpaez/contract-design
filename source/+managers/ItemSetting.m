classdef ItemSetting < matlab.mixin.Copyable
    
    properties (Constant, Hidden = true)
        % Type of problem setting
        VALUE_PARAM     = 'VALUE_PARAM'
        PLAYER_ACTION   = 'PLAYER_ACTION'
        
        % Associated with 'type' attribute
        GIVEN           = 'GIVEN'       % Set by the user of program
        CONTROLLED      = 'CONTROLLED'  % Or controlled by some player
        
        % Controller / Executors
        PRINCIPAL       = 'PRINCIPAL'
        AGENT           = 'AGENT'
        NATURE          = 'NATURE'
        
        
        %  ------------------- IDENTIFIERS -------------------------
        
        % Management
        FILE_INFO    = 'FILE_INFO'  % 
        
        % Problem
        TYPE_EXP        = 'TYPE_EXP'    % Type of experiment
        TIME_RES        = 'TIME_RES'    % Time resolution
        DISC_RATE       = 'DISC_RATE'   % Annual discount rate
        DEMAND_FNC      = 'DEMAND_FNC'  % How users demand respond to Perf and time
        
        % Optimization
        NUM_REALIZ      = 'NUM_REALIZ'  % Number of realizations
        MAX_ITER        = 'MAX_ITER'    % Maximum iterations
        TOL             = 'TOL'         % Tolerance
        
        % Realization
        
        
        % Contract
        INV             = 'INV'         % Initial investment %TODO May be initial agent's balance?
        PEN_POLICY      = 'PEN_POLICY'  % 
        
        % Nature
        NAT_HAZARD      = 'NAT_HAZARD'      % 
        STRATS_SHOCK    = 'STRATS_SHOCK'    % 
        CONT_ENV_FORCE  = 'CONT_ENV_FORCE'  % 
        
        
        % Principal
        STRATS_CONTRACT     = 'STRATS_CONTRACT'     % 
        STRATS_INSP         = 'STRATS_INSP'         % 
        COST_INSP           = 'COST_INSP'           % 
        PRINCIPAL_UTIL_FNC  = 'PRINCIPAL_UTIL_FNC'  % 
        
        % Agent
        PART_CONSTR         = 'PART_CONSTR'         % 
        STRATS_VOL_MAINT    = 'STRATS_VOL_MAINT'    % 
        STRATS_MAND_MAINT   = 'STRATS_MAND_MAINT'   % 
        MAINT_COST_FNC      = 'MAINT_COST_FNC'      % 
        AGENT_UTIL_FNC      = 'AGENT_UTIL_FNC'      % 
        
        % Infrastructure
        MAX_PERF        = 'MAX_PERF'        % 
        NULL_PERF       = 'NULL_PERF'       % 
        INITIAL_PERF    = 'INITIAL_PERF'    % 
        DET_RATE        = 'DET_RATE'        % 
        CONT_RESP_FNC   = 'CONT_RESP_FNC'   % 
        SHOCK_RESP_FNC  = 'SHOCK_RESP_FNC'  % 
        
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        identifier = [];                % [string]
        type                            % [string]
        controller                      % [string]
        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
    
    properties (GetAccess = public, SetAccess = public)
        % ----------- %
        % Attributes
        % ----------- %
        
        
        % ----------- %
        % Objects
        % ----------- %
        
    end
    
    methods
        %% Constructor
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function self = ItemSetting()
            self.type = self.GIVEN;
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
        function setIdentifier(self, ident)
            self.identifier = ident;
        end
        
        %{
        % Sets the type attribute of self to GIVEN. It means
        that 
            Input
                
            Output
                
        %}
        function setAsGiven(self)
            self.type = self.GIVEN;
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function setAsControlled(self, controller)
            self.type = self.CONTROLLED;
            self.controller = controller;
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function setValue_NumberSet(self, setName)
            self.value_NumberSet = setName;
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function clearAllAttributes(self)
            
            % Set all attributes to empty except the identifier
            self.type = [];
            self.controller = [];
            self.degreeFreedom = [];
            
            self.value = [];
            self.value_bounds = [];
            self.value_admitted = [];
            self.value_of = [];
        end

        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function checkValidity(self)
            error('This method has to be defined for those properties of ItemSetting that InputData and Action both share')
            
            % TODO
            % If the itemSetting is GIVEN, it does not need any controller
            % attribute. It should be empty
            
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function answer = isControlled(self, controller)
            if nargin < 2
                no_controller_spec = true;
            else
                no_controller_spec = false;
            end
            
            if no_controller_spec == false
            assert(strcmp(controller, ItemSetting.PRINCIPAL) || ...
                   strcmp(controller, ItemSetting.AGENT), ...
                   'The controller argument is not valid');
            end
            
            if strcmp(self.type, self.CONTROLLED)
                if no_controller_spec == true
                    answer = true;
                else
                    if strcmp(self.controller, controller )
                        answer = true;
                    else
                        answer = false;
                    end
                end
            else
                answer = false;
            end
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function answer = isGiven(self)
            if strcmp(self.type, self.GIVEN)
                answer = true;
            else
                answer = false;
            end
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function [indices, n] = getNumberGivenItems(self)
            count = 0;
            
            for i=1:self.getLength()
                if ~self(i).isEmptyDataObject() && self(i).isGiven()
                    count = count + 1;
                    indices(count) = i;
                end
            end
            n = count;
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function [indices , count] = getNumberControlledItems(self, controller)
            if nargin < 2
                no_controller_spec = true;
            else
                no_controller_spec = false;
            end
            
            assert(strcmp(controller, self.PRINCIPAL) || ...
                   strcmp(controller, self.AGENT), ...
                   'The controller argument is not valid');
            
            indices = [];
            count = 0;
            
            for i=1:self.getLength()
                if no_controller_spec == true
                    logicalTest = ~self(i).isEmptyDataObject() && ...
                        self(i).isControlled();
                else
                    logicalTest = ~self(i).isEmptyDataObject() && ...
                        self(i).isControlled(controller);
                end
                
                if logicalTest
                    count = count + 1;
                    indices(count) = i;
                end
            end
        end
        
    end
    
end

%% Auxiliar functions
