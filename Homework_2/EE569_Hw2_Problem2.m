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
fprintf("\nApplying fixed thresholding to the image...\n");
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
fprintf("\nApplying random(uniform) thresholding to the image...\n");
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

fprintf("\nApplying Dithering methods with different matrixs to the image...\n");

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
imshow(DTresults3,[]);
title("Half-tone with DIthering I32");
writeraw(DTresults3, "bridge_Halftone_dithering32.raw");

fprintf("\nThe results for Part 2-A are shown in Figure 1.\n");


%% Part 1-b Error diffusion

fprintf("\nPart 2-b starting now...\n")

Threshold = 128;

figure("name", "Problem 2-b results");
try
    sgtitle("Problem 2-b: Half-toning: Error Diffusion results");
catch
end
subplot(2,2,1);
imshow(OriginalData1,[]);
title("original Image");

%%Floyd Steinburg's matrix setup
fprintf("\nApplying Floyd Steingerg's error diffusion method to the image...\n");

EDmatrix1 = [0 0 0; 0 0 7; 3 5 1] / 16;
Ftilde1 = zeros(Row+2, Col+2);
Ftilde1(2:Row+1, 2:Col+1) = OriginalData1;

EDresults1 = zeros(Row+2, Col+2);

for nRow = 2: Row+1
    if mod(nRow, 2) == 0
        for nCol = 2:Col+1 
            if Ftilde1(nRow, nCol) >= Treshold  
                EDresults1(nRow, nCol) = 255;
            end
    
            ErrorVal = Ftilde1(nRow, nCol) - EDresults1(nRow, nCol);
            Ftilde1(nRow, nCol+1) = Ftilde1(nRow, nCol+1) + ErrorVal*EDmatrix1(2,3);
            Ftilde1(nRow+1, nCol-1) = Ftilde1(nRow+1, nCol-1) + ErrorVal*EDmatrix1(3,1);
            Ftilde1(nRow+1, nCol) = Ftilde1(nRow+1, nCol) + ErrorVal*EDmatrix1(3,2);
            Ftilde1(nRow+1, nCol+1) = Ftilde1(nRow+1, nCol+1) + ErrorVal*EDmatrix1(3,3);

        end
    else
        for nCol = Col+1 :-1:2
            if Ftilde1(nRow, nCol) >= Treshold  
                EDresults1(nRow, nCol) = 255;
            end
    
            ErrorVal = Ftilde1(nRow, nCol) - EDresults1(nRow, nCol);
            Ftilde1(nRow, nCol-1) = Ftilde1(nRow, nCol-1) + ErrorVal*EDmatrix1(2,3);
            Ftilde1(nRow+1, nCol+1) = Ftilde1(nRow+1, nCol+1) + ErrorVal*EDmatrix1(3,1);
            Ftilde1(nRow+1, nCol) = Ftilde1(nRow+1, nCol) + ErrorVal*EDmatrix1(3,2);
            Ftilde1(nRow+1, nCol-1) = Ftilde1(nRow+1, nCol-1) + ErrorVal*EDmatrix1(3,3);
        end
    end
end

EDresults1 = EDresults1(2:Row+1, 2:Col+1);
subplot(2,2,2);
imshow(EDresults1,[]);
title("Error diffusion with Floyd Steinburg matrix");
writeraw(EDresults1, "bridge_Halftone_FloydED.raw");


% JJN matrix
fprintf("\nApplying JJN's error diffusion method to the image...\n");

EDmatrix2 = [0 0 0 0 0; 0 0 0 0 0; 0 0 0 7 5; 3 5 7 5 3; 1 3 5 3 1] / 48;
Ftilde2 = zeros(Row+4, Col+4);
Ftilde2(3:Row+2, 3:Col+2) = OriginalData1;

EDresults2 = zeros(Row+4, Col+4);

