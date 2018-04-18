function [ inserted, msg ] = db_insertVideo( videoURI, indexMap )
%INSERTVIDEO Inserts given video into DB Framework
%   Detailed explanation goes here
    inserted = true;
    msg = 'insertVideo: ';

%%  Check DB Framework Sanity
%   DANGER: if any db file/folder is missing, it will reset whole db.
%   Make some kind of initDB() which runs only once.
    if ~db_isFrameworkStructureSane()
        db_createFrameworkStructure();
        if ~db_isFrameworkStructureSane()
            inserted = false;
            msg = [msg, 'Error in createFrameworkStructure().'];
            return;
        end
    end
    load('dbConfig.mat');

%%  Input Validation
%   Check if file extension is supported
    [pathstr,name,ext] = fileparts(videoURI);
    ext = strrep(ext, '.', '');
    disp(ext);
    if ~any(strcmp(supportedVideoFormats, ext))
        inserted = false;
        msg = [msg, videoURI, ': ', 'Unsupported File format.'];
        return;
    end

%   Check if index map is good
    indexMapLength = length(indexMap);
    if indexMapLength ~= length(indexCategories)
        inserted = false;
        msg = [msg, 'Invalid length of indexMap.'];
        return;
    end

%%  Copy video to tmpDir
    [pathstr,tmpName] = fileparts(tempname);
    tmpURI = sprintf('%s%d.%s', tmpDir, tmpName, ext);
    [inserted, message] = copyfile(videoURI, tmpURI, 'f');
    if ~inserted
        msg = [msg, videoURI, ': ', message];
        return;
    end

%%  Atomic Section: Adds/Updates records in DB files.
%   TODO: Find a way to actually make it atomic, atomicity is not possible
%   in MATLAB
%   TODO: Check if fopen puts a mutex/system_wide lock on file or not?
    fileID = fopen(videoDbCountFile, 'r+');
    if fileID == -1
        inserted = false;
        msg = [msg, videoDbCountFile, ': ', ferror(fileID)];
        return;
    end
    if fseek(fileID, 0, 'bof') == -1
        fclose(fileID);
        inserted = false;
        msg = [msg, ferror(fileID)];
        return;
    end
%   Generate new name for video a/c to DB rules
    currentVideoCount = fread(fileID, 1, headerIntType);
    newVideoName = currentVideoCount + 1;
%   Move video to videoDbDir
    newVideoURI = sprintf('%s%d.%s', videoDbDir, newVideoName, ext);
    [inserted, message] = movefile(tmpURI, newVideoURI, 'f');
    if ~inserted
        fclose(fileID);
        msg = [msg, tmpURI, ': ', message];
        return;
    end
%   Make entries for indexMap in indexDir files
    indexMapLocations = zeros(1, indexMapLength, bytePositionIntType);
    for i = 1 : indexMapLength
        thisCategoryClasses = eval(strcat(indexCategories{i}, classVariableExtension));
        if isempty(thisCategoryClasses)
            continue;
        end
        thisCategoryIndexClassFile = strcat(indexDir, indexCategories{i}, pathSeparator, thisCategoryClasses{indexMap(i)}, indexFileExtension);
        indexClassFileID = fopen(thisCategoryIndexClassFile, 'a');
        indexMapLocations(i) = ftell(indexClassFileID);
        if (indexClassFileID == -1) || (indexMapLocations(i) == -1)
            fclose(indexClassFileID);
            fclose(fileID);
            inserted = false;
            msg = [msg, thisCategoryIndexClassFile, ': ', ferror(indexClassFileID)];
            return;
        end
        fwrite(indexClassFileID, newVideoName, indexClassIntType);
        fclose(indexClassFileID);
    end
%   Make entry in videoDbIndexFile 
    [ inserted, message ] = db_addVideoDbIndex( newVideoName, ext, indexMap, indexMapLocations );
    if ~inserted
        fclose(fileID);
        msg = [msg, message];
        return;
    end
%   Update count in videoDbCountFile
%   updated only if all above operations succeed, to ensure DB consistency
    if fseek(fileID, 0, 'bof') == -1
        fclose(fileID);
        inserted = false;
        msg = [msg, ferror(fileID)];
        return;
    end
    fwrite(fileID, newVideoName, headerIntType);
    fclose(fileID);

end