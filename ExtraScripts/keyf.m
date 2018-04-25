filename = 'sonySix2.mp4';      %Video Name 
video = VideoReader(filename);   %Using video reader reading video
numFrames = video.NumberOfFrames;            % Calculating number of frames
video = VideoReader(filename);   %Using video reader reading video

outputFolder = strcat(strrep(filename, '.', '_'), '_keyframes_4bins');
mkdir(outputFolder);

histDiff = zeros(numFrames-1, 1);

if hasFrame(video)
%     currHistogram = imhist(rgb2gray(readFrame(video)));
    currHistogram = colorHistogram(imresize(readFrame(video), [NaN 100]), 4);
end

i = 1;
while hasFrame(video)
%     nextHistogram = imhist(rgb2gray(readFrame(video)));
    nextHistogram = colorHistogram(imresize(readFrame(video), [NaN 100]));
    histDiff(i) = sum(imabsdiff(currHistogram, nextHistogram));        %To calculate histogram difference between two frames 
    fprintf('Histogram diff calculated for frame %d-%d.\n', i, i+1);
    currHistogram = nextHistogram;
    i = i + 1;
end

%calculating mean and standard deviation
mean = mean2(histDiff);
std = std2(histDiff);
threshold = 4*std + mean;

video = VideoReader(filename);
for i = 1 : numFrames-1
    if histDiff(i) > threshold    % Greater than threshold select as a candidate frame
        filename = fullfile(outputFolder, sprintf('candidateFrame_%05d.jpg', i+1));   %Writing the keyframes
        imwrite(read(video, i+1), filename);
        fprintf('Frame %d is a candidate frame.\n', i+1);
    end
end

candidateFrames = dir(strcat(outputFolder, '/*.jpg'));
currFrame = imread(strcat(outputFolder, '/', candidateFrames(1).name));
resizedFrame = double(rgb2gray(imresize(currFrame, [9 16])));
X = resizedFrame(:);
% X = getGridDescriptors(currFrame);

for i = 1 : length(candidateFrames)-1
    nextFrame = imread(strcat(outputFolder, '/', candidateFrames(i+1).name));
    resizedFrame = double(rgb2gray(imresize(nextFrame, [9 16])));
    Y = resizedFrame(:);
%     Y = getGridDescriptors(nextFrame);
    covMat = cov(X,Y);
    sXY = covMat(1,2) / sqrt(covMat(1,1)*covMat(2,2));
    
    fprintf('Structural similarity of %s-%s is: %f\n', candidateFrames(i).name, candidateFrames(i+1).name, sXY);
    if sXY <= 0.5
        filename = fullfile(outputFolder, strcat('gray_key_', candidateFrames(i).name));
        imwrite(currFrame, filename);
        fprintf('candidateFrames %d is a key frame.\n', i);
    end
    
    currFrame = nextFrame;
    X = Y;
end