%   EE569 Homework3 Problem 2 solutions
%   Author: Boyang Xiao
%   USC id: 3326730274
%   email:  boyangxi@usc.edu
%   Date:   3/4/2022

clear;
close all;
clc;

%% Import the image

MaxRow = 432;
MaxCol = 576;
MaxChannel = 3;

LeftImg = readraw("left.raw", MaxRow, MaxCol, MaxChannel);
MidImg = readraw("middle.raw", MaxRow, MaxCol, MaxChannel);
RightImg = readraw("right.raw", MaxRow, MaxCol, MaxChannel);
LeftImg_gray = im2gray(rescale(LeftImg));
MidImg_gray = im2gray(rescale(MidImg));
RightImg_gray = im2gray(rescale(RightImg));


%% Match feature pairs and create transform matrics

% Detect and extract SURF features for I(n).
points1 = detectSURFFeatures(LeftImg_gray);    
[features1, points1] = extractFeatures(LeftImg_gray, points1);
points2 = detectSURFFeatures(MidImg_gray);
[features2, points2] = extractFeatures(MidImg_gray,points2);
points3 = detectSURFFeatures(RightImg_gray);
[features3, points3] = extractFeatures(RightImg_gray,points3);

% Initialize the transform matrics
TransMat1 = projective2d(eye(3));
TransMat2 = projective2d(eye(3));
TransMat3 = projective2d(eye(3));

% Find correspondences between Images
indexPairs12 = matchFeatures(features1, features2, 'Unique', true);
indexPairs23 = matchFeatures(features2, features3, 'Unique', true);

matchedPoints12_1 = points1(indexPairs12(:,1), :);
matchedPoints12_2 = points2(indexPairs12(:,2), :);
matchedPoints23_2 = points2(indexPairs23(:,1), :);
matchedPoints23_3 = points3(indexPairs23(:,2), :);


% Get the transformation matrix between two images

TransMat2 = estimateGeometricTransform2D(matchedPoints12_1, matchedPoints12_2, 'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

TransMat3 = estimateGeometricTransform2D(matchedPoints23_2, matchedPoints23_3, 'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
TransMat3.T = TransMat3.T * TransMat2.T;


%% 
% Compute the output limits for each transform.          
[xlim(1,:), ylim(1,:)] = outputLimits(TransMat1, [1 MaxCol], [1 MaxRow]);    
[xlim(2,:), ylim(2,:)] = outputLimits(TransMat2, [1 MaxCol], [1 MaxRow]);
[xlim(3,:), ylim(3,:)] = outputLimits(TransMat3, [1 MaxCol], [1 MaxRow]);

avgXLim = mean(xlim, 2);
[~,idx] = sort(avgXLim);


Tinv = invert(TransMat2);   
TransMat1.T = TransMat1.T * Tinv.T;
TransMat2.T = TransMat2.T * Tinv.T;
TransMat3.T = TransMat3.T * Tinv.T;


%% Create panorama

[xlim(1,:), ylim(1,:)] = outputLimits(TransMat1, [1 MaxCol], [1 MaxRow]);    
[xlim(2,:), ylim(2,:)] = outputLimits(TransMat2, [1 MaxCol], [1 MaxRow]);
[xlim(3,:), ylim(3,:)] = outputLimits(TransMat3, [1 MaxCol], [1 MaxRow]);


maxImageSize = [MaxRow, MaxCol];

% Find the minimum and maximum output limits. 
xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', LeftImg);

%% Render the output image

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);


% Transform I into the panorama.
warpedImage = imwarp(rescale(RightImg), TransMat1, 'OutputView', panoramaView);       
% Generate a binary mask.    
mask = imwarp(true(size(RightImg,1),size(RightImg,2)), TransMat1, 'OutputView', panoramaView);
% Overlay the warpedImage onto the panorama.
panorama = step(blender, panorama, warpedImage, mask);

% Transform I into the panorama.
warpedImage = imwarp(rescale(MidImg), TransMat2, 'OutputView', panoramaView);       
% Generate a binary mask.    
mask = imwarp(true(size(MidImg,1),size(MidImg,2)), TransMat2, 'OutputView', panoramaView);
% Overlay the warpedImage onto the panorama.
panorama = step(blender, panorama, warpedImage, mask);

% Transform I into the panorama.
warpedImage = imwarp(rescale(LeftImg), TransMat3, 'OutputView', panoramaView);       
% Generate a binary mask.    
mask = imwarp(true(size(LeftImg,1),size(LeftImg,2)), TransMat3, 'OutputView', panoramaView);
% Overlay the warpedImage onto the panorama.
panorama = step(blender, panorama, warpedImage, mask);

figure('name', 'Panorama image');
imshow(panorama);

writeraw(panorama*255, "Panorama.raw");



