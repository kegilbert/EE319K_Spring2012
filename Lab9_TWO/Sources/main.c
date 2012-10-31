#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */
#include "sci1.h"
#include "PLL.h"
#include "ISR.h"
#include "ADC.h"

extern Buffer;

void main(void) {
  asm sei           // Disable interrupts
  PLL_Init();
  ADC_Init();
  sci1_Init();
  DDRP |= 0x80;     // PP7 output
  OC0_Init();       // Intializes timer as well
  asm cli           // Enable interrupts
  
  for(;;) { /* Do Nothing */}
}

void mainRECEIVER(void) {
  
}

void mainFIFOtest(void){
   
}