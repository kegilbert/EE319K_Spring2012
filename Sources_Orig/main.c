// filename ******** Main.C ************** 
// This example illustrates the running Trobots in C, Version 1.85 
// 9S12DP512 EE319K Spring 2012         
// ****ERASE THIS LINE AND PUT YOUR NAMES HERE*****
// 10 points will be deducted if you do not follow submission instructions       
// 

// Configure this project for your tank (do this once)
// 1) Open the Edit->HCS12SerialMonitorSettings, 
// 2) click "Linker for HC12"
// 3) Place your team name in the "Application Filename" field 
//    If you are A0, change "z3.abs" to "a0.abs"  
//  The rest of the instructions assume you are team z3

// To run this program in TExaS
// 0) Start TExaS and open the Texas.uc file in bin folder 
// 1) In Metrowerks, Execute Project->Make to compile C code
//   This creates a bunch of files in the bin directory
//       an object code     z3.sx
//       listing files      main.lst start12.lst plus your files
//       map file           z3.map
// 2) Within TExaS import these files, execute Action->OpenS19
//    select z3.sx in the bin folder
//  (Subsequent times you can execute Action->OpenS19Again)
// 3) Debug using usual TExaS debugging features   

// To run this program in TRobots simulator
// 1) Execute Project->Make to compile C code
//   This creates a bunch of files in the bin directory
//       an object code     z3.sx
//       listing files      main.lst start12.lst plus your files
//       map file           z3.map
// 2) move z3.sx to the S19 folder of TRobots
// 3) Run TRobots   

#include <hidef.h>           /* common defines and macros */
#include <mc9s12dp512.h>     /* derivative information */

#pragma LINK_INFO DERIVATIVE "mc9s12dp512"

//****DO NOT PUT ANY RAM DEFINITIONS HERE ******
// these first 8 bytes are observable in TRobots
unsigned char volatile Mem3800[8];  // this will be at address $3800
#define WatchByte0 *(unsigned char volatile *)(0x3800)
#define WatchByte1 *(unsigned char volatile *)(0x3801)
#define WatchByte2 *(unsigned char volatile *)(0x3802)
#define WatchByte3 *(unsigned char volatile *)(0x3803)
#define WatchByte4 *(unsigned char volatile *)(0x3804)
#define WatchByte5 *(unsigned char volatile *)(0x3805)
#define WatchByte6 *(unsigned char volatile *)(0x3806)
#define WatchByte7 *(unsigned char volatile *)(0x3807)
// these macros can be used to observe 16-bit values
#define WatchWord0	*(unsigned short volatile *)(0x3800)
#define WatchWord1	*(unsigned short volatile *)(0x3802)
#define WatchWord2	*(unsigned short volatile *)(0x3804)
#define WatchWord3	*(unsigned short volatile *)(0x3806)

//****PUT YOUR RAM VARIABLES and INCLUDES BELOW HERE*************

// *********** Global Variables ***************
// *********** Function header files **********

#include "ADC_Sample.h"
#include "Movement.h"
#include "Turret.h"

//************ User_Defines *************
    //define resolution parameters for scan function calls
#define res120  0x30    //%b00110000
#define res30 0x20      //%b00100000
#define res10 0x10      //%b00010000
#define res5  0x00      //%b00000000
 
//---------Wait------------------
// fixed time delay
// inputs: time to wait in 40ns cycles
// outputs: none
void Wait(unsigned short delay){ 
unsigned short startTime;
  startTime = TCNT;
  while((TCNT-startTime) <= delay){} 
}
  
/*void mainGAME(void) { 
  Mem3800[0] = 0; // leave this so the compiler will not remove it
  WatchWord1 = 0;
  WatchWord2 = 0; 
  TSCR1 = 0x80;     // Enable TCNT, 25MHz E clock
  TSCR2 = 0x00;     // divide by 1 TCNT prescale, TOI disarm
  PACTL = 0;        // timer prescale used for TCNT
  DDRT = 0xFF;      // PT7-4 are left track, PT3-0 are right track
  PTT = 0x55;       // activate two track stepper coils
  DDRM |= 0x80;     // PP7 is gearbox
  PTP &= ~0x80;     // slow speed
  ADC_Init();     
  EnableInterrupts; 
  for(;;) {       */
    //forwardOC0,leftOC1,right0C2
    //Scan surroundings   --    int scan_L120/scan_R120/scan_F120, return 0 or 1
    //Ceck state of robot (health,etc)   --    if(status() == danger) {/*healthpack*/}, #define danger = 2
        //    --    int status(void);
    //If health ok, and enemy deteched, pursue.  If no enemy, drive
    //parameters for scan: res120,res30,res10,res5 (resolutions); scanner heading (0-255) 
//    if((scan_L(res120,0) == scan_R(res120,0) == scan_F(res120,0)) && scan_F(res120,0)==1023) {  //Res. defines above
      /* Move */  
//    }   
//****** enemy deteced, check side scanners ******    
//    if(scan_L(res30,0) != 1023) {
//       motor_left(450);
//       while(scan_F(res30,0) == 1023) {/*Do Nothing*/} 
//       TIE &= 0xFD;   //clear channel 1, stop motor interrupts
/*    } else {
      if(scan_R(res30,0) != 1023) {
        while(scan_F(res30,0) == 1023) {
          motor_right(); 
        }
      }
    }      */
//****** enemy in front, pursue until in range, narrow scan ******
/*  while(scan_F(res30,0) >= 512)     //robot within 128m
    //50% movement boost?
    motor_forward();   
  }   */
//****** narrow heading *******
//    if(scan_L(res10,0) != 1023) {
//       while(scan_F(res10,0) == 1023) {
//          motor_left(/*speed,-127,128?*/);
/*       }
    } else {
      if(scan_R(res10,0) != 1023) {
        while(scan_F(res10,0) == 1023) {
          motor_right(); 
        }
      }
    }  
}  
        */

void main(void) {
  Mem3800[0] = 0; // leave this so the compiler will not remove it
  WatchWord1 = 0;
  WatchWord2 = 0; 
  TSCR1 = 0x80;     // Enable TCNT, 25MHz E clock
  TSCR2 = 0x00;     // divide by 1 TCNT prescale, TOI disarm
  PACTL = 0;        // timer prescale used for TCNT
  DDRT = 0xFF;      // PT7-4 are left track, PT3-0 are right track
  PTT = 0x55;       // activate two track stepper coils
  DDRM |= 0x8F;     // PP7 is gearbox, PM3-0 turret
  PTP &= ~0x80;     // slow speed
  ADC_Init(); 
  motor_Init();   
  EnableInterrupts; 
  //Turret_Init(); 
  for(;;) { 
    motor_straight(430);
    Wait(64000);
    TIE &= 0xFE;
    motor_RightRotate(1000);
    Wait(64000);
    TIE &= 0xFD;
    motor_LeftRotate(1000);
    Wait(64000);
    TIE &= 0xFB;
    motor_straight(430);
    while(scan_X() > 150 && scan_X() < 870) { }
    TIE &= 0xFE;
    for(;;) { }
  }
}