for nRow = 3: Row+2
    if mod(nRow, 2) == 1
        for nCol = 3:Col+2 
            if Ftilde2(nRow, nCol) >= Treshold  
                EDresults2(nRow, nCol) = 255;
            end
    
            ErrorVal = Ftilde2(nRow, nCol) - EDresults2(nRow, nCol);

            Ftilde2(nRow, nCol+1) = Ftilde2(nRow, nCol+1) + ErrorVal*EDmatrix2(3,4);
            Ftilde2(nRow, nCol+2) = Ftilde2(nRow, nCol+2) + ErrorVal*EDmatrix2(3,5);
            Ftilde2(nRow+1, nCol-2) = Ftilde2(nRow+1, nCol-2) + ErrorVal*EDmatrix2(4,1);
            Ftilde2(nRow+1, nCol-1) = Ftilde2(nRow+1, nCol-1) + ErrorVal*EDmatrix2(4,2);
            Ftilde2(nRow+1, nCol) = Ftilde2(nRow+1, nCol) + ErrorVal*EDmatrix2(4,3);
            Ftilde2(nRow+1, nCol+1) = Ftilde2(nRow+1, nCol+1) + ErrorVal*EDmatrix2(4,4);
            Ftilde2(nRow+1, nCol+2) = Ftilde2(nRow+1, nCol+2) + ErrorVal*EDmatrix2(4,5);
            Ftilde2(nRow+2, nCol-2) = Ftilde2(nRow+2, nCol-2) + ErrorVal*EDmatrix2(5,1);
            Ftilde2(nRow+2, nCol-1) = Ftilde2(nRow+2, nCol-1) + ErrorVal*EDmatrix2(5,2);
            Ftilde2(nRow+2, nCol) = Ftilde2(nRow+2, nCol) + ErrorVal*EDmatrix2(5,3);
            Ftilde2(nRow+2, nCol+1) = Ftilde2(nRow+2, nCol+1) + ErrorVal*EDmatrix2(5,4);
            Ftilde2(nRow+2, nCol+2) = Ftilde2(nRow+2, nCol+2) + ErrorVal*EDmatrix2(5,5);

        end
    else
        for nCol = Col+2 :-1:3
            if Ftilde2(nRow, nCol) >= Treshold  
                EDresults2(nRow, nCol) = 255;
            end

            ErrorVal = Ftilde2(nRow, nCol) - EDresults2(nRow, nCol);

            Ftilde2(nRow, nCol-1) = Ftilde2(nRow, nCol-1) + ErrorVal*EDmatrix2(3,4);
            Ftilde2(nRow, nCol-2) = Ftilde2(nRow, nCol-2) + ErrorVal*EDmatrix2(3,5);
            Ftilde2(nRow+1, nCol+2) = Ftilde2(nRow+1, nCol+2) + ErrorVal*EDmatrix2(4,1);
            Ftilde2(nRow+1, nCol+1) = Ftilde2(nRow+1, nCol+1) + ErrorVal*EDmatrix2(4,2);
            Ftilde2(nRow+1, nCol) = Ftilde2(nRow+1, nCol) + ErrorVal*EDmatrix2(4,3);
            Ftilde2(nRow+1, nCol-1) = Ftilde2(nRow+1, nCol-1) + ErrorVal*EDmatrix2(4,4);
            Ftilde2(nRow+1, nCol-2) = Ftilde2(nRow+1, nCol-2) + ErrorVal*EDmatrix2(4,5);
            Ftilde2(nRow+2, nCol+2) = Ftilde2(nRow+2, nCol+2) + ErrorVal*EDmatrix2(5,1);
            Ftilde2(nRow+2, nCol+1) = Ftilde2(nRow+2, nCol+1) + ErrorVal*EDmatrix2(5,2);
            Ftilde2(nRow+2, nCol) = Ftilde2(nRow+2, nCol) + ErrorVal*EDmatrix2(5,3);
            Ftilde2(nRow+2, nCol-1) = Ftilde2(nRow+2, nCol-1) + ErrorVal*EDmatrix2(5,4);
            Ftilde2(nRow+2, nCol-2) = Ftilde2(nRow+2, nCol-2) + ErrorVal*EDmatrix2(5,5);
        end
    end
end

EDresults2 = EDresults2(3:Row+2, 3:Col+2);
subplot(2,2,3);
imshow(EDresults2,[]);
title("Error diffusion with JJN matrix");
writeraw(EDresults2, "bridge_Halftone_JJNED.raw");


% Stucki matrix
fprintf("\nApplying Stucki's error diffusion method to the image...\n");

EDmatrix2 = [0 0 0 0 0; 0 0 0 0 0; 0 0 0 8 4; 2 4 8 4 2; 1 2 4 2 1] / 42;
Ftilde2 = zeros(Row+4, Col+4);
Ftilde2(3:Row+2, 3:Col+2) = OriginalData1;

EDresults2 = zeros(Row+4, Col+4);

