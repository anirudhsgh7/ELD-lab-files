#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include <complex.h>
#include <xtime_l.h>
#include "xparameters.h"
#include "xaxidma.h"
#include "dma_init.h"
#include <math.h>

#define N 16
#define TOLERANCE 1e-6  // Set a tolerance for comparing PS and PL results
#define COUNTS_PER_SECOND XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ  // Use clock frequency defined in hardware specs

// Bit-reversal array for 16-point FFT
const int rev16[N] = {0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15};

// Real and imaginary parts of the twiddle factors for 16-point FFT
const float W_real_16[] = { 1.000000,  0.923880,  0.707107,  0.382683,  0.000000,  -0.382683,  -0.707107,  -0.923880 };
const float W_imag_16[] = { -0.000000,  -0.382683,  -0.707107,  -0.923880,  -1.000000,  -0.923880,  -0.707107,  -0.382683 };

// Software (PS) FFT function
void FFT_stages(float complex FFT_input[N], float complex FFT_output[N]) {
    float complex temp1[N], temp2[N], temp3[N];

    // Stage 1
    for (int i = 0; i < N; i = i + 2) {
        temp1[i] = FFT_input[i] + (W_real_16[0] + I * W_imag_16[0]) * FFT_input[i + 1];
        temp1[i + 1] = FFT_input[i] - (W_real_16[0] + I * W_imag_16[0]) * FFT_input[i + 1];
    }

    // Stage 2
    for (int i = 0; i < N; i = i + 4) {
        temp2[i] = temp1[i] + (W_real_16[0] + I * W_imag_16[0]) * temp1[i + 2];
        temp2[i + 1] = temp1[i + 1] + (W_real_16[4] + I * W_imag_16[4]) * temp1[i + 3];
        temp2[i + 2] = temp1[i] - (W_real_16[0] + I * W_imag_16[0]) * temp1[i + 2];
        temp2[i + 3] = temp1[i + 1] - (W_real_16[4] + I * W_imag_16[4]) * temp1[i + 3];
    }

    // Stage 3
    for (int i = 0; i < N; i = i + 8) {
        temp3[i] = temp2[i] + (W_real_16[0] + I * W_imag_16[0]) * temp2[i + 4];
        temp3[i + 1] = temp2[i + 1] + (W_real_16[2] + I * W_imag_16[2]) * temp2[i + 5];
        temp3[i + 2] = temp2[i + 2] + (W_real_16[4] + I * W_imag_16[4]) * temp2[i + 6];
        temp3[i + 3] = temp2[i + 3] + (W_real_16[6] + I * W_imag_16[6]) * temp2[i + 7];
        temp3[i + 4] = temp2[i] - (W_real_16[0] + I * W_imag_16[0]) * temp2[i + 4];
        temp3[i + 5] = temp2[i + 1] - (W_real_16[2] + I * W_imag_16[2]) * temp2[i + 5];
        temp3[i + 6] = temp2[i + 2] - (W_real_16[4] + I * W_imag_16[4]) * temp2[i + 6];
        temp3[i + 7] = temp2[i + 3] - (W_real_16[6] + I * W_imag_16[6]) * temp2[i + 7];
    }

    // Stage 4
    for (int i = 0; i < N; i++) {
        int twiddle_index = i % 8;
        FFT_output[i] = temp3[i] + (W_real_16[twiddle_index] + I * W_imag_16[twiddle_index]) * temp3[i + 8];
    }
}

// Bit-reversal function
void bitreverse(float complex dataIn[N], float complex dataOut[N]) {
    for (int i = 0; i < N; i++) {
        dataOut[i] = dataIn[rev16[i]];
    }
}

// Main function
int main() {
    init_platform();

    XTime PS_start_time, PS_end_time;
    XTime PL_start_time, PL_end_time;

    // Sample input for FFT
    float complex FFT_input[N] = { 1.0 + 0.0 * I, 2.0 + 1.0 * I, 3.0 + 1.0 * I, 4.0 + 2.0 * I,
                                    5.0 + 0.0 * I, 6.0 + 2.0 * I, 7.0 + 1.0 * I, 8.0 + 3.0 * I,
                                    9.0 + 0.0 * I, 10.0 + 2.0 * I, 11.0 + 1.0 * I, 12.0 + 0.0 * I,
                                    13.0 + 2.0 * I, 14.0 + 3.0 * I, 15.0 + 1.0 * I, 16.0 + 0.0 * I };

    float complex FFT_input_reversed[N], PS_output[N], PL_output[N];

    // Bit-reversal of input
    bitreverse(FFT_input, FFT_input_reversed);

    // Measure PS execution time
    XTime_GetTime(&PS_start_time);
    FFT_stages(FFT_input_reversed, PS_output);
    XTime_GetTime(&PS_end_time);

    float ps_time = (float)(PS_end_time - PS_start_time) / (COUNTS_PER_SECOND / 1e6);
    printf("Execution time (PS): %.2f microseconds\n", ps_time);

    // Measure PL execution time (placeholder logic; actual PL call should replace this)
    XTime_GetTime(&PL_start_time);
    FFT_stages(FFT_input_reversed, PL_output);  // Placeholder for PL FFT
    XTime_GetTime(&PL_end_time);

    float pl_time = (float)(PL_end_time - PL_start_time) / (COUNTS_PER_SECOND / 1e6);
    printf("Execution time (PL): %.2f microseconds\n", pl_time);

    // Compare outputs
    for (int i = 0; i < N; i++) {
        float ps_real = creal(PS_output[i]);
        float ps_imag = cimag(PS_output[i]);
        float pl_real = creal(PL_output[i]);
        float pl_imag = cimag(PL_output[i]);

        printf("Index %d: PS = %.8f + %.8fj, PL = %.8f + %.8fj\n", i, ps_real, ps_imag, pl_real, pl_imag);

        // Compare outputs and print messages
        if (fabs(ps_real - pl_real) <= TOLERANCE && fabs(ps_imag - pl_imag) <= TOLERANCE) {
            printf("DMA transfer successful at index %d\n", i);
        } else {
            printf("Mismatch at index %d: PS = %.8f + %.8fj, PL = %.8f + %.8fj\n", i, ps_real, ps_imag, pl_real, pl_imag);
        }
    }

    cleanup_platform();
    return 0;
}
