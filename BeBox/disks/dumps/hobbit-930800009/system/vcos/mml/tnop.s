/* module to waste processing time onchip 
*/
#include <macros.h>

NewModule( main)
NewSection( main, sPROG)
NewSection( pbuf, sPARAM)
loopTimes: long 0x0	/* amount of time in .1ms incs to waste */

AppendSection( main)

	!r1= loopTimes
	r1= *r1
	nop

again:
	r1= r1-1
	if( gt) pcgoto loop
	nop

	return( r18)
	nop

loop:
	do 0, 1388
		nop
	pcgoto again
	nop


