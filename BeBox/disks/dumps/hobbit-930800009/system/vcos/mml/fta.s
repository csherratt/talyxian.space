/*****************************************************************************/

/*             File Name: fta.s
/*****************************************************************************/
/*       Description:  FIFO to AIAO Wire program
/*           Assumes:
/*                   Reads the entire input buffer to output buffer
/*                   The buffer sizes can be changed in the fta.tbd file.
/*                   buffers size is N x 4byte
/*                   variable frame size
/*****************************************************************************/
#include <macros.h>

NewModule( main)
NewSection( main, sPROG)
NewSection( cmain, sPROG)
NewSection( fin,  sFIFO)
NewSection( aout, sAIAO)
/*---------------------------------------------------------------------------*/




/*****************************************************************************/
/*      main()
/*****************************************************************************/
/*     start execution offchip
/*****************************************************************************/
AppendSection( main)
       Push(r18)              /* save the return pointer */
       LoadRunSection( cmain, cmain) /* load the prog onchip ( see ata.ldf) */
/*===========================================================================*/



/*****************************************************************************/
/*      cmain()
/*****************************************************************************/
/*     continue execution onchip
/*****************************************************************************/
AppendSection( cmain)
       GetSectionSize( aout)       /* returns bytesize in r2       */
       ReadFifo( fin, r2,  aout)  /* move input to output buffer           */
exit:
       Pop(r18)                     /* restore the return pointer            */
       return(r18);                 /* exit this module                      */
       nop;
/*===========================================================================*/
