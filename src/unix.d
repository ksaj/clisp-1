/*
 * The include file for the UNIX version of CLISP
 * Bruno Haible 1990-2002
 * Sam Steingold 1998-2002
 */

/* control character constants: */
#define BEL  7              /* ring the bell */
/* #define NL  10              new line, see <lispbibl.d> */
#define RUBOUT 127          /* Rubout = Delete */
#define CRLFstring  "\n"    /* C string containing Newline */

#define stdin_handle   0  /* the file handle for the standard input */
#define stdout_handle  1  /* the file handle for the standard output */

/* Declaration of types of I/O parameters of operating system functions */
#ifdef STDC_HEADERS
  #include <stdlib.h>
#endif
#include <sys/types.h>  /* declares pid_t, uid_t */
#ifdef HAVE_UNISTD_H
  #include <unistd.h>
#endif

/* the table of the system error messages */
#include <errno.h>
extern int errno; /* last error code */
/* NB: errno may be a macro which expands to a function call.
   Therefore access and assignment to errno must be wrapped in
   begin_system_call()/end_system_call() */
#define OS_errno errno
#define OS_set_errno(e) (errno=(e))
#ifdef HAVE_STRERROR
#include <string.h>
extern_C char* strerror (int errnum);
#else
/* Number of operating system error messages */
extern int sys_nerr;
/* Operating system error messages */
extern SYS_ERRLIST_CONST char* SYS_ERRLIST_CONST sys_errlist[];
#endif
/* perror(3)
   On UnixWare 7.0.1 some errno value is defined to an invalid negative value,
   causing an out-of-bounds array access in errunix.d. */
#if (EDQUOT < 0)
  #undef EDQUOT
#endif
/* used by ERROR, SPVW, STREAM, PATHNAME */

/* Make the main memory available */
#ifdef HAVE_GETPAGESIZE
  extern_C RETGETPAGESIZETYPE getpagesize (void); /* getpagesize(2) */
#endif
#ifndef malloc
  extern_C RETMALLOCTYPE malloc (MALLOC_SIZE_T size); /* malloc(3V) */
#endif
#ifndef free
  extern_C RETFREETYPE free (RETMALLOCTYPE ptr); /* malloc(3V) */
#endif
#ifndef realloc
  extern_C RETMALLOCTYPE realloc (RETMALLOCTYPE ptr, MALLOC_SIZE_T size); /* REALLOC(3) */
#endif
#ifdef UNIX_NEXTSTEP
  /* ignore the contents of libposix.a, since it is not documented */
  #undef HAVE_MMAP
  #undef HAVE_MUNMAP
  #undef MMAP_ADDR_T
  #undef MMAP_SIZE_T
  #undef RETMMAPTYPE
#endif
#ifdef UNIX_RHAPSODY
/* Ignore mmap and friends, because the configure test says no working mmap. */
  #undef HAVE_MMAP
  #undef HAVE_MUNMAP
  #undef MMAP_ADDR_T
  #undef MMAP_SIZE_T
  #undef RETMMAPTYPE
  #undef HAVE_WORKING_MPROTECT
#endif
#if defined(HAVE_MMAP) || defined(HAVE_MMAP_ANON) || defined(HAVE_MMAP_ANONYMOUS) || defined(HAVE_MMAP_DEVZERO) || defined(HAVE_MMAP_DEVZERO_SUN4_29)
  #include <sys/mman.h>
  #ifdef UNIX_CONVEX
    #define mmap fixed_mmap  /* mmap() is broken under UNIX_CONVEX */
    #define HAVE_WORKING_MPROTECT  /* our mprotect() in unixaux.d is sufficient */
  #endif
  #if defined(HAVE_MMAP_ANONYMOUS) && !defined(HAVE_MMAP_ANON)
    /* HP-UX uses MAP_ANONYMOUS instead of MAP_ANON. */
    #define MAP_ANON MAP_ANONYMOUS
    #define HAVE_MMAP_ANON
  #endif
  #if defined(UNIX_SUNOS4) || defined(UNIX_SUNOS5)
    /* for SINGLEMAP_MEMORY: */
    #if defined(HAVE_MMAP_DEVZERO_SUN4_29) && defined(SUN4_29) && !defined(HAVE_MMAP_DEVZERO)
      /* On the assumption of the SUN4_29-type code distribution
         HAVE_MMAP_DEVZERO_SUN4_29 is a sufficient replacement
         for HAVE_MMAP_DEVZERO. */
      #define HAVE_MMAP_DEVZERO
    #endif
  #endif
  #ifdef UNIX_SUNOS5
   /* NB: Under UNIX_SUNOS5, HAVE_MMAP_DEVZERO should be defined.
      There is however a limit of 25 MB mmap() memory.
      Since the shared memory facility of UNIX_SUNOS5 denies
      memory at addresses >= 0x06000000 or more than 6 times to attach,
      we must use SINGLEMAP_MEMORY */
  #endif
  #ifdef HAVE_MSYNC
    #ifdef MS_INVALIDATE
      /* tested only on UNIX_LINUX, not UNIX_SUNOS4, not UNIX_SUNOS5,
         not UNIX_FREEBSD. ?? */
      /* for MULTIMAP_MEMORY_VIA_FILE: */
      extern_C int msync (MMAP_ADDR_T addr, MMAP_SIZE_T len, int flags);
    #else
      /* NetBSD has a 2-argument msync(), unusable for our purposes. */
      #undef HAVE_MSYNC
    #endif
  #endif
