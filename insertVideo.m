function [ inserted, msg ] = insertVideo( videoURI, indexMap )
%INSERTVIDEO Inserts given video into Framework DB
%   Detailed explanation goes here
    inserted = true;
    msg = 'insertVideo: ';
    
    if ~isFrameworkStructureSane()
        createFrameworkStructure();
        if ~isFrameworkStructureSane()
            inserted = false;
            msg = 'Error in createFrameworkStructure().';
            return;
        end
    end
    load('metadata.mat');
    
%%   chceck if file extension is supported.
    [pathstr,name,ext] = fileparts(videoURI);
    ext = strrep(ext, '.', '');
    disp(ext);
    if ~any(strcmp(supportedVideoFormats, ext))
        inserted = false;
        msg = strcat(msg, 'Unsupported File format.');
        return;
    end
    
%%   copy video to videoDbDir
%   need to combine the two fopens in this and below section alongwith a
%   mutex lock to ensure no other process is writing to the
%   videoDbCountFile before this process can update it.
    fileID = fopen(videoDbCountFile, 'r');
    if fileID == -1
        inserted = false;
        msg = strcat(msg, ferror(fileID));
        return;
    end
    currentVideoCount = fread(fileID, 1, intSize);
    fclose(fileID);
    newVideoCount = currentVideoCount + 1;
    newVideoURI = sprintf('%s%d.%s', videoDbDir, newVideoCount, ext);
    disp(newVideoURI);
    [status, message] = copyfile(videoURI, newVideoURI, 'f');
    if ~status
        inserted = false;
        msg = message;
        return;
    end
    
%%   make entries in videoDbIndexFile and videoDbCountFile
    fileID = fopen(videoDbCountFile, 'w');
    if fileID == -1
        inserted = false;
        msg = strcat(msg, ferror(fileID));
        return;
    end
    [ inserted, message ] = addVideoDbIndex( newVideoCount, ext, indexMap );
    if ~inserted
        fclose(fileID);
        msg = strcat(msg, message);
        return;
    end
%   write newVideoCount only if addVideoDbIndex() succeeds
    fwrite(fileID, newVideoCount, intSize);
    fclose(fileID);
    
%%   make entries for indexMap in indexDir files
    

end