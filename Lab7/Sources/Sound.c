#include <hidef.h>
#include "derivative.h" 
#include "DAC.h"
#include "Sound.h"

unsigned int PERIOD;
unsigned char count;
   const unsigned char sinewave[32] = {
       8,9,11,12,13,14,14,15,15,15,14,14,13,12,11,9,8,7,5,4,3,
       2,2,1,1,1,2,2,3,4,5,7 
    };
void Sound_Init(void) {
    const unsigned char sinewave[32] = {
       8,9,11,12,13,14,14,15,15,15,14,14,13,12,11,9,8,7,5,4,3,
       2,2,1,1,1,2,2,3,4,5,7 
    }; // Array of output values to DAC, forms sine wave    
    
    DAC_Init();
    
    TSCR1 = 0x80;
    TSCR2 = 0x05;  // TCNT enabled to 667nseconds (PLL = 24MHz)  
    TIOS |= 0x40;
    TIE |= 0x40;  
    TFLG1 = 0x40;
    TC6 = TCNT + 100; // Begin interrupts 100*667ns 
  
    count = 0;
    PERIOD = 0;   
}

//void Sound_Play(unsigned int PERIOD) {  
//}
    
interrupt 14 void OC6handler(void) {
      TFLG1 |= 0x40;
      PTP |= 0x08;
      TC6 = TC6 + PERIOD;
      DAC_Out(sinewave[count]);
      if(PERIOD != 99){
         count = (++count)%32;
         PTP &= 0xF7;
      }
      PTP &= 0xF7;
}  