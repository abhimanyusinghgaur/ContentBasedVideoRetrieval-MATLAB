function [ histogram ] = colorHistogram( img, binsPerColor )
    if ndims(img) <= 2
        histogram = imhist(img);
        return;
    end
    
    if ~exist('binsPerColor', 'var')
        binsPerColor = 4;
    end
    
    height = size(img, 1);
    width = size(img, 2);
    binSize = 256 / binsPerColor;
    
    colorCount = zeros(binsPerColor, binsPerColor, binsPerColor);
    img(:,:,:) = idivide(img(:,:,:), binSize) + 1;
    
    for i = 1 : height
        for j = 1 : width
            colorCount(img(i,j,1), img(i,j,2), img(i,j,3)) = colorCount(img(i,j,1), img(i,j,2), img(i,j,3)) + 1;
        end
    end
    
    histogram = colorCount(:);
end