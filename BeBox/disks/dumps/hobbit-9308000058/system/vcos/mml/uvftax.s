/* 8b mulaw Fifo to 16b linear Aiao,
/* sums into output buffer
/* volume control
/* framesize scaleable in .tbd file
*/
#include "macros.h"                          /*                              */

NewModule(main)                /* start at label main */

NewSection(main, sPROG)        /* startup section */
NewSection(cmain, sPROG)       /* main cached section */
NewSection(input, sFIFO)       /* input fifo */
NewSection(output, sAIAO)      /* output aiao */
NewSection(abuf, sAIAO)        /* scratch (automatic variables) */
NewSection(vparam, sPARAM)      /* volume control */

AppendSection(vparam)
volume: long 0x3f800000      /* volume: init to (ieee format)1.0 */

AppendSection(main)
        Push(r18)
        LoadRunSection( cmain, cmain)

AppendSection(cmain)
/* load output buffer because we need to sum into it */
        LoadSection( output)

/*set dau for mulaw conversion */
        dauc= (byte)r0

/* get bytesize of mulaw frame, returns count in r2 */
        GetSectionSize( abuf)
        r5= (long) r2

/* then read mulaw into abuf, returns count in r4 */
        ReadFifo( input, r2, abuf)

/* if not enough data to fill abuf, then exit */
        (long)r5-r4
        if( ne) pcgoto exit

/* then convert mulaw to float, do volume, and sum into output */
        !r1= (long)abuf
        !r2= (long)output
        !r3= (long)volume
        a2= dsp( *r3)
        r5 = (short)r4-2

sumout:
        a0= ic( *r1++)  /* get input and convert mulaw -> float */
        a1= float16( *r2) /* get output */
        nop     /* wait for a0 */
        a0= a1 + a2 * a0        /* do volume on input, and sum into output */
        *r2++= a0= int16( a0)
        if( r5-->=0) pcgoto sumout
        nop

exit:
        SaveSection( output)
        Pop(r18)
        return(r18)
        nop
