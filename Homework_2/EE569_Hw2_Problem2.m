%   EE569 Homework Problem 2 solutions
%   Author: Boyang Xiao
%   USC id: 3326730274
%   email:  boyangxi@usc.edu
%   Date:   2/6/2022

clear;
close all;
clc;

%% Problem 2 - A

% Import Image and convert to YUV space
fprintf("Part 2-A: Starting now...\n");
Row = 400;
Col = 600;
Channel = 1;

FileName1 = "bridge.raw";
OriginalData1 = readraw(FileName1, Row, Col, Channel);
figure("name", "Problem 2-a results");
try
    sgtitle("Problem 2-a: Different Half-toning results");
catch
end
subplot(2,3,1);
imshow(OriginalData1,[]);
title("original Image");

% Fixed thresholding
HTresults1 = zeros(Row, Col, Channel);
Threshold1 = 128;

for nRow = 1: Row
    for nCol = 1:Col
        if OriginalData1(nRow, nCol) >= Threshold1  HTresults1(nRow, nCol) = 255;   end
    end
end
subplot(2,3,2);
imshow(HTresults1,[]);
title("Half-tone with fixed threshold");
writeraw(HTresults1, "bridge_Halftone_fixed.raw");


% Random thresholding
HTresults2 = zeros(Row, Col, Channel);

for nRow = 1: Row
    for nCol = 1:Col
        %Treshold2 = round(abs(randn) * 255);
        Treshold2 = round(rand * 255);
        if OriginalData1(nRow, nCol) >= Treshold2  HTresults2(nRow, nCol) = 255;   end
    end
end
subplot(2,3,3);
imshow(HTresults2,[]);
title("Half-tone with random threshold");
writeraw(HTresults2, "bridge_Halftone_random.raw");

%% Dithering

% Firstly apply I2 dithering
DTresults1 = zeros(Row, Col);
IMkernal1 = [1,2;3,0];
IMthreshold1 = (IMkernal1 + 0.5) * 255 / power(2,2);

for nRow = 1: Row
    for nCol = 1:Col
        Treshold = IMthreshold1(mod(nRow, 2)+1, mod(nCol, 2)+1);
        if OriginalData1(nRow, nCol) >= Treshold  DTresults1(nRow, nCol) = 255;   end
    end
end

subplot(2,3,4);
imshow(DTresults1,[]);
title("Half-tone with DIthering I2");
writeraw(DTresults1, "bridge_Halftone_dithering2.raw");

%Apply I8 dithering
IMkernal2 = [IMkernal1*4+1 IMkernal1*4+2; IMkernal1*4+3 IMkernal1*4];
IMkernal3 = [IMkernal2*4+1 IMkernal2*4+2; IMkernal2*4+3 IMkernal2*4];

DTresults2 = zeros(Row, Col);
IMthreshold3 = (IMkernal3 + 0.5) * 255 / power(8,2);

for nRow = 1: Row
    for nCol = 1:Col
        Treshold = IMthreshold3(mod(nRow, 8)+1, mod(nCol, 8)+1);
        if OriginalData1(nRow, nCol) >= Treshold  DTresults2(nRow, nCol) = 255;   end
    end
end

subplot(2,3,5);
imshow(DTresults2,[]);
title("Half-tone with DIthering I8");
writeraw(DTresults2, "bridge_Halftone_dithering8.raw");


%Apply I32 dithering
IMkernal4 = [IMkernal3*4+1 IMkernal3*4+2; IMkernal3*4+3 IMkernal3*4];
IMkernal5 = [IMkernal4*4+1 IMkernal4*4+2; IMkernal4*4+3 IMkernal4*4];

DTresults3 = zeros(Row, Col);
IMthreshold5 = (IMkernal5 + 0.5) * 255 / power(32,2);

for nRow = 1: Row
    for nCol = 1:Col
        Treshold = IMthreshold5(mod(nRow, 32)+1, mod(nCol, 32)+1);
        if OriginalData1(nRow, nCol) >= Treshold  DTresults3(nRow, nCol) = 255;   end
    end
end

subplot(2,3,6);
imshow(DTresults2,[]);
title("Half-tone with DIthering I32");
writeraw(DTresults2, "bridge_Halftone_dithering32.raw");






