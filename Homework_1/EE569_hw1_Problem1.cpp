#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <fstream> 
#include <streambuf>
#include <cstdlib>
#include <string>
#include <vector>
#include <map>
#include <algorithm>
#include <random>
#include <math.h>
using namespace std;

/////////////////////////////////////////////////
// 			  HARDCODE PARAMETERS			   //
/////////////////////////////////////////////////
#define ROW0 512
#define COL0 768
#define ROW1 256
#define	COL1 256
#define ROW2 400
#define COL2 600
#define MONOCHANNEL 1
#define RGBCHANNEL 3

/////////////////////////////////////////////////
// 			Functions Declarations			   //
/////////////////////////////////////////////////
int ReadImage(string strFileName, vector<vector<vector<unsigned char> > > &vecImageData, int nIndex = 0);
int WriteImage(string strFileName, vector<vector<vector<unsigned char> > > vecImageData, string strFileSuffix = "_transformed", int nIndex = 0);

/////////////Part(a) Functions/////////////////
int TransDemosaicing(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputeData);

/////////////Part(b) Functions/////////////////
int GenerateHistogramData(vector<vector<vector<unsigned char> > > vecInputData, map<unsigned char, int> &mapHistgData, int nIndex = 1, bool bSaveData = false, string strFileName = "histgram.csv");
int ManipulationMethodA(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputData, map<unsigned char, int> mapHistgData, int nIndex = 1);
int ManipulationMethodB(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputData, map<unsigned char, int> mapHistgData, int nIndex = 1);

/////////////Part(c) Functions/////////////////
int RGB2YUV(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputData);
int YUV2RGB(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputData);


int main()
{
	string strFileName;

	/////////////////////Part (a)/////////////////////
	cout<<endl<<"Enter the file name to process in Part <a>: ";
	getline(cin, strFileName);
	if (".raw" != strFileName.substr(strFileName.length()-4, strFileName.length()-1))
	{
		strFileName += ".raw";
	}
	cout<<endl;

	vector<vector<vector<unsigned char> > > vecImageData_a;
	vector<vector<vector<unsigned char> > > vecTransData_a;

	cout<<"Part <a> processing starts..."<<endl<<endl;

	if (0== ReadImage(strFileName, vecImageData_a, 0))
	{
		TransDemosaicing(vecImageData_a, vecTransData_a);

		WriteImage(strFileName, vecTransData_a, "_demosaiced", 0);

		cout<<"Part <a> operating success!"<<endl<<endl;

	}else{
		cout<<"Part <a> operating error!"<<endl<<endl;
	}
	
	//////////////////Part (b)//////////////////
	cout<<"Enter the file name to process in Part <b>: ";
	getline(cin, strFileName);
	if (".raw" != strFileName.substr(strFileName.length()-4, strFileName.length()-1))
	{
		strFileName += ".raw";
	}
	cout<<endl;

	cout<<"Part <b> processing starts..."<<endl<<endl;

	//strFileName = "Hat_new.raw";
	vector<vector<vector<unsigned char> > > vecImageData_b;
	vector<vector<vector<unsigned char> > > vecTransData_b;
	map<unsigned char, int> mapHistgData_b;
	if (0== ReadImage(strFileName, vecImageData_b, 1))
	{
		GenerateHistogramData(vecImageData_b, mapHistgData_b, 1, true, strFileName.substr(0, strFileName.length()-4)+"_Histogram.csv");
		//Apply Method A
		cout<<endl<<"Now using the Method A to enchance the image..."<<endl;
		ManipulationMethodA(vecImageData_b, vecTransData_b, mapHistgData_b, 1);
		WriteImage(strFileName, vecTransData_b, "_enhanced_method_A", 1);

		//Apply Method B
		cout<<endl<<"Now using the Method B to enchance the image..."<<endl;
		ManipulationMethodB(vecImageData_b, vecTransData_b, mapHistgData_b, 1);
		WriteImage(strFileName, vecTransData_b, "_enhanced_method_B", 1);

		cout<<"Part <b> operating success!"<<endl<<endl;
	}else{
		cout<<"Part <b> operating error!"<<endl<<endl;
	}

	///////////////////Part (c)////////////////////
	cout<<"Enter the file name to process in Part <c>: ";
	getline(cin, strFileName);
	if (".raw" != strFileName.substr(strFileName.length()-4, strFileName.length()-1))
	{
		strFileName += ".raw";
	}
	cout<<endl;

	cout<<"Part <c> processing starts..."<<endl<<endl;

	//strFileName = "Taj_Mahal.raw";
	vector<vector<vector<unsigned char> > > vecImageData_c;
	vector<vector<vector<unsigned char> > > vecYUVData_c;
	vector<vector<vector<unsigned char> > > vecTransYUVData_c;
	vector<vector<vector<unsigned char> > > vecTransRGBData_c;
	map<unsigned char, int> mapHistgData_c;
	if (0== ReadImage(strFileName, vecImageData_c, 2))
	{
		RGB2YUV(vecImageData_c, vecYUVData_c);
		GenerateHistogramData(vecYUVData_c, mapHistgData_c, 2);

		//Process using method A in Part(b)
		cout<<endl<<"Now using the Method A in Part<b> to enchance the image..."<<endl;
		ManipulationMethodA(vecYUVData_c, vecTransYUVData_c, mapHistgData_c, 2);
		YUV2RGB(vecTransYUVData_c, vecTransRGBData_c);
		WriteImage(strFileName, vecTransRGBData_c, "_enhanced_method_A", 2);
		//Process using method B in Part(b)
		cout<<endl<<"Now using the Method B in Part<b> to enchance the image..."<<endl;
		ManipulationMethodB(vecYUVData_c, vecTransYUVData_c, mapHistgData_c, 2);
		YUV2RGB(vecTransYUVData_c, vecTransRGBData_c);
		WriteImage(strFileName, vecTransRGBData_c, "_enhanced_method_B", 2);

		//Process using CLAHE
		cout<<endl<<"The CLAHE part implementation uses MATLAB codes."<<endl<<"please open Problem1_c.m to execute the CLAHE part!"<<endl<<endl;

		cout<<"Part <c> operating success!"<<endl<<endl;
	}else{
		cout<<"Part <c> operating error!"<<endl<<endl;
	}
	cout<<"Press \"Enter\" to Exit the program...";
	getchar();
	cout<<endl<<endl;
	

	return 0;

}


