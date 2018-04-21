function [ ] = db_generateConfig()
%DB_GENERATECONFIG Generates a configuration file for DB Framework

    clear; % clear all workspace variables
    dbConfigFilename = 'dbConfig.mat';

%%  Miscellaneous variables
    supportedVideoFormats = {'avi', 'mj2', 'mpg', 'wmv', 'asf', 'asx', 'mp4', 'm4v', 'mov'};
    maxExtensionChars = 3;
    pathSeparator = '/';
    indexFileExtension = '.dat';

%%  DataType used in index files to write data
    headerIntType = 'uint32';
    videoNameIntType = 'uint16';
    extensionType = 'char*1';
    indexClassIntType = videoNameIntType;
    bytePositionIntType = headerIntType;
%   avgVideoSize = 5Mb for 1min video in mp4 format
%   maxIndexFileSize = 4Gb = (((2^32 byte positions in file)/1024 bytes per
%   Kb)/1024 Kb per Mb)/1024 Mb per Gb
%   maxRecordsInVideoDbIndexFile = 186737708 = (2^32)/23 bytes per record
%   maxRecordsInClassIndexFiles = 1073741824 = (2^32)/4 bytes per record

%%  DB Frameowrk directories and files
    dbFrameworkRootDir = strcat('dbFramework', pathSeparator);
    videoDbDir = strcat(dbFrameworkRootDir, 'videoDB', pathSeparator);
    tmpDir = strcat(dbFrameworkRootDir, 'tmp', pathSeparator);
    indexDir = strcat(dbFrameworkRootDir, 'indexes', pathSeparator);
    videoDbRecordFile = strcat(dbFrameworkRootDir, 'dbRecords', indexFileExtension);
    videoDbCountFile = strcat(dbFrameworkRootDir, 'dbRecordsCount', indexFileExtension);

%%  Categories of indexing and Classes in each category
    indexCategories = {'tvChannel', 'sport', 'team', 'player'};
    videoDbRecordByteSize = sizeof(videoNameIntType) + maxExtensionChars + length(indexCategories)*(sizeof(indexClassIntType) + sizeof(bytePositionIntType));
    classVariableExtension = 'Classes';
    % name class variables for an indexCategory as:
    % strcat(indexCategory{i}, classVariableExtension)
    % Eg: sportClasses, teamClasses as written below

    % Remove spaces from class names before indexing next time
    tvChannelClasses    = {'DD Sports', 'ESPN', 'Sony Six Old', 'Star Sports New', 'Ten Sports'};
    % classLabels       = [      1    ,    2  ,        3      ,          4       ,       5     ];
    expectedLogoCorners = [      2,        2,          2,                2,              2     ];

    sportClasses        = {'cricket', 'football'};
    % classLabels       = [      1  ,      2    ];

    teamClasses         = {};

    playerClasses       = {};

%%  Save above variables in configuration file
    save(dbConfigFilename);

end