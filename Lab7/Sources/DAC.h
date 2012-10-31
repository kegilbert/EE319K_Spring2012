/*************************DAC.h***************************
* Header file for the 4-bit DAC                                    *
*********************************************************/

//********* DAC_Init ****************
// Initialize the DAC
// Inputs: none
// Outputs: none
// Errors:  
void DAC_Init(void);

//********* DAC_Init ****************
// Write a sample value out to the DAC
// Inputs: the 4-bit value to write out
// Outputs: none
// Errors:  
void DAC_Out(unsigned char);