%  @author	Boyang XIao
%  @Email	boyangxi@usc.edu
%  @usc id	3326730274  
%  @date	2022-01-30

clear;

%% Read and cache image data
prompt = "Enter the File name to be processed in Part 2-D:";
FileName = input(prompt,"s");
if false == contains(FileName, ".raw")
    FileName = FileName + ".raw";
end
Row = 512;
Col = 768;
Channel = 3;

ImageData = readraw(FileName, Row, Col, Channel);

%% Apply NLM filter to denoise the image
disp("Applying NLM filter to the image...")

TransImageData(:,:,1) = imnlmfilt(ImageData(:,:,1));
TransImageData(:,:,2) = imnlmfilt(ImageData(:,:,2));
TransImageData(:,:,3) = imnlmfilt(ImageData(:,:,3));

disp("NLM has been applied to the Image.")

%% Write and save picture
writeraw(TransImageData, extractBefore(FileName, ".raw")+"__RGB_NLM.raw");