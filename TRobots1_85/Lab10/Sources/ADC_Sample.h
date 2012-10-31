//******************* Scan Header File ********************
//    For all scan inputs, inputs are defines as res120,res30,res10, or res5
//    - this inputs are defines as their corresponding PM values

//*************** ADC_Init **************
//Inputs: none
//Outpts: none
// Initializes ADC and scan operations
void ADC_Init(void);

//*************** Scan_F *****************
//Inputs: degree of scan (range in degrees),heading of scanner
//Outputs: ADC value, fixed point decimal res of .25m
// PP0-7 = direction of scanner relative to tank; 0 = facing tank's direction
// Tanks Front scanner (ADC Channel 5)
unsigned short scan_F(unsigned char Resolution,unsigned char ScanHead);

//*************** Scan_L *****************
//Inputs: degree of scan (range in degrees),heading of scanner
//Outputs: ADC value, fixed point decimal res of .25m
// PP0-7 = direction of scanner relative to tank; 0 = facing tank's direction
// Tanks Left scanner (ADC Channel 4)
unsigned short scan_L(unsigned char Resolution,unsigned char ScanHead);

//*************** Scan_R *****************
//Inputs: degree of scan (range in degrees),heading of scanner
//Outputs: ADC value, fixed point decimal res of .25m
// PP0-7 = direction of scanner relative to tank; 0 = facing tank's direction
// Tanks Right scanner (ADC Channel 6)
unsigned short scan_R(unsigned char Resolution,unsigned char ScanHead);


unsigned short scan_X(void);

unsigned short scan_Y(void);

unsigned short scan_Heading(void);

unsigned short scan_Turret(void);

void ADC_In(void);