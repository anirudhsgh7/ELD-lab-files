//64 POINT FFT

#include <stdio.h>
#include <complex.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include <xtime_l.h>
#include "xparameters.h"
#include "xaxidma.h"
#include "dma_init.h"

#define N 64  // FFT Size

// Predefined bit-reversal indices and twiddle factors for 64-point FFT
const int rev64[N] = {0, 32, 16, 48, 8, 40, 24, 56, 4, 36, 20, 52, 12, 44, 28, 60,
                      2, 34, 18, 50, 10, 42, 26, 58, 6, 38, 22, 54, 14, 46, 30, 62,
                      1, 33, 17, 49, 9, 41, 25, 57, 5, 37, 21, 53, 13, 45, 29, 61,
                      3, 35, 19, 51, 11, 43, 27, 59, 7, 39, 23, 55, 15, 47, 31, 63};
const float complex W[N / 2] = {
    1 - 0 * I, 0.9951847266721969 - 0.0980171403295606 * I, 0.9807852804032304 - 0.19509032201612825 * I,
    0.9569403357322088 - 0.29028467725446233 * I, 0.9238795325112867 - 0.3826834323650898 * I,
    0.881921264348355 - 0.47139673682599764 * I, 0.8314696123025452 - 0.5555702330196022 * I,
    0.773010453362737 - 0.6343932841636455 * I, 0.7071067811865476 - 0.7071067811865475 * I,
    0.6343932841636455 - 0.773010453362737 * I, 0.5555702330196023 - 0.8314696123025452 * I,
    0.4713967368259978 - 0.8819212643483549 * I, 0.38268343236508984 - 0.9238795325112867 * I,
    0.29028467725446233 - 0.9569403357322088 * I, 0.19509032201612833 - 0.9807852804032304 * I,
    0.09801714032956083 - 0.9951847266721968 * I, 0.0 - 1.0 * I, -0.09801714032956059 - 0.9951847266721969 * I,
    -0.1950903220161282 - 0.9807852804032304 * I, -0.29028467725446216 - 0.9569403357322089 * I,
    -0.3826834323650897 - 0.9238795325112867 * I, -0.4713967368259977 - 0.881921264348355 * I,
    -0.555570233019602 - 0.8314696123025455 * I, -0.6343932841636454 - 0.7730104533627371 * I,
    -0.7071067811865475 - 0.7071067811865476 * I, -0.773010453362737 - 0.6343932841636455 * I,
    -0.8314696123025452 - 0.5555702330196022 * I, -0.8819212643483549 - 0.47139673682599786 * I,
    -0.9238795325112867 - 0.3826834323650899 * I, -0.9569403357322088 - 0.2902846772544624 * I,
    -0.9807852804032304 - 0.1950903220161286 * I, -0.9951847266721968 - 0.09801714032956108 * I};

// Function to perform bit-reversal
void bitreverse(float complex dataIn[N], float complex dataOut[N]) {
    for (int i = 0; i < N; i++) {
        dataOut[i] = dataIn[rev64[i]];
    }
}

