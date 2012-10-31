// filename ************* Fifo.h ********
// Header file for the receive FIFO
// Jonathan W. Valvano 3/18/07

//  This example accompanies the books
//   "Embedded Microcomputer Systems: Real Time Interfacing",
//        Thompson, copyright (c) 2006,
//   "Introduction to Embedded Microcomputer Systems: 
//    Motorola 6811 and 6812 Simulation", Brooks-Cole, copyright (c) 2002

// Copyright 2007 by Jonathan W. Valvano, valvano@mail.utexas.edu 
//    You may use, edit, run or distribute this file 
//    as long as the above copyright notice remains  

#define FIFOSIZE 4
/* Number of characters in the Fifo
     the FIFO is full when it has FifoSize-1 characters */
void Fifo_Init(void);

/*-----------------------Fifo_Put----------------------------
  Enter one character into the fifo
  Inputs: 8-bit data
  Outputs: true if data is properly saved
  Since this is called by interrupt handlers no sei,cli*/
int Fifo_Put(unsigned char data); 

/*-----------------------Fifo_Get----------------------------
  Remove one character from the fifo
  Inputs: pointer to place to save 8-bit data
  Outputs: true if data is valid */
int Fifo_Get(unsigned char *datapt);

/*-----------------------Fifo_Status----------------------------
  Check the status of the fifo
  Inputs: none
  Outputs: true if there is any data in the fifo */
int Fifo_Status(void); 

/*-----------------------Fifo_Size----------------------------
  Check the status of the fifo
  Inputs: none
  Outputs: number of elements currently stored in the FIFO */
unsigned short Fifo_Size(void) ;
