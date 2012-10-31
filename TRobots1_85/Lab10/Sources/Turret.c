//*************** Turret File ****************
#include <hidef.h>
#include <mc9s12dp512.h>
#include "Turret.h"
#include "ADC_Sample.h"

unsigned short PERIODT;
signed char Ind;
const unsigned char stepT[4] = {
  0x06,0x0A,0x09,0x05
  }; 

void Turret_Init(void) {
  SCI0CR2 |= 0x0C;// TE bit enabled
  SCI0BD = 651;
  PERIODT = 0;
  Ind = 0; 
  Turret_move(1000);        // Turret facing ahead
  while(scan_Turret() != 512) {/*Do Nothing*/}
  TIE &= 0xF7;
}

void Turret_move(unsigned short speed) {    //OC channel 3, Forward step CCW
  PERIODT = speed;
  TIE |= 0x08;  
  TFLG1 |= 0x08;
  TC3 = TCNT + PERIODT;
}

void Turret_Fire(unsigned char ADCScan) {
  unsigned char distance;
  //convert ADC value into distance in meters
  distance = (ADCScan/4);    //+20 to account for movement
  while((SCI0SR1_TDRE) == 0) { }
  SCI0DRL = distance;           //Fire
}

void interrupt 11 TC3Handler(void) {
  TFLG1 |= 0x08;
  TC3 += PERIODT;
  PTM = stepT[Ind];
  Ind++;
  if(Ind>3){
    Ind = 0;
  }
}