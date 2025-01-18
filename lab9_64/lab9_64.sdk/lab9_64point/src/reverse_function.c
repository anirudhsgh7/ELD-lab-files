#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <complex.h>
#include <xtime_l.h>
#include "xaxidma.h"
#include "platform.h"
#include "fftsw.h"

#define reverse(n) ((n & 0x1) << 5) | ((n & 0x2) << 3) | ((n & 0x4) << 1) | ((n & 0x8) >> 1) | (n & 0x10) >> 3 | ((n & 0x20) >> 5)

// FFT computation on Processor
void FFT_PS(double FFTIn_I[FFTSIZE], double FFTIn_R[FFTSIZE], double FFTOut_I[FFTSIZE], double FFTOut_R[FFTSIZE]) {
    DTYPE temp_R, temp_I;   // Temporary storage for complex values
    int i, j, i_lower;      // Loop indexes and lower point index
    int stage, subFFTSIZE, BFWidth;

    // Bit-Reversal
    for (i = 0; i < FFTSIZE; ++i) {
        FFTOut_R[reverse(i)] = FFTIn_R[i];
        FFTOut_I[reverse(i)] = FFTIn_I[i];
    }

    // FFT computation across stages
    for (stage = 1; stage <= FFTSTAGES; stage++) {
        subFFTSIZE = 1 << stage;
        BFWidth = subFFTSIZE >> 1;

        for (j = 0; j < BFWidth; j++) {
            DTYPE BFWeight_R = W_real[j * (FFTSIZE >> stage)];
            DTYPE BFWeight_I = W_imag[j * (FFTSIZE >> stage)];

            for (i = j; i < FFTSIZE; i += subFFTSIZE) {
                i_lower = i + BFWidth;
                temp_R = FFTOut_R[i_lower] * BFWeight_R - FFTOut_I[i_lower] * BFWeight_I;
                temp_I = FFTOut_I[i_lower] * BFWeight_R + FFTOut_R[i_lower] * BFWeight_I;

                FFTOut_R[i_lower] = FFTOut_R[i] - temp_R;
                FFTOut_I[i_lower] = FFTOut_I[i] - temp_I;
                FFTOut_R[i] = FFTOut_R[i] + temp_R;
                FFTOut_I[i] = FFTOut_I[i] + temp_I;
            }
        }
    }
}

// Main Function
int main() {
    init_platform();

    double FFT_input_I[FFTSIZE] = {0};
    double FFT_input_R[FFTSIZE] = {0};
    double FFT_output_I[FFTSIZE] = {0};
    double FFT_output_R[FFTSIZE] = {0};

    // Initialize random inputs
    for (int i = 0; i < FFTSIZE; i++) {
        FFT_input_R[i] = rand() % 2000 / 1000.0;  // Random real inputs
        FFT_input_I[i] = rand() % 2000 / 1000.0;  // Random imaginary inputs
    }

    // Perform FFT
    FFT_PS(FFT_input_I, FFT_input_R, FFT_output_I, FFT_output_R);

    // Display results
    for (int i = 0; i < FFTSIZE; i++) {
        printf("Output[%d]: Real = %lf, Imag = %lf\n", i, FFT_output_R[i], FFT_output_I[i]);
    }

    cleanup_platform();
    return 0;
}
