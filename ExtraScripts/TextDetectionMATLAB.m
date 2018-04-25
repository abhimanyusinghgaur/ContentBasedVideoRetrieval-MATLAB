%% Automatically Detect and Recognize Text in Natural Images
% This example shows how to detect regions containing text in an
% image. It is a common task performed on unstructured scenes, for
% example when capturing video from a moving vehicle for the purpose
% of alerting a driver about a road sign. Segmenting out the text 
% from a cluttered scene greatly helps with additional tasks 
% such as optical character recognition (OCR). 
%
% The automated text detection algorithm in this example starts with
% a large number of text region candidates and progressively removes those 
% less likely to contain text. To highlight this algorithm's flexibility,
% it is applied to images containing a road sign, a poster and a set 
% of license plates.
%
%   Copyright 2014 The MathWorks, Inc.

%% Step 1: Load image
% Load the image. The text can be rotated in plane, but significant out of
% plane rotations may require additional pre-processing.
colorImage = imread('sl.jpg');
figure; imshow(colorImage); title('Original image')

%% Step 2: Detect MSER Regions
% Since text characters usually have consistent color, we begin
% by finding regions of similar intensities in the image using the MSER
% region detector [1].

% Detect and extract regions
grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));  % extract regions

% Visualize the MSER regions overlaid on the original image
figure; imshow(colorImage); hold on;
plot(mserRegions, 'showPixelList', true,'showEllipses',false);
title('MSER regions');
%%
% Some of these regions include extra background pixels. At this stage, the
% letter E and D in "TOWED" combine into one region. Also notice that the
% space between bricks is included.

%% Step 3: Use Canny Edge Detector to Further Segment the Text
% Since written text is typically placed on clear background, it tends
% to produce high response to edge detection. Furthermore, an intersection
% of MSER regions with the edges is going to produce regions that are
% even more likely to belong to text.

% Convert MSER pixel lists to a binary mask
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;

% Run the edge detector
edgeMask = edge(grayImage, 'Canny');

% Find intersection between edges and MSER regions
edgeAndMSERIntersection = edgeMask & mserMask; 
figure; imshowpair(edgeMask, edgeAndMSERIntersection, 'montage'); 
title('Canny edges and intersection of canny edges with MSER regions')

%%
% Note that the original MSER regions in |mserMask| still contain 
% pixels that are not part of the text. We can use the edge mask
% together with edge gradients to eliminate those regions.
%
% Grow the edges outward by using image gradients around edge locations. 
% <matlab:edit(fullfile(matlabroot,'toolbox','vision','visiondemos','helperGrowEdges.m')) |helperGrowEdges|>
% helper function.

[~, gDir] = imgradient(grayImage);
% You must specify if the text is light on dark background or vice versa
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'LightTextOnDark');
figure; imshow(gradientGrownEdgesMask); title('Edges grown along gradient direction')

%%
% This mask can now be used to remove pixels that are within the MSER
% regions but are likely not part of text.

% Remove gradient grown edge pixels
edgeEnhancedMSERMask = ~gradientGrownEdgesMask & mserMask; 

% Visualize the effect of segmentation
figure; imshowpair(mserMask, edgeEnhancedMSERMask, 'montage'); 
title('Original MSER regions and segmented MSER regions')

%%
% In this image, letters have been further separated from the background and
% many of the non-text regions have been separated from text.

%% Step 4: Filter Character Candidates Using Connected Component Analysis
% Some of the remaining connected components can now be removed by using
% their region properties. The thresholds used below may vary for 
% different fonts, image sizes, or languages.

connComp = bwconncomp(edgeEnhancedMSERMask); % Find connected components
stats = regionprops(connComp,'Area','Eccentricity','Solidity');

% Eliminate regions that do not follow common text measurements
regionFilteredTextMask = edgeEnhancedMSERMask;

regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Eccentricity] > .995})) = 0;
regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Area] < 150 | [stats.Area] > 2000})) = 0;
regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Solidity] < .4})) = 0;

% Visualize results of filtering
figure; imshowpair(edgeEnhancedMSERMask, regionFilteredTextMask, 'montage'); 
title('Text candidates before and after region filtering')

%% Step 5: Filter Character Candidates Using the Stroke Width Image
% Another useful discriminator for text in images is the variation in 
% stroke width within each text candidate. Characters in most languages 
% have a similar stroke width or thickness throughout. It is therefore
% useful to remove regions where the stroke width exhibits too much 
% variation [1]. The stroke width image below is computed using the
% <matlab:edit(fullfile(matlabroot,'toolbox','vision','visiondemos','helperStrokeWidth.m')) |helperStrokeWidth|>
% helper function.

