%%  TO test the db_insert() function
videoDir = 'D:\1\';
fileID = fopen([videoDir, 'tags.txt'], 'rt');
if fileID == -1
    disp('Unable to open file');
    return;
end

for i = 1 : 35
    videoURI = [videoDir, '1 (', num2str(i), ').mp4'];
    indexMap = fscanf(fileID,'%d', 4);
    indexMap = indexMap.';
    [ inserted, msg ] = db_insertVideo(videoURI, indexMap);
    disp(videoURI);
    disp(indexMap);
    disp(inserted);
    disp(msg);
end

fclose(fileID);