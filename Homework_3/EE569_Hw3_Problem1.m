%   EE569 Homework Problem 3 solutions
%   Author: Boyang Xiao
%   USC id: 3326730274
%   email:  boyangxi@usc.edu
%   Date:   3/4/2022

clear;
close all;
clc;

%% Normal Image to Star Image

MaxRow = 328;
MaxCol = 328;
MaxChannel = 3;

% Coordinates transfer

CoordiatesMatrix = [ 0 1 -164; -1 0 164; 0 0 1 ];

PosMatrix = zeros(MaxRow, MaxCol, 2);

for row = 1:MaxRow
    for col = 1:MaxCol
        tempMat = [row; col; 1];
        tempOut = CoordiatesMatrix * tempMat;
        PosMatrix(row, col, 1:2) = tempOut(1:2);
    end
end

% Work out the warping matrix

BeforePts = [0 0; 82 82; 164 164; 0 164; -164 164; -82 82];
AfterPts = [0 0; 82 82; 164 164; 0 100; -164 164; -82 82];
InterPts = zeros(6,6);
for n = 1:6
    x = BeforePts(n, 1);
    y = BeforePts(n, 2);
    InterPts(1, n) = 1; InterPts(2, n) = x; InterPts(3, n) = y;
    InterPts(4, n) = x*x; InterPts(5, n) = x*y;InterPts(6, n) = y*y;
end
WarpMatrix1 = transpose(AfterPts)/InterPts;

BeforePts = [0 0; 82 -82; 164 -164; 164 0; 164 164; 82 82];
AfterPts = [0 0; 82 -82; 164 -164; 100 0; 164 164; 82 82];
for n = 1:6
    x = BeforePts(n, 1);
    y = BeforePts(n, 2);
    InterPts(1, n) = 1; InterPts(2, n) = x; InterPts(3, n) = y;
    InterPts(4, n) = x*x; InterPts(5, n) = x*y;InterPts(6, n) = y*y;
end
WarpMatrix2 = transpose(AfterPts)/InterPts;

BeforePts = [0 0; -82 -82; -164 -164; 0 -164; 164 -164; 82 -82];
AfterPts = [0 0; -82 -82; -164 -164; 0 -100; 164 -164; 82 -82];
for n = 1:6
    x = BeforePts(n, 1);
    y = BeforePts(n, 2);
    InterPts(1, n) = 1; InterPts(2, n) = x; InterPts(3, n) = y;
    InterPts(4, n) = x*x; InterPts(5, n) = x*y;InterPts(6, n) = y*y;
end
WarpMatrix3 = transpose(AfterPts)/InterPts;

BeforePts = [0 0; -82 82; -164 164; -164 0; -164 -164; -82 -82];
AfterPts = [0 0; -82 82; -164 164; -100 0; -164 -164; -82 -82];
for n = 1:6
    x = BeforePts(n, 1);
    y = BeforePts(n, 2);
    InterPts(1, n) = 1; InterPts(2, n) = x; InterPts(3, n) = y;
    InterPts(4, n) = x*x; InterPts(5, n) = x*y;InterPts(6, n) = y*y;
end
WarpMatrix4 = transpose(AfterPts)/InterPts;


% Apply the warping matrics to the Position matrix

for row = 1:MaxRow
    for col = 1:MaxCol
        x = PosMatrix(row, col, 1);
        y = PosMatrix(row, col, 2);
        InterPts = zeros(6,1);
        InterPts(1) = 1; InterPts(2) = x; InterPts(3) = y;
        InterPts(4) = x*x; InterPts(5) = x*y;InterPts(6) = y*y;
        AfterPts = zeros(2,1);
        
        if y >= x && y >=(-x)
            AfterPts = WarpMatrix1 * InterPts;
        elseif y <x && y >= (-x)
            AfterPts = WarpMatrix2 * InterPts;
        elseif y <x && y < (-x)
            AfterPts = WarpMatrix3 * InterPts;
        else
            AfterPts = WarpMatrix4 * InterPts;
        end
       
        PosMatrix(row, col, 1) = AfterPts(1);
        PosMatrix(row, col, 2) = AfterPts(2);

    end
