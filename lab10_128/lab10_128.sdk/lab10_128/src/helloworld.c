//128 FFT code for sdk

#include <stdio.h>
#include <complex.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include <xtime_l.h>
#include "xparameters.h"
#include "xaxidma.h"
#include "dma_init.h"

#define N 128  // FFT Size

// Predefined bit-reversal indices and twiddle factors for 128-point FFT
const int rev128[N] = {
    0, 64, 32, 96, 16, 80, 48, 112, 8, 72, 40, 104, 24, 88, 56, 120,
    4, 68, 36, 100, 20, 84, 52, 116, 12, 76, 44, 108, 28, 92, 60, 124,
    2, 66, 34, 98, 18, 82, 50, 114, 10, 74, 42, 106, 26, 90, 58, 122,
    6, 70, 38, 102, 22, 86, 54, 118, 14, 78, 46, 110, 30, 94, 62, 126,
    1, 65, 33, 97, 17, 81, 49, 113, 9, 73, 41, 105, 25, 89, 57, 121,
    5, 69, 37, 101, 21, 85, 53, 117, 13, 77, 45, 109, 29, 93, 61, 125,
    3, 67, 35, 99, 19, 83, 51, 115, 11, 75, 43, 107, 27, 91, 59, 123,
    7, 71, 39, 103, 23, 87, 55, 119, 15, 79, 47, 111, 31, 95, 63, 127
};

const float complex W[N / 2] = {
    1.0 - 0.0 * I, 0.9987954562051724 - 0.049067674327418015 * I,
    0.9951847266721969 - 0.0980171403295606 * I, 0.989176509964781 - 0.14673047445536175 * I,
    0.9807852804032304 - 0.19509032201612825 * I, 0.970031253194544 - 0.24298017990326387 * I,
    0.9569403357322088 - 0.29028467725446233 * I, 0.9415440651830208 - 0.33688985339222005 * I,
    0.9238795325112867 - 0.3826834323650898 * I, 0.9039892931234433 - 0.4275550934302821 * I,
    0.881921264348355 - 0.47139673682599764 * I, 0.8577286100002721 - 0.5141027441932217 * I,
    0.8314696123025452 - 0.5555702330196022 * I, 0.8032075314806449 - 0.5956993044924334 * I,
    0.773010453362737 - 0.6343932841636455 * I, 0.7409511253549591 - 0.6715589548470183 * I,
    0.7071067811865476 - 0.7071067811865475 * I, 0.6715589548470183 - 0.7409511253549591 * I,
    0.6343932841636455 - 0.773010453362737 * I, 0.5956993044924335 - 0.8032075314806448 * I,
    0.5555702330196023 - 0.8314696123025452 * I, 0.5141027441932217 - 0.8577286100002721 * I,
    0.4713967368259978 - 0.8819212643483549 * I, 0.4275550934302822 - 0.9039892931234433 * I,
    0.38268343236508984 - 0.9238795325112867 * I, 0.33688985339222033 - 0.9415440651830207 * I,
    0.2902846772544624 - 0.9569403357322088 * I, 0.24298017990326407 - 0.970031253194544 * I,
    0.19509032201612833 - 0.9807852804032304 * I, 0.14673047445536175 - 0.989176509964781 * I,
    0.09801714032956083 - 0.9951847266721968 * I, 0.049067674327418126 - 0.9987954562051724 * I,
    0.0 - 1.0 * I, -0.04906767432741801 - 0.9987954562051724 * I,
    -0.09801714032956059 - 0.9951847266721969 * I, -0.14673047445536164 - 0.989176509964781 * I,
    -0.1950903220161282 - 0.9807852804032304 * I, -0.24298017990326387 - 0.970031253194544 * I,
    -0.29028467725446216 - 0.9569403357322089 * I, -0.3368898533922201 - 0.9415440651830208 * I,
    -0.3826834323650897 - 0.9238795325112867 * I, -0.42755509343028203 - 0.9039892931234434 * I,
    -0.4713967368259977 - 0.881921264348355 * I, -0.5141027441932216 - 0.8577286100002721 * I,
    -0.555570233019602 - 0.8314696123025455 * I, -0.5956993044924334 - 0.803207531480645 * I,
    -0.6343932841636454 - 0.7730104533627371 * I, -0.6715589548470183 - 0.740951125354959 * I,
    -0.7071067811865475 - 0.7071067811865476 * I, -0.7409511253549589 - 0.6715589548470186 * I,
    -0.773010453362737 - 0.6343932841636455 * I, -0.8032075314806448 - 0.5956993044924335 * I,
    -0.8314696123025452 - 0.5555702330196022 * I, -0.857728610000272 - 0.5141027441932218 * I,
    -0.8819212643483549 - 0.4713967368259978 * I, -0.9039892931234433 - 0.4275550934302822 * I,
    -0.9238795325112867 - 0.3826834323650899 * I, -0.9415440651830207 - 0.33688985339222033 * I,
    -0.9569403357322088 - 0.29028467725446244 * I, -0.970031253194544 - 0.24298017990326412 * I,
    -0.9807852804032303 - 0.1950903220161286 * I, -0.989176509964781 - 0.1467304744553618 * I,
    -0.9951847266721968 - 0.0980171403295609 * I, -0.9987954562051724 - 0.04906767432741809 * I
};

