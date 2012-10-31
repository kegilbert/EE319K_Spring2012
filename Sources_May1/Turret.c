//*************** Turret File ****************
#include <hidef.h>
#include <mc9s12dp512.h>
#include "Turret.h"
#include "ADC_Sample.h"


unsigned short PERIODT;
signed char OffsetT;
const unsigned char stepT[8] = {
    0x05,0x04,0x06,0x02,0x0A,0x08,0x09,0x01
  }; 
  
void Wait(unsigned short delay);

void Turret_Init(void) {
  SCI0CR2 |= 0x0C;// TE bit enabled
  SCI0BD = 651;
  PERIODT = 0;
  OffsetT = 0; 
  Turret_move(1000);        // Turret facing ahead
  while(scan_Turret() != 0) {/*Do Nothing*/}
  TIE &= 0xF7;
}

void Turret_move(unsigned short speed) {    //OC channel 3, Forward step CCW
  PERIODT = speed;
  TIE |= 0x08;  
  TFLG1 |= 0x08;
  TC3 = TCNT + PERIODT;
}

void Turret_Fire(unsigned short ADCScan) {
  unsigned char distance;
  //convert ADC value into distance in meters
  distance = (ADCScan/4)+20;    //+20 to account for movement
  while((SCI0SR1_TDRE) == 0) { }
  SCI0DRL = distance;           //Fire
}

void interrupt 11 TC3Handler(void) {
  TFLG1 |= 0x08;
  TC3 += PERIODT;
  PTM = stepT[OffsetT];
  OffsetT += 2;
  if(OffsetT > 7) {
    OffsetT = 0; 
  } 
}