function Output = RGBxYUV(G, flag_R2Y)
%RGBxYUV - Convert RGB to YUV or Convert YUV to RGB
% Usage:    RGBxYUV(G, flag_R2Y)
% G:        input image matrix
% flag_R2Y: indicator: 1:RGB 2 YUV;  2: YUV 2 RGB; 3: RGB 2 Y
% Output:   Output image matrix
    
    [Row, Col, Channel] = size(G);
    
    if flag_R2Y == 1
        Output = zeros(Row, Col, Channel);
        
        for nRow = 1:Row
            for nCol = 1:Col
                Output(nRow, nCol, 1) = 0.257*G(nRow, nCol, 1) + 0.504*G(nRow, nCol, 2) + 0.098*G(nRow, nCol, 3) +16;
                Output(nRow, nCol, 2) = (-0.148)*G(nRow, nCol, 1) - 0.291*G(nRow, nCol, 2) + 0.439*G(nRow, nCol, 3) +128;
                Output(nRow, nCol, 3) = 0.439*G(nRow, nCol, 1) -0.368*G(nRow, nCol, 2) -0.071*G(nRow, nCol, 3) +128;
            end
        end

    elseif flag_R2Y == 2
        Output = zeros(Row, Col, Channel);

        for nRow = 1:Row
            for nCol = 1:Col
                Output(nRow, nCol, 1) = 1.164* (G(nRow,nCol,1)-16) + 1.596* (G(nRow,nCol,3)-128);
                Output(nRow, nCol, 2) = 1.164* (G(nRow,nCol,1)-16) - 0.391* (G(nRow,nCol,2)-128) - 0.813*(G(nRow,nCol,3)-128);
                Output(nRow, nCol, 3) = 1.164* (G(nRow,nCol,1)-16) + 2.018* (G(nRow,nCol,2)-128);
            end
        end

    elseif flag_R2Y == 3
        Output = zeros(Row, Col, 1);

        for nRow = 1:Row
            for nCol = 1:Col
                Output(nRow, nCol, 1) = 0.2989 * G(nRow,nCol,1) + 0.5870 *G(nRow,nCol,2) + 0.1140 *G(nRow,nCol,3);
            end
        end
    end


end%function