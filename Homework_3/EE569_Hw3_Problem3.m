%   EE569 Homework3 Problem 3 solutions
%   Author: Boyang Xiao
%   USC id: 3326730274
%   email:  boyangxi@usc.edu
%   Date:   3/4/2022

clear;
close all;
clc;

%% Part1: Thinning
disp("");
disp("Part (a) starts now!");

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

% nCount = 1;
% while 1
%     [OutputImage1, flag] = thinning(OutputImage1);
%     imshow(OutputImage1, []);
%     disp("Thinning iteration: "+nCount);
%     nCount = nCount +1;
%     if flag == false
%         break
%     end
% end
nThinCount = zeros(1,3);
IntermImages = {};

PrevThinImage = OriginalImage1;
tempImages = {};
nCount = 1;
while 1
    tempImg = bwmorph(PrevThinImage, 'thin', 1);
    tempImages{nCount} = tempImg;
    nCount = nCount +1;

    if tempImg == PrevThinImage
        break
    else
        PrevThinImage = tempImg;
    end
end
IntermImages{1} = tempImages;
nThinCount(1) = nCount;

PrevThinImage = OriginalImage2;
tempImages = {};
nCount = 1;
while 1
    tempImg = bwmorph(PrevThinImage, 'thin', 1);
    tempImages{nCount} = tempImg;
    nCount = nCount +1;

    if tempImg == PrevThinImage
        break
    else
        PrevThinImage = tempImg;
    end
end
IntermImages{2} = tempImages;
nThinCount(2) = nCount;

PrevThinImage = OriginalImage3;
tempImages = {};
nCount = 1;
while 1
    tempImg = bwmorph(PrevThinImage, 'thin', 1);
    tempImages{nCount} = tempImg;
    nCount = nCount +1;

    if tempImg == PrevThinImage
        break
    else
        PrevThinImage = tempImg;
    end
end
IntermImages{3} = tempImages;
nThinCount(3) = nCount;

figure("Name","Part a - Shrinking for each bean and the intermidiate images");
for i = 1:3
    subplot(3,3,3*i-2);
    temp = IntermImages{i}{floor(nThinCount(i)/3)};
    imshow(temp);
    title("1/3 of shrinking result: #"+floor(nThinCount(i)/3)+" iteration");
    subplot(3,3,3*i-1);
    temp = IntermImages{i}{floor(nThinCount(i)/3 *2)};
    imshow(temp);
    title("2/3 of shrinking result: #"+floor(nThinCount(i)/3 *2)+" iteration");
    subplot(3,3,3*i);
    temp = IntermImages{i}{nThinCount(i)-1};
    imshow(temp);
    title("Full shrinking result: #"+(nThinCount(i)-1)+" iteration");

end


%% Part (b) 

clear;

disp("");
disp("Part (b) starts now!");

MaxRow = 691;
MaxCol = 550;
MaxChannel = 1;

OriginalImage = readraw("deer.raw", MaxRow, MaxCol, MaxChannel);

%Binarize the input images
for row = 1:MaxRow
    for col = 1:MaxCol
        if OriginalImage(row, col) >= 255/2
            OriginalImage(row, col) = 255;
        else
            OriginalImage(row, col) = 0;
        end
    end
end

OriginalImage_inverse = 255 - OriginalImage;

figure('name', "Part b - Shrinking results and intermediate results");

ShrinkImage1 = bwmorph(OriginalImage_inverse/255, 'shrink', 20);
ShrinkImage2 = bwmorph(OriginalImage_inverse/255, 'shrink', 50);
ShrinkImage3 = bwmorph(OriginalImage_inverse/255, 'shrink', Inf);
subplot(1,3,1);
imshow(ShrinkImage1, []);
title("Shrinking with 20 iterations");
subplot(1,3,2);
imshow(ShrinkImage2, []);
title("Shrinking with 50 iterations");
subplot(1,3,3);
imshow(ShrinkImage3, []);
title("Shrinking final results");

writeraw(ShrinkImage3*255, "ShrinkRes.raw");

IndexRecord = [];
nCount = 0;

for row = 1:MaxRow
    for col = 1:MaxCol
        if ShrinkImage3(row, col) == 1
            nCount = nCount +1;
            IndexRecord(nCount, 1) = row;
            IndexRecord(nCount, 2) = col;
        end
    end
end

defectCount = [];
ClearImage = OriginalImage;

