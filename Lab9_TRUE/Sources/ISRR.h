//****************** ISRR Header file *****************

//*************** OC0_InitR ***************
//Inputs: none
//Outputs: none
// Initializes interrupts/timer
void OC1_InitR(void);

//*************** Interrupt handler ***************
interrupt 21 void RDRFHandler(void);
         