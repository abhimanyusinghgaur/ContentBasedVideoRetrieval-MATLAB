clc;
filename = 'ddSports1/ddSports1-003.MP4';
% filename = 'sonySix2.mp4';
% filename = 'Demo.mp4';
% filename = 'football/football-005.mp4';
% filename = '2538-5_70133.avi';

load('LogoModelRealData.mat', 'classificationMdlSVM', 'logoClassNames');
if ~exist('classificationMdlSVM', 'var') || ~exist('logoClassNames', 'var') || ~exist('expectedLogoCorners', 'var')
    disp('Status: SVM Classification Model not found.');
    disp('Status: Exiting...');
    return;
else
    disp('Status: SVM Classification Model Loaded.');
    featureVectorSize = length(classificationMdlSVM.PredictorNames);
end

keyFrames = getKeyFrames(filename); disp('Status: Key Frames Extracted.');
corners = getCorners(keyFrames);    disp('Status: Corners Extracted.');
cornerHeight = size(corners,1);
cornerWidth = size(corners,2);
numFrames = size(corners, 4);

currentEdgeField = zeros(cornerHeight, cornerWidth, 4);
timeAveragedEdgeField = zeros(cornerHeight, cornerWidth, 4);

figure;
for i = 1 : numFrames
    alpha = getAlpha(i);
    for j = 1 : 4
        currentEdgeField(:,:,j) = edge(rgb2gray(corners(:,:,:,i,j)),'canny');
        timeAveragedEdgeField(:,:,j) = alpha*timeAveragedEdgeField(:,:,j) + (1-alpha)*currentEdgeField(:,:,j);
    end
    
    subplot(3,4,1), imshow(corners(:,:,:,i,1)), title(sprintf('Frame %d', i));
    subplot(3,4,2), imshow(corners(:,:,:,i,2));
    subplot(3,4,3), imshow(corners(:,:,:,i,3));
    subplot(3,4,4), imshow(corners(:,:,:,i,4));
    subplot(3,4,5), imshow(currentEdgeField(:,:,1));
    subplot(3,4,6), imshow(currentEdgeField(:,:,2));
    subplot(3,4,7), imshow(currentEdgeField(:,:,3));
    subplot(3,4,8), imshow(currentEdgeField(:,:,4));
    subplot(3,4,9), imshow(timeAveragedEdgeField(:,:,1));
    subplot(3,4,10), imshow(timeAveragedEdgeField(:,:,2));
    subplot(3,4,11), imshow(timeAveragedEdgeField(:,:,3));
    subplot(3,4,12), imshow(timeAveragedEdgeField(:,:,4));
%     k = waitforbuttonpress;
end
disp('Status: Average Edge Fields calculated.');

trinarisationImage = zeros(cornerHeight, cornerWidth, 4);
binaryLogoMask = zeros(cornerHeight, cornerWidth, 4);

minIntesity = min(timeAveragedEdgeField(:));
maxIntesity = max(timeAveragedEdgeField(:));

figure;
for j = 1 : 4
    [ trinarisationImage(:,:,j), binaryLogoMask(:,:,j) ] = hysteresis3d(timeAveragedEdgeField(:,:,j), 0.2, 0.7, minIntesity, maxIntesity);
    subplot(2,4,j), imshow(trinarisationImage(:,:,j));
    subplot(2,4,j+4), imshow(binaryLogoMask(:,:,j));
end
disp('Status: Prominent Edges Extracted.');

closedLogoMask = zeros(cornerHeight, cornerWidth, 4);
holeFilledLogoMask = zeros(cornerHeight, cornerWidth, 4);
openedLogoMask = zeros(cornerHeight, cornerWidth, 4);

disk5px = strel('disk',5);

h = figure('Name','Disk 5px Morphological Operarions','NumberTitle','off');
for j = 1 : 4
    fprintf('Status: Processing Corner %d.\n', j);
    closedLogoMask(:,:,j) = imclose(binaryLogoMask(:,:,j), disk5px);
    holeFilledLogoMask(:,:,j) = imfill(closedLogoMask(:,:,j),'holes');
    openedLogoMask(:,:,j) = imopen(holeFilledLogoMask(:,:,j), disk5px);
    
    figure(h);
    subplot(3,4,j), imshow(closedLogoMask(:,:,j)), title('Closed Logo Mask');
    subplot(3,4,j+4), imshow(holeFilledLogoMask(:,:,j)), title('Hole Filled Logo Mask');
    subplot(3,4,j+8), imshow(openedLogoMask(:,:,j)), title('Opened Logo Mask');
    
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
            fprintf('Logo classified as: %s.\n', char(logoClassNames(mostOccuringLabel)));
%             check if occurs in expected corner
            if expectedLogoCorners(mostOccuringLabel) == j
%                 show the classified logo
                figure('Name',sprintf('Corner %d - ConnComp %d classified as: %s', j, k, char(logoClassNames(mostOccuringLabel))),'NumberTitle','off');
                imshow(imcrop(binaryLogoMask(:,:,j), stats(k).BoundingBox));
            else
                disp('Logo does not occur in expected corner, so not considered.');
            end
        else
            fprintf('Corner %d - ConnComp %d does not  satisfy shape constraints.\n', j, k);
        end
    end
end

fprintf('\n%d frames processed in all.\n', numFrames);