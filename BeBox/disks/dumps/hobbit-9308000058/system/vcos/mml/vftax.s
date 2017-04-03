/*****************************************************************************/
/*    vftax.s
/*****************************************************************************/
/* Volume, Fifo-to-Aiao, Mix into Output channel
/*      if input fifo is empty
/*              set Status param to 0
/*              exit
/*      else
/*              set Status param to number of bytes in fin
/*              read input fifo (fin) into input buffer (ain)
/*              read output buffer (aout) into CacheMem
/*              for each sample (i), aout[i]= volume*ain[i] + aout[i]
/*              write aout to HostMem
/*      9/92 jfl
/*****************************************************************************/
#include  <macros.h>

NewModule( main)
NewSection( main,  sPROG)
NewSection( cmain, sPROG)
NewSection( fin,   sFIFO)
NewSection( ain,   sAIAO)
NewSection( aout,  sAIAO)
NewSection( pbuf,  sPARAM)

AppendSection( pbuf)
Volume: long 0x3f800000 /* volume control, set to ieee float 1.0 */
Status: long 0x0        /* 0:fin empty, else finReadCount */

/*****************************************************************************/
/* main
*/
AppendSection( main)
	Push( r18)
	LoadRunSection( cmain, cmain)

/*****************************************************************************/
/* cmain
*/
AppendSection( cmain)
	/* if (finCount < FrameSize)    status=0, exit
	/* else                         goto continue
	*/
	GetFifoReadCount( fin)
	!r5= Status                     /* r5 pts to Status */
	*r5= r2                         /* save amt. in fifo */

	r2 - r0
	if (eq) pcgoto exit             /* don't do anything if fifo empty */
	r6 = r2				/* save fifo size in r6 */
	
	GetSectionSize( ain)
	
	r6-r2                           /* compare fifo size - aiao size */
	if(gt) r6=r2                    /* if fifo size > aiao size */
					/* copy aiao size data */
	/* set Status= finCount
	/* load ain from fin
	/* load aout
	/* sum volume*ain into aout
	/* save aout
	/* r2=finCount r5=&Status r6=FrameSize
	*/ 
	ReadFifo( fin, r6, ain)         /* load ain input buffer */

	LoadSection( aout)              /* load aout output buffer */

	r5=  (long)r6 >>1;
	r5=  (long)r5 - 2;              /* r5 is # of samples - 2 */
	!r1=  (long)ain;                /* r1 pts to ain */
	!r6=  (long)aout;               /* r6 pts to aout */
	r3=   (long)r6;                 /* r3 pts to aout */
	!r2=  (long)Volume;             
	a2=   dsp( *r2);                /* a2 is volume for this frame */

	a3= float16( *r1++);            /* convert input int ->float */
	do 3, r5;                       /* next 4 instr, r5+1 times */
		a1= float16( *r6++);    /* get output */
		a0= a1 + a2 * a3;       /* do volume on input */
		a3= float16( *r1++);    /* wait for a0 */
		*r3++= a0= int16( a0);  /* sum into output */
	a1= float16( *r6);              /* get output */
	a0= a1 + a2 * a3;               /* do volume on input */
	*r6++= a0= int16( a0);          /* sum into output */

	SaveSection( aout)
exit:
	Pop( r18)
	return( r18)
	nop

