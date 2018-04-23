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
    dbFrameworkRootDir = strcat(pwd, pathSeparator, 'dbFramework', pathSeparator);
    videoDbDir = strcat(dbFrameworkRootDir, 'videoDB', pathSeparator);
    tmpDir = strcat(dbFrameworkRootDir, 'tmp', pathSeparator);
    indexDir = strcat(dbFrameworkRootDir, 'indexes', pathSeparator);
    videoDbRecordFile = strcat(dbFrameworkRootDir, 'dbRecords', indexFileExtension);
    videoDbCountFile = strcat(dbFrameworkRootDir, 'dbRecordsCount', indexFileExtension);

%%  Categories of indexing and Classes in each category
%   If adding a new index category, regenerate all the DB files. i.e.
%   re-insert all the videos, after deleting contents of dbFrameworkRootDir
    indexCategories = {'tvChannel', 'sport', 'team', 'player'};
    videoDbRecordByteSize = sizeof(videoNameIntType) + maxExtensionChars + length(indexCategories)*(sizeof(indexClassIntType) + sizeof(bytePositionIntType));
    classVariableExtension = 'Classes';
    % name class variables for an indexCategory as:
    % strcat(indexCategory{i}, classVariableExtension)
    % Eg: sportClasses, teamClasses as written below

    % Remove spaces from class names before indexing next time
    tvChannelClasses    = {'DD SPORTS', 'ESPN', 'SONY SIX OLD', 'STAR SPORTS NEW', 'TEN SPORTS'};
    % classLabels       = [      1    ,    2  ,        3      ,          4       ,       5     ];
    expectedLogoCorners = [      2,        2,          2,                2,              2     ];

    sportClasses        = {'CRICKET', 'FOOTBALL'};
    % classLabels       = [      1  ,      2    ];

    teamClasses         = {'INDIA', 'PAKISTAN', 'SRI LANKA', 'SOUTH AFRICA', 'ENGLAND', 'FC BARCELONA', 'REAL MADRID', 'ATM FA'};
    % classLabels       = [    1  ,      2    ,       3    ,       4       ,      5   ,         6     ,        7     ,     8   ];

    playerClasses       = {'SACHIN TENDULKAR', 'MS DHONI', 'VIRAT KOHLI', 'DINESH KARTHIK', 'JEHAN MUBARAK', 'RANGANA HERATH', 'RONALDO', 'MESSI', 'CHETESHWAR PUJARA', 'AMIT MISHRA'};
    % classLabels       = [         1        ,      2    ,       3      ,         4       ,        5       ,         6       ,     7    ,    8   ,            9       ,       10     ];

    % name maps as strcat(indexCategory{i}, 'Text_', indexCategory{j}, '_Map')
    keyText_sport_Map   = containers.Map('KeyType', 'char', 'ValueType', indexClassIntType);
    keyText_sport_Map('OVERS') = 1; keyText_sport_Map('INNS') = 1;  keyText_sport_Map('RR')  = 1;
    keyText_sport_Map('FIFTY') = 1; keyText_sport_Map('TEST') = 1;  keyText_sport_Map('MPH') = 1;
    keyText_sport_Map('KPH')   = 1;
    
    teamText_sport_Map  = containers.Map('KeyType', 'char', 'ValueType', 'any');
    teamText_sport_Map('IND') = [1]; teamText_sport_Map('PAK') = [1]; teamText_sport_Map('SL')  = [1];
    teamText_sport_Map('SA')  = [1]; teamText_sport_Map('ENG') = [1]; teamText_sport_Map('FCB') = [2];
    teamText_sport_Map('RMA') = [2]; teamText_sport_Map('ATM') = [2];
    
    teamText_team_Map   = containers.Map('KeyType', 'char', 'ValueType', indexClassIntType);
    teamText_team_Map('IND') = 1;    teamText_team_Map('PAK') = 2;    teamText_team_Map('SL')  = 3;
    teamText_team_Map('SA')  = 4;    teamText_team_Map('ENG') = 5;    teamText_team_Map('FCB') = 6;
    teamText_team_Map('RMA') = 7;    teamText_team_Map('ATM') = 8;
    
    playerText_sport_Map= containers.Map('KeyType', 'char', 'ValueType', indexClassIntType);
    playerText_sport_Map('STENDULKAR') = 1;  playerText_sport_Map('TENDULKAR') = 1;   playerText_sport_Map('SACHINTENDULKAR') = 1;
    playerText_sport_Map('MSD')        = 1;  playerText_sport_Map('DHONI')     = 1;   playerText_sport_Map('MSDHONI')         = 1;
    playerText_sport_Map('VKOHLI')     = 1;  playerText_sport_Map('KOHLI')     = 1;   playerText_sport_Map('VIRATKOHLI')      = 1;
    playerText_sport_Map('DKARTHIK')   = 1;  playerText_sport_Map('KARTHIK')   = 1;   playerText_sport_Map('DINESHKARTHIK')   = 1;
    playerText_sport_Map('JMUBARAK')   = 1;  playerText_sport_Map('MUBARAK')   = 1;   playerText_sport_Map('JEHANMUBARAK')    = 1;
    playerText_sport_Map('RHERATH')    = 1;  playerText_sport_Map('HERATH')    = 1;   playerText_sport_Map('RANGANAHERATH')   = 1;
    playerText_sport_Map('CPUJARA')    = 1;  playerText_sport_Map('PUJARA')    = 1;   playerText_sport_Map('CHETESHWARPUJARA')= 1;
    playerText_sport_Map('AMISHRA')    = 1;  playerText_sport_Map('MISHRA')    = 1;   playerText_sport_Map('AMITMISHRA')      = 1;
    playerText_sport_Map('RONALDO')    = 2;  playerText_sport_Map('MESSI')     = 2;
    
    playerText_team_Map = containers.Map('KeyType', 'char', 'ValueType', indexClassIntType);
    playerText_team_Map('STENDULKAR') = 1;  playerText_team_Map('TENDULKAR') = 1;   playerText_team_Map('SACHINTENDULKAR') = 1;
    playerText_team_Map('MSD')        = 1;  playerText_team_Map('DHONI')     = 1;   playerText_team_Map('MSDHONI')         = 1;
    playerText_team_Map('VKOHLI')     = 1;  playerText_team_Map('KOHLI')     = 1;   playerText_team_Map('VIRATKOHLI')      = 1;
    playerText_team_Map('DKARTHIK')   = 1;  playerText_team_Map('KARTHIK')   = 1;   playerText_team_Map('DINESHKARTHIK')   = 1;
    playerText_team_Map('CPUJARA')    = 1;  playerText_team_Map('PUJARA')    = 1;   playerText_team_Map('CHETESHWARPUJARA')= 1;
    playerText_team_Map('AMISHRA')    = 1;  playerText_team_Map('MISHRA')    = 1;   playerText_team_Map('AMITMISHRA')      = 1;
    playerText_team_Map('JMUBARAK')   = 3;  playerText_team_Map('MUBARAK')   = 3;   playerText_team_Map('JEHANMUBARAK')    = 3;
    playerText_team_Map('RHERATH')    = 3;  playerText_team_Map('HERATH')    = 3;   playerText_team_Map('RANGANAHERATH')   = 3;
    playerText_team_Map('RONALDO')    = 7;  playerText_team_Map('MESSI')     = 6;
    
    playerText_player_Map = containers.Map('KeyType', 'char', 'ValueType', indexClassIntType);
    playerText_player_Map('STENDULKAR') = 1;  playerText_player_Map('TENDULKAR') = 1;   playerText_player_Map('SACHINTENDULKAR') = 1;
    playerText_player_Map('MSD')        = 2;  playerText_player_Map('DHONI')     = 2;   playerText_player_Map('MSDHONI')         = 2;
    playerText_player_Map('VKOHLI')     = 3;  playerText_player_Map('KOHLI')     = 3;   playerText_player_Map('VIRATKOHLI')      = 3;
    playerText_player_Map('DKARTHIK')   = 4;  playerText_player_Map('KARTHIK')   = 4;   playerText_player_Map('DINESHKARTHIK')   = 4;
    playerText_player_Map('JMUBARAK')   = 5;  playerText_player_Map('MUBARAK')   = 5;   playerText_player_Map('JEHANMUBARAK')    = 5;
    playerText_player_Map('RHERATH')    = 6;  playerText_player_Map('HERATH')    = 6;   playerText_player_Map('RANGANAHERATH')   = 6;
    playerText_player_Map('RONALDO')    = 7;  playerText_player_Map('MESSI')     = 8;
    playerText_player_Map('CPUJARA')    = 9;  playerText_player_Map('PUJARA')    = 9;   playerText_player_Map('CHETESHWARPUJARA')= 9;
    playerText_player_Map('AMISHRA')    = 10; playerText_player_Map('MISHRA')    = 10;  playerText_player_Map('AMITMISHRA')      = 10;
    
    queryText_indexCategory_Map = containers.Map('KeyType', 'char', 'ValueType', indexClassIntType);
    queryText_indexCategory_Map = [queryText_indexCategory_Map; containers.Map([tvChannelClasses, strrep(tvChannelClasses, ' ', '')], ones(1, 2*length(tvChannelClasses), indexClassIntType))];
    queryText_indexCategory_Map = [queryText_indexCategory_Map; containers.Map(sportClasses, 2*ones(1, length(sportClasses), indexClassIntType))];
    queryText_indexCategory_Map = [queryText_indexCategory_Map; containers.Map([teamClasses, strrep(teamClasses, ' ', '')], 3*ones(1, 2*length(teamClasses), indexClassIntType))];
    queryText_indexCategory_Map = [queryText_indexCategory_Map; containers.Map([playerClasses, strrep(playerClasses, ' ', '')], 4*ones(1, 2*length(playerClasses), indexClassIntType))];
    queryText_indexCategory_Map = [queryText_indexCategory_Map; containers.Map(teamText_sport_Map.keys(), 3*ones(1, teamText_sport_Map.length(), indexClassIntType))];
    queryText_indexCategory_Map = [queryText_indexCategory_Map; containers.Map(playerText_sport_Map.keys(), 4*ones(1, playerText_sport_Map.length(), indexClassIntType))];

%%  Save above variables in configuration file
    save(dbConfigFilename);

end