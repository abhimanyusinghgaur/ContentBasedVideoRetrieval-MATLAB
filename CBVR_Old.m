clc;
% This script Contains  code for classifying TV Channel and finding sport
% out of Cricket and Football.
% Below is the video filename on which this script will run.
filename = 'SonySix/sonySix2-005_2.mp4';
% If SVM model has not been generated, generate one with
% multiclassLogoTrainer.m script.
svmModelFileURI = 'LogoModelRealDataWithOriginal.mat';
% filename = 'TenSports/Demo.mp4';

%% Load SVM Model
load(svmModelFileURI, 'classificationMdlSVM', 'tvChannelClasses', 'expectedLogoCorners');
if (exist('classificationMdlSVM', 'var')~=1) || (exist('tvChannelClasses', 'var')~=1) || (exist('expectedLogoCorners', 'var')~=1)
    disp('Status: SVM Classification Model not found.');
    disp('Status: Exiting...');
    return;
else
    disp('Status: SVM Classification Model Loaded.');
    featureVectorSize = length(classificationMdlSVM.PredictorNames);
end

%% Control Variables
showOutput = true;
sportRecognitionEnabled = true;
saveResults = true;

%% Result saving functionality
if saveResults
    resultFolder = strcat(strrep(filename, '.', '_'), '_results');
    resultFile = fullfile(resultFolder, 'Results.txt');
    mkdir(resultFolder);
    fileID = fopen(resultFile,'wt');
    fclose(fileID);
end

%% CBVR Start
corners = getTimedframeCorners(filename);    disp('Status: Timed Frame Corners Extracted.');
cornerHeight = size(corners,1);
cornerWidth = size(corners,2);
numFrames = size(corners, 4);

currentEdgeField = zeros(cornerHeight, cornerWidth, 4);
timeAveragedEdgeField = zeros(cornerHeight, cornerWidth, 4);

if showOutput
    figure;
end
for i = 1 : numFrames
    alpha = getAlpha(i);
    for j = 1 : 4
        currentEdgeField(:,:,j) = edge(rgb2gray(corners(:,:,:,i,j)),'canny');
        timeAveragedEdgeField(:,:,j) = alpha*timeAveragedEdgeField(:,:,j) + (1-alpha)*currentEdgeField(:,:,j);
    end
    
    if showOutput
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
    end
    k = waitforbuttonpress;
end
disp('Status: Average Edge Fields calculated.');

trinarisationImage = zeros(cornerHeight, cornerWidth, 4);
binaryLogoMask = zeros(cornerHeight, cornerWidth, 4);

minIntesity = min(timeAveragedEdgeField(:));
maxIntesity = max(timeAveragedEdgeField(:));

if showOutput
    figure;
end
for j = 1 : 4
    [ trinarisationImage(:,:,j), binaryLogoMask(:,:,j) ] = hysteresis3d(timeAveragedEdgeField(:,:,j), 0.2, 0.7, minIntesity, maxIntesity);
    if showOutput
        subplot(2,4,j), imshow(trinarisationImage(:,:,j));
        subplot(2,4,j+4), imshow(binaryLogoMask(:,:,j));
    end
end
disp('Status: Prominent Edges Extracted.');

closedLogoMask = zeros(cornerHeight, cornerWidth, 4);
holeFilledLogoMask = zeros(cornerHeight, cornerWidth, 4);
openedLogoMask = zeros(cornerHeight, cornerWidth, 4);

disk5px = strel('disk',5);

if showOutput
    h = figure('Name','Disk 5px Morphological Operarions','NumberTitle','off');
end
for j = 1 : 4
    fprintf('Status: Processing Corner %d.\n', j);
%     ocrResults = ocr(binaryLogoMask(:,:,j));
%     recognizedText = ocrResults.Text;
%     fprintf('Status: Text in Corner %d: %s.\n', j, recognizedText);
    closedLogoMask(:,:,j) = imclose(binaryLogoMask(:,:,j), disk5px);
    holeFilledLogoMask(:,:,j) = imfill(closedLogoMask(:,:,j),'holes');
    openedLogoMask(:,:,j) = imopen(holeFilledLogoMask(:,:,j), disk5px);
    
    if showOutput
        figure(h);
        subplot(3,4,j), imshow(closedLogoMask(:,:,j)), title('Closed Logo Mask');
        subplot(3,4,j+4), imshow(holeFilledLogoMask(:,:,j)), title('Hole Filled Logo Mask');
        subplot(3,4,j+8), imshow(openedLogoMask(:,:,j)), title('Opened Logo Mask');
    end
    
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
            fprintf('Logo classified as: %s.\n', char(tvChannelClasses(mostOccuringLabel)));
%             check if occurs in expected corner
            if expectedLogoCorners(mostOccuringLabel) == j
%                 show the classified logo
                if showOutput
                    figure('Name',sprintf('Corner %d - ConnComp %d classified as: %s', j, k, char(tvChannelClasses(mostOccuringLabel))),'NumberTitle','off');
                    imshow(imcrop(binaryLogoMask(:,:,j), stats(k).BoundingBox));
                end
                if saveResults
                    imwrite(imcrop(binaryLogoMask(:,:,j), stats(k).BoundingBox), fullfile(resultFolder, sprintf('Step7_Corner%d_%s.png', j, char(tvChannelClasses(mostOccuringLabel)))));
                    fileID = fopen(resultFile,'at');
                    fprintf(fileID, 'Detected Logo: %s, Corner: %d\n', char(tvChannelClasses(mostOccuringLabel)), j);
                    fclose(fileID);
                end
            else
                disp('Logo does not occur in expected corner, so not considered.');
            end
        else
            fprintf('Corner %d - ConnComp %d does not  satisfy shape constraints.\n', j, k);
        end
    end
end

% Sport Recognition
if sportRecognitionEnabled
    sportCategory = getSport(binaryLogoMask(:,:,:));
    fprintf('\nStatus: Sport Category: %s\n', sportCategory);
end

fprintf('\n%d frames processed in all.\n', numFrames);

%% Save Results
if saveResults
    for i = 1 : 4
        imwrite(timeAveragedEdgeField(:,:,i), fullfile(resultFolder, sprintf('Step1_Corner%d_timeAveragedEdgeField.png', i)));
        imwrite(trinarisationImage(:,:,i)   , fullfile(resultFolder, sprintf('Step2_Corner%d_trinarisationImage.png', i)));
        imwrite(binaryLogoMask(:,:,i)       , fullfile(resultFolder, sprintf('Step3_Corner%d_binaryLogoMask.png', i)));
        imwrite(closedLogoMask(:,:,i)       , fullfile(resultFolder, sprintf('Step4_Corner%d_closedLogoMask.png', i)));
        imwrite(holeFilledLogoMask(:,:,i)   , fullfile(resultFolder, sprintf('Step5_Corner%d_holeFilledLogoMask.png', i)));
        imwrite(openedLogoMask(:,:,i)       , fullfile(resultFolder, sprintf('Step6_Corner%d_openedLogoMask.png', i)));
    end
    if sportRecognitionEnabled
        fileID = fopen(resultFile,'at');
        fprintf(fileID, 'SportCategory: %s\n', sportCategory);
        fclose(fileID);
    end
end