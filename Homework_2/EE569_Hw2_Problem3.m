%   EE569 Homework Problem 3 solutions
%   Author: Boyang Xiao
%   USC id: 3326730274
%   email:  boyangxi@usc.edu
%   Date:   2/6/2022

clear;
close all;
clc;

%% Problem 3 - A

% Import Image and convert to YUV space
fprintf("Part 3-A: Starting now...\n");
Row = 375;
Col = 500;
Channel = 3;

FileName1 = "bird.raw";
OriginalData1 = readraw(FileName1, Row, Col, Channel);

%First, convert image to CMY color space
CMYData1 = zeros(Row, Col, Channel);
for i = 1:3
    CMYData1(:,:,i) = 255 - OriginalData1(:,:,i);
end

% Apply the Floyd Steinberg matrix to the CMY image 
Threshold = 128;

EDmatrix1 = [0 0 0; 0 0 7; 3 5 1] / 16;
Ftilde1 = zeros(Row+2, Col+2 , Channel);
Ftilde1(2:Row+1, 2:Col+1 , :) = CMYData1;

EDresults1 = zeros(Row+2, Col+2 , Channel);

for nChannel = 1:Channel
    for nRow = 2: Row+1
        if mod(nRow, 2) == 1
            for nCol = 2:Col+1 
                if Ftilde1(nRow, nCol, nChannel) >= Threshold  
                    EDresults1(nRow, nCol, nChannel) = 255;
                end
        
                ErrorVal = Ftilde1(nRow, nCol, nChannel) - EDresults1(nRow, nCol, nChannel);
                Ftilde1(nRow, nCol+1, nChannel) = Ftilde1(nRow, nCol+1, nChannel) + ErrorVal*EDmatrix1(2,3);
                Ftilde1(nRow+1, nCol-1, nChannel) = Ftilde1(nRow+1, nCol-1, nChannel) + ErrorVal*EDmatrix1(3,1);
                Ftilde1(nRow+1, nCol, nChannel) = Ftilde1(nRow+1, nCol, nChannel) + ErrorVal*EDmatrix1(3,2);
                Ftilde1(nRow+1, nCol+1, nChannel) = Ftilde1(nRow+1, nCol+1, nChannel) + ErrorVal*EDmatrix1(3,3);
    
            end
        else
            for nCol = Col+1 :-1:2
                if Ftilde1(nRow, nCol, nChannel) >= Threshold  
                    EDresults1(nRow, nCol, nChannel) = 255;
                end
        
                ErrorVal = Ftilde1(nRow, nCol, nChannel) - EDresults1(nRow, nCol, nChannel);
                Ftilde1(nRow, nCol-1, nChannel) = Ftilde1(nRow, nCol-1, nChannel) + ErrorVal*EDmatrix1(2,3);
                Ftilde1(nRow+1, nCol+1, nChannel) = Ftilde1(nRow+1, nCol+1, nChannel) + ErrorVal*EDmatrix1(3,1);
                Ftilde1(nRow+1, nCol, nChannel) = Ftilde1(nRow+1, nCol, nChannel) + ErrorVal*EDmatrix1(3,2);
                Ftilde1(nRow+1, nCol-1, nChannel) = Ftilde1(nRow+1, nCol-1, nChannel) + ErrorVal*EDmatrix1(3,3);
            end
        end
%         imshow(rescale(255-EDresults1));
%         pause(0.001);
    end
end

EDresults1 = EDresults1(2:Row+1, 2:Col+1,:);

HTresult1 = zeros(Row, Col, Channel);
for i = 1:3
    HTresult1(:,:,i) = 255 - EDresults1(:,:,i);
end

figure("Name","Part 3-A Color image half-toning with Floyd Steinberg Error diffusion")
imshow(rescale(HTresult1));
title("Part 3-A results: Color image half-toning with Floyd Steinberg Error diffusion");
writeraw(HTresult1, "bird_Halftone_FloydED.raw");
fprintf("Part 3-A's results are shown in Figure 1.\n")


%% Problem 3-B
fprintf("\nPart 3-B: Starting now...\n");

EDmatrix2 = [0 0 0; 0 0 7; 3 5 1] / 16;
Ftilde2 = zeros(Row+2, Col+2 , Channel);
Ftilde2(2:Row+1, 2:Col+1 , :) = OriginalData1;
OriginalDataPadding = zeros(Row+2, Col+2 , Channel);
OriginalDataPadding(2:Row+1, 2:Col+1 , :) = OriginalData1;

EDresults2 = zeros(Row+2, Col+2 , Channel);