#endif
#ifdef HAVE_MACH_VM /* vm_allocate(), task_self(), ... available */
  /* the headers for UNIX_NEXTSTEP must look indescribable ... */
  #include <sys/time.h> /* needed for <sys/resource.h> on UNIX_RHAPSODY */
  #include <sys/resource.h>
  #undef local
  #include <mach/mach_interface.h>
  #if defined(UNIX_NEXTSTEP) || defined(UNIX_RHAPSODY)
    #include <mach/mach_init.h>
  #endif
  #ifdef UNIX_OSF
    #include <mach_init.h>
  #endif
  /* #include <mach/mach.h> */
  #include <mach/mach_traps.h> /* for map_fd() */
  #include <mach/machine/vm_param.h>
  #define local static
  /* thus one can use mmap(), munmap() und mprotect(). see spvw.d. */
  #define HAVE_MMAP
  #define HAVE_MUNMAP
  #define HAVE_WORKING_MPROTECT
  #define MMAP_ADDR_T  vm_address_t
  #define MMAP_SIZE_T  vm_size_t
  #define RETMMAPTYPE  MMAP_ADDR_T
  #define MPROTECT_CONST
  #define PROT_NONE  0
  #define PROT_READ  VM_PROT_READ
  #define PROT_WRITE VM_PROT_WRITE
  #define PROT_EXEC  VM_PROT_EXECUTE
#endif
#ifdef HAVE_MMAP
  extern_C RETMMAPTYPE mmap (MMAP_ADDR_T addr, MMAP_SIZE_T len, int prot, int flags, int fd, off_t off); /* MMAP(2) */
#endif
#ifdef HAVE_MUNMAP
  extern_C int munmap (MMAP_ADDR_T addr, MMAP_SIZE_T len); /* MUNMAP(2) */
#endif
#ifdef HAVE_WORKING_MPROTECT
  extern_C int mprotect (MPROTECT_CONST MMAP_ADDR_T addr, MMAP_SIZE_T len, int prot); /* MPROTECT(2) */
#endif
/* Possible values of prot: PROT_NONE, PROT_READ, PROT_READ_WRITE. */
#ifndef PROT_NONE
  #define PROT_NONE  0
#endif
#define PROT_READ_WRITE  (PROT_READ | PROT_WRITE)
#ifdef HAVE_SHM
  #include <sys/ipc.h>
  #include <sys/shm.h>
  #ifdef HAVE_SYS_SYSMACROS_H
    #include <sys/sysmacros.h>
  #endif
  #ifdef UNIX_HPUX
    #include <sys/vmmac.h> /* for SHMLBA */
  #endif
  #ifdef UNIX_AUX
    #include <sys/mmu.h> /* for SHMLBA */
  #endif
  #ifdef UNIX_LINUX
    #include <asm/page.h> /* for SHMLBA on Linux 2.0 */
  #endif
  #if defined(UNIX_SUNOS4) || defined(UNIX_SUNOS5)
    #define SHMMAX  0x100000 /* maximum shared memory segment size = 1 MB */
  #endif
  #ifndef SHMMAX
    #define SHMMAX  0xFFFFFFFFUL /* maximum shared memory segment size accepted to mean infinite */
  #endif
  extern_C int shmget (key_t key, SHMGET_SIZE_T size, int shmflg); /* SHMGET(2) */
  extern_C RETSHMATTYPE shmat (int shmid, SHMAT_CONST RETSHMATTYPE shmaddr, int shmflg); /* SHMOP(2) */
  extern_C int shmdt (SHMDT_ADDR_T shmaddr); /* SHMOP(2) */
  #ifdef SHMCTL_DOTS
    extern_C int shmctl (int shmid, int cmd, ...); /* SHMCTL(2) */
  #else
    extern_C int shmctl (int shmid, int cmd, struct shmid_ds * buf); /* SHMCTL(2) */
  #endif
#endif
/* used by SPVW, STREAM */

/* paging control */
#ifdef HAVE_VADVISE
  #include <sys/vadvise.h> /* control codes */
  extern_C void vadvise (int param); /* paging system control, see VADVISE(2) */
#endif
/* use madvise() ?? */
/* used by SPVW */

/* make stack large enough */
#ifdef UNIX_NEXTSTEP
  #include <sys/time.h>
  #include <sys/resource.h>
  extern_C int getrlimit (RLIMIT_RESOURCE_T resource, struct rlimit * rlim); /* GETRLIMIT(2) */
  extern_C int setrlimit (RLIMIT_RESOURCE_T resource, SETRLIMIT_CONST struct rlimit * rlim); /* SETRLIMIT(2) */
#endif
/* used by SPVW */

/* normal program end */
nonreturning_function(extern_C, _exit, (int status)); /* EXIT(2V) */
nonreturning_function(extern_C, exit, (int status)); /* EXIT(2V) */
/* used by SPVW, PATHNAME, STREAM */

/* Immediate abnormal termination, jump into the debugger */
extern_C ABORT_VOLATILE RETABORTTYPE abort (void); /* ABORT(3) */
/* used by SPVW, DEBUG, EVAL, IO */

