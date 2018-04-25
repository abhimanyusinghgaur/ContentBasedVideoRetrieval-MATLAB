function [ corners ] = getCorners( frames )
%GETCORNERS Returns a 5D array of frame corners, where the 4th dimension
%represents frame number and the 5th dimension represents corner number

    heightDivisionFactor = 3;
    widthDivisionFactor = 3;

    frameHeight = size(frames,1);
    frameWidth = size(frames,2);
    colorSpaceSize = size(frames,3);
    numFrames = size(frames,4);

    cornerHeight = floor(frameHeight / heightDivisionFactor);
    cornerWidth = floor(frameWidth / widthDivisionFactor);

    corners = zeros(cornerHeight, cornerWidth, colorSpaceSize, numFrames, 4, 'uint8');
    
    for i = 1 : numFrames
        corners(:,:,:,i,1) = frames(1:cornerHeight, 1:cornerWidth, :, i);
        corners(:,:,:,i,2) = frames(1:cornerHeight, frameWidth-cornerWidth+1:frameWidth, :, i);
        corners(:,:,:,i,3) = frames(frameHeight-cornerHeight+1:frameHeight, 1:cornerWidth, :, i);
        corners(:,:,:,i,4) = frames(frameHeight-cornerHeight+1:frameHeight, frameWidth-cornerWidth+1:frameWidth, :, i);
    end

end

