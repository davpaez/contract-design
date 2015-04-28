classdef FileInfo < managers.ItemSetting
    % 
    
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
        function thisFileInfo = FileInfo()
        
            % Close all open files
            fclose('all');
        end
        
        
        function createOutputFolder(thisFileInfo)
            nameOutputFolder = 'output';
            
            pathOutputFolder = fullfile(thisFileInfo.expFolder_path, nameOutputFolder);
            
            if exist(pathOutputFolder,'dir') == 0
                mkdir(pathOutputFolder);
            end
            thisFileInfo.outputFolder_path = pathOutputFolder;
        end
        
        function openLogFile(thisFileInfo)
            if thisFileInfo.logStatus == true
                dt = strrep(datestr(clock), ':', '');
                nlf = [thisFileInfo.nameLogFile,' ', dt,'.txt'];
                fullPathLogfile = fullfile(thisFileInfo.outputFolder_path, nlf);
                thisFileInfo.fid = fopen(fullPathLogfile, 'w');
                thisFileInfo.outputFile_path = fullPathLogfile;
            end
        end
        
        function closeLogFile(thisFileInfo)
            if thisFileInfo.logStatus == true
                fclose(thisFileInfo.fid);
            end
        end
        
        function showLogFile(thisFileInfo)
            if thisFileInfo.logStatus == true
                winopen(thisFileInfo.outputFile_path);
            end
        end
        
        function printLog(thisFileInfo, line)
            if thisFileInfo.logStatus == true
                fprintf(thisFileInfo.fid, line);
            end
        end
        
    end
    
end