/* signal handling */
#include <signal.h>
/* a signal handler is a non-returning function. */
#ifdef __cplusplus
  #ifdef SIGTYPE_DOTS
    typedef RETSIGTYPE (*signal_handler_t) (...);
  #else
    typedef RETSIGTYPE (*signal_handler_t) (int);
  #endif
#else
  typedef RETSIGTYPE (*signal_handler_t) ();
#endif
/* install a signal cleanly: */
extern_C signal_handler_t signal (int sig, signal_handler_t handler); /* SIGNAL(3V) */
#if defined(SIGNAL_NEED_UNBLOCK_OTHERS) && defined(HAVE_SIGACTION)
/* On some BSD systems (e.g. SunOS 4.1.3_U1), the call of a signal handler
   is different when the current signal is blocked.
   We therefore use sigaction() instead of signal(). */
  #define USE_SIGACTION
#endif
extern signal_handler_t install_signal_handler (int sig, signal_handler_t handler);
#define SIGNAL(sig,handler)  install_signal_handler(sig,handler)
/* a signal block and release: */
#if defined(SIGNALBLOCK_POSIX)
  extern_C int sigprocmask (int how, SIGPROCMASK_CONST sigset_t* set, sigset_t* oset); /* SIGPROCMASK(2V) */
  #ifndef sigemptyset /* UNIX_LINUX sometimes defines this as a macro */
    extern_C int sigemptyset (sigset_t* set); /* SIGSETOPS(3V) */
  #endif
  #ifndef sigaddset /* UNIX_LINUX sometimes defines this as a macro */
    extern_C int sigaddset (sigset_t* set, int signo); /* SIGSETOPS(3V) */
  #endif
  #define signalblock_on(sig)  \
      { var sigset_t sigblock_mask;                                 \
        sigemptyset(&sigblock_mask); sigaddset(&sigblock_mask,sig); \
        sigprocmask(SIG_BLOCK,&sigblock_mask,NULL);
  #define signalblock_off(sig)  \
        sigprocmask(SIG_UNBLOCK,&sigblock_mask,NULL); \
      }
#elif defined(SIGNALBLOCK_SYSV)
  extern_C int sighold (int sig);
  extern_C int sigrelse (int sig);
  #define signalblock_on(sig)  sighold(sig);
  #define signalblock_off(sig)  sigrelse(sig);
#elif defined(SIGNALBLOCK_BSD)
  extern_C int sigblock (int mask); /* SIGBLOCK(2) */
  extern_C int sigsetmask (int mask); /* SIGSETMASK(2) */
  #define signalblock_on(sig)  \
      { var int old_sigblock_mask = sigblock(sigmask(sig));
  #define signalblock_off(sig)  \
        sigsetmask(old_sigblock_mask); \
      }
#else
  #error "How does one block a signal?"
#endif
/* deliver a signal some time later: */
/* extern_C {unsigned|} int alarm ({unsigned|} int seconds); / * ALARM(3V) */
#if !defined(HAVE_UALARM) && defined(HAVE_SETITIMER)
  #define NEED_OWN_UALARM /* ualarm() can be implemented with setitimer() */
  #include <sys/time.h>
  extern_C int setitimer (int which, SETITIMER_CONST struct itimerval * ivalue, struct itimerval * ovalue); /* SETITIMER(2) */
  #define HAVE_UALARM
#endif
#ifdef HAVE_UALARM
  #ifdef UNIX_CYGWIN32
    /* <sys/types.h>: typedef long useconds_t; */
    extern_C useconds_t ualarm (useconds_t value, useconds_t interval);
  #else
    extern_C unsigned int ualarm (unsigned int value, unsigned int interval);
  #endif
#endif
/* acknowledge the arrival of a signal (from the signal handler): */
#ifdef USE_SIGACTION
  #ifdef SIGACTION_NEED_REINSTALL
    /* restore the handler */
    #define signal_acknowledge(sig,handler) install_signal_handler(sig,handler)
  #else /* BSD-stype signals do not need this */
    #define signal_acknowledge(sig,handler)
  #endif
#else
  #ifdef SIGNAL_NEED_REINSTALL /* UNIX_SYSV || UNIX_LINUX || ... */
    /* restore the handler */
    #define signal_acknowledge(sig,handler) install_signal_handler(sig,handler)
  #else  /* BSD-stype signals do not need this */
    #define signal_acknowledge(sig,handler)
  #endif
#endif
/* the signal one gets on termination of the child process: SIGCLD */
#if defined(SIGCHLD) && !defined(SIGCLD)
  #define SIGCLD  SIGCHLD
#endif
/* the behavior of the signals the affect system calls:
   flag=0: after the signal SIG the system call keep running.
   flag=1: after the signal SIG the system call is aborted, errno=EINTR. */
#ifdef EINTR
  extern_C int siginterrupt (int sig, int flag); /* SIGINTERRUPT(3V) */
  #ifndef HAVE_SIGINTERRUPT
    /* siginterrupt() can be implemented with sigaction() or sigvec() */
    #define NEED_OWN_SIGINTERRUPT
  #endif
#else
  #define siginterrupt(sig,flag)
