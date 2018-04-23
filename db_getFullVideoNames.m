function [ fullVideoNames, success, msg  ] = db_getFullVideoNames( videoNames )
%READVIDEODBINDEXFILE Given videoNames, returns full name for the videos
%   Assumes none of the given videoNames is greater than videoDbCount.
%   videoNames is a horizontal vector.

%%  Basic required input sanitation
    videoNames = videoNames(videoNames>0);
    len = length(videoNames);

%%  Set initial output vars
    fullVideoNames = cell(1, len);
    success = true;
    msg = 'getFullVideoNames: ';

%%  Load dbConfig
    load('dbConfig.mat');

%% Input Validation
    if isempty(videoNames)
        msg = [msg, 'Why was I called?'];
        return;
    end

%%  Open videoDbRecordFile
    fileID = fopen(videoDbRecordFile, 'r');
    if fileID == -1
        success = false;
        msg = [msg, videoDbRecordFile, ': ', ferror(fileID)];
        return;
    end

%%  For each video: Move read pointer to correct record position and retrieve fullName
    for i = 1 : len
        readBytePos = sizeof(headerIntType) + (videoNames(i)-1)*(videoDbRecordByteSize);
        if fseek(fileID, readBytePos, 'bof') == -1
            success = false;
            msg = [msg, videoDbRecordFile, ': ', ferror(fileID)];
            fclose(fileID);
            return;
        end
        videoName = fread(fileID, 1, videoNameIntType);
        extension = fread(fileID, maxExtensionChars, [extensionType,'=>',extensionType]);
        extension = strrep(extension.', '0', '');
        fullVideoNames{i} = sprintf('%d.%s', videoName, extension);
    end
    fclose(fileID);

end