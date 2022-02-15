%   EE569 Homework Problem 1 solutions
%   Author: Boyang Xiao
%   USC id: 3326730274
%   email:  boyangxi@usc.edu
%   Date:   2/6/2022

clear;
close all;
clc;

%% Problem 1 - A

% Import Image and convert to YUV space
fprintf("Part 1-A: Starting now...\n");
Row = 321;
Col = 481;
Channel = 3;

% prompt = "Enter the first File name to be processed in Problem 1(a) and (b):";
% FileName1 = input(prompt,"s");
% if false == contains(FileName1, ".raw")
%     FileName1 = FileName1 + ".raw";
% end
FileName1 = "Tiger.raw";
OriginalData1 = readraw(FileName1, Row, Col, Channel);

% prompt = "Enter the first File name to be processed in Problem 1(a) and (b):";
% FileName2 = input(prompt,"s");
% if false == contains(FileName2, ".raw")
%     FileName2 = FileName2 + ".raw";
% end
FileName2 = "Pig.raw";
OriginalData2 = readraw(FileName2, Row, Col, Channel);

OriData1_YUV = RGBxYUV(OriginalData1,3);
OriData2_YUV = RGBxYUV(OriginalData2,3);

%For Image 1
disp("Now conducting Sobel Edge detection for "+FileName1+"...");
%Get X and Y gradient map
GradData1_X = zeros(Row, Col, 1);
GradData1_Y = zeros(Row, Col, 1);
for nRow = 1:Row
    for nCol = 1:Col
        Up = nRow -1;
        if Up <= 0
            Up = nRow +1;
        end
        Down = nRow +1;
        if Down > Row
            Down = nRow -1;
        end
        Left = nCol -1;
        if Left <= 0
            Left = nCol +1;
        end
        Right = nCol +1;
        if Right > Col
            Right = nCol -1;
        end
        
        GradData1_X(nRow,nCol,1) = OriData1_YUV(Up, Right) + 2*OriData1_YUV(nRow, Right) + OriData1_YUV(Down, Right) - OriData1_YUV(Up, Left) - 2*OriData1_YUV(nRow, Left) - OriData1_YUV(Down, Left);
        GradData1_Y(nRow,nCol,1) = OriData1_YUV(Up, Left) + 2*OriData1_YUV(Up, nCol) + OriData1_YUV(Up, Right) - OriData1_YUV(Down, Left) - 2*OriData1_YUV(Down, nCol) - OriData1_YUV(Down, Right);

    end
end

GradData1_X = NormalizeImage(GradData1_X, 0, 255);
GradData1_Y = NormalizeImage(GradData1_Y, 0, 255);

figure("name", "Problem 1-a resutls: For Image: "+FileName1);
try
    sgtitle("Problem 1-a resutls: For Image: "+FileName1);
catch
end
subplot(2,2,1);
imshow(GradData1_X,[]);
title('X gradient map for Image: ' + FileName1);
subplot(2,2,2)
imshow(GradData1_Y,[]);
title('Y gradient map for Image: ' + FileName1);

GradData1 = sqrt(power(GradData1_X,2) + power(GradData1_Y,2));
GradData1 = NormalizeImage(GradData1, 0, 255);
subplot(2,2,3);
imshow(GradData1,[]);
title('Magnititude map for Image: ' + FileName1);

%Get Magnitude map and the final binary map
ThresHold1 = max(max(GradData1)) * 0.609;
ResultData1 = zeros(Row, Col, 1);
for nRow = 1:Row
    for nCol = 1:Col
        if GradData1(nRow, nCol) >= ThresHold1
            ResultData1(nRow, nCol) = 255;
        end
    end
end

subplot(2,2,4);
imshow(ResultData1,[]);
title('Sobel Edge Detection result for Image: ' + FileName1);

writeraw(ResultData1, extractBefore(FileName1, ".raw")+"_SobelEdge.raw");

% For Image 2
disp("Now conducting Sobel Edge detection for "+FileName2+"...");
%Get X and Y gradient map

