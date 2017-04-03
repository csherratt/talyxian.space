/* src1t2.s 
*/
#include <macros.h>
#include <mmio.h>

#define SRC 2
#define NumC 32
#define NumCM1 31          /* NumC-1 */
#define NumCdSrcM3 13       /* NumC/SRC - 3 */
#define MaxAinSize 1152

NewModule( main)
NewSection( main, sPROG)
NewSection( cmain, sPROG)
NewSection( dbuf, sPROG)
	NumC*float 0.0
NewSection( fbuf, sPROG)
	MaxAinSize*char 0x0
NewSection( ain, sAIAO)
NewSection( aout, sAIAO)

NewSection( pbuf,  sPARAM)
volume:    long 0x3f800000  /* volume control, set to ieee float 1.0 */

AppendSection( main)
	Push( r18)
	LoadRunSection( cmain, cmain)

AppendSection( cmain)
	LoadSection( dbuf)

/* convert input to float array */
	GetSectionSize( ain )
	r5= r2>>1
	r5 = r5-1				/* r5 is number of input samples -1 */
	r1= ain
	r3 = r1		// save r1
	r2= fbuf

	do 0,r5
		*r2++= a0= float16( *r1++);
	
	do 0,r5
		*r3++=r0;		// New, clear ain buffer when done

/* do fir for each output sample */
	r5= r5-1                           /* r5 is number of input samples -2 */
	                                   /* which is the number of lout loops */
	r1= dbuf                           /* r1 pts to dbuf */
	r3= AddressPR( table)        
	r3= r3 + 4*SRC-4                   /* r3 pts to table */
	r6= aout                           /* r6 pts to output buffer */

	// New code: get volume
	!r7=(long)volume
	a3=dsp(*r7)			// a3=volume

	r17= (short) 4-4*NumC/SRC       /* r17 used to phase dbuf ptr */
	r18= (short) 4*SRC-4*NumC-4     /* r18 used to phase table ptr */
	r16= (short) 8-4*NumC/SRC       /* r16 used to reset dbuf ptr */
	r15= (short) 2*4*SRC-4*NumC-4   /* r15 used to reset table ptr */
	r19= 4*SRC                         /* r19 used to inc table ptr */
lout:
	a0= *r1++ * *r3++r19              /* first phase(s) */

	do 0, NumCdSrcM3
		a0= a0 + *r1++ * *r3++r19 /* do fir */
	a0= a0 + *r1++r17 * *r3++r18      /* do last tap and phase ptrs */

	// New code: sum into output
	a1=float16(*r6);			// read output sample
	a0=a1 + a3 * a0;			// sum into output

	*r6++= a0= int16( a0)             /* output one sample */

	a0= *r1++ * *r3++r19              /* last phase */
	do 0, NumCdSrcM3
		a0= a0 + *r1++ * *r3++r19 /* do fir */
	a0= a0 + *r1++r16 * *r3++r15      /* do last tap and reset ptrs */

	// New code: sum into output
	a1=float16(*r6);			// read output sample
	a0=a1 + a3 * a0;			// sum into output

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

/* Parks McClellan 2t1 low pass filter
/* 0 to 3.3/8 BW passband, .3dB ripple (where: BW=fs/2)
/* -37 dB at 1/2 BW
*/
table: 
float     1.62712e-02,     4.74388e-02,     9.58647e-03,    -2.81352e-02;
float    -2.29590e-02,     3.24356e-02,     4.09138e-02,    -2.98699e-02;
float    -6.79074e-02,     1.78401e-02,     1.06272e-01,     1.32723e-02;
float    -1.70300e-01,    -9.85161e-02,     3.58049e-01,     8.28654e-01;
float     8.28654e-01,     3.58049e-01,    -9.85161e-02,    -1.70300e-01;
float     1.32723e-02,     1.06272e-01,     1.78401e-02,    -6.79074e-02;
float    -2.98699e-02,     4.09138e-02,     3.24356e-02,    -2.29590e-02;
float    -2.81352e-02,     9.58647e-03,     4.74388e-02,     1.62712e-02;
