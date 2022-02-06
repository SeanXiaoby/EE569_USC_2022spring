function Output = NormalizeImage(InputData, lowerB, upperB);
%NORMALIZEIMAGE Normalize the matrix into a certain range
%   Usage:      NormalizeImage(InputData, [min,max])
%   InputData:  The input matrix
%   min and max:Normalization range
%   Output:     THe normalized data

[Row, Col] = size(InputData);

VecData = reshape(InputData, [1, Row*Col]);

minValue = min(VecData);
maxValue = max(VecData);

VecData = round((VecData - minValue) / (maxValue - minValue) *upperB + lowerB);

Output = reshape(VecData, [Row, Col]);

end

