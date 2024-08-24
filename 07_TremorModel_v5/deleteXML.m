function [] = deleteXML(folderPath)



    % Create a pattern to match all .xml files in the specified folder
    filePattern = fullfile(folderPath, '*.xml');
    
    % Get a list of all the .xml files
    xmlFiles = dir(filePattern);
    
    % Loop through each file and delete it
    for k = 1:length(xmlFiles)
        baseFileName = xmlFiles(k).name;
        fullFileName = fullfile(xmlFiles(k).folder, baseFileName);
        delete(fullFileName); % Delete the file
    end



end