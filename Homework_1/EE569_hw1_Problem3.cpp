/**
 * @file	EE569_hw1_Problem3.cpp
 * @author	Boyang XIao
 * @Email	boyangxi@usc.edu
 * @usc id	3326730274  
 * @date	2022-01-30
 */

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
#define MONOCHANNEL 1
#define RGBCHANNEL 3

/////////////////////////////////////////////////
// 			Functions Declarations			   //
/////////////////////////////////////////////////
int ReadImage(string strFileName, vector<vector<vector<unsigned char> > > &vecImageData, int nIndex = 0);
int WriteImage(string strFileName, vector<vector<vector<unsigned char> > > vecImageData, string strFileSuffix = "_transformed", int nIndex = 0);
float PSNRestimator(vector<vector<vector<unsigned char> > > vecOriginData, vector<vector<vector<unsigned char> > > vecDenoisedData, int nMaxRow, int nMaxCol);
int SplitRGBImage(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecRData, vector<vector<vector<unsigned char> > > &vecGData, vector<vector<vector<unsigned char> > > &vecBData);
int MergeRGBImage(vector<vector<vector<unsigned char> > > vecRData, vector<vector<vector<unsigned char> > > vecGData, vector<vector<vector<unsigned char> > > vecBData, vector<vector<vector<unsigned char> > > &vecOutputData);
int FrostedGlassFilter(vector<vector<vector<unsigned char> > > vecImageData, vector<vector<vector<unsigned char> > > &vecFilteredData, int nMonoChannel);
int BilateralFilter(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputeData, int nKernalSize, float nSigmaC, float nSigmaS);
float CalculateWeight(int centerRow, int centerCol, int nbRow, int nbCol, unsigned char centerPixel, unsigned char nbPixel, float sigmaC, float sigmaS);


int main()
{
	string strFileName;
	// string strOriginalFileName;

	cout<<endl<<"Enter the file name of the NOISE-FREE IMAGE to apply the frosty filter: ";
	getline(cin, strFileName);

    if (".raw" != strFileName.substr(strFileName.length()-4, strFileName.length()-1))
	{
		strFileName += ".raw";
	}

	cout<<endl;

	vector<vector<vector<unsigned char> > > vecImageData;
	vector<vector<vector<unsigned char> > > vecTransData;
	vector<vector<vector<unsigned char> > > vecTempData;

    if (0== ReadImage(strFileName, vecImageData, 2))
	{
		FrostedGlassFilter(vecImageData, vecTransData, 1);
        WriteImage(strFileName, vecTransData, "_Frosty", 2);
    }

	cout<<endl<<"Enter the file name of the NOISY IMAGE to apply the frosty filter: ";
	getline(cin, strFileName);

    if (".raw" != strFileName.substr(strFileName.length()-4, strFileName.length()-1))
	{
		strFileName += ".raw";
	}

	cout<<endl;

	if (0== ReadImage(strFileName, vecImageData, 2))
	{
		FrostedGlassFilter(vecImageData, vecTransData, 1);
        WriteImage(strFileName, vecTransData, "_Frosty", 2);
    }

	

	cout<<endl<<"Enter the file name of the NOISY GRAY_SCALE IMAGE to apply Bilateral filter and Frosty Glass Filter: ";
	getline(cin, strFileName);

    if (".raw" != strFileName.substr(strFileName.length()-4, strFileName.length()-1))
	{
		strFileName += ".raw";
	}

	cout<<endl;

	if (0== ReadImage(strFileName, vecImageData, 0))
	{
		cout<<"Now apply the Bilateral Filter first and then Frosty Glass Filter..."<<endl<<endl;
		BilateralFilter(vecImageData, vecTempData, 3, 20, 50);
		FrostedGlassFilter(vecTempData, vecTransData, 0);
        WriteImage(strFileName, vecTransData, "_DENOISED_FROSTY", 0);

		cout<<endl<<"Now apply the Frosty Glass Filter first and then the Bilateral Filter..."<<endl<<endl;
		FrostedGlassFilter(vecImageData, vecTempData, 0);
		BilateralFilter(vecTempData, vecTransData, 3, 20, 50);
        WriteImage(strFileName, vecTransData, "_FROSTY_DENOISED", 0);
    }

	return 0;
}