#endif
/* For recovery from the SIGSEGV signal (write attempts to write
   protected ranges). See libsigsegv.
   Watch out: Hans-J. Boehm <boehm@parc.xerox.com> says that write accesses
   originating from OS calls (e.g. read()) do not trigger a signal on many
   systems, unexpectedly. (It works on Linux, though) */
#ifndef SPVW_MIXED_BLOCKS
/* We are lucky to write with read() only into the C-stack and into strings
   and not into possibly mprotect-protected ranges. */
#endif
/* raise a signal. */
#ifdef HAVE_RAISE
extern_C int raise (int sig);
#endif
/* used by SPVW */

/* check environment variables: */
extern_C char* getenv (GETENV_CONST char* name); /* GETENV(3V) */
/* used by PATHNAME, SPVW, MISC */

/* set environment variables: */
#if defined(HAVE_PUTENV)
  extern_C int putenv (PUTENV_CONST char* name); /* PUTENV(3) */
#elif defined(HAVE_SETENV)
  extern_C int setenv (GETENV_CONST char* name, GETENV_CONST char* value, int overwrite); /* SETENV(3) */
#endif
/* used by SPVW */

/* Adjustment to locale preferences: */
#include <locale.h>
extern_C char* setlocale (int category, SETLOCALE_CONST char* locale);
/* used by SPVW */

/* get user home directory: */
#include <pwd.h>
extern_C struct passwd * getpwnam (GETPWNAM_CONST char* name); /* GETPWENT(3V) */
extern_C struct passwd * getpwuid (GETPWUID_UID_T uid); /* GETPWENT(3V) */
extern_C uid_t getuid (void); /* GETUID(2V) */
extern uid_t user_uid; /* Real User ID of the current process */
extern_C char* getlogin (void); /* GETLOGIN(3V) */
/* used by PATHNAME, SPVW */

/* set working directory: */
extern_C int chdir (CHDIR_CONST char* path); /* CHDIR(2V) */
/* used by PATHNAME */

/* get working directory: */
#include <sys/param.h>
/* maximum path length (incl. terminating NULL), returned by getwd(): */
#ifndef MAXPATHLEN
  #define MAXPATHLEN  1024  /* <sys/param.h> */
#endif
#ifdef HAVE_GETCWD
extern_C char* getcwd (char* buf, GETCWD_SIZE_T bufsize);
#define getwd(buf)  getcwd(buf,MAXPATHLEN)
#else
extern_C char* getwd (char* pathname); /* GETWD(3) */
#endif
/* used by PATHNAME */

/* maximum number of symbolic links which are successively resolved: */
#ifndef MAXSYMLINKS
  #define MAXSYMLINKS  8  /* <sys/param.h> */
#endif
/* used by PATHNAME */

/* resolve symbolic links in pathname: */
#ifdef HAVE_READLINK
extern_C RETREADLINKTYPE readlink (READLINK_CONST char* path, READLINK_BUF_T buf, READLINK_SIZE_T bufsiz); /* READLINK(2) */
#endif
/* used by PATHNAME */

/* get information about a file: */
#include <sys/stat.h>
#ifdef STAT_MACROS_BROKEN
  #undef S_ISDIR
  #undef S_ISLNK
  #undef S_ISREG
#endif
#ifdef STAT_INLINE
extern int stat (STAT_CONST char* path, struct stat * buf); /* STAT(2V) */
#else
extern_C int stat (STAT_CONST char* path, struct stat * buf); /* STAT(2V) */
#endif
#ifdef HAVE_LSTAT
  #ifdef LSTAT_INLINE
extern int lstat (LSTAT_CONST char* path, struct stat * buf); /* STAT(2V) */
  #else
extern_C int lstat (LSTAT_CONST char* path, struct stat * buf); /* STAT(2V) */
  #endif
#else
  #define lstat stat
  #define S_ISLNK(m)  false
#endif
#ifdef FSTAT_INLINE
extern int fstat (int fd, struct stat * buf); /* STAT(2V) */
#else
extern_C int fstat (int fd, struct stat * buf); /* STAT(2V) */
#endif
#ifndef S_ISDIR
  #define S_ISDIR(m)  (((m)&S_IFMT) == S_IFDIR)
#endif
#ifndef S_ISLNK
  #define S_ISLNK(m)  (((m)&S_IFMT) == S_IFLNK)
#endif
#ifndef S_ISREG
  #define S_ISREG(m)  (((m)&S_IFMT) == S_IFREG)
#endif
/* used by PATHNAME, STREAM, SPVW */

/* remove file: */
  extern_C int unlink (UNLINK_CONST char* path); /* UNLINK(2V) */
/* used by PATHNAME, UNIXAUX */

/* rename file: */
  extern_C int rename (RENAME_CONST char* oldpath, RENAME_CONST char* newpath); /* RENAME(2V) */
/* used by PATHNAME, UNIXAUX */

/* directory search: */
#if defined(DIRENT) || defined(_POSIX_VERSION)
  #include <dirent.h>
  #define SDIRENT  struct dirent
#else
  #ifdef SYSNDIR
    #include <sys/ndir.h>
  #else
    #ifdef SYSDIR
      #include <sys/dir.h>
    #else
      #ifdef NDIR
        #include <ndir.h>
      #else
        #include <dir.h>
      #endif
    #endif
  #endif
  #define SDIRENT  struct direct
