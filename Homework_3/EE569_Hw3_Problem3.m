%   EE569 Homework3 Problem 3 solutions
%   Author: Boyang Xiao
%   USC id: 3326730274
%   email:  boyangxi@usc.edu
%   Date:   3/4/2022

clear;
close all;
clc;

%% Part1: Thinning

MaxRow1 = 247;
MaxCol1 = 247;
MaxRow2 = 252;
MaxCol2 = 252;
MaxChannel = 1;

OriginalImage1 = readraw("flower.raw", MaxRow1, MaxCol1, MaxChannel);
OriginalImage2 = readraw("jar.raw", MaxRow2, MaxCol2, MaxChannel);
OriginalImage3 = readraw("spring.raw", MaxRow2, MaxCol2, MaxChannel);

%Binarize the input images
for row = 1:MaxRow1
    for col = 1:MaxCol1
        if OriginalImage1(row, col) >= 255/2
            OriginalImage1(row, col) = 255;
        else
            OriginalImage1(row, col) = 0;
        end
    end
end

for row = 1:MaxRow2
    for col = 1:MaxCol2
        if OriginalImage2(row, col) >= 255/2
            OriginalImage2(row, col) = 255;
        else
            OriginalImage2(row, col) = 0;
        end
        if OriginalImage3(row, col) >= 255/2
            OriginalImage3(row, col) = 255;
        else
            OriginalImage3(row, col) = 0;
        end
    end
end

% Apply the thining operation

OutputImage1 = OriginalImage3;
flag = false;

figure;
nCount = 1;
while 1
    [OutputImage1, flag] = thinning(OutputImage1);
    imshow(OutputImage1, []);
    disp("Thinning iteration: "+nCount);
    nCount = nCount +1;
    if flag == false
        break
    end
end

% OutputImage1 = bwmorph(OriginalImage2/255, 'thin', 50);
% imshow(OutputImage1, []);










