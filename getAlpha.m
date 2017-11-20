function [ alpha ] = getAlpha( i )
%ALPHA Summary of this function goes here
%   Detailed explanation goes here
    nRef = 20;
    
    if i <= nRef
        alpha = (i - 1) / i;
    else
        alpha = (nRef - 1) / nRef;
    end

end

