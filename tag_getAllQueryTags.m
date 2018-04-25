function [ indexMap ] = tag_getAllQueryTags( query )
%TAG_GETALLQUERYTAGS Returns tagged indexMap for indexCategories for given video.
%   Detailed explanation goes here

%%  Load dbConfig
    load(db_getDbConfigFileURI(), 'indexClassIntType', 'indexCategories', 'tvChannelClasses',...
        'sportClasses', 'teamClasses', 'playerClasses', 'teamText_team_Map',...
        'playerText_player_Map', 'queryText_indexCategory_Map');

%%  Set initial output vars
    indexMap = zeros(1, length(indexCategories), indexClassIntType);
    msg = 'tag_getAllQueryTags: ';

%%  Start Finding Sport Class
    queryKeys = strsplit(upper(query));
    tvChannelClass = 0;
    sportClass = 0;
    teamClass = 0;
    playerClass = 0;
    
    for i = 1 : length(queryKeys)
        if queryText_indexCategory_Map.isKey(queryKeys{i})
            indexCategory = queryText_indexCategory_Map(queryKeys{i});
            switch indexCategory
                case 1
                        tvChannelClass = find(strcmp(strrep(tvChannelClasses, ' ', ''), queryKeys{i}));
                case 2
                        sportClass = find(strcmp(strrep(sportClasses, ' ', ''), queryKeys{i}));
                case 3
                        temp = find(strcmp(strrep(teamClasses, ' ', ''), queryKeys{i}));
                        if ~isempty(temp)
                            teamClass = temp;
                        else
                            teamClass = teamText_team_Map(queryKeys{i});
                        end
                case 4
                        temp = find(strcmp(strrep(playerClasses, ' ', ''), queryKeys{i}));
                        if ~isempty(temp)
                            playerClass = temp;
                        else
                            playerClass = playerText_player_Map(queryKeys{i});
                        end
            end
        end
    end

%%  Return indexMap
    indexMap = [tvChannelClass, sportClass, teamClass, playerClass];
    disp(['Status: IndexMap: ', int2str(indexMap)]);

end

