//ADC Header File
//*************** ADC_Init ***************
//Inputs: none
//Outputs: none
// Initializes the ADC 8 bit mode, 6 microsecond conversion
void ADC_Init(void);

//*************** ADC_In ****************
//Inputs: Channel number (2 lab8,9)
//Outputs: ADC value from PAD2 [0-255]
// Samples ADC, passes back value from 0-255
unsigned short ADC_In(unsigned short);