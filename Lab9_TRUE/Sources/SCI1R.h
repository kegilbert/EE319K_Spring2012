//**************** SCI1 Header file for receiver ***************

//********** SCI1R_Init ************
//Inputs: none
//Outputs: none
// Initializes receiver
void SCI1R_Init(void);

//********** SCI1_InData ************
//Inputs: none
//Outputs: data from queue
// Samples FIFO, returns data
 unsigned char SCI1_InData(void);