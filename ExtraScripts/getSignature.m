function signature = getSignature(L_Surface)
%   This function takes as input the L surface of 
%   the Lab colour space transformation of an image.
%   It returns the 1x128 signature vector for the image.
    sobelKernel = fspecial('sobel');
    L_Surface2dConv = conv2(double(L_Surface), double(sobelKernel));
    
    L_Surface2dConv8x8 = imresize(L_Surface2dConv, [8 8]);
    L_Surface8x8 = imresize(double(L_Surface), [8 8]);
    
    L_Surface2dConv8x8Normalized = (L_Surface2dConv8x8 - min(L_Surface2dConv8x8(:)))/(max(L_Surface2dConv8x8(:)) - min(L_Surface2dConv8x8(:)));
    L_Surface8x8Normalized = (L_Surface8x8 - min(L_Surface8x8(:)))/(max(L_Surface8x8(:)) - min(L_Surface8x8(:)));
    
    signature = horzcat(reshape(L_Surface8x8Normalized',1,64), reshape(L_Surface2dConv8x8Normalized',1,64));
end