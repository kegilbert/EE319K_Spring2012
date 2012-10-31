// sci_Init and sci_Out functions
// initialize SCI, use busy-wait to send 1byte frames
#include "derivative.h"
  
unsigned char SR1Mask;
extern ADCMail;

void sci1_Init(void) {
  SCI1CR2 |= 0x0C;// TE bit enabled
  SCI1BD = 13;    // Sets baud rate to 38400 bps
}

void sci1_OutChar(unsigned char Data) {
   while((SCI1SR1_TDRE) == 0) { };
   SCI1DRL = Data;
}