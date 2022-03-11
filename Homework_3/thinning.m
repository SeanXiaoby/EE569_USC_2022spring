function [outputImage, flag] = thinning(inputImage)
%THINNING operate the thining translation on the input image
%   Input parameters:
%   inputImage: the input image
%
%   Output parameters:
%   outputImage: the thinned image
%   flag: showing if the image is changed. True if changed

[MaxRow, MaxCol] = size(inputImage);

outputImage = inputImage;
flag = false;

%% add padding

PadImage = zeros(MaxRow+2, MaxCol+2);
PadImage(2:MaxRow+1, 2:MaxCol+1) = inputImage;

%% Hardcode the conditional and unconditional patterns

CondPatterns = {
    '010011000', '010110000', '000110010', '000011010', ...
    '001011001', '111010000', '100110100', '000010111', ...
    '110011000', '010011001', '011110000', '001011010', ...
    '011011000', '110110000', '000110110', '000011011', ...
    '110011001', '011110100', ...
    '111011001', '011011001', '111110000', '110110100', '100110110', '000110111', '000011111', '001011011',...
    '111011001', '111110100', '100110111', '001011111',...
    '011011011', '111111000', '110110110', '000111111',...
    '111011011', '011011111', '111111100', '111111001', '111110110', '110110111', '100111111', '001111111',...
    '111011111', '111111101', '111110111', '101111111',...
};

UncondPatterns_noD = {
    '00M0M0000', 'M000M0000', ...
    '0000M00M0', '0000MM000', ...
    '00M0MM000', '0MM0M0000', 'MM00M0000', 'M00MM0000', ...
    '000MM0M00', '0000M0MM0', '0000M00MM', '0000MM00M', ...
    '0MMMM0000', 'MM00MM000', '0M00MM00M', '00M0MM0M0', ...
    '01M0M0M00', '00M0M1M00', '01M0M1M00', 'M100M000M', 'M001M000M', 'M101M000M', '00M1M0M00', '00M0M0M10', '00M1M0M10', 'M000M100M', 'M000M001M', 'M000M101M',...
};

UncondPatterns_WithD = {
    'MMDMMDDDD', ...
    'DM0MMMD00', '0MDMMM00D', '00DMMM0MD', 'D00MMMDM0', 'DMDMM00M0', '0M0MM0DMD', '0M00MMDMD', 'DMD0MM0M0',...
    'MDMDMD100', 'MDMDMD010', 'MDMDMD001', 'MDMDMD110', 'MDMDMD101', 'MDMDMD011', 'MDMDMD111', ...
    'MD1DM0MD0', 'MD0DM1MD0', 'MD0DM0MD1', 'MD1DM1MD0', 'MD1DM0MD1', 'MD0DM1MD1', 'MD1DM1MD1',...
    '100DMDMDM', '010DMDMDM', '001DMDMDM', '110DMDMDM', '101DMDMDM', '011DMDMDM', '111DMDMDM',...
    '1DM0MD0DM', '0DM1MD0DM', '0DM0MD1DM', '1DM1MD0DM', '1DM0MD1DM', '0DM1MD1DM', '1DM1MD1DM', ...
    'DM00MMM0D', '0MDMM0D0M', 'D0MMM00MD', 'M0D0MMDM0', ...
};

D_Mask = {
    '00D00DDDD', ...
    'D00000D00', '00D00000D', '00D00000D', 'D00000D00', 'D0D0000M0', '000000D0D', '000000D0D', 'D0D000000',...
    '0D0D0D000', '0D0D0D000', '0D0D0D000', '0D0D0D000', '0D0D0D000', '0D0D0D000', '0D0D0D000', ...
    '0D0D000D0', '0D0D000D0', '0D0D000D0', '0D0D000D0', '0D0D000D0', '0D0D000D0', '0D0D000D0',...
    '000D0D0D0', '000D0D0D0', '000D0D0D0', '000D0D0D0', '000D0D0D0', '000D0D0D0', '000D0D0D0',...
    '0D000D0D0', '0D000D0D0', '0D000D0D0', '0D000D0D0', '0D000D0D0', '0D000D0D0', '0D000D0D0', ...
    'D0000000D', '00D000D00', 'D0000000D', '00D000D00', ...
};



%% Get the mark map M for image

Mtable = zeros(MaxRow+2, MaxCol+2);

for row = 2:MaxRow+1
    for col = 2:MaxCol+1
        unitStr = getString(PadImage(row-1:row+1, col-1:col+1));

        for match = 1:46
            if unitStr == CondPatterns{match}
                Mtable(row, col) = 255;
                break;
            end
        end
    end
end

%% Check for NoD unconditional table

for row = 2:MaxRow+1
    for col = 2:MaxCol+1
        if Mtable(row, col) ~= 255
            outputImage(row-1, col-1) = 0;
            continue;
        end

        tempFlag = false;

        unitStr = getString(PadImage(row-1:row+1, col-1:col+1));
        unitMstr = getString(Mtable(row-1:row+1, col-1:col+1));
        
        unitStr = AddMmark(unitStr, unitMstr);
        

        % Search for Uncond_noD first

        for i = 1:28
            Goal = UncondPatterns_noD{i};
            if unitStr == UncondPatterns_noD{i}
%                 outputImage(row-1, col-1) = 0;
                flag = true;
                tempFlag = true;
                break;
            end
        end

        if tempFlag == true
            continue;
        end
        
        for i = 1:41

            % Add D marks
            unitStrD = AddDmark(unitStr, D_Mask{i});
            Goal = UncondPatterns_WithD{i};
            if unitStrD == UncondPatterns_WithD{i}
%                 outputImage(row-1, col-1) = 0;
                flag = true;
                break;
            end
        end
        if tempFlag == false
            outputImage(row-1, col-1) = 0;
        end
    end
end


end

%% Convert a unit matrix to a char array
function strOut = getString(input)

[UnitRow, UnitCol] = size(input);

strOut = blanks(9);
nCount = 1;

for urow = 1:UnitRow
    for ucol = 1:UnitCol
        if input(urow, ucol) ~= 0
            strOut(nCount) = '1';
        else
            strOut(nCount) = '0';
        end

        nCount = nCount+1;
    end
end

end

%% Add M mark
function strOut = AddMmark(strInput, strM)

[dontcare, index] = size(strInput);
strOut = strInput;

for i = 1:index
    if strM(i) == '1'
        strOut(i) = "M";
    end
end

end

%% Add D mark
function strOut = AddDmark(strInput, strD)

[dontcare, index] = size(strInput);
strOut = strInput;

for i = 1:index
    if strD(i) == 'D'
        strOut(i) = 'D';
    end
end

end

