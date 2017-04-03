/*****************************************************************************/
/*    vftax2.s
/*****************************************************************************/
/* Description:  
/*	Volume control and mixing portion of the "vftax" function
/*
/*	if status != 0
/*		aout[i] = aout[i] + volume*ain[i]
/*	else
/*		nop
/* note:
/*	vftax does volume, status, fta, and mix function in one module.
/*	vftax1 and vftax2 together provide the same functions, except these two
/*	modules allow a decoder module to be used in the middle, whereas
/*	vftax does not.
/*	The param buffer structure is the same for all three modules.
/*****************************************************************************/
#include  <macros.h>

NewModule( main)
NewSection( main,  sPROG)
NewSection( cmain, sPROG)
NewSection( ain,   sAIAO)
NewSection( aout,  sAIAO)
NewSection( pbuf,  sPARAM)

AppendSection( pbuf)
volume:    long 0x3f800000	/* volume control, set to ieee float 1.0 */
status:    long 0x0  		/* status set in vftax1.s */		

AppendSection( main)
           r10= (long)r18;
           LoadRunSection( cmain, cmain)

/*****************************************************************************/
/*    cmain
/*****************************************************************************/
AppendSection( cmain)
	r1= (long) status
	r1= *r1
	nop
	if( eq) pcgoto exit
	nop
	LoadSection( ain)
	LoadSection( aout)
	GetSectionSize( ain)
	r6=  (long)r2 >>1;            /* r6<-- # of samples.              */
	r5=  (long)r6 - 2;            /* r5<-- (-2 + # of samples).       */
	/*----------------------------------------------------------------*/
	/* do volume, and sum into output.
	/*----------------------------------------------------------------*/
	!r1=  (long)ain;
	!r6=  (long)aout;
	!r3=  (long)volume;
	a2=   dsp( *r3);

	r3=   (long)r6;
	a3= float16( *r1++);          /* get input and convert int ->float*/
	do 3, r5;                     /* next 4 instr, r5+1 times.        */
		a1= float16( *r6++);         /* get output */
		a0= a1 + a2 * a3;            /* do volume on input */
		a3= float16( *r1++);         /* wait for a0 */
		*r3++= a0= int16( a0);       /* sum into output */

	a1= float16( *r6);            /* get output                       */
	a0= a1 + a2 * a3;             /* do volume on input               */
	*r6++= a0= int16( a0);        /* sum into output                  */

exit:
	SaveSection( aout)
	return( r10 );
	nop;
