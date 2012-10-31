// filename ******** main.c ************** 
// EE319K Lab 8 starter system    
//    Jonathan W. Valvano  4/12/12
// Potentiometer connected to 9S12

#include <hidef.h>        /* common defines and macros */
#include "derivative.h"   /* derivative-specific definitions */
#include "ADC.h"
#include "PLL.h"
#include "LCD.h"
#include "OC.h"

void LCD_Open(void);
void LCD_Clear(void);
void LCD_OutChar(unsigned short Data);
unsigned short Convert(unsigned short data);

unsigned short Data;      // 8-bit ADC
unsigned short Position;  // 16-bit fixed-point 0.01 cm


extern unsigned char ADCStatus;
extern unsigned char ADCMail;


/*void main1(void){
  LCD_Open();    // Initialize LCD Display
  LCD_Clear();
  PLL_Init();  // E clock is 24 MHz in both RUN and LOAD modes
  ADC_Init();  // turn on ADC
asm cli        // enable debugger
  for(;;){
    Data = ADC_In(4);  // sample 8-bit channel 4
    LCD_OutChar(Data);
  }
}   */

/*void main(void){
  PLL_Init();  // E clock is 24 MHz in both RUN and LOAD modes
  ADC_Init();  // turn on ADC
  LCD_Open();
  LCD_Clear();
asm cli        // enable debugger
  for(;;){
    LCD_Clear();       // clear display
    Data = ADC_In(2);  // sample 8-bit channel
     
    LCD_OutDec(Data);
    Timer_Wait10ms(10); // 100ms wait
  }
}    */

//*********  Convert *********
// converts 8-bit ADC to fixed-point position in cm
// Input: 8-bit ADC 0 to 255
// Output: position in 0.01 cm
// needs calibration
unsigned short Convert(unsigned short data){
  unsigned short position;
  unsigned short cmData[257] = {
106,
106,
107,
108,
108,
109,
110,
111,
111,
112,
113,
114,
114,
115,
116,
117,
117,
118,
119,
120,
120,
121,
122,
123,
123,
124,
125,
125,
126,
127,
128,
128,
129,
130,
131,
131,
132,
133,
134,
134,
135,
136,
137,
137,
138,
139,
140,
140,
141,
142,
143,
143,
144,
145,
145,
146,
147,
148,
148,
149,
150,
151,
151,
152,
153,
154,
154,
155,
156,
157,
157,
158,
159,
160,
160,
161,
162,
162,
163,
164,
165,
165,
166,
167,
168,
168,
169,
170,
171,
171,
172,
173,
174,
174,
175,
176,
177,
177,
178,
179,
180,
180,
181,
182,
182,
183,
184,
185,
185,
186,
187,
188,
188,
189,
190,
191,
191,
192,
193,
194,
194,
195,
196,
197,
197,
198,
199,
199,
200,
201,
202,
202,
203,
204,
205,
205,
206,
207,
208,
208,
209,
210,
211,
211,
212,
213,
214,
214,
215,
216,
217,
217,
218,
219,
219,
220,
221,
222,
222,
223,
224,
225,
225,
226,
227,
228,
228,
229,
230,
231,
231,
232,
233,
234,
234,
235,
236,
236,
237,
238,
239,
239,
240,
241,
242,
242,
243,
244,
245,
245,
246,
247,
248,
248,
249,
250,
251,
251,
252,
253,
254,
254,
255,
256,
256,
257,
258,
259,
259,
260,
261,
262,
262,
263,
264,
265,
265,
266,
267,
268,
268,
269,
270,
271,
271,
272,
273,
273,
274,
275,
276,
276,
277,
278,
279,
279,
280,
281,
282,
282,
283,
284,
285,
285,
286,
287,
288,
288,
289,
290,
291,
291,
292,
293,
293,
294,
295,
  };
       
  position = cmData[data];
  return position;
}

void main3(void){
  PLL_Init();  // E clock is 24 MHz in both RUN and LOAD modes
  ADC_Init();  // turn on ADC
  LCD_Open();
  LCD_Clear();
asm cli        // enable debugger
  for(;;){
    LCD_GoTo(0);       // move to home
    Data = ADC_In(2);  // sample 8-bit channel 2
    Position = Convert(Data);  // you write this function
    LCD_OutFix(Position);
    //Timer_Wait10ms(10); // 100ms wait
  }
}  
void main(void){
  unsigned char *txtPnt;
  unsigned char EE319K[9] = {
    'E','E','3','1','9','K',' ',' ',0
  };
  unsigned char CM[5] = {
    ' ',' ','c','m',0,
  };
  txtPnt = EE319K;
  
  DDRP |= 0x80;  // PP7 heartbeat
  PLL_Init();  // E clock is 24 MHz in both RUN and LOAD modes
  LCD_Open();  // Initialize LCD
  ADC_Init();
  LCD_Clear();

  LCD_OutString(txtPnt);
  //Timer_Wait10ms(100);
  OC0_Init();
  txtPnt = CM;
asm cli        // enable debugger
  for(;;){
    while(ADCStatus == 0) { }
    LCD_Clear();
    Position = Convert(ADCMail);
    ADCStatus = 0;
    LCD_OutFix(Position);
    LCD_OutString(txtPnt);
  }
}       
