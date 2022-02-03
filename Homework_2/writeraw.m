function count = writeraw(G, filename)
%writeraw - write RAW format grey scale image file 
% Usage :	writeraw(G, filename)
% G:		input image matrix
% filename: file name of the file to write to disk
% count:	return value, the elements written to file

	disp("Writing Image to "+ filename + "...");

	% Get file ID
	fid = fopen(filename,'wb');

	% Check if file exists
	if (fid == -1)
		error('can not open output image filem press CTRL-C to exit \n');
		pause
    end

    [nRow, nCol, nChannel] = size(G);
    data_temp = zeros(1, nRow*nCol*nChannel);
    nCount = 1;

    for x = 1:nRow
        for y = 1:nCol
            for z = 1:nChannel
                data_temp(nCount) = G(x,y,z);
                nCount = nCount +1;
            end
        end
    end
   
	% Write and close file
	count = fwrite(fid, data_temp, 'uchar');
	fclose(fid);

end %function