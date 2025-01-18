#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include <complex.h>
#include <xtime_l.h>
#include "dma_init.h"
#include "xparameters.h"
#include "xaxidma.h"

#define N 8
const int rev8[N] = {0, 4, 2, 6, 1, 5, 3, 7};
const float complex W[N/2] = {1+0*I, 0.707-0.707*I, 0-1*I, -0.707-0.707*I};

void bitreverse(float complex dataIn[N], float complex dataOut[N])
{
	for(int i = 0; i < N; i++)
	{
		dataOut[i] = dataIn[rev8[i]];
	}
}

void FFT_stages(float complex FFT_input[N], float complex FFT_output[N])
{
	float complex temp1[N], temp2[N];

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
		temp2[i+1] = temp1[i+1] + W[2]*temp1[i+3];
		temp2[i+2] = temp1[i] - W[0]*temp1[i+2];
		temp2[i+3] = temp1[i+1] - W[2]*temp1[i+3];
	}

	//stage 3
	FFT_output[0] = temp2[0]+W[0]*temp2[4];
	FFT_output[1] = temp2[1]+W[1]*temp2[5];
	FFT_output[2] = temp2[2]+W[2]*temp2[6];
	FFT_output[3] = temp2[3]+W[3]*temp2[7];
	FFT_output[4] = temp2[0]-W[0]*temp2[4];
	FFT_output[5] = temp2[1]-W[1]*temp2[5];
	FFT_output[6] = temp2[2]-W[2]*temp2[6];
	FFT_output[7] = temp2[3]-W[3]*temp2[7];
}

void recp(float complex FFT_input[N], float complex FFT_output[N])
{
	for (int i = 0; i < N; i++)
	{
		FFT_output[i] = (1/creal(FFT_input[i])) + I*(1/cimagf(FFT_input[i]));
	}
}

int main()
{
    init_platform();

    XTime PS_start_time, PS_end_time;
    XTime PL_start_time, PL_end_time;

    float complex FFT_input[N];

    for (int i = 0; i < N; i++)
        {
            FFT_input[i] = i + 1.0 + (i + 1.0) * I;
        }

    float complex FFT_output_sw[N], FFT_output_hw[N];
    float complex FFT_rev_sw[N];
    float complex FFT_input_recp_sw[N];

    ////////////Hardware 8 point FFT
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

    /////////////Software 8 point FFT

    XTime_SetTime(0);
    XTime_GetTime(&PS_start_time);

    bitreverse(FFT_input, FFT_rev_sw);
    FFT_stages(FFT_rev_sw, FFT_input_recp_sw);
    recp(FFT_input_recp_sw, FFT_output_sw);

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
