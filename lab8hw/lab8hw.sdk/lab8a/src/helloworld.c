#include <stdio.h>
#include <math.h> // For sine and cosine functions

#define N 8 // Number of points for the Fourier Transform

// Input array
float input[N] = {1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0};

// Function to compute 8-point DFT
void compute_dft(float input[], float real_out[], float imag_out[]) {
    // Loop over each output frequency bin k (0 to N-1)
    for (int k = 0; k < N; k++) {
        real_out[k] = 0.0;
        imag_out[k] = 0.0;
        // Compute the DFT sum for the current frequency bin k
        for (int n = 0; n < N; n++) {
            float angle = 2 * M_PI * k * n / N;
            real_out[k] += input[n] * cos(angle);
            imag_out[k] += -input[n] * sin(angle); // Negative sign for imaginary part
        }
    }
}

int main() {
    // Arrays to hold the real and imaginary parts of the DFT result
    float real_out[N] = {0.0};
    float imag_out[N] = {0.0};

    // Compute the DFT
    compute_dft(input, real_out, imag_out);

    // Print the results
    printf("8-point DFT Results:\n");
    for (int k = 0; k < N; k++) {
        printf("X[%d]: Real = %f, Imag = %f\n", k, real_out[k], imag_out[k]);
    }

    return 0;
}
