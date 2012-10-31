/***************** Scan File *********************/
#include "ADC_Sample.h"
#include <mc9s12dp512.h>

extern WatchByte0;
extern WatchByte4;
extern WatchWord0;

void ADC_Init(void) {
  DDRP = 0xFF;    // PTP = all input, direction of scanner in relation to tank (0 = tank heading)
  DDRM &= 0xCF;    // 1 = output, 0 = input, PM4-PM5 = output (Resolution)
  ATD0CTL2 = 0x80;  //ASPU, A/D Enabled
  
  ATD0CTL3 = 0x78;  //Convesion sequence of 1, write to bits below to alter
  
/* Bits 6,5,4,3 S8C, S4C, S2C, S1C - Conversion Sequence Length
;  These bits control the number of conversions per sequence. 
;  on reset, S4C is set to 1 (sequence length is 4). 
;  S8C S4C S2C S1C number of conversions/sequence
;   0   0   0   0   8
;   0   0   0   1   1
;   0   0   1   0   2
;   0   0   1   1   3
;   0   1   0   0   4
;   0   1   0   1   5
;   0   1   1   0   6
;   0   1   1   1   7
;   1   X   X   X   8   */

  ATD0CTL4 = 0x05;  //10bit ADC reading (bit7=0), prescalers none armed, fast conversion rates
}

void ADC_In(void) {
  ATD0CTL5 = 0x90;
  while(ATD0STAT0_SCF == 0){ }
}

unsigned short scan_F(unsigned char Resolution,unsigned char ScanHead) {  //channel 5 data
  PTM |= Resolution;    //Friendly
  PTP = ScanHead;      //Scanner direction (0 = tank heading)
  ADC_In();
  return ATD0DR5; 
}

unsigned short scan_L(unsigned char Resolution,unsigned char ScanHead) {  //channel 4 data
  PTM |= Resolution;   //Friendly
  PTP = ScanHead;      //Scanner direction (0 = tank heading)
  ADC_In();
  return ATD0DR4;  
}

unsigned short scan_R(unsigned char Resolution,unsigned char ScanHead) {  //channel 6 data
  PTM |= Resolution;   //Friendly
  PTP = ScanHead;      //Scanner direction (0 = tank heading)
  ADC_In();
  return ATD0DR6;
}
                                                                            
unsigned short scan_Turret(void) {
  ADC_In();
  return ATD0DR3;
}

unsigned short scan_X(void) {
  ADC_In();
  return ATD0DR0;
}

unsigned short scan_Y(void) {
  ADC_In();
  return ATD0DR1;  
}

unsigned short scan_Heading(void) {
  ADC_In();
  return ATD0DR2; 
}
