function [ indexMap ] = tag_getAllTags( videoURI )
%GETVIDEOTAGS Returns tagged indexMap for indexCategories for given video.
%   Detailed explanation goes here

%%  Load dbConfig
    load(db_getDbConfigFileURI(), 'supportedVideoFormats', 'indexClassIntType', 'indexCategories');

%%  Set initial output vars
    indexMap = zeros(1, length(indexCategories), indexClassIntType);
    msg = 'tag_getAllTags: ';

%%  Input Validation
%   Check if file extension is supported
    [pathstr,name,ext] = fileparts(videoURI);
    ext = strrep(ext, '.', '');
    if ~any(strcmp(supportedVideoFormats, ext))
        msg = [msg, videoURI, ': ', 'Unsupported File format.'];
        return;
    end

%%  Find TV Channel Class
    [indexMap(1), ocrRegion] = tag_getTvChannelClass(videoURI);
    disp(['Status: TV Channel Class: ', int2str(indexMap(1)), ', OCR Region: ', int2str(ocrRegion)]);

%% Get OCR Key Frames and OCR text for each Key Frame
    ocrFrameFilenames = tag_getOcrKeyFrames(videoURI, ocrRegion);
    disp('Status: OCR Frames Extracted.');
    ocrTexts = tag_getOCRTexts(ocrFrameFilenames);
    for i = 1 : length(ocrTexts)
        fprintf('Status: File: %s\nDetected Text: %s\n', ocrFrameFilenames{i}, ocrTexts{i});
    end
    ocrTexts = upper(ocrTexts);

%% Get Sport Class
    indexMap(2) = tag_getSportClass(ocrTexts);
    disp(['Status: SportClass: ', int2str(indexMap(2))]);

%% Get Team Class
    indexMap(3) = tag_getTeamClass(ocrTexts);
    disp(['Status: TeamClass: ', int2str(indexMap(3))]);

%% Get Team Class
    indexMap(4) = tag_getPlayerClass(ocrTexts);
    disp(['Status: PlayerClass: ', int2str(indexMap(4))]);

end