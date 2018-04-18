function [ added, msg ] = db_addVideoDbIndex( videoName, extension, indexMap, indexMapLocations )
%ADDVIDEODBINDEX Summary of this function goes here
%   Detailed explanation goes here
    added = true;
    msg = 'addVideoDbIndex: ';

%%  Load dbConfig
    load('dbConfig.mat');

%%  Input Formatting
%   Pad extension with 0, if length is less than maxExtensionChars
    extension = sprintf('%0*s', maxExtensionChars, extension);

%%  Open videoDbIndexFile and move write pointer to correct position
    fileID = fopen(videoDbIndexFile, 'r+');
    if fileID == -1
        added = false;
        msg = [msg, videoDbIndexFile, ': ', ferror(fileID)];
        return;
    end
    currentBytePos = ftell(fileID);
    if currentBytePos == -1
        fclose(fileID);
        added = false;
        msg = [msg, videoDbIndexFile, ': ', ferror(fileID)];
        return;
    end
    len = length(indexMap);
    insertBytePos = sizeof(headerIntType) + (videoName-1)*(sizeof(videoNameIntType) + maxExtensionChars + len*(sizeof(indexClassIntType) + sizeof(bytePositionIntType)));
    offset = insertBytePos - currentBytePos;
    if fseek(fileID, offset, 'cof') == -1
        fclose(fileID);
        added = false;
        msg = [msg, videoDbIndexFile, ': ', ferror(fileID)];
        return;
    end

%%  Write Record to videoDbIndexFile
%   In deletion of a video, videoName would change to 0 and indexMap(0) 
%   would point to position of next deleted video
    fwrite(fileID, videoName, videoNameIntType);
    fwrite(fileID, extension, extensionType);
%   TODO: can it be optimized in terms of writes?
    for i = 1 : len
        fwrite(fileID, indexMap(i), indexClassIntType);
        fwrite(fileID, indexMapLocations(i), bytePositionIntType);
    end
    fclose(fileID);

end