/////////////////////////////////////////////////
// 		Basic I/O FUNCTIONS IMPLEMENTATION	   //
/////////////////////////////////////////////////

int ReadImage(string strFileName, vector<vector<vector<unsigned char> > > &vecImageData, int nIndex)
{
	// Define file pointer and variables
	FILE* file;
	int nRow, nCol, nChannel;

	switch (nIndex)
	{
	case 0:
		nRow = ROW0;
		nCol = COL0;
		nChannel = MONOCHANNEL;
		break;
	case 1:
		nRow = ROW1;
		nCol = COL1;
		nChannel = MONOCHANNEL;
		break;
	case 2:
		nRow = ROW2;
		nCol = COL2;
		nChannel = RGBCHANNEL;
		break;
	}

	// Allocate image data array
	unsigned char Imagedata_0[ROW0][COL0][MONOCHANNEL];
	unsigned char Imagedata_1[ROW1][COL1][MONOCHANNEL];
	unsigned char Imagedata_2[ROW2][COL2][RGBCHANNEL];

	// Read image (filename specified by first argument) into image data matrix
	if (!(file = fopen((char*)strFileName.c_str(), "rb"))) {
		cout << "Cannot open file: " << strFileName << endl;
		return 1;
	}
	switch (nIndex)
	{
	case 0:
		fread(Imagedata_0, sizeof(unsigned char), nRow * nCol * nChannel, file);
		break;
	case 1:
		fread(Imagedata_1, sizeof(unsigned char), nRow * nCol * nChannel, file);
		break;
	case 2:
		fread(Imagedata_2, sizeof(unsigned char), nRow * nCol * nChannel, file);
		break;
	}
	fclose(file);

	vector<vector<vector<unsigned char> > > vecImageData_temp;

	for (int Row = 0; Row < nRow; Row++)
	{
		vector<vector<unsigned char> > vecCol;
		for (int Col = 0; Col < nCol; Col++)
		{
			vector<unsigned char> vecChannel;
			for(int Channel = 0; Channel<nChannel; Channel++)
			{
				switch (nIndex)
				{
				case 0:
					vecChannel.push_back(Imagedata_0[Row][Col][Channel]);
					break;
				case 1:
					vecChannel.push_back(Imagedata_1[Row][Col][Channel]);
					break;
				case 2:
					vecChannel.push_back(Imagedata_2[Row][Col][Channel]);
					break;
				}
			}
			vecCol.push_back(vecChannel);
		}

		vecImageData_temp.push_back(vecCol);
	}

	vecImageData = vecImageData_temp;

	cout<<"Reading file: "<<strFileName<<" success!"<<endl;

	return 0;
}


