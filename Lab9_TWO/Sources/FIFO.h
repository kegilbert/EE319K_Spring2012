//FIFO Header file

//************* FIFO_Put *************
//Inputs: 8bit value to be stored into the buffer
//Outputs: none
// Stores data into the buffer 
void FIFO_Put(unsigned char input);

//************* FIFO_Get *************
//Inputs: none
//Outputs: 8bit value from buffer
// Pulls oldest data from buffer (FIFO order)
unsigned char FIFO_Get(void);