for n = 1:size(IndexRecord, 1)

    AreaMat = OriginalImage(IndexRecord(n,1)-5:IndexRecord(n,1)+5, IndexRecord(n, 2)-5:IndexRecord(n, 2)+5);
    sizeCount = 0;

    for row = 1:11
        for col = 1:11
            if AreaMat(row, col) == 0
                sizeCount = sizeCount+1;
            end
        end
    end

    IndexRecord(n, 3) = sizeCount;

    if sizeCount<=50
        defectCount = [defectCount, sizeCount];
        IndexRecord(n, 3) = sizeCount;
        ClearImage(IndexRecord(n,1)-5:IndexRecord(n,1)+5, IndexRecord(n, 2)-5:IndexRecord(n, 2)+5) = 255;
    end

end

[n,defectNo] = size(defectCount);
disp("Number of Defects is: "+defectNo);

figure('name', "Part b - Defect points count");
histogram(defectCount);
ylim([0 6])
title("Defect points count")

figure('name', "Part b - Cleared Image");
imshow(ClearImage, []);
writeraw(ClearImage, "deer_clear.raw");


%% Part c

clear;

disp("");
disp("Part (c) starts now!");

MaxRow = 82;
MaxCol = 494;
MaxChannel = 3;

OriginalImage = readraw("beans.raw", MaxRow, MaxCol, MaxChannel);

GrayscaleImage = rgb2gray(OriginalImage/255);
GrayscaleImage_bi = ones(MaxRow,MaxCol);

for row = 1:MaxRow
    for col = 1:MaxCol
        if GrayscaleImage(row, col) <= 0.95
            GrayscaleImage_bi(row, col) = 0;
        end
    end
end


WhiteDots = [28 175; 29 177; 31 179; 31 180 ];

for i = 1:4
    GrayscaleImage_bi(WhiteDots(i,1), WhiteDots(i,2)) = 0;
end

GrayscaleImage_inverse = 1- GrayscaleImage_bi;

shrinkImage = bwmorph(GrayscaleImage_inverse, 'shrink', Inf);

figure('name', "Part c - Shrinked image");
imshow(shrinkImage);
title("Shrinked image to count the number of beans")

nCountBeans = 0;
BeansIndex = [];
for row =1: MaxRow
    for col =1: MaxCol
        if shrinkImage(row, col) ~= 0
            nCountBeans = nCountBeans +1;
            BeansIndex(nCountBeans, 1) = row;
            BeansIndex(nCountBeans, 2) = col;
        end
    end
end

disp("THe number of beans is :"+nCountBeans);

SubBeans = { 
    GrayscaleImage_bi(:, 1:116);
    GrayscaleImage_bi(:, 117:223);
    GrayscaleImage_bi(:, 224:302);
    GrayscaleImage_bi(:, 303:420);
    GrayscaleImage_bi(:, 421:494);
};

nSizeCount = [];
IntermImage = {};
for i = 1:nCountBeans
    SubImg = 1- SubBeans{i};
    nIterCount = 0;
    TempImage = {};
    while 1
        PrevImage = SubImg;
        SubImg = bwmorph(SubImg, 'shrink', 1);
        nIterCount = nIterCount+1;
        TempImage{nIterCount} = SubImg;

        if SubImg == PrevImage
            break
        end
    end

    IntermImage{i} = TempImage;
    nSizeCount(i) = nIterCount;

end

figure("Name","No. of shrinking iterations for each bean");
bFigure = bar(nSizeCount);
title('No. of shrinking iterations for each bean, standing for their size order');
xtips1 = bFigure.XEndPoints;
ytips1 = bFigure.YEndPoints;
labels1 = string(nSizeCount);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')

figure("Name","Shrinking for each bean and the intermidiate images");
for i = 1:5
    subplot(5,3,3*i-2);
    temp = IntermImage{i}{floor(nSizeCount(i)/3)};
    imshow(temp);
    title("1/3 of shrinking result: #"+floor(nSizeCount(i)/3)+" iteration");
    subplot(5,3,3*i-1);
    temp = IntermImage{i}{floor(nSizeCount(i)/3 *2)};
    imshow(temp);
    title("2/3 of shrinking result: #"+floor(nSizeCount(i)/3 *2)+" iteration");
    subplot(5,3,3*i);
    temp = IntermImage{i}{nSizeCount(i)};
    imshow(temp);
    title("Full shrinking result: #"+nSizeCount(i)+" iteration");

end




