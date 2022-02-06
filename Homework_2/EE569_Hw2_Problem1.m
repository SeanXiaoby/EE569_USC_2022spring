clear;
close all;

%% Problem 1 - A

% Import Image and convert to YUV space

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

figure(1);
sgtitle("Problem 1-a resutls: For Image: "+FileName1);
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

figure(2);
sgtitle("Problem 1-a resutls: For Image: "+FileName2);
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



%% Problem 1 - B

CannyResult1 = edge(OriData1_YUV, "canny", [0.16,0.42], 2.2);

figure(3);
sgtitle("Problem 1-b results")
subplot(2,2,1);
imshow(OriData1_YUV, []);
title("Original Image of: "+ FileName1);
subplot(2,2,2);
imshow(CannyResult1,[]);
title("Canny detection results of: "+ FileName1);

writeraw(CannyResult1*255, extractBefore(FileName1, ".raw")+"_CannyEdge.raw");

CannyResult2 = edge(OriData2_YUV, "canny", [0.11,0.51], 2.1);

subplot(2,2,3);
imshow(OriData2_YUV, []);
title("Original Image of: "+ FileName2);
subplot(2,2,4);
imshow(CannyResult2,[]);
title("Canny detection results of: "+ FileName2);

writeraw(CannyResult2*255, extractBefore(FileName2, ".raw")+"_CannyEdge.raw");


%% Problem 1 - C