for nRow = 3: Row+2
    if mod(nRow, 2) == 1
        for nCol = 3:Col+2 
            if Ftilde2(nRow, nCol) >= Treshold  
                EDresults2(nRow, nCol) = 255;
            end
    
            ErrorVal = Ftilde2(nRow, nCol) - EDresults2(nRow, nCol);

            Ftilde2(nRow, nCol+1) = Ftilde2(nRow, nCol+1) + ErrorVal*EDmatrix2(3,4);
            Ftilde2(nRow, nCol+2) = Ftilde2(nRow, nCol+2) + ErrorVal*EDmatrix2(3,5);
            Ftilde2(nRow+1, nCol-2) = Ftilde2(nRow+1, nCol-2) + ErrorVal*EDmatrix2(4,1);
            Ftilde2(nRow+1, nCol-1) = Ftilde2(nRow+1, nCol-1) + ErrorVal*EDmatrix2(4,2);
            Ftilde2(nRow+1, nCol) = Ftilde2(nRow+1, nCol) + ErrorVal*EDmatrix2(4,3);
            Ftilde2(nRow+1, nCol+1) = Ftilde2(nRow+1, nCol+1) + ErrorVal*EDmatrix2(4,4);
            Ftilde2(nRow+1, nCol+2) = Ftilde2(nRow+1, nCol+2) + ErrorVal*EDmatrix2(4,5);
            Ftilde2(nRow+2, nCol-2) = Ftilde2(nRow+2, nCol-2) + ErrorVal*EDmatrix2(5,1);
            Ftilde2(nRow+2, nCol-1) = Ftilde2(nRow+2, nCol-1) + ErrorVal*EDmatrix2(5,2);
            Ftilde2(nRow+2, nCol) = Ftilde2(nRow+2, nCol) + ErrorVal*EDmatrix2(5,3);
            Ftilde2(nRow+2, nCol+1) = Ftilde2(nRow+2, nCol+1) + ErrorVal*EDmatrix2(5,4);
            Ftilde2(nRow+2, nCol+2) = Ftilde2(nRow+2, nCol+2) + ErrorVal*EDmatrix2(5,5);

        end
    else
        for nCol = Col+2 :-1: 3
            if Ftilde2(nRow, nCol) >= Treshold  
                EDresults2(nRow, nCol) = 255;
            end

            ErrorVal = Ftilde2(nRow, nCol) - EDresults2(nRow, nCol);

            Ftilde2(nRow, nCol-1) = Ftilde2(nRow, nCol-1) + ErrorVal*EDmatrix2(3,4);
            Ftilde2(nRow, nCol-2) = Ftilde2(nRow, nCol-2) + ErrorVal*EDmatrix2(3,5);
            Ftilde2(nRow+1, nCol+2) = Ftilde2(nRow+1, nCol+2) + ErrorVal*EDmatrix2(4,1);
            Ftilde2(nRow+1, nCol+1) = Ftilde2(nRow+1, nCol+1) + ErrorVal*EDmatrix2(4,2);
            Ftilde2(nRow+1, nCol) = Ftilde2(nRow+1, nCol) + ErrorVal*EDmatrix2(4,3);
            Ftilde2(nRow+1, nCol-1) = Ftilde2(nRow+1, nCol-1) + ErrorVal*EDmatrix2(4,4);
            Ftilde2(nRow+1, nCol-2) = Ftilde2(nRow+1, nCol-2) + ErrorVal*EDmatrix2(4,5);
            Ftilde2(nRow+2, nCol+2) = Ftilde2(nRow+2, nCol+2) + ErrorVal*EDmatrix2(5,1);
            Ftilde2(nRow+2, nCol+1) = Ftilde2(nRow+2, nCol+1) + ErrorVal*EDmatrix2(5,2);
            Ftilde2(nRow+2, nCol) = Ftilde2(nRow+2, nCol) + ErrorVal*EDmatrix2(5,3);
            Ftilde2(nRow+2, nCol-1) = Ftilde2(nRow+2, nCol-1) + ErrorVal*EDmatrix2(5,4);
            Ftilde2(nRow+2, nCol-2) = Ftilde2(nRow+2, nCol-2) + ErrorVal*EDmatrix2(5,5);
        end
    end
end

EDresults2 = EDresults2(3:Row+2, 3:Col+2);
subplot(2,2,4);
imshow(EDresults2,[]);
title("Error diffusion with Stucki matrix");
writeraw(EDresults2, "bridge_Halftone_StuckiED.raw");

fprintf("\nThe results for Part 2-B are shown in Figure 2.\n");

