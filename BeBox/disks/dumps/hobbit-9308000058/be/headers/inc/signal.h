/*
 *   signal.h -- ANSI 
 *
 *   Functions and macros for handling signals.
 *
 *           Copyright (c) 1990, MetaWare Incorporated
 */

#ifndef _SIGNAL_H
#define _SIGNAL_H	

#ifdef __CPLUSPLUS__
extern "C" {
#endif

#ifdef __PENPOINT__
    #define SIG_IGN         (void (*)(int))1
    #define SIG_DFL         (void (*)(int))2
    #define SIG_ERR         (void (*)(int))3
#else
    #define SIG_ERR         (void (*)(int))-1
    #define SIG_DFL         (void (*)(int))0
    #define SIG_IGN         (void (*)(int))1
#endif

#ifdef _MSDOS
# define SIG_ACK	(void (*)(int))-2
#endif

typedef int	sig_atomic_t;

#if !defined(_NSIG)
#   if defined(NSIG)
#       define _NSIG NSIG
#   else
#       if _ATT
#           define _NSIG 28
#       else
#           define _NSIG 32
#	    if defined(_ATT4)
#           	define NSIG _NSIG
#	    endif
#       endif
#   endif
#endif

#ifdef __PENPOINT__
    #define SIGABRT	1
    #define SIGFPE	2

    /* Not currently generated by PenPoint */
    #define SIGILL	3
    #define SIGSEGV	4
    #define SIGTERM	5
    #define SIGINT	6

    #define _SIGMAX	6
    #define _SIGMIN     1

#else	/* ! __PENPOINT__ */

    #define SIGHUP	1	/* hangup */
    #define SIGINT	2	/* interrupt */
    #define SIGQUIT	3	/* quit */
    #if _MSDOS || _MSNT || _OS2
	#define SIGBREAK SIGQUIT	/* Microsoft compatibility */
    #endif

    #define SIGILL	4	/* illegal instruction (not reset when caught) */
    #define ILL_RESAD_FAULT	0x0	/* reserved addressing fault */
    #define ILL_PRIVIN_FAULT	0x1	/* privileged instruction fault */
    #define ILL_RESOP_FAULT	0x2	/* reserved operand fault */
    #if _MSDOS || _MSNT || _OS2
	#define    ILL_EXPLICITGEN	0xf	/* generated by 'raise' */
    #endif

    /* CHME, CHMS, CHMU are not yet given back to users reasonably */
    #define SIGTRAP	5	/* trace trap (not reset when caught) */
    #define SIGIOT	6	/* IOT instruction */
    #define SIGABRT	SIGIOT	/* compatibility */
    #define SIGEMT	7	/* EMT instruction */
    #define SIGFPE	8	/* floating point exception */
    #if _MSDOS || _MSNT || _OS2
	#define _FPE_INVALID             0x81
	#define _FPE_DENORMAL            0x82
	#define _FPE_ZERODIVIDE          0x83
	#define _FPE_OVERFLOW            0x84
	#define _FPE_UNDERFLOW           0x85
	#define _FPE_INEXACT             0x86

	#define _FPE_STACKOVERFLOW       0x8a
	#define _FPE_STACKUNDERFLOW      0x8b

	#define _FPE_EXPLICITGEN         0x8c	/* generated by 'raise' */
	#define _FPE_INTDIV0             0x91	/* integer divide error */
	#define _FPE_INT_OFLOW           0x92	/* integer overflow */
	#define _FPE_INTOVFLOW           0x92	/* integer overflow */
	#define _FPE_BOUND               0x93	/* bounds check */
    #endif
    #define SIGKILL	9	/* kill (cannot be caught or ignored) */
    #define SIGBUS	10	/* bus error */
    #define SIGSEGV	11	/* segmentation violation */
    #define SIGSYS	12	/* bad argument to system call */
    #define SIGPIPE	13	/* write on a pipe with no one to read it */
    #define SIGALRM	14	/* alarm clock */
    #define SIGTERM	15	/* software termination signal from kill */
#endif	/* __PENPOINT__ */

#if _ATT
    #define SIGUSR1	16 /* user defined signal 1 */
    #define SIGUSR2	17 /* user defined signal 2 */
    #define SIGCHLD	18 /* death of a child */
    #define SIGCLD	18 /* death of a child (older spelling of SIGCHLD) */
    #define SIGPWR	19 /* power-fail restart */
    #define SIGWINCH	20 /* window change */

    /* SIGPHONE only used in UNIX/PC */
    /*#define SIGPHONE 21*/	/* handset, line status change */

    #define SIGPOLL	22 /* pollable event occured */

    /* Job control signals (other than SIGCHLD, defined above) */
    #define SIGCONT	23 /* continue if stopped */
    #define SIGSTOP	24 /* stop signal (cannot be caught or ignored) */
    #define SIGTSTP	25 /* interactive stop signal */
    #define SIGTTIN	26 /* background read attempted */
    #define SIGTTOU	27 /* background write attempted */

    #define MAXSIG	32 /* size of u_signal[], NSIG-1 <= MAXSIG*/
			   /* MAXSIG is larger than we need now. */
			   /* In the future, we can add more signal */
			   /* number without changing user.h */

#elif _ATT4 || _SOL
    #define SIGUSR1	16 /* user defined signal 1 */
    #define SIGUSR2	17 /* user defined signal 2 */
    #define SIGCLD	18 /* child status change */
    #define SIGCHLD	18 /* child status change alias (POSIX) */
    #define SIGPWR	19 /* power-fail restart */
    #define SIGWINCH	20 /* window size change */
    #define SIGURG	21 /* urgent socket condition */
    #define SIGPOLL	22 /* pollable event occured */
    #define SIGIO	22 /* socket I/O possible (SIGPOLL alias) */
    #define SIGSTOP	23 /* stop (cannot be caught or ignored) */
    #define SIGTSTP	24 /* user stop requested from tty */
    #define SIGCONT	25 /* stopped process has been continued */
    #define SIGTTIN	26 /* background tty read attempted */
    #define SIGTTOU	27 /* background tty write attempted */
    #define SIGVTALRM	28 /* virtual timer expired */
    #define SIGPROF	29 /* profiling timer expired */
    #define SIGXCPU	30 /* exceeded cpu limit */
    #define SIGXFSZ	31 /* exceeded file size limit */
    #define SIGWAITING  32 /* process's lwps are blocked */
    #define SIGLWP      33 /* special signal used by thread library */
#elif _UPA
    #define SIGUSR1	16 /* user defined signal 1 */
    #define SIGUSR2	17 /* user defined signal 2 */
    #define SIGCLD	18 /* child status change */
    #define SIGCHLD	18 /* child status change alias (POSIX) */
    #define SIGPWR	19 /* power-fail restart */
    #define SIGVTALRM	20 /* virtual timer alarm */
    #define SIGPROF	21 /* profiling timer alarm */
    #define SIGPOLL	22 /* pollable event occured */
    #define SIGIO	22 /* socket I/O possible (SIGPOLL alias) */
    #define SIGWINCH	23 /* window size change */
    #define SIGSTOP	24 /* stop (cannot be caught or ignored) */
    #define SIGTSTP	25 /* user stop requested from tty */
    #define SIGCONT	26 /* stopped process has been continued */
    #define SIGTTIN	27 /* background tty read attempted */
    #define SIGTTOU	28 /* background tty write attempted */
    #define SIGURG	29 /* urgent condition on IO channel */
    #define SIGLOST	30 /* remote lock lost (NFS) */
    #define SIGRESERVE	31 /* Save for future use */
    #define SIGDIL	32 /* DIL signal */
#else
    #define SIGURG	16 /* urgent condition on IO channel */
    #define SIGSTOP	17 /* sendable stop signal not from tty */
    #define SIGTSTP	18 /* stop signal from tty */
    #define SIGCONT	19 /* continue a stopped process */
    #define SIGCHLD	20 /* to parent on child stop or exit */
    #define SIGCLD	SIGCHLD	/* compatibility */
    #define SIGTTIN	21 /* to readers pgrp upon background tty read */
    #define SIGTTOU	22 /* like TTIN for output if (tp->t_local&LTOSTOP) */
    #define SIGIO	23 /* input/output possible signal */
    #define SIGXCPU	24 /* exceeded CPU time limit */
    #define SIGXFSZ	25 /* exceeded file size limit */
    #define SIGVTALRM	26 /* virtual time alarm */
    #define SIGPROF	27 /* profiling time alarm */
    #define SIGWINCH	28 /* window size changes */
    #define SIGUSR1	30 /* user defined signal 1 */
    #define SIGUSR2	31 /* user defined signal 2 */
#endif

#ifdef _MSDOS
    #define SIGUSR3 32	/* user defined signal 3, MS compatibility */
#endif

extern  void            (*signal(int __n, void (*__f)(int)))(int);
extern  int             raise(int __n);

#if _MSDOS || _MSNT || _OS2
    extern int _kill(int __pid, int __sig);
    #include <_na.h>
    #if _NA_NAMES
        _NA(kill)
    #elif _MSDOS && __HIGHC__
	extern int kill(int __pid, int __sig);
    #endif
#endif

#ifdef __CPLUSPLUS__
}
#endif
#endif /*_SIGNAL_H*/
