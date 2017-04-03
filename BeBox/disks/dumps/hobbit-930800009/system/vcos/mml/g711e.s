/*
g711e.s
Convert 7/8-bit mulaw/alaw in any bit order to 16 bit linear samples
Author:
	JFL
Modified:
	12/12/92 ARR: Added support for 7/8 bit, mulaw/alaw, 
	and bit order switches
*/
#include "macros.h"       

NewModule(main)                 /* start at label main          */

NewSection(main, sPROG)         /* startup section              */
NewSection(cmain, sPROG)        /* main cached section          */
NewSection(pbuf,  sPARAM)       /* parameter buffer             */
NewSection(ain, sAIAO)          /* input buffer                 */
NewSection(aout, sAIAO)         /* output buffer                */

AppendSection( pbuf)
mode:    long 0x00000000        /* bits 7-0=dauc:       */
				/*      0x00->mulaw, 0x03->alaw */
				/* bit 8=bit order:             */
				/*      0->sign in bit 0, 1->sign in bit 7*/
				/* bit 9=7/8 bit switch                   */
				/*      0->8 bit, 1->7 bit (lsb set to 0) */

AppendSection(main)
	Push(r18)
	LoadRunSection(cmain, cmain)

AppendSection(cmain)
	LoadSection(ain);               /* load input buffer            */

	!r5 = (long)mode;               /* fetch mode address           */
	r5 = *r5;                       /* r5 = mode word               */

	GetSectionSize( aout)           /* get ouput framesize in r2    */
	r6=r2-1;                        /* r6 = # samples-1             */
	r7=r2>>1;                       /* r7 = # samples/2             */
	
	!r8= (long) ain
	!r9= (long) aout

/* first do 16 bit input to mulaw/alaw conversion                       */
	r10 = r9                        /* save address of aout         */

	dauc = (byte)r5;                /* set mulaw/alaw format        */

	/* at this point:       r5=mode, r6=count, r7=#samples/2        */
	/*                      r8=ain,  r9=aout,  r10=aout             */

	do r6
	{
		a0= float16( *r8++)     /* 16-bit -> float              */
		*r9++= a0= oc( a0)      /* 32-bit float -> mulaw/alaw   */
	}

	r5 & 0x200;                     /* 7 or 8 bit?                  */
	if (eq) pcgoto cont1;           /* if 8 bit, continue           */

/* clear least significant bit of output byte                           */
	r9 = r10;                       /* restore r9 = aout, latent    */

	!r8= (long) 0x7f7f7f7f;

	r6 = r7 >> 1;
	r6 = r6 - 1;                    /* r6 = (#samples/4)-1          */

	/* at this point:       r5=mode, r6=count, r7=#samples/2        */
	/*                      r8=mask, r9=aout, r10=aout              */

	do r6
	{
		r1= (long) *r9;
		nop;
		r1 = (long) r1 & r8;
		*r9++= (long) r1;
	}

cont1:
	r5 & 0x100;                     /* check for bit reversal       */
	if(eq) pcgoto exit;             /* if no, go to exit            */

/* reverse bits in input byte                                           */
	r9 = r10;                       /* restore r9 = aout, latent    */

	r6 = r7 - 1;                    /* r6 = (#samples/2)-1, latent  */

	r8 = AddressPR(bitrevtab);     /* r8 = table base address      */

	/* at this point:       r5=mode, r6=count, r7=#samples/2        */
	/*                      r8=bitrevtab, r9=aout, r10=aout         */
	
	do r6
	{
		r1 = (byte)*r9++;       /* r10 = unreversed byte a      */
		r2 = (byte)*r9++;       /* r11 = unreversed byte b      */

		r1 += r8;               /* index into table for a       */
		r2 += r8;               /* index into table for b       */

		r1 = (byte)*r1          /* get reversed byte a          */
		r2 = (byte)*r2          /* get reversed byte b          */

		*r10++ = (byte)r1       /* store reversed byte a        */
		*r10++ = (byte)r2       /* store reversed byte b        */
	}
	
exit:
	SaveSection( aout)
	Pop(r18)
	return(r18)
	nop
	
