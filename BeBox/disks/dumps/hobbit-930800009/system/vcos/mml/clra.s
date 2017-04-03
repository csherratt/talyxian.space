/* clear an Aiao buffer */
#include "macros.h"

NewModule( main)
NewSection( main, sPROG)
NewSection( ain, sAIAO)

AppendSection( main)
	Push( r18)

	GetSectionSize( ain)
	r2= r2>>2	
	r5= r2 - 1	/* r5 is number of words - 1 */
	!r1= (long) ain

do 0, r5
	*r1++= r0

exit:
	Pop( r18)
	return(r18)
	nop