////////////////////////////////////////////////////////////////////
//////////		Basic I/O FUNCTIONS IMPLEMENTATION	   		////////
////////////////////////////////////////////////////////////////////

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
		nRow = ROW0;
		nCol = COL0;
		nChannel = MONOCHANNEL;
		break;
	case 2:
		nRow = ROW0;
		nCol = COL0;
		nChannel = RGBCHANNEL;
		break;
	}

	// Allocate image data array
	unsigned char Imagedata_0[ROW0][COL0][MONOCHANNEL];
	unsigned char Imagedata_1[ROW0][COL0][MONOCHANNEL];
	unsigned char Imagedata_2[ROW0][COL0][RGBCHANNEL];

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
		nChannel = MONOCHANNEL;
		break;
	case 1:
		nRow = ROW0;
		nCol = COL0;
		nChannel = MONOCHANNEL;
		break;
	case 2:
		nRow = ROW0;
		nCol = COL0;
		nChannel = RGBCHANNEL;
		break;
	}

	// Allocate image data array
	unsigned char arrImageData_0[ROW0][COL0][MONOCHANNEL];
	unsigned char arrImageData_1[ROW0][COL0][MONOCHANNEL];
	unsigned char arrImageData_2[ROW0][COL0][RGBCHANNEL];

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


float PSNRestimator(vector<vector<vector<unsigned char> > > vecOriginData, vector<vector<vector<unsigned char> > > vecDenoisedData, int nMaxRow, int nMaxCol)
{
	float tempResult = 0;
	for (int nRow = 0; nRow < nMaxRow; ++nRow)
	{
		for (int nCol = 0; nCol < nMaxRow; ++nCol)
		{
			tempResult += pow((vecOriginData[nRow][nCol][0] - vecDenoisedData[nRow][nCol][0]), 2);
		}
	}
	tempResult = tempResult / (nMaxRow * nMaxCol);

	float fResult = 10 * log10f( pow(255,2) / tempResult );

	return fResult;
}


int SplitRGBImage(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecRData, vector<vector<vector<unsigned char> > > &vecGData, vector<vector<vector<unsigned char> > > &vecBData)
{
    vector<vector<vector<unsigned char> > > vecImageData_R(ROW0, vector<vector<unsigned char> >(COL0, vector<unsigned char>(MONOCHANNEL, 0)));
	vector<vector<vector<unsigned char> > > vecImageData_G(ROW0, vector<vector<unsigned char> >(COL0, vector<unsigned char>(MONOCHANNEL, 0)));
	vector<vector<vector<unsigned char> > > vecImageData_B(ROW0, vector<vector<unsigned char> >(COL0, vector<unsigned char>(MONOCHANNEL, 0)));

    for (int nRow = 0; nRow < ROW0; nRow++)
    {
        for (int nCol = 0; nCol < COL0; nCol++)
        {
            vecImageData_R[nRow][nCol][0] = vecInputData[nRow][nCol][0];
            vecImageData_G[nRow][nCol][0] = vecInputData[nRow][nCol][1];
            vecImageData_B[nRow][nCol][0] = vecInputData[nRow][nCol][2];
        }
    }

    vecRData = vecImageData_R;
    vecGData = vecImageData_G;
    vecBData = vecImageData_B;

    return 0;

}


int MergeRGBImage(vector<vector<vector<unsigned char> > > vecRData, vector<vector<vector<unsigned char> > > vecGData, vector<vector<vector<unsigned char> > > vecBData, vector<vector<vector<unsigned char> > > &vecOutputData)
{
    vector<vector<vector<unsigned char> > > vecImageData_temp(ROW0, vector<vector<unsigned char> >(COL0, vector<unsigned char>(RGBCHANNEL, 0)));

    for (int nRow = 0; nRow < ROW0; nRow++)
    {
        for (int nCol = 0; nCol < COL0; nCol++)
        {
            vecImageData_temp[nRow][nCol][0] = vecRData[nRow][nCol][0];
            vecImageData_temp[nRow][nCol][1] = vecGData[nRow][nCol][0];
            vecImageData_temp[nRow][nCol][2] = vecBData[nRow][nCol][0];
        }
    }

    vecOutputData = vecImageData_temp;

    return 0;
}