// Function to perform bit-reversal
void bitreverse(float complex dataIn[N], float complex dataOut[N]) {
    for (int i = 0; i < N; i++) {
        dataOut[i] = dataIn[rev128[i]];
    }
}

// Function to compute FFT using Cooley-Tukey algorithm
void FFT_stages(float complex dataIn[N], float complex dataOut[N]) {
    float complex temp1[N], temp2[N];
    bitreverse(dataIn, temp1);

    for (int stage = 1; stage <= 7; stage++) {  // log2(N) = 7 stages for N=128
        int step = 1 << stage;                 // 2^stage
        int half_step = step / 2;

        for (int i = 0; i < N; i += step) {
            for (int j = 0; j < half_step; j++) {
                float complex t = W[(N / step) * j] * temp1[i + j + half_step];
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
    XTime PS_start_time, PS_end_time, PL_start_time, PL_end_time;

    const float complex FFT_input[N] = {
    1.0 + 2.0 * I, -1.0 + 1.0 * I, 3.0 - 4.0 * I, 0.0 + 0.0 * I,
    5.0 + 0.0 * I, 0.0 + 6.0 * I, -3.0 - 3.0 * I, 2.0 + 2.0 * I,
    7.0 - 1.0 * I, -2.0 + 3.0 * I, 0.0 - 8.0 * I, 4.0 + 5.0 * I,
    -5.0 - 5.0 * I, 6.0 + 0.0 * I, -6.0 + 4.0 * I, 3.0 - 7.0 * I,
    8.0 + 0.0 * I, 1.0 + 9.0 * I, -4.0 - 6.0 * I, 0.0 + 3.0 * I,
    2.0 + 2.0 * I, 5.0 - 5.0 * I, -1.0 + 6.0 * I, 7.0 + 7.0 * I,
    0.0 - 4.0 * I, -2.0 + 3.0 * I, 4.0 - 5.0 * I, 3.0 + 0.0 * I,
    6.0 + 6.0 * I, -8.0 + 2.0 * I, 5.0 - 3.0 * I, 1.0 + 0.0 * I,
    2.0 + 1.0 * I, 0.0 + 8.0 * I, -7.0 - 1.0 * I, 4.0 + 2.0 * I,
    3.0 - 4.0 * I, -1.0 + 2.0 * I, 0.0 + 0.0 * I, 5.0 + 0.0 * I,
    -3.0 + 3.0 * I, 2.0 + 1.0 * I, 6.0 - 2.0 * I, 0.0 + 7.0 * I,
    8.0 + 9.0 * I, -6.0 - 5.0 * I, 4.0 - 3.0 * I, -2.0 + 4.0 * I,
    7.0 + 1.0 * I, 1.0 + 3.0 * I, -5.0 + 0.0 * I, 2.0 - 7.0 * I,
    0.0 + 2.0 * I, -8.0 - 3.0 * I, 6.0 + 6.0 * I, 3.0 - 1.0 * I,
    -4.0 + 5.0 * I, 0.0 + 0.0 * I, 5.0 - 2.0 * I, -2.0 + 6.0 * I,
    1.0 + 8.0 * I, 7.0 - 3.0 * I, -3.0 + 4.0 * I, 2.0 + 0.0 * I,
    8.0 + 1.0 * I, 0.0 - 7.0 * I, -5.0 - 4.0 * I, 4.0 + 6.0 * I,
    -2.0 + 3.0 * I, 3.0 - 8.0 * I, 6.0 + 0.0 * I, -8.0 + 7.0 * I,
    0.0 + 0.0 * I, 1.0 + 5.0 * I, -4.0 - 3.0 * I, 5.0 - 6.0 * I,
    2.0 + 4.0 * I, 0.0 - 8.0 * I, 7.0 + 0.0 * I, -6.0 + 2.0 * I,
    3.0 + 3.0 * I, -1.0 + 7.0 * I, 0.0 + 6.0 * I, 8.0 - 5.0 * I,
    -3.0 - 4.0 * I, 4.0 + 2.0 * I, 5.0 - 7.0 * I, -2.0 + 1.0 * I,
    0.0 + 0.0 * I, 6.0 + 8.0 * I, -7.0 - 2.0 * I, 1.0 + 4.0 * I,
    3.0 - 3.0 * I, -4.0 + 5.0 * I, 2.0 + 0.0 * I, 0.0 + 7.0 * I,
    5.0 - 6.0 * I, -8.0 + 4.0 * I, 4.0 + 0.0 * I, 6.0 + 1.0 * I
};


    float complex FFT_output_sw[N], FFT_output_hw[N];
    XAxiDma AxiDMA;
    int status = DMA_Init(&AxiDMA, XPAR_AXI_DMA_0_DEVICE_ID);
    if (status != XST_SUCCESS) return XST_FAILURE;

    // PS Calculation
    XTime_GetTime(&PS_start_time);
    FFT_stages(FFT_input, FFT_output_sw);
    XTime_GetTime(&PS_end_time);

    // Hardware FFT Calculation
    XTime_GetTime(&PL_start_time);
    XAxiDma_SimpleTransfer(&AxiDMA, (UINTPTR)FFT_input, sizeof(float complex) * N, XAXIDMA_DMA_TO_DEVICE);
    XAxiDma_SimpleTransfer(&AxiDMA, (UINTPTR)FFT_output_hw, sizeof(float complex) * N, XAXIDMA_DEVICE_TO_DMA);

    while (XAxiDma_Busy(&AxiDMA, XAXIDMA_DMA_TO_DEVICE));
    while (XAxiDma_Busy(&AxiDMA, XAXIDMA_DEVICE_TO_DMA));
    XTime_GetTime(&PL_end_time);

    // Compare Outputs
    for (int i = 0; i < N; i++) {
        float diff1 = fabsf(crealf(FFT_output_sw[i]) - crealf(FFT_output_hw[i]));
        float diff2 = fabsf(cimagf(FFT_output_sw[i]) - cimagf(FFT_output_hw[i]));
        printf("\nIndex %d: PS Output: %f + %fi, PL Output: %f + %fi", i,
               crealf(FFT_output_sw[i]), cimagf(FFT_output_sw[i]),
               crealf(FFT_output_hw[i]), cimagf(FFT_output_hw[i]));
        if (diff1 > 0.0001 || diff2 > 0.0001) {
            printf(" -> Mismatch");
        } else {
            printf(" -> Match");
        }
    }

    printf("\nExecution time for PS: %f microseconds",
           (float)(PS_end_time - PS_start_time) / (COUNTS_PER_SECOND / 1e6));
    printf("\nExecution time for PL: %f microseconds",
           (float)(PL_end_time - PL_start_time) / (COUNTS_PER_SECOND / 1e6));

    return 0;
}
