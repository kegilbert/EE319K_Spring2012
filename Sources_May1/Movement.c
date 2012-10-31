//****************** Movement file *********************
#include <hidef.h>           /* common defines and macros */
#include <mc9s12dp512.h>     /* derivative information */

#include "Movement.h"

extern WatchByte1;

signed short PERIOD,PERIODR,PERIODL;
const unsigned char step[4] = {
    0x55,0x66,0xAA,0x99
  };
const unsigned char rotateRight[4] = {
    0x56,0x9A,0xA9,0x65
  };
const unsigned char rotateLeft[4] = {
    0x65,0xA9,0x9A,0x56
  };
signed char LMP,RMP;
signed char Offset,OffsetR,OffsetL;


//******************* Initialize ******************
void motor_Init(void) {                      
  LMP = 0;
  RMP = 0;
  PERIOD = 0;
  PERIODR = 0;
  PERIODL = 0;
  Offset = 0;
  OffsetR = 0;
  OffsetL = 0;
  TIOS |= 0x0F;
}

//***************** motor_STRAIGHT *****************
void motor_straight(signed short speed) {   //uses TC0
  if(speed < 0) {
    Offset = -1;
    PERIOD = speed*(-1);
  } else {
    Offset = 1; 
    PERIOD = speed;
  }
  TIE |= 0x01;         
  TFLG1 |= 0x01;
  TC0 = TCNT + PERIOD;  
}

//******************* motor_RIGHT ******************
void motor_RightRotate(signed short speed) {   //uses TC1.  Neg speed = left, positive = right
  PERIODR = speed;
  TIE |= 0x02;         
  TFLG1 |= 0x02;
  TC1 = TCNT + PERIODR;  
}

//****************** motor_LEFT *********************
void motor_LeftRotate(signed short speed) {
  PERIODL = speed;
  TIE |= 0x04;
  TFLG1 |= 0x04;
  TC2 = TCNT + PERIODL;
}

//******************* Interrupt Handlers *******************
  
void interrupt 8 TC0Handler(void) {
   TFLG1 |= 0x01;
   TC0 += PERIOD;
   PTT = step[LMP];
   LMP += Offset;    //step through array with offset of +/-1 for straight forward/backwards 
   if(LMP>=3 && Offset>0) {
      LMP = 0;
   }
   if(LMP<0 && Offset<0) {
      LMP = 3;
   }
}

void interrupt 9 TC1Handler(void) {
  TFLG1 |= 0x02;
  TC1 += PERIODR;
  if(Offset < 0) {
    OffsetR = Offset*(-1); 
  } else {
    OffsetR = Offset; 
  }
  PTT = rotateRight[LMP];
  LMP++;
  if(OffsetR > 3) {
    OffsetR = 0; 
  }
}

void interrupt 10 TC2Handler(void) {
  TFLG1 |= 0x04;
  TC2 += PERIODL;
  PTT = rotateLeft[LMP];
  LMP++;
  if(OffsetL > 3) {
    OffsetL = 0; 
  }
}