int FrostedGlassFilter(vector<vector<vector<unsigned char> > > vecImageData, vector<vector<vector<unsigned char> > > &vecFilteredData, int nChannel)
{
    int nMaxRow = ROW0, nMaxCol = COL0, nMaxChannel = MONOCHANNEL;
	if (nChannel == 0)
	{
		nMaxChannel = MONOCHANNEL;
	}else
	{
		nMaxChannel = RGBCHANNEL;
	}
	

	int nUp1 = 0, nUp2 = 0, nDown1 = 0, nDown2 = 0, nLeft1 = 0, nLeft2 = 0, nRight1 = 0, nRight2 = 0;
	vector<vector<vector<unsigned char> > > vecTemp(nMaxRow, vector<vector<unsigned char> >(nMaxCol, vector<unsigned char>(nMaxChannel, 0)));

	for (int nRow = 0; nRow < nMaxRow; ++nRow)
	{
		for(int nCol = 0; nCol<nMaxCol; ++nCol)
		{
            vector<int> vecRowVal, vecColVal;

			nUp2 = nRow - 2;
			if(nUp2<0)	nUp2 = 0;
            vecRowVal.push_back(nUp2);
			nUp1 = nRow - 1;
			if(nUp1<0)	nUp1 = 0;
            vecRowVal.push_back(nUp1);
			nDown2 = nRow +2;
			if(nDown2>= nMaxRow-1)	nDown2 = nMaxRow-1;
            vecRowVal.push_back(nDown2);
			nDown1 = nRow +1;
			if(nDown1>= nMaxRow-1)	nDown1 = nMaxRow-1;
            vecRowVal.push_back(nDown1);
			nLeft2 = nCol-2;
			if(nLeft2<0)	nLeft2 = 0;
            vecColVal.push_back(nLeft2);
			nLeft1 = nCol-1;
			if(nLeft1<0)	nLeft1 = 0;
            vecColVal.push_back(nLeft1);
			nRight2 = nCol+2;
			if(nRight2>= nMaxCol)	nRight2 = nMaxCol-1;
            vecColVal.push_back(nRight2);
			nRight1 = nCol+1;
			if(nRight1>= nMaxCol)	nRight1 = nMaxCol-1;
            vecColVal.push_back(nRight1);

            vecRowVal.push_back(nRow);
            vecColVal.push_back(nCol);

            int nNewRow = vecRowVal[ rand()%5 ], nNewCol = vecColVal[ rand()%5 ];

			for (int nChannel = 0; nChannel < nMaxChannel; nChannel++)
			{
				vecTemp[nRow][nCol][nChannel] = vecImageData[nNewRow][nNewCol][nChannel];
			}
        }
    }

    vecFilteredData = vecTemp;

	cout<<"Frosted Glass Filter with kernal size <5*5> has been applied to the image."<<endl;

    return 0;
}

