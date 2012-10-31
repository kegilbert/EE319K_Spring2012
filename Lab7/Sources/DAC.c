/*************************DAC.c***************************
* The implementation file for the 4-bit DAC
* The two routines are provided here                                    *
*********************************************************/
#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */

//********* DAC_Init ****************
// Initialize the DAC
// The four bits for the DAC are on pins PT3-PT0
// Inputs: none
// Outputs: none
// Errors:  
void DAC_Init(void){
    DDRT |= 0x0F; //Friendly way to make pins PT3-PT0 be outputs
}


//********* DAC_Out ****************
// Write a sample value out to the DAC
// Inputs: the 4-bit value to write out
// Outputs: none
// Errors:  
void DAC_Out(unsigned char sample){  
   //unsigned char PTTmask;
  
  // PTTmask = sample&0x0F;     // Friendly
   //PTT &=0xF0;
    PTT = sample;
}