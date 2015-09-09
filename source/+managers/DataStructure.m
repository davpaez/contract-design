classdef DataStructure < handle
    % 
    
    properties
        keywords
        descriptions
        values
        mean
        cov
        source
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = DataStructure()
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
        
        function addSource(self, s)
            assert(length(s) > 1 , 'Source must be a cell array (of DataStructure objects)')
            self.source = s;
        end
        
        function addStatEntry(self, kw)
            s = self.source;
            n = length(s);
            
            v = zeros(n,1);
            
            for i=1:n
                v(i) = s{i}.getValue(kw);
            end
            
            m = mean(v); %#ok<*CPROP>
            
            self.keywords{end+1} = kw;
            self.descriptions{end+1} = s{i}.getDescription(kw);
            self.values{end+1} = v;
            self.mean(end+1) = m;
            self.cov(end+1) = abs(std(v)/m);
            
        end
        
        function addEntry(self, kw, desc, val)
        %{
        * 
            Input
                kw: Keyword
                desc: Description
                val: Value
            
            Output
                
        %}
            self.keywords{end+1} = kw;
            self.descriptions{end+1} = desc;
            self.values{end+1} = val;
            self.mean(end+1) = nan;
            self.cov(end+1) = nan;
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
        
        function st = getEntry(self, kw)
        %{
        * 
            Input
                
            Output
                
        %}
            index = [];
            for i=1:numel(self.keywords)
                if strcmp(self.keywords{i}, kw)
                    index = i;
                    break
                end
            end
            
            if isempty(index)
                st = [];
            else
                st = struct('keyword', self.keywords{i}, ...
                    'description', self.descriptions{i}, ...
                    'value', self.values{i}, ...
                    'mean', self.mean(i), ...
                    'cov', self.cov(i));
            end
        end
        
    end
    
end