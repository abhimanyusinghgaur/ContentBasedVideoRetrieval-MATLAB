function [ ] = generateMetadata()
    % clear all workspace variables
    clear;
%%  Miscellaneous variables
    supportedVideoFormats = {'avi', 'mj2', 'mpg', 'wmv', 'asf', 'asx', 'mp4', 'm4v', 'mov'};
    extensionSize = 'char';
    pathSeparator = '/';
    indexFileExtension = '.dat';

%%  DataSize used in index files to write data
    headerIntSize = 'uint32';
    videoNameIntSize = 'uint16';
    indexClassIntSize = videoNameIntSize;
    bytePositionIntSize = headerIntSize;
%   avgVideoSize = 5Mb for 1min video in mp4 format
%   maxIndexFileSize = 4Gb = (((2^32 byte positions in file)/1024 bytes per
%   Kb)/1024 Kb per Mb)/1024 Mb per Gb
%   maxRecordsInVideoDbIndexFile = 186737708 = (2^32)/23 bytes per record
%   maxRecordsInClassIndexFiles = 1073741824 = (2^32)/4 bytes per record

%%  Frameowrk directories and files
    rootDir = strcat('Framework', pathSeparator);
    videoDbDir = strcat(rootDir, 'videoDB', pathSeparator);
    tmpDir = strcat(rootDir, 'tmp', pathSeparator);
    indexDir = strcat(rootDir, 'indexes', pathSeparator);
    videoDbIndexFile = strcat(rootDir, 'db', indexFileExtension);
    videoDbCountFile = strcat(rootDir, 'numRecords', indexFileExtension);

%%  Categories of indexing and Classes in each category
    indexCategories = {'tvChannel', 'sport', 'team', 'player'};
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

%%  Save above variables
    save('metadata.mat');
end