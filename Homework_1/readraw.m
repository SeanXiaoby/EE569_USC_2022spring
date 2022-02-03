function G = readraw(filename, Row, Col, Channel)
%readraw - read RAW format grey scale image of square size into matrix G
% Usage:	G = readraw(filename)

	disp("Retrieving Image "+ filename + "...");

	% Get file ID for file
	fid=fopen(filename,'rb');

	% Check if file exists
	if (fid == -1)
	  	error('can not open input image file press CTRL-C to exit \n');
	  	pause
	end

	% Get all the pixels from the image
	pixel = fread(fid, inf, 'uchar');

	% Close file
	fclose(fid);

	% Construct matrix
	G = zeros(Row, Col, Channel);

	% Write pixels into matrix
    nCount = 1;
	for nRow = 1:Row
        for nCol = 1:Col
            for nChannel = 1:Channel
                G(nRow,nCol,nChannel) = pixel(nCount);
                nCount = nCount +1;
            end
        end
    end

% 	% Transpose matrix, to orient it properly
% 	G = G';
end %function