int WriteImage(string strFileName, vector<vector<vector<unsigned char> > > vecImageData, string strFileSuffix, int nIndex)
{
    // Write image data (filename specified by second argument) from image data matrix

	FILE* file;
	int nRow, nCol, nChannel;

	switch (nIndex)
	{
	case 0:
		nRow = ROW0;
		nCol = COL0;
		nChannel = RGBCHANNEL;
		break;
	case 1:
		nRow = ROW1;
		nCol = COL1;
		nChannel = MONOCHANNEL;
		break;
	case 2:
		nRow = ROW2;
		nCol = COL2;
		nChannel = RGBCHANNEL;
		break;
	}

	// Allocate image data array
	unsigned char arrImageData_0[ROW0][COL0][RGBCHANNEL];
	unsigned char arrImageData_1[ROW1][COL1][MONOCHANNEL];
	unsigned char arrImageData_2[ROW2][COL2][RGBCHANNEL];

	string strNewFileName = strFileName.substr(0, strFileName.length()-4) + strFileSuffix+".raw";

	if (!(file = fopen((char*)strNewFileName.c_str(), "wb"))) {
		cout << "Cannot open file: " << strNewFileName << endl;
		exit(1);
	}

	for (int Row = 0; Row < nRow; Row++)
	{
		for (int Col = 0; Col < nCol; Col++)
		{
			for(int Channel = 0; Channel<nChannel; Channel++)
			{
				switch (nIndex)
				{
				case 0:
					arrImageData_0[Row][Col][Channel] = vecImageData[Row][Col][Channel];
					break;
				case 1:
					arrImageData_1[Row][Col][Channel] = vecImageData[Row][Col][Channel];
					break;
				case 2:
					arrImageData_2[Row][Col][Channel] = vecImageData[Row][Col][Channel];
					break;
				}
			}
		}
	}

	switch (nIndex)
	{
	case 0:
		fwrite(arrImageData_0, sizeof(unsigned char), nRow * nCol * nChannel, file);
		break;
	case 1:
		fwrite(arrImageData_1, sizeof(unsigned char), nRow * nCol * nChannel, file);
		break;
	case 2:
		fwrite(arrImageData_2, sizeof(unsigned char), nRow * nCol * nChannel, file);
		break;
	}
	fclose(file);

	cout<<"File: "<<strNewFileName<<" has been saved successfully."<<endl;

	return 0;
}


/////////////////////////////////////////////////
// 	  	 PART A FUNCTIONS IMPLEMENTATION	   //
/////////////////////////////////////////////////