GradData2_X = zeros(Row, Col, 1);
GradData2_Y = zeros(Row, Col, 1);
for nRow = 1:Row
    for nCol = 1:Col
        Up = nRow -1;
        if Up <= 0
            Up = nRow +1;
        end
        Down = nRow +1;
        if Down > Row
            Down = nRow -1;
        end
        Left = nCol -1;
        if Left <= 0
            Left = nCol +1;
        end
        Right = nCol +1;
        if Right > Col
            Right = nCol -1;
        end
        
        GradData2_X(nRow,nCol,1) = OriData2_YUV(Up, Right) + 2*OriData2_YUV(nRow, Right) + OriData2_YUV(Down, Right) - OriData2_YUV(Up, Left) - 2*OriData2_YUV(nRow, Left) - OriData2_YUV(Down, Left);
        GradData2_Y(nRow,nCol,1) = OriData2_YUV(Up, Left) + 2*OriData2_YUV(Up, nCol) + OriData2_YUV(Up, Right) - OriData2_YUV(Down, Left) - 2*OriData2_YUV(Down, nCol) - OriData2_YUV(Down, Right);

    end
end

GradData2_X = NormalizeImage(GradData2_X, 0, 255);
GradData2_Y = NormalizeImage(GradData2_Y, 0, 255);

figure("name", "Problem 1-a resutls: For Image: "+FileName2);
try
    sgtitle("Problem 1-a resutls: For Image: "+FileName2);
catch
end
subplot(2,2,1);
imshow(GradData2_X,[]);
title('X gradient map for Image: ' + FileName2);
subplot(2,2,2)
imshow(GradData2_Y,[]);
title('Y gradient map for Image: ' + FileName2);

GradData2 = sqrt(power(GradData2_X,2) + power(GradData2_Y,2));
GradData2 = NormalizeImage(GradData2, 0, 255);
subplot(2,2,3);
imshow(GradData2,[]);
title('Magnititude map for Image: ' + FileName2);

%Get Magnitude map and the final binary map
ThresHold2 = max(max(GradData2)) * 0.59;
ResultData2 = zeros(Row, Col, 1);
for nRow = 1:Row
    for nCol = 1:Col
        if GradData2(nRow, nCol) >= ThresHold2
            ResultData2(nRow, nCol) = 255;
        end
    end
end

subplot(2,2,4);
imshow(ResultData2,[]);
title('Sobel Edge Detection result for Image: ' + FileName2);

writeraw(ResultData2, extractBefore(FileName2, ".raw")+"_SobelEdge.raw");

%Rename and cache for Part 1-d evaluation
SobelResult1 = ResultData1;
SobelResult2 = ResultData2;

%% Problem 1 - B
fprintf("\nPart 1-B: Starting now...\n");
disp("Now conducting Canny Edge detection for "+FileName1+"...");

CannyResult1 = edge(OriData1_YUV, "canny", [0.16,0.42], 2.2);

figure("name", "Problem 1-b results");
try
    sgtitle("Problem 1-b resutls");
catch
end
subplot(2,2,1); imshow(OriData1_YUV, []); title("Original Image of: "+ FileName1);
subplot(2,2,2); imshow(CannyResult1,[]); title("Canny detection results of: "+ FileName1);
writeraw(CannyResult1*255, extractBefore(FileName1, ".raw")+"_CannyEdge.raw");

disp("Now conducting Canny Edge detection for "+FileName2+"...");

CannyResult2 = edge(OriData2_YUV, "canny", [0.11,0.51], 2.1);

subplot(2,2,3); imshow(OriData2_YUV, []); title("Original Image of: "+ FileName2);
subplot(2,2,4); imshow(CannyResult2,[]); title("Canny detection results of: "+ FileName2);
writeraw(CannyResult2*255, extractBefore(FileName2, ".raw")+"_CannyEdge.raw");


%% Problem 1 - C

% clear;
fprintf("\nPart 1-C: Starting now...\n");
OriginFolder = pwd;
addpath(genpath('edges-master'));
addpath(genpath('toolbox-master'));
addpath(genpath('./'));

disp("Now conducting Structured Edge detection...");

Row = 321;
Col = 481;
Channel = 3;

FileName1 = 'Tiger.jpg';
FileName2 = 'Pig.jpg';

% % load pre-trained edge detection model and set opts (see edgesDemo.m)
% model=load('models/forest/modelBsds'); model=model.model;

opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelBsds';        % model name
opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory

% train edge detector (~20m/8Gb per tree, proportional to nPos/nNeg)
model=edgesTrain(opts); % will load model if already trained

% set detection parameters (can set after training)
model.opts.multiscale=0;          % for top accuracy set multiscale=1
model.opts.sharpen=2;             % for top speed set sharpen=0
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=0;                 % set to true to enable nms

cd (OriginFolder);
% detect edge and visualize results
ImageData1 = imread(FileName1);
SEresults1=edgesDetect(ImageData1,model);
ImageData2 = imread(FileName2);
SEresults2=edgesDetect(ImageData2,model);