end


% Apply the reverse coordianats transfer

for row = 1:MaxRow
    for col = 1:MaxCol
        x = PosMatrix(row, col, 1);
        y = PosMatrix(row, col, 2);
        BeforePts = [x; y; 1];
        InterPts = zeros(6,1);
        InterPts(1) = 1; InterPts(2) = x; InterPts(3) = y;
        InterPts(4) = x*x; InterPts(5) = x*y;InterPts(6) = y*y;
        AfterPts = CoordiatesMatrix \ BeforePts;
       
        PosMatrix(row, col, 1) = AfterPts(1);
        PosMatrix(row, col, 2) = AfterPts(2);

    end
end

% Render output image

OriginData1 = readraw('Forky.raw', MaxRow, MaxCol, MaxChannel);
OutputData1 = zeros(MaxRow,MaxCol, MaxChannel);

for row = 1:MaxRow
    for col = 1:MaxCol
        for channel = 1: MaxChannel
            OutputData1(round(PosMatrix(row, col, 1)), round(PosMatrix(row,col,2)), channel) = OriginData1(row, col, channel);
        end
    end
end

OriginData2 = readraw('22.raw', MaxRow, MaxCol, MaxChannel);
OutputData2 = zeros(MaxRow,MaxCol, MaxChannel);

for row = 1:MaxRow
    for col = 1:MaxCol
        for channel = 1: MaxChannel
            OutputData2(round(PosMatrix(row, col, 1)), round(PosMatrix(row,col,2)), channel) = OriginData2(row, col, channel);
        end
    end
end

figure("name", "Forky_StarShape");
imshow(rescale(OutputData1));
figure("name", "22_StarShape");
imshow(rescale(OutputData2));

writeraw(OutputData1, "Forky_StarShape.raw");
writeraw(OutputData2, "22_StarShape.raw");


%% Star Image back to normal image

OriginData1 = OutputData1;
OriginData2 = OutputData2;

% Coordinates transfer

CoordiatesMatrix = [ 0 1 -164; -1 0 164; 0 0 1 ];

PosMatrix = zeros(MaxRow, MaxCol, 2);

for row = 1:MaxRow
    for col = 1:MaxCol
        tempMat = [row; col; 1];
        tempOut = CoordiatesMatrix * tempMat;
        PosMatrix(row, col, 1:2) = tempOut(1:2);
    end
end

% Work out the warping matrix

AfterPts = [0 0; 82 82; 164 164; 0 164; -164 164; -82 82];
BeforePts = [0 0; 82 82; 164 164; 0 100; -164 164; -82 82];
InterPts = zeros(6,6);
for n = 1:6
    x = BeforePts(n, 1);
    y = BeforePts(n, 2);
    InterPts(1, n) = 1; InterPts(2, n) = x; InterPts(3, n) = y;
    InterPts(4, n) = x*x; InterPts(5, n) = x*y;InterPts(6, n) = y*y;
end
WarpMatrix1 = transpose(AfterPts)/InterPts;

AfterPts = [0 0; 82 -82; 164 -164; 164 0; 164 164; 82 82];
BeforePts = [0 0; 82 -82; 164 -164; 100 0; 164 164; 82 82];
for n = 1:6
    x = BeforePts(n, 1);
    y = BeforePts(n, 2);
    InterPts(1, n) = 1; InterPts(2, n) = x; InterPts(3, n) = y;
    InterPts(4, n) = x*x; InterPts(5, n) = x*y;InterPts(6, n) = y*y;
end
WarpMatrix2 = transpose(AfterPts)/InterPts;

AfterPts = [0 0; -82 -82; -164 -164; 0 -164; 164 -164; 82 -82];
BeforePts = [0 0; -82 -82; -164 -164; 0 -100; 164 -164; 82 -82];
for n = 1:6
    x = BeforePts(n, 1);
    y = BeforePts(n, 2);
    InterPts(1, n) = 1; InterPts(2, n) = x; InterPts(3, n) = y;
    InterPts(4, n) = x*x; InterPts(5, n) = x*y;InterPts(6, n) = y*y;