int BilateralFilter(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputeData, int nKernalSize, float fSigmaC, float fSigmaS)
{
	int nMaxRow = ROW0, nMaxCol = COL0, nMaxChannel = MONOCHANNEL;

	int nUp1 = 0, nUp2 = 0, nDown1 = 0, nDown2 = 0, nLeft1 = 0, nLeft2 = 0, nRight1 = 0, nRight2 = 0;
	vector<vector<vector<unsigned char> > > vecTemp(nMaxRow, vector<vector<unsigned char> >(nMaxCol, vector<unsigned char>(nMaxChannel, 0)));

		for (int nRow = 0; nRow < nMaxRow; ++nRow)
	{
		for(int nCol = 0; nCol<nMaxCol; ++nCol)
		{
			nUp2 = nRow - 2;
			if(nUp2<0)	nUp2 = 0;
			nUp1 = nRow - 1;
			if(nUp1<0)	nUp1 = 0;
			nDown2 = nRow +2;
			if(nDown2>= nMaxRow-1)	nDown2 = nMaxRow-1;
			nDown1 = nRow +1;
			if(nDown1>= nMaxRow-1)	nDown1 = nMaxRow-1;
			nLeft2 = nCol-2;
			if(nLeft2<0)	nLeft2 = 0;
			nLeft1 = nCol-1;
			if(nLeft1<0)	nLeft1 = 0;
			nRight2 = nCol+2;
			if(nRight2>= nMaxCol)	nRight2 = nMaxCol-1;
			nRight1 = nCol+1;
			if(nRight1>= nMaxCol)	nRight1 = nMaxCol-1;
			if (nKernalSize == 3)
			{
				//Apply the filter
				float fWeight0 = CalculateWeight(nRow, nCol, nUp1, nLeft1, vecInputData[nRow][nCol][0], vecInputData[nUp1][nLeft1][0], fSigmaC, fSigmaS),
						fWeight1 = CalculateWeight(nRow, nCol, nUp1, nCol, vecInputData[nRow][nCol][0], vecInputData[nUp1][nCol][0], fSigmaC, fSigmaS),
						fWeight2 = CalculateWeight(nRow, nCol, nUp1, nRight1, vecInputData[nRow][nCol][0], vecInputData[nUp1][nRight1][0], fSigmaC, fSigmaS),
						fWeight3 = CalculateWeight(nRow, nCol, nRow, nLeft1, vecInputData[nRow][nCol][0], vecInputData[nRow][nLeft1][0], fSigmaC, fSigmaS),
						fWeight4 = CalculateWeight(nRow, nCol, nRow, nCol, vecInputData[nRow][nCol][0], vecInputData[nRow][nCol][0], fSigmaC, fSigmaS),
						fWeight5 = CalculateWeight(nRow, nCol, nRow, nRight1, vecInputData[nRow][nCol][0], vecInputData[nRow][nRight1][0], fSigmaC, fSigmaS),
						fWeight6 = CalculateWeight(nRow, nCol, nDown1, nLeft1, vecInputData[nRow][nCol][0], vecInputData[nDown1][nLeft1][0], fSigmaC, fSigmaS),
						fWeight7 = CalculateWeight(nRow, nCol, nDown1, nCol, vecInputData[nRow][nCol][0], vecInputData[nDown1][nCol][0], fSigmaC, fSigmaS),
						fWeight8 = CalculateWeight(nRow, nCol, nDown1, nRight1, vecInputData[nRow][nCol][0], vecInputData[nDown1][nRight1][0], fSigmaC, fSigmaS);
						
				vecTemp[nRow][nCol][0] = (unsigned char)( (vecInputData[nUp1][nLeft1][0] * fWeight0 + vecInputData[nUp1][nCol][0] * fWeight1 + vecInputData[nUp1][nRight1][0] * fWeight2
														+  vecInputData[nRow][nLeft1][0] * fWeight3 + vecInputData[nRow][nCol][0] * fWeight4 + vecInputData[nRow][nRight1][0] * fWeight5
														+  vecInputData[nDown1][nLeft1][0] * fWeight6 + vecInputData[nDown1][nCol][0] * fWeight7 + vecInputData[nDown1][nRight1][0] * fWeight8) /
														(fWeight0 + fWeight1 + fWeight2 + fWeight3 + fWeight4 + fWeight5 +fWeight6 +fWeight7 +fWeight8 ) );
				
			}else if(nKernalSize == 5)
			{
				//Apply the filter
				float fWeight0 = CalculateWeight(nRow, nCol, nUp1, nLeft1, vecInputData[nRow][nCol][0], vecInputData[nUp1][nLeft1][0], fSigmaC, fSigmaS),
						fWeight1 = CalculateWeight(nRow, nCol, nUp1, nCol, vecInputData[nRow][nCol][0], vecInputData[nUp1][nCol][0], fSigmaC, fSigmaS),
						fWeight2 = CalculateWeight(nRow, nCol, nUp1, nRight1, vecInputData[nRow][nCol][0], vecInputData[nUp1][nRight1][0], fSigmaC, fSigmaS),
						fWeight3 = CalculateWeight(nRow, nCol, nRow, nLeft1, vecInputData[nRow][nCol][0], vecInputData[nRow][nLeft1][0], fSigmaC, fSigmaS),
						fWeight4 = CalculateWeight(nRow, nCol, nRow, nCol, vecInputData[nRow][nCol][0], vecInputData[nRow][nCol][0], fSigmaC, fSigmaS),
						fWeight5 = CalculateWeight(nRow, nCol, nRow, nRight1, vecInputData[nRow][nCol][0], vecInputData[nRow][nRight1][0], fSigmaC, fSigmaS),
						fWeight6 = CalculateWeight(nRow, nCol, nDown1, nLeft1, vecInputData[nRow][nCol][0], vecInputData[nDown1][nLeft1][0], fSigmaC, fSigmaS),
						fWeight7 = CalculateWeight(nRow, nCol, nDown1, nCol, vecInputData[nRow][nCol][0], vecInputData[nDown1][nCol][0], fSigmaC, fSigmaS),
						fWeight8 = CalculateWeight(nRow, nCol, nDown1, nRight1, vecInputData[nRow][nCol][0], vecInputData[nDown1][nRight1][0], fSigmaC, fSigmaS),
						fWeight9 = CalculateWeight(nRow, nCol, nUp2, nLeft2, vecInputData[nRow][nCol][0], vecInputData[nUp2][nLeft2][0], fSigmaC, fSigmaS),
						fWeight10 = CalculateWeight(nRow, nCol, nUp2, nLeft1, vecInputData[nRow][nCol][0], vecInputData[nUp2][nLeft1][0], fSigmaC, fSigmaS),
						fWeight11 = CalculateWeight(nRow, nCol, nUp2, nCol, vecInputData[nRow][nCol][0], vecInputData[nUp2][nCol][0], fSigmaC, fSigmaS),
						fWeight12 = CalculateWeight(nRow, nCol, nUp2, nRight1, vecInputData[nRow][nCol][0], vecInputData[nUp2][nRight1][0], fSigmaC, fSigmaS),
						fWeight13 = CalculateWeight(nRow, nCol, nUp2, nRight2, vecInputData[nRow][nCol][0], vecInputData[nUp2][nRight2][0], fSigmaC, fSigmaS),
						fWeight14 = CalculateWeight(nRow, nCol, nUp1, nLeft2, vecInputData[nRow][nCol][0], vecInputData[nUp1][nLeft2][0], fSigmaC, fSigmaS),
						fWeight15 = CalculateWeight(nRow, nCol, nUp1, nRight2, vecInputData[nRow][nCol][0], vecInputData[nUp1][nRight2][0], fSigmaC, fSigmaS),
						fWeight16 = CalculateWeight(nRow, nCol, nRow, nLeft2, vecInputData[nRow][nCol][0], vecInputData[nRow][nLeft2][0], fSigmaC, fSigmaS),
						fWeight17 = CalculateWeight(nRow, nCol, nRow, nRight2, vecInputData[nRow][nCol][0], vecInputData[nRow][nRight2][0], fSigmaC, fSigmaS),
						fWeight18 = CalculateWeight(nRow, nCol, nDown1, nLeft2, vecInputData[nRow][nCol][0], vecInputData[nDown1][nLeft2][0], fSigmaC, fSigmaS),
						fWeight19 = CalculateWeight(nRow, nCol, nDown1, nRight2, vecInputData[nRow][nCol][0], vecInputData[nDown1][nRight2][0], fSigmaC, fSigmaS),
						fWeight20 = CalculateWeight(nRow, nCol, nDown2, nLeft2, vecInputData[nRow][nCol][0], vecInputData[nDown2][nLeft2][0], fSigmaC, fSigmaS),
						fWeight21 = CalculateWeight(nRow, nCol, nDown2, nLeft1, vecInputData[nRow][nCol][0], vecInputData[nDown2][nLeft1][0], fSigmaC, fSigmaS),
						fWeight22 = CalculateWeight(nRow, nCol, nDown2, nCol, vecInputData[nRow][nCol][0], vecInputData[nDown2][nCol][0], fSigmaC, fSigmaS),
						fWeight23 = CalculateWeight(nRow, nCol, nDown2, nRight1, vecInputData[nRow][nCol][0], vecInputData[nDown2][nRight1][0], fSigmaC, fSigmaS),
						fWeight24 = CalculateWeight(nRow, nCol, nDown2, nRight2, vecInputData[nRow][nCol][0], vecInputData[nDown2][nRight2][0], fSigmaC, fSigmaS);

				vecTemp[nRow][nCol][0] = (fWeight9* vecInputData[nUp2][nLeft2][0] + fWeight10* vecInputData[nUp2][nLeft1][0] + fWeight11* vecInputData[nUp2][nCol][0] + fWeight12* vecInputData[nUp2][nRight1][0] + fWeight13* vecInputData[nUp2][nRight2][0] +
										  fWeight14* vecInputData[nUp1][nLeft2][0] + fWeight0* vecInputData[nUp1][nLeft1][0] + fWeight1* vecInputData[nUp1][nCol][0] + fWeight2* vecInputData[nUp1][nRight1][0] + fWeight15* vecInputData[nUp1][nRight2][0] +
										  fWeight16* vecInputData[nRow][nLeft2][0] + fWeight3* vecInputData[nRow][nLeft1][0] + fWeight4* vecInputData[nRow][nCol][0] + fWeight5* vecInputData[nRow][nRight1][0] + fWeight17* vecInputData[nRow][nRight2][0] +
										  fWeight18* vecInputData[nDown1][nLeft2][0] + fWeight6* vecInputData[nDown1][nLeft1][0] + fWeight7* vecInputData[nDown1][nCol][0] + fWeight8* vecInputData[nDown1][nRight1][0] + fWeight19* vecInputData[nDown1][nRight2][0] +
										  fWeight20* vecInputData[nDown2][nLeft2][0] + fWeight21* vecInputData[nDown2][nLeft1][0] + fWeight22* vecInputData[nDown2][nCol][0] + fWeight23* vecInputData[nDown2][nRight1][0] + fWeight24* vecInputData[nDown2][nRight2][0] ) / 
										  (fWeight0 + fWeight1 +fWeight2 +fWeight3 +fWeight4 +fWeight5 +fWeight6 +fWeight7 +fWeight8 +fWeight9 +fWeight10 +fWeight11 +fWeight12 +fWeight13 +fWeight14 +fWeight15 +fWeight16 +fWeight17 +fWeight18
										   +fWeight19 +fWeight20 +fWeight21 +fWeight22 +fWeight23 +fWeight24);
			}
		}
	}
	
	vecOutputeData = vecTemp;

	if (nKernalSize != 3 && nKernalSize != 5)
	{
		cout<< "Wrong Kernal size for the filter!";
		return 1;
	}else if(nKernalSize == 3)
	{
		cout<< "Bilateral Filter of Kernal size <3*3> has been appied to the image. "<<endl;
	}else
	{
		cout<< "Bilateral Filter of Kernal size <5*5> has been appied to the image. "<<endl;
	}

	return 0;
}


float CalculateWeight(int centerRow, int centerCol, int nbRow, int nbCol, unsigned char centerPixel, unsigned char nbPixel, float sigmaC, float sigmaS)
{
	float fWeight1, fWeight2;
	fWeight1 = (powf(centerRow - nbRow, 2) + powf(centerCol - nbCol, 2)) / (2* powf(sigmaC,2)) * (-1);
	fWeight2 = powf(centerPixel - nbPixel, 2) / (2* powf(sigmaS,2)) * (-1);

	float fResult = expf(fWeight1 + fWeight2);

	return fResult;
}