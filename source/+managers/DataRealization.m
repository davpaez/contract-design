classdef DataRealization < handle
    
    properties
        keywords
        descriptions
        values
    end
    
    methods
        
        function self = DataRealization()
            self.keywords = cell(0,1);
            self.descriptions = cell(0,1);
            self.values = cell(0,1);
        end
        
        function addEntry(self, kw, desc, val)
            self.keywords{end+1} = kw;
            self.descriptions{end+1} = desc;
            self.values{end+1} = val;
        end
        
        function desc = getDescription(self, kw)
            desc = [];
            for i=1:numel(self.keywords)
                if strcmp(self.keywords{i}, kw)
                    desc = self.descriptions{i};
                    break
                end
            end
        end
        
        function val = getValue(self, kw)
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

