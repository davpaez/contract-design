% Generate documentation
%
% How to use:
% - Make 'Matlab Model' the current folder
% - Run this script
% - The documentation will be built inside the 'Matlab Model/doc' folder

nameFolderSource = 'source';
nameFolderDoc = 'doc';

if exist(nameFolderDoc,'dir') == 7
    % Removes existing documentation folder
    %rmdir(nameFolderDoc,'s')
end

% 
m2html('mfiles',nameFolderSource, 'htmldir',nameFolderDoc, ...
    'recursive','on', 'global','on', 'template','frame', 'index','menu');