function [ output_args ] = TextDetectorLaplacian( inputImgPath )
%LAPLACIANTEXTDETECTOR from "A Laplacian Method for Video Text Detection"
%   by
%   Trung Quy Phan, Palaiahnakote Shivakumara and Chew Lim Tan
%   School of Computing, National University of Singapore
%   WARNING: Not Fully Implemented

%% 2.1 Text Detection
inputImg = imread(inputImgPath);
grayscaleImg = rgb2gray(inputImg);
height = size(grayscaleImg, 1);
width = size(grayscaleImg, 2);
zeroAppendedGrayscaleImg = zeros(height+2, width+2);
zeroAppendedGrayscaleImg(2:height+1, 2:width+1) = grayscaleImg;
% laplacianMask = [1 1 1; 1 -8 1; 1 1 1];
filteredImage = zeros(height, width, 'int16');
% Applying above laplacian mask, tricky way
for i = 1 : height
    for j = 1 : width
        filteredImage(i, j) = filteredImage(i, j) + sum(sum(zeroAppendedGrayscaleImg(i:i+2,j:j+2))) - 9*zeroAppendedGrayscaleImg(i+1, j+1);
    end
end
% filteredImage = imfilter(grayscaleImg, laplacianMask);
figure; imshow(inputImg); disp(inputImg);
figure; imshow(grayscaleImg); disp(grayscaleImg);
figure; imshow(filteredImage); disp(filteredImage);

end

