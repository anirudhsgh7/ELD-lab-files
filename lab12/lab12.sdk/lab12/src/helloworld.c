#include <stdio.h>
#include <complex.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include <xtime_l.h>
#include "xparameters.h"
#include "xaxidma.h"
#include "dma_init.h"

#define N 8

const int rev8[N] = {0, 4, 2, 6, 1, 5, 3, 7};
const float complex W[N / 2] = {
    1 - 0 * I, 0.7071067811865476 - 0.7071067811865475 * I, 0.0 - 1 * I, -0.7071067811865476 - 0.7071067811865475 * I
};

void bitreverse(float complex dataIn[N], float complex dataOut[N]) {
    for (int i = 0; i < N; i++) {
        dataOut[i] = dataIn[rev8[i]];
    }
}

void FFT_stages(float complex dataIn[N], float complex dataOut[N]) {
    float complex temp1[N], temp2[N];
    bitreverse(dataIn, temp1);

    for (int stage = 1; stage <= 3; stage++) {
        int step = 1 << stage;
        int half_step = step / 2;

        for (int i = 0; i < N; i += step) {
            for (int j = 0; j < half_step; j++) {
                float complex t = W[N / step * j] * temp1[i + j + half_step];
                temp2[i + j] = temp1[i + j] + t;
                temp2[i + j + half_step] = temp1[i + j] - t;
            }
        }
        for (int i = 0; i < N; i++) temp1[i] = temp2[i];
    }
    for (int i = 0; i < N; i++) dataOut[i] = temp1[i];
}

void recp(float complex FFT_input[N], float complex FFT_output[N]) {
    for (int i = 0; i < N; i++) {
        FFT_output[i] = (1 / creal(FFT_input[i])) + I * (1 / cimagf(FFT_input[i]));
    }
}

int main() {
    init_platform();
    XTime PL_start_time, PL_end_time;
    XTime PS_start_time, PS_end_time;

    const float complex FFT_input[N] = {
        100 + 200 * I, 300 + 100 * I, 500 + 600 * I, 700 + 800 * I,
        9 + 10 * I, 1100 + 1200 * I, 1300 + 1400 * I, 1500 + 1600 * I
    };

    float complex FFT_output_sw[N], FFT_output_hw[N];
    float complex FFT_input_recp_sw[N];

    // Software 8-point FFT (processor)
    XTime_SetTime(0);
    XTime_GetTime(&PS_start_time);
    recp(FFT_input, FFT_input_recp_sw);
    FFT_stages(FFT_input_recp_sw, FFT_output_sw);
    XTime_GetTime(&PS_end_time);

    // Hardware 8-point FFT (FPGA)
    int status;
    XAxiDma AxiDMA;
    status = DMA_Init(&AxiDMA, XPAR_AXI_DMA_0_DEVICE_ID);

    XTime_SetTime(0);
    XTime_GetTime(&PL_start_time);

    // Transfer input data to FPGA
    status = XAxiDma_SimpleTransfer(&AxiDMA, (UINTPTR)FFT_input, (sizeof(float complex) * N), XAXIDMA_DMA_TO_DEVICE);
    status = XAxiDma_SimpleTransfer(&AxiDMA, (UINTPTR)FFT_output_hw, (sizeof(float complex) * N), XAXIDMA_DEVICE_TO_DMA);

    while (XAxiDma_Busy(&AxiDMA, XAXIDMA_DMA_TO_DEVICE));
    while (XAxiDma_Busy(&AxiDMA, XAXIDMA_DEVICE_TO_DMA));

    XTime_GetTime(&PL_end_time);

    // Verifying Hardware result with Software
    for (int i = 0; i < N; i++) {
        float diff1 = fabsf(crealf(FFT_output_sw[i]) - crealf(FFT_output_hw[i]));
        float diff2 = fabsf(cimagf(FFT_output_sw[i]) - cimagf(FFT_output_hw[i]));

        printf("\nPS Output: %f+%fI, PL Output: %f+%fI", crealf(FFT_output_sw[i]), cimagf(FFT_output_sw[i]),
               crealf(FFT_output_hw[i]), cimagf(FFT_output_hw[i]));

        if (diff1 > 0.0001 || diff2 > 0.0001) {
            printf("\nData Mismatch at index %d!", i);
        } else {
            printf("\nDMA Transfer Successful!");
        }
    }

    // Software & Hardware Execution Time calculation
    printf("\n\r------- Execution Time Comparison --------");
    float time = (float)1.0 * (PS_end_time - PS_start_time) / (COUNTS_PER_SECOND / 1000000);
    printf("\n\rExecution time for PS in Micro-seconds: %f", time);

    time = (float)1.0 * (PL_end_time - PL_start_time) / (COUNTS_PER_SECOND / 1000000);
    printf("\n\rExecution time for PL in Micro-seconds: %f", time);

    return 0;
}
