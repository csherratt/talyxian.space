/* ftf.s
/* move input to output fifo 
/* moves up to sizeof( temp) bytes at a time
/* does not overwrite output fifo
*/
#include "macros.h"
NewModule( main)
NewSection( main, sPROG)
NewSection( temp, sAIAO)
NewSection( fin, sFIFO)
NewSection( fout, sFIFO)

AppendSection( main)
	Push( r18)

	GetFifoReadCount( fin)
	r5=r2
	GetSectionSize( temp)
	r5-r2
	if( gt) r5= r2
	GetFifoWriteCount( fout)
	r5-r2
	if( gt) r5= r2
	ReadFifo( fin, r5, temp)
	WriteFifo( fout, r5, temp)

exit:
	Pop( r18)
	return( r18)
	nop

