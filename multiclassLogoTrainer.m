% The directory where all the TV channel logos have been stored.
% Create sub-directories within this directory to store logo for each
% distinct logo class. Name sub-directories as 1, 2, 3, 4, ...
allLogoDir = 'logos';
% This is the file where the generated SVM model will be saved.
svmModelFileURI = 'LogoModelRealDataWithOriginal.mat';

%%  Load variables from dbConfig
dbConfigFile = db_getDbConfigFileURI();
if exist(dbConfigFile, 'file') ~= 2
    db_generateConfig();
end
load(dbConfigFile, 'tvChannelClasses', 'expectedLogoCorners');

%%  Set initial variables
totalObservations = getTotalPNGs(allLogoDir);
featureVectorSize = 75;
trainingData = zeros(totalObservations, featureVectorSize);
trainingLabels = zeros(totalObservations, 1);

%%  Extract features from logo files for each logo class
k = 1;
logoClasses = length(tvChannelClasses);
for i = 1 : logoClasses
    thisClassLogoFiles = dir(sprintf('%s/%d/*.png', allLogoDir, i));
    numFiles = length(thisClassLogoFiles);
    for j = 1 : numFiles
        thisFilename = sprintf('%s/%d/%s', allLogoDir, i, thisClassLogoFiles(j).name);
        img = imread(thisFilename);
        featureVector = getGridDescriptors(img);
        trainingData(k,:) = featureVector(:);
        trainingLabels(k) = i;
        k = k + 1;
    end
end

%%  Train SVM model
classificationMdlSVM = fitcecoc(trainingData, trainingLabels);

%%  Save the SVM model with related variables
% saveCompactModel(Mdl, 'LogoModelECOC');
save(svmModelFileURI, 'classificationMdlSVM', 'tvChannelClasses', 'expectedLogoCorners');