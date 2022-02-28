clc;
clear;

%% Input data


OriginData = [8 3 3 7 7;
                3 4 3 1 0;
                3 6 9 5 4;
                6 4 4 2 1;
                6 8 8 4 0];

InputData = [9 4 4 7 7;
                4 3 3 1 0;
                3 5 8 5 5;
                6 3 5 2 2;
                5 5 6 3 1];


%% Mean filter

MeanKernel = ones(3,3)/9;

MeanMat = zeros(5,5);


for i = 2:4
    for k = 2:4
        TempVal = 0;
        for m = -1:1
            for n = -1:1
                TempVal = TempVal+MeanKernel(m+2,n+2)*InputData(i+m,k+n);
            end
        end
        MeanMat(i,k) = round(TempVal);
    end
end

% Gaussian filter

GaussianKernel = [0.08 0.12 0.08;
                    0.12 0.20 0.12;
                    0.08 0.12 0.08];

GaussianMat = zeros(5,5);

for i = 2:4
    for k = 2:4
        TempVal = 0;
        for m = -1:1
            for n = -1:1
                TempVal = TempVal+GaussianKernel(m+2,n+2)*InputData(i+m,k+n);
            end
        end
        GaussianMat(i,k) = round(TempVal);
    end
end

% Median Filter

MedianMat = zeros(5,5);

for i = 2:4
    for k = 2:4
        TempArray = zeros(1,9);
        index = 1;
        for m = -1:1
            for n = -1:1
                TempArray(index) = InputData(i+m,k+n);
                index = index +1;
            end
        end
        MedianMat(i,k) = median(TempArray);
    end
end

MeanMSE = 0 ;
GaussianMSE = 0;
MedianMSE = 0;

for i = 2:4
    for k = 2:4
        MeanMSE = MeanMSE + power((MeanMat(i,k)-OriginData(i,k)), 2);
        GaussianMSE = GaussianMSE + power((GaussianMat(i,k)-OriginData(i,k)), 2);
        MedianMSE = MedianMSE + power((MedianMat(i,k)-OriginData(i,k)), 2);
    end
end

MeanMSE = MeanMSE / 9;
GaussianMSE = GaussianMSE /9;
MedianMSE = MedianMSE /9;