int TransDemosaicing(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputeData)
{
	//Define basic parameters and variables
	const int nRow = ROW0;
	const int nCol = COL0;
	const int nChannel = RGBCHANNEL;
	vector<vector<vector<unsigned char> > > vecOutputeData_temp(nRow, vector<vector<unsigned char> >(nCol, vector<unsigned char>(nChannel, 0)));

	//First process the GREEN channel
	for (int Row = 0; Row < nRow; Row++)
	{
		for (int Col = 0; Col < nCol; Col++)
		{
			int nUp, nDown, nLeft, nRight;

			if((Row + Col)%2 == 0)
			{
				vecOutputeData_temp[Row][Col][1] = vecInputData[Row][Col][0];
			}else{
				nUp = Row-1;
				nDown = Row+1;
				nLeft = Col-1;
				nRight = Col+1;

				nUp = nUp <0 ? nUp == Row : nUp;
				nDown = nDown >= nRow ? nDown == Row : nDown;
				nLeft = nLeft <0 ? nLeft == Col : nLeft;
				nRight = nRight >= nCol ? nRight == Col : nRight;

				vecOutputeData_temp[Row][Col][1] = 0.25 * (vecInputData[nUp][Col][0] + vecInputData[nDown][Col][0] + vecInputData[Row][nLeft][0] +vecInputData[Row][nRight][0]);
			}
		}
	}

	//Then process the RED channel
	for (int Row = 0; Row < nRow; Row++)
	{
		for (int Col = 0; Col < nCol; Col++)
		{
			int nUp, nDown, nLeft, nRight;

			if(Row %2 == 0 && Col %2 !=0)
			{
				vecOutputeData_temp[Row][Col][0] = vecInputData[Row][Col][0];
			}else if(Row %2 == 0 && Col %2 ==0)
			{
				nLeft = Col-1;
				nRight = Col+1;

				nLeft = nLeft <0 ? nLeft == Col : nLeft;
				nRight = nRight >= nCol ? nRight == Col : nRight;

				vecOutputeData_temp[Row][Col][0] = 0.5 * (vecInputData[Row][nLeft][0] +vecInputData[Row][nRight][0]);
			}else if(Row %2 != 0 && Col %2 !=0)
			{
				nUp = Row-1;
				nDown = Row+1;

				nUp = nUp <0 ? nUp == Row : nUp;
				nDown = nDown >= nRow ? nDown == Row : nDown;

				vecOutputeData_temp[Row][Col][0] = 0.5 * (vecInputData[nUp][Col][0] +vecInputData[nDown][Col][0]);
			}else
			{
				nUp = Row-1;
				nDown = Row+1;
				nLeft = Col-1;
				nRight = Col+1;

				nUp = nUp <0 ? nUp == Row : nUp;
				nDown = nDown >= nRow ? nDown == Row : nDown;
				nLeft = nLeft <0 ? nLeft == Col : nLeft;
				nRight = nRight >= nCol ? nRight == Col : nRight;

				vecOutputeData_temp[Row][Col][0] = 0.25 * (vecInputData[nUp][nLeft][0] + vecInputData[nDown][nLeft][0] + vecInputData[nUp][nRight][0] +vecInputData[nDown][nRight][0]);
			}
		}
	}

	//Last, process the BLUE channel
	for (int Row = 0; Row < nRow; Row++)
	{
		for (int Col = 0; Col < nCol; Col++)
		{
			int nUp, nDown, nLeft, nRight;

			if(Row %2 != 0 && Col %2 ==0)
			{
				vecOutputeData_temp[Row][Col][2] = vecInputData[Row][Col][0];
			}else if(Row %2 != 0 && Col %2 !=0)
			{
				nLeft = Col-1;
				nRight = Col+1;

				nLeft = nLeft <0 ? nLeft == Col : nLeft;
				nRight = nRight >= nCol ? nRight == Col : nRight;

				vecOutputeData_temp[Row][Col][2] = 0.5 * (vecInputData[Row][nLeft][0] +vecInputData[Row][nRight][0]);
			}else if(Row %2 == 0 && Col %2 ==0)
			{
				nUp = Row-1;
				nDown = Row+1;

				nUp = nUp <0 ? nUp == Row : nUp;
				nDown = nDown >= nRow ? nDown == Row : nDown;

				vecOutputeData_temp[Row][Col][0] = 0.5 * (vecInputData[nUp][Col][0] +vecInputData[nDown][Col][0]);
			}else
			{
				nUp = Row-1;
				nDown = Row+1;
				nLeft = Col-1;
				nRight = Col+1;

				nUp = nUp <0 ? nUp == Row : nUp;
				nDown = nDown >= nRow ? nDown == Row : nDown;
				nLeft = nLeft <0 ? nLeft == Col : nLeft;
				nRight = nRight >= nCol ? nRight == Col : nRight;

				vecOutputeData_temp[Row][Col][2] = 0.25 * (vecInputData[nUp][nLeft][0] + vecInputData[nDown][nLeft][0] + vecInputData[nUp][nRight][0] +vecInputData[nDown][nRight][0]);
			}
		}
	}

	vecOutputeData = vecOutputeData_temp;

	cout<<"Image demosaicing success!"<<endl;
	
	return 0;
}