%Set the threshold and binarize the results
Threshold1 = 0.18 * max(SEresults1);
Threshold2 = 0.18 * max(SEresults2);
EdgeMap1 = zeros(Row, Col);
EdgeMap2 = zeros(Row, Col);

for nRow = 1:Row
    for nCol = 1:Col
        if SEresults1(nRow, nCol) >= Threshold1   EdgeMap1(nRow, nCol) = 255;   end
        if SEresults2(nRow, nCol) >= Threshold2   EdgeMap2(nRow, nCol) = 255;   end
    end
end

figure("name", "Problem 1-C results");
try
    sgtitle("Problem 1-C resutls");
catch
end
subplot(2,3,1); imshow(ImageData1, []);  title("Original Image of: "+ FileName1);
subplot(2,3,2); imshow(SEresults1, []);  title("SE detection results of: "+ FileName1);
subplot(2,3,3); imshow(EdgeMap1, []);  title("Binary Edge map of: "+ FileName1);
subplot(2,3,4); imshow(ImageData2, []);  title("Original Image of: "+ FileName2);
subplot(2,3,5); imshow(SEresults2, []);  title("SE detection results of: "+ FileName2);
subplot(2,3,6); imshow(EdgeMap2, []);  title("Binary Edge map of: "+ FileName2);


%% Part 1-d Edge detection evaluation
fprintf("\nPart 1-D: Starting now...\n");
load('Tiger_GT.mat');
Tiger_GT = groundTruth;
load('Pig_GT.mat');
Pig_GT = groundTruth;

%Evaluation for Sobel 
SobelPRF = zeros(3,5,2);
fprintf("\nEvaluation results for Sobel detector:\n");
fprintf("GT No.\t\t\tPrecision\t\t\tRecall\t\t\tF-measure\n");
for GTi = 1:5
    [SobelPRF(1, GTi,1), SobelPRF(2, GTi,1)] = PrecisionRecall(SobelResult1, Tiger_GT{GTi}.Boundaries);
    SobelPRF(3, GTi,1) = 2 * SobelPRF(1, GTi,1) * SobelPRF(2, GTi,1) / (SobelPRF(1, GTi,1) + SobelPRF(2, GTi,1));
    [SobelPRF(1, GTi,2), SobelPRF(2, GTi,2)] = PrecisionRecall(SobelResult2, Pig_GT{GTi}.Boundaries);
    SobelPRF(3, GTi,2) = 2 * SobelPRF(1, GTi,2) * SobelPRF(2, GTi,2) / (SobelPRF(1, GTi,2) + SobelPRF(2, GTi,2));
    fprintf("%d-%s\t\t%f\t\t\t%f\t\t%f\n",GTi,FileName1,SobelPRF(1, GTi,1),SobelPRF(2, GTi,1),SobelPRF(3, GTi,1) );
    fprintf("%d-%s\t\t%f\t\t\t%f\t\t%f\n",GTi,FileName2,SobelPRF(1, GTi,2),SobelPRF(2, GTi,2),SobelPRF(3, GTi,2) );
end
fprintf("The average F-measure for Sobel Detector for "+FileName1+" is %f\n", mean(SobelPRF(3,:,1)) );
fprintf("The average F-measure for Sobel Detector for "+FileName2+" is %f\n", mean(SobelPRF(3,:,2)));
fprintf("The average F-measure for Sobel Detector is %f\n", (mean(SobelPRF(3,:,1))+ mean(SobelPRF(3,:,2)))/2);

%Evaluation for Canny 
CannyPRF = zeros(3,5,2);
fprintf("\nEvaluation results for Canny detector:\n");
fprintf("GT No.\t\t\tPrecision\t\t\tRecall\t\t\tF-measure\n");
for GTi = 1:5
    [CannyPRF(1, GTi,1), CannyPRF(2, GTi,1)] = PrecisionRecall(CannyResult1, Tiger_GT{GTi}.Boundaries);
    CannyPRF(3, GTi,1) = 2 * CannyPRF(1, GTi,1) * CannyPRF(2, GTi,1) / (CannyPRF(1, GTi,1) + CannyPRF(2, GTi,1));
    [CannyPRF(1, GTi,2), CannyPRF(2, GTi,2)] = PrecisionRecall(CannyResult2, Pig_GT{GTi}.Boundaries);
    CannyPRF(3, GTi,2) = 2 * CannyPRF(1, GTi,2) * CannyPRF(2, GTi,2) / (CannyPRF(1, GTi,2) + CannyPRF(2, GTi,2));
    fprintf("%d-%s\t\t%f\t\t\t%f\t\t%f\n",GTi,FileName1,CannyPRF(1, GTi,1),CannyPRF(2, GTi,1),CannyPRF(3, GTi,1) );
    fprintf("%d-%s\t\t%f\t\t\t%f\t\t%f\n",GTi,FileName2,CannyPRF(1, GTi,2),CannyPRF(2, GTi,2),CannyPRF(3, GTi,2) );
