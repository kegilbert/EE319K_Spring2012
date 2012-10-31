#define FIFO_SIZE 4

char static *PutPt;
char static *GetPt;
char static Fifo[FIFO_SIZE];
unsigned short adcValue;

void Fifo_Init(void){
  PutPt = GetPt = &Fifo[0];
}

int Fifo_Put(char data){     
   char *tempPt;
   tempPt = PutPt;
   *(tempPt++) = data; 
   if(tempPt==&Fifo[FIFO_SIZE]){
     tempPt = &Fifo[0];
     PutPt = &Fifo[0];
   }
   if(tempPt == GetPt){
    return(0);
   } else {   
   PutPt = tempPt;
   return(1);
   }
}

int Fifo_Get(char *dataPt){
 if(PutPt == GetPt){
  return(0); 
 } else {
  //*dataPt = *(GetPt++);
  adcValue = *(GetPt++);
  if(GetPt==&Fifo[FIFO_SIZE]){
    GetPt = &Fifo[0];
  }
  return(1);
 }
}

