function [ sportCategory ] = getSport( binaryLogoMask )
%GETSPORT Summary of this function goes here
%   Detailed explanation goes here
    topSum = sum(sum(binaryLogoMask(:,:,1)));
    bottomSum = sum(sum(binaryLogoMask(:,:,3)));
    threshold = 500;

    if ( topSum > threshold ) || ( bottomSum > threshold )
        if topSum > bottomSum
            sportCategory = 'Football';
        else
            sportCategory = 'Cricket';
        end
    else
        sportCategory = 'None';
    end

end