distanceImage    = bwdist(~regionFilteredTextMask);  % Compute distance transform
strokeWidthImage = helperStrokeWidth(distanceImage); % Compute stroke width image

% Show stroke width image
figure; imshow(strokeWidthImage); 
caxis([0 max(max(strokeWidthImage))]); axis image, colormap('jet'), colorbar;
title('Visualization of text candidates stroke width')
%%
% Note that most non-text regions show a large variation in stroke width.
% These can now be filtered using the coefficient of stroke width variation.

% Find remaining connected components
connComp = bwconncomp(regionFilteredTextMask);
afterStrokeWidthTextMask = regionFilteredTextMask;
for i = 1:connComp.NumObjects
    strokewidths = strokeWidthImage(connComp.PixelIdxList{i});
    % Compute normalized stroke width variation and compare to common value
    if std(strokewidths)/mean(strokewidths) > 0.35
        afterStrokeWidthTextMask(connComp.PixelIdxList{i}) = 0; % Remove from text candidates
    end
end

% Visualize the effect of stroke width filtering
figure; imshowpair(regionFilteredTextMask, afterStrokeWidthTextMask,'montage'); 
title('Text candidates before and after stroke width filtering')

%% Step 6: Determine Bounding Boxes Enclosing Text Regions
% To compute a bounding box of the text region, we will first merge the
% individual characters into a single connected component. This can be
% accomplished using morphological closing followed by opening
% to clean up any outliers.
se1=strel('disk',25);
se2=strel('disk',7);

afterMorphologyMask = imclose(afterStrokeWidthTextMask,se1);
afterMorphologyMask = imopen(afterMorphologyMask,se2);

% Display image region corresponding to afterMorphologyMask 
displayImage = colorImage; 
displayImage(~repmat(afterMorphologyMask,1,1,3)) = 0;
figure; imshow(displayImage); title('Image region under mask created by joining individual characters')
%%
% Find bounding boxes of large regions.
areaThreshold = 5000; % threshold in pixels
connComp = bwconncomp(afterMorphologyMask);
stats = regionprops(connComp,'BoundingBox','Area');
boxes = round(vertcat(stats(vertcat(stats.Area) > areaThreshold).BoundingBox));
for i=1:size(boxes,1)
    figure;
    imshow(imcrop(colorImage, boxes(i,:))); % Display segmented text
    title('Text region')
end

%% Step 7: Perform Optical Character Recognition on Text Region
% The segmentation of text from a cluttered scene can greatly improve OCR results.
% Since our algorithm already produced a well segmented text region, we can use 
% the binary text mask to improve the accuracy of the recognition results.
ocrtxt = ocr(afterStrokeWidthTextMask, boxes); % use the binary image instead of the color image
disp(ocrtxt);
ocrtxt.Text 

%% Step 8: Apply the Text Detection Process to Other Images
% To  highlight flexibility of this approach, we will apply the entire
% algorithm to other images using the 
% <matlab:edit(fullfile(matlabroot,'toolbox','vision','visiondemos','helperDetectText.m')) |helperDetectText|>  
% helper function. 
%
% Process image containing three posters.
languageImage = imread('posters.jpg');
boxes = helperDetectText(languageImage);

% Visualize the results
figure; imshow(languageImage); title('Posters with different languages')
hold on
for i=1:size(boxes,1)
    rectangle('Position', boxes(i,:),'EdgeColor','r')
end

%%
% Below, we will process an image containing three license plates. License plates 
% usually have white or gray background with a darker text color. This requires 
% that the edges are grown in the opposite direction. Additionally, the maximum
% eccentricity threshold must be adjusted since license plate characters are
% relatively thin. Both of these parameters can be supplied to the helper function.
plateImage = imread('licensePlates.jpg');
eccentricityThreshold = 0.995;
boxes = helperDetectText(plateImage,'TextPolarity','DarkTextOnLight',...
    'MaxEccentricity', eccentricityThreshold, 'SizeRange', [200,2000]);
figure; imshow(plateImage); title('License plates'); hold on
for i=1:size(boxes,1)
    rectangle('Position', boxes(i,:),'EdgeColor','r')
end

%% References
%
% [1] Chen, Huizhong, et al. "Robust Text Detection in Natural Images with
%     Edge-Enhanced Maximally Stable Extremal Regions." Image Processing
%     (ICIP), 2011 18th IEEE International Conference on. IEEE, 2011.

displayEndOfDemoMessage(mfilename)