/////////////////////////////////////////////////
// 	  	 PART B FUNCTIONS IMPLEMENTATION	   //
/////////////////////////////////////////////////
int GenerateHistogramData(vector<vector<vector<unsigned char> > > vecInputData, map<unsigned char, int> &mapHistgData, int nIndex, bool bSaveData, string strFileName)
{
	int nRow = ROW1;
	int nCol = COL1;
	int nChannel = MONOCHANNEL;
	int nLowerBound = 0;
	int nUpperBound = 255;

	switch (nIndex)
	{
	case 0:
		nRow = ROW0;
		nCol = COL0;
		break;
	case 1:
		nRow = ROW1;
		nCol = COL1;
		break;
	case 2:
		nRow = ROW2;
		nCol = COL2;
		nLowerBound = 16;
		nUpperBound = 235;
		break;
	}
	map<unsigned char, int> mapTempData;

	for (int i = nLowerBound; i < (nUpperBound+1); i++)
	{
		mapTempData.insert(pair<unsigned char, int>((unsigned char)i, 0));
	}

	for (int Row = 0; Row < nRow; Row++)
	{
		for (int Col = 0; Col < nCol; Col++)
		{
			for(int channel = 0; channel < nChannel; channel++)
			{
				mapTempData.at(vecInputData[Row][Col][channel])++;
			}
		}
	}
	mapHistgData = mapTempData;
	cout<<"Generating histogram data success!!"<<endl;

	//Save data as a csv file and plot externally
	if(bSaveData)
	{
		ofstream oFile; 
		oFile.open(strFileName, ios::out | ios::trunc);

		for(map<unsigned char, int>::iterator iter = mapTempData.begin(); iter!= mapTempData.end(); iter++)
		{
			oFile << (int)iter->first << "," << iter->second << endl; 
		}
		oFile.close(); 

		cout<<"Histogram data file: "<<strFileName<<" has been saved!!"<<endl;
	}

	return 0;
}

int ManipulationMethodA(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputData, map<unsigned char, int> mapHistgData, int nIndex)
{
	int nRow = ROW1;
	int nCol = COL1;
	int nChannel = MONOCHANNEL;
	int nLowerBound = 0;
	int nUpperBound = 255;

	switch (nIndex)
	{
	case 0:
		nRow = ROW0;
		nCol = COL0;
		break;
	case 1:
		nRow = ROW1;
		nCol = COL1;
		break;
	case 2:
		nRow = ROW2;
		nCol = COL2;
		nLowerBound = 16;
		nUpperBound = 235;
		break;
	}

	//First, get the pdf/cdf of the histogram data, and manipulate to the uniform distribution
	int nCount = mapHistgData.at((unsigned char)nLowerBound);
	mapHistgData.at((unsigned char)nLowerBound) = mapHistgData.at((unsigned char)nLowerBound)/((nRow*nCol)/(nUpperBound-nLowerBound+1)) + nLowerBound;

	for(int i = nLowerBound+1; i<(nUpperBound+1); i++)
	{
		mapHistgData.at((unsigned char)i) += nCount;
		nCount = mapHistgData.at((unsigned char)i);
		mapHistgData.at((unsigned char)i) = mapHistgData.at((unsigned char)i)/((nRow*nCol)/(nUpperBound-nLowerBound+1)) + nLowerBound ;

		if(mapHistgData.at((unsigned char)i) >= (nUpperBound))
		{
			mapHistgData.at((unsigned char)i) = nUpperBound;
		}else if(mapHistgData.at((unsigned char)i) < (nLowerBound))
		{
			mapHistgData.at((unsigned char)i) = nLowerBound;
		}
	}

	//Then apply the mapping table to the original image data
	vector<vector<vector<unsigned char> > > vecOutputData_temp = vecInputData;

	for (int Row = 0; Row < nRow; Row++)
	{
		for (int Col = 0; Col < nCol; Col++)
		{
			for(int channel = 0; channel < nChannel; channel++)
			{
				vecOutputData_temp[Row][Col][channel] = mapHistgData.at(vecInputData[Row][Col][channel]);
				
			}
		}
	}

	vecOutputData = vecOutputData_temp;

	cout<<"Contrast Enhancement using Method A: <the transfer-function-based histogram equalization> has been operated."<<endl;

	return 0;
}


