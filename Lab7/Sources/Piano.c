#include "derivative.h"
#include <hidef.h>
#include "piano.h"

extern unsigned int PERIOD;

void Piano_Init(void) {
    DDRP &= 0xF8;   // PP0,1,2 inputs (0)
    DDRP |= 0x88;   // Set PP7,3 output(1) (PP3 int. test bitpartg)
}

void Piano_In(void) {
     unsigned char PTPmask;     
     PTPmask = (PTP&=0x70);
           /* use to branch to correct note */ 
           /* Tests if only 1 switch is pressed, and whether to play A,G, or F */  
    if(PTPmask == 0x10) { // A
       PERIOD = 106; //1/(32*440Hz*.000000667s)=106.4 
       return;   
    }
    if(PTPmask == 0x20) { // G
       PERIOD = 120; //1/(32*392*.000000667s)=119.51
       return;
    }  
    if(PTPmask == 0x40) { // F
       PERIOD = 134; //1/(32*349*.000000667s)=134.2
       return;
    } else {
          PERIOD = 99;
          return; 
      }  
}
    