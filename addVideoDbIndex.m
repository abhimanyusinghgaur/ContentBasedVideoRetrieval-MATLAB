function [ added, msg ] = addVideoDbIndex( videoName, extension, indexMap )
%ADDVIDEODBINDEX Summary of this function goes here
%   Detailed explanation goes here
    added = true;
    msg = 'addVideoDbIndex: ';
    load('metadata.mat');
    
    len = length(indexMap);
    if len ~= length(indexCategories)
        added = false;
        msg = strcat(msg, 'Invalid number of indexes.');
    end
    
    fileID = fopen(videoDbIndexFile, 'a');
    if fileID == -1
        added = false;
        msg = strcat(msg, ferror(fileID));
        return;
    end
%   In deletion of a video, videoName would change to 0 and indexMap(0) 
%   would point to position of next deleted video
    fwrite(fileID, videoName, videoNameIntSize);
    fwrite(fileID, extension, extensionSize);
%   TODO: can it be optimized in terms of writes?
    for i = 1 : len
        fwrite(fileID, indexMap(i), indexClassIntSize);
        fwrite(fileID, 0, bytePositionIntSize);
    end
    fclose(fileID);

end

