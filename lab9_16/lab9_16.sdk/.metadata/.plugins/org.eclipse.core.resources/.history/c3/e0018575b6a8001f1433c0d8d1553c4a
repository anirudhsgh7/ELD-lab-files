/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include <complex.h>
#include <xtime_l.h>
#include "xparameters.h"
#include "xaxidma.h"
#include "dma_init.h"

#define N 16
const int rev16[N] = {0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15};
const float complex W[N/2] = {1+0*I, 0.924-0.382*I, 0.707-0.707*I, 0.382-0.924*I, 0-1*I, -0.382-0.924*I, -0.707-0.707*I, -0.924-0.382*I};

void bitreverse(float complex dataIn[N], float complex dataOut[N])
{
	for(int i = 0; i < N; i++)
	{
		dataOut[i] = dataIn[rev16[i]];
	}
}

void FFT_stages(float complex FFT_input[N], float complex FFT_output[N])
{
	float complex temp1[N], temp2[N], temp3[N];

	//stage 1
	for (int i = 0; i < N; i=i+2)
	{
		temp1[i] = FFT_input[i] + W[0]*FFT_input[i+1];
		temp1[i+1] = FFT_input[i] - W[0]*FFT_input[i+1];
	}

	//stage 2
	for (int i = 0; i < N; i=i+4)
	{
		temp2[i] = temp1[i] + W[0]*temp1[i+2];
		temp2[i+1] = temp1[i+1] + W[4]*temp1[i+3];
		temp2[i+2] = temp1[i] - W[0]*temp1[i+2];
		temp2[i+3] = temp1[i+1] - W[4]*temp1[i+3];
	}

	//stage 3
	for (int i = 0; i < N; i=i+8)
	{
		temp3[i] = temp2[i] + W[0]*temp2[i+4];
		temp3[i+1] = temp2[i+1] + W[2]*temp2[i+5];
		temp3[i+2] = temp2[i+2] + W[4]*temp2[i+6];
		temp3[i+3] = temp2[i+3] + W[6]*temp2[i+7];
		temp3[i+4] = temp2[i] - W[0]*temp2[i+4];
		temp3[i+5] = temp2[i+1] - W[2]*temp2[i+5];
		temp3[i+6] = temp2[i+2] - W[4]*temp2[i+6];
		temp3[i+7] = temp2[i+3] - W[6]*temp2[i+7];
	}

	//stage 4
	FFT_output[0] = temp3[0] + W[0]*temp3[8];
	FFT_output[1] = temp3[1] + W[1]*temp3[9];
	FFT_output[2] = temp3[2] + W[2]*temp3[10];
	FFT_output[3] = temp3[3] + W[3]*temp3[11];
	FFT_output[4] = temp3[4] + W[4]*temp3[12];
	FFT_output[5] = temp3[5] + W[5]*temp3[13];
	FFT_output[6] = temp3[6] + W[6]*temp3[14];
	FFT_output[7] = temp3[7] + W[7]*temp3[15];
	FFT_output[8] = temp3[0] - W[0]*temp3[8];
	FFT_output[9] = temp3[1] - W[1]*temp3[9];
	FFT_output[10] = temp3[2] - W[2]*temp3[10];
	FFT_output[11] = temp3[3] - W[3]*temp3[11];
	FFT_output[12] = temp3[4] - W[4]*temp3[12];
	FFT_output[13] = temp3[5] - W[5]*temp3[13];
	FFT_output[14] = temp3[6] - W[6]*temp3[14];
	FFT_output[15] = temp3[7] - W[7]*temp3[15];
}


int main()
{
    init_platform();

	XTime PS_start_time, PS_end_time;
	XTime PL_start_time, PL_end_time;

	float complex FFT_input[N];
	for (int i = 0; i < N; i++)
		{
			float real, img;
			printf("Enter %d real value: ", i);
			scanf("%f", &real);
			printf("Enter %d imaginary value: ", i);
			scanf("%f", &img);

			FFT_input[i] = real+img*I;
		}

	float complex FFT_output_sw[N], FFT_output_hw[N];
	float complex FFT_rev_sw[N];

	////////////Hardware 16 point FFT
	int status;

	XAxiDma AxiDMA;
	status = DMA_Init(&AxiDMA, XPAR_AXI_DMA_0_DEVICE_ID);

	if (status)
		return 1;  //DMA Init failed

	XTime_SetTime(0);
	XTime_GetTime(&PL_start_time);

	//Simple DMA transfers
	status = XAxiDma_SimpleTransfer(&AxiDMA, (UINTPTR)FFT_output_hw, ((sizeof(float complex))*N), XAXIDMA_DEVICE_TO_DMA);
	status = XAxiDma_SimpleTransfer(&AxiDMA, (UINTPTR)FFT_input, ((sizeof(float complex))*N), XAXIDMA_DMA_TO_DEVICE);

	//Check whether transfers are complete
	while(XAxiDma_Busy(&AxiDMA,XAXIDMA_DMA_TO_DEVICE));
	//printf("\n\rDMA-to-Device Transfer Done!");

	while(XAxiDma_Busy(&AxiDMA,XAXIDMA_DEVICE_TO_DMA));
	//printf("\n\rDevice-to-DMA Transfer Done!");

	XTime_GetTime(&PL_end_time);

	/////////////Software 16 point FFT

	printf("16 point FFT\n\r");

	XTime_SetTime(0);
	XTime_GetTime(&PS_start_time);

	bitreverse(FFT_input, FFT_rev_sw);
	FFT_stages(FFT_rev_sw, FFT_output_sw);

	XTime_GetTime(&PS_end_time);

	////////////////////////Verifying hardware and software results
	for (int i = 0; i < N; i++)
	{
		printf("\n\rPS Output: %f + %fI, PL Output: %f + %fI", crealf(FFT_output_sw[i]), cimagf(FFT_output_sw[i]), crealf(FFT_output_hw[i]), cimagf(FFT_output_hw[i]));
		float diff1 = abs(crealf(FFT_output_sw[i]) - crealf(FFT_output_hw[i]));
		float diff2 = abs(cimagf(FFT_output_sw[i]) - cimagf(FFT_output_hw[i]));

		if (diff1 >= 0.0001 && diff2 >= 0.0001)
		{
			printf("\n\rData Mismatch found at index %d!", i);
			break;
		}

		else
		{
			printf("\nDMA transfer successful!");
		}
	}

	///////////////Hardware and Software Execution Time Calculation

	float time = 0;
	time = (float) 1.0*(PS_end_time-PS_start_time)/(COUNTS_PER_SECOND/1000000);
	printf("\n\rExecution time for PS in microseconds: %f", time);

	time = 0;
	time = (float) 1.0*(PL_end_time-PL_start_time)/(COUNTS_PER_SECOND/1000000);
	printf("\n\rExecution time for PL in microseconds: %f", time);

	cleanup_platform();
	return 0;

}
