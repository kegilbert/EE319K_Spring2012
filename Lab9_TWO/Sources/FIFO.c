#include "FIFO.h"

unsigned char Buffer[4]; 
unsigned char Data;
unsigned char WriteInd = 0;
unsigned char ReadInd = 0;

void FIFO_Put(unsigned char input){
   if(WriteInd > 4){     //Wrap around
     WriteInd=0;
   }
   if((ReadInd - WriteInd) == 1) {   // Error condition, try using a counter if this does not work
      /* Error, array full */
   } else {
     if(ReadInd == WriteInd) {
       /* Array empty */
     }
   }
   Buffer[WriteInd] = input;
   WriteInd++;          
}

unsigned char FIFO_Get(){
  if(ReadInd>4) {        //Wrap around
    ReadInd=0; 
  }
  if((ReadInd - WriteInd) == 1) {   // Error condition, try using a counter if this does not work
     /* Error, array full */
  } else {
    if(ReadInd == WriteInd) {
      /* Array empty */
    }
  }
  Data = Buffer[ReadInd];
  ReadInd++;
  return Data; 
}    