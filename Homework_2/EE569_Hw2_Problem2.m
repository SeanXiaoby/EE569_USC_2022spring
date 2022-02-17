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
subplot(2,2,1);
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
subplot(2,2,2);
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
subplot(2,2,3);
imshow(HTresults2,[]);
title("Half-tone with random threshold");
writeraw(HTresults2, "bridge_Halftone_random.raw");

% Dithering














