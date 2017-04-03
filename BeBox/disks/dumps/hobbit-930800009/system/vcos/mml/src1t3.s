/* src1t2.s */
#include <macros.h>

#define SRC 3
#define NumC 33
#define NumCM1 32          /* NumC-1 */
#define NumCdSrcM3 8       /* NumC/SRC - 3 */
#define MaxAinSize 768

NewModule( main)
NewSection( main, sPROG)
NewSection( cmain, sPROG)
NewSection( dbuf, sPROG)
    NumC*float 0.0
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
	r5= r5-1                           /* r5 is number of input samples -2 */
	                                   /* which is the number of lout loops */
	r1= dbuf                           /* r1 pts to dbuf */
	r3= AddressPR( table)        
	r3= r3 + 4*SRC-4                   /* r3 pts to table */
	r6= aout                           /* r6 pts to output buffer */
	r17= (short) 4-4*NumC/SRC       /* r17 used to phase dbuf ptr */
	r18= (short) 4*SRC-4*NumC-4     /* r18 used to phase table ptr */
	r16= (short) 8-4*NumC/SRC       /* r16 used to reset dbuf ptr */
	r15= (short) 2*4*SRC-4*NumC-4   /* r15 used to reset table ptr */
	r19= 4*SRC                         /* r19 used to inc table ptr */
lout:
	a0= *r1++ * *r3++r19              /* first phase(s) */
	do 0, NumCdSrcM3
		a0= a0 + *r1++ * *r3++r19     /* do fir */
	a0= a0 + *r1++r17 * *r3++r18      /* do last tap and phase ptrs */
	*r6++= a0= int16( a0)             /* output one sample */
t0: nop; nop; nop

	a0= *r1++ * *r3++r19              /* first phase(s) */
	do 0, NumCdSrcM3
		a0= a0 + *r1++ * *r3++r19     /* do fir */
	a0= a0 + *r1++r17 * *r3++r18      /* do last tap and phase ptrs */
	*r6++= a0= int16( a0)             /* output one sample */
t1: nop; nop; nop

	a0= *r1++ * *r3++r19              /* last phase */
	do 0, NumCdSrcM3
		a0= a0 + *r1++ * *r3++r19     /* do fir */
	a0= a0 + *r1++r16 * *r3++r15      /* do last tap and reset ptrs */
t2: nop; nop; nop
	if( r5-- >= 0) pcgoto lout        /* repeat for each sample in frame */
	*r6++= a0= int16( a0)             /* output one sample */

/* move state data to dbuf */
	r3= dbuf
	do 0, NumCM1
		a0= (*r3++= *r1++) + a0  

exit:
	SaveSection( dbuf)
	SaveSection( aout)
	Pop( r18)
	return( r18)
	nop

/* Kaiser Window 3t1 filter
/* 0 to 7/24 BW, .8dB ripple, (BW=fs/2)
/* -16dB at 8/24 BW, -30dB at 1/2 BW, -40dB at BW
*/
table: 
float    -4.03179e-08,     5.29330e-02,     6.30172e-02,     1.43306e-02;
float    -5.62697e-02,    -8.51437e-02,    -3.65436e-02,     5.89478e-02;
float     1.19366e-01,     7.57901e-02,    -6.09059e-02,    -1.87316e-01;
float    -1.68809e-01,     6.20991e-02,     4.41120e-01,     7.93995e-01;
float     9.37500e-01,     7.93995e-01,     4.41120e-01,     6.20991e-02;
float    -1.68809e-01,    -1.87316e-01,    -6.09059e-02,     7.57901e-02;
float     1.19366e-01,     5.89478e-02,    -3.65436e-02,    -8.51437e-02;
float    -5.62697e-02,     1.43306e-02,     6.30172e-02,     5.29330e-02;
float    -4.03179e-08;
