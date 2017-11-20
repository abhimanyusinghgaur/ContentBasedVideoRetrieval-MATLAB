function [ totalPNGs ] = getTotalPNGs( dirName )
%GETTOTALPNGS Summary of this function goes here
%   Detailed explanation goes here

    totalPNGs = 0;

    dirData = dir(dirName);     %# Get the data for the current directory
    dirIndex = [dirData.isdir]; %# Find the index for directories
    
    subDirs = {dirData(dirIndex).name}; %# Get a list of the subdirectories
    validIndex = ~ismember(subDirs,{'.','..'}); %# Find index of subdirectories that are not '.' or '..'
    
    for iDir = find(validIndex)                  %# Loop over valid subdirectories
        totalPNGs = totalPNGs + length(dir(sprintf('%s/%s/*.png', dirName, iDir)));
    end

end

