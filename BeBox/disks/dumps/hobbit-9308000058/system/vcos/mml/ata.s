/*****************************************************************************/
/*             File Name: ata.s
/*****************************************************************************/
/*       Description:  AIAO to AIAO Wire program
/*           Assumes:
/*                   buffers size is N x 4byte
/*                   variable frame size
/*****************************************************************************/
#include <macros.h>

NewModule( main)
NewSection( main, sPROG)
NewSection( ain, sAIAO)
NewSection( aout, sAIAO)
/*---------------------------------------------------------------------------*/



/*****************************************************************************/
/*     Main()
/*****************************************************************************/
/*     start execution offchip
/*****************************************************************************/
AppendSection( main)

       GetSectionSize( ain)	/* returns bytesize of input in r2 */
       r2 = (long)r2 >> 2	
       r2 = (long)r2 - 1	/* r2 is the number of 32b words -1 */
       r1 = (long) ain		/* r1 pts to input buffer */
       r3 = (long) aout		/* r3 pts to output buffer */
       do 0, r2;
         a0 = (*r3++ = *r1++) + a0; /* copy input to output buffer */

exit:
       return(r18);                 /* exit this module */
       nop;
/*===========================================================================*/
