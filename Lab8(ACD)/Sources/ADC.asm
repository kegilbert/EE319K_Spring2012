; filename ******** ADC.asm ************** 
; Lab 8  analog to digital convertor, 8-bit ADC
;    put your solution here

  absentry   ADC_Init
  absentry   ADC_In

EEPROM:       section  

;***********ADC routines*********************
ATD0CTL0  equ $0080  ; ATD Control Register 0
ATD0CTL1  equ $0081  ; ATD Control Register 1
ATD0CTL2  equ $0082  ; ATD Control Register 2
ATD0CTL3  equ $0083  ; ATD Control Register 3
ATD0CTL4  equ $0084  ; ATD Control Register 4
ATD0CTL5  equ $0085  ; ATD Control Register 5
ATD0DIEN  equ $008D  ; ATD Input Enable Mask Register
ATD0DR0   equ $0090  ; A/D Conversion Result Register 0
ATD0DR0L  equ $0091  ; A/D Conversion Result Register 0 (low byte)
ATD0DR1   equ $0092  ; A/D Conversion Result Register 1
ATD0DR2   equ $0094  ; A/D Conversion Result Register 2
ATD0DR3   equ $0096  ; A/D Conversion Result Register 3  
ATD0DR4   equ $0098  ; A/D Conversion Result Register 4
ATD0DR5   equ $009A  ; A/D Conversion Result Register 5
ATD0DR6   equ $009C  ; A/D Conversion Result Register 6
ATD0DR7   equ $009E  ; A/D Conversion Result Register 7
ATD0STAT0 equ $0086  ; A/D Status Register 0
ATD0STAT1 equ $008B  ; A/D Status Register 1
;            ATDDRxH                ATDCRxL   (9S12DP512)
; 8-bit left   MSB,6,5,4,3,2,1,LSB    U,U,z,z,z,z,z,z  (z means zero, U means unknown)
;10-bit left   MSB,8,7,6,5,4,3,2      1,LSB,z,z,z,z,z,z
; 8-bit right  z,z,z,z,z,z,z,z        MSB,6,5,4,3,2,1,LSB
;10-bit right  z,z,z,z,z,z,MSB,8      7,6,5,4,3,2,1,LSB
;        8-s-right  8-un-right 8-s-left 8-un-left 10-s-left 10-s-right 10-un-left 10-un-right
; 5.0 V    007F      00FF       7F00      FF00      7FC0      01FF       FFC0      03FF
; 2.5 V    0000      0080       0000      8000      0000      0000       8000      0200
; 0.0 V    FF80      0000       8000      0000      8000      FE00       0000      0000  

;****Initialize ADC*******
;one conversion, 2MHz clock, 8-bit mode
;Inputs: None
;Outputs: None
; assume 24 MHz E clock
; speed is 2(m+1)(s+n)/ fE = 2(5+1)(4+8)/24MHz = 6us
ADC_Init 
    movb #$80,ATD0CTL2
    movb #$08,ATD0CTL3
    movb #$85,ATD0CTL4
    
    rts       
    
;ATD0CTL2	;ASPU=1 enables A/D
; bit 7 ADPU=1 enable
; bit 6 AFFC=0 ATD Fast Flag Clear All
; bit 5 AWAI=0 ATD Power Down in Wait Mode
; bit 4 ETRIGLE=0 External Trigger Level/Edge Control
; bit 3 ETRIGP=0 External Trigger Polarity
; bit 2 ETRIGE=0 External Trigger Mode Enable
; bit 1 ASCIE=0 ATD Sequence Complete Interrupt Enable
; bit 0 ASCIF=0 ATD Sequence Complete Interrupt Flag

;ATD0CTL3   make sequence length=1
; Bits 6,5,4,3 S8C, S4C, S2C, S1C - Conversion Sequence Length
;  These bits control the number of conversions per sequence. 
;  on reset, S4C is set to 1 (sequence length is 4). 
;  S8C S4C S2C S1C number of conversions/sequence
;   0   0   0   0   8
;   0   0   0   1   1
;   0   0   1   0   2
;   0   0   1   1   3
;   0   1   0   0   4
;   0   1   0   1   5
;   0   1   1   0   6
;   0   1   1   1   7
;   1   X   X   X   8

;ATD0CTL4
; bit 7 SRES8=0 A/D Resolution Select
;      1 n= 8 bit resolution
;      0 n= 10 bit resolution
; bit 6 SMP1=0 Sample Time Select 
; bit 5 SMP0=0 s=2+2 sample period
; bit 4 PRS4=0 ATD Clock Prescaler m=5, divide by 6
; bit 3 PRS3=0 ATD Clock Prescaler
; bit 2 PRS2=1 ATD Clock Prescaler
; bit 1 PRS1=0 ATD Clock Prescaler
; bit 0 PRS0=1 ATD Clock Prescaler
          
                          
;*****Input sample from ADC*******
; perform 8-bit analog to digital conversion
;Inputs: RegD is channel number 0-7, e.g., 4 means channel 4
;Outputs: RegD is 8-bit ADC sample
; analog input    right justified(decimal)
;  0.00              0
;  0.02              1
;  0.04              2
;  1.25             64 
;  2.50            128
;  5.00            255
; uses busy-wait synchronization
; bit 7 DJM Result Register Data Justification
;       1=right justified, 0=left justified
; bit 6 DSGN Result Register Data Signed or Unsigned Representation
;       1=signed, 0=unsigned
; bit 5 SCAN Continuous Conversion Sequence Mode
;       1=continuous, 0=single
; bit 4 MULT Multi-Channel Sample Mode
;       1=multiple channel, 0=single channel
; bit 3 0
; bit 2-0 CC,CB,CA channel number 0 to 7
ADC_In  ; RegB has channel number
        orab  #$80
        stab  ATD0CTL5    ; Begins conversion of channel 2 (right justified)
ADCLoop
       brclr ATD0STAT0,$80,ADCLoop
       ldd ATD0DR0
        
       rts

    
;* * * * * * * * End of ADC routines* * * * * * * * 

