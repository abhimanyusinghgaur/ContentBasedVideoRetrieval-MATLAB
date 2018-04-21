function [ ] = db_createFrameworkStructure()
%createFrameworkStructure Creates the basic framework structure
%   Detailed explanation goes here

%%  Load dbConfig
    dbConfigFile = 'dbConfig.mat';
    
    if exist(dbConfigFile, 'file') ~= 2
        db_generateConfig();
    end
    load(dbConfigFile);

%%  Start Creating Framework Structure
    mkdir(dbFrameworkRootDir);
    mkdir(videoDbDir);
    mkdir(tmpDir);
    mkdir(indexDir);
%   create videoDbRecordFile and write header as 0 => no video has been
%   deleted yet. Header tells the count of deleted videos in file.
    fileID = fopen(videoDbRecordFile, 'w');  fwrite(fileID, 0, headerIntType); fclose(fileID);
%   create videoDbCountFile and write count as 0 => no video inserted yet
    fileID = fopen(videoDbCountFile, 'w');  fwrite(fileID, 0, headerIntType); fclose(fileID);
%   videos will be stored starting naming from 1.
    
%   create all index category directories with index files
    numCategories = length(indexCategories);
    for i = 1 : numCategories
%       create directory for this index category
        thisCategoryDir = strcat(indexDir, indexCategories{i}, pathSeparator);
        mkdir(thisCategoryDir);
%       create index files for this index category
        thisCategoryClasses = eval(strcat(indexCategories{i}, classVariableExtension));
        numClasses = length(thisCategoryClasses);
        for j = 1 : numClasses
            %   create thisClass IndexFile and write header as 0 => no video has been
            %   deleted yet. Header tells the count of deleted videos in file.
            fileID = fopen(strcat(thisCategoryDir, thisCategoryClasses{j}, indexFileExtension), 'w');
            fwrite(fileID, 0, headerIntType);
            fclose(fileID);
        end
    end

end