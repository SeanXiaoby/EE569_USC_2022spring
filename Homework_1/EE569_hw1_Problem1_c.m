%  @author	Boyang XIao
%  @Email	boyangxi@usc.edu
%  @usc id	3326730274  
%  @date	2022-01-30

clear;

%% Read and cache image data
prompt = "Enter the File name to be processed in Part 1-C:";
FileName = input(prompt,"s");
if false == contains(FileName, ".raw")
    FileName = FileName + ".raw";
end
Row = 400;
Col = 600;
Channel = 3;

ImageData = readraw(FileName, Row, Col, Channel);

%% Convert RGB to YUV

disp("CLAHE operation starts...");

ImageDataYUV = zeros(Row, Col, Channel);

for nRow = 1:Row
    for nCol = 1:Col
        ImageDataYUV(nRow, nCol, 1) = 0.257*ImageData(nRow, nCol, 1) + 0.504*ImageData(nRow, nCol, 2) + 0.098*ImageData(nRow, nCol, 3) +16;
        ImageDataYUV(nRow, nCol, 2) = (-0.148)*ImageData(nRow, nCol, 1) - 0.291*ImageData(nRow, nCol, 2) + 0.439*ImageData(nRow, nCol, 3) +128;
        ImageDataYUV(nRow, nCol, 3) = 0.439*ImageData(nRow, nCol, 1) -0.368*ImageData(nRow, nCol, 2) -0.071*ImageData(nRow, nCol, 3) +128;
    end
end

ImageData_temp = (ImageDataYUV(:,:,1) - 16) / (235-15) ;
ImageData_trans_temp = adapthisteq(ImageData_temp, 'clipLimit',0.0045, "NumTiles", [12,8]);

ImageData_trans_YUV = ImageDataYUV;
ImageData_trans_YUV(:,:,1) = floor(ImageData_trans_temp*(235-15) + 16);

disp("CLAHE has been applied to Image"+ FileName +".");

%% Convert YUV to RGB

ImageData_trans = zeros(Row, Col, Channel);

for nRow = 1:Row
    for nCol = 1:Col
        ImageData_trans(nRow, nCol, 1) = 1.164* (ImageData_trans_YUV(nRow,nCol,1)-16) + 1.596* (ImageData_trans_YUV(nRow,nCol,3)-128);
        ImageData_trans(nRow, nCol, 2) = 1.164* (ImageData_trans_YUV(nRow,nCol,1)-16) - 0.391* (ImageData_trans_YUV(nRow,nCol,2)-128) - 0.813*(ImageData_trans_YUV(nRow,nCol,3)-128);
        ImageData_trans(nRow, nCol, 3) = 1.164* (ImageData_trans_YUV(nRow,nCol,1)-16) + 2.018* (ImageData_trans_YUV(nRow,nCol,2)-128);
    end
end

temp = ImageData_trans_YUV(:,:,3);

%% Output data
writeraw(ImageData_trans, extractBefore(FileName, ".raw")+"_CLAHE.raw");