int ManipulationMethodB(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputData, map<unsigned char, int> mapHistgData, int nIndex)
{
	/*	Firstly, I convert all the pixels into pairs, which contain their gray-scales value and positions. 
				I put the pairs who have the same gray-scale value into the same vectors.

	  	Secondly, I shuffle all the vectors, and put them into a whole vector one by one.

	 	Finally, I push the members in this whole vector into the size-equal containers representing for 0-255 gray-scale value one by one.
	  			And modify the values in the original image according to their new values and their position coordinates. */


	int nRow = ROW1;
	int nCol = COL1;
	int nChannel = MONOCHANNEL;
	int nLowerBound = 0;
	int nUpperBound = 255;

	switch (nIndex)
	{
	case 0:
		nRow = ROW0;
		nCol = COL0;
		break;
	case 1:
		nRow = ROW1;
		nCol = COL1;
		break;
	case 2:
		nRow = ROW2;
		nCol = COL2;
		nLowerBound = 16;
		nUpperBound = 235;
		break;
	}

	vector<vector<vector<unsigned char> > > vecOutputData_temp = vecInputData;
	vector<vector<pair<unsigned char, pair<int, int> > > > vecPxls;

	for (int i = nLowerBound; i < (nUpperBound+1); i++)
	{
		vector<pair<unsigned char, pair<int, int> > > vecTemp;
		vecPxls.push_back(vecTemp);
	}
	

	for (int Row = 0; Row < nRow; Row++)
	{
		for (int Col = 0; Col < nCol; Col++)
		{
			for(int channel = 0; channel < nChannel; channel++)
			{
				pair<int, int> prPos(Row, Col);
				pair<unsigned char, pair<int, int> > prPxl(vecInputData[Row][Col][channel], prPos);

				vecPxls[(int)vecInputData[Row][Col][channel] - nLowerBound].push_back(prPxl);
			}
		}
	}

	vector<pair<unsigned char, pair<int, int> > > vecAllPxls;

	for (vector<vector<pair<unsigned char, pair<int, int> > > >::iterator iter = vecPxls.begin(); iter!= vecPxls.end(); iter++)
	{
		shuffle(iter->begin(), iter->end(), default_random_engine());
		vecAllPxls.insert(vecAllPxls.end(), iter->begin(), iter->end());
	}

	int nSize = ceil(nRow*nCol / (nUpperBound - nLowerBound +1));
	for (int i = 0; i < (nUpperBound - nLowerBound +1); i++)
	{
		for(int n = 0; n<nSize; n++)
		{
			vecOutputData_temp[vecAllPxls[i*nSize+n].second.first][vecAllPxls[i*nSize+n].second.second][0] = (unsigned char)( i + nLowerBound);
		}
	}
	
	vecOutputData = vecOutputData_temp;

	cout<<"Contrast Enhancement using Method B: <the cumulative-probability-based histogram equalization> has been operated."<<endl;
	
	return 0;
}



/////////////////////////////////////////////////
// 	  	 PART B FUNCTIONS IMPLEMENTATION	   //
/////////////////////////////////////////////////

int RGB2YUV(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputData)
{
	int nRow = ROW2;
	int nCol = COL2;
	int nChannel = RGBCHANNEL;

	vector<vector<vector<unsigned char> > > vecTempData(nRow, vector<vector<unsigned char> >(nCol, vector<unsigned char>(nChannel, 0)));

	
	for (int Row = 0; Row < nRow; Row++)
	{
		for (int Col = 0; Col < nCol; Col++)
		{
			vecTempData[Row][Col][0] = 0.257* vecInputData[Row][Col][0] + 0.504*vecInputData[Row][Col][1] + 0.098*vecInputData[Row][Col][2] +16;
			vecTempData[Row][Col][1] = -0.148* vecInputData[Row][Col][0] - 0.291*vecInputData[Row][Col][1] + 0.439*vecInputData[Row][Col][2] +128;
			vecTempData[Row][Col][2] = 0.439* vecInputData[Row][Col][0] - 0.368*vecInputData[Row][Col][1] - 0.071*vecInputData[Row][Col][2] +128;
		}
	}

	vecOutputData = vecTempData;

	return 0;
}


int YUV2RGB(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputData)
{
	int nRow = ROW2;
	int nCol = COL2;
	int nChannel = RGBCHANNEL;

	vector<vector<vector<unsigned char> > > vecTempData(nRow, vector<vector<unsigned char> >(nCol, vector<unsigned char>(nChannel, 0)));

	
	for (int Row = 0; Row < nRow; Row++)
	{
		for (int Col = 0; Col < nCol; Col++)
		{
			vecTempData[Row][Col][0] = 1.164* (vecInputData[Row][Col][0]-16) + 1.596* (vecInputData[Row][Col][2]-128);
			vecTempData[Row][Col][1] = 1.164* (vecInputData[Row][Col][0]-16) - 0.391* (vecInputData[Row][Col][1]-128) - 0.813*(vecInputData[Row][Col][2]-128);
			vecTempData[Row][Col][2] = 1.164* (vecInputData[Row][Col][0]-16) + 2.018* (vecInputData[Row][Col][1]-128);
		}
	}

	vecOutputData = vecTempData;

	return 0;
}


