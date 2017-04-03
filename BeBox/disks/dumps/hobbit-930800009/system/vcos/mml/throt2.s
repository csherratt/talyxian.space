/* Execution List Throttle 
/* throttle hack for play
/* always reads the input fifo
/*	This module aborts the data-flow execution list if the input fifo has
/*	insufficient data, or if the output fifo has insufficient space. 
/*	This module is called "Throttle" and what makes it unique is its
/*	ability to tell the Scheduler to abort execution list processing.
/*
/*	A data-flow execution list is one of the VRM managed lists [2,11].
/*	Execution flow in these lists is managed by the Scheduler.
/*	These lists are useful when "frame-rate-conversion" (FRC) or 
/*	"inter-DSP-communication" (IDC) is needed.  FRC and IDC are similar
/*	in need to a generalized "data-flow" concept, but are simpler since
/*	they use fixed buffers for input and output.
/*
/*	Throttle may be customized for particular task, or embedded into
/*	any module(s) in a data-flow task.
/*
/*	Throttle can be used anywhere in the data-flow execution lists [2,11].
/*	Throttle may not be used in BLevel (background, non-real-time), or
/*	ILevel (interrupt, real-time) execution lists.
/*
/*	For disk-to-fifo (play from disk) tasks, throttle may also monitor 
/*	the input fifo for "less-than-half-full" and "empty" conditions, 
/*	and signal the host for more data.
/*
/*	New arguments may be added to the pbuf parameter section after the
/*	VrmCmd argument.
/*	jfl 9/92
*/
#include <macros.h>

/* Scheduler Commands 
*/
#define CONTINUE 0x10000  /* Continue execution list processing */
#define EXITLIST 0x10001  /* Abort executiion list processing */

/* Section Declarations
*/
NewModule( main)
NewSection( main, sPROG)
NewSection( fin, sFIFO)
NewSection( aout, sAIAO)
NewSection( fout, sFIFO)
NewSection( pbuf, sPARAM)

AppendSection( pbuf)
VrmCmd: long 0x0	/* vrm command to scheduler, 0=>nop */

AppendSection( main)
	Push( r18)

/* initialize the the scheduler command to CONTINUE
*/
	r6= (ushort24) CONTINUE

/* test input and output conditions
*/
	GetSectionSize( aout)	/* get the required frame size */
	r5= r2

	GetFifoWriteCount( fout)
	r2-r5
	if( lt) pcgoto exitlist	/* cannot write output frame */
	nop

	GetFifoReadCount( fin)
	r2-r5
	if( lt) pcgoto exitlist2/* cannot read input frame */
	nop
	pcgoto exit
	nop

/* hack: empty input fifo
*/
exitlist2:
	ReadFifo( fin, r5, aout)

/* set the scheduler command to EXITLIST 
*/
exitlist:
	r6= (ushort24) EXITLIST 

exit:
	r7= (long)VrmCmd
	r7= *r7
	nop
	if( ne) r6= r7		/* scheduler command = any non-zero VrmCmd */

	Pop( r18)
	return( r18)
	Push( r6)		/* send command to scheduler */

/* NOTE: 
/* The scheduler retrieves commands left on the stack by the module.
/* The scheduler will only accept valid commands on the stack.
/* An invalid command will be detected by the scheduler and result in
/* the scheduler going into a "stack_error" infinite loop.  
/* Valid commands are (currently): CONTINUE and EXITLIST
*/


