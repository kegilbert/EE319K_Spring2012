/*************** Movement Header File **************/

void motor_Init(void);

//*********** motor_straight ************
//Inputs: Speed(430-10000+)
//Outputs: none
//  Controls straight driving functions, 430 is the fastest the stepper
//  can go, to decrease speed, pass in larger values.
//  To go in reverse, pass in negative values starting at -430, then decresing (-451,etc)
void motor_straight(signed short speed);

//*********** motor_RightRotate ************
//Inputs: Speed(430-10000+)
//Outputs: none
// Controls right spins (central pivot point)
void motor_RightRotate(signed short speed);

//*********** motor_LeftRotate ************
//Inputs: Speed(430-10000+)
//Outputs: none
// Controls left spins (central pivot point)
void motor_LeftRotate(signed short speed);

//*************Interrupt Handlers *************
//  Controls writes to PTT to control speed