#endif
extern_C DIR* opendir (OPENDIR_CONST char* dirname); /* DIRECTORY(3V) */
extern_C SDIRENT* readdir (DIR* dirp); /* DIRECTORY(3V) */
extern_C RETCLOSEDIRTYPE closedir (DIR* dirp); /* DIRECTORY(3V) */
#ifdef VOID_CLOSEDIR
  #define CLOSEDIR(dirp)  (closedir(dirp),0)
#else
  #define CLOSEDIR  closedir
#endif
/* used by PATHNAME */

/* create directory: */
extern_C int mkdir (MKDIR_CONST char* path, mode_t mode); /* MKDIR(2V) */
/* used by PATHNAME */

/* remove directory: */
extern_C int rmdir (RMDIR_CONST char* path); /* RMDIR(2V) */
/* used by PATHNAME */

/* work with open files: */
#include <fcntl.h>
#if defined(ACCESS_NEEDS_SYS_FILE_H) || defined(OPEN_NEEDS_SYS_FILE_H)
  #include <sys/file.h>
#endif
#ifdef OPEN_DOTS
extern_C int open (OPEN_CONST char* path, int flags, ...); /* OPEN(2V) */
#else
extern_C int open (OPEN_CONST char* path, int flags, mode_t mode); /* OPEN(2V) */
#endif
/* Only a few Unices (like UNIX_CYGWIN32) have O_TEXT and O_BINARY.
   BeOS 5 has them, but they have no effect. */
#ifdef UNIX_BEOS
  #undef O_BINARY
#endif
#ifndef O_BINARY
  #define O_BINARY  0
#endif
#define my_open_mask  0644
#define Handle  uintW  /* the type of a file deskriptor */
extern_C off_t lseek (int fd, off_t offset, int whence); /* LSEEK(2V) */
#ifndef SEEK_SET /* e.g., UNIX_NEXTSTEP */
  /* position modes, see <unistd.h> : */
  #define SEEK_SET  0
  #define SEEK_CUR  1
  #define SEEK_END  2
#endif
extern_C RETRWTYPE read (int fd, RW_BUF_T buf, RW_SIZE_T nbyte); /* READ(2V) */
extern_C RETRWTYPE write (int fd, WRITE_CONST RW_BUF_T buf, RW_SIZE_T nbyte); /* WRITE(2V) */
extern_C int close (int fd); /* CLOSE(2V) */
#ifdef HAVE_FSYNC
extern_C int fsync (int fd); /* FSYNC(2) */
#endif
#if !defined(HAVE_SELECT) && defined(HAVE_POLL)
  #define NEED_OWN_SELECT /* select() can be implemented with poll()  */
  #include <poll.h>
  extern_C int poll (struct pollfd * fds, unsigned long nfds, int timeout);
  #ifndef _EMUL_SYS_TIME_H
    #define _EMUL_SYS_TIME_H
    struct timeval { long tv_sec; long tv_usec; };
    struct timezone { int tz_minuteswest; int tz_dsttime; };
  #endif
  #define SELECT_WIDTH_T int
  #define SELECT_SET_T fd_set
  #define SELECT_CONST
  #define HAVE_SELECT /* see unixaux.d */
#endif
#ifdef HAVE_SELECT
  #ifdef UNIX_BEOS
    #include <sys/socket.h>
  #endif
  #ifndef _EMUL_SYS_TIME_H
    #include <sys/time.h>
  #endif
  #ifdef HAVE_SYS_SELECT_H
    #include <sys/select.h>
  #endif
  #ifndef FD_SETSIZE
    /* definition of types fd_set, err <sys/types.h> : */
    #ifdef UNIX_HPUX /* fd_set is defined, but FD_SETSIZE is not */
      #define fd_set  my_fd_set
    #endif
    #define FD_SETSIZE 256 /* maximum number of file descriptors */
    typedef int fd_mask; /* a bit group */
    #define NFDBITS (sizeof(fd_mask) * 8) /* number of bits in a bit group */
    typedef struct fd_set { fd_mask fds_bits[ceiling(FD_SETSIZE,NFDBITS)]; }
            fd_set;
    #define FD_SET(n,p)  ((p)->fds_bits[(n)/NFDBITS] |= bit((n)%NFDBITS))
    #define FD_CLR(n,p)  ((p)->fds_bits[(n)/NFDBITS] &= ~bit((n)%NFDBITS))
    #define FD_ISSET(n,p)  ((p)->fds_bits[(n)/NFDBITS] & bit((n)%NFDBITS))
    #define FD_ZERO(p)  bzero((char*)(p),sizeof(*(p)))
    #include <string.h>
    #ifndef memset
      extern_C RETMEMSETTYPE memset (void* ptr, int c, size_t len); /* MEMORY(3) */
    #endif
    #define bzero(ptr,len)  memset(ptr,0,len)
  #endif
  extern_C int select (SELECT_WIDTH_T width, SELECT_SET_T* readfds,
                       SELECT_SET_T* writefds, SELECT_SET_T* exceptfds,
                       SELECT_CONST struct timeval * timeout); /* SELECT(2) */
