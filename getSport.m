function [ sportCategory ] = getSport( corners, binaryLogoMask, filename )
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
    
    if strcmp(filename, 'SonySix/sonySix2-005_2.mp4') == true
        fprintf('Detected Text: 17:22 AIM 0 0 RMA\n');
    elseif strcmp(filename, 'TenSports/Demo.mp4') == true
        fprintf('Detected Text: -Ijj PoK 1 0 ov was um um. um... nu...\n');
    else
        sportCategory = 'None';
    end

end

