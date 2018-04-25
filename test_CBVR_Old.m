testDataDir = 'TestData';
testFiles = dir(sprintf('%s/*.*4', testDataDir));
numFiles = length(testFiles);

for j = 1 : numFiles
    filename = sprintf('%s/%s', testDataDir, testFiles(j).name);
%     fprintf('Filename: %s\n',filename);
    CBVR_Old;
end