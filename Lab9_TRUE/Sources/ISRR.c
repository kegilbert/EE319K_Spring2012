// OC Interrupt file for Recierver
#include "derivative.h"
#include "ISRR.h"
#include "FIFO.h"

unsigned char flag = 0;
unsigned short frames;        // Number of frames received
unsigned short ErrorCounter;
unsigned char junk;


void OC1_InitR(void) {
    ErrorCounter = 0;
    TSCR1 = 0x80;
    TSCR2 = 0x07;  //PLL enabled, 24MHz, clockspeed = 5.33microseconds  
}


interrupt 21 void RDRFHandler(void) { 
   PTP ^= 0x80;          // Heartbeat
   junk = SCI1SR1&0x80;       // Acknowledge interrupt
   junk = SCI1DRL;
   flag = Fifo_Put(junk);    // Store received data into buffer
   if(flag == 0){        // Error
      ErrorCounter++;
      return;
   }  
   frames++;
   return;   
}