function [ output ] = satisfyShapeConstraints( conncomp, cornerNumber, cornerHeight, cornerWidth )
%CHECKSHAPECONSTRAINTS Summary of this function goes here
%   Detailed explanation goes here
    output = true;

    x = conncomp.BoundingBox(1,1);
    y = conncomp.BoundingBox(1,2);
    width = conncomp.BoundingBox(1,3);
    height = conncomp.BoundingBox(1,4);
    
% boundary distance check
    minRequiredHorizontalGap = 5;
    minRequiredVerticalGap = 5;
    horizontalGap = 0;
    verticalGap = 0;
    switch cornerNumber
        case 1
            horizontalGap = x;
            verticalGap = y;
        case 2
            horizontalGap = cornerWidth - (x + width);
            verticalGap = y;
        case 3
            horizontalGap = x;
            verticalGap = cornerHeight - (y + height);
        case 4
            horizontalGap = cornerWidth - (x + width);
            verticalGap = cornerHeight - (y + height);
    end
    output = ~( (horizontalGap <= minRequiredHorizontalGap) || (verticalGap <= minRequiredVerticalGap) );
    if ~output
        return
    end
    disp('Boundary distance satisfied.');
    
% aspect ratio check
    minAspectRatio = 0.5;
    maxAspectRatio = 5.5;
    aspectRatio = width / height;
    output  = (minAspectRatio <= aspectRatio) && (aspectRatio <= maxAspectRatio);
    if ~output
        return
    end
    disp('Aspect Ratio satisfied.');

% area ratio check
    minAreaRatio = 0.09;
    maxAreaRatio = 0.5;
    cornerArea = cornerWidth * cornerHeight;
    areaRatio = conncomp.Area / cornerArea;
    fprintf('AreaRatio = %f\n',areaRatio);
    output = (minAreaRatio <= areaRatio) && (areaRatio <= maxAreaRatio);
    if output
        disp('AreaRatio satisfied.');
    end

end

