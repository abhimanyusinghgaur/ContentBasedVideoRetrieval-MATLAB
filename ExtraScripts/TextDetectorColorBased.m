function [ output_args ] = TextDetectorColorBased( inputImgPath )
%TEXTDETECTORCOLORBASED Summary of this function goes here
%   Own method to try to find text regions in inputImg
%   Based on assumption that caption text in sport videos is always white
%   or black. Can be safely changed to consider top and bottom 10%
%   intensities from the img.

inputImg = imread(inputImgPath);
grayscaleImg = rgb2gray(inputImg);

% portion of 32-32 colors from top & bottom
whiteTextImg = im2bw(grayscaleImg, 223.0/255);
blackTextImg = imcomplement(im2bw(grayscaleImg, 31.0/255));

figure; imshow(inputImg);
figure; imshow(grayscaleImg);
figure; imshow(whiteTextImg);
figure; imshow(blackTextImg);

whiteText = ocr(whiteTextImg);
blackText = ocr(blackTextImg);

disp('whiteText:');
disp(whiteText);
fields = fieldnames(whiteText);
for i = 1:numel(fields)
  disp(whiteText.(fields{i}));
end

disp('blackText:');
disp(blackText);
fields = fieldnames(blackText);
for i = 1:numel(fields)
  disp(blackText.(fields{i}));
end

disp('whiteText character wise:');
CC = bwconncomp(whiteTextImg);
stats = regionprops(CC, 'BoundingBox');
for i = 1 : size(stats,1)
    char = ocr(whiteTextImg, stats(i).BoundingBox);
    disp(stats(i).BoundingBox);
    disp(char);
end

disp('blackText character wise:');
CC = bwconncomp(blackTextImg);
stats = regionprops(CC, 'BoundingBox');
for i = 1 : size(stats,1)
    char = ocr(blackTextImg, stats(i).BoundingBox);
    disp(stats(i).BoundingBox);
    disp(char);
end

end

