function [ fullVideoNames, success, msg  ] = db_getFullVideoNames( videoNames )
%READVIDEODBINDEXFILE Given videoNames, returns full name for the videos
%   Assumes none of the given videoNames is 0, or greater than videoDbCount
    len = length(videoNames);
    fullVideoNames = cell(1, len);
    success = true;
    msg = 'getFullVideoNames: ';

%%  Load dbConfig
    load('dbConfig.mat');

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