bitrevtab:
byte 0x00;byte 0x80;byte 0x40;byte 0xc0;byte 0x20;byte 0xa0;byte 0x60;byte 0xe0
byte 0x10;byte 0x90;byte 0x50;byte 0xd0;byte 0x30;byte 0xb0;byte 0x70;byte 0xf0
byte 0x08;byte 0x88;byte 0x48;byte 0xc8;byte 0x28;byte 0xa8;byte 0x68;byte 0xe8
byte 0x18;byte 0x98;byte 0x58;byte 0xd8;byte 0x38;byte 0xb8;byte 0x78;byte 0xf8
byte 0x04;byte 0x84;byte 0x44;byte 0xc4;byte 0x24;byte 0xa4;byte 0x64;byte 0xe4
byte 0x14;byte 0x94;byte 0x54;byte 0xd4;byte 0x34;byte 0xb4;byte 0x74;byte 0xf4
byte 0x0c;byte 0x8c;byte 0x4c;byte 0xcc;byte 0x2c;byte 0xac;byte 0x6c;byte 0xec
byte 0x1c;byte 0x9c;byte 0x5c;byte 0xdc;byte 0x3c;byte 0xbc;byte 0x7c;byte 0xfc
byte 0x02;byte 0x82;byte 0x42;byte 0xc2;byte 0x22;byte 0xa2;byte 0x62;byte 0xe2
byte 0x12;byte 0x92;byte 0x52;byte 0xd2;byte 0x32;byte 0xb2;byte 0x72;byte 0xf2
byte 0x0a;byte 0x8a;byte 0x4a;byte 0xca;byte 0x2a;byte 0xaa;byte 0x6a;byte 0xea
byte 0x1a;byte 0x9a;byte 0x5a;byte 0xda;byte 0x3a;byte 0xba;byte 0x7a;byte 0xfa
byte 0x06;byte 0x86;byte 0x46;byte 0xc6;byte 0x26;byte 0xa6;byte 0x66;byte 0xe6
byte 0x16;byte 0x96;byte 0x56;byte 0xd6;byte 0x36;byte 0xb6;byte 0x76;byte 0xf6
byte 0x0e;byte 0x8e;byte 0x4e;byte 0xce;byte 0x2e;byte 0xae;byte 0x6e;byte 0xee
byte 0x1e;byte 0x9e;byte 0x5e;byte 0xde;byte 0x3e;byte 0xbe;byte 0x7e;byte 0xfe
byte 0x01;byte 0x81;byte 0x41;byte 0xc1;byte 0x21;byte 0xa1;byte 0x61;byte 0xe1
byte 0x11;byte 0x91;byte 0x51;byte 0xd1;byte 0x31;byte 0xb1;byte 0x71;byte 0xf1
byte 0x09;byte 0x89;byte 0x49;byte 0xc9;byte 0x29;byte 0xa9;byte 0x69;byte 0xe9
byte 0x19;byte 0x99;byte 0x59;byte 0xd9;byte 0x39;byte 0xb9;byte 0x79;byte 0xf9
byte 0x05;byte 0x85;byte 0x45;byte 0xc5;byte 0x25;byte 0xa5;byte 0x65;byte 0xe5
byte 0x15;byte 0x95;byte 0x55;byte 0xd5;byte 0x35;byte 0xb5;byte 0x75;byte 0xf5
byte 0x0d;byte 0x8d;byte 0x4d;byte 0xcd;byte 0x2d;byte 0xad;byte 0x6d;byte 0xed
byte 0x1d;byte 0x9d;byte 0x5d;byte 0xdd;byte 0x3d;byte 0xbd;byte 0x7d;byte 0xfd
byte 0x03;byte 0x83;byte 0x43;byte 0xc3;byte 0x23;byte 0xa3;byte 0x63;byte 0xe3
byte 0x13;byte 0x93;byte 0x53;byte 0xd3;byte 0x33;byte 0xb3;byte 0x73;byte 0xf3
byte 0x0b;byte 0x8b;byte 0x4b;byte 0xcb;byte 0x2b;byte 0xab;byte 0x6b;byte 0xeb
byte 0x1b;byte 0x9b;byte 0x5b;byte 0xdb;byte 0x3b;byte 0xbb;byte 0x7b;byte 0xfb
byte 0x07;byte 0x87;byte 0x47;byte 0xc7;byte 0x27;byte 0xa7;byte 0x67;byte 0xe7
byte 0x17;byte 0x97;byte 0x57;byte 0xd7;byte 0x37;byte 0xb7;byte 0x77;byte 0xf7
byte 0x0f;byte 0x8f;byte 0x4f;byte 0xcf;byte 0x2f;byte 0xaf;byte 0x6f;byte 0xef
byte 0x1f;byte 0x9f;byte 0x5f;byte 0xdf;byte 0x3f;byte 0xbf;byte 0x7f;byte 0xff

