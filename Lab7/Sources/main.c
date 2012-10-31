#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */
#include "PLL.h"       
#include "DAC.h" 
#include "piano.h"
#include "Sound.h"
#define ever ;;

unsigned char Data; // 0 to 15 DAC output

void main(void) {

  PLL_Init();   // Engaging PLL allows use to run 9S12 at 24MHz even in RUN mode
  DAC_Init(); 
  Piano_Init();
  Sound_Init();
  EnableInterrupts;
  Data = 0;
  for(ever) {
     Piano_In();
     PTP ^= 0x80;     // Heartbeat
  } 
  
  /* for(;;) {
    DAC_Out(Data); 
    Data = 0x0F&(Data+1);  
  }   */ 
}