end
fprintf("The average F-measure for Canny Detector for "+FileName1+" is %f\n", mean(CannyPRF(3,:,1)) );
fprintf("The average F-measure for Canny Detector for "+FileName2+" is %f\n", mean(CannyPRF(3,:,2)));
fprintf("The average F-measure for Canny Detector is %f\n", (mean(CannyPRF(3,:,1))+ mean(CannyPRF(3,:,2)))/2);

%Evaluation for Canny 
SEPRF = zeros(3,5,2);
fprintf("\nEvaluation results for SE detector:\n");
fprintf("GT No.\t\t\tPrecision\t\t\tRecall\t\t\tF-measure\n");
for GTi = 1:5
    [SEPRF(1, GTi,1), SEPRF(2, GTi,1)] = PrecisionRecall(EdgeMap1, Tiger_GT{GTi}.Boundaries);
    SEPRF(3, GTi,1) = 2 * SEPRF(1, GTi,1) * SEPRF(2, GTi,1) / (SEPRF(1, GTi,1) + SEPRF(2, GTi,1));
    [SEPRF(1, GTi,2), SEPRF(2, GTi,2)] = PrecisionRecall(EdgeMap2, Pig_GT{GTi}.Boundaries);
    SEPRF(3, GTi,2) = 2 * SEPRF(1, GTi,2) * SEPRF(2, GTi,2) / (SEPRF(1, GTi,2) + SEPRF(2, GTi,2));
    fprintf("%d-%s\t\t%f\t\t\t%f\t\t%f\n",GTi,FileName1,SEPRF(1, GTi,1),SEPRF(2, GTi,1),SEPRF(3, GTi,1) );
    fprintf("%d-%s\t\t%f\t\t\t%f\t\t%f\n",GTi,FileName2,SEPRF(1, GTi,2),SEPRF(2, GTi,2),SEPRF(3, GTi,2) );
end
fprintf("The average F-measure for SE Detector for "+FileName1+" is %f\n", mean(SEPRF(3,:,1)) );
fprintf("The average F-measure for SE Detector for "+FileName2+" is %f\n", mean(SEPRF(3,:,2)));
fprintf("The average F-measure for SE Detector is %f\n", (mean(SEPRF(3,:,1))+ mean(SEPRF(3,:,2)))/2);


%Find out correlation between F-measure and threshold value for SE detector
FandThres = zeros(3, 100); 
nCount = 0;
h=waitbar(0,'Computing F-measures for different threshold values...');
for iThreshold = 0.01 :0.01: 1
    waitbar(iThreshold, h);
    nCount = nCount +1;
    newEdgeMap1= zeros(Row, Col);
    newEdgeMap2= zeros(Row, Col);
    Tval1 = iThreshold * max(SEresults1);
    Tval2 = iThreshold * max(SEresults2);
    for nRow = 1:Row
        for nCol = 1:Col
            if SEresults1(nRow, nCol) >= Tval1   newEdgeMap1(nRow, nCol) = 255;   end
            if SEresults2(nRow, nCol) >= Tval2   newEdgeMap2(nRow, nCol) = 255;   end
        end
    end
    FandThres(1, nCount) = iThreshold;

    Fmeasures = zeros(2,5);

    for GTi = 1:5
        [Pval, Rval] = PrecisionRecall(newEdgeMap1, Tiger_GT{GTi}.Boundaries);
        Fmeasures(1, GTi) = 2 * Pval * Rval / (Pval + Rval);
        [Pval, Rval] = PrecisionRecall(newEdgeMap1, Pig_GT{GTi}.Boundaries);
        Fmeasures(2, GTi) = 2 * Pval * Rval / (Pval + Rval);
    end
    FandThres(2, nCount) = mean(Fmeasures(1, :));
    FandThres(3, nCount) = mean(Fmeasures(2, :));
    
end
delete(h);

figure("name", "Problem 1-D results");
hold on;
plot(FandThres(1,:)*100, FandThres(2,:), 'linewidth' ,2);
hold on;
plot(FandThres(1,:)*100, FandThres(3,:), 'linewidth' ,2);
xlabel('Threshold values in percentage(%)');
ylabel('F-measures');
legend(FileName1, FileName2);
hold off;


