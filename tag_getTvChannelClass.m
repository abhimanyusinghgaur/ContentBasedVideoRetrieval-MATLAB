function [ tvChannelClass, ocrRegion ] = tag_getTvChannelClass( videoURI )
%TAG_GETTVCHANNELCLASS Returns TV Channel class for given video
%   Detailed explanation goes here

%%  Load dbConfig
    load('dbConfig.mat', 'indexClassIntType', 'tvChannelClasses', 'expectedLogoCorners');

%%  Set initial output vars
    tvChannelClass = 0;
    tvChannelClass = cast(tvChannelClass, indexClassIntType);
    msg = 'tag_getTvChannelClass: ';

%% Load SVM Model
    load('LogoModelRealDataWithOriginal.mat', 'classificationMdlSVM');
    if ~exist('classificationMdlSVM', 'var')
        disp('Status: SVM Classification Model not found.');
        disp('Status: Exiting...');
        return;
    else
        disp('Status: SVM Classification Model Loaded.');
        featureVectorSize = length(classificationMdlSVM.PredictorNames);
    end

%% Find TV Channel Class
    corners = getKeyframeCorners(videoURI);    disp('Status: Key Frame Corners Extracted.');
    cornerHeight = size(corners,1);
    cornerWidth = size(corners,2);
    numFrames = size(corners, 4);

    currentEdgeField = zeros(cornerHeight, cornerWidth, 4);
    timeAveragedEdgeField = zeros(cornerHeight, cornerWidth, 4);

    for i = 1 : numFrames
        alpha = getAlpha(i);
        for j = 1 : 4
            currentEdgeField(:,:,j) = edge(rgb2gray(corners(:,:,:,i,j)),'canny');
            timeAveragedEdgeField(:,:,j) = alpha*timeAveragedEdgeField(:,:,j) + (1-alpha)*currentEdgeField(:,:,j);
        end
    end
    disp('Status: Average Edge Fields calculated.');

    trinarisationImage = zeros(cornerHeight, cornerWidth, 4);
    binaryLogoMask = zeros(cornerHeight, cornerWidth, 4);

    minIntesity = min(timeAveragedEdgeField(:));
    maxIntesity = max(timeAveragedEdgeField(:));

    for j = 1 : 4
        [ trinarisationImage(:,:,j), binaryLogoMask(:,:,j) ] = hysteresis3d(timeAveragedEdgeField(:,:,j), 0.2, 0.7, minIntesity, maxIntesity);
    end
    disp('Status: Prominent Edges Extracted.');

    closedLogoMask = zeros(cornerHeight, cornerWidth, 4);
    holeFilledLogoMask = zeros(cornerHeight, cornerWidth, 4);
    openedLogoMask = zeros(cornerHeight, cornerWidth, 4);

    tvChannelClassesFound = [];
    tvChannelCorners = [];
    numClassesFound = 0;

    disk5px = strel('disk',5);

    for j = 1 : 4
        fprintf('Status: Processing Corner %d.\n', j);
        closedLogoMask(:,:,j) = imclose(binaryLogoMask(:,:,j), disk5px);
        holeFilledLogoMask(:,:,j) = imfill(closedLogoMask(:,:,j),'holes');
        openedLogoMask(:,:,j) = imopen(holeFilledLogoMask(:,:,j), disk5px);

        CC = bwconncomp(openedLogoMask(:,:,j));
        stats = regionprops(CC, 'BoundingBox', 'Area');
        fprintf('Corner %d - Number of ConnComps =  %d.\n', j, size(stats,1));

        for k = 1 : size(stats,1)
            fprintf('Status: Processing Corner %d - ConnComp %d.\n', j, k);
            disp(stats(k));
            if satisfyShapeConstraints(stats(k), j, cornerHeight, cornerWidth)
    %             logo has been detected
                fprintf('Corner %d - ConnComp %d satisfies shape constraints.\n', j, k);

    %             classify the detected logo
                gdFeatures = zeros(numFrames, featureVectorSize);
                for m = 1 : numFrames
                    featureVector = getGridDescriptors(imcrop(corners(:,:,:,m,j), stats(k).BoundingBox));
                    gdFeatures(m,:) = featureVector(:);
                end
                labels = predict(classificationMdlSVM, gdFeatures);
                mostOccuringLabel = mode(labels);
                fprintf('Logo classified as: %s.\n', char(tvChannelClasses{mostOccuringLabel}));
    %             check if occurs in expected corner
                if expectedLogoCorners(mostOccuringLabel) == j
    %                 show the classified logo
                    numClassesFound = numClassesFound + 1;
                    tvChannelClassesFound(numClassesFound) = mostOccuringLabel;
                    tvChannelCorners(numClassesFound) = j;
                else
                    disp('Logo does not occur in expected corner, so not considered.');
                end
            else
                fprintf('Corner %d - ConnComp %d does not  satisfy shape constraints.\n', j, k);
            end
        end
    end

%%  Return most occuring TV Channel Class
    tvChannelCorner = 2;    %   By default corner is 2, if no tv channel found
    temp = mode(tvChannelClassesFound);
    if ~isnan(temp)
        tvChannelClass = temp;
        tvChannelCorners = tvChannelCorners(tvChannelClassesFound == tvChannelClass);
        tvChannelCorner = mode(tvChannelCorners);
    end

%%  Find OCR Region
    cornerSums = zeros(1, 4);
    for i = 1 : 4
        if i ~= tvChannelCorner
            cornerSums(i) = sum(sum(binaryLogoMask(:,:,i)));
        else
            cornerSums(i) = 0;
        end
    end
    [m, i] = max(cornerSums);
    if (i == 3) || (i == 4)
%       cricket score board covers the frame from left to right
        CCL = bwconncomp(openedLogoMask(:,:,3));
        CCR = bwconncomp(openedLogoMask(:,:,4));
        stats = cat(1, regionprops(CCL, 'BoundingBox'), regionprops(CCR, 'BoundingBox'));
        ocrRegion = [3];
    elseif i==1
%       football score board covers only left part of screen
        CC = bwconncomp(openedLogoMask(:,:,1));
        stats = regionprops(CC, 'BoundingBox');
        ocrRegion = [1];
    else
%       mostly will never reach here, as logo occurs mostly here
        CC = bwconncomp(openedLogoMask(:,:,2));
        stats = regionprops(CC, 'BoundingBox');
        ocrRegion = [2];
    end
    minY = cornerHeight; maxY = 0;
    for i = 1 : size(stats,1)
        y = stats(i).BoundingBox(1,2);
        if(y > maxY)
            maxY = y;
        end
        if(y < minY)
            minY = y;
        end
    end
    
    ocrRegion = [ocrRegion, minY, maxY];

end