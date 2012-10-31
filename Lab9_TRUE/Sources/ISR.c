#include "derivative.h"
#include "sci1T.h"
#include "ISR.h"
#include <hidef.h>

 unsigned short ADC_In(unsigned short);
 unsigned short Counter;    // Keeps track of ADC samples taken
 unsigned char ADCMail;
 unsigned short ADCStatus;
 extern ADC_Data;

void OC0_Init(void){
    TSCR1 = 0x80;
    TSCR2 = 0x07;  //PLL enabled, 24MHz, clockspeed = 5.33microseconds  
    TIOS |= 0x01;
    TIE |= 0x01;  
    TFLG1 = 0x01;
    TC0 = TCNT + 100;  // Begin first interrupt in 533 microseconds 
}

interrupt 8 void OC0handler(void) { 
   TFLG1 |= 0x01;
   TC0 = TC0 + 37525;    // Set next interrupt (5Hz) 37525
   PTP ^= 0x80;         // Heartbeat
   ADCMail = ADC_In(2);
   //ADCStatus = 0x80;
   sci1_OutChar(ADC_In(2));
   Counter++;   
}  