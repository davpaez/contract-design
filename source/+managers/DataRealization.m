classdef DataRealization < handle
    % 
    
    properties
        keywords
        descriptions
        values
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = DataRealization()
        %{
        * 
            Input
                
            Output
                
        %}
            self.keywords = cell(0,1);
            self.descriptions = cell(0,1);
            self.values = cell(0,1);
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function addEntry(self, kw, desc, val)
        %{
        * 
            Input
                
            Output
                
        %}
            self.keywords{end+1} = kw;
            self.descriptions{end+1} = desc;
            self.values{end+1} = val;
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function desc = getDescription(self, kw)
        %{
        * 
            Input
                
            Output
                
        %}
            desc = [];
            for i=1:numel(self.keywords)
                if strcmp(self.keywords{i}, kw)
                    desc = self.descriptions{i};
                    break
                end
            end
        end
        
        
        function val = getValue(self, kw)
        %{
        * 
            Input
                
            Output
                
        %}
            val = [];
            for i=1:numel(self.keywords)
                if strcmp(self.keywords{i}, kw)
                    val = self.values{i};
                    break
                end
            end
        end        
        
    end
    
end