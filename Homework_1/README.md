
# EE569 Homework Assignment #1

 * @author：*Boyang XIao*
 * @Email：[boyangxi@usc.edu](boyangxi@usc.edu)
 * @usc id：		3326730274  
 * @date：		2022-01-30
***
 * @IDE：		VScode C++ & Matlab
 * @Platform：	Windows 10/11
 * @compiler：	g++  --version 8.1.0
 * @IDE extensions：	C/C++ extensions for VScode & Image Processing toolbox for MATLAB
***

#### :warning: Compiling Instructions: There are two ways for you to compile and run the cpp source code files:
    1. You can open the source codes in VScode and run/debug them
    2. You can use the terminal to compile and run them. Please execute the following sentences one by one:
    	g++ .\EE569_HW1_Problem1.cpp -o EE569_Hw1_Problem1.exe
    	g++ .\EE569_HW1_Problem2.cpp -o EE569_Hw1_Problem2.exe
    	g++ .\EE569_HW1_Problem3.cpp -o EE569_Hw1_Problem3.exe
<br>

---
#### CPP SOURCE CODE : [Problem1] Project Overview
---
**File name: EE569_hw1_Problem1.cpp**

This source code file contains the solutions to Problem 1 part(a), part(b) and part of part(c). The CLAHE part of part(C) is implemented in MATLAB.

**Steps:**
1. Open the source code in VScode and run it, or compile it in the terminal using：
`g++ .\EE569_HW1_Problem1.cpp -o EE569_Hw1_Problem1.exe" and run it.`

2. Follow the instruction information in the terminal. Generally, every part of the problem will ask you to type in the Image file name and press "enter" to continue.

3. After each part's execution, the program will generate several new Image raw files containing the processing results.
	The generated files are named as the original file names with a suffix. Such as the demosaiced image will be named as **"OriginalFile_demosaiced.raw"**. 
<br>

---
####    MATLAB SCRIPT : [Problem1 PART C] Project Overview
---
**File name: EE569_hw1_Problem1_c.m**

This source code includes the solution to Problem1 part(c), the CLAHE part of this problem.

**Steps:**

1. Open the source code in MATLAB.

2. Run the code and follow the instruction information in the terminal of MATLAB.

3. The results image will be saved as **"OriginalFile_CLAHE.raw"** in the same folder.
<br>

----------------------------------------------------------------------
#### CPP SOURCE CODE : [Problem2] Project Overview
----------------------------------------------------------------------
**File name: EE569_hw1_Problem2.cpp**

This source code file contains the solutions to Problem 2 part(a), part(b) and part(d). The NLM filtering part of part(C) is implemented in MATLAB and some part of part(d) is implemented in MATLAB.

**Steps:**

1. Open the source code in VScode and run it, or compile it in the terminal using:
`g++ .\EE569_HW1_Problem2.cpp -o EE569_Hw1_Problem2.exe" and run it.`

2. Follow the instruction information in the terminal. Generally, every part of the problem will ask you to type in the Image file name and press "enter" to continue.

3. After each part's execution, the program will generate several new Image raw files containing the processing results.
	The generated files are named as the original file names with a suffix. Such as the denoised image with a Bilateral filter of 3*3 kernel size will be named as **"OriginalFile_bilateral_3.raw"**. 

4. Please see the terminal information to find the generated file name for each part.
<br>

----------------------------------------------------------------------
#### MATLAB SCRIPT : [Problem2 PART C] Project Overview
----------------------------------------------------------------------
**File name:** EE569_hw1_Problem2_c.m

This source code file contains the solution to Problem 2 part (c), the NLM filtering.

**Steps:**

1. Open the source code in MATLAB.

2. Run the code and follow the instruction information in the terminal of MATLAB.

3. The results image will be saved as **"OriginalFile_NLM.raw"** in the same folder.
<br>

----------------------------------------------------------------------
#### MATLAB SCRIPT : [Problem2 PART D] Project Overview
----------------------------------------------------------------------
**File name:** EE569_hw1_Problem2_d.m

This source code file contains the solution to Problem 2 part (d), the NLM filtering for RGB images.

**Steps:**

1. Open the source code in MATLAB.

2. Run the code and follow the instruction information in the terminal of MATLAB.

3. The results image will be saved as **"OriginalFile_RGB_NLM.raw"** in the same folder.

4. If you want to apply a series of NLM filters and bilateral filters to a image, you can run this MATLAB script and the part(d) of EE569_hw1_Problem2.cpp file for multiple times.

----------------------------------------------------------------------
#### CPP SOURCE CODE : [Problem3] Project Overview
----------------------------------------------------------------------
**File name:** EE569_hw1_Problem3.cpp

This source code file contains the solutions to Problem 3.

**Steps:**

1. Open the source code in VScode and run it, or compile it in the terminal using:
`g++ .\EE569_HW1_Problem3.cpp -o EE569_Hw1_Problem3.exe" and run it.`

2. Follow the instruction information in the terminal. Generally, every part of the problem will ask you to type in the Image file name and press "enter" to continue.

3. After each part's execution, the program will generate several new Image raw files containing the processing results.
	The generated files are named as the original file names with a suffix. Such as the denoised image with a Bilateral filter of 3*3 kernel size will be named as **"OriginalFile_bilateral_3.raw"**. 

4. Please see the terminal information to find the generated file name for each part.
