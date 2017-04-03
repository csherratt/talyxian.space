/*****************************************************************************/
/*             File Name: atf.s
/*****************************************************************************/
/*       Description:  AIAO to FIFO Wire program
/*                   variable frame size
/*****************************************************************************/
#include <macros.h>

NewModule( main)
NewSection( main,  sPROG)
NewSection( cmain, sPROG)
NewSection( ain,  sAIAO)
NewSection( fout, sFIFO)
/*---------------------------------------------------------------------------*/



/*****************************************************************************/
/*      main()
/*****************************************************************************/
/*     start execution offchip
/*****************************************************************************/
AppendSection( main)
       Push(r18)               /* save the return pointer               */
       LoadSection( cmain)     /* load the input onchip ( see ata.ldf)  */
       !r1= (long) cmain;
       call r1 (r18);          /* invoke the  cmain function               */
       nop;
/*===========================================================================*/



/*****************************************************************************/
/*      cmain()
/*****************************************************************************/
/*     continue execution onchip
/*****************************************************************************/
AppendSection( cmain)
       LoadSection( ain)        /* load the input onchip ( see atf.ldf)  */
       GetSectionSize( ain)     /* returns bytesize of input in r2       */
       WriteFifo( fout, r2,  ain) /* move input to output buffer           */
exit:
       Pop(r18)                 /* restore the return pointer            */
       return(r18);             /* exit this module                      */
       nop;
/*===========================================================================*/
