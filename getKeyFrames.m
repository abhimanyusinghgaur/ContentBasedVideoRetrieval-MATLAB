function [ keyFrames ] = getKeyFrames( videoURI, requiredFps )
%GETKEYFRAMES Summary of this function goes here
%   Detailed explanation goes here
    if ~exist('requiredFps', 'var')
        requiredFps = 1;
    end
    
    video = VideoReader(videoURI);
    totalFrames = video.NumberOfFrames;
    requiredNumberOfFrames = uint32(video.Duration * requiredFps);
    
    if totalFrames <= requiredNumberOfFrames
        requiredNumberOfFrames = totalFrames;
    end
    
    keyFrames = zeros(video.Height, video.Width, video.BitsPerPixel/8, requiredNumberOfFrames, 'uint8');
    frameInterval = ( totalFrames - rem(totalFrames, requiredNumberOfFrames) ) / requiredNumberOfFrames;

%     re-initialize because of the problem with video.NumberOfFrames
    video = VideoReader(videoURI);
    i = 1;
    while i <= requiredNumberOfFrames
        for j = 1 : frameInterval - 1
%                 skip (frameInterval - 1) frames
            readFrame(video);
        end
        keyFrames(:,:,:,i) = readFrame(video);
        i = i + 1;
    end

end