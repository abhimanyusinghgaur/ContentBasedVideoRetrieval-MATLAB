allLogoDir = 'logos';
logoClasses = 5;

logoClassNames      = {'DD Sports', 'ESPN', 'Sony Six Old', 'Star Sports New', 'Ten Sports'};
% classLabels       = [      1    ,    2  ,        3      ,          4       ,       5     ];
expectedLogoCorners = [      2,        4,          2,                2,              2     ];

totalObservations = getTotalPNGs(allLogoDir);
featureVectorSize = 75;
trainingData = zeros(totalObservations, featureVectorSize);
trainingLabels = zeros(totalObservations, 1);

k = 1;
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

classificationMdlSVM = fitcecoc(trainingData, trainingLabels);
% saveCompactModel(Mdl, 'LogoModelECOC');
save('LogoModelRealData.mat', 'classificationMdlSVM', 'logoClassNames', 'expectedLogoCorners');

% img = imread('Sony_SIX_old.svg.png');
% getGridDescriptors(img);
% img = imread('DD_Sports.png');
% getGridDescriptors(img);
% img = imread('espn-red_50.png');
% getGridDescriptors(img);
% img = imread('STAR_Sports_Logo_New.jpg');
% getGridDescriptors(img);
% img = imread('Ten_Sports_logo.png');
% getGridDescriptors(img);