function [ ocrFrameFilenames ] = tag_getOcrKeyFrames( videoURI, ocrRegion )
%TAG_GETKEYFRAMES Summary of this function goes here
%   ocrRegion = [cornerNum, minY, maxY]

%%  Load dbConfig
    load(db_getDbConfigFileURI(), 'pathSeparator');

%%  Initial Settings
    heightDivisionFactor = 3;
    video = VideoReader(videoURI);
    frameHeight = video.Height;
    frameWidth = video.Width;
    cornerHeight = floor(frameHeight / heightDivisionFactor);
    numFrames = video.NumberOfFrames;

%%  Find Candidate Frames
    video = VideoReader(videoURI);

    [pathstr,filename,ext] = fileparts(videoURI);
    ext = strrep(ext, '.', '');
    outputFolder = [pathstr, pathSeparator, filename, '_', ext, pathSeparator, 'keyframes', pathSeparator];
    if exist(outputFolder, 'dir') == 7
        rmdir(outputFolder, 's');
    end
    mkdir(outputFolder);

    numberOfBins = 4;
    histDiff = zeros(numFrames-1, 1);

    if hasFrame(video)
        currHistogram = colorHistogram(imresize(readFrame(video), [NaN 100]), numberOfBins);
    end

    i = 1;
    while hasFrame(video)
        nextHistogram = colorHistogram(imresize(readFrame(video), [NaN 100]));
        histDiff(i) = sum(imabsdiff(currHistogram, nextHistogram));
        currHistogram = nextHistogram;
        i = i + 1;
    end

    %calculating mean and standard deviation
    mean = mean2(histDiff);
    std = std2(histDiff);
    threshold = 4*std + mean;

    video = VideoReader(videoURI);
    readFrame(video);
    for i = 1 : numFrames-1
        frame = readFrame(video);
        if histDiff(i) > threshold    % Greater than threshold select as a candidate frame
            filename = fullfile(outputFolder, sprintf('candidateFrame_%08d.png', i+1));   %Writing the candidate frame
            imwrite(frame, filename);
%             fprintf('Frame %d is a candidate frame.\n', i+1);
        end
    end

%%  Find and save Key Frames and OCR Key Frames
    candidateFrames = dir([outputFolder, '*.png']);
    currFrame = imread([outputFolder, candidateFrames(1).name]);
    resizedFrame = double(rgb2gray(imresize(currFrame, [9 16])));
    X = resizedFrame(:);
    % X = getGridDescriptors(currFrame);

    for i = 1 : length(candidateFrames)-1
        nextFrame = imread([outputFolder, candidateFrames(i+1).name]);
        resizedFrame = double(rgb2gray(imresize(nextFrame, [9 16])));
        Y = resizedFrame(:);
    %     Y = getGridDescriptors(nextFrame);
        covMat = cov(X,Y);
        sXY = covMat(1,2) / sqrt(covMat(1,1)*covMat(2,2));

%         fprintf('Structural similarity of %s-%s is: %f\n', candidateFrames(i).name, candidateFrames(i+1).name, sXY);
        if sXY <= 0.5
            filename = fullfile(outputFolder, strcat('key_', candidateFrames(i).name));
            imwrite(currFrame, filename);
%             fprintf('candidateFrames %d is a key frame.\n', i);
%           if ocrRegion has been found correctly, save ocrRegions as
%           separate frames
            if ocrRegion(2) < ocrRegion(3)  %   => if minY < maxY
                filename = fullfile(outputFolder, strcat('ocr_key_', candidateFrames(i).name));
                if ocrRegion(1) == 3
                    imwrite(imcrop(currFrame, [0 frameHeight-cornerHeight+ocrRegion(2) frameWidth cornerHeight-ocrRegion(2)]), filename);
                elseif ocrRegion(1) == 1
                    imwrite(imcrop(currFrame, [0 0 frameWidth/2 ocrRegion(3)]), filename);
                elseif ocrRegion(1) == 2
                    imwrite(imcrop(currFrame, [frameWidth/2 0 frameWidth/2 ocrRegion(3)]), filename);
                end
            end
        end

        currFrame = nextFrame;
        X = Y;
    end

%%  Return OCR Key Frame Filenames
    ocrFrameNames = dir([outputFolder, 'ocr_*.png']);
    len = length(ocrFrameNames);
    ocrFrameFilenames = cell(1, len);
    for i = 1 : len
        ocrFrameFilenames{i} = [outputFolder, ocrFrameNames(i).name];
    end

end