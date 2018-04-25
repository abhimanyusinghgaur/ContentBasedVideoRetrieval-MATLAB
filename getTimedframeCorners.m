function [ corners ] = getTimedframeCorners( videoURI, requiredFps )
%GETKEYFRAMECORNERS  Returns a 5D array of frame corners, where the 4th dimension
%represents frame number and the 5th dimension represents corner number
%   Detailed explanation goes here
    if ~exist('requiredFps', 'var')
        requiredFps = 1;
    end
    
    heightDivisionFactor = 3;
    widthDivisionFactor = 3;
    
    video = VideoReader(videoURI);
    frameHeight = video.Height;
    frameWidth = video.Width;
    colorSpaceSize = video.BitsPerPixel / 8;
    totalFrames = video.NumberOfFrames;
    requiredNumberOfFrames = uint32(video.Duration * requiredFps);

    cornerHeight = floor(frameHeight / heightDivisionFactor);
    cornerWidth = floor(frameWidth / widthDivisionFactor);
    
    if totalFrames <= requiredNumberOfFrames
        requiredNumberOfFrames = totalFrames;
    end
    
    corners = zeros(cornerHeight, cornerWidth, colorSpaceSize, requiredNumberOfFrames, 4, 'uint8');
    frameInterval = ( totalFrames - rem(totalFrames, requiredNumberOfFrames) ) / requiredNumberOfFrames;
    
%     re-initialize because of the problem with video.NumberOfFrames
    video = VideoReader(videoURI);
    i = 1;
    while i <= requiredNumberOfFrames
        for j = 1 : frameInterval - 1
%                 skip (frameInterval - 1) frames
            readFrame(video);
        end
        keyFrame = readFrame(video);
        corners(:,:,:,i,1) = keyFrame(1:cornerHeight, 1:cornerWidth, :);
        corners(:,:,:,i,2) = keyFrame(1:cornerHeight, frameWidth-cornerWidth+1:frameWidth, :);
        corners(:,:,:,i,3) = keyFrame(frameHeight-cornerHeight+1:frameHeight, 1:cornerWidth, :);
        corners(:,:,:,i,4) = keyFrame(frameHeight-cornerHeight+1:frameHeight, frameWidth-cornerWidth+1:frameWidth, :);
        i = i + 1;
    end
    
end