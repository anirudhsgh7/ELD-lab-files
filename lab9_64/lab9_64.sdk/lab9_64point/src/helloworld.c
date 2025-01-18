#include <stdio.h>
#include <stdlib.h>
#include <complex.h>
#include <xtime_l.h>
#include "platform.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "fftsw.h"

#define reverse(n) ((n & 0x1) << 5) | ((n & 0x2) << 3) | ((n & 0x4) << 1) | ((n & 0x8) >> 1) | (n & 0x10) >> 3 | ((n & 0x20) >> 5)

// FFT function with Inverse FFT normalization
void FFT(double INPUT_I[FFTSIZE], double INPUT_R[FFTSIZE], double FFT_out_R[FFTSIZE], double FFT_out_I[FFTSIZE]) {
    double OUTPUT_R[FFTSIZE];
    double OUTPUT_I[FFTSIZE];
    DTYPE temp_R, temp_I;

    // Bit-Reversal
    for (int i = 0; i < FFTSIZE; ++i) {
        OUTPUT_R[reverse(i)] = INPUT_R[i];
        OUTPUT_I[reverse(i)] = INPUT_I[i];
    }

    // FFT computation
    for (int stage = 1; stage <= FFTSTAGES; stage++) {
        int subFFTSize = 1 << stage;
        int BFWidth = subFFTSize >> 1;

        for (int j = 0; j < BFWidth; j++) {
            DTYPE Weight_R = W_real[j * (FFTSIZE >> stage)];
            DTYPE Weight_I = W_imag[j * (FFTSIZE >> stage)];

            for (int i = j; i < FFTSIZE; i += subFFTSize) {
                int i_lower = i + BFWidth;
                temp_R = OUTPUT_R[i_lower] * Weight_R - OUTPUT_I[i_lower] * Weight_I;
                temp_I = OUTPUT_I[i_lower] * Weight_R + OUTPUT_R[i_lower] * Weight_I;

                OUTPUT_R[i_lower] = OUTPUT_R[i] - temp_R;
                OUTPUT_I[i_lower] = OUTPUT_I[i] - temp_I;
                OUTPUT_R[i] = OUTPUT_R[i] + temp_R;
                OUTPUT_I[i] = OUTPUT_I[i] + temp_I;
            }
        }
    }

    for (int i = 0; i < FFTSIZE; i++) {
        FFT_out_R[i] = OUTPUT_R[i];
        FFT_out_I[i] = OUTPUT_I[i];
    }
}

int main() {
    init_platform();

    double INPUT_I[FFTSIZE] = {0};
    double INPUT_R[FFTSIZE] = {0};
    double FFT_out_R[FFTSIZE];
    double FFT_out_I[FFTSIZE];

    // Initialize random inputs
    for (int i = 0; i < FFTSIZE; i++) {
        INPUT_R[i] = rand() % 2000 / 1000.0;
        INPUT_I[i] = rand() % 2000 / 1000.0;
    }

    FFT(INPUT_I, INPUT_R, FFT_out_R, FFT_out_I);

    for (int i = 0; i < FFTSIZE; i++) {
        printf("FFT Output[%d]: Real = %lf, Imag = %lf\n", i, FFT_out_R[i], FFT_out_I[i]);
    }

    cleanup_platform();
    return 0;
}
