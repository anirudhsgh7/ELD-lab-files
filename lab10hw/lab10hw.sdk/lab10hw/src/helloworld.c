#include <stdio.h>
#include <complex.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include <xtime_l.h>
#include "xparameters.h"
#include "xaxidma.h"
#include "dma_init.h"

#define FFT_SIZE 32 // Size of FFT

// Predefined bit-reversal indices and twiddle factors
const int bit_rev[FFT_SIZE] = {0, 16, 8, 24, 4, 20, 12, 28, 2, 18, 10, 26, 6, 22, 14, 30,
                               1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31};
const float complex twiddle_factors[FFT_SIZE / 2] = {
    1 - 0 * I, 0.9807852804032304 - 0.19509032201612825 * I, 0.9238795325112867 - 0.3826834323650898 * I,
    0.8314696123025452 - 0.5555702330196022 * I, 0.7071067811865476 - 0.7071067811865475 * I,
    0.5555702330196023 - 0.8314696123025452 * I, 0.38268343236508984 - 0.9238795325112867 * I,
    0.19509032201612833 - 0.9807852804032304 * I, 0.0 - 1.0 * I, -0.1950903220161282 - 0.9807852804032304 * I,
    -0.3826834323650897 - 0.9238795325112867 * I, -0.555570233019602 - 0.8314696123025455 * I,
    -0.7071067811865475 - 0.7071067811865476 * I, -0.8314696123025453 - 0.5555702330196022 * I,
    -0.9238795325112867 - 0.3826834323650899 * I, -0.9807852804032304 - 0.1950903220161286 * I};

// Function for bit-reversal
void perform_bit_reversal(const float complex input_data[FFT_SIZE], float complex reversed_data[FFT_SIZE]) {
    for (int idx = 0; idx < FFT_SIZE; idx++) {
        reversed_data[idx] = input_data[bit_rev[idx]];
    }
}

// Function to compute FFT using Cooley-Tukey algorithm
void compute_fft(const float complex input_data[FFT_SIZE], float complex output_data[FFT_SIZE]) {
    float complex temp_buffer1[FFT_SIZE], temp_buffer2[FFT_SIZE];

    // Apply bit-reversal
    perform_bit_reversal(input_data, temp_buffer1);

    // Perform FFT stages
    for (int stage = 1; stage <= 5; stage++) { // log2(FFT_SIZE) = 5 stages for FFT_SIZE=32
        int group_size = 1 << stage;           // 2^stage
        int half_group = group_size / 2;

        for (int start = 0; start < FFT_SIZE; start += group_size) {
            for (int offset = 0; offset < half_group; offset++) {
                float complex multiplier = twiddle_factors[FFT_SIZE / group_size * offset] * temp_buffer1[start + offset + half_group];
                temp_buffer2[start + offset] = temp_buffer1[start + offset] + multiplier;
                temp_buffer2[start + offset + half_group] = temp_buffer1[start + offset] - multiplier;
            }
        }
        for (int idx = 0; idx < FFT_SIZE; idx++) temp_buffer1[idx] = temp_buffer2[idx];
    }

    // Copy results to output
    for (int idx = 0; idx < FFT_SIZE; idx++) output_data[idx] = temp_buffer1[idx];
}

// Main function
int main() {
    init_platform();

    // Timer variables
    XTime start_time_ps, end_time_ps, start_time_pl, end_time_pl;

    // FFT buffers
    const float complex input_signal[FFT_SIZE] = {
        10 + 20 * I, 22 + 11 * I, 90 + 85 * I, 16 + 68 * I,
        48 + 94 * I, 42 + 15 * I, 97 + 18 * I, 50 + 56 * I,
        8 + 21 * I, 15 + 35 * I, 54 + 74 * I, 32 + 20 * I,
        21 + 13 * I, 34 + 47 * I, 86 + 65 * I, 43 + 14 * I,
        76 + 88 * I, 40 + 22 * I, 35 + 17 * I, 85 + 36 * I,
        62 + 73 * I, 18 + 26 * I, 37 + 20 * I, 20 + 30 * I,
        40 + 35 * I, 26 + 47 * I, 61 + 28 * I, 18 + 23 * I,
        46 + 53 * I, 28 + 35 * I, 70 + 83 * I, 38 + 50 * I};

    float complex fft_result_ps[FFT_SIZE], fft_result_pl[FFT_SIZE];

    // Perform FFT in PS
    XTime_GetTime(&start_time_ps);
    compute_fft(input_signal, fft_result_ps);
    XTime_GetTime(&end_time_ps);

    // Perform FFT in PL
    XAxiDma dma_instance;
    int dma_status = DMA_Init(&dma_instance, XPAR_AXI_DMA_0_DEVICE_ID);
    if (dma_status != XST_SUCCESS) {
        printf("\nDMA Initialization Failed!\n");
        return XST_FAILURE;
    }

    XTime_GetTime(&start_time_pl);

    // Send input to FPGA
    dma_status = XAxiDma_SimpleTransfer(&dma_instance, (UINTPTR)input_signal, sizeof(float complex) * FFT_SIZE, XAXIDMA_DMA_TO_DEVICE);
    if (dma_status != XST_SUCCESS) return XST_FAILURE;

    // Receive output from FPGA
    dma_status = XAxiDma_SimpleTransfer(&dma_instance, (UINTPTR)fft_result_pl, sizeof(float complex) * FFT_SIZE, XAXIDMA_DEVICE_TO_DMA);
    if (dma_status != XST_SUCCESS) return XST_FAILURE;

    // Wait for DMA operations to complete
    while (XAxiDma_Busy(&dma_instance, XAXIDMA_DMA_TO_DEVICE));
    while (XAxiDma_Busy(&dma_instance, XAXIDMA_DEVICE_TO_DMA));

    XTime_GetTime(&end_time_pl);

    // Compare results
    for (int idx = 0; idx < FFT_SIZE; idx++) {
        float real_diff = fabsf(crealf(fft_result_ps[idx]) - crealf(fft_result_pl[idx]));
        float imag_diff = fabsf(cimagf(fft_result_ps[idx]) - cimagf(fft_result_pl[idx]));

        printf("\nPS Output: %.2f + %.2fI, PL Output: %.2f + %.2fI",
               crealf(fft_result_ps[idx]), cimagf(fft_result_ps[idx]),
               crealf(fft_result_pl[idx]), cimagf(fft_result_pl[idx]));

        if (real_diff > 0.0001 || imag_diff > 0.0001) {
            printf("\nMismatch detected at index %d!\n", idx);
        } else {
            printf("\nResults match at index %d!", idx);
            printf("\nDMA Transfer Successful!\n");
        }

        // Add a blank line for better readability
        printf("\n");
    }

    // Print execution times
    printf("\n\n------- Execution Time Comparison -------\n");
    printf("Execution time on PS: %.2f microseconds\n",
           (float)(end_time_ps - start_time_ps) / (COUNTS_PER_SECOND / 1e6));
    printf("Execution time on PL: %.2f microseconds\n",
           (float)(end_time_pl - start_time_pl) / (COUNTS_PER_SECOND / 1e6));

    return 0;
}
