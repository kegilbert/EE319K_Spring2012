/*************************Piano.h***************************
* Header file for the Switch interface                                  *
*********************************************************/

//********* Piano_Init ****************
// Initialize the Switch intereface
// Inputs: none
// Outputs: none
// Errors:  
void Piano_Init(void);

//********* Piano_In ******************
// Reads the switch being pressed, passses back logical key code
// Inputs: none
// Outputs: Logical key code for pressed switch
// Errors:  
void Piano_In(void);