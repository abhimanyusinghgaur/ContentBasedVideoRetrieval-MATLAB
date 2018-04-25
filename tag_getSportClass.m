function [ sportClass ] = tag_getSportClass( ocrTexts )
%TAG_GETSPORTCLASS Returns sport class for given ocr texts
%   Detailed explanation goes here

%%  Load dbConfig
    load(db_getDbConfigFileURI(), 'indexClassIntType', 'sportClasses', 'teamText_sport_Map', 'playerText_sport_Map', 'keyText_sport_Map');

%%  Set initial output vars
    sportClass = 0;
    sportClass = cast(sportClass, indexClassIntType);
    msg = 'tag_getSportClass: ';

%%  Start Finding Sport Class
    teamTextKeys = teamText_sport_Map.keys();
    playerTextKeys = playerText_sport_Map.keys();
    keyTextKeys = keyText_sport_Map.keys();
    sportClassesFound = zeros(1, 50, indexClassIntType);
    numClassesFound = 0;
    
    for i = 1 : length(ocrTexts)
        for j = 1 : length(teamTextKeys)
            if(~isempty(strfind(ocrTexts{i}, upper(teamTextKeys{j}))))
                numClassesFound = numClassesFound + 1;
                sportClassesFound(numClassesFound) = teamText_sport_Map(teamTextKeys{j});
            end
        end
        
        for j = 1 : length(playerTextKeys)
            if(~isempty(strfind(ocrTexts{i}, upper(playerTextKeys{j}))))
                numClassesFound = numClassesFound + 1;
                sportClassesFound(numClassesFound) = playerText_sport_Map(playerTextKeys{j});
            end
        end
        
        for j = 1 : length(keyTextKeys)
            if(~isempty(strfind(ocrTexts{i}, upper(keyTextKeys{j}))))
                numClassesFound = numClassesFound + 1;
                sportClassesFound(numClassesFound) = keyText_sport_Map(keyTextKeys{j});
            end
        end
    end

%%  Return sportClass
    sportClassesFound = sportClassesFound(sportClassesFound>0);
    temp = mode(sportClassesFound);
    if ~isnan(temp)
        sportClass = temp;
    end

end