%   EE569 Homework4 Problem 3 solutions
%   Author: Boyang Xiao
%   USC id: 3326730274
%   email:  boyangxi@usc.edu
%   Date:   3/21/2022

clear;
close all;
clc;

addpath(genpath('./LiFF-master/'))

%% Part (b)

MaxRow = 400;
MaxCol = 600;
MaxChannel = 3;

cat1 = readraw("Cat_1.raw", MaxRow, MaxCol, MaxChannel,true);
cat2 = readraw("Cat_2.raw", MaxRow, MaxCol, MaxChannel,true);
catdog = readraw("Cat_Dog.raw", MaxRow, MaxCol, MaxChannel,true);
dog1 = readraw("Dog_1.raw", MaxRow, MaxCol, MaxChannel,true);
dog2 = readraw("Dog_2.raw", MaxRow, MaxCol, MaxChannel,true);

cat1_gray = single(rgb2gray(rescale(cat1)));
[cat1_f,cat1_d] = vl_sift(cat1_gray);

cat2_gray = single(rgb2gray(rescale(cat2)));
[cat2_f,cat2_d] = vl_sift(cat2_gray);

catdog_gray = single(rgb2gray(rescale(catdog)));
[catdog_f,catdog_d] = vl_sift(catdog_gray);

dog1_gray = single(rgb2gray(rescale(dog1)));
[dog1_f,dog1_d] = vl_sift(dog1_gray);

dog2_gray = single(rgb2gray(rescale(dog2)));
[dog2_f,dog2_d] = vl_sift(dog2_gray);

figure("Name","Keypoints in both the Cat_1 and Cat_dog pictures");
subplot(1,2,1);
hold on
imshow(rescale(cat1));
vl_plotframe(cat1_f(:, randperm(size(cat1_f,2),200)));
hold off

subplot(1,2,2);
hold on
imshow(rescale(catdog));
vl_plotframe(catdog_f(:, randperm(size(cat1_f,2),200)));
hold off

largestF = zeros(4,1);
fIndex = 0;
for i = 1:size(cat1_f,2)
    if cat1_f(3,i) > largestF(3)
        largestF = cat1_f(:,i);
        fIndex = i;
    end
end

% matches = vl_ubcmatch(cat1_d, catdog_d);
leastDist = 100000;
matchIndex = 0;
for i = 1:size(catdog_d,2)
%     pt1 = cat1_d(:,fIndex);
%     pt2 = catdog(:,i);
    tempDist = pdist2(double(transpose(cat1_d(:,fIndex))), double(transpose(catdog_d(:,i))),"euclidean");
    if tempDist<leastDist
        leastDist = tempDist;
        matchIndex = i;
    end
end

figure("Name","Keypoint matching between cat1 and cat_dog")
subplot(1,2,1);
hold on
imshow(rescale(cat1));
vl_plotframe(largestF);
hold off

subplot(1,2,2);
hold on
imshow(rescale(catdog));
vl_plotframe(catdog_f(:,matchIndex));
hold off


% Dog1 and catdog

largestF = zeros(4,1);
fIndex = 0;
for i = 1:size(dog1_f,2)
    if dog1_f(3,i) > largestF(3)
        largestF = dog1_f(:,i);
        fIndex = i;
    end
end

% matches = vl_ubcmatch(cat1_d, catdog_d);
leastDist = 100000;
matchIndex = 0;
for i = 1:size(catdog_d,2)
    tempDist = pdist2(double(transpose(cat1_d(:,fIndex))), double(transpose(catdog_d(:,i))),"euclidean");
    if tempDist<leastDist
        leastDist = tempDist;
        matchIndex = i;
    end
end

figure("Name","Keypoint matching between dog1 and cat_dog")
subplot(1,2,1);
hold on
imshow(rescale(dog1));
vl_plotframe(largestF);
hold off

subplot(1,2,2);
hold on
imshow(rescale(catdog));
vl_plotframe(catdog_f(:,matchIndex));
hold off

% Cat1 and cat2

largestF = zeros(4,1);
fIndex = 0;
for i = 1:size(cat1_f,2)
    if cat1_f(3,i) > largestF(3)
        largestF = cat1_f(:,i);
        fIndex = i;
    end
end

leastDist = 100000;
matchIndex = 0;
for i = 1:size(cat2_d,2)
    tempDist = pdist2(double(transpose(cat1_d(:,fIndex))), double(transpose(cat2_d(:,i))),"euclidean");
    if tempDist<leastDist
        leastDist = tempDist;
        matchIndex = i;
    end
end

figure("Name","Keypoint matching between cat1 and cat2")
subplot(1,2,1);
hold on
imshow(rescale(cat1));
vl_plotframe(largestF);
hold off

subplot(1,2,2);
hold on
imshow(rescale(cat2));
vl_plotframe(cat2_f(:,matchIndex));
hold off

% Cat1 and Dog1

largestF = zeros(4,1);
fIndex = 0;
for i = 1:size(cat1_f,2)
    if cat1_f(3,i) > largestF(3)
        largestF = cat1_f(:,i);
        fIndex = i;
    end
end

leastDist = 100000;
matchIndex = 0;
for i = 1:size(dog1_d,2)
    tempDist = pdist2(double(transpose(cat1_d(:,fIndex))), double(transpose(dog1_d(:,i))),"euclidean");
    if tempDist<leastDist
        leastDist = tempDist;
        matchIndex = i;
    end
end

figure("Name","Keypoint matching between cat1 and cat2")
subplot(1,2,1);
hold on
imshow(rescale(cat1));
vl_plotframe(largestF);
hold off

subplot(1,2,2);
hold on
imshow(rescale(dog1));
vl_plotframe(dog1_f(:,matchIndex));
hold off


%% Part (c)
rmpath("LiFF-master\lib\vlfeat-0.9.21\toolbox\noprefix")
PreData = {cat1_d, dog1_d, dog2_d};
BoWdata = {};
titleNames = {"Cat_1", "Dog_1", "Dog_2"};
figure;
for i = 1:3
    tempData = transpose(PreData{i});
    PCAcoeff = pca(double(tempData), "NumComponents",20);
    reducedData = double(tempData)*PCAcoeff;

    ClusterData = kmeans(reducedData,8);
    subplot(1,3,i);
    histogram(ClusterData);
    title(titleNames{i});
    BoWdata{i} = ClusterData;
end

cat1_hist = [];
for i = 1:8
    cat1_hist(i) = length(find(BoWdata{1} == i));
end
dog1_hist = [];
for i = 1:8
    dog1_hist(i) = length(find(BoWdata{2} == i));
end
dog2_hist = [];
for i = 1:8
    dog2_hist(i) = length(find(BoWdata{3} == i));
end

up_cd = 0;
down_cd = 0;
up_dd = 0;
down_dd = 0;

for i = 1:8
    up_cd = up_cd+ min([cat1_hist(i), dog2_hist(i)]);
    down_cd = down_cd + max([cat1_hist(i), dog2_hist(i)]);
    up_dd = up_dd+ min([dog1_hist(i), dog2_hist(i)]);
    down_dd = down_dd + max([dog1_hist(i), dog2_hist(i)]);
end

Similarity_cat_dog = up_cd/down_cd;
disp("Similarity between Cat_1 and Dog_2 is: "+ Similarity_cat_dog);
Similarity_dog_dog = up_dd/down_dd;
disp("Similarity between Dog_1 and Dog_2 is: "+ Similarity_dog_dog);