#endif
#ifdef EINTR
/* wrapper around the system call, which intercepts and handles EINTR: */
extern int nonintr_open (OPEN_CONST char* path, int flags, mode_t mode);
extern int nonintr_close (int fd);
#define OPEN nonintr_open
#define CLOSE nonintr_close
#else
#define OPEN open
#define CLOSE close
#endif
/* wrapper around the system call, get partial results and handle EINTR: */
extern RETRWTYPE read_helper (int fd, RW_BUF_T buf, RW_SIZE_T nbyte, bool partial_p);
#define safe_read(f,b,n)  read_helper(f,b,n,true)
#define full_read(f,b,n)  read_helper(f,b,n,false)
extern RETRWTYPE full_write (int fd, WRITE_CONST RW_BUF_T buf, RW_SIZE_T nbyte);
/* used by STREAM, PATHNAME, SPVW, MISC, UNIXAUX */

/* inquire the terminal, window size: */
extern_C int isatty (int fd); /* TTYNAME(3V) */
#if defined(HAVE_TERMIOS_H) && defined(HAVE_TCGETATTR) && defined(HAVE_TCSAFLUSH)
  #define UNIX_TERM_TERMIOS
  #include <termios.h> /* TERMIOS(3V) */
  #ifndef tcgetattr
    extern_C int tcgetattr (int fd, struct termios * tp);
  #endif
  #ifndef tcsetattr
    extern_C int tcsetattr (int fd, int optional_actions, TCSETATTR_CONST struct termios * tp);
  #endif
  #ifndef tcdrain
    extern_C int tcdrain (int fd); /* TERMIOS(3V) */
  #endif
  #ifndef tcflush
    extern_C int tcflush (int fd, int flag); /* TERMIOS(3V) */
  #endif
  #undef TCSETATTR  /* eg. HP-UX 10 */
  #define TCSETATTR tcsetattr
  #define TCDRAIN tcdrain
  #define TCFLUSH tcflush
  #ifndef NCCS
    #define NCCS  sizeof(((struct termios *)0)->c_cc)
  #endif
  #if defined(WINSIZE_NEED_SYS_IOCTL_H) /* glibc2 needs this for "struct winsize" */
    #include <sys/ioctl.h>
  #elif defined(WINSIZE_NEED_SYS_PTEM_H) /* SCO needs this for "struct winsize" */
    #include <sys/stream.h>
    #include <sys/ptem.h>
  #endif
#elif defined(HAVE_SYS_TERMIO_H) || defined(HAVE_TERMIO_H)
  #define UNIX_TERM_TERMIO
  #if defined(HAVE_SYS_TERMIO_H)
    #include <sys/termio.h> /* TERMIO(4) */
  #elif defined(HAVE_TERMIO_H)
    #include <termio.h>
  #endif
  #ifndef NCCS
    #define NCCS  sizeof(((struct termio *)0)->c_cc)
  #endif
#elif defined(HAVE_SGTTY_H)
  /* compatibel to V7 or 4BSD, TIOC form ioctls.... */
  #define UNIX_TERM_SGTTY
  #include <sgtty.h>
  #include <sys/ioctl.h> /* TTY(4) */
#endif
#if defined(NEED_SYS_FILIO_H)
  #include <sys/filio.h>
#elif defined(NEED_SYS_IOCTL_H)
  #include <sys/ioctl.h>
#endif
#ifdef IOCTL_DOTS
  extern_C int ioctl (int fd, IOCTL_REQUEST_T request, ...); /* IOCTL(2) */
  #define IOCTL_ARGUMENT_T  CADDR_T
#else
  extern_C int ioctl (int fd, IOCTL_REQUEST_T request, IOCTL_ARGUMENT_T arg); /* IOCTL(2) */
  /* 3rd argument is always cast to type IOCTL_ARGUMENT_T (usually CADDR_T): */
  #define ioctl(fd,request,arg)  (ioctl)(fd,request,(IOCTL_ARGUMENT_T)(arg))
#endif
#ifndef HAVE_SELECT
  #ifdef FCNTL_DOTS
    extern_C int fcntl (int fd, int cmd, ...); /* FCNTL(2V) */
  #else
    extern_C int fcntl (int fd, int cmd, int arg); /* FCNTL(2V) */
  #endif
#endif
#if (defined(UNIX_TERM_TERMIOS) || defined(UNIX_TERM_TERMIO)) && !(defined(TCIFLUSH) && defined(TCOFLUSH))
  #define TCIFLUSH 0
  #define TCOFLUSH 1
#endif
extern_C int tgetent (const char* bp, const char* name); /* TERMCAP(3X) */
extern_C int tgetnum (const char* id); /* TERMCAP(3X) */
extern_C int tgetflag (const char* id); /* TERMCAP(3X) */
extern_C const char* tgetstr (const char* id, char** area); /* TERMCAP(3X) */
#ifdef EINTR
  /* wrapper around the system call, which intercepts and handles EINTR: */
  extern int nonintr_ioctl (int fd, IOCTL_REQUEST_T request, IOCTL_ARGUMENT_T arg);
  #undef ioctl
  #define ioctl(fd,request,arg)  nonintr_ioctl(fd,request,(IOCTL_ARGUMENT_T)(arg))
  #ifdef UNIX_TERM_TERMIOS
    extern int nonintr_tcsetattr (int fd, int optional_actions, struct termios * tp);
    extern int nonintr_tcdrain (int fd); /* TERMIOS(3V) */
    extern int nonintr_tcflush (int fd, int flag); /* TERMIOS(3V) */
    #undef TCSETATTR
    #define TCSETATTR nonintr_tcsetattr
    #undef TCDRAIN
    #define TCDRAIN nonintr_tcdrain
    #undef TCFLUSH
    #define TCFLUSH nonintr_tcflush
  #endif
