classdef ProgramSettings < matlab.mixin.Copyable
    
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
        function thisProgramSettings = ProgramSettings(setArr)
            
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
        
        
        function itemSettingObject = returnItemSetting(thisProgramSetting, id)
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
            n = thisProgramSetting.getNumberItems();
            
            found = false;
            
            for i = 1:n
                if ~isempty(thisProgramSetting.settingArray{i})
                    if strcmp(thisProgramSetting.settingArray{i}.identifier, id)
                        found = true;
                        itemSettingObject = thisProgramSetting.settingArray{i};
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
        
        function lockSettings(thisProgSet)
            thisProgSet.writable = false;
            disp('    Problem Settings Write Access: Locked')
        end
        
        function unlockSettings(thisProgSet)
            thisProgSet.writable = true;
            disp('    Problem Settings Write Access: Unlocked')
        end
        
        function add(thisProgSet, item)
            
            import managers.ItemSetting
            
            assert(thisProgSet.writable, ...
                'The program settings object must be unlocked to be modified.')
            
            % Conditions
            switch item.identifier
                
                case ItemSetting.MAX_PERF
                    assert( item.value > thisProgSet.returnItemSetting(ItemSetting.NULL_PERF).value, ...
                            'The maximum performance MUST be greater than the Null performance')
                
                case ItemSetting.INITIAL_PERF
                    assert( item.value >= thisProgSet.returnItemSetting(ItemSetting.NULL_PERF).value && ...
                            item.value <= thisProgSet.returnItemSetting(ItemSetting.MAX_PERF).value, ...
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
            thisProgSet.settingArray{end+1} = item;
            thisProgSet.settingItems_Number = thisProgSet.settingItems_Number + 1;
            
        end
        
        function init_UserInput(thisProgSet)
            n = thisProgSet.settingItems_Number;
            
            for i=1:n
                currentObj = thisProgSet.settingArray{i};
                if isa(currentObj, 'managers.Action')
                    currentObj.setParamsValue_UserInput();
                end
            end
        end
        
        function init_Random(thisProgramSetting)
            n = thisProgSet.settingItems_Number;
            
            for i=1:n
                currentObj = thisProgramSetting.settingArray{i};
                if isa(currentObj, 'managers.Action')
                    currentObj.setParamsValue_Random();
                end
            end
        end
        
        function promptUserSelectRules(thisProgSet)
            %TODO
        end
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        %{
        
            Input
                
            Output
                
        %}
        function n = getNumberItems(thisProgSet)
            n = thisProgSet.settingItems_Number;
        end
        

    end
    
end