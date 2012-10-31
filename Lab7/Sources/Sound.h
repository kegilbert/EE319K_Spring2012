/*************************Piano.h***************************
* Header file for the Sound operations                      *
*********************************************************/

//********* Sound_Init ****************
// Initialize the Sound routines
// Inputs: none
// Outputs: none
// Errors:  
void Sound_Init(void);

//********* Sound_Play ****************
// Inputs: Input note
// Outputs: none, calls DAC_Out to play notes
// Errors:  
//void Sound_Play(unsigned int PERIOD);

//********* Interrupt Function ********

interrupt 14 void OC6handler(void); 