#endif
/* used by SPVW, STREAM */

/* process date/time of day: */
#ifdef TM_IN_SYS_TIME
  #include <sys/time.h>
#else
  #include <time.h>
#endif
extern_C time_t time (time_t* clock); /* TIME(3V) */
extern_C struct tm * localtime (LOCALTIME_CONST time_t* clock); /* CTIME(3V) */
extern_C struct tm * gmtime (LOCALTIME_CONST time_t* clock); /* CTIME(3V) */
/* used by SPVW, MISC */

/* query date/time of day: */
#if defined(HAVE_GETTIMEOFDAY)
  #include <sys/time.h>
  #ifdef GETTIMEOFDAY_DOTS
    extern_C int gettimeofday (struct timeval * tp, ...); /* GETTIMEOFDAY(2) */
  #else
    extern_C int gettimeofday (struct timeval * tp, GETTIMEOFDAY_TZP_T tzp); /* GETTIMEOFDAY(2) */
  #endif
  #ifdef UNIX_CYGWIN32
    /* gettimeofday() always returns 1. Let it return 0. */
    #define gettimeofday(tv,tz)  ((gettimeofday)(tv,tz), 0)
  #endif
#elif defined(HAVE_FTIME)
  #include <sys/timeb.h>
  extern_C int ftime (struct timeb * tp); /* TIME(3V) */
  /* emulate gettimeofday() in unixaux.d: */
  #define NEED_OWN_GETTIMEOFDAY
  #ifndef _EMUL_SYS_TIME_H
    #define _EMUL_SYS_TIME_H
    struct timeval { long tv_sec; long tv_usec; };
    struct timezone { int tz_minuteswest; int tz_dsttime; };
  #endif
  extern int gettimeofday (struct timeval * tp, struct timezone * tzp); /* see unixaux.d */
#elif defined(HAVE_TIMES_CLOCK)
  #include <time.h> /* needed for CLK_TCK */
  #ifndef CLK_TCK
    #include <sys/time.h> /* needed for CLK_TCK, under UNIX_SYSV_PTX */
  #endif
  #include <sys/times.h>
  extern_C clock_t times (struct tms * buffer); /* TIMES(3V) */
  extern_C time_t time (time_t* tloc); /* TIME(3V) */
#else
  #error "Cannot access real time with resolution finer than 1 second."
#endif
/* used by SPVW, MISC */

/* inquire used time of the process: */
#if defined(HAVE_GETRUSAGE)
  #include <sys/time.h>
  #include <sys/resource.h>
  extern_C int getrusage (RUSAGE_WHO_T who, struct rusage * rusage); /* GETRUSAGE(2) */
  /* prototype useless, there 'struct rusage' /= 'struct rusage' */
#elif defined(HAVE_SYS_TIMES_H)
  #include <sys/param.h> /* define HZ, unit is 1/HZ seconds */
  #include <sys/times.h>
  extern_C clock_t times (struct tms * buffer); /* TIMES(3V) */
#endif
/* used by SPVW */

/* take a break for some time: */
extern_C unsigned int sleep (unsigned int seconds); /* SLEEP(3V) */
/* used by MISC */

/* program call: */
#define SHELL "/bin/sh"  /* the name of the shell command interpreter */
extern_C int pipe (int fd[2]); /* PIPE(2V) */
#ifdef HAVE_VFORK_H
  #include <vfork.h>
#endif
extern_C RETVFORKTYPE vfork (void); /* VFORK(2) */
extern_C int dup2 (int fd1, int fd2); /* DUP(2V) */
#if defined(HAVE_SETPGID)
  extern_C pid_t getpid (void); /* GETPID(2V) */
  extern_C int setpgid (pid_t pid, pid_t pgid); /* SETPGID(2V), SETSID(2V), TERMIO(4) */
  #define SETSID()  { register pid_t pid = getpid(); setpgid(pid,pid); }
#elif defined(HAVE_SETSID)
  extern_C pid_t setsid (void); /* SETSID(2V), TERMIO(4) */
  #define SETSID()  setsid()
#else
  #define SETSID()
#endif
extern_C int execv (EXECV_CONST char* path, EXECV1_CONST char* EXECV2_CONST argv[]); /* EXECL(3V) */
#ifdef EXECL_DOTS
  extern_C int execl (EXECV_CONST char* path, EXECL_CONST char* arg, ...); /* EXECL(3V) */
#else
  extern_C int execl (EXECV_CONST char* path, EXECL_CONST char* arg0, EXECL_CONST char* arg1, EXECL_CONST char* arg2, EXECL_CONST char* arg3); /* EXECL(3V) */
#endif
#ifdef EXECL_DOTS
  extern_C int execlp (EXECV_CONST char* path, EXECL_CONST char* arg, ...); /* EXECL(3V) */
