function [ videoNames, found, msg ] = db_findBestMatchVideos( indexMap, numVideos, startCursors )
%DB_FINDBESTMATCHVIDEOS Finds best matching videos to indexMap in DB
%   Returns max 'numVideos' strict best matches to indexMap.
%   If there are no videos with exact tags as specified by indexMap,
%   nothing 'may' be returned.
%   startCursors is OPTIONAL argument.
%   Give 0 in indexMap, or -1 in startCursors to ignore that category in search.
%   Give 0 in startCursors to start search from beginning of that file.
%   Yet To Implement:   Mechanism to return cursors

%%  Load dbConfig
    load(db_getDbConfigFileURI());

%%  Set initial output vars
    videoNames = zeros(1, numVideos, videoNameIntType);
    found = 0; % count of total matching videos found by this algorithm
    msg = 'db_findBestMatchVideos: ';

%%  Input Validation and Sanitation
%   Check if index map is good
    indexMapLength = length(indexMap);
    if indexMapLength ~= length(indexCategories)
        msg = [msg, 'Invalid length of indexMap.'];
        return;
    end
%   Sanitize indexMap from lower bound
    indexMap(indexMap < 0) = 0;
    if ~any(indexMap)
        return;
    end

%   Check if startCursors are good
    if exist('startCursors', 'var') ~= 1
        startCursors = zeros(1, indexMapLength, bytePositionIntType);
    elseif length(startCursors) ~= indexMapLength
        msg = [msg, 'Invalid length of startCursors.'];
        return;
    end
%   Sanitize startCursors from lower bound
    for i = 1 : indexMapLength
        if startCursors(i) < -1
            startCursors(i) = -1;
        elseif (startCursors(i) >= 0) && (startCursors(i) < sizeof(headerIntType))
                startCursors(i) = sizeof(headerIntType);
        end
    end

%   Check numVideos
    if numVideos <= 0
        return;
    end

%%  Check DB Framework Sanity
    if ~db_isFrameworkStructureSane()
            msg = [msg, 'DB Framework is not sane.'];
            return;
    end

%%  Find indexClassFiles and their sizes
    indexClassFiles = cell(1, indexMapLength);
    indexClassFileSizes = zeros(1, indexMapLength);
    for i = 1 : indexMapLength
        thisCategoryClasses = eval(strcat(indexCategories{i}, classVariableExtension));
        if (indexMap(i)==0) || (indexMap(i)>length(thisCategoryClasses))
            continue;
        end
        indexClassFiles{i} = strcat(indexDir, indexCategories{i}, pathSeparator, thisCategoryClasses{indexMap(i)}, indexFileExtension);
        listing = dir(indexClassFiles{i});
        indexClassFileSizes(i) = listing.bytes;
    end
    if ~any(indexClassFileSizes)
        msg = [msg, 'All of the given index files have zero size!.'];
        return;
    end
%   sort files based on file size to decrease chances of 'nothing' being
%   returned
    [indexClassFileSizes, mappingVector] = sort(indexClassFileSizes, 2);

%%  Open indexClassFiles in sorted order of size and correctly place read pointers
    fileIDs = zeros(1, indexMapLength);
%   Follow lazy error reporting in below loop
    for i = 1 : indexMapLength
        if indexClassFileSizes(i) == 0
            fileIDs(i) = -1;
        else
            fileIDs(i) = fopen(indexClassFiles{mappingVector(i)}, 'r');
            if fileIDs(i) == -1
                msg = [msg, indexClassFiles{mappingVector(i)}, ': Unable to open file. '];
                continue;
            end
%           if unable to seek in file, pose as if it was never opened
            if fseek(fileIDs(i), startCursors(mappingVector(i)), 'bof') == -1
                msg = [msg, indexClassFiles{mappingVector(i)}, ': ', ferror(fileIDs(i)), '. '];
                fclose(fileIDs(i));
                fileIDs(i) = -1;
                continue;
            end
%             fprintf('fileIDs(%d): %d. Position: %d. Size: %d. EOF: %d\n', i, fileIDs(i), ftell(fileIDs(i)), indexClassFileSizes(i), feof(fileIDs(i)));
%           if file contains only header, pose as if it was never opened
            currBytePos = ftell(fileIDs(i));
            if (currBytePos == -1) || (currBytePos == indexClassFileSizes(i))
                msg = [msg, indexClassFiles{mappingVector(i)}, ': No videos indexed for this class. '];
                fclose(fileIDs(i));
                fileIDs(i) = -1;
            end
        end
    end
