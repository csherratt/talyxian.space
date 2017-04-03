/* src3t1.s */
#include <macros.h>

#define TabSize 32
#define TabSizeM1 31
#define TabSizeM3 29
#define SampInc  12
#define MaxAinSize 2304

NewModule( main)
NewSection( main, sPROG)
NewSection( cmain, sPROG)
NewSection( dbuf, sPROG)
    TabSize*float 0.0
NewSection( fbuf, sPROG)
	MaxAinSize*char 0x0
NewSection( ain, sAIAO)
NewSection( aout, sAIAO)

AppendSection( main)
	Push( r18)
	LoadRunSection( cmain, cmain)

AppendSection( cmain)
	LoadSection( ain)
	LoadSection( dbuf)

/* convert input to float array */
	GetSectionSize( ain )
	r5= r2>>1
	r5 = r5-1				/* r5 is number of input samples -1 */
	r1= ain
	r2= fbuf
do 0, r5
	*r2++= a0= float16( *r1++)

/* do fir for each output sample */
	GetSectionSize( aout)
	r5= r2>>1
	r5= r5-2                          /* r5 is number of output samples -2 */
	r6= aout                          /* r6 pts to output buffer */
	r17= (short) SampInc-TabSizeM1*4  /* r17 used to reset dbuf ptr */
	r18= (short) -TabSizeM1*4         /* r18 used to reset table ptr */
	r1= dbuf                          /* r1 pts to dbuf */
	r3= AddressPR( table)             /* r3 pts to table */
lout:
	a0= *r1++ * *r3++  /* do first tap of fir */
	do 0, TabSizeM3
		a0= a0 + *r1++ * *r3++  /* do fir */
	a0= a0 + *r1++r17 * *r3++r18 /* do last tap and reset ptrs */
	if( r5-- >= 0) pcgoto lout  /* repeat for each sample in frame */
	*r6++= a0= int16( a0)       /* output one sample */

/* move state data to dbuf */
	r3= dbuf
	do 0, TabSizeM1
		a0= (*r3++= *r1++) + a0  

exit:
	SaveSection( dbuf)
	SaveSection( aout)
	Pop( r18)
	return( r18)
	nop

/* Kaiser Window 3t1 low pass filter coefficients
/* 0 to 7/24 BW, 1.5dB passband ripple, (where: BW=fs/2)
/* -16db at 1/3 BW, -40dB at 1/2 BW
*/
table: 
float   9.680656E-003, 2.184670E-002, 1.495805E-002, -7.392026E-003;
float  -2.648726E-002, -2.343400E-002, 3.284168E-003, 3.302637E-002;
float   3.742991E-002, 4.799995E-003, -4.473761E-002, -6.768968E-002;
float  -2.640015E-002, 8.077346E-002, 2.111848E-001, 3.001005E-001;
float   3.001005E-001, 2.111848E-001, 8.077346E-002, -2.640015E-002;
float  -6.768968E-002, -4.473761E-002, 4.799995E-003, 3.742991E-002;
float   3.302637E-002, 3.284168E-003, -2.343400E-002, -2.648726E-002;
float  -7.392026E-003, 1.495805E-002, 2.184670E-002, 9.680656E-003;
