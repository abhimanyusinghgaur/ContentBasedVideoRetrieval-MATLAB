function [ totalFrames ] = saveVideoFrames( filename )
%SAVEVIDEOFRAMES Summary of this function goes here
%   Detailed explanation goes here
    outputFolder = strrep(filename, '.', '_');
    mkdir(outputFolder);

    mov = VideoReader(filename);
    vidFrames = read(mov);

    totalFrames = size(vidFrames, 4);

    for frame = 1 : totalFrames
        outputBaseFileName = sprintf('%d.png', frame);
        outputFullFileName = fullfile(outputFolder, outputBaseFileName);
        imwrite( vidFrames(:,:,:,frame), outputFullFileName, 'png');
    end

end

