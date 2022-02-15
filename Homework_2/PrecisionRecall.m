function [Precision, Recall] = PrecisionRecall(EdgeMap, GT)

%   Calculate Precision and Recall for Edge map and Ground truth
[Row, Col] = size(EdgeMap);

FalsePcount = 0;
FalseNcount = 0;
TruePcount = 0;

EdgeMap = EdgeMap / 255;

for nRow = 1:Row
    for nCol = 1:Col
        if GT(nRow, nCol) ~= 0
            if EdgeMap(nRow, nCol) ~= 0
                TruePcount = TruePcount +1;
            else
                FalseNcount = FalseNcount +1;
            end
        else
            if EdgeMap(nRow, nCol) ~= 0
                FalsePcount = FalsePcount +1;
            end
        end
    end
end

Precision = TruePcount / (TruePcount + FalsePcount);
Recall = TruePcount / (TruePcount + FalseNcount);

end

