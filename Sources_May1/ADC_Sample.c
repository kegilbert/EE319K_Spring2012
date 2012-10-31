/***************** Scan File *********************/
#include "ADC_Sample.h"
#include <mc9s12dp512.h>


void ADC_Init(void) {
  DDRP &= 0x00;    // PTP = all input, direction of scanner in relation to tank (0 = tank heading)
  DDRM &= 0xCF;    // 1 = output, 0 = input, PM4-PM5 = output (Resolution)
  ATD0CTL2 |= 0x80;  //ASPU, A/D Enabled
  
  ATD0CTL3 |= 0x08;  //Convesion sequence of 1, write to bits below to alter
  
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

  ATD0CTL4 |= 0x05;  //10bit ADC reading (bit7=0), prescalers none armed, fast conversion rates
}

short scan_F(unsigned char Resolution,unsigned char ScanHead) {  //channel 5 data
  PTM |= Resolution;   //Friendly
  PTP = ScanHead;      //Scanner direction (0 = tank heading)
  //Sample ADC5
  ATD0CTL5 |= 0x85;      //Begin conversion of channel 5
  while((ATD0STAT0&0x80)==0){/*wait*/}
  return ATD0DR0; 
}

short scan_L(unsigned char Resolution,unsigned char ScanHead) {  //channel 4 data
   PTM |= Resolution;   //Friendly
   PTP = ScanHead;      //Scanner direction (0 = tank heading)
  //Sample ADC4
  ATD0CTL5 |= 0x84;      //Begin conversion of channel 4
  while((ATD0STAT0&0x80)==0){/*wait*/}
  return ATD0DR0;  
}

short scan_R(unsigned char Resolution,unsigned char ScanHead) {  //channel 6 data
  PTM |= Resolution;   //Friendly
  PTP = ScanHead;      //Scanner direction (0 = tank heading)
  //Sample ADC56
  ATD0CTL5 |= 0x86;      //Begin conversion of channel 6
  while((ATD0STAT0&0x80)==0){/*wait*/}
  return ATD0DR0;
}

short scan_Turret(void) {
  ATD0CTL5 |= 0x83;
  while((ATD0STAT0&0x80)==0) {/*wait*/}
  return ATD0DR0;
}

short scan_X(void) {
  ATD0CTL5 |= 0x80;
  while((ATD0STAT0&0x80)==0) {/*wait*/}
  return ATD0DR0;
}

short scan_Y(void) {
  ATD0CTL5 |= 0x81;
  while((ATD0STAT0&0x80)==0) {/*wait*/}
  return ATD0DR0;
}

short scan_Heading(void) {
  ATD0CTL5 |= 0x82;
  while((ATD0STAT0&0x80)==0) {/*wait*/}
  return ATD0DR0;
}
