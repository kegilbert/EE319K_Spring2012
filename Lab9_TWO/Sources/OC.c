
#include <hidef.h>        /* common defines and macros */
#include "derivative.h"   /* derivative-specific definitions */
#include "sci1.h"
 
 extern unsigned char ADCStatus;
 extern unsigned short ADCMail; 
 
 unsigned short temp;
 static int counter;
 void Timer_Wait10ms();
     
void OC0_Init(void){

    DDRP |=  0x80;
    ADCStatus=0;
    temp=0;
    counter=0;
  
    asm sei          // make atomic
    TSCR1 = 0x80;    // 1MHz TCNT
    TSCR2 = 0x03;    // (0x02 if C32)
    TIOS |= 0x01;    // activate 0c0
    TIE  |= 0x01;    // arm 0c0  
    TC0 = TCNT+60000;   // first in 10ms
    TFLG1 = 0x01;    // clear C6F
    asm cli          // enable IRQ 
}
    
    
    
    //******** OC0handler **********
// Acts as a timer to control the rate of waveform generation
// Is an interrupt
interrupt 8 void OC0handler(void){
      PTP = PTP^0x80;
      TC0 = TC0+60000;  //waitTime
      TFLG1 = 0x01;        //acknowledge C0F
      
      temp=ADC_In(2);
      ADCMail = temp;
      sci1_OutChar(temp);
      ADCStatus=0x80;
      
      counter++;       
}
