classdef FileInfo < managers.ItemSetting
    
    properties (Constant, Hidden = true)
        nameLogFile = 'log'
    end
    
    properties
        fileSettings_name
        expFolder_path
        experiment_name
        outputFolder_path
        outputFile_path
        
        logStatus = true
        
        fid
    end
    
    methods
        function self = FileInfo()
        
            % Close all open files
            fclose('all');
        end
        
        
        function createOutputFolder(self)
            nameOutputFolder = 'output';
            
            pathOutputFolder = fullfile(self.expFolder_path, nameOutputFolder);
            
            if exist(pathOutputFolder,'dir') == 0
                mkdir(pathOutputFolder);
            end
            self.outputFolder_path = pathOutputFolder;
        end
        
        function openLogFile(self)
            if self.logStatus == true
                dt = strrep(datestr(clock), ':', '');
                nlf = [self.nameLogFile,' ', dt,'.txt'];
                fullPathLogfile = fullfile(self.outputFolder_path, nlf);
                self.fid = fopen(fullPathLogfile, 'w');
                self.outputFile_path = fullPathLogfile;
            end
        end
        
        function closeLogFile(self)
            if self.logStatus == true
                fclose(self.fid);
            end
        end
        
        function showLogFile(self)
            if self.logStatus == true
                winopen(self.outputFile_path);
            end
        end
        
        function printLog(self, line)
            if self.logStatus == true
                fprintf(self.fid, line);
            end
        end
        
    end
    
end