for nRow = 2: Row+1
    if mod(nRow, 2) == 1
        for nCol = 2:Col+1 
            charMBVQ = getMBVQ(OriginalDataPadding(nRow,nCol,1),OriginalDataPadding(nRow,nCol,2),OriginalDataPadding(nRow,nCol,3));
            charColor = getNearestVertex(charMBVQ, Ftilde2(nRow,nCol,1),Ftilde2(nRow,nCol,2),Ftilde2(nRow,nCol,3));
            [EDresults2(nRow, nCol,1),EDresults2(nRow, nCol,2),EDresults2(nRow, nCol,3)] = getRGBval(charColor);
            
            for nChannel =1:Channel
                ErrorVal = Ftilde2(nRow, nCol, nChannel) - EDresults2(nRow, nCol, nChannel);
                Ftilde2(nRow, nCol+1, nChannel) = Ftilde2(nRow, nCol+1, nChannel) + ErrorVal*EDmatrix2(2,3);
                Ftilde2(nRow+1, nCol-1, nChannel) = Ftilde2(nRow+1, nCol-1, nChannel) + ErrorVal*EDmatrix2(3,1);
                Ftilde2(nRow+1, nCol, nChannel) = Ftilde2(nRow+1, nCol, nChannel) + ErrorVal*EDmatrix2(3,2);
                Ftilde2(nRow+1, nCol+1, nChannel) = Ftilde2(nRow+1, nCol+1, nChannel) + ErrorVal*EDmatrix2(3,3);
            end

        end
    else
        for nCol = Col+1 :-1:2
            charMBVQ = getMBVQ(OriginalDataPadding(nRow,nCol,1),OriginalDataPadding(nRow,nCol,2),OriginalDataPadding(nRow,nCol,3));
            charColor = getNearestVertex(charMBVQ, Ftilde2(nRow,nCol,1),Ftilde2(nRow,nCol,2),Ftilde2(nRow,nCol,3));
            [EDresults2(nRow, nCol,1),EDresults2(nRow, nCol,2),EDresults2(nRow, nCol,3)] = getRGBval(charColor);
            
            for nChannel =1:Channel
                ErrorVal = Ftilde2(nRow, nCol, nChannel) - EDresults2(nRow, nCol, nChannel);
                Ftilde2(nRow, nCol-1, nChannel) = Ftilde2(nRow, nCol-1, nChannel) + ErrorVal*EDmatrix2(2,3);
                Ftilde2(nRow+1, nCol+1, nChannel) = Ftilde2(nRow+1, nCol+1, nChannel) + ErrorVal*EDmatrix2(3,1);
                Ftilde2(nRow+1, nCol, nChannel) = Ftilde2(nRow+1, nCol, nChannel) + ErrorVal*EDmatrix2(3,2);
                Ftilde2(nRow+1, nCol-1, nChannel) = Ftilde2(nRow+1, nCol-1, nChannel) + ErrorVal*EDmatrix2(3,3);
            end
        end
    end
%         imshow(rescale(EDresults2));
%         pause(0.001);
end

HTresult2 = EDresults2(2:Row+1, 2:Col+1, :);

figure("Name","Part 3-B Color image half-toning with MBVQ Error diffusion");
title("Part 3-B results: Color image half-toning with MBVQ Error diffusion");
imshow(rescale(HTresult2));
writeraw(HTresult2, "bird_Halftone_MBVQ.raw");
fprintf("Part 3-B's results are shown in Figure 2.\n")


%extra functions used in part 3-B

function charMBVQ = getMBVQ(R,G,B)

    if (R+G)>255
        if(G+B)>255
            if(R+G+B)>510
                charMBVQ = 'CMYW';
            else
                charMBVQ = 'MYGC';
            end
        else
            charMBVQ = 'RGMY';
        end
    else
        if (G+B) <= 255
            if (R+G+B)<=255
                charMBVQ = 'KRGB';
            else
                charMBVQ = 'RGBM';
            end
        else
            charMBVQ = 'CMGB';
        end
    end

end

function [R, G, B] = getRGBval(charColor)
    
    if strcmp(charColor , 'white')
        R = 255; G = 255; B = 255;
    elseif strcmp(charColor , 'yellow')
        R = 255; G = 255; B = 0;
    elseif strcmp(charColor , 'magenta')
        R = 255; G = 0; B = 255;
    elseif strcmp(charColor , 'cyan')
        R = 0; G = 255; B = 255;
    elseif strcmp(charColor , 'red')
        R = 255; G = 0; B = 0;
    elseif strcmp(charColor , 'green')
        R = 0; G = 255; B = 0;
    elseif strcmp(charColor , 'blue')
        R = 0; G = 0; B = 255;
    else
        R = 0; G = 0; B = 0;
    end

end