end
WarpMatrix3 = transpose(AfterPts)/InterPts;

AfterPts = [0 0; -82 82; -164 164; -164 0; -164 -164; -82 -82];
BeforePts = [0 0; -82 82; -164 164; -100 0; -164 -164; -82 -82];
for n = 1:6
    x = BeforePts(n, 1);
    y = BeforePts(n, 2);
    InterPts(1, n) = 1; InterPts(2, n) = x; InterPts(3, n) = y;
    InterPts(4, n) = x*x; InterPts(5, n) = x*y;InterPts(6, n) = y*y;
end
WarpMatrix4 = transpose(AfterPts)/InterPts;


% Apply the warping matrics to the Position matrix

for row = 1:MaxRow
    for col = 1:MaxCol
        x = PosMatrix(row, col, 1);
        y = PosMatrix(row, col, 2);
        InterPts = zeros(6,1);
        InterPts(1) = 1; InterPts(2) = x; InterPts(3) = y;
        InterPts(4) = x*x; InterPts(5) = x*y;InterPts(6) = y*y;
        AfterPts = zeros(2,1);
        
        if y >= x && y >=(-x)
            AfterPts = WarpMatrix1 * InterPts;
        elseif y <x && y >= (-x)
            AfterPts = WarpMatrix2 * InterPts;
        elseif y <x && y < (-x)
            AfterPts = WarpMatrix3 * InterPts;
        else
            AfterPts = WarpMatrix4 * InterPts;
        end
       
        PosMatrix(row, col, 1) = AfterPts(1);
        PosMatrix(row, col, 2) = AfterPts(2);

    end
end


% Apply the reverse coordianats transfer

for row = 1:MaxRow
    for col = 1:MaxCol
        x = PosMatrix(row, col, 1);
        y = PosMatrix(row, col, 2);
        BeforePts = [x; y; 1];
        InterPts = zeros(6,1);
        InterPts(1) = 1; InterPts(2) = x; InterPts(3) = y;
        InterPts(4) = x*x; InterPts(5) = x*y;InterPts(6) = y*y;
        AfterPts = CoordiatesMatrix \ BeforePts;
       
        PosMatrix(row, col, 1) = AfterPts(1);
        PosMatrix(row, col, 2) = AfterPts(2);

    end
end

% Render output image

OutputData1 = zeros(MaxRow,MaxCol, MaxChannel);
OutputData2 = zeros(MaxRow,MaxCol, MaxChannel);

h = waitbar(0, 'Rendering output images');

for row = 1:MaxRow
    for col = 1:MaxCol
        for channel = 1: MaxChannel
            startRow = 1;
            startCol = 1;
            for pRow = startRow:MaxRow-1
                for pCol = startCol:MaxCol-1
                    if row >= PosMatrix(pRow, pCol, 1) && row<= PosMatrix(pRow+1,pCol,1) && col >= PosMatrix(pRow, pCol, 2) && col<= PosMatrix(pRow,pCol+1,2)
                        OutputData1(row,col,channel) = mean([OriginData1(pRow, pCol, channel) OriginData1(pRow+1, pCol, channel) OriginData1(pRow, pCol+1, channel) OriginData1(pRow+1, pCol+1, channel)]);
                        OutputData2(row,col,channel) = mean([OriginData2(pRow, pCol, channel) OriginData2(pRow+1, pCol, channel) OriginData2(pRow, pCol+1, channel) OriginData2(pRow+1, pCol+1, channel)]);
                        startRow = pRow;
                        startCol = pCol;
                    end
                end
            end
        end
    end
    waitbar(row/MaxRow, h);
end 

delete(h);

figure("name", "Forky_Restore");
imshow(rescale(OutputData1));
figure("name", "22_Restore");
imshow(rescale(OutputData2));

writeraw(OutputData1, "Forky_reversed.raw");
writeraw(OutputData2, "22_reversed.raw");