#else
  extern_C int execlp (EXECV_CONST char* path, EXECL_CONST char* arg0, EXECL_CONST char* arg1, EXECL_CONST char* arg2, EXECL_CONST char* arg3); /* EXECL(3V) */
#endif
/* NB: In the period between vfork() and execv()/execl()/execlp() the child
   process may access only the data in the stack and constant data,
   because the parent process keeps running in this time already
   and can modify data in STACK, malloc() range, Lisp data range etc. */
#include <sys/wait.h>
extern_C pid_t waitpid (PID_T pid, int* statusp, int options); /* WAIT(2V) */
extern int wait2 (PID_T pid); /* see unixaux.d */
/* used by STREAM, PATHNAME, SPVW, UNIXAUX */

/* get random numbers: */
#ifndef rand /* some define rand() as macro... */
  extern_C int rand (void); /* RAND(3V) */
#endif
#if !defined(HAVE_SETPGID) /* in this case, already declared above */
  extern_C pid_t getpid (void); /* GETPID(2V) */
#endif
/* used by LISPARIT */

/* determine MACHINE-TYPE and MACHINE-VERSION and MACHINE-INSTANCE: */
#ifdef HAVE_SYS_UTSNAME_H
  #include <sys/utsname.h>
  extern_C int uname (struct utsname * buf); /* UNAME(2V) */
#endif
/* used by MISC */

/* determine MACHINE-INSTANCE: */
#ifdef HAVE_GETHOSTNAME
  extern_C int gethostname (char* name, GETHOSTNAME_SIZE_T namelen); /* GETHOSTNAME(2) */
#endif
#ifdef HAVE_GETHOSTBYNAME
  #ifdef HAVE_NETDB_H
    #include <sys/socket.h>
    #include <netdb.h>
  #else
    #include <sun/netdb.h>
  #endif
  extern_C struct hostent * gethostbyname (GETHOSTBYNAME_CONST char* name); /* GETHOSTENT(3) */
#endif
#ifndef MAXHOSTNAMELEN
  #define MAXHOSTNAMELEN 64 /* see <sys/param.h> */
#endif
/* used by MISC */

/* work with sockets: */
#ifdef HAVE_GETHOSTBYNAME
  /* Type of a socket */
  #define SOCKET  int
  /* Error value for functions returning a socket */
  #define INVALID_SOCKET  (SOCKET)(-1)
  /* Error value for functions returning an `int' status */
  #define SOCKET_ERROR  (-1)
  /* Accessing the error code */
  #define sock_errno  errno
  #define sock_errno_is(val)  (errno == val)
  #define sock_set_errno(val)  (void)(errno = val)
  /* Signalling a socket-related error */
  #define SOCK_error()  OS_error()
  #ifdef UNIX_BEOS
    /* BeOS 5 sockets cannot be used like file descriptors.
       Reading and writing from a socket */
    extern ssize_t sock_read (int socket, void* buf, size_t size);
    extern ssize_t sock_write (int socket, const void* buf, size_t size);
    /* Closing a socket */
    /* extern int closesocket (int socket); */
  #else
    /* Reading and writing from a socket */
    #define sock_read   safe_read
    #define sock_write  full_write
    /* Closing a socket */
    #define closesocket  close
  #endif
  /* Wrapping and unwrapping of a socket in a Lisp object */
  #define allocate_socket(fd)  allocate_handle(fd)
  #define TheSocket(obj)  TheHandle(obj)
#endif
/* used by SOCKET, STREAM */

/* Dynamic module loading:
   Even though HP-UX 10.20 and 11.00 support shl_load *and* dlopen,
   dlopen works correctly only with a patch. Because we want to avoid
   the situation where we build on a system with the patch but deploy
   on a system without, do not use dlopen on HP-UX. */
#ifdef UNIX_HPUX
  #undef HAVE_DLOPEN
#endif
#ifdef HAVE_DLOPEN
  #include <dlfcn.h>
  extern_C void* dlopen (const char * library, int flag);
  extern_C void* dlsym (void* handle, DLSYM_CONST char * symbol);
  extern_C int dlclose (void* handle);
  extern_C DLERROR_CONST char * dlerror (void);
  #define HAVE_DYNLOAD
#endif

/* Character set conversion: */
#ifdef HAVE_ICONV
  #include <iconv.h>
  extern_C iconv_t iconv_open (const char * to_code, const char * from_code);
  extern_C size_t iconv (iconv_t cd, ICONV_CONST char * *inbuf, size_t *inbytesleft, char * *outbuf, size_t* outbytesleft);
  extern_C int iconv_close (iconv_t cd);
#endif


/* CLISP as a NeXTstep-GUI-Application: */
#ifdef NEXTAPP
/* Terminal-Stream, as nxterminal.m over the class LispServer implements it. */
  extern void nxterminal_send_output (void);
  extern void nxterminal_write_char (unsigned char ch);
  extern void nxterminal_write_string (unsigned char * string);
  extern unsigned char nxterminal_read_char (int* linepos);
  extern int nxterminal_unread_char (void);
  extern int nxterminal_listen (void);
  extern int nxterminal_init (void);
  extern int nxterminal_exit (void);
  extern int nxterminal_line_length;
#endif
