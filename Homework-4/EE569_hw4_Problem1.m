%   EE569 Homework4 Problem 1 solutions
%   Author: Boyang Xiao
%   USC id: 3326730274
%   email:  boyangxi@usc.edu
%   Date:   3/21/2022

clear;
close all;
clc;

%% Part (a)

MaxRow = 128;
MaxCol = 128;
MaxChannel = 1;

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

% Load pictures

TrainPics = cell(4,9);
for i = 1:9
    TrainPics{1,i} = readraw("./train/blanket_"+int2str(i)+".raw", MaxRow,MaxCol, MaxChannel,false);
    TrainPics{2,i} = readraw("./train/brick_"+int2str(i)+".raw", MaxRow,MaxCol, MaxChannel,false);
    TrainPics{3,i} = readraw("./train/grass_"+int2str(i)+".raw", MaxRow,MaxCol, MaxChannel,false);
    TrainPics{4,i} = readraw("./train/stones_"+int2str(i)+".raw", MaxRow,MaxCol, MaxChannel,false);
end


% Calculate filtering and energy features for each pic

EnergyFeatures = cell(4,9);

for i = 1:4
    for j = 1:9
        tempPic = TrainPics{i,j};
        PaddingPic = zeros(MaxRow+4, MaxCol+4);
        PaddingPic(3:MaxRow+2, 3:MaxCol+2) = tempPic;
        EnergyFeature = zeros(1,25);
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
                    FilterResponse(r-2,c-2) = FilterResponse(r-2,c-2)*FilterResponse(r-2,c-2)/(MaxRow*MaxCol);
                end
            end
            EnergyFeature(fi) = mean(mean(FilterResponse));
        end
        EnergyFeatures{i, j} = EnergyFeature;
    end
end

PCAdata = zeros(36,25);

for i = 1:4
    for j = 1:9
        PCAdata(i*9-9+j, : ) = EnergyFeatures{i,j}(1,:);
    end
end

PCAdata = PCAdata(:, 2:25);

PCAres = pca(PCAdata,"NumComponents",3);
PCAres = PCAdata*PCAres;

figure;
hold on
scatter3(PCAres(1:9,1),PCAres(1:9,2),PCAres(1:9,3),"blue");
scatter3(PCAres(10:18,1),PCAres(10:18,2),PCAres(10:18,3),"black");
scatter3(PCAres(19:27,1),PCAres(19:27,2),PCAres(19:27,3),"green");
scatter3(PCAres(28:36,1),PCAres(28:36,2),PCAres(28:36,3),"red");
legend("Blacket", "Brick", "Grass", "Stones")
title("Training samples features visualization")
grid on
hold off


%% Part(b)

idx = kmeans(PCAdata,4);
idx2 = kmeans(PCAres,4);







