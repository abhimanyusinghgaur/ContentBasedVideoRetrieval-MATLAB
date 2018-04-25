function [ totalFrames ] = getCandidateFrames( videoURI )
%getCandidateFrames Summary of this function goes here
%   Detailed explanation goes here
    video = VideoReader(videoURI);
    vidHeight=video.Height;
    vidWidth=video.Width;
    vidFrames = read(video);
    totalFrames = size(vidFrames, 4);
    
%     Preallocating memory
%     currR = zeros(vidHeight, vidWidth, 'uint8');
%     currG = zeros(vidHeight, vidWidth, 'uint8');
%     currB = zeros(vidHeight, vidWidth, 'uint8');    
%     nextR = zeros(vidHeight, vidWidth, 'uint8');
%     nextG = zeros(vidHeight, vidWidth, 'uint8');
%     nextB = zeros(vidHeight, vidWidth, 'uint8');

        k = 1;
        img = vidFrames(:,:,:,k);
        grayImg = rgb2gray(img);
        currSignature = getSignature(grayImg);
%         [currHist, x] = imhist(grayImg);
%         %Split into RGB Channels
%         currR = img(:,:,1);
%         currG = img(:,:,2);
%         currB = img(:,:,3);
%         %Get histValues for each channel
%         [yCurrR, x] = imhist(currR);
%         [yCurrG, x] = imhist(Green);
%         [yCurrB, x] = imhist(Blue);
    
    skip = 5;
    
    while k < totalFrames - skip
        k = k+skip+1;
        img = vidFrames(:,:,:,k);
        grayImg = rgb2gray(img);
        
        nextSignature = getSignature(grayImg);
        match = dot(currSignature,nextSignature)/(norm(currSignature)*norm(nextSignature));
        fprintf('\n%d-%d frame matching: %f', k-skip-1, k, match);
        
        currSignature = nextSignature;
        
%         [nextHist, x] = imhist(grayImg);
%         histDiff = pdist2(currHist, nextHist, 'chisq');
%         fprintf('\n%d-%d frame difference: ', k, k+1);
%         disp(histDiff);        
%         currHist = nextHist;
        
%         nextR = img(:,:,1);
%         nextG = img(:,:,2);
%         nextB = img(:,:,3);
% calc histogram and diff %
%         currR = nextR;
%         currG = nextG;
%         currB = nextB;
    end

end

