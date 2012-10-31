//SCI1 routines for receiver
#include "derivative.h"
#include "FIFO.h"

unsigned short ErrorCount;
unsigned char error;
unsigned char result;
unsigned char dataPt;
extern unsigned char adcValue;

void SCI1R_Init(void){
  ErrorCount = 0;
  Fifo_Init();
  SCI1CR2 |= 0x24;     // Enable interrupt receiver, RIE bit set
  SCI1BD = 13;         // Baud Rate set to 38400 bps  
}

unsigned char SCI1_InData(void) {
  while(Fifo_Get(&dataPt) == 0){ }   //0 = false, do nothing
    return adcValue;       //FIFO_Get no longer empty, return     
}

                        