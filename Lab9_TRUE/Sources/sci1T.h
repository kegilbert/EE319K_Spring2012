//*************** SCI1 header file for transmitter *************
//sci_Init
//inputs: none
//outputs: none
// Initializes the SCI
void sci1_Init(void);

//sci_OutChar
//inputs: 8bit ascii character
//outputs: none
// waits for status to be ready, then writes ascii char. into output register
void sci1_OutChar(unsigned char Data);