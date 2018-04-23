function [ playerClass ] = tag_getPlayerClass( ocrTexts )
%TAG_GETPLAYERCLASS Returns sport class for given ocr texts
%   Detailed explanation goes here

%%  Load dbConfig
    load('dbConfig.mat', 'indexClassIntType', 'playerClasses', 'playerText_player_Map');

%%  Set initial output vars
    playerClass = 0;
    playerClass = cast(playerClass, indexClassIntType);
    msg = 'tag_getPlayerClass: ';

%%  Start Finding Sport Class
    playerTextKeys = playerText_player_Map.keys();
    playerClassesFound = zeros(1, 50, indexClassIntType);
    numClassesFound = 0;
    
    for i = 1 : length(ocrTexts)
        for j = 1 : length(playerTextKeys)
            if(~isempty(strfind(ocrTexts{i}, upper(playerTextKeys{j}))))
                numClassesFound = numClassesFound + 1;
                playerClassesFound(numClassesFound) = playerText_player_Map(playerTextKeys{j});
            end
        end
    end

%%  Return sportClass
    playerClassesFound = playerClassesFound(playerClassesFound>0);
    temp = mode(playerClassesFound);
    if ~isnan(temp)
        playerClass = temp;
    end

end