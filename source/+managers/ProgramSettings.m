classdef ProgramSettings < matlab.mixin.Copyable
    % Collection of item settings that define an experiment
    
    properties (Constant, Hidden = true)
        
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        writable = false
        settingItems_Number = 0
        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
    
    properties (GetAccess = public, SetAccess = public)
        % ----------- %
        % Attributes
        % ----------- %
        determined
        
        % ----------- %
        % Objects
        % ----------- %
        settingArray        % Cell array of objects of class ItemSettings
                            % -> They can be InputData or Action objects
        
    end
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            if ~isempty(obj.settingArray)
                n = length(obj.settingArray);
                for i=1:n
                    cpObj.settingArray{i} = copy(obj.settingArray{i});
                end
                
            end
        end
        
    end
    
    methods
        %% Constructor
        %{
        * 
            Input
                setArr: [array of ItemSetting]
            Output
                
        %}
        function self = ProgramSettings(setArr)
            
        end
        
        
        %% Getter functions
        function answer = get.determined(thisProgramSetting)
            n = length(thisProgramSetting.settingArray);
            
            answer = true;
            
            for i=1:n
                if ~isempty(thisProgramSetting.settingArray{i})
                    if ~thisProgramSetting.settingArray{i}.determined
                        answer = false;
                        break
                    end
                end
            end
        end
        
        
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        function itemSettingObject = returnItemSetting(self, id)
        %{
        * Returns the ItemSetting object characterized by the id pass as
        argument
        
            Input
                id: [string] Identifier of the ItemSetting object being
                searched.
            
            Output
                itemSettingObject: [class ItemSetting] Found ItemSetting
                object. If no object is found, an error is raised.
        %}
            n = self.getNumberItems();
            
            found = false;
            
            for i = 1:n
                if ~isempty(self.settingArray{i})
                    if strcmp(self.settingArray{i}.identifier, id)
                        found = true;
                        itemSettingObject = self.settingArray{i};
                        break
                    end
                end
            end
            
            if found == false
                error(['No object was found with the identifier "',id , '"' ])
            end
        end
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        
        function lockSettings(self)
            self.writable = false;
            disp('    Problem Settings Write Access: Locked')
        end
        
        function unlockSettings(self)
            self.writable = true;
            disp('    Problem Settings Write Access: Unlocked')
        end
        
        function add(self, item)
            
            import managers.ItemSetting
            
            assert(self.writable, ...
                'The program settings object must be unlocked to be modified.')
            
            % Conditions
            switch item.identifier
                
                case ItemSetting.MAX_PERF
                    assert( item.value > self.returnItemSetting(ItemSetting.NULL_PERF).value, ...
                            'The maximum performance MUST be greater than the Null performance')
                
                case ItemSetting.INITIAL_PERF
                    assert( item.value >= self.returnItemSetting(ItemSetting.NULL_PERF).value && ...
                            item.value <= self.returnItemSetting(ItemSetting.MAX_PERF).value, ...
                            'The initial performance MUST be within the bounds of Null and Max performance')
                
                %{
                %TODO This is no longer necessary. Remove or place within the ContractOffer strategy
      
                case ItemSetting.PERF_THRESH
                    assert( item.value >= thisProgSet.returnItemSetting(ItemSetting.NULL_PERF).value && ...
                            item.value < thisProgSet.returnItemSetting(ItemSetting.MAX_PERF).value, ...
                            'The performance threshold MUST be within the bounds of Null and Max performance')
                %}
                            
                otherwise
                    disp('')
            end
            
            % Addition
            self.settingArray{end+1} = item;
            self.settingItems_Number = self.settingItems_Number + 1;
            
        end
        
        function init_UserInput(self)
            n = self.settingItems_Number;
            
            for i=1:n
                currentObj = self.settingArray{i};
                if isa(currentObj, 'managers.Action')
                    currentObj.setParamsValue_UserInput();
                end
            end
        end
        
        function init_Random(self)
            n = thisProgSet.settingItems_Number;
            
            for i=1:n
                currentObj = self.settingArray{i};
                if isa(currentObj, 'managers.Action')
                    currentObj.setParamsValue_Random();
                end
            end
        end
        
        function promptUserSelectRules(self)
            %TODO
        end
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        %{
        
            Input
                
            Output
                
        %}
        function n = getNumberItems(self)
            n = self.settingItems_Number;
        end
        

    end
    
end