%   Check if at least one file has been opened and read pointer has been
%   placed successfully, otherwise Reporting the errors now.
    fileIDs = fileIDs(fileIDs~=-1);
    if isempty(fileIDs)
        return;
    end

%%  Find Best Matches
%   Files that are open now are guarunteed to have at least one videoName
%   in each of them.
    openFilesCount = length(fileIDs);
%   Preallocate buffer of length numVideos for all open files
    videoNamesBuffer = zeros(numVideos, openFilesCount, videoNameIntType);
%   Initial videoNamesBuffer from open files.
    for i = 1 : openFilesCount
        videoNamesBuffer(:,i) = readBufferFromFile(fileIDs(i), numVideos, videoNameIntType);
    end
    candidateVideoNames = videoNamesBuffer(1,:);
    candidateVideoNamesBufferIndex = ones(1, openFilesCount);
%   Best match algo starts here
    while (found < numVideos)
%       Find the min and max videoNames from candidateVideoNames
        minVideoName = Inf; minVideoNameFileIndex = 0;
        maxVideoName = 0;
        for i = 1 : openFilesCount
            if (candidateVideoNames(i) ~= 0) && (candidateVideoNames(i) < minVideoName)
                minVideoName = candidateVideoNames(i);
                minVideoNameFileIndex = i;
            end
            if (maxVideoName < candidateVideoNames(i))
                maxVideoName = candidateVideoNames(i);
            end
        end
%       If minVideoName == Inf, => all the candidateVideoNames=0, i.e.,
%       there is no more data in any of the files/buffer. So, we stop the
%       algorithm.
        if (minVideoName == Inf) % => maxVideoName = 0
            break;
        end
%       Check if all the candidateVideoNames are equal or not, if equal we
%       have found a best match.
        if minVideoName == maxVideoName
            found = found + 1;
            videoNames(found) = minVideoName;
%           Update all candidateVideoNames except Inf ones
            for i = 1 : openFilesCount
                if candidateVideoNames(i) ~= Inf
%                  if reached at buffer end for this file, read more names
%                  from file into buffer
                    if (candidateVideoNamesBufferIndex(i) == numVideos)
                        videoNamesBuffer(:,i) = readBufferFromFile(fileIDs(i), numVideos, videoNameIntType);
                        candidateVideoNamesBufferIndex(i) = 1;
                    else
                        candidateVideoNamesBufferIndex(i) = candidateVideoNamesBufferIndex(i) + 1;
                    end
                    candidateVideoNames(i) = videoNamesBuffer(candidateVideoNamesBufferIndex(i), i);
                end
            end
        else
            if candidateVideoNamesBufferIndex(minVideoNameFileIndex) == numVideos
                videoNamesBuffer(:,minVideoNameFileIndex) = readBufferFromFile(fileIDs(minVideoNameFileIndex), numVideos, videoNameIntType);
                candidateVideoNamesBufferIndex(minVideoNameFileIndex) = 1;
            else
                candidateVideoNamesBufferIndex(minVideoNameFileIndex) = candidateVideoNamesBufferIndex(minVideoNameFileIndex) + 1;
            end
            candidateVideoNames(minVideoNameFileIndex) = videoNamesBuffer(candidateVideoNamesBufferIndex(minVideoNameFileIndex), minVideoNameFileIndex);
        end
    end % end of while // Best match algo ends here

%%  Close all files that were opened
    for i = 1 : openFilesCount
        fclose(fileIDs(i));
    end

end % END of FUNCTION db_findBestMatchVideos


%%  START of FUNCTION readBufferFromFile
function [fileVideoNamesBuffer] = readBufferFromFile(fileID, bufferLength, valueType)
%READBUFFERFROMFILE Reads a buffer of length bufferLength from given file.
%   Returns the read buffer.
%   As deletedVideoName=0, so we don't let such videos come into buffer.
%   If ever feof is encountered, we use 0 as values to fill remaining
%   buffer length.

    fileVideoNamesBuffer = fread(fileID, bufferLength, valueType);
    fileVideoNamesBuffer = fileVideoNamesBuffer(fileVideoNamesBuffer~=0);
    while (length(fileVideoNamesBuffer) < bufferLength) && ~feof(fileID)
        temp1 = fread(fileID, bufferLength-length(fileVideoNamesBuffer), valueType);
        temp1 = temp1(temp1~=0);
        fileVideoNamesBuffer = [fileVideoNamesBuffer; temp1];
    end
    fileVideoNamesBuffer = [fileVideoNamesBuffer; zeros(bufferLength-length(fileVideoNamesBuffer), 1, valueType)];

end % END of FUNCTION readBufferFromFile