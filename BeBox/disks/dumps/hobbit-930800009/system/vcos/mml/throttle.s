/*--------------------------------------------------------------------------*/
/* Execution List Throttle 
/*	This module aborts an SLevel (scheduled level) if the input fifo has
/*	insufficient data, or if the output fifo has insufficient space. 
/*	This module is called "Throttle" and what makes it unique is its
/*	ability to tell the Scheduler to abort execution list processing.
/*
/*	A "Scheduled Level" is one of the VRM managed lists [2,11].
/*	Execution flow in an SLevel is therefore managed by the Scheduler
/*	and the "throttle" function in the SLevel.
/*	These lists are useful when "frame-rate-conversion" (FRC) or 
/*	"inter-DSP-communication" (IDC) is needed.  FRC and IDC are similar
/*	to a generalized "data-flow" concept, but are simpler since
/*	they use fixed buffers for input and output.
/*
/*	Throttle can be used anywhere in a schedule level [2,11].
/*	Throttle can not be used in BLevel (background, non-real-time), or
/*	ILevel (interrupt, real-time) execution lists.
/*
/*	This throttle module may be CUSTOMIZED for particular task, or 
/*	embedded into other modules.  Just be sure to not call the resulting
/*	module by the same name.
/*
/*	For disk-to-fifo (play from disk) tasks, throttle may be modified
/*	to also monitor the input fifo for "less-than-half-full" and "empty" 
/*	conditions, and signal the host for more data.
/*
/*	jfl 5/93
/*--------------------------------------------------------------------------*/
#include <macros.h>

/*--------------------------------------------------------------------------*/
/* Scheduler Commands 
/*--------------------------------------------------------------------------*/
#define CONTINUE 0x10000  /* Continue execution list processing */
#define EXITLIST 0x10001  /* Abort executiion list processing */

/*--------------------------------------------------------------------------*/
/* Section Declarations
/*--------------------------------------------------------------------------*/
NewModule( main)
NewSection( main, sPROG)
NewSection( cmain, sPROG)
NewSection( fin, sFIFO)
NewSection( fout, sFIFO)
NewSection( pbuf, sPARAM)

/*--------------------------------------------------------------------------*/
AppendSection( pbuf)
InputSize: long 0x0	/* input buffer size */
OutputSize: long 0x0	/* input buffer size */
FlushFlag: long 0x0	/* 0:no flush 1:flush input fifo */

/*--------------------------------------------------------------------------*/
AppendSection( main)
	Push( r18)
	LoadRunSection( cmain, cmain)

/*--------------------------------------------------------------------------*/
AppendSection( cmain)

/* initialize the the scheduler command to CONTINUE
*/

	r8= (long) pbuf
	r6= (long) *r8++	/* r6 is input size */
	r7= (long) *r8++	/* r7 is output size */
	r8= (long) *r8++	/* r8 is flush flag */
	r9= (ushort24) CONTINUE

/* test if fout can hold enuf data
*/
	GetFifoWriteCount( fout)
	r2-r7
	if( lt) pcgoto exitlist		/* cannot write output frame */
	nop

/* test if fin has enuf data
/* if FlushFlag, flush fin data 
*/
	GetFifoReadCount( fin)
	r2-r6
	if( ge) pcgoto exit		
	r8= r8
	if( eq) pcgoto exitlist
	nop
	ReadFifo( fin, 4000, scratch)

/* set the scheduler command to EXITLIST 
*/
exitlist:
	r9= (ushort24) EXITLIST 

exit:
	Pop( r18)
	return( r18)
	Push( r9)		/* send command to scheduler */

scratch: long 0x0		/* 4000 onchip bytes used for dumping fin */

/*--------------------------------------------------------------------------*/
/* NOTE: 
/* The scheduler retrieves commands left on the stack by the module.
/* The scheduler will only accept valid commands on the stack.
/* An invalid command will be detected by the scheduler and result in
/* the scheduler going into a "stack_error" infinite loop.  
/* Valid commands are (currently): CONTINUE and EXITLIST
/*--------------------------------------------------------------------------*/


