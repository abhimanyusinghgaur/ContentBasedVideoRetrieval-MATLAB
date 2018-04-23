function [ teamClass ] = tag_getTeamClass( ocrTexts )
%TAG_GETTEAMCLASS Returns team class for given ocr texts
%   Detailed explanation goes here

%%  Load dbConfig
    load('dbConfig.mat', 'indexClassIntType', 'teamClasses', 'teamText_team_Map', 'playerText_team_Map');

%%  Set initial output vars
    teamClass = 0;
    teamClass = cast(teamClass, indexClassIntType);
    msg = 'tag_getTeamClass: ';

%%  Start Finding Sport Class
    teamTextKeys = teamText_team_Map.keys();
    playerTextKeys = playerText_team_Map.keys();
    teamClassesFound = zeros(1, 50, indexClassIntType);
    numClassesFound = 0;
    
    for i = 1 : length(ocrTexts)
        for j = 1 : length(teamTextKeys)
            if(~isempty(strfind(ocrTexts{i}, upper(teamTextKeys{j}))))
                numClassesFound = numClassesFound + 1;
                teamClassesFound(numClassesFound) = teamText_team_Map(teamTextKeys{j});
            end
        end
        
        for j = 1 : length(playerTextKeys)
            if(~isempty(strfind(ocrTexts{i}, upper(playerTextKeys{j}))))
                numClassesFound = numClassesFound + 1;
                teamClassesFound(numClassesFound) = playerText_team_Map(playerTextKeys{j});
            end
        end
    end

%%  Return sportClass
    teamClassesFound = teamClassesFound(teamClassesFound>0);
    temp = mode(teamClassesFound);
    if ~isnan(temp)
        teamClass = temp;
    end

end

