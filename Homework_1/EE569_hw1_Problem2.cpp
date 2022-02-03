/**
 * @file	EE569_hw1_Problem2.cpp
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

/////////////Part(a) Functions/////////////////
int LowPassFilterMean(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputeData, int nKernalSize);
int LowPassFilterGaussian(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputeData, int nKernalSize);

/////////////Part(b) Functions/////////////////
int BilateralFilter(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputeData, int nKernalSize, float nSigmaC, float nSigmaS);
float CalculateWeight(int centerRow, int centerCol, int nbRow, int nbCol, unsigned char centerPixel, unsigned char nbPixel, float sigmaC, float sigmaS);
/////////////Part(c) Functions/////////////////

/////////////Part(d) Functions/////////////////
int GenerateHistogramData(vector<vector<vector<unsigned char> > > vecInputData, map<unsigned char, int> &mapHistgData, int nIndex = 1, bool bSaveData = false, string strFileName = "histgram.csv");


int main()
{
    string strFileName;
	string strOriginalFileName;

	/////////////////////Part (a)/////////////////////
	cout<<endl<<"Enter the file name of the NOISY IMAGE to process in Part <a>: ";
	getline(cin, strFileName);
	cout<<endl<<"Enter the file name of the NOISE-FREE IMAGE to evaluate the denoising effects: ";
	getline(cin, strOriginalFileName);
	if (".raw" != strFileName.substr(strFileName.length()-4, strFileName.length()-1))
	{
		strFileName += ".raw";
	}
	if (".raw" != strOriginalFileName.substr(strOriginalFileName.length()-4, strOriginalFileName.length()-1))
	{
		strOriginalFileName += ".raw";
	}
	cout<<endl;

	vector<vector<vector<unsigned char> > > vecImageData_a;
	vector<vector<vector<unsigned char> > > vecOriImageData_a;
	vector<vector<vector<unsigned char> > > vecTransData_a;

	cout<<"Part <a> processing starts..."<<endl<<endl;

	if (0== ReadImage(strFileName, vecImageData_a, 0) && 0 == ReadImage(strOriginalFileName, vecOriImageData_a, 0))
	{
		LowPassFilterMean(vecImageData_a, vecTransData_a, 3);
		WriteImage(strFileName, vecTransData_a, "_denoised_mean_3", 0);
		cout<<"The PSNR for Low pass filter (mean) with kernal size <3*3> equals to: "<<PSNRestimator(vecOriImageData_a, vecTransData_a, 512, 768)<<endl<<endl;
		LowPassFilterMean(vecImageData_a, vecTransData_a, 5);
		WriteImage(strFileName, vecTransData_a, "_denoised_mean_5", 0);
		cout<<"The PSNR for Low pass filter (mean) with kernal size <5*5> equals to: "<<PSNRestimator(vecOriImageData_a, vecTransData_a, 512, 768)<<endl<<endl;
		LowPassFilterGaussian(vecImageData_a, vecTransData_a, 3);
		WriteImage(strFileName, vecTransData_a, "_denoised_Gaussian_3", 0);
		cout<<"The PSNR for Low pass filter (Gaussian) with kernal size <3*3> equals to: "<<PSNRestimator(vecOriImageData_a, vecTransData_a, 512, 768)<<endl<<endl;
		LowPassFilterGaussian(vecImageData_a, vecTransData_a, 5);
		WriteImage(strFileName, vecTransData_a, "_denoised_Gaussian_5", 0);
		cout<<"The PSNR for Low pass filter (Gaussian) with kernal size <5*5> equals to: "<<PSNRestimator(vecOriImageData_a, vecTransData_a, 512, 768)<<endl<<endl;
		cout<<endl<<"Part <a> operating success!"<<endl<<endl;

	}else{
		cout<<endl<<"Part <a> operating error!"<<endl<<endl;
	}

	/////////////////////Part (b)/////////////////////
	cout<<endl<<"Enter the file name of the NOISY IMAGE to process in Part <b>: ";
	getline(cin, strFileName);
	cout<<endl<<"Enter the file name of the NOISE-FREE IMAGE to evaluate the denoising effects: ";
	getline(cin, strOriginalFileName);
	// strFileName = "Flower_gray_noisy";
	// strOriginalFileName = "Flower_gray";
	if (".raw" != strFileName.substr(strFileName.length()-4, strFileName.length()-1))
	{
		strFileName += ".raw";
	}
	if (".raw" != strOriginalFileName.substr(strOriginalFileName.length()-4, strOriginalFileName.length()-1))
	{
		strOriginalFileName += ".raw";
	}
	cout<<endl;

	vector<vector<vector<unsigned char> > > vecImageData_b;
	vector<vector<vector<unsigned char> > > vecOriImageData_b;
	vector<vector<vector<unsigned char> > > vecTransData_b;

	cout<<"Part <b> processing starts..."<<endl<<endl;

	if (0== ReadImage(strFileName, vecImageData_b, 1) && 0 == ReadImage(strOriginalFileName, vecOriImageData_b, 1))
	{
		BilateralFilter(vecImageData_b, vecTransData_b, 3, 20, 50);
		WriteImage(strFileName, vecTransData_b, "_bilateral_3", 1);
		cout<<"The PSNR for Bilateral filter with kernal size <3*3> equals to: "<<PSNRestimator(vecOriImageData_b, vecTransData_b, 512, 768)<<endl<<endl;
		BilateralFilter(vecImageData_b, vecTransData_b, 5, 10, 20);
		WriteImage(strFileName, vecTransData_b, "_bilateral_5", 1);
		cout<<"The PSNR for Bilateral filter with kernal size <5*5> equals to: "<<PSNRestimator(vecOriImageData_b, vecTransData_b, 512, 768)<<endl<<endl;

		cout<<endl<<"Part <b> operating success!"<<endl<<endl;

	}else{
		cout<<endl<<"Part <b> operating error!"<<endl<<endl;
	}

	/////////////////////Part (c)/////////////////////
	cout<<"Part C is implemented using MATLAT codes, please see EE569_hw1_Problem2_c.m"<<endl;
	cout<<"Press Enter to execute the next part..."<<endl<<endl;
	getchar();
	

	/////////////////////Part (d)/////////////////////
	cout<<endl<<"Enter the file name of the NOISY IMAGE to process in Part <d>: ";
	getline(cin, strFileName);
	cout<<endl<<"Enter the file name of the NOISE-FREE IMAGE to evaluate the denoising effects: ";
	getline(cin, strOriginalFileName);
	// strFileName = "Flower_gray_noisy";
	// strOriginalFileName = "Flower_gray";
	if (".raw" != strFileName.substr(strFileName.length()-4, strFileName.length()-1))
	{
		strFileName += ".raw";
	}
	if (".raw" != strOriginalFileName.substr(strOriginalFileName.length()-4, strOriginalFileName.length()-1))
	{
		strOriginalFileName += ".raw";
	}
	cout<<endl;

	vector<vector<vector<unsigned char> > > vecImageData_d;
	vector<vector<vector<unsigned char> > > vecOriImageData_d;
	vector<vector<vector<unsigned char> > > vecTransData_d(ROW0, vector<vector<unsigned char> >(COL0, vector<unsigned char>(RGBCHANNEL, 0)));
	vector<vector<vector<unsigned char> > > vecImageData_R(ROW0, vector<vector<unsigned char> >(COL0, vector<unsigned char>(MONOCHANNEL, 0)));
	vector<vector<vector<unsigned char> > > vecImageData_G(ROW0, vector<vector<unsigned char> >(COL0, vector<unsigned char>(MONOCHANNEL, 0)));
	vector<vector<vector<unsigned char> > > vecImageData_B(ROW0, vector<vector<unsigned char> >(COL0, vector<unsigned char>(MONOCHANNEL, 0)));
	vector<vector<vector<unsigned char> > > vecTransImageData_R;
	vector<vector<vector<unsigned char> > > vecTransImageData_G;
	vector<vector<vector<unsigned char> > > vecTransImageData_B;
	vector<vector<vector<unsigned char> > > vecDiffData_R(ROW0, vector<vector<unsigned char> >(COL0, vector<unsigned char>(MONOCHANNEL, 0)));
	vector<vector<vector<unsigned char> > > vecDiffData_G(ROW0, vector<vector<unsigned char> >(COL0, vector<unsigned char>(MONOCHANNEL, 0)));
	vector<vector<vector<unsigned char> > > vecDiffData_B(ROW0, vector<vector<unsigned char> >(COL0, vector<unsigned char>(MONOCHANNEL, 0)));
	map<unsigned char, int> mapHistgData_d;

	cout<<"Part <d> processing starts..."<<endl<<endl;

	//extract three channels
	if (0== ReadImage(strFileName, vecImageData_d, 2) && 0 == ReadImage(strOriginalFileName, vecOriImageData_d, 2))
	{
		for (int nRow = 0; nRow < ROW0; nRow++)
		{
			for (int nCol = 0; nCol < COL0; nCol++)
			{
				vecImageData_R[nRow][nCol][0] = vecImageData_d[nRow][nCol][0];
				vecImageData_G[nRow][nCol][0] = vecImageData_d[nRow][nCol][1];
				vecImageData_B[nRow][nCol][0] = vecImageData_d[nRow][nCol][2];

				vecDiffData_R[nRow][nCol][0] = abs(vecImageData_d[nRow][nCol][0] - vecOriImageData_d[nRow][nCol][0]);
				vecDiffData_G[nRow][nCol][0] = abs(vecImageData_d[nRow][nCol][1] - vecOriImageData_d[nRow][nCol][1]);
				vecDiffData_B[nRow][nCol][0] = abs(vecImageData_d[nRow][nCol][1] - vecOriImageData_d[nRow][nCol][1]);
			}
		}

		GenerateHistogramData(vecImageData_R, mapHistgData_d, 2, true, strFileName.substr(0, strFileName.length()-4)+"_Rchannel_histogram.csv");
		// GenerateHistogramData(vecImageData_G, mapHistgData_d, 2, true, strFileName.substr(0, strFileName.length()-4)+"_Gchannel_histogram.csv");
		// GenerateHistogramData(vecImageData_B, mapHistgData_d, 2, true, strFileName.substr(0, strFileName.length()-4)+"_Bchannel_histogram.csv");
		GenerateHistogramData(vecDiffData_R, mapHistgData_d, 2, true, strFileName.substr(0, strFileName.length()-4)+"_R_diff_histogram.csv");
		// GenerateHistogramData(vecDiffData_G, mapHistgData_d, 2, true, strFileName.substr(0, strFileName.length()-4)+"_G_diff_histogram.csv");
		// GenerateHistogramData(vecDiffData_B, mapHistgData_d, 2, true, strFileName.substr(0, strFileName.length()-4)+"_B_diff_histogram.csv");

		BilateralFilter(vecImageData_R, vecTransImageData_R, 3, 20, 50);
		BilateralFilter(vecImageData_G, vecTransImageData_G, 3, 20, 50);
		BilateralFilter(vecImageData_B, vecTransImageData_B, 3, 20, 50);
		for (int nRow = 0; nRow < ROW0; nRow++)
		{
			for (int nCol = 0; nCol < COL0; nCol++)
			{
				vecTransData_d[nRow][nCol][0] = vecTransImageData_R[nRow][nCol][0];
				vecTransData_d[nRow][nCol][1] = vecTransImageData_G[nRow][nCol][0];
				vecTransData_d[nRow][nCol][2] = vecTransImageData_B[nRow][nCol][0];
			}
		}
		WriteImage(strFileName, vecTransData_d,"_RGB_Bilateral", 2);

		cout<<endl<<"Part <d> operating success!"<<endl<<endl;

	}else{
		cout<<endl<<"Part <d> operating error!"<<endl<<endl;
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

////////////////////////////////////////////////////////////////////
//////////		FUNCTIONS in Part(A) IMPLEMENTATION	   		////////
////////////////////////////////////////////////////////////////////

int LowPassFilterMean(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputeData, int nKernalSize)
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
				vecTemp[nRow][nCol][0] = (vecInputData[nUp1][nLeft1][0] + vecInputData[nUp1][nCol][0] + vecInputData[nUp1][nRight1][0]+
										  vecInputData[nRow][nLeft1][0] + vecInputData[nRow][nCol][0] + vecInputData[nRow][nRight1][0]+
										  vecInputData[nDown1][nLeft1][0] + vecInputData[nDown1][nCol][0] + vecInputData[nDown1][nRight1][0]) /9;
				
			}else if(nKernalSize == 5)
			{
				//Apply the filter
				vecTemp[nRow][nCol][0] = (vecInputData[nUp2][nLeft2][0] + vecInputData[nUp2][nLeft1][0] + vecInputData[nUp2][nCol][0] + vecInputData[nUp2][nRight1][0] + vecInputData[nUp2][nRight2][0] +
										  vecInputData[nUp1][nLeft2][0] + vecInputData[nUp1][nLeft1][0] + vecInputData[nUp1][nCol][0] + vecInputData[nUp1][nRight1][0] + vecInputData[nUp1][nRight2][0] +
										  vecInputData[nRow][nLeft2][0] + vecInputData[nRow][nLeft1][0] + vecInputData[nRow][nCol][0] + vecInputData[nRow][nRight1][0] + vecInputData[nRow][nRight2][0] +
										  vecInputData[nDown1][nLeft2][0] + vecInputData[nDown1][nLeft1][0] + vecInputData[nDown1][nCol][0] + vecInputData[nDown1][nRight1][0] + vecInputData[nDown1][nRight2][0] +
										  vecInputData[nDown2][nLeft2][0] + vecInputData[nDown2][nLeft1][0] + vecInputData[nDown2][nCol][0] + vecInputData[nDown2][nRight1][0] + vecInputData[nDown2][nRight2][0] ) /25;
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
		cout<< "Low Pass Filter (mean) of Kernal size <3*3> has been appied to the image. "<<endl;
	}else
	{
		cout<< "Low Pass Filter (mean) of Kernal size <5*5> has been appied to the image. "<<endl;
	}

	return 0;
}


int LowPassFilterGaussian(vector<vector<vector<unsigned char> > > vecInputData, vector<vector<vector<unsigned char> > > &vecOutputeData, int nKernalSize)
{
	int nMaxRow = ROW0, nMaxCol = COL0, nMaxChannel = MONOCHANNEL;

	if (nKernalSize != 3 && nKernalSize != 5)
	{
		cout<< "Wrong Kernal size for the filter!";
		return 1;
	}

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
				vecTemp[nRow][nCol][0] = (1* vecInputData[nUp1][nLeft1][0] + 2* vecInputData[nUp1][nCol][0] + 1* vecInputData[nUp1][nRight1][0]+
										  2* vecInputData[nRow][nLeft1][0] + 4* vecInputData[nRow][nCol][0] + 2* vecInputData[nRow][nRight1][0]+
										  1* vecInputData[nDown1][nLeft1][0] + 2* vecInputData[nDown1][nCol][0] + 1* vecInputData[nDown1][nRight1][0]) /16;
				
			}else if(nKernalSize == 5)
			{
				//Apply the filter
				vecTemp[nRow][nCol][0] = (1* vecInputData[nUp2][nLeft2][0] + 4* vecInputData[nUp2][nLeft1][0] + 7* vecInputData[nUp2][nCol][0] + 4* vecInputData[nUp2][nRight1][0] + 1* vecInputData[nUp2][nRight2][0] +
										  4* vecInputData[nUp1][nLeft2][0] + 16* vecInputData[nUp1][nLeft1][0] + 26* vecInputData[nUp1][nCol][0] + 16* vecInputData[nUp1][nRight1][0] + 4* vecInputData[nUp1][nRight2][0] +
										  7* vecInputData[nRow][nLeft2][0] + 26* vecInputData[nRow][nLeft1][0] + 41* vecInputData[nRow][nCol][0] + 26* vecInputData[nRow][nRight1][0] + 7* vecInputData[nRow][nRight2][0] +
										  4* vecInputData[nDown1][nLeft2][0] + 16* vecInputData[nDown1][nLeft1][0] + 26* vecInputData[nDown1][nCol][0] + 16* vecInputData[nDown1][nRight1][0] + 4* vecInputData[nDown1][nRight2][0] +
										  1* vecInputData[nDown2][nLeft2][0] + 4* vecInputData[nDown2][nLeft1][0] + 7* vecInputData[nDown2][nCol][0] + 4* vecInputData[nDown2][nRight1][0] + 1* vecInputData[nDown2][nRight2][0] ) /273;
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
		cout<< "Low Pass Filter (Gaussian) of Kernal size <3*3> has been appied to the image. "<<endl;
	}else
	{
		cout<< "Low Pass Filter (Gaussian) of Kernal size <5*5> has been appied to the image. "<<endl;
	}

	return 0;
}


////////////////////////////////////////////////////////////////////
//////////		FUNCTIONS in Part(B) IMPLEMENTATION	   		////////
////////////////////////////////////////////////////////////////////
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


////////////////////////////////////////////////////////////////////
//////////		FUNCTIONS in Part(D) IMPLEMENTATION	   		////////
////////////////////////////////////////////////////////////////////

int GenerateHistogramData(vector<vector<vector<unsigned char> > > vecInputData, map<unsigned char, int> &mapHistgData, int nIndex, bool bSaveData, string strFileName)
{
	int nRow = ROW0;
	int nCol = COL0;
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
		nRow = ROW0;
		nCol = COL0;
		break;
	case 2:
		nRow = ROW0;
		nCol = COL0;
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
