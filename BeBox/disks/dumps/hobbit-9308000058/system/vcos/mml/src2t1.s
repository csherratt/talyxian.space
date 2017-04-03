/* src2t1.s */
#include <macros.h>

#define TabSize 32
#define TabSizeM1 31
#define TabSizeM3 29
#define SampInc 8
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

/* Parks McClellan 2t1 low pass filter
/* 0 to 3.3/8 BW passband, .3dB ripple (where: BW=fs/2)
/* -37 dB at 1/2 BW
*/
table: 
float   8.135612E-003, 2.371940E-002, 4.793234E-003, -1.406760E-002;
float  -1.147951E-002, 1.621779E-002, 2.045692E-002, -1.493497E-002;
float  -3.395371E-002, 8.920031E-003, 5.313616E-002, 6.636159E-003;
float  -8.514982E-002, -4.925804E-002, 1.790245E-001, 4.143271E-001;
float   4.143271E-001, 1.790245E-001, -4.925804E-002, -8.514982E-002;
float   6.636159E-003, 5.313616E-002, 8.920031E-003, -3.395371E-002;
float  -1.493497E-002, 2.045692E-002, 1.621779E-002, -1.147951E-002;
float  -1.406760E-002, 4.793234E-003, 2.371940E-002, 8.135612E-003;
