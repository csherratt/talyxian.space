/*****************************************************************************/
/* vftax1
/*****************************************************************************/
/* Description:  
/*	Fifo to Aiao portion of the "vftax" (volume, fta, mix) function
/*
/*	if input fifo has at least one frame of data
/*		read fifo to aiao 
/*		pbuf->status= input fifo size
/*	else 
/*		pbuf->status= 0
/* note:
/*	vftax does volume, status, fta, and mix function in one module.
/*	vftax1 and vftax2 together provide the same functions, except these two
/*	modules allow a decoder module to be used in the middle, whereas
/*	vftax does not.
/*	The param buffer structure is the same for all three modules.
/*****************************************************************************/
#include <macros.h>

NewModule( main)
NewSection( main, sPROG)
NewSection( cmain, sPROG)
NewSection( fin,  sFIFO)
NewSection( aout, sAIAO)
NewSection( pbuf, sPARAM)
/*---------------------------------------------------------------------------*/

/*****************************************************************************/
AppendSection( pbuf)
volume:	long 	0x3f80000	/* ieee 1.0, not used here, used in vftax2 */
status:	long 	0x0		/* set to size of fin, or 0 when fin is empty */
/*---------------------------------------------------------------------------*/

/*****************************************************************************/
/* main()
/*	start execution offchip
/*****************************************************************************/
AppendSection( main)
	Push(r18)              /* save the return pointer */
	LoadRunSection( cmain, cmain) /* load the prog onchip ( see ata.ldf) */
/*===========================================================================*/



/*****************************************************************************/
/* cmain()
/*	continue execution onchip
/*****************************************************************************/
AppendSection( cmain)
	GetSectionSize( aout)       
	r6= r2			/* r6= input framesize */
	GetFifoReadCount( fin)	/* r2= input fifo data size */
	r2-r6				
	if( lt) r2= r0		/* if less than a frame, set size to zero */

	r5= (long) status
	*r5= r2				/* status= input fifo data size */
	ReadFifo( fin, r6,  aout)	/* move input to output buffer */

exit:
	Pop(r18)			/* restore the return pointer */
	return(r18)			/* exit this module */
	nop;
/*===========================================================================*/
