function Output = NormalizeImage(InputData, min, max);
%NORMALIZEIMAGE Normalize the matrix into a certain range
%   Usage:      NormalizeImage(InputData, [min,max])
%   InputData:  The input matrix
%   min and max:Normalization range
%   Output:     THe normalized data

[Row, Col] = size(InputData);

VecData = reshape(InputData, [1, Row*Col]);

VecData = round(normalize(VecData, "range", [min, max]));

Output = reshape(VecData, [Row, Col]);

end

