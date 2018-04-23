function [ thumbnail ] = getThumbnail( videoURI, width, height )
%GETTHUMBNAIL Returns a thumbnail for given video
%   Detailed explanation goes here

    video = VideoReader(videoURI);
    thumbnail = imresize(readFrame(video), [width height]);

end

