#include <macros.h>

NewModule( main)
NewSection( main, sPROG)
NewSection( cmain1, sPROG)
NewSection( cmain2, sPROG)
NewSection( ain, sAIAO)
NewSection( aout, sAIAO)
NewSection( fio, sFIFO)

#define BUFSIZE 1024

AppendSection( main)

Init:	Push( r18)
	LoadRunSection( cmain1, cmain1)

Run:	Push( r18)
	LoadRunSection( cmain2, cmain2)

ZerBuf: BUFSIZE* char 0x0

AppendSection( cmain1)
	WriteFifo( fio, BUFSIZE, ZerBuf)
	GetFifoWriteCount( fio)
	r2= r2
	if( gt) pcgoto cmain1
	nop
	SetEntryPoint( Run)
	Pop( r18)
	return( r18)
	nop

AppendSection( cmain2)
	GetSectionSize( ain)
	r5= r2
	ReadFifo( fio, r5, aout)
	WriteFifo( fio, r5, ain)
	Pop( r18)
	return( r18)
	nop

