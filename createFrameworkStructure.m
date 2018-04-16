function [ ] = createFrameworkStructure()
%createFrameworkStructure Creates the basic framework structure
%   Detailed explanation goes here
    metadataFile = 'metadata.mat';
    
    if exist(metadataFile, 'file') ~= 2
        generateMetadata();
    end
%   load metadata
    load(metadataFile);
    
    mkdir(videoDbDir);
    mkdir(tmpDir);
    mkdir(indexDir);
%   create videoDbIndexFile and write header as 0 => no video has been
%   deleted yet. Header tells the count of deleted videos in file.
    fileID = fopen(videoDbIndexFile, 'w');  fwrite(fileID, 0, headerIntSize); fclose(fileID);
%   create videoDbCountFile and write count as 0 => no video inserted yet
    fileID = fopen(videoDbCountFile, 'w');  fwrite(fileID, 0, headerIntSize); fclose(fileID);
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
            fileID = fopen(strcat(thisCategoryDir, thisCategoryClasses{j}, indexFileExtension), 'w');
            %   create thisClass IndexFile and write header as 0 => no video has been
            %   deleted yet. Header tells the count of deleted videos in file.
            fwrite(fileID, 0, headerIntSize);
            fclose(fileID);
        end
    end

end