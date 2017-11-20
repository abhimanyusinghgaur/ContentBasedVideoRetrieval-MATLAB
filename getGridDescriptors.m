function gdFeatureVector = getGridDescriptors( inputImgRGB )
%GETGRIDDESCRIPTORS Summary of this function goes here
%   Detailed explanation goes here
    gridWidth = 50;
    gridHeight = 50;
    cellWidth = 10;
    cellHeight = 10;
    
    numHorizontalCells = gridWidth / cellWidth;
    numVerticalCells = gridHeight / cellHeight;
    numCells = numHorizontalCells * numVerticalCells;
    numPixelsPerCell = cellWidth * cellHeight;
    
    inputImgRGB = imresize(inputImgRGB, [ gridHeight, gridWidth ]);
    
%     gdFeatureVector1 = zeros(numVerticalCells, numHorizontalCells, 3, 'uint8');
    gdFeatureVector = zeros(1, numVerticalCells*numHorizontalCells*3);
    
    for k = 1 : numVerticalCells
        cellStartRow = (k - 1) * cellHeight + 1;
        cellEndRow = k * cellHeight;
        for l = 1 : numHorizontalCells
            cellStartCol = (l - 1) * cellWidth + 1;
            cellEndCol = l * cellWidth;
%             gdFeatureVector1( k, l, 1 ) = sum(sum(inputImgRGB(cellStartRow:cellEndRow,cellStartCol:cellEndCol,1))) / numPixelsPerCell;
%             gdFeatureVector1( k, l, 2 ) = sum(sum(inputImgRGB(cellStartRow:cellEndRow,cellStartCol:cellEndCol,2))) / numPixelsPerCell;
%             gdFeatureVector1( k, l, 3 ) = sum(sum(inputImgRGB(cellStartRow:cellEndRow,cellStartCol:cellEndCol,3))) / numPixelsPerCell;
            gdFeatureVector( (k-1) * numHorizontalCells + l ) = sum(sum(inputImgRGB(cellStartRow:cellEndRow,cellStartCol:cellEndCol,1))) / numPixelsPerCell;
            gdFeatureVector( numCells +  (k-1) * numHorizontalCells + l ) = sum(sum(inputImgRGB(cellStartRow:cellEndRow,cellStartCol:cellEndCol,2))) / numPixelsPerCell;
            gdFeatureVector( 2 * numCells + (k-1) * numHorizontalCells + l ) = sum(sum(inputImgRGB(cellStartRow:cellEndRow,cellStartCol:cellEndCol,3))) / numPixelsPerCell;
        end
    end
    
%     figure;
%     imshow(gdFeatureVector1);

end