// Function to compute FFT using Cooley-Tukey algorithm
void FFT_stages(float complex dataIn[N], float complex dataOut[N]) {
    float complex temp1[N], temp2[N];
    bitreverse(dataIn, temp1);

    for (int stage = 1; stage <= 6; stage++) {  // log2(N) = 6 stages for N=64
        int step = 1 << stage;                 // 2^stage
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

// Main function
int main() {
    init_platform();
    // Timer variables
    XTime PS_start_time, PS_end_time, PL_start_time, PL_end_time;

    // FFT buffers
    const float complex FFT_input[N] = {
        1.0 + 0.0 * I, 2.0 + 0.0 * I, 3.0 + 0.0 * I, 4.0 + 0.0 * I,
        5.0 + 0.0 * I, 6.0 + 0.0 * I, 7.0 + 0.0 * I, 8.0 + 0.0 * I,
        9.0 + 0.0 * I, 10.0 + 0.0 * I, 11.0 + 0.0 * I, 12.0 + 0.0 * I,
        13.0 + 0.0 * I, 14.0 + 0.0 * I, 15.0 + 0.0 * I, 16.0 + 0.0 * I,
        17.0 + 0.0 * I, 18.0 + 0.0 * I, 19.0 + 0.0 * I, 20.0 + 0.0 * I,
        21.0 + 0.0 * I, 22.0 + 0.0 * I, 23.0 + 0.0 * I, 24.0 + 0.0 * I,
        25.0 + 0.0 * I, 26.0 + 0.0 * I, 27.0 + 0.0 * I, 28.0 + 0.0 * I,
        29.0 + 0.0 * I, 30.0 + 0.0 * I, 31.0 + 0.0 * I, 32.0 + 0.0 * I,
        33.0 + 0.0 * I, 34.0 + 0.0 * I, 35.0 + 0.0 * I, 36.0 + 0.0 * I,
        37.0 + 0.0 * I, 38.0 + 0.0 * I, 39.0 + 0.0 * I, 40.0 + 0.0 * I,
        41.0 + 0.0 * I, 42.0 + 0.0 * I, 43.0 + 0.0 * I, 44.0 + 0.0 * I,
        45.0 + 0.0 * I, 46.0 + 0.0 * I, 47.0 + 0.0 * I, 48.0 + 0.0 * I,
        49.0 + 0.0 * I, 50.0 + 0.0 * I, 51.0 + 0.0 * I, 52.0 + 0.0 * I,
        53.0 + 0.0 * I, 54.0 + 0.0 * I, 55.0 + 0.0 * I, 56.0 + 0.0 * I,
        57.0 + 0.0 * I, 58.0 + 0.0 * I, 59.0 + 0.0 * I, 60.0 + 0.0 * I,
        61.0 + 0.0 * I, 62.0 + 0.0 * I, 63.0 + 0.0 * I, 64.0 + 0.0 * I
    };
    float complex FFT_output_sw[N], FFT_output_hw[N];

    // PS FFT Calculation
    XTime_GetTime(&PS_start_time);
    FFT_stages(FFT_input, FFT_output_sw);
    XTime_GetTime(&PS_end_time);

    // Hardware FFT Calculation
    XAxiDma AxiDMA;
    int status = DMA_Init(&AxiDMA, XPAR_AXI_DMA_0_DEVICE_ID);
    if (status != XST_SUCCESS) {
        printf("\nDMA Initialization Failed!");
        return XST_FAILURE;
    }

    XTime_GetTime(&PL_start_time);

    // Transfer input data to FPGA
    status = XAxiDma_SimpleTransfer(&AxiDMA, (UINTPTR)FFT_input, sizeof(float complex) * N, XAXIDMA_DMA_TO_DEVICE);
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Retrieve output data from FPGA
    status = XAxiDma_SimpleTransfer(&AxiDMA, (UINTPTR)FFT_output_hw, sizeof(float complex) * N, XAXIDMA_DEVICE_TO_DMA);
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Wait for transfers to complete
    while (XAxiDma_Busy(&AxiDMA, XAXIDMA_DMA_TO_DEVICE));
    while (XAxiDma_Busy(&AxiDMA, XAXIDMA_DEVICE_TO_DMA));

    XTime_GetTime(&PL_end_time);

    // Compare outputs
    for (int i = 0; i < N; i++) {
        float diff1 = fabsf(crealf(FFT_output_sw[i]) - crealf(FFT_output_hw[i]));
        float diff2 = fabsf(cimagf(FFT_output_sw[i]) - cimagf(FFT_output_hw[i]));

        printf("\nPS Output: %f+%fI, PL Output: %f+%fI", crealf(FFT_output_sw[i]), cimagf(FFT_output_sw[i]),
               crealf(FFT_output_hw[i]), cimagf(FFT_output_hw[i]));

        if (diff1 > 0.0001 || diff2 > 0.0001) {
            printf("\nData Mismatch at index %d!", i);
        } else {
            printf("\nOutput Matched at index %d!", i);
        }
    }

    // Execution Time Comparison
    printf("\n\n------- Execution Time Comparison --------");
    printf("\nExecution time for PS: %f microseconds",
           (float)(PS_end_time - PS_start_time) / (COUNTS_PER_SECOND / 1e6));
    printf("\nExecution time for PL: %f microseconds",
           (float)(PL_end_time - PL_start_time) / (COUNTS_PER_SECOND / 1e6));

    return 0;
}
