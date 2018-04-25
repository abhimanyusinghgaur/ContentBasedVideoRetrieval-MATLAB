function [ sanity ] = db_isFrameworkStructureSane()
%isFrameworkStructureSane Checks the sanity of basic framework structure
%   Detailed explanation goes here

%%  Set initial output vars
    sanity = true;

%%  Load dbConfig
    dbConfigFile = db_getDbConfigFileURI();

    if exist(dbConfigFile, 'file') ~= 2
        db_generateConfig();
    end
    load(dbConfigFile);

%%  Start sanity check
    if exist(dbFrameworkRootDir, 'dir') ~= 7
        sanity = false; return;
    end    
    if exist(videoDbDir, 'dir') ~= 7
        sanity = false; return;
    end
    if exist(tmpDir, 'dir') ~= 7
        sanity = false; return;
    end
    if exist(indexDir, 'dir') ~= 7
        sanity = false; return;
    end
    if exist(videoDbRecordFile, 'file') ~= 2
        sanity = false; return;
    end
    if exist(videoDbCountFile, 'file') ~= 2
        sanity = false; return;
    end

%   check existence for all index category directories with index files
    numCategories = length(indexCategories);
    for i = 1 : numCategories
%       check directory existence for this index category
        thisCategoryDir = strcat(indexDir, indexCategories{i}, pathSeparator);
        if exist(thisCategoryDir, 'dir') ~= 7
            sanity = false; return;
        end
%       check existence for index files for this index category
        thisCategoryClasses = eval(strcat(indexCategories{i}, classVariableExtension));
        numClasses = length(thisCategoryClasses);
        for j = 1 : numClasses
            if exist(strcat(thisCategoryDir, thisCategoryClasses{j}, indexFileExtension), 'file') ~= 2
                sanity = false; return;
            end
        end
    end

end