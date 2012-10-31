// sci_Init and sci_Out functions
// initialize SCI, use busy-wait to send 1byte frames
#include "derivative.h"

void sci1_Init(void) {
  SCI1CR2 = 0x0C;
  SCI1BD = 13;   // Sets baud rate to 38400 bps
}

void sci1_OutChar(unsigned char Data) {
   unsigned char SR1Mask = 0;
   SR1Mask &= 0x80;
   while(SR1Mask != 1) { }
   SCI1DRL = Data;
}