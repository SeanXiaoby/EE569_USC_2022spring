%   EE569 Homework4 Problem 2 solutions
%   Author: Boyang Xiao
%   USC id: 3326730274
%   email:  boyangxi@usc.edu
%   Date:   3/21/2022

clear;
close all;
clc;
rmpath("LiFF-master\lib\vlfeat-0.9.21\toolbox\noprefix")

%% Part (a)

MaxRow = 512;
MaxCol = 512;
MaxChannel = 1;

MarkingColors = {
    [107 143 159]; [114 99 107]; [175 128 74]; [167 57 32]; [144 147 104]; [157 189 204]
};

MosaicImg = readraw("Mosaic.raw", MaxRow, MaxCol, MaxChannel, true);

% Obtain the filter bank

OneDim = cell(1,5);
OneDim{1} = [1;4;6;4;1];
OneDim{2} = [-1;-2;0;2;1];
OneDim{3} = [-1;0;2;0;-1];
OneDim{4} = [-1;2;0;-2;1];
OneDim{5} = [1;-4;6;-4;1];

LawFilters = cell(1,25);

for i = 1:5
    for j = 1:5
        LawFilters{i*5-5+j} = OneDim{i}*transpose(OneDim{j});
    end
end

% Calculate filtering and energy features for each pic

tempPic = MosaicImg;
% PaddingPic = zeros(MaxRow+4, MaxCol+4);
% PaddingPic(3:MaxRow+2, 3:MaxCol+2) = tempPic;
PaddingPic = padarray(tempPic,[2,2], "replicate","both");
FilterImages = {1,25};
for fi = 1:25
    filter = LawFilters{fi};
    FilterResponse = zeros(MaxRow, MaxCol);
    for r = 3:MaxRow+2
        for c = 3:MaxCol+2
            for fr = -2:2
                for fc = -2:2
                    FilterResponse(r-2,c-2) = FilterResponse(r-2,c-2)+PaddingPic(r+fr,c+fc)*filter(fr+3,fc+3);
                end
            end
            FilterResponse(r-2,c-2) = FilterResponse(r-2,c-2)*FilterResponse(r-2,c-2);
        end
    end
    FilterImages{fi} = FilterResponse;
end

FilterImages(1) = [];


calculate energy averaging and kmeans clustering for different window sizes

windowSizes = [7 15 19 25 35 45 55 65 75];
figure("Name","Texture segmentation with different window sizes");
for i = 1:size(windowSizes,2)
    EnergyFeature = WindowEnergy(FilterImages, windowSizes(i));
    SegmentationResult = kmeansSegmentation(EnergyFeature, MarkingColors);
    subplot(3,3,i);
    imshow(rescale(SegmentationResult));
    title("Window size: "+windowSizes(i));
end


%% Part (b)

windowSizes = [15 41 65];
PCApara = [3 7 15];

figure("Name","Texture segmentation with different window sizes and PCA reduction");

for dim = 1:size(PCApara,2)
    PCAdata = zeros(MaxRow*MaxCol,24);
    for fi = 1:24
%         disp(fi);
        FilterImage = FilterImages{fi};
        for r= 1:MaxRow
            for c = 1:MaxCol
                PCAdata(r*MaxCol-MaxCol+c, :) = FilterImage(r, c, :);
            end
        end
    end
    PCAcoeff = pca(PCAdata,"NumComponents",PCApara(dim));
    reducedFeature = PCAdata*PCAcoeff;
    reducedImages = {};
    for fi = 1:PCApara(dim)
        for r= 1:MaxRow
            for c = 1:MaxCol
                reducedImages{fi}(r,c) = reducedFeature(r*MaxCol-MaxCol+c, fi);
            end
        end
    end

    for i = 1:size(windowSizes,2)
        EnergyFeature = WindowEnergy(reducedImages, windowSizes(i));
        SegmentationResult = kmeansSegmentation(EnergyFeature, MarkingColors);
        subplot(3,3,dim*3-3+i);
        imshow(rescale(SegmentationResult));
        title("PCA dim: "+PCApara(dim)+" Window size: "+windowSizes(i));
    end
end



%% Window energy averaging function

function E = WindowEnergy(ImageSet, windowSize)

numImg = size(ImageSet, 2);
paddingsize = floor(windowSize/2);
[MaxRow, MaxCol] = size(ImageSet{1});

E = zeros(MaxRow, MaxCol, numImg);

h = waitbar(0,"Calculating energy averaging for windows size: "+windowSize);

for index = 1:numImg
%     paddingImage = zeros(MaxRow+2*paddingsize, MaxCol+2*paddingsize);
%     paddingImage(paddingsize+1:MaxRow+paddingsize, paddingsize+1:MaxCol+paddingsize) = ImageSet{index};
    paddingImage = padarray(ImageSet{index}, [paddingsize, paddingsize], "replicate", "both");
    EnergyAverageImage = zeros(MaxRow, MaxCol);
    for r = paddingsize+1:MaxRow+paddingsize
        for c = paddingsize+1:MaxCol+paddingsize
            for wr = 1:windowSize
                for wc = 1:windowSize
                    EnergyAverageImage(r-paddingsize,c-paddingsize) = EnergyAverageImage(r-paddingsize,c-paddingsize)+paddingImage(r+wr-1-paddingsize,c+wc-1-paddingsize);
                end
            end
            EnergyAverageImage(r-paddingsize,c-paddingsize) = EnergyAverageImage(r-paddingsize,c-paddingsize) / (windowSize*windowSize);
        end
    end
    
    E(:,:,index) = EnergyAverageImage;

    waitbar(index/numImg, h);

end
delete(h);

end


%% calculate k-means and segmentation for energy features

function Output = kmeansSegmentation(input, MarkingColors)
    [MaxRow, MaxCol, dim] = size(input);
    EnergyFeature = input;
    classfyData = zeros(MaxRow*MaxCol, dim);
    for r= 1:MaxRow
        for c = 1:MaxCol
            classfyData(r*MaxCol-MaxCol+c, :) = EnergyFeature(r, c, :);
        end
    end
    
    kmeansRes = kmeans(classfyData, 6);
    
    SegmentationResult = zeros(MaxRow,MaxCol,3);
    for r= 1:MaxRow
        for c = 1:MaxCol
            SegmentationResult(r, c, :) = MarkingColors{kmeansRes(r*MaxCol-MaxCol+c)};
        end
    end

    Output = SegmentationResult;
end

