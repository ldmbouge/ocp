# 1 "DFSController.C"
# 1 "/Users/ldm/work/langExp/cpp//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "DFSController.C"
# 9 "DFSController.C"
# 1 "DFSController.H" 1
# 12 "DFSController.H"
# 1 "CPController.H" 1
# 12 "CPController.H"
# 1 "cont.H" 1
# 12 "cont.H"
# 1 "/usr/include/stdlib.h" 1 3 4
# 61 "/usr/include/stdlib.h" 3 4
# 1 "/usr/include/Availability.h" 1 3 4
# 126 "/usr/include/Availability.h" 3 4
# 1 "/usr/include/AvailabilityInternal.h" 1 3 4
# 127 "/usr/include/Availability.h" 2 3 4
# 62 "/usr/include/stdlib.h" 2 3 4

# 1 "/usr/include/_types.h" 1 3 4
# 27 "/usr/include/_types.h" 3 4
# 1 "/usr/include/sys/_types.h" 1 3 4
# 32 "/usr/include/sys/_types.h" 3 4
# 1 "/usr/include/sys/cdefs.h" 1 3 4
# 33 "/usr/include/sys/_types.h" 2 3 4
# 1 "/usr/include/machine/_types.h" 1 3 4
# 34 "/usr/include/machine/_types.h" 3 4
# 1 "/usr/include/i386/_types.h" 1 3 4
# 37 "/usr/include/i386/_types.h" 3 4
typedef signed char __int8_t;



typedef unsigned char __uint8_t;
typedef short __int16_t;
typedef unsigned short __uint16_t;
typedef int __int32_t;
typedef unsigned int __uint32_t;
typedef long long __int64_t;
typedef unsigned long long __uint64_t;

typedef long __darwin_intptr_t;
typedef unsigned int __darwin_natural_t;
# 70 "/usr/include/i386/_types.h" 3 4
typedef int __darwin_ct_rune_t;





typedef union {
 char __mbstate8[128];
 long long _mbstateL;
} __mbstate_t;

typedef __mbstate_t __darwin_mbstate_t;


typedef long int __darwin_ptrdiff_t;





typedef long unsigned int __darwin_size_t;





typedef __builtin_va_list __darwin_va_list;





typedef int __darwin_wchar_t;




typedef __darwin_wchar_t __darwin_rune_t;


typedef int __darwin_wint_t;




typedef unsigned long __darwin_clock_t;
typedef __uint32_t __darwin_socklen_t;
typedef long __darwin_ssize_t;
typedef long __darwin_time_t;
# 35 "/usr/include/machine/_types.h" 2 3 4
# 34 "/usr/include/sys/_types.h" 2 3 4
# 58 "/usr/include/sys/_types.h" 3 4
struct __darwin_pthread_handler_rec
{
 void (*__routine)(void *);
 void *__arg;
 struct __darwin_pthread_handler_rec *__next;
};
struct _opaque_pthread_attr_t { long __sig; char __opaque[56]; };
struct _opaque_pthread_cond_t { long __sig; char __opaque[40]; };
struct _opaque_pthread_condattr_t { long __sig; char __opaque[8]; };
struct _opaque_pthread_mutex_t { long __sig; char __opaque[56]; };
struct _opaque_pthread_mutexattr_t { long __sig; char __opaque[8]; };
struct _opaque_pthread_once_t { long __sig; char __opaque[8]; };
struct _opaque_pthread_rwlock_t { long __sig; char __opaque[192]; };
struct _opaque_pthread_rwlockattr_t { long __sig; char __opaque[16]; };
struct _opaque_pthread_t { long __sig; struct __darwin_pthread_handler_rec *__cleanup_stack; char __opaque[1168]; };
# 94 "/usr/include/sys/_types.h" 3 4
typedef __int64_t __darwin_blkcnt_t;
typedef __int32_t __darwin_blksize_t;
typedef __int32_t __darwin_dev_t;
typedef unsigned int __darwin_fsblkcnt_t;
typedef unsigned int __darwin_fsfilcnt_t;
typedef __uint32_t __darwin_gid_t;
typedef __uint32_t __darwin_id_t;
typedef __uint64_t __darwin_ino64_t;

typedef __darwin_ino64_t __darwin_ino_t;



typedef __darwin_natural_t __darwin_mach_port_name_t;
typedef __darwin_mach_port_name_t __darwin_mach_port_t;
typedef __uint16_t __darwin_mode_t;
typedef __int64_t __darwin_off_t;
typedef __int32_t __darwin_pid_t;
typedef struct _opaque_pthread_attr_t
   __darwin_pthread_attr_t;
typedef struct _opaque_pthread_cond_t
   __darwin_pthread_cond_t;
typedef struct _opaque_pthread_condattr_t
   __darwin_pthread_condattr_t;
typedef unsigned long __darwin_pthread_key_t;
typedef struct _opaque_pthread_mutex_t
   __darwin_pthread_mutex_t;
typedef struct _opaque_pthread_mutexattr_t
   __darwin_pthread_mutexattr_t;
typedef struct _opaque_pthread_once_t
   __darwin_pthread_once_t;
typedef struct _opaque_pthread_rwlock_t
   __darwin_pthread_rwlock_t;
typedef struct _opaque_pthread_rwlockattr_t
   __darwin_pthread_rwlockattr_t;
typedef struct _opaque_pthread_t
   *__darwin_pthread_t;
typedef __uint32_t __darwin_sigset_t;
typedef __int32_t __darwin_suseconds_t;
typedef __uint32_t __darwin_uid_t;
typedef __uint32_t __darwin_useconds_t;
typedef unsigned char __darwin_uuid_t[16];
typedef char __darwin_uuid_string_t[37];
# 28 "/usr/include/_types.h" 2 3 4
# 39 "/usr/include/_types.h" 3 4
typedef int __darwin_nl_item;
typedef int __darwin_wctrans_t;

typedef __uint32_t __darwin_wctype_t;
# 64 "/usr/include/stdlib.h" 2 3 4

# 1 "/usr/include/sys/wait.h" 1 3 4
# 79 "/usr/include/sys/wait.h" 3 4
typedef enum {
 P_ALL,
 P_PID,
 P_PGID
} idtype_t;






typedef __darwin_pid_t pid_t;




typedef __darwin_id_t id_t;
# 116 "/usr/include/sys/wait.h" 3 4
# 1 "/usr/include/sys/signal.h" 1 3 4
# 73 "/usr/include/sys/signal.h" 3 4
# 1 "/usr/include/sys/appleapiopts.h" 1 3 4
# 74 "/usr/include/sys/signal.h" 2 3 4







# 1 "/usr/include/machine/signal.h" 1 3 4
# 34 "/usr/include/machine/signal.h" 3 4
# 1 "/usr/include/i386/signal.h" 1 3 4
# 39 "/usr/include/i386/signal.h" 3 4
typedef int sig_atomic_t;
# 55 "/usr/include/i386/signal.h" 3 4
# 1 "/usr/include/i386/_structs.h" 1 3 4
# 56 "/usr/include/i386/signal.h" 2 3 4
# 35 "/usr/include/machine/signal.h" 2 3 4
# 82 "/usr/include/sys/signal.h" 2 3 4
# 154 "/usr/include/sys/signal.h" 3 4
# 1 "/usr/include/sys/_structs.h" 1 3 4
# 57 "/usr/include/sys/_structs.h" 3 4
# 1 "/usr/include/machine/_structs.h" 1 3 4
# 31 "/usr/include/machine/_structs.h" 3 4
# 1 "/usr/include/i386/_structs.h" 1 3 4
# 38 "/usr/include/i386/_structs.h" 3 4
# 1 "/usr/include/mach/i386/_structs.h" 1 3 4
# 43 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_i386_thread_state
{
    unsigned int __eax;
    unsigned int __ebx;
    unsigned int __ecx;
    unsigned int __edx;
    unsigned int __edi;
    unsigned int __esi;
    unsigned int __ebp;
    unsigned int __esp;
    unsigned int __ss;
    unsigned int __eflags;
    unsigned int __eip;
    unsigned int __cs;
    unsigned int __ds;
    unsigned int __es;
    unsigned int __fs;
    unsigned int __gs;
};
# 89 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_fp_control
{
    unsigned short __invalid :1,
        __denorm :1,
    __zdiv :1,
    __ovrfl :1,
    __undfl :1,
    __precis :1,
      :2,
    __pc :2,





    __rc :2,






             :1,
      :3;
};
typedef struct __darwin_fp_control __darwin_fp_control_t;
# 147 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_fp_status
{
    unsigned short __invalid :1,
        __denorm :1,
    __zdiv :1,
    __ovrfl :1,
    __undfl :1,
    __precis :1,
    __stkflt :1,
    __errsumm :1,
    __c0 :1,
    __c1 :1,
    __c2 :1,
    __tos :3,
    __c3 :1,
    __busy :1;
};
typedef struct __darwin_fp_status __darwin_fp_status_t;
# 191 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_mmst_reg
{
 char __mmst_reg[10];
 char __mmst_rsrv[6];
};
# 210 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_xmm_reg
{
 char __xmm_reg[16];
};
# 232 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_i386_float_state
{
 int __fpu_reserved[2];
 struct __darwin_fp_control __fpu_fcw;
 struct __darwin_fp_status __fpu_fsw;
 __uint8_t __fpu_ftw;
 __uint8_t __fpu_rsrv1;
 __uint16_t __fpu_fop;
 __uint32_t __fpu_ip;
 __uint16_t __fpu_cs;
 __uint16_t __fpu_rsrv2;
 __uint32_t __fpu_dp;
 __uint16_t __fpu_ds;
 __uint16_t __fpu_rsrv3;
 __uint32_t __fpu_mxcsr;
 __uint32_t __fpu_mxcsrmask;
 struct __darwin_mmst_reg __fpu_stmm0;
 struct __darwin_mmst_reg __fpu_stmm1;
 struct __darwin_mmst_reg __fpu_stmm2;
 struct __darwin_mmst_reg __fpu_stmm3;
 struct __darwin_mmst_reg __fpu_stmm4;
 struct __darwin_mmst_reg __fpu_stmm5;
 struct __darwin_mmst_reg __fpu_stmm6;
 struct __darwin_mmst_reg __fpu_stmm7;
 struct __darwin_xmm_reg __fpu_xmm0;
 struct __darwin_xmm_reg __fpu_xmm1;
 struct __darwin_xmm_reg __fpu_xmm2;
 struct __darwin_xmm_reg __fpu_xmm3;
 struct __darwin_xmm_reg __fpu_xmm4;
 struct __darwin_xmm_reg __fpu_xmm5;
 struct __darwin_xmm_reg __fpu_xmm6;
 struct __darwin_xmm_reg __fpu_xmm7;
 char __fpu_rsrv4[14*16];
 int __fpu_reserved1;
};
# 308 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_i386_exception_state
{
    unsigned int __trapno;
    unsigned int __err;
    unsigned int __faultvaddr;
};
# 326 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_x86_debug_state32
{
 unsigned int __dr0;
 unsigned int __dr1;
 unsigned int __dr2;
 unsigned int __dr3;
 unsigned int __dr4;
 unsigned int __dr5;
 unsigned int __dr6;
 unsigned int __dr7;
};
# 358 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_x86_thread_state64
{
 __uint64_t __rax;
 __uint64_t __rbx;
 __uint64_t __rcx;
 __uint64_t __rdx;
 __uint64_t __rdi;
 __uint64_t __rsi;
 __uint64_t __rbp;
 __uint64_t __rsp;
 __uint64_t __r8;
 __uint64_t __r9;
 __uint64_t __r10;
 __uint64_t __r11;
 __uint64_t __r12;
 __uint64_t __r13;
 __uint64_t __r14;
 __uint64_t __r15;
 __uint64_t __rip;
 __uint64_t __rflags;
 __uint64_t __cs;
 __uint64_t __fs;
 __uint64_t __gs;
};
# 413 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_x86_float_state64
{
 int __fpu_reserved[2];
 struct __darwin_fp_control __fpu_fcw;
 struct __darwin_fp_status __fpu_fsw;
 __uint8_t __fpu_ftw;
 __uint8_t __fpu_rsrv1;
 __uint16_t __fpu_fop;


 __uint32_t __fpu_ip;
 __uint16_t __fpu_cs;

 __uint16_t __fpu_rsrv2;


 __uint32_t __fpu_dp;
 __uint16_t __fpu_ds;

 __uint16_t __fpu_rsrv3;
 __uint32_t __fpu_mxcsr;
 __uint32_t __fpu_mxcsrmask;
 struct __darwin_mmst_reg __fpu_stmm0;
 struct __darwin_mmst_reg __fpu_stmm1;
 struct __darwin_mmst_reg __fpu_stmm2;
 struct __darwin_mmst_reg __fpu_stmm3;
 struct __darwin_mmst_reg __fpu_stmm4;
 struct __darwin_mmst_reg __fpu_stmm5;
 struct __darwin_mmst_reg __fpu_stmm6;
 struct __darwin_mmst_reg __fpu_stmm7;
 struct __darwin_xmm_reg __fpu_xmm0;
 struct __darwin_xmm_reg __fpu_xmm1;
 struct __darwin_xmm_reg __fpu_xmm2;
 struct __darwin_xmm_reg __fpu_xmm3;
 struct __darwin_xmm_reg __fpu_xmm4;
 struct __darwin_xmm_reg __fpu_xmm5;
 struct __darwin_xmm_reg __fpu_xmm6;
 struct __darwin_xmm_reg __fpu_xmm7;
 struct __darwin_xmm_reg __fpu_xmm8;
 struct __darwin_xmm_reg __fpu_xmm9;
 struct __darwin_xmm_reg __fpu_xmm10;
 struct __darwin_xmm_reg __fpu_xmm11;
 struct __darwin_xmm_reg __fpu_xmm12;
 struct __darwin_xmm_reg __fpu_xmm13;
 struct __darwin_xmm_reg __fpu_xmm14;
 struct __darwin_xmm_reg __fpu_xmm15;
 char __fpu_rsrv4[6*16];
 int __fpu_reserved1;
};
# 517 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_x86_exception_state64
{
    unsigned int __trapno;
    unsigned int __err;
    __uint64_t __faultvaddr;
};
# 535 "/usr/include/mach/i386/_structs.h" 3 4
struct __darwin_x86_debug_state64
{
 __uint64_t __dr0;
 __uint64_t __dr1;
 __uint64_t __dr2;
 __uint64_t __dr3;
 __uint64_t __dr4;
 __uint64_t __dr5;
 __uint64_t __dr6;
 __uint64_t __dr7;
};
# 39 "/usr/include/i386/_structs.h" 2 3 4
# 48 "/usr/include/i386/_structs.h" 3 4
struct __darwin_mcontext32
{
 struct __darwin_i386_exception_state __es;
 struct __darwin_i386_thread_state __ss;
 struct __darwin_i386_float_state __fs;
};
# 68 "/usr/include/i386/_structs.h" 3 4
struct __darwin_mcontext64
{
 struct __darwin_x86_exception_state64 __es;
 struct __darwin_x86_thread_state64 __ss;
 struct __darwin_x86_float_state64 __fs;
};
# 91 "/usr/include/i386/_structs.h" 3 4
typedef struct __darwin_mcontext64 *mcontext_t;
# 32 "/usr/include/machine/_structs.h" 2 3 4
# 58 "/usr/include/sys/_structs.h" 2 3 4
# 75 "/usr/include/sys/_structs.h" 3 4
struct __darwin_sigaltstack
{
 void *ss_sp;
 __darwin_size_t ss_size;
 int ss_flags;
};
# 128 "/usr/include/sys/_structs.h" 3 4
struct __darwin_ucontext
{
 int uc_onstack;
 __darwin_sigset_t uc_sigmask;
 struct __darwin_sigaltstack uc_stack;
 struct __darwin_ucontext *uc_link;
 __darwin_size_t uc_mcsize;
 struct __darwin_mcontext64 *uc_mcontext;



};
# 218 "/usr/include/sys/_structs.h" 3 4
typedef struct __darwin_sigaltstack stack_t;
# 227 "/usr/include/sys/_structs.h" 3 4
typedef struct __darwin_ucontext ucontext_t;
# 155 "/usr/include/sys/signal.h" 2 3 4
# 163 "/usr/include/sys/signal.h" 3 4
typedef __darwin_pthread_attr_t pthread_attr_t;




typedef __darwin_sigset_t sigset_t;




typedef __darwin_size_t size_t;




typedef __darwin_uid_t uid_t;


union sigval {

 int sival_int;
 void *sival_ptr;
};





struct sigevent {
 int sigev_notify;
 int sigev_signo;
 union sigval sigev_value;
 void (*sigev_notify_function)(union sigval);
 pthread_attr_t *sigev_notify_attributes;
};


typedef struct __siginfo {
 int si_signo;
 int si_errno;
 int si_code;
 pid_t si_pid;
 uid_t si_uid;
 int si_status;
 void *si_addr;
 union sigval si_value;
 long si_band;
 unsigned long __pad[7];
} siginfo_t;
# 292 "/usr/include/sys/signal.h" 3 4
union __sigaction_u {
 void (*__sa_handler)(int);
 void (*__sa_sigaction)(int, struct __siginfo *,
         void *);
};


struct __sigaction {
 union __sigaction_u __sigaction_u;
 void (*sa_tramp)(void *, int, int, siginfo_t *, void *);
 sigset_t sa_mask;
 int sa_flags;
};




struct sigaction {
 union __sigaction_u __sigaction_u;
 sigset_t sa_mask;
 int sa_flags;
};
# 354 "/usr/include/sys/signal.h" 3 4
typedef void (*sig_t)(int);
# 371 "/usr/include/sys/signal.h" 3 4
struct sigvec {
 void (*sv_handler)(int);
 int sv_mask;
 int sv_flags;
};
# 390 "/usr/include/sys/signal.h" 3 4
struct sigstack {
 char *ss_sp;
 int ss_onstack;
};
# 412 "/usr/include/sys/signal.h" 3 4
extern "C" {
void (*signal(int, void (*)(int)))(int);
}
# 117 "/usr/include/sys/wait.h" 2 3 4
# 1 "/usr/include/sys/resource.h" 1 3 4
# 76 "/usr/include/sys/resource.h" 3 4
# 1 "/usr/include/sys/_structs.h" 1 3 4
# 100 "/usr/include/sys/_structs.h" 3 4
struct timeval
{
 __darwin_time_t tv_sec;
 __darwin_suseconds_t tv_usec;
};
# 77 "/usr/include/sys/resource.h" 2 3 4
# 88 "/usr/include/sys/resource.h" 3 4
typedef __uint64_t rlim_t;
# 142 "/usr/include/sys/resource.h" 3 4
struct rusage {
 struct timeval ru_utime;
 struct timeval ru_stime;
# 153 "/usr/include/sys/resource.h" 3 4
 long ru_maxrss;

 long ru_ixrss;
 long ru_idrss;
 long ru_isrss;
 long ru_minflt;
 long ru_majflt;
 long ru_nswap;
 long ru_inblock;
 long ru_oublock;
 long ru_msgsnd;
 long ru_msgrcv;
 long ru_nsignals;
 long ru_nvcsw;
 long ru_nivcsw;


};
# 213 "/usr/include/sys/resource.h" 3 4
struct rlimit {
 rlim_t rlim_cur;
 rlim_t rlim_max;
};
# 235 "/usr/include/sys/resource.h" 3 4
extern "C" {
int getpriority(int, id_t);

int getiopolicy_np(int, int);

int getrlimit(int, struct rlimit *) __asm("_" "getrlimit" );
int getrusage(int, struct rusage *);
int setpriority(int, id_t, int);

int setiopolicy_np(int, int, int);

int setrlimit(int, const struct rlimit *) __asm("_" "setrlimit" );
}
# 118 "/usr/include/sys/wait.h" 2 3 4
# 193 "/usr/include/sys/wait.h" 3 4
# 1 "/usr/include/machine/endian.h" 1 3 4
# 37 "/usr/include/machine/endian.h" 3 4
# 1 "/usr/include/i386/endian.h" 1 3 4
# 99 "/usr/include/i386/endian.h" 3 4
# 1 "/usr/include/sys/_endian.h" 1 3 4
# 124 "/usr/include/sys/_endian.h" 3 4
# 1 "/usr/include/libkern/_OSByteOrder.h" 1 3 4
# 66 "/usr/include/libkern/_OSByteOrder.h" 3 4
# 1 "/usr/include/libkern/i386/_OSByteOrder.h" 1 3 4
# 44 "/usr/include/libkern/i386/_OSByteOrder.h" 3 4
static inline
__uint16_t
_OSSwapInt16(
    __uint16_t _data
)
{
    return ((_data << 8) | (_data >> 8));
}

static inline
__uint32_t
_OSSwapInt32(
    __uint32_t _data
)
{



    __asm__ ("bswap   %0" : "+r" (_data));
    return _data;

}
# 91 "/usr/include/libkern/i386/_OSByteOrder.h" 3 4
static inline
__uint64_t
_OSSwapInt64(
    __uint64_t _data
)
{
    __asm__ ("bswap   %0" : "+r" (_data));
    return _data;
}
# 67 "/usr/include/libkern/_OSByteOrder.h" 2 3 4
# 125 "/usr/include/sys/_endian.h" 2 3 4
# 100 "/usr/include/i386/endian.h" 2 3 4
# 38 "/usr/include/machine/endian.h" 2 3 4
# 194 "/usr/include/sys/wait.h" 2 3 4







union wait {
 int w_status;



 struct {

  unsigned int w_Termsig:7,
    w_Coredump:1,
    w_Retcode:8,
    w_Filler:16;







 } w_T;





 struct {

  unsigned int w_Stopval:8,
    w_Stopsig:8,
    w_Filler:16;






 } w_S;
};
# 254 "/usr/include/sys/wait.h" 3 4
extern "C" {
pid_t wait(int *) __asm("_" "wait" );
pid_t waitpid(pid_t, int *, int) __asm("_" "waitpid" );

int waitid(idtype_t, id_t, siginfo_t *, int) __asm("_" "waitid" );


pid_t wait3(int *, int, struct rusage *);
pid_t wait4(pid_t, int *, int, struct rusage *);

}
# 66 "/usr/include/stdlib.h" 2 3 4

# 1 "/usr/include/alloca.h" 1 3 4
# 35 "/usr/include/alloca.h" 3 4
extern "C" {
void *alloca(size_t);
}
# 68 "/usr/include/stdlib.h" 2 3 4
# 81 "/usr/include/stdlib.h" 3 4
typedef __darwin_ct_rune_t ct_rune_t;




typedef __darwin_rune_t rune_t;
# 97 "/usr/include/stdlib.h" 3 4
typedef struct {
 int quot;
 int rem;
} div_t;

typedef struct {
 long quot;
 long rem;
} ldiv_t;


typedef struct {
 long long quot;
 long long rem;
} lldiv_t;
# 134 "/usr/include/stdlib.h" 3 4
extern int __mb_cur_max;
# 144 "/usr/include/stdlib.h" 3 4
extern "C" {
void abort(void) __attribute__((__noreturn__));
int abs(int) __attribute__((__const__));
int atexit(void (*)(void));
double atof(const char *);
int atoi(const char *);
long atol(const char *);

long long
  atoll(const char *);

void *bsearch(const void *, const void *, size_t,
     size_t, int (*)(const void *, const void *));
void *calloc(size_t, size_t);
div_t div(int, int) __attribute__((__const__));
void exit(int) __attribute__((__noreturn__));
void free(void *);
char *getenv(const char *);
long labs(long) __attribute__((__const__));
ldiv_t ldiv(long, long) __attribute__((__const__));

long long
  llabs(long long);
lldiv_t lldiv(long long, long long);

void *malloc(size_t);
int mblen(const char *, size_t);
size_t mbstowcs(wchar_t * , const char * , size_t);
int mbtowc(wchar_t * , const char * , size_t);
int posix_memalign(void **, size_t, size_t);
void qsort(void *, size_t, size_t,
     int (*)(const void *, const void *));
int rand(void);
void *realloc(void *, size_t);
void srand(unsigned);
double strtod(const char *, char **) __asm("_" "strtod" );
float strtof(const char *, char **) __asm("_" "strtof" );
long strtol(const char *, char **, int);
long double
  strtold(const char *, char **) ;

long long
  strtoll(const char *, char **, int);

unsigned long
  strtoul(const char *, char **, int);

unsigned long long
  strtoull(const char *, char **, int);

int system(const char *) __asm("_" "system" );
size_t wcstombs(char * , const wchar_t * , size_t);
int wctomb(char *, wchar_t);


void _Exit(int) __attribute__((__noreturn__));
long a64l(const char *);
double drand48(void);
char *ecvt(double, int, int *, int *);
double erand48(unsigned short[3]);
char *fcvt(double, int, int *, int *);
char *gcvt(double, int, char *);
int getsubopt(char **, char * const *, char **);
int grantpt(int);

char *initstate(unsigned, char *, size_t);



long jrand48(unsigned short[3]);
char *l64a(long);
void lcong48(unsigned short[7]);
long lrand48(void);
char *mktemp(char *);
int mkstemp(char *);
long mrand48(void);
long nrand48(unsigned short[3]);
int posix_openpt(int);
char *ptsname(int);
int putenv(char *) __asm("_" "putenv" );
long random(void);
int rand_r(unsigned *);

char *realpath(const char * , char * ) __asm("_" "realpath" "$DARWIN_EXTSN");



unsigned short
 *seed48(unsigned short[3]);
int setenv(const char *, const char *, int) __asm("_" "setenv" );

void setkey(const char *) __asm("_" "setkey" );



char *setstate(const char *);
void srand48(long);

void srandom(unsigned);



int unlockpt(int);

int unsetenv(const char *) __asm("_" "unsetenv" );






# 1 "/usr/include/machine/types.h" 1 3 4
# 37 "/usr/include/machine/types.h" 3 4
# 1 "/usr/include/i386/types.h" 1 3 4
# 78 "/usr/include/i386/types.h" 3 4
typedef signed char int8_t;

typedef unsigned char u_int8_t;


typedef short int16_t;

typedef unsigned short u_int16_t;


typedef int int32_t;

typedef unsigned int u_int32_t;


typedef long long int64_t;

typedef unsigned long long u_int64_t;


typedef int64_t register_t;






typedef __darwin_intptr_t intptr_t;



typedef unsigned long uintptr_t;




typedef u_int64_t user_addr_t;
typedef u_int64_t user_size_t;
typedef int64_t user_ssize_t;
typedef int64_t user_long_t;
typedef u_int64_t user_ulong_t;
typedef int64_t user_time_t;
typedef int64_t user_off_t;







typedef u_int64_t syscall_arg_t;
# 38 "/usr/include/machine/types.h" 2 3 4
# 256 "/usr/include/stdlib.h" 2 3 4


typedef __darwin_dev_t dev_t;




typedef __darwin_mode_t mode_t;



u_int32_t
  arc4random(void);
void arc4random_addrandom(unsigned char *dat, int datlen);
void arc4random_stir(void);







char *cgetcap(char *, const char *, int);
int cgetclose(void);
int cgetent(char **, char **, const char *);
int cgetfirst(char **, char **);
int cgetmatch(const char *, const char *);
int cgetnext(char **, char **);
int cgetnum(char *, const char *, long *);
int cgetset(const char *);
int cgetstr(char *, const char *, char **);
int cgetustr(char *, const char *, char **);

int daemon(int, int) __asm("_" "daemon" "$1050") __attribute__((deprecated,visibility("default")));
char *devname(dev_t, mode_t);
char *devname_r(dev_t, mode_t, char *buf, int len);
char *getbsize(int *, long *);
int getloadavg(double [], int);
const char
 *getprogname(void);

int heapsort(void *, size_t, size_t,
     int (*)(const void *, const void *));




int mergesort(void *, size_t, size_t,
     int (*)(const void *, const void *));




void psort(void *, size_t, size_t,
     int (*)(const void *, const void *));




void psort_r(void *, size_t, size_t, void *,
     int (*)(void *, const void *, const void *));




void qsort_r(void *, size_t, size_t, void *,
     int (*)(void *, const void *, const void *));
int radixsort(const unsigned char **, int, const unsigned char *,
     unsigned);
void setprogname(const char *);
int sradixsort(const unsigned char **, int, const unsigned char *,
     unsigned);
void sranddev(void);
void srandomdev(void);
void *reallocf(void *, size_t);

long long
  strtoq(const char *, char **, int);
unsigned long long
  strtouq(const char *, char **, int);

extern char *suboptarg;
void *valloc(size_t);






}
# 13 "cont.H" 2
# 1 "/usr/include/string.h" 1 3 4
# 70 "/usr/include/string.h" 3 4
typedef __darwin_ssize_t ssize_t;
# 80 "/usr/include/string.h" 3 4
extern "C" {
void *memchr(const void *, int, size_t);
int memcmp(const void *, const void *, size_t);
void *memcpy(void *, const void *, size_t);
void *memmove(void *, const void *, size_t);
void *memset(void *, int, size_t);

char *stpcpy(char *, const char *);
char *strcasestr(const char *, const char *);

char *strcat(char *, const char *);
char *strchr(const char *, int);
int strcmp(const char *, const char *);
int strcoll(const char *, const char *);
char *strcpy(char *, const char *);
size_t strcspn(const char *, const char *);
char *strerror(int) __asm("_" "strerror" );
int strerror_r(int, char *, size_t);
size_t strlen(const char *);
char *strncat(char *, const char *, size_t);
int strncmp(const char *, const char *, size_t);
char *strncpy(char *, const char *, size_t);

char *strnstr(const char *, const char *, size_t);

char *strpbrk(const char *, const char *);
char *strrchr(const char *, int);
size_t strspn(const char *, const char *);
char *strstr(const char *, const char *);
char *strtok(char *, const char *);
size_t strxfrm(char *, const char *, size_t);



void *memccpy(void *, const void *, int, size_t);
char *strtok_r(char *, const char *, char **);
char *strdup(const char *);

int bcmp(const void *, const void *, size_t);
void bcopy(const void *, void *, size_t);
void bzero(void *, size_t);
int ffs(int);
int ffsl(long);
int fls(int);
int flsl(long);
char *index(const char *, int);
void memset_pattern4(void *, const void *, size_t);
void memset_pattern8(void *, const void *, size_t);
void memset_pattern16(void *, const void *, size_t);
char *rindex(const char *, int);
int strcasecmp(const char *, const char *);
size_t strlcat(char *, const char *, size_t);
size_t strlcpy(char *, const char *, size_t);
void strmode(int, char *);
int strncasecmp(const char *, const char *, size_t);
char *strsep(char **, const char *);
char *strsignal(int sig);
void swab(const void * , void * , ssize_t);


}
# 14 "cont.H" 2
# 1 "/usr/include/stdio.h" 1 3 4
# 70 "/usr/include/stdio.h" 3 4
typedef __darwin_va_list va_list;




typedef __darwin_off_t off_t;
# 87 "/usr/include/stdio.h" 3 4
typedef __darwin_off_t fpos_t;
# 98 "/usr/include/stdio.h" 3 4
struct __sbuf {
 unsigned char *_base;
 int _size;
};


struct __sFILEX;
# 132 "/usr/include/stdio.h" 3 4
typedef struct __sFILE {
 unsigned char *_p;
 int _r;
 int _w;
 short _flags;
 short _file;
 struct __sbuf _bf;
 int _lbfsize;


 void *_cookie;
 int (*_close)(void *);
 int (*_read) (void *, char *, int);
 fpos_t (*_seek) (void *, fpos_t, int);
 int (*_write)(void *, const char *, int);


 struct __sbuf _ub;
 struct __sFILEX *_extra;
 int _ur;


 unsigned char _ubuf[3];
 unsigned char _nbuf[1];


 struct __sbuf _lb;


 int _blksize;
 fpos_t _offset;
} FILE;

extern "C" {

extern FILE *__stdinp;
extern FILE *__stdoutp;
extern FILE *__stderrp;



}
# 248 "/usr/include/stdio.h" 3 4
extern "C" {
void clearerr(FILE *);
int fclose(FILE *);
int feof(FILE *);
int ferror(FILE *);
int fflush(FILE *);
int fgetc(FILE *);
int fgetpos(FILE * , fpos_t *);
char *fgets(char * , int, FILE *);



FILE *fopen(const char * , const char * ) __asm("_" "fopen" );

int fprintf(FILE * , const char * , ...) ;
int fputc(int, FILE *);
int fputs(const char * , FILE * ) __asm("_" "fputs" );
size_t fread(void * , size_t, size_t, FILE * );
FILE *freopen(const char * , const char * ,
     FILE * ) __asm("_" "freopen" );
int fscanf(FILE * , const char * , ...) ;
int fseek(FILE *, long, int);
int fsetpos(FILE *, const fpos_t *);
long ftell(FILE *);
size_t fwrite(const void * , size_t, size_t, FILE * ) __asm("_" "fwrite" );
int getc(FILE *);
int getchar(void);
char *gets(char *);

extern const int sys_nerr;
extern const char *const sys_errlist[];

void perror(const char *);
int printf(const char * , ...) ;
int putc(int, FILE *);
int putchar(int);
int puts(const char *);
int remove(const char *);
int rename (const char *, const char *);
void rewind(FILE *);
int scanf(const char * , ...) ;
void setbuf(FILE * , char * );
int setvbuf(FILE * , char * , int, size_t);
int sprintf(char * , const char * , ...) ;
int sscanf(const char * , const char * , ...) ;
FILE *tmpfile(void);
char *tmpnam(char *);
int ungetc(int, FILE *);
int vfprintf(FILE * , const char * , va_list) ;
int vprintf(const char * , va_list) ;
int vsprintf(char * , const char * , va_list) ;

int asprintf(char **, const char *, ...) ;
int vasprintf(char **, const char *, va_list) ;

}







extern "C" {
char *ctermid(char *);

char *ctermid_r(char *);




FILE *fdopen(int, const char *) __asm("_" "fdopen" );


char *fgetln(FILE *, size_t *);

int fileno(FILE *);
void flockfile(FILE *);

const char
 *fmtcheck(const char *, const char *);
int fpurge(FILE *);

int fseeko(FILE *, off_t, int);
off_t ftello(FILE *);
int ftrylockfile(FILE *);
void funlockfile(FILE *);
int getc_unlocked(FILE *);
int getchar_unlocked(void);

int getw(FILE *);

int pclose(FILE *);



FILE *popen(const char *, const char *) __asm("_" "popen" );

int putc_unlocked(int, FILE *);
int putchar_unlocked(int);

int putw(int, FILE *);
void setbuffer(FILE *, char *, int);
int setlinebuf(FILE *);

int snprintf(char * , size_t, const char * , ...) ;
char *tempnam(const char *, const char *) __asm("_" "tempnam" );
int vfscanf(FILE * , const char * , va_list) ;
int vscanf(const char * , va_list) ;
int vsnprintf(char * , size_t, const char * , va_list) ;
int vsscanf(const char * , const char * , va_list) ;

FILE *zopen(const char *, const char *, int);

}





extern "C" {
FILE *funopen(const void *,
  int (*)(void *, char *, int),
  int (*)(void *, const char *, int),
  fpos_t (*)(void *, fpos_t, int),
  int (*)(void *));
}
# 383 "/usr/include/stdio.h" 3 4
extern "C" {
int __srget(FILE *);
int __svfscanf(FILE *, const char *, va_list) ;
int __swbuf(int, FILE *);
}







static inline int __sputc(int _c, FILE *_p) {
 if (--_p->_w >= 0 || (_p->_w >= _p->_lbfsize && (char)_c != '\n'))
  return (*_p->_p++ = _c);
 else
  return (__swbuf(_c, _p));
}
# 15 "cont.H" 2
# 1 "context.H" 1
# 13 "context.H"
class NSCont;


struct Ctx64 {
   long rax;
   long rbx;
   long rcx;
   long rdx;
   long rdi;
   long rsi;
   long rbp;
   long rsp;
   long r8;
   long r9;
   long r10;
   long r11;
   long r12;
   long r13;
   long r14;
   long r15;
   int cs;
   int ss;
   int ds;
   int fs;
   int es;
   int gs;
   long rip;
   double xmm0[2];
   double xmm1[2];
};

__attribute__((noinline)) NSCont* saveCtx(struct Ctx64* ctx,NSCont* k);
__attribute__((noinline)) NSCont* restoreCtx(struct Ctx64* ctx,char* start,char* data,size_t length);




void initContinuationLibrary(int *base);
char* getContBase();
# 16 "cont.H" 2

class NSCont {

   long _pad;
   struct Ctx64 _target;



   size_t _length;
   void* _start;
   char* _data;
   int _used;
   int _ref;
 public:
   NSCont();
   ~NSCont();
   void saveStack(char* buf,size_t l,void* s);
   void call();
   int nbCalls();
   void addRef();
   static NSCont* takeContinuation();
   static void callContinuation(NSCont* c);
   static void releaseContinuation(NSCont* c);
};
# 13 "CPController.H" 2

class CPController {
 public:
   CPController() {}
   virtual ~CPController() {}
   virtual void addChoice(NSCont* k) = 0;
   virtual void fail();
   virtual void searchWithRestart(NSCont* k,NSCont* ex);
};
# 13 "DFSController.H" 2
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/vector" 1 3
# 59 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/vector" 3
       
# 60 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/vector" 3

# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 1 3
# 60 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/x86_64-apple-darwin10.7.0/bits/c++config.h" 1 3
# 153 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/x86_64-apple-darwin10.7.0/bits/c++config.h" 3
namespace std
{
  typedef long unsigned int size_t;
  typedef long int ptrdiff_t;


  typedef decltype(nullptr) nullptr_t;

}
# 392 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/x86_64-apple-darwin10.7.0/bits/c++config.h" 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/x86_64-apple-darwin10.7.0/bits/os_defines.h" 1 3
# 393 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/x86_64-apple-darwin10.7.0/bits/c++config.h" 2 3


# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/x86_64-apple-darwin10.7.0/bits/cpu_defines.h" 1 3
# 396 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/x86_64-apple-darwin10.7.0/bits/c++config.h" 2 3
# 61 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/functexcept.h" 1 3
# 41 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/functexcept.h" 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/exception_defines.h" 1 3
# 42 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/functexcept.h" 2 3

namespace std __attribute__ ((__visibility__ ("default")))
{



  void
  __throw_bad_exception(void) __attribute__((__noreturn__));


  void
  __throw_bad_alloc(void) __attribute__((__noreturn__));


  void
  __throw_bad_cast(void) __attribute__((__noreturn__));

  void
  __throw_bad_typeid(void) __attribute__((__noreturn__));


  void
  __throw_logic_error(const char*) __attribute__((__noreturn__));

  void
  __throw_domain_error(const char*) __attribute__((__noreturn__));

  void
  __throw_invalid_argument(const char*) __attribute__((__noreturn__));

  void
  __throw_length_error(const char*) __attribute__((__noreturn__));

  void
  __throw_out_of_range(const char*) __attribute__((__noreturn__));

  void
  __throw_runtime_error(const char*) __attribute__((__noreturn__));

  void
  __throw_range_error(const char*) __attribute__((__noreturn__));

  void
  __throw_overflow_error(const char*) __attribute__((__noreturn__));

  void
  __throw_underflow_error(const char*) __attribute__((__noreturn__));


  void
  __throw_ios_failure(const char*) __attribute__((__noreturn__));

  void
  __throw_system_error(int) __attribute__((__noreturn__));

  void
  __throw_future_error(int) __attribute__((__noreturn__));


  void
  __throw_bad_function_call() __attribute__((__noreturn__));


}
# 62 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/cpp_type_traits.h" 1 3
# 36 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/cpp_type_traits.h" 3
       
# 37 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/cpp_type_traits.h" 3
# 69 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/cpp_type_traits.h" 3
namespace __gnu_cxx __attribute__ ((__visibility__ ("default")))
{


  template<typename _Iterator, typename _Container>
    class __normal_iterator;


}

namespace std __attribute__ ((__visibility__ ("default")))
{


  struct __true_type { };
  struct __false_type { };

  template<bool>
    struct __truth_type
    { typedef __false_type __type; };

  template<>
    struct __truth_type<true>
    { typedef __true_type __type; };



  template<class _Sp, class _Tp>
    struct __traitor
    {
      enum { __value = bool(_Sp::__value) || bool(_Tp::__value) };
      typedef typename __truth_type<__value>::__type __type;
    };


  template<typename, typename>
    struct __are_same
    {
      enum { __value = 0 };
      typedef __false_type __type;
    };

  template<typename _Tp>
    struct __are_same<_Tp, _Tp>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };


  template<typename _Tp>
    struct __is_void
    {
      enum { __value = 0 };
      typedef __false_type __type;
    };

  template<>
    struct __is_void<void>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };




  template<typename _Tp>
    struct __is_integer
    {
      enum { __value = 0 };
      typedef __false_type __type;
    };




  template<>
    struct __is_integer<bool>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_integer<char>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_integer<signed char>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_integer<unsigned char>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };


  template<>
    struct __is_integer<wchar_t>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };



  template<>
    struct __is_integer<char16_t>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_integer<char32_t>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };


  template<>
    struct __is_integer<short>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_integer<unsigned short>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_integer<int>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_integer<unsigned int>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_integer<long>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_integer<unsigned long>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_integer<long long>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_integer<unsigned long long>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };




  template<typename _Tp>
    struct __is_floating
    {
      enum { __value = 0 };
      typedef __false_type __type;
    };


  template<>
    struct __is_floating<float>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_floating<double>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_floating<long double>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };




  template<typename _Tp>
    struct __is_pointer
    {
      enum { __value = 0 };
      typedef __false_type __type;
    };

  template<typename _Tp>
    struct __is_pointer<_Tp*>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };




  template<typename _Tp>
    struct __is_normal_iterator
    {
      enum { __value = 0 };
      typedef __false_type __type;
    };

  template<typename _Iterator, typename _Container>
    struct __is_normal_iterator< __gnu_cxx::__normal_iterator<_Iterator,
             _Container> >
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };




  template<typename _Tp>
    struct __is_arithmetic
    : public __traitor<__is_integer<_Tp>, __is_floating<_Tp> >
    { };




  template<typename _Tp>
    struct __is_fundamental
    : public __traitor<__is_void<_Tp>, __is_arithmetic<_Tp> >
    { };




  template<typename _Tp>
    struct __is_scalar
    : public __traitor<__is_arithmetic<_Tp>, __is_pointer<_Tp> >
    { };




  template<typename _Tp>
    struct __is_char
    {
      enum { __value = 0 };
      typedef __false_type __type;
    };

  template<>
    struct __is_char<char>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };


  template<>
    struct __is_char<wchar_t>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };


  template<typename _Tp>
    struct __is_byte
    {
      enum { __value = 0 };
      typedef __false_type __type;
    };

  template<>
    struct __is_byte<char>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_byte<signed char>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };

  template<>
    struct __is_byte<unsigned char>
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };




  template<typename _Tp>
    struct __is_move_iterator
    {
      enum { __value = 0 };
      typedef __false_type __type;
    };


  template<typename _Iterator>
    class move_iterator;

  template<typename _Iterator>
    struct __is_move_iterator< move_iterator<_Iterator> >
    {
      enum { __value = 1 };
      typedef __true_type __type;
    };



}
# 63 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/type_traits.h" 1 3
# 32 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/type_traits.h" 3
       
# 33 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/type_traits.h" 3




namespace __gnu_cxx __attribute__ ((__visibility__ ("default")))
{



  template<bool, typename>
    struct __enable_if
    { };

  template<typename _Tp>
    struct __enable_if<true, _Tp>
    { typedef _Tp __type; };



  template<bool _Cond, typename _Iftrue, typename _Iffalse>
    struct __conditional_type
    { typedef _Iftrue __type; };

  template<typename _Iftrue, typename _Iffalse>
    struct __conditional_type<false, _Iftrue, _Iffalse>
    { typedef _Iffalse __type; };



  template<typename _Tp>
    struct __add_unsigned
    {
    private:
      typedef __enable_if<std::__is_integer<_Tp>::__value, _Tp> __if_type;

    public:
      typedef typename __if_type::__type __type;
    };

  template<>
    struct __add_unsigned<char>
    { typedef unsigned char __type; };

  template<>
    struct __add_unsigned<signed char>
    { typedef unsigned char __type; };

  template<>
    struct __add_unsigned<short>
    { typedef unsigned short __type; };

  template<>
    struct __add_unsigned<int>
    { typedef unsigned int __type; };

  template<>
    struct __add_unsigned<long>
    { typedef unsigned long __type; };

  template<>
    struct __add_unsigned<long long>
    { typedef unsigned long long __type; };


  template<>
    struct __add_unsigned<bool>;

  template<>
    struct __add_unsigned<wchar_t>;



  template<typename _Tp>
    struct __remove_unsigned
    {
    private:
      typedef __enable_if<std::__is_integer<_Tp>::__value, _Tp> __if_type;

    public:
      typedef typename __if_type::__type __type;
    };

  template<>
    struct __remove_unsigned<char>
    { typedef signed char __type; };

  template<>
    struct __remove_unsigned<unsigned char>
    { typedef signed char __type; };

  template<>
    struct __remove_unsigned<unsigned short>
    { typedef short __type; };

  template<>
    struct __remove_unsigned<unsigned int>
    { typedef int __type; };

  template<>
    struct __remove_unsigned<unsigned long>
    { typedef long __type; };

  template<>
    struct __remove_unsigned<unsigned long long>
    { typedef long long __type; };


  template<>
    struct __remove_unsigned<bool>;

  template<>
    struct __remove_unsigned<wchar_t>;



  template<typename _Type>
    inline bool
    __is_null_pointer(_Type* __ptr)
    { return __ptr == 0; }

  template<typename _Type>
    inline bool
    __is_null_pointer(_Type)
    { return false; }



  template<typename _Tp, bool = std::__is_integer<_Tp>::__value>
    struct __promote
    { typedef double __type; };

  template<typename _Tp>
    struct __promote<_Tp, false>
    { typedef _Tp __type; };

  template<typename _Tp, typename _Up>
    struct __promote_2
    {
    private:
      typedef typename __promote<_Tp>::__type __type1;
      typedef typename __promote<_Up>::__type __type2;

    public:
      typedef __typeof__(__type1() + __type2()) __type;
    };

  template<typename _Tp, typename _Up, typename _Vp>
    struct __promote_3
    {
    private:
      typedef typename __promote<_Tp>::__type __type1;
      typedef typename __promote<_Up>::__type __type2;
      typedef typename __promote<_Vp>::__type __type3;

    public:
      typedef __typeof__(__type1() + __type2() + __type3()) __type;
    };

  template<typename _Tp, typename _Up, typename _Vp, typename _Wp>
    struct __promote_4
    {
    private:
      typedef typename __promote<_Tp>::__type __type1;
      typedef typename __promote<_Up>::__type __type2;
      typedef typename __promote<_Vp>::__type __type3;
      typedef typename __promote<_Wp>::__type __type4;

    public:
      typedef __typeof__(__type1() + __type2() + __type3() + __type4()) __type;
    };


}
# 64 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/numeric_traits.h" 1 3
# 32 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/numeric_traits.h" 3
       
# 33 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/numeric_traits.h" 3




namespace __gnu_cxx __attribute__ ((__visibility__ ("default")))
{

# 54 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/numeric_traits.h" 3
  template<typename _Value>
    struct __numeric_traits_integer
    {

      static const _Value __min = (((_Value)(-1) < 0) ? (_Value)1 << (sizeof(_Value) * 8 - ((_Value)(-1) < 0)) : (_Value)0);
      static const _Value __max = (((_Value)(-1) < 0) ? (((((_Value)1 << ((sizeof(_Value) * 8 - ((_Value)(-1) < 0)) - 1)) - 1) << 1) + 1) : ~(_Value)0);



      static const bool __is_signed = ((_Value)(-1) < 0);
      static const int __digits = (sizeof(_Value) * 8 - ((_Value)(-1) < 0));
    };

  template<typename _Value>
    const _Value __numeric_traits_integer<_Value>::__min;

  template<typename _Value>
    const _Value __numeric_traits_integer<_Value>::__max;

  template<typename _Value>
    const bool __numeric_traits_integer<_Value>::__is_signed;

  template<typename _Value>
    const int __numeric_traits_integer<_Value>::__digits;
# 99 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/numeric_traits.h" 3
  template<typename _Value>
    struct __numeric_traits_floating
    {

      static const int __max_digits10 = (2 + (std::__are_same<_Value, float>::__value ? 24 : std::__are_same<_Value, double>::__value ? 53 : 64) * 643L / 2136);


      static const bool __is_signed = true;
      static const int __digits10 = (std::__are_same<_Value, float>::__value ? 6 : std::__are_same<_Value, double>::__value ? 15 : 18);
      static const int __max_exponent10 = (std::__are_same<_Value, float>::__value ? 38 : std::__are_same<_Value, double>::__value ? 308 : 4932);
    };

  template<typename _Value>
    const int __numeric_traits_floating<_Value>::__max_digits10;

  template<typename _Value>
    const bool __numeric_traits_floating<_Value>::__is_signed;

  template<typename _Value>
    const int __numeric_traits_floating<_Value>::__digits10;

  template<typename _Value>
    const int __numeric_traits_floating<_Value>::__max_exponent10;

  template<typename _Value>
    struct __numeric_traits
    : public __conditional_type<std::__is_integer<_Value>::__value,
    __numeric_traits_integer<_Value>,
    __numeric_traits_floating<_Value> >::__type
    { };


}
# 65 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_pair.h" 1 3
# 60 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_pair.h" 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/move.h" 1 3
# 34 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/move.h" 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/concept_check.h" 1 3
# 33 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/concept_check.h" 3
       
# 34 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/concept_check.h" 3
# 35 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/move.h" 2 3

namespace std __attribute__ ((__visibility__ ("default")))
{



  template<typename _Tp>
    inline _Tp*
    __addressof(_Tp& __r)
    {
      return reinterpret_cast<_Tp*>
 (&const_cast<char&>(reinterpret_cast<const volatile char&>(__r)));
    }


}


# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/type_traits" 1 3
# 32 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/type_traits" 3
       
# 33 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/type_traits" 3







namespace std __attribute__ ((__visibility__ ("default")))
{






  struct __sfinae_types
  {
    typedef char __one;
    typedef struct { char __arr[2]; } __two;
  };
# 71 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/type_traits" 3
  template<typename _Tp, _Tp __v>
    struct integral_constant
    {
      static constexpr _Tp value = __v;
      typedef _Tp value_type;
      typedef integral_constant<_Tp, __v> type;
      constexpr operator value_type() { return value; }
    };


  typedef integral_constant<bool, true> true_type;


  typedef integral_constant<bool, false> false_type;

  template<typename _Tp, _Tp __v>
    constexpr _Tp integral_constant<_Tp, __v>::value;


  template<typename>
    struct remove_cv;

  template<typename>
    struct __is_void_helper
    : public false_type { };
  template<> struct __is_void_helper<void> : public integral_constant<bool, true> { };




  template<typename _Tp>
    struct is_void
    : public integral_constant<bool, (__is_void_helper<typename
          remove_cv<_Tp>::type>::value)>
    { };

  template<typename>
    struct __is_integral_helper
    : public false_type { };
  template<> struct __is_integral_helper<bool> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<char> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<signed char> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<unsigned char> : public integral_constant<bool, true> { };

  template<> struct __is_integral_helper<wchar_t> : public integral_constant<bool, true> { };

  template<> struct __is_integral_helper<char16_t> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<char32_t> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<short> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<unsigned short> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<int> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<unsigned int> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<long> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<unsigned long> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<long long> : public integral_constant<bool, true> { };
  template<> struct __is_integral_helper<unsigned long long> : public integral_constant<bool, true> { };


  template<typename _Tp>
    struct is_integral
    : public integral_constant<bool, (__is_integral_helper<typename
          remove_cv<_Tp>::type>::value)>
    { };

  template<typename>
    struct __is_floating_point_helper
    : public false_type { };
  template<> struct __is_floating_point_helper<float> : public integral_constant<bool, true> { };
  template<> struct __is_floating_point_helper<double> : public integral_constant<bool, true> { };
  template<> struct __is_floating_point_helper<long double> : public integral_constant<bool, true> { };


  template<typename _Tp>
    struct is_floating_point
    : public integral_constant<bool, (__is_floating_point_helper<typename
          remove_cv<_Tp>::type>::value)>
    { };


  template<typename>
    struct is_array
    : public false_type { };

  template<typename _Tp, std::size_t _Size>
    struct is_array<_Tp[_Size]>
    : public true_type { };

  template<typename _Tp>
    struct is_array<_Tp[]>
    : public true_type { };

  template<typename>
    struct __is_pointer_helper
    : public false_type { };
  template<typename _Tp> struct __is_pointer_helper<_Tp*> : public integral_constant<bool, true> { };


  template<typename _Tp>
    struct is_pointer
    : public integral_constant<bool, (__is_pointer_helper<typename
          remove_cv<_Tp>::type>::value)>
    { };


  template<typename _Tp>
    struct is_reference;


  template<typename _Tp>
    struct is_function;

  template<typename>
    struct __is_member_object_pointer_helper
    : public false_type { };
 
 template<typename _Tp, typename _Cp> struct __is_member_object_pointer_helper<_Tp _Cp::*> : public integral_constant<bool, !is_function<_Tp>::value> { };


  template<typename _Tp>
    struct is_member_object_pointer
    : public integral_constant<bool, (__is_member_object_pointer_helper<
          typename remove_cv<_Tp>::type>::value)>
    { };

  template<typename>
    struct __is_member_function_pointer_helper
    : public false_type { };
 
 template<typename _Tp, typename _Cp> struct __is_member_function_pointer_helper<_Tp _Cp::*> : public integral_constant<bool, is_function<_Tp>::value> { };


  template<typename _Tp>
    struct is_member_function_pointer
    : public integral_constant<bool, (__is_member_function_pointer_helper<
          typename remove_cv<_Tp>::type>::value)>
    { };


  template<typename _Tp>
    struct is_enum
    : public integral_constant<bool, __is_enum(_Tp)>
    { };


  template<typename _Tp>
    struct is_union
    : public integral_constant<bool, __is_union(_Tp)>
    { };


  template<typename _Tp>
    struct is_class
    : public integral_constant<bool, __is_class(_Tp)>
    { };


  template<typename>
    struct is_function
    : public false_type { };
  template<typename _Res, typename... _ArgTypes>
    struct is_function<_Res(_ArgTypes...)>
    : public true_type { };
  template<typename _Res, typename... _ArgTypes>
    struct is_function<_Res(_ArgTypes......)>
    : public true_type { };
  template<typename _Res, typename... _ArgTypes>
    struct is_function<_Res(_ArgTypes...) const>
    : public true_type { };
  template<typename _Res, typename... _ArgTypes>
    struct is_function<_Res(_ArgTypes......) const>
    : public true_type { };
  template<typename _Res, typename... _ArgTypes>
    struct is_function<_Res(_ArgTypes...) volatile>
    : public true_type { };
  template<typename _Res, typename... _ArgTypes>
    struct is_function<_Res(_ArgTypes......) volatile>
    : public true_type { };
  template<typename _Res, typename... _ArgTypes>
    struct is_function<_Res(_ArgTypes...) const volatile>
    : public true_type { };
  template<typename _Res, typename... _ArgTypes>
    struct is_function<_Res(_ArgTypes......) const volatile>
    : public true_type { };

  template<typename>
    struct __is_nullptr_t_helper
    : public false_type { };
  template<> struct __is_nullptr_t_helper<std::nullptr_t> : public integral_constant<bool, true> { };


  template<typename _Tp>
    struct __is_nullptr_t
    : public integral_constant<bool, (__is_nullptr_t_helper<typename
          remove_cv<_Tp>::type>::value)>
    { };




  template<typename _Tp>
    struct is_arithmetic
    : public integral_constant<bool, (is_integral<_Tp>::value
          || is_floating_point<_Tp>::value)>
    { };


  template<typename _Tp>
    struct is_fundamental
    : public integral_constant<bool, (is_arithmetic<_Tp>::value
          || is_void<_Tp>::value)>
    { };


  template<typename _Tp>
    struct is_object
    : public integral_constant<bool, !(is_function<_Tp>::value
           || is_reference<_Tp>::value
           || is_void<_Tp>::value)>
    { };


  template<typename _Tp>
    struct is_member_pointer;


  template<typename _Tp>
    struct is_scalar
    : public integral_constant<bool, (is_arithmetic<_Tp>::value
          || is_enum<_Tp>::value
          || is_pointer<_Tp>::value
          || is_member_pointer<_Tp>::value
          || __is_nullptr_t<_Tp>::value)>
    { };


  template<typename _Tp>
    struct is_compound
    : public integral_constant<bool, !is_fundamental<_Tp>::value> { };


  template<typename _Tp>
    struct __is_member_pointer_helper
    : public false_type { };
  template<typename _Tp, typename _Cp> struct __is_member_pointer_helper<_Tp _Cp::*> : public integral_constant<bool, true> { };

  template<typename _Tp>
  struct is_member_pointer
    : public integral_constant<bool, (__is_member_pointer_helper<
          typename remove_cv<_Tp>::type>::value)>
    { };



  template<typename>
    struct is_const
    : public false_type { };

  template<typename _Tp>
    struct is_const<_Tp const>
    : public true_type { };


  template<typename>
    struct is_volatile
    : public false_type { };

  template<typename _Tp>
    struct is_volatile<_Tp volatile>
    : public true_type { };


  template<typename _Tp>
    struct is_empty
    : public integral_constant<bool, __is_empty(_Tp)>
    { };


  template<typename _Tp>
    struct is_polymorphic
    : public integral_constant<bool, __is_polymorphic(_Tp)>
    { };


  template<typename _Tp>
    struct is_abstract
    : public integral_constant<bool, __is_abstract(_Tp)>
    { };


  template<typename _Tp>
    struct has_virtual_destructor
    : public integral_constant<bool, __has_virtual_destructor(_Tp)>
    { };


  template<typename _Tp>
    struct alignment_of
    : public integral_constant<std::size_t, __alignof__(_Tp)> { };


  template<typename>
    struct rank
    : public integral_constant<std::size_t, 0> { };

  template<typename _Tp, std::size_t _Size>
    struct rank<_Tp[_Size]>
    : public integral_constant<std::size_t, 1 + rank<_Tp>::value> { };

  template<typename _Tp>
    struct rank<_Tp[]>
    : public integral_constant<std::size_t, 1 + rank<_Tp>::value> { };


  template<typename, unsigned _Uint = 0>
    struct extent
    : public integral_constant<std::size_t, 0> { };

  template<typename _Tp, unsigned _Uint, std::size_t _Size>
    struct extent<_Tp[_Size], _Uint>
    : public integral_constant<std::size_t,
          _Uint == 0 ? _Size : extent<_Tp,
          _Uint - 1>::value>
    { };

  template<typename _Tp, unsigned _Uint>
    struct extent<_Tp[], _Uint>
    : public integral_constant<std::size_t,
          _Uint == 0 ? 0 : extent<_Tp,
             _Uint - 1>::value>
    { };




  template<typename, typename>
    struct is_same
    : public false_type { };

  template<typename _Tp>
    struct is_same<_Tp, _Tp>
    : public true_type { };




  template<typename _Tp>
    struct remove_const
    { typedef _Tp type; };

  template<typename _Tp>
    struct remove_const<_Tp const>
    { typedef _Tp type; };


  template<typename _Tp>
    struct remove_volatile
    { typedef _Tp type; };

  template<typename _Tp>
    struct remove_volatile<_Tp volatile>
    { typedef _Tp type; };


  template<typename _Tp>
    struct remove_cv
    {
      typedef typename
      remove_const<typename remove_volatile<_Tp>::type>::type type;
    };


  template<typename _Tp>
    struct add_const
    { typedef _Tp const type; };


  template<typename _Tp>
    struct add_volatile
    { typedef _Tp volatile type; };


  template<typename _Tp>
    struct add_cv
    {
      typedef typename
      add_const<typename add_volatile<_Tp>::type>::type type;
    };




  template<typename _Tp>
    struct remove_extent
    { typedef _Tp type; };

  template<typename _Tp, std::size_t _Size>
    struct remove_extent<_Tp[_Size]>
    { typedef _Tp type; };

  template<typename _Tp>
    struct remove_extent<_Tp[]>
    { typedef _Tp type; };


  template<typename _Tp>
    struct remove_all_extents
    { typedef _Tp type; };

  template<typename _Tp, std::size_t _Size>
    struct remove_all_extents<_Tp[_Size]>
    { typedef typename remove_all_extents<_Tp>::type type; };

  template<typename _Tp>
    struct remove_all_extents<_Tp[]>
    { typedef typename remove_all_extents<_Tp>::type type; };



  template<typename _Tp, typename>
    struct __remove_pointer_helper
    { typedef _Tp type; };

  template<typename _Tp, typename _Up>
    struct __remove_pointer_helper<_Tp, _Up*>
    { typedef _Up type; };


  template<typename _Tp>
    struct remove_pointer
    : public __remove_pointer_helper<_Tp, typename remove_cv<_Tp>::type>
    { };

  template<typename>
    struct remove_reference;


  template<typename _Tp>
    struct add_pointer
    { typedef typename remove_reference<_Tp>::type* type; };




  template<typename>
    struct is_lvalue_reference
    : public false_type { };

  template<typename _Tp>
    struct is_lvalue_reference<_Tp&>
    : public true_type { };


  template<typename>
    struct is_rvalue_reference
    : public false_type { };

  template<typename _Tp>
    struct is_rvalue_reference<_Tp&&>
    : public true_type { };




  template<typename _Tp>
    struct is_reference
    : public integral_constant<bool, (is_lvalue_reference<_Tp>::value
          || is_rvalue_reference<_Tp>::value)>
    { };




  template<typename _Tp>
    struct remove_reference
    { typedef _Tp type; };

  template<typename _Tp>
    struct remove_reference<_Tp&>
    { typedef _Tp type; };

  template<typename _Tp>
    struct remove_reference<_Tp&&>
    { typedef _Tp type; };

  template<typename _Tp,
    bool = !is_reference<_Tp>::value && !is_void<_Tp>::value,
    bool = is_rvalue_reference<_Tp>::value>
    struct __add_lvalue_reference_helper
    { typedef _Tp type; };

  template<typename _Tp>
    struct __add_lvalue_reference_helper<_Tp, true, false>
    { typedef _Tp& type; };

  template<typename _Tp>
    struct __add_lvalue_reference_helper<_Tp, false, true>
    { typedef typename remove_reference<_Tp>::type& type; };


  template<typename _Tp>
    struct add_lvalue_reference
    : public __add_lvalue_reference_helper<_Tp>
    { };

  template<typename _Tp,
    bool = !is_reference<_Tp>::value && !is_void<_Tp>::value>
    struct __add_rvalue_reference_helper
    { typedef _Tp type; };

  template<typename _Tp>
    struct __add_rvalue_reference_helper<_Tp, true>
    { typedef _Tp&& type; };


  template<typename _Tp>
    struct add_rvalue_reference
    : public __add_rvalue_reference_helper<_Tp>
    { };



  template<typename _Tp,
    bool = is_integral<_Tp>::value,
    bool = is_floating_point<_Tp>::value>
    struct __is_signed_helper
    : public false_type { };

  template<typename _Tp>
    struct __is_signed_helper<_Tp, false, true>
    : public true_type { };

  template<typename _Tp>
    struct __is_signed_helper<_Tp, true, false>
    : public integral_constant<bool, static_cast<bool>(_Tp(-1) < _Tp(0))>
    { };


  template<typename _Tp>
    struct is_signed
    : public integral_constant<bool, __is_signed_helper<_Tp>::value>
    { };


  template<typename _Tp>
    struct is_unsigned
    : public integral_constant<bool, (is_arithmetic<_Tp>::value
          && !is_signed<_Tp>::value)>
    { };




  template<typename _Tp>
    struct is_trivial
    : public integral_constant<bool, __is_trivial(_Tp)>
    { };


  template<typename _Tp>
    struct is_standard_layout
    : public integral_constant<bool, __is_standard_layout(_Tp)>
    { };



  template<typename _Tp>
    struct is_pod
    : public integral_constant<bool, __is_pod(_Tp)>
    { };


  template<typename _Tp>
    struct is_literal_type
    : public integral_constant<bool, __is_literal_type(_Tp)>
    { };

  template<typename _Tp>
    typename add_rvalue_reference<_Tp>::type declval() noexcept;

  template<typename _Tp, typename... _Args>
    class __is_constructible_helper
    : public __sfinae_types
    {
      template<typename _Tp1, typename... _Args1>
        static decltype(_Tp1(declval<_Args1>()...), __one()) __test(int);

      template<typename, typename...>
        static __two __test(...);

    public:
      static const bool __value = sizeof(__test<_Tp, _Args...>(0)) == 1;
    };

  template<typename _Tp, typename _Arg>
    class __is_constructible_helper<_Tp, _Arg>
    : public __sfinae_types
    {
      template<typename _Tp1, typename _Arg1>
        static decltype(static_cast<_Tp1>(declval<_Arg1>()), __one())
 __test(int);

      template<typename, typename>
        static __two __test(...);

    public:
      static const bool __value = sizeof(__test<_Tp, _Arg>(0)) == 1;
    };




  template<typename _Tp, typename... _Args>
    struct is_constructible
    : public integral_constant<bool,
          __is_constructible_helper<_Tp,
        _Args...>::__value>
    { };

  template<bool, typename _Tp, typename... _Args>
    struct __is_nt_constructible_helper
    { static const bool __value = false; };

  template<typename _Tp, typename... _Args>
    struct __is_nt_constructible_helper<true, _Tp, _Args...>
    { static const bool __value = noexcept(_Tp(declval<_Args>()...)); };

  template<typename _Tp, typename _Arg>
    struct __is_nt_constructible_helper<true, _Tp, _Arg>
    {
      static const bool __value = noexcept(static_cast<_Tp>(declval<_Arg>()));
    };


  template<typename _Tp, typename... _Args>
    struct is_nothrow_constructible
    : public integral_constant<bool,
   __is_nt_constructible_helper<is_constructible<_Tp, _Args...>::value,
           _Tp, _Args...>::__value>
    { };


  template<typename _Tp>
    struct has_trivial_default_constructor
    : public integral_constant<bool, __has_trivial_constructor(_Tp)>
    { };


  template<typename _Tp>
    struct has_trivial_copy_constructor
    : public integral_constant<bool, __has_trivial_copy(_Tp)>
    { };


  template<typename _Tp>
    struct has_trivial_copy_assign
    : public integral_constant<bool, __has_trivial_assign(_Tp)>
    { };


  template<typename _Tp>
    struct has_trivial_destructor
    : public integral_constant<bool, __has_trivial_destructor(_Tp)>
    { };


  template<typename _Tp>
    struct has_nothrow_default_constructor
    : public integral_constant<bool, __has_nothrow_constructor(_Tp)>
    { };


  template<typename _Tp>
    struct has_nothrow_copy_constructor
    : public integral_constant<bool, __has_nothrow_copy(_Tp)>
    { };


  template<typename _Tp>
    struct has_nothrow_copy_assign
    : public integral_constant<bool, __has_nothrow_assign(_Tp)>
    { };




  template<typename _Base, typename _Derived>
    struct is_base_of
    : public integral_constant<bool, __is_base_of(_Base, _Derived)>
    { };

  template<typename _From, typename _To,
    bool = (is_void<_From>::value || is_function<_To>::value
     || is_array<_To>::value)>
    struct __is_convertible_helper
    { static const bool __value = is_void<_To>::value; };

  template<typename _From, typename _To>
    class __is_convertible_helper<_From, _To, false>
    : public __sfinae_types
    {
      template<typename _To1>
        static void __test_aux(_To1);

      template<typename _From1, typename _To1>
        static decltype(__test_aux<_To1>(std::declval<_From1>()), __one())
 __test(int);

      template<typename, typename>
        static __two __test(...);

    public:
      static const bool __value = sizeof(__test<_From, _To>(0)) == 1;
    };




  template<typename _From, typename _To>
    struct is_convertible
    : public integral_constant<bool,
          __is_convertible_helper<_From, _To>::__value>
    { };


  template<typename _From, typename _To>
    struct is_explicitly_convertible
    : public is_constructible<_To, _From>
    { };

  template<std::size_t _Len>
    struct __aligned_storage_msa
    {
      union __type
      {
 unsigned char __data[_Len];
 struct __attribute__((__aligned__)) { } __align;
      };
    };
# 820 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/type_traits" 3
  template<std::size_t _Len, std::size_t _Align =
    __alignof__(typename __aligned_storage_msa<_Len>::__type)>
    struct aligned_storage
    {
      union type
      {
 unsigned char __data[_Len];
 struct __attribute__((__aligned__((_Align)))) { } __align;
      };
    };





  template<bool, typename _Tp = void>
    struct enable_if
    { };


  template<typename _Tp>
    struct enable_if<true, _Tp>
    { typedef _Tp type; };





  template<bool _Cond, typename _Iftrue, typename _Iffalse>
    struct conditional
    { typedef _Iftrue type; };


  template<typename _Iftrue, typename _Iffalse>
    struct conditional<false, _Iftrue, _Iffalse>
    { typedef _Iffalse type; };




  template<typename _Up,
    bool _IsArray = is_array<_Up>::value,
    bool _IsFunction = is_function<_Up>::value>
    struct __decay_selector;


  template<typename _Up>
    struct __decay_selector<_Up, false, false>
    { typedef typename remove_cv<_Up>::type __type; };

  template<typename _Up>
    struct __decay_selector<_Up, true, false>
    { typedef typename remove_extent<_Up>::type* __type; };

  template<typename _Up>
    struct __decay_selector<_Up, false, true>
    { typedef typename add_pointer<_Up>::type __type; };


  template<typename _Tp>
    class decay
    {
      typedef typename remove_reference<_Tp>::type __remove_type;

    public:
      typedef typename __decay_selector<__remove_type>::__type type;
    };

  template<typename _Tp>
    class reference_wrapper;


  template<typename _Tp>
    struct __strip_reference_wrapper
    {
      typedef _Tp __type;
    };

  template<typename _Tp>
    struct __strip_reference_wrapper<reference_wrapper<_Tp> >
    {
      typedef _Tp& __type;
    };

  template<typename _Tp>
    struct __strip_reference_wrapper<const reference_wrapper<_Tp> >
    {
      typedef _Tp& __type;
    };

  template<typename _Tp>
    struct __decay_and_strip
    {
      typedef typename __strip_reference_wrapper<
 typename decay<_Tp>::type>::__type __type;
    };



  template<typename _Unqualified, bool _IsConst, bool _IsVol>
    struct __cv_selector;

  template<typename _Unqualified>
    struct __cv_selector<_Unqualified, false, false>
    { typedef _Unqualified __type; };

  template<typename _Unqualified>
    struct __cv_selector<_Unqualified, false, true>
    { typedef volatile _Unqualified __type; };

  template<typename _Unqualified>
    struct __cv_selector<_Unqualified, true, false>
    { typedef const _Unqualified __type; };

  template<typename _Unqualified>
    struct __cv_selector<_Unqualified, true, true>
    { typedef const volatile _Unqualified __type; };

  template<typename _Qualified, typename _Unqualified,
    bool _IsConst = is_const<_Qualified>::value,
    bool _IsVol = is_volatile<_Qualified>::value>
    class __match_cv_qualifiers
    {
      typedef __cv_selector<_Unqualified, _IsConst, _IsVol> __match;

    public:
      typedef typename __match::__type __type;
    };



  template<typename _Tp>
    struct __make_unsigned
    { typedef _Tp __type; };

  template<>
    struct __make_unsigned<char>
    { typedef unsigned char __type; };

  template<>
    struct __make_unsigned<signed char>
    { typedef unsigned char __type; };

  template<>
    struct __make_unsigned<short>
    { typedef unsigned short __type; };

  template<>
    struct __make_unsigned<int>
    { typedef unsigned int __type; };

  template<>
    struct __make_unsigned<long>
    { typedef unsigned long __type; };

  template<>
    struct __make_unsigned<long long>
    { typedef unsigned long long __type; };



  template<typename _Tp,
    bool _IsInt = is_integral<_Tp>::value,
    bool _IsEnum = is_enum<_Tp>::value>
    class __make_unsigned_selector;

  template<typename _Tp>
    class __make_unsigned_selector<_Tp, true, false>
    {
      typedef __make_unsigned<typename remove_cv<_Tp>::type> __unsignedt;
      typedef typename __unsignedt::__type __unsigned_type;
      typedef __match_cv_qualifiers<_Tp, __unsigned_type> __cv_unsigned;

    public:
      typedef typename __cv_unsigned::__type __type;
    };

  template<typename _Tp>
    class __make_unsigned_selector<_Tp, false, true>
    {

      typedef unsigned char __smallest;
      static const bool __b0 = sizeof(_Tp) <= sizeof(__smallest);
      static const bool __b1 = sizeof(_Tp) <= sizeof(unsigned short);
      static const bool __b2 = sizeof(_Tp) <= sizeof(unsigned int);
      typedef conditional<__b2, unsigned int, unsigned long> __cond2;
      typedef typename __cond2::type __cond2_type;
      typedef conditional<__b1, unsigned short, __cond2_type> __cond1;
      typedef typename __cond1::type __cond1_type;

    public:
      typedef typename conditional<__b0, __smallest, __cond1_type>::type __type;
    };





  template<typename _Tp>
    struct make_unsigned
    { typedef typename __make_unsigned_selector<_Tp>::__type type; };


  template<>
    struct make_unsigned<bool>;



  template<typename _Tp>
    struct __make_signed
    { typedef _Tp __type; };

  template<>
    struct __make_signed<char>
    { typedef signed char __type; };

  template<>
    struct __make_signed<unsigned char>
    { typedef signed char __type; };

  template<>
    struct __make_signed<unsigned short>
    { typedef signed short __type; };

  template<>
    struct __make_signed<unsigned int>
    { typedef signed int __type; };

  template<>
    struct __make_signed<unsigned long>
    { typedef signed long __type; };

  template<>
    struct __make_signed<unsigned long long>
    { typedef signed long long __type; };



  template<typename _Tp,
    bool _IsInt = is_integral<_Tp>::value,
    bool _IsEnum = is_enum<_Tp>::value>
    class __make_signed_selector;

  template<typename _Tp>
    class __make_signed_selector<_Tp, true, false>
    {
      typedef __make_signed<typename remove_cv<_Tp>::type> __signedt;
      typedef typename __signedt::__type __signed_type;
      typedef __match_cv_qualifiers<_Tp, __signed_type> __cv_signed;

    public:
      typedef typename __cv_signed::__type __type;
    };

  template<typename _Tp>
    class __make_signed_selector<_Tp, false, true>
    {

      typedef signed char __smallest;
      static const bool __b0 = sizeof(_Tp) <= sizeof(__smallest);
      static const bool __b1 = sizeof(_Tp) <= sizeof(signed short);
      static const bool __b2 = sizeof(_Tp) <= sizeof(signed int);
      typedef conditional<__b2, signed int, signed long> __cond2;
      typedef typename __cond2::type __cond2_type;
      typedef conditional<__b1, signed short, __cond2_type> __cond1;
      typedef typename __cond1::type __cond1_type;

    public:
      typedef typename conditional<__b0, __smallest, __cond1_type>::type __type;
    };





  template<typename _Tp>
    struct make_signed
    { typedef typename __make_signed_selector<_Tp>::__type type; };


  template<>
    struct make_signed<bool>;


  template<typename... _Tp>
    struct common_type;

  template<typename _Tp>
    struct common_type<_Tp>
    { typedef _Tp type; };

  template<typename _Tp, typename _Up>
    struct common_type<_Tp, _Up>
    { typedef decltype(true ? declval<_Tp>() : declval<_Up>()) type; };

  template<typename _Tp, typename _Up, typename... _Vp>
    struct common_type<_Tp, _Up, _Vp...>
    {
      typedef typename
        common_type<typename common_type<_Tp, _Up>::type, _Vp...>::type type;
    };


  template<typename _Tp>
    struct __declval_protector
    {
      static const bool __stop = false;
      static typename add_rvalue_reference<_Tp>::type __delegate();
    };

  template<typename _Tp>
    inline typename add_rvalue_reference<_Tp>::type
    declval() noexcept
    {
      static_assert(__declval_protector<_Tp>::__stop,
      "declval() must not be used!");
      return __declval_protector<_Tp>::__delegate();
    }


  template<typename _Signature>
    class result_of;

  template<typename _Functor, typename... _ArgTypes>
    struct result_of<_Functor(_ArgTypes...)>
    {
      typedef
        decltype( std::declval<_Functor>()(std::declval<_ArgTypes>()...) )
        type;
    };
# 1186 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/type_traits" 3

}
# 54 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/move.h" 2 3

namespace std __attribute__ ((__visibility__ ("default")))
{



  template<typename _Tp>
    inline _Tp&&
    forward(typename std::remove_reference<_Tp>::type& __t)
    { return static_cast<_Tp&&>(__t); }

  template<typename _Tp>
    inline _Tp&&
    forward(typename std::remove_reference<_Tp>::type&& __t)
    {
      static_assert(!std::is_lvalue_reference<_Tp>::value, "template argument"
      " substituting _Tp is an lvalue reference type");
      return static_cast<_Tp&&>(__t);
    }







  template<typename _Tp>
    inline typename std::remove_reference<_Tp>::type&&
    move(_Tp&& __t)
    { return static_cast<typename std::remove_reference<_Tp>::type&&>(__t); }
# 94 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/move.h" 3
  template<typename _Tp>
    inline _Tp*
    addressof(_Tp& __r)
    { return std::__addressof(__r); }


}
# 109 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/move.h" 3
namespace std __attribute__ ((__visibility__ ("default")))
{

# 120 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/move.h" 3
  template<typename _Tp>
    inline void
    swap(_Tp& __a, _Tp& __b)
    {

     

      _Tp __tmp = std::move(__a);
      __a = std::move(__b);
      __b = std::move(__tmp);
    }



  template<typename _Tp, size_t _Nm>
    inline void
    swap(_Tp (&__a)[_Nm], _Tp (&__b)[_Nm])
    {
      for (size_t __n = 0; __n < _Nm; ++__n)
 swap(__a[__n], __b[__n]);
    }


}
# 61 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_pair.h" 2 3





namespace std __attribute__ ((__visibility__ ("default")))
{




  struct piecewise_construct_t { };


  constexpr piecewise_construct_t piecewise_construct = piecewise_construct_t();


  template<typename...>
    class tuple;

  template<int...>
    struct _Index_tuple;



  template<class _T1, class _T2>
    struct pair
    {
      typedef _T1 first_type;
      typedef _T2 second_type;

      _T1 first;
      _T2 second;





      constexpr pair()
      : first(), second() { }


      constexpr pair(const _T1& __a, const _T2& __b)
      : first(__a), second(__b) { }


      template<class _U1, class _U2>
 constexpr pair(const pair<_U1, _U2>& __p)
 : first(__p.first), second(__p.second) { }


      constexpr pair(const pair&) = default;





      template<class _U1, class = typename
        std::enable_if<std::is_convertible<_U1, _T1>::value>::type>
 pair(_U1&& __x, const _T2& __y)
 : first(std::forward<_U1>(__x)), second(__y) { }

      template<class _U2, class = typename
        std::enable_if<std::is_convertible<_U2, _T2>::value>::type>
 pair(const _T1& __x, _U2&& __y)
 : first(__x), second(std::forward<_U2>(__y)) { }

      template<class _U1, class _U2, class = typename
        std::enable_if<std::is_convertible<_U1, _T1>::value
         && std::is_convertible<_U2, _T2>::value>::type>
 pair(_U1&& __x, _U2&& __y)
 : first(std::forward<_U1>(__x)), second(std::forward<_U2>(__y)) { }

      template<class _U1, class _U2>
 pair(pair<_U1, _U2>&& __p)
 : first(std::forward<_U1>(__p.first)),
   second(std::forward<_U2>(__p.second)) { }

      template<class... _Args1, class... _Args2>
 pair(piecewise_construct_t,
      tuple<_Args1...> __first, tuple<_Args2...> __second)
 : first(__cons<first_type>(std::move(__first))),
   second(__cons<second_type>(std::move(__second))) { }

      pair&
      operator=(const pair& __p)
      {
 first = __p.first;
 second = __p.second;
 return *this;
      }

      pair&
      operator=(pair&& __p)
      {
 first = std::move(__p.first);
 second = std::move(__p.second);
 return *this;
      }

      template<class _U1, class _U2>
 pair&
 operator=(const pair<_U1, _U2>& __p)
 {
   first = __p.first;
   second = __p.second;
   return *this;
 }

      template<class _U1, class _U2>
 pair&
 operator=(pair<_U1, _U2>&& __p)
 {
   first = std::move(__p.first);
   second = std::move(__p.second);
   return *this;
 }

      void
      swap(pair& __p)
      {
 using std::swap;
 swap(first, __p.first);
 swap(second, __p.second);
      }

    private:
      template<typename _Tp, typename... _Args>
 static _Tp
 __cons(tuple<_Args...>&&);

      template<typename _Tp, typename... _Args, int... _Indexes>
 static _Tp
 __do_cons(tuple<_Args...>&&, const _Index_tuple<_Indexes...>&);

    };


  template<class _T1, class _T2>
    inline constexpr bool
    operator==(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y)
    { return __x.first == __y.first && __x.second == __y.second; }


  template<class _T1, class _T2>
    inline constexpr bool
    operator<(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y)
    { return __x.first < __y.first
      || (!(__y.first < __x.first) && __x.second < __y.second); }


  template<class _T1, class _T2>
    inline constexpr bool
    operator!=(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y)
    { return !(__x == __y); }


  template<class _T1, class _T2>
    inline constexpr bool
    operator>(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y)
    { return __y < __x; }


  template<class _T1, class _T2>
    inline constexpr bool
    operator<=(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y)
    { return !(__y < __x); }


  template<class _T1, class _T2>
    inline constexpr bool
    operator>=(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y)
    { return !(__x < __y); }





  template<class _T1, class _T2>
    inline void
    swap(pair<_T1, _T2>& __x, pair<_T1, _T2>& __y)
    { __x.swap(__y); }
# 259 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_pair.h" 3
  template<class _T1, class _T2>
    inline pair<typename __decay_and_strip<_T1>::__type,
  typename __decay_and_strip<_T2>::__type>
    make_pair(_T1&& __x, _T2&& __y)
    {
      typedef typename __decay_and_strip<_T1>::__type __ds_type1;
      typedef typename __decay_and_strip<_T2>::__type __ds_type2;
      typedef pair<__ds_type1, __ds_type2> __pair_type;
      return __pair_type(std::forward<_T1>(__x), std::forward<_T2>(__y));
    }








}
# 66 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_types.h" 1 3
# 63 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_types.h" 3
       
# 64 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_types.h" 3







namespace std __attribute__ ((__visibility__ ("default")))
{

# 90 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_types.h" 3
  struct input_iterator_tag { };


  struct output_iterator_tag { };


  struct forward_iterator_tag : public input_iterator_tag { };



  struct bidirectional_iterator_tag : public forward_iterator_tag { };



  struct random_access_iterator_tag : public bidirectional_iterator_tag { };
# 117 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_types.h" 3
  template<typename _Category, typename _Tp, typename _Distance = ptrdiff_t,
           typename _Pointer = _Tp*, typename _Reference = _Tp&>
    struct iterator
    {

      typedef _Category iterator_category;

      typedef _Tp value_type;

      typedef _Distance difference_type;

      typedef _Pointer pointer;

      typedef _Reference reference;
    };
# 143 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_types.h" 3
template<typename _Tp> class __has_iterator_category_helper : __sfinae_types { template<typename _Up> struct _Wrap_type { }; template<typename _Up> static __one __test(_Wrap_type<typename _Up::iterator_category>*); template<typename _Up> static __two __test(...); public: static const bool value = sizeof(__test<_Tp>(0)) == 1; }; template<typename _Tp> struct __has_iterator_category : integral_constant<bool, __has_iterator_category_helper <typename remove_cv<_Tp>::type>::value> { };

  template<typename _Iterator,
    bool = __has_iterator_category<_Iterator>::value>
    struct __iterator_traits { };

  template<typename _Iterator>
    struct __iterator_traits<_Iterator, true>
    {
      typedef typename _Iterator::iterator_category iterator_category;
      typedef typename _Iterator::value_type value_type;
      typedef typename _Iterator::difference_type difference_type;
      typedef typename _Iterator::pointer pointer;
      typedef typename _Iterator::reference reference;
    };

  template<typename _Iterator>
    struct iterator_traits
    : public __iterator_traits<_Iterator> { };
# 175 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_types.h" 3
  template<typename _Tp>
    struct iterator_traits<_Tp*>
    {
      typedef random_access_iterator_tag iterator_category;
      typedef _Tp value_type;
      typedef ptrdiff_t difference_type;
      typedef _Tp* pointer;
      typedef _Tp& reference;
    };


  template<typename _Tp>
    struct iterator_traits<const _Tp*>
    {
      typedef random_access_iterator_tag iterator_category;
      typedef _Tp value_type;
      typedef ptrdiff_t difference_type;
      typedef const _Tp* pointer;
      typedef const _Tp& reference;
    };





  template<typename _Iter>
    inline typename iterator_traits<_Iter>::iterator_category
    __iterator_category(const _Iter&)
    { return typename iterator_traits<_Iter>::iterator_category(); }





  template<typename _Iterator, bool _HasBase>
    struct _Iter_base
    {
      typedef _Iterator iterator_type;
      static iterator_type _S_base(_Iterator __it)
      { return __it; }
    };

  template<typename _Iterator>
    struct _Iter_base<_Iterator, true>
    {
      typedef typename _Iterator::iterator_type iterator_type;
      static iterator_type _S_base(_Iterator __it)
      { return __it.base(); }
    };


}
# 67 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_funcs.h" 1 3
# 63 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_funcs.h" 3
       
# 64 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_funcs.h" 3



namespace std __attribute__ ((__visibility__ ("default")))
{


  template<typename _InputIterator>
    inline typename iterator_traits<_InputIterator>::difference_type
    __distance(_InputIterator __first, _InputIterator __last,
               input_iterator_tag)
    {

     

      typename iterator_traits<_InputIterator>::difference_type __n = 0;
      while (__first != __last)
 {
   ++__first;
   ++__n;
 }
      return __n;
    }

  template<typename _RandomAccessIterator>
    inline typename iterator_traits<_RandomAccessIterator>::difference_type
    __distance(_RandomAccessIterator __first, _RandomAccessIterator __last,
               random_access_iterator_tag)
    {

     

      return __last - __first;
    }
# 111 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_funcs.h" 3
  template<typename _InputIterator>
    inline typename iterator_traits<_InputIterator>::difference_type
    distance(_InputIterator __first, _InputIterator __last)
    {

      return std::__distance(__first, __last,
        std::__iterator_category(__first));
    }

  template<typename _InputIterator, typename _Distance>
    inline void
    __advance(_InputIterator& __i, _Distance __n, input_iterator_tag)
    {

     
      while (__n--)
 ++__i;
    }

  template<typename _BidirectionalIterator, typename _Distance>
    inline void
    __advance(_BidirectionalIterator& __i, _Distance __n,
       bidirectional_iterator_tag)
    {

     

      if (__n > 0)
        while (__n--)
   ++__i;
      else
        while (__n++)
   --__i;
    }

  template<typename _RandomAccessIterator, typename _Distance>
    inline void
    __advance(_RandomAccessIterator& __i, _Distance __n,
              random_access_iterator_tag)
    {

     

      __i += __n;
    }
# 169 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator_base_funcs.h" 3
  template<typename _InputIterator, typename _Distance>
    inline void
    advance(_InputIterator& __i, _Distance __n)
    {

      typename iterator_traits<_InputIterator>::difference_type __d = __n;
      std::__advance(__i, __d, std::__iterator_category(__i));
    }



  template<typename _ForwardIterator>
    inline _ForwardIterator
    next(_ForwardIterator __x, typename
  iterator_traits<_ForwardIterator>::difference_type __n = 1)
    {
      std::advance(__x, __n);
      return __x;
    }

  template<typename _BidirectionalIterator>
    inline _BidirectionalIterator
    prev(_BidirectionalIterator __x, typename
  iterator_traits<_BidirectionalIterator>::difference_type __n = 1)
    {
      std::advance(__x, -__n);
      return __x;
    }




}
# 68 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 1 3
# 68 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
namespace std __attribute__ ((__visibility__ ("default")))
{

# 96 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
  template<typename _Iterator>
    class reverse_iterator
    : public iterator<typename iterator_traits<_Iterator>::iterator_category,
        typename iterator_traits<_Iterator>::value_type,
        typename iterator_traits<_Iterator>::difference_type,
        typename iterator_traits<_Iterator>::pointer,
                      typename iterator_traits<_Iterator>::reference>
    {
    protected:
      _Iterator current;

      typedef iterator_traits<_Iterator> __traits_type;

    public:
      typedef _Iterator iterator_type;
      typedef typename __traits_type::difference_type difference_type;
      typedef typename __traits_type::pointer pointer;
      typedef typename __traits_type::reference reference;







      reverse_iterator() : current() { }




      explicit
      reverse_iterator(iterator_type __x) : current(__x) { }




      reverse_iterator(const reverse_iterator& __x)
      : current(__x.current) { }





      template<typename _Iter>
        reverse_iterator(const reverse_iterator<_Iter>& __x)
 : current(__x.base()) { }




      iterator_type
      base() const
      { return current; }






      reference
      operator*() const
      {
 _Iterator __tmp = current;
 return *--__tmp;
      }






      pointer
      operator->() const
      { return &(operator*()); }






      reverse_iterator&
      operator++()
      {
 --current;
 return *this;
      }






      reverse_iterator
      operator++(int)
      {
 reverse_iterator __tmp = *this;
 --current;
 return __tmp;
      }






      reverse_iterator&
      operator--()
      {
 ++current;
 return *this;
      }






      reverse_iterator
      operator--(int)
      {
 reverse_iterator __tmp = *this;
 ++current;
 return __tmp;
      }






      reverse_iterator
      operator+(difference_type __n) const
      { return reverse_iterator(current - __n); }






      reverse_iterator&
      operator+=(difference_type __n)
      {
 current -= __n;
 return *this;
      }






      reverse_iterator
      operator-(difference_type __n) const
      { return reverse_iterator(current + __n); }






      reverse_iterator&
      operator-=(difference_type __n)
      {
 current += __n;
 return *this;
      }






      reference
      operator[](difference_type __n) const
      { return *(*this + __n); }
    };
# 283 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
  template<typename _Iterator>
    inline bool
    operator==(const reverse_iterator<_Iterator>& __x,
        const reverse_iterator<_Iterator>& __y)
    { return __x.base() == __y.base(); }

  template<typename _Iterator>
    inline bool
    operator<(const reverse_iterator<_Iterator>& __x,
       const reverse_iterator<_Iterator>& __y)
    { return __y.base() < __x.base(); }

  template<typename _Iterator>
    inline bool
    operator!=(const reverse_iterator<_Iterator>& __x,
        const reverse_iterator<_Iterator>& __y)
    { return !(__x == __y); }

  template<typename _Iterator>
    inline bool
    operator>(const reverse_iterator<_Iterator>& __x,
       const reverse_iterator<_Iterator>& __y)
    { return __y < __x; }

  template<typename _Iterator>
    inline bool
    operator<=(const reverse_iterator<_Iterator>& __x,
        const reverse_iterator<_Iterator>& __y)
    { return !(__y < __x); }

  template<typename _Iterator>
    inline bool
    operator>=(const reverse_iterator<_Iterator>& __x,
        const reverse_iterator<_Iterator>& __y)
    { return !(__x < __y); }

  template<typename _Iterator>
    inline typename reverse_iterator<_Iterator>::difference_type
    operator-(const reverse_iterator<_Iterator>& __x,
       const reverse_iterator<_Iterator>& __y)
    { return __y.base() - __x.base(); }

  template<typename _Iterator>
    inline reverse_iterator<_Iterator>
    operator+(typename reverse_iterator<_Iterator>::difference_type __n,
       const reverse_iterator<_Iterator>& __x)
    { return reverse_iterator<_Iterator>(__x.base() - __n); }



  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator==(const reverse_iterator<_IteratorL>& __x,
        const reverse_iterator<_IteratorR>& __y)
    { return __x.base() == __y.base(); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator<(const reverse_iterator<_IteratorL>& __x,
       const reverse_iterator<_IteratorR>& __y)
    { return __y.base() < __x.base(); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator!=(const reverse_iterator<_IteratorL>& __x,
        const reverse_iterator<_IteratorR>& __y)
    { return !(__x == __y); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator>(const reverse_iterator<_IteratorL>& __x,
       const reverse_iterator<_IteratorR>& __y)
    { return __y < __x; }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator<=(const reverse_iterator<_IteratorL>& __x,
        const reverse_iterator<_IteratorR>& __y)
    { return !(__y < __x); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator>=(const reverse_iterator<_IteratorL>& __x,
        const reverse_iterator<_IteratorR>& __y)
    { return !(__x < __y); }

  template<typename _IteratorL, typename _IteratorR>


    inline auto
    operator-(const reverse_iterator<_IteratorL>& __x,
       const reverse_iterator<_IteratorR>& __y)
    -> decltype(__y.base() - __x.base())





    { return __y.base() - __x.base(); }
# 395 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
  template<typename _Container>
    class back_insert_iterator
    : public iterator<output_iterator_tag, void, void, void, void>
    {
    protected:
      _Container* container;

    public:

      typedef _Container container_type;


      explicit
      back_insert_iterator(_Container& __x) : container(&__x) { }
# 429 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
      back_insert_iterator&
      operator=(const typename _Container::value_type& __value)
      {
 container->push_back(__value);
 return *this;
      }

      back_insert_iterator&
      operator=(typename _Container::value_type&& __value)
      {
 container->push_back(std::move(__value));
 return *this;
      }



      back_insert_iterator&
      operator*()
      { return *this; }


      back_insert_iterator&
      operator++()
      { return *this; }


      back_insert_iterator
      operator++(int)
      { return *this; }
    };
# 471 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
  template<typename _Container>
    inline back_insert_iterator<_Container>
    back_inserter(_Container& __x)
    { return back_insert_iterator<_Container>(__x); }
# 486 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
  template<typename _Container>
    class front_insert_iterator
    : public iterator<output_iterator_tag, void, void, void, void>
    {
    protected:
      _Container* container;

    public:

      typedef _Container container_type;


      explicit front_insert_iterator(_Container& __x) : container(&__x) { }
# 519 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
      front_insert_iterator&
      operator=(const typename _Container::value_type& __value)
      {
 container->push_front(__value);
 return *this;
      }

      front_insert_iterator&
      operator=(typename _Container::value_type&& __value)
      {
 container->push_front(std::move(__value));
 return *this;
      }



      front_insert_iterator&
      operator*()
      { return *this; }


      front_insert_iterator&
      operator++()
      { return *this; }


      front_insert_iterator
      operator++(int)
      { return *this; }
    };
# 561 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
  template<typename _Container>
    inline front_insert_iterator<_Container>
    front_inserter(_Container& __x)
    { return front_insert_iterator<_Container>(__x); }
# 580 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
  template<typename _Container>
    class insert_iterator
    : public iterator<output_iterator_tag, void, void, void, void>
    {
    protected:
      _Container* container;
      typename _Container::iterator iter;

    public:

      typedef _Container container_type;





      insert_iterator(_Container& __x, typename _Container::iterator __i)
      : container(&__x), iter(__i) {}
# 631 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
      insert_iterator&
      operator=(const typename _Container::value_type& __value)
      {
 iter = container->insert(iter, __value);
 ++iter;
 return *this;
      }

      insert_iterator&
      operator=(typename _Container::value_type&& __value)
      {
 iter = container->insert(iter, std::move(__value));
 ++iter;
 return *this;
      }



      insert_iterator&
      operator*()
      { return *this; }


      insert_iterator&
      operator++()
      { return *this; }


      insert_iterator&
      operator++(int)
      { return *this; }
    };
# 675 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
  template<typename _Container, typename _Iterator>
    inline insert_iterator<_Container>
    inserter(_Container& __x, _Iterator __i)
    {
      return insert_iterator<_Container>(__x,
      typename _Container::iterator(__i));
    }




}

namespace __gnu_cxx __attribute__ ((__visibility__ ("default")))
{

# 699 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
  using std::iterator_traits;
  using std::iterator;
  template<typename _Iterator, typename _Container>
    class __normal_iterator
    {
    protected:
      _Iterator _M_current;

      typedef iterator_traits<_Iterator> __traits_type;

    public:
      typedef _Iterator iterator_type;
      typedef typename __traits_type::iterator_category iterator_category;
      typedef typename __traits_type::value_type value_type;
      typedef typename __traits_type::difference_type difference_type;
      typedef typename __traits_type::reference reference;
      typedef typename __traits_type::pointer pointer;

      constexpr __normal_iterator() : _M_current(_Iterator()) { }

      explicit
      __normal_iterator(const _Iterator& __i) : _M_current(__i) { }


      template<typename _Iter>
        __normal_iterator(const __normal_iterator<_Iter,
     typename __enable_if<
              (std::__are_same<_Iter, typename _Container::pointer>::__value),
        _Container>::__type>& __i)
        : _M_current(__i.base()) { }


      reference
      operator*() const
      { return *_M_current; }

      pointer
      operator->() const
      { return _M_current; }

      __normal_iterator&
      operator++()
      {
 ++_M_current;
 return *this;
      }

      __normal_iterator
      operator++(int)
      { return __normal_iterator(_M_current++); }


      __normal_iterator&
      operator--()
      {
 --_M_current;
 return *this;
      }

      __normal_iterator
      operator--(int)
      { return __normal_iterator(_M_current--); }


      reference
      operator[](const difference_type& __n) const
      { return _M_current[__n]; }

      __normal_iterator&
      operator+=(const difference_type& __n)
      { _M_current += __n; return *this; }

      __normal_iterator
      operator+(const difference_type& __n) const
      { return __normal_iterator(_M_current + __n); }

      __normal_iterator&
      operator-=(const difference_type& __n)
      { _M_current -= __n; return *this; }

      __normal_iterator
      operator-(const difference_type& __n) const
      { return __normal_iterator(_M_current - __n); }

      const _Iterator&
      base() const
      { return _M_current; }
    };
# 797 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
  template<typename _IteratorL, typename _IteratorR, typename _Container>
    inline bool
    operator==(const __normal_iterator<_IteratorL, _Container>& __lhs,
        const __normal_iterator<_IteratorR, _Container>& __rhs)
    { return __lhs.base() == __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline bool
    operator==(const __normal_iterator<_Iterator, _Container>& __lhs,
        const __normal_iterator<_Iterator, _Container>& __rhs)
    { return __lhs.base() == __rhs.base(); }

  template<typename _IteratorL, typename _IteratorR, typename _Container>
    inline bool
    operator!=(const __normal_iterator<_IteratorL, _Container>& __lhs,
        const __normal_iterator<_IteratorR, _Container>& __rhs)
    { return __lhs.base() != __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline bool
    operator!=(const __normal_iterator<_Iterator, _Container>& __lhs,
        const __normal_iterator<_Iterator, _Container>& __rhs)
    { return __lhs.base() != __rhs.base(); }


  template<typename _IteratorL, typename _IteratorR, typename _Container>
    inline bool
    operator<(const __normal_iterator<_IteratorL, _Container>& __lhs,
       const __normal_iterator<_IteratorR, _Container>& __rhs)
    { return __lhs.base() < __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline bool
    operator<(const __normal_iterator<_Iterator, _Container>& __lhs,
       const __normal_iterator<_Iterator, _Container>& __rhs)
    { return __lhs.base() < __rhs.base(); }

  template<typename _IteratorL, typename _IteratorR, typename _Container>
    inline bool
    operator>(const __normal_iterator<_IteratorL, _Container>& __lhs,
       const __normal_iterator<_IteratorR, _Container>& __rhs)
    { return __lhs.base() > __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline bool
    operator>(const __normal_iterator<_Iterator, _Container>& __lhs,
       const __normal_iterator<_Iterator, _Container>& __rhs)
    { return __lhs.base() > __rhs.base(); }

  template<typename _IteratorL, typename _IteratorR, typename _Container>
    inline bool
    operator<=(const __normal_iterator<_IteratorL, _Container>& __lhs,
        const __normal_iterator<_IteratorR, _Container>& __rhs)
    { return __lhs.base() <= __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline bool
    operator<=(const __normal_iterator<_Iterator, _Container>& __lhs,
        const __normal_iterator<_Iterator, _Container>& __rhs)
    { return __lhs.base() <= __rhs.base(); }

  template<typename _IteratorL, typename _IteratorR, typename _Container>
    inline bool
    operator>=(const __normal_iterator<_IteratorL, _Container>& __lhs,
        const __normal_iterator<_IteratorR, _Container>& __rhs)
    { return __lhs.base() >= __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline bool
    operator>=(const __normal_iterator<_Iterator, _Container>& __lhs,
        const __normal_iterator<_Iterator, _Container>& __rhs)
    { return __lhs.base() >= __rhs.base(); }





  template<typename _IteratorL, typename _IteratorR, typename _Container>


    inline auto
    operator-(const __normal_iterator<_IteratorL, _Container>& __lhs,
       const __normal_iterator<_IteratorR, _Container>& __rhs)
    -> decltype(__lhs.base() - __rhs.base())





    { return __lhs.base() - __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline typename __normal_iterator<_Iterator, _Container>::difference_type
    operator-(const __normal_iterator<_Iterator, _Container>& __lhs,
       const __normal_iterator<_Iterator, _Container>& __rhs)
    { return __lhs.base() - __rhs.base(); }

  template<typename _Iterator, typename _Container>
    inline __normal_iterator<_Iterator, _Container>
    operator+(typename __normal_iterator<_Iterator, _Container>::difference_type
       __n, const __normal_iterator<_Iterator, _Container>& __i)
    { return __normal_iterator<_Iterator, _Container>(__i.base() + __n); }


}



namespace std __attribute__ ((__visibility__ ("default")))
{

# 923 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_iterator.h" 3
  template<typename _Iterator>
    class move_iterator
    {
    protected:
      _Iterator _M_current;

      typedef iterator_traits<_Iterator> __traits_type;

    public:
      typedef _Iterator iterator_type;
      typedef typename __traits_type::iterator_category iterator_category;
      typedef typename __traits_type::value_type value_type;
      typedef typename __traits_type::difference_type difference_type;

      typedef _Iterator pointer;
      typedef value_type&& reference;

      move_iterator()
      : _M_current() { }

      explicit
      move_iterator(iterator_type __i)
      : _M_current(__i) { }

      template<typename _Iter>
 move_iterator(const move_iterator<_Iter>& __i)
 : _M_current(__i.base()) { }

      iterator_type
      base() const
      { return _M_current; }

      reference
      operator*() const
      { return std::move(*_M_current); }

      pointer
      operator->() const
      { return _M_current; }

      move_iterator&
      operator++()
      {
 ++_M_current;
 return *this;
      }

      move_iterator
      operator++(int)
      {
 move_iterator __tmp = *this;
 ++_M_current;
 return __tmp;
      }

      move_iterator&
      operator--()
      {
 --_M_current;
 return *this;
      }

      move_iterator
      operator--(int)
      {
 move_iterator __tmp = *this;
 --_M_current;
 return __tmp;
      }

      move_iterator
      operator+(difference_type __n) const
      { return move_iterator(_M_current + __n); }

      move_iterator&
      operator+=(difference_type __n)
      {
 _M_current += __n;
 return *this;
      }

      move_iterator
      operator-(difference_type __n) const
      { return move_iterator(_M_current - __n); }

      move_iterator&
      operator-=(difference_type __n)
      {
 _M_current -= __n;
 return *this;
      }

      reference
      operator[](difference_type __n) const
      { return std::move(_M_current[__n]); }
    };




  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator==(const move_iterator<_IteratorL>& __x,
        const move_iterator<_IteratorR>& __y)
    { return __x.base() == __y.base(); }

  template<typename _Iterator>
    inline bool
    operator==(const move_iterator<_Iterator>& __x,
        const move_iterator<_Iterator>& __y)
    { return __x.base() == __y.base(); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator!=(const move_iterator<_IteratorL>& __x,
        const move_iterator<_IteratorR>& __y)
    { return !(__x == __y); }

  template<typename _Iterator>
    inline bool
    operator!=(const move_iterator<_Iterator>& __x,
        const move_iterator<_Iterator>& __y)
    { return !(__x == __y); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator<(const move_iterator<_IteratorL>& __x,
       const move_iterator<_IteratorR>& __y)
    { return __x.base() < __y.base(); }

  template<typename _Iterator>
    inline bool
    operator<(const move_iterator<_Iterator>& __x,
       const move_iterator<_Iterator>& __y)
    { return __x.base() < __y.base(); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator<=(const move_iterator<_IteratorL>& __x,
        const move_iterator<_IteratorR>& __y)
    { return !(__y < __x); }

  template<typename _Iterator>
    inline bool
    operator<=(const move_iterator<_Iterator>& __x,
        const move_iterator<_Iterator>& __y)
    { return !(__y < __x); }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator>(const move_iterator<_IteratorL>& __x,
       const move_iterator<_IteratorR>& __y)
    { return __y < __x; }

  template<typename _Iterator>
    inline bool
    operator>(const move_iterator<_Iterator>& __x,
       const move_iterator<_Iterator>& __y)
    { return __y < __x; }

  template<typename _IteratorL, typename _IteratorR>
    inline bool
    operator>=(const move_iterator<_IteratorL>& __x,
        const move_iterator<_IteratorR>& __y)
    { return !(__x < __y); }

  template<typename _Iterator>
    inline bool
    operator>=(const move_iterator<_Iterator>& __x,
        const move_iterator<_Iterator>& __y)
    { return !(__x < __y); }


  template<typename _IteratorL, typename _IteratorR>
    inline auto
    operator-(const move_iterator<_IteratorL>& __x,
       const move_iterator<_IteratorR>& __y)
    -> decltype(__x.base() - __y.base())
    { return __x.base() - __y.base(); }

  template<typename _Iterator>
    inline auto
    operator-(const move_iterator<_Iterator>& __x,
       const move_iterator<_Iterator>& __y)
    -> decltype(__x.base() - __y.base())
    { return __x.base() - __y.base(); }

  template<typename _Iterator>
    inline move_iterator<_Iterator>
    operator+(typename move_iterator<_Iterator>::difference_type __n,
       const move_iterator<_Iterator>& __x)
    { return __x + __n; }

  template<typename _Iterator>
    inline move_iterator<_Iterator>
    make_move_iterator(const _Iterator& __i)
    { return move_iterator<_Iterator>(__i); }




}
# 69 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 2 3

# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/debug/debug.h" 1 3
# 47 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/debug/debug.h" 3
namespace std
{
  namespace __debug { }
}




namespace __gnu_debug
{
  using namespace std::__debug;
}
# 71 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 2 3


namespace std __attribute__ ((__visibility__ ("default")))
{





  template<bool _BoolType>
    struct __iter_swap
    {
      template<typename _ForwardIterator1, typename _ForwardIterator2>
        static void
        iter_swap(_ForwardIterator1 __a, _ForwardIterator2 __b)
        {
          typedef typename iterator_traits<_ForwardIterator1>::value_type
            _ValueType1;
          _ValueType1 __tmp = std::move(*__a);
          *__a = std::move(*__b);
          *__b = std::move(__tmp);
 }
    };

  template<>
    struct __iter_swap<true>
    {
      template<typename _ForwardIterator1, typename _ForwardIterator2>
        static void
        iter_swap(_ForwardIterator1 __a, _ForwardIterator2 __b)
        {
          swap(*__a, *__b);
        }
    };
# 116 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _ForwardIterator1, typename _ForwardIterator2>
    inline void
    iter_swap(_ForwardIterator1 __a, _ForwardIterator2 __b)
    {
      typedef typename iterator_traits<_ForwardIterator1>::value_type
 _ValueType1;
      typedef typename iterator_traits<_ForwardIterator2>::value_type
 _ValueType2;


     

     

     

     


      typedef typename iterator_traits<_ForwardIterator1>::reference
 _ReferenceType1;
      typedef typename iterator_traits<_ForwardIterator2>::reference
 _ReferenceType2;
      std::__iter_swap<__are_same<_ValueType1, _ValueType2>::__value
 && __are_same<_ValueType1&, _ReferenceType1>::__value
 && __are_same<_ValueType2&, _ReferenceType2>::__value>::
 iter_swap(__a, __b);
    }
# 157 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _ForwardIterator1, typename _ForwardIterator2>
    _ForwardIterator2
    swap_ranges(_ForwardIterator1 __first1, _ForwardIterator1 __last1,
  _ForwardIterator2 __first2)
    {

     

     

      ;

      for (; __first1 != __last1; ++__first1, ++__first2)
 std::iter_swap(__first1, __first2);
      return __first2;
    }
# 185 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _Tp>
    inline const _Tp&
    min(const _Tp& __a, const _Tp& __b)
    {

     

      if (__b < __a)
 return __b;
      return __a;
    }
# 208 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _Tp>
    inline const _Tp&
    max(const _Tp& __a, const _Tp& __b)
    {

     

      if (__a < __b)
 return __b;
      return __a;
    }
# 231 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _Tp, typename _Compare>
    inline const _Tp&
    min(const _Tp& __a, const _Tp& __b, _Compare __comp)
    {

      if (__comp(__b, __a))
 return __b;
      return __a;
    }
# 252 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _Tp, typename _Compare>
    inline const _Tp&
    max(const _Tp& __a, const _Tp& __b, _Compare __comp)
    {

      if (__comp(__a, __b))
 return __b;
      return __a;
    }



  template<typename _Iterator>
    struct _Niter_base
    : _Iter_base<_Iterator, __is_normal_iterator<_Iterator>::__value>
    { };

  template<typename _Iterator>
    inline typename _Niter_base<_Iterator>::iterator_type
    __niter_base(_Iterator __it)
    { return std::_Niter_base<_Iterator>::_S_base(__it); }


  template<typename _Iterator>
    struct _Miter_base
    : _Iter_base<_Iterator, __is_move_iterator<_Iterator>::__value>
    { };

  template<typename _Iterator>
    inline typename _Miter_base<_Iterator>::iterator_type
    __miter_base(_Iterator __it)
    { return std::_Miter_base<_Iterator>::_S_base(__it); }







  template<bool, bool, typename>
    struct __copy_move
    {
      template<typename _II, typename _OI>
        static _OI
        __copy_m(_II __first, _II __last, _OI __result)
        {
   for (; __first != __last; ++__result, ++__first)
     *__result = *__first;
   return __result;
 }
    };


  template<typename _Category>
    struct __copy_move<true, false, _Category>
    {
      template<typename _II, typename _OI>
        static _OI
        __copy_m(_II __first, _II __last, _OI __result)
        {
   for (; __first != __last; ++__result, ++__first)
     *__result = std::move(*__first);
   return __result;
 }
    };


  template<>
    struct __copy_move<false, false, random_access_iterator_tag>
    {
      template<typename _II, typename _OI>
        static _OI
        __copy_m(_II __first, _II __last, _OI __result)
        {
   typedef typename iterator_traits<_II>::difference_type _Distance;
   for(_Distance __n = __last - __first; __n > 0; --__n)
     {
       *__result = *__first;
       ++__first;
       ++__result;
     }
   return __result;
 }
    };


  template<>
    struct __copy_move<true, false, random_access_iterator_tag>
    {
      template<typename _II, typename _OI>
        static _OI
        __copy_m(_II __first, _II __last, _OI __result)
        {
   typedef typename iterator_traits<_II>::difference_type _Distance;
   for(_Distance __n = __last - __first; __n > 0; --__n)
     {
       *__result = std::move(*__first);
       ++__first;
       ++__result;
     }
   return __result;
 }
    };


  template<bool _IsMove>
    struct __copy_move<_IsMove, true, random_access_iterator_tag>
    {
      template<typename _Tp>
        static _Tp*
        __copy_m(const _Tp* __first, const _Tp* __last, _Tp* __result)
        {
   const ptrdiff_t _Num = __last - __first;
   if (_Num)
     __builtin_memmove(__result, __first, sizeof(_Tp) * _Num);
   return __result + _Num;
 }
    };

  template<bool _IsMove, typename _II, typename _OI>
    inline _OI
    __copy_move_a(_II __first, _II __last, _OI __result)
    {
      typedef typename iterator_traits<_II>::value_type _ValueTypeI;
      typedef typename iterator_traits<_OI>::value_type _ValueTypeO;
      typedef typename iterator_traits<_II>::iterator_category _Category;
      const bool __simple = (__is_trivial(_ValueTypeI)
                      && __is_pointer<_II>::__value
                      && __is_pointer<_OI>::__value
        && __are_same<_ValueTypeI, _ValueTypeO>::__value);

      return std::__copy_move<_IsMove, __simple,
                       _Category>::__copy_m(__first, __last, __result);
    }



  template<typename _CharT>
    struct char_traits;

  template<typename _CharT, typename _Traits>
    class istreambuf_iterator;

  template<typename _CharT, typename _Traits>
    class ostreambuf_iterator;

  template<bool _IsMove, typename _CharT>
    typename __gnu_cxx::__enable_if<__is_char<_CharT>::__value,
      ostreambuf_iterator<_CharT, char_traits<_CharT> > >::__type
    __copy_move_a2(_CharT*, _CharT*,
     ostreambuf_iterator<_CharT, char_traits<_CharT> >);

  template<bool _IsMove, typename _CharT>
    typename __gnu_cxx::__enable_if<__is_char<_CharT>::__value,
      ostreambuf_iterator<_CharT, char_traits<_CharT> > >::__type
    __copy_move_a2(const _CharT*, const _CharT*,
     ostreambuf_iterator<_CharT, char_traits<_CharT> >);

  template<bool _IsMove, typename _CharT>
    typename __gnu_cxx::__enable_if<__is_char<_CharT>::__value,
        _CharT*>::__type
    __copy_move_a2(istreambuf_iterator<_CharT, char_traits<_CharT> >,
     istreambuf_iterator<_CharT, char_traits<_CharT> >, _CharT*);

  template<bool _IsMove, typename _II, typename _OI>
    inline _OI
    __copy_move_a2(_II __first, _II __last, _OI __result)
    {
      return _OI(std::__copy_move_a<_IsMove>(std::__niter_base(__first),
          std::__niter_base(__last),
          std::__niter_base(__result)));
    }
# 442 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _II, typename _OI>
    inline _OI
    copy(_II __first, _II __last, _OI __result)
    {

     
     

      ;

      return (std::__copy_move_a2<__is_move_iterator<_II>::__value>
       (std::__miter_base(__first), std::__miter_base(__last),
        __result));
    }
# 475 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _II, typename _OI>
    inline _OI
    move(_II __first, _II __last, _OI __result)
    {

     
     

      ;

      return std::__copy_move_a2<true>(std::__miter_base(__first),
           std::__miter_base(__last), __result);
    }






  template<bool, bool, typename>
    struct __copy_move_backward
    {
      template<typename _BI1, typename _BI2>
        static _BI2
        __copy_move_b(_BI1 __first, _BI1 __last, _BI2 __result)
        {
   while (__first != __last)
     *--__result = *--__last;
   return __result;
 }
    };


  template<typename _Category>
    struct __copy_move_backward<true, false, _Category>
    {
      template<typename _BI1, typename _BI2>
        static _BI2
        __copy_move_b(_BI1 __first, _BI1 __last, _BI2 __result)
        {
   while (__first != __last)
     *--__result = std::move(*--__last);
   return __result;
 }
    };


  template<>
    struct __copy_move_backward<false, false, random_access_iterator_tag>
    {
      template<typename _BI1, typename _BI2>
        static _BI2
        __copy_move_b(_BI1 __first, _BI1 __last, _BI2 __result)
        {
   typename iterator_traits<_BI1>::difference_type __n;
   for (__n = __last - __first; __n > 0; --__n)
     *--__result = *--__last;
   return __result;
 }
    };


  template<>
    struct __copy_move_backward<true, false, random_access_iterator_tag>
    {
      template<typename _BI1, typename _BI2>
        static _BI2
        __copy_move_b(_BI1 __first, _BI1 __last, _BI2 __result)
        {
   typename iterator_traits<_BI1>::difference_type __n;
   for (__n = __last - __first; __n > 0; --__n)
     *--__result = std::move(*--__last);
   return __result;
 }
    };


  template<bool _IsMove>
    struct __copy_move_backward<_IsMove, true, random_access_iterator_tag>
    {
      template<typename _Tp>
        static _Tp*
        __copy_move_b(const _Tp* __first, const _Tp* __last, _Tp* __result)
        {
   const ptrdiff_t _Num = __last - __first;
   if (_Num)
     __builtin_memmove(__result - _Num, __first, sizeof(_Tp) * _Num);
   return __result - _Num;
 }
    };

  template<bool _IsMove, typename _BI1, typename _BI2>
    inline _BI2
    __copy_move_backward_a(_BI1 __first, _BI1 __last, _BI2 __result)
    {
      typedef typename iterator_traits<_BI1>::value_type _ValueType1;
      typedef typename iterator_traits<_BI2>::value_type _ValueType2;
      typedef typename iterator_traits<_BI1>::iterator_category _Category;
      const bool __simple = (__is_trivial(_ValueType1)
                      && __is_pointer<_BI1>::__value
                      && __is_pointer<_BI2>::__value
        && __are_same<_ValueType1, _ValueType2>::__value);

      return std::__copy_move_backward<_IsMove, __simple,
                                _Category>::__copy_move_b(__first,
         __last,
         __result);
    }

  template<bool _IsMove, typename _BI1, typename _BI2>
    inline _BI2
    __copy_move_backward_a2(_BI1 __first, _BI1 __last, _BI2 __result)
    {
      return _BI2(std::__copy_move_backward_a<_IsMove>
    (std::__niter_base(__first), std::__niter_base(__last),
     std::__niter_base(__result)));
    }
# 611 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _BI1, typename _BI2>
    inline _BI2
    copy_backward(_BI1 __first, _BI1 __last, _BI2 __result)
    {

     
     
     


      ;

      return (std::__copy_move_backward_a2<__is_move_iterator<_BI1>::__value>
       (std::__miter_base(__first), std::__miter_base(__last),
        __result));
    }
# 647 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _BI1, typename _BI2>
    inline _BI2
    move_backward(_BI1 __first, _BI1 __last, _BI2 __result)
    {

     
     
     


      ;

      return std::__copy_move_backward_a2<true>(std::__miter_base(__first),
      std::__miter_base(__last),
      __result);
    }






  template<typename _ForwardIterator, typename _Tp>
    inline typename
    __gnu_cxx::__enable_if<!__is_scalar<_Tp>::__value, void>::__type
    __fill_a(_ForwardIterator __first, _ForwardIterator __last,
       const _Tp& __value)
    {
      for (; __first != __last; ++__first)
 *__first = __value;
    }

  template<typename _ForwardIterator, typename _Tp>
    inline typename
    __gnu_cxx::__enable_if<__is_scalar<_Tp>::__value, void>::__type
    __fill_a(_ForwardIterator __first, _ForwardIterator __last,
      const _Tp& __value)
    {
      const _Tp __tmp = __value;
      for (; __first != __last; ++__first)
 *__first = __tmp;
    }


  template<typename _Tp>
    inline typename
    __gnu_cxx::__enable_if<__is_byte<_Tp>::__value, void>::__type
    __fill_a(_Tp* __first, _Tp* __last, const _Tp& __c)
    {
      const _Tp __tmp = __c;
      __builtin_memset(__first, static_cast<unsigned char>(__tmp),
         __last - __first);
    }
# 713 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _ForwardIterator, typename _Tp>
    inline void
    fill(_ForwardIterator __first, _ForwardIterator __last, const _Tp& __value)
    {

     

      ;

      std::__fill_a(std::__niter_base(__first), std::__niter_base(__last),
      __value);
    }

  template<typename _OutputIterator, typename _Size, typename _Tp>
    inline typename
    __gnu_cxx::__enable_if<!__is_scalar<_Tp>::__value, _OutputIterator>::__type
    __fill_n_a(_OutputIterator __first, _Size __n, const _Tp& __value)
    {
      for (__decltype(__n + 0) __niter = __n;
    __niter > 0; --__niter, ++__first)
 *__first = __value;
      return __first;
    }

  template<typename _OutputIterator, typename _Size, typename _Tp>
    inline typename
    __gnu_cxx::__enable_if<__is_scalar<_Tp>::__value, _OutputIterator>::__type
    __fill_n_a(_OutputIterator __first, _Size __n, const _Tp& __value)
    {
      const _Tp __tmp = __value;
      for (__decltype(__n + 0) __niter = __n;
    __niter > 0; --__niter, ++__first)
 *__first = __tmp;
      return __first;
    }

  template<typename _Size, typename _Tp>
    inline typename
    __gnu_cxx::__enable_if<__is_byte<_Tp>::__value, _Tp*>::__type
    __fill_n_a(_Tp* __first, _Size __n, const _Tp& __c)
    {
      std::__fill_a(__first, __first + __n, __c);
      return __first + __n;
    }
# 773 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _OI, typename _Size, typename _Tp>
    inline _OI
    fill_n(_OI __first, _Size __n, const _Tp& __value)
    {

     

      return _OI(std::__fill_n_a(std::__niter_base(__first), __n, __value));
    }

  template<bool _BoolType>
    struct __equal
    {
      template<typename _II1, typename _II2>
        static bool
        equal(_II1 __first1, _II1 __last1, _II2 __first2)
        {
   for (; __first1 != __last1; ++__first1, ++__first2)
     if (!(*__first1 == *__first2))
       return false;
   return true;
 }
    };

  template<>
    struct __equal<true>
    {
      template<typename _Tp>
        static bool
        equal(const _Tp* __first1, const _Tp* __last1, const _Tp* __first2)
        {
   return !__builtin_memcmp(__first1, __first2, sizeof(_Tp)
       * (__last1 - __first1));
 }
    };

  template<typename _II1, typename _II2>
    inline bool
    __equal_aux(_II1 __first1, _II1 __last1, _II2 __first2)
    {
      typedef typename iterator_traits<_II1>::value_type _ValueType1;
      typedef typename iterator_traits<_II2>::value_type _ValueType2;
      const bool __simple = (__is_integer<_ValueType1>::__value
                      && __is_pointer<_II1>::__value
                      && __is_pointer<_II2>::__value
        && __are_same<_ValueType1, _ValueType2>::__value);

      return std::__equal<__simple>::equal(__first1, __last1, __first2);
    }


  template<typename, typename>
    struct __lc_rai
    {
      template<typename _II1, typename _II2>
        static _II1
        __newlast1(_II1, _II1 __last1, _II2, _II2)
        { return __last1; }

      template<typename _II>
        static bool
        __cnd2(_II __first, _II __last)
        { return __first != __last; }
    };

  template<>
    struct __lc_rai<random_access_iterator_tag, random_access_iterator_tag>
    {
      template<typename _RAI1, typename _RAI2>
        static _RAI1
        __newlast1(_RAI1 __first1, _RAI1 __last1,
     _RAI2 __first2, _RAI2 __last2)
        {
   const typename iterator_traits<_RAI1>::difference_type
     __diff1 = __last1 - __first1;
   const typename iterator_traits<_RAI2>::difference_type
     __diff2 = __last2 - __first2;
   return __diff2 < __diff1 ? __first1 + __diff2 : __last1;
 }

      template<typename _RAI>
        static bool
        __cnd2(_RAI, _RAI)
        { return true; }
    };

  template<bool _BoolType>
    struct __lexicographical_compare
    {
      template<typename _II1, typename _II2>
        static bool __lc(_II1, _II1, _II2, _II2);
    };

  template<bool _BoolType>
    template<typename _II1, typename _II2>
      bool
      __lexicographical_compare<_BoolType>::
      __lc(_II1 __first1, _II1 __last1, _II2 __first2, _II2 __last2)
      {
 typedef typename iterator_traits<_II1>::iterator_category _Category1;
 typedef typename iterator_traits<_II2>::iterator_category _Category2;
 typedef std::__lc_rai<_Category1, _Category2> __rai_type;

 __last1 = __rai_type::__newlast1(__first1, __last1,
      __first2, __last2);
 for (; __first1 != __last1 && __rai_type::__cnd2(__first2, __last2);
      ++__first1, ++__first2)
   {
     if (*__first1 < *__first2)
       return true;
     if (*__first2 < *__first1)
       return false;
   }
 return __first1 == __last1 && __first2 != __last2;
      }

  template<>
    struct __lexicographical_compare<true>
    {
      template<typename _Tp, typename _Up>
        static bool
        __lc(const _Tp* __first1, const _Tp* __last1,
      const _Up* __first2, const _Up* __last2)
 {
   const size_t __len1 = __last1 - __first1;
   const size_t __len2 = __last2 - __first2;
   const int __result = __builtin_memcmp(__first1, __first2,
      std::min(__len1, __len2));
   return __result != 0 ? __result < 0 : __len1 < __len2;
 }
    };

  template<typename _II1, typename _II2>
    inline bool
    __lexicographical_compare_aux(_II1 __first1, _II1 __last1,
      _II2 __first2, _II2 __last2)
    {
      typedef typename iterator_traits<_II1>::value_type _ValueType1;
      typedef typename iterator_traits<_II2>::value_type _ValueType2;
      const bool __simple =
 (__is_byte<_ValueType1>::__value && __is_byte<_ValueType2>::__value
  && !__gnu_cxx::__numeric_traits<_ValueType1>::__is_signed
  && !__gnu_cxx::__numeric_traits<_ValueType2>::__is_signed
  && __is_pointer<_II1>::__value
  && __is_pointer<_II2>::__value);

      return std::__lexicographical_compare<__simple>::__lc(__first1, __last1,
           __first2, __last2);
    }
# 934 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _ForwardIterator, typename _Tp>
    _ForwardIterator
    lower_bound(_ForwardIterator __first, _ForwardIterator __last,
  const _Tp& __val)
    {
      typedef typename iterator_traits<_ForwardIterator>::value_type
 _ValueType;
      typedef typename iterator_traits<_ForwardIterator>::difference_type
 _DistanceType;


     
     
      ;

      _DistanceType __len = std::distance(__first, __last);

      while (__len > 0)
 {
   _DistanceType __half = __len >> 1;
   _ForwardIterator __middle = __first;
   std::advance(__middle, __half);
   if (*__middle < __val)
     {
       __first = __middle;
       ++__first;
       __len = __len - __half - 1;
     }
   else
     __len = __half;
 }
      return __first;
    }



  template<typename _Size>
    inline _Size
    __lg(_Size __n)
    {
      _Size __k;
      for (__k = 0; __n != 0; __n >>= 1)
 ++__k;
      return __k - 1;
    }

  inline int
  __lg(int __n)
  { return sizeof(int) * 8 - 1 - __builtin_clz(__n); }

  inline long
  __lg(long __n)
  { return sizeof(long) * 8 - 1 - __builtin_clzl(__n); }

  inline long long
  __lg(long long __n)
  { return sizeof(long long) * 8 - 1 - __builtin_clzll(__n); }




# 1008 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _II1, typename _II2>
    inline bool
    equal(_II1 __first1, _II1 __last1, _II2 __first2)
    {

     
     
     


      ;

      return std::__equal_aux(std::__niter_base(__first1),
         std::__niter_base(__last1),
         std::__niter_base(__first2));
    }
# 1040 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _IIter1, typename _IIter2, typename _BinaryPredicate>
    inline bool
    equal(_IIter1 __first1, _IIter1 __last1,
   _IIter2 __first2, _BinaryPredicate __binary_pred)
    {

     
     
      ;

      for (; __first1 != __last1; ++__first1, ++__first2)
 if (!bool(__binary_pred(*__first1, *__first2)))
   return false;
      return true;
    }
# 1071 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _II1, typename _II2>
    inline bool
    lexicographical_compare(_II1 __first1, _II1 __last1,
       _II2 __first2, _II2 __last2)
    {

      typedef typename iterator_traits<_II1>::value_type _ValueType1;
      typedef typename iterator_traits<_II2>::value_type _ValueType2;
     
     
     
     
      ;
      ;

      return std::__lexicographical_compare_aux(std::__niter_base(__first1),
      std::__niter_base(__last1),
      std::__niter_base(__first2),
      std::__niter_base(__last2));
    }
# 1105 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _II1, typename _II2, typename _Compare>
    bool
    lexicographical_compare(_II1 __first1, _II1 __last1,
       _II2 __first2, _II2 __last2, _Compare __comp)
    {
      typedef typename iterator_traits<_II1>::iterator_category _Category1;
      typedef typename iterator_traits<_II2>::iterator_category _Category2;
      typedef std::__lc_rai<_Category1, _Category2> __rai_type;


     
     
      ;
      ;

      __last1 = __rai_type::__newlast1(__first1, __last1, __first2, __last2);
      for (; __first1 != __last1 && __rai_type::__cnd2(__first2, __last2);
    ++__first1, ++__first2)
 {
   if (__comp(*__first1, *__first2))
     return true;
   if (__comp(*__first2, *__first1))
     return false;
 }
      return __first1 == __last1 && __first2 != __last2;
    }
# 1145 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _InputIterator1, typename _InputIterator2>
    pair<_InputIterator1, _InputIterator2>
    mismatch(_InputIterator1 __first1, _InputIterator1 __last1,
      _InputIterator2 __first2)
    {

     
     
     


      ;

      while (__first1 != __last1 && *__first1 == *__first2)
        {
   ++__first1;
   ++__first2;
        }
      return pair<_InputIterator1, _InputIterator2>(__first1, __first2);
    }
# 1182 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_algobase.h" 3
  template<typename _InputIterator1, typename _InputIterator2,
    typename _BinaryPredicate>
    pair<_InputIterator1, _InputIterator2>
    mismatch(_InputIterator1 __first1, _InputIterator1 __last1,
      _InputIterator2 __first2, _BinaryPredicate __binary_pred)
    {

     
     
      ;

      while (__first1 != __last1 && bool(__binary_pred(*__first1, *__first2)))
        {
   ++__first1;
   ++__first2;
        }
      return pair<_InputIterator1, _InputIterator2>(__first1, __first2);
    }


}
# 62 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/vector" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/allocator.h" 1 3
# 48 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/allocator.h" 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/x86_64-apple-darwin10.7.0/bits/c++allocator.h" 1 3
# 34 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/x86_64-apple-darwin10.7.0/bits/c++allocator.h" 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/new_allocator.h" 1 3
# 34 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/new_allocator.h" 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/new" 1 3
# 39 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/new" 3
       
# 40 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/new" 3


# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/exception" 1 3
# 35 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/exception" 3
       
# 36 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/exception" 3

#pragma GCC visibility push(default)



extern "C++" {

namespace std
{
# 61 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/exception" 3
  class exception
  {
  public:
    exception() throw() { }
    virtual ~exception() throw();



    virtual const char* what() const throw();
  };



  class bad_exception : public exception
  {
  public:
    bad_exception() throw() { }



    virtual ~bad_exception() throw();


    virtual const char* what() const throw();
  };


  typedef void (*terminate_handler) ();


  typedef void (*unexpected_handler) ();


  terminate_handler set_terminate(terminate_handler) throw();



  void terminate() throw() __attribute__ ((__noreturn__));


  unexpected_handler set_unexpected(unexpected_handler) throw();



  void unexpected() __attribute__ ((__noreturn__));
# 118 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/exception" 3
  bool uncaught_exception() throw() __attribute__ ((__pure__));


}

namespace __gnu_cxx
{

# 143 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/exception" 3
  void __verbose_terminate_handler();


}

}

#pragma GCC visibility pop



# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/exception_ptr.h" 1 3
# 34 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/exception_ptr.h" 3
#pragma GCC visibility push(default)
# 43 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/exception_ptr.h" 3
extern "C++" {

namespace std
{




  namespace __exception_ptr
  {
    class exception_ptr;
  }

  using __exception_ptr::exception_ptr;





  exception_ptr current_exception() throw();


  void rethrow_exception(exception_ptr) __attribute__ ((__noreturn__));

  namespace __exception_ptr
  {




    class exception_ptr
    {
      void* _M_exception_object;

      explicit exception_ptr(void* __e) throw();

      void _M_addref() throw();
      void _M_release() throw();

      void *_M_get() const throw() __attribute__ ((__pure__));

      friend exception_ptr std::current_exception() throw();
      friend void std::rethrow_exception(exception_ptr);

    public:
      exception_ptr() throw();

      exception_ptr(const exception_ptr&) throw();


      exception_ptr(nullptr_t) throw()
      : _M_exception_object(0)
      { }

      exception_ptr(exception_ptr&& __o) throw()
      : _M_exception_object(__o._M_exception_object)
      { __o._M_exception_object = 0; }







      exception_ptr&
      operator=(const exception_ptr&) throw();


      exception_ptr&
      operator=(exception_ptr&& __o) throw()
      {
        exception_ptr(static_cast<exception_ptr&&>(__o)).swap(*this);
        return *this;
      }


      ~exception_ptr() throw();

      void
      swap(exception_ptr&) throw();
# 132 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/exception_ptr.h" 3
      explicit operator bool() const
      { return _M_exception_object; }


      friend bool
      operator==(const exception_ptr&, const exception_ptr&) throw()
      __attribute__ ((__pure__));

      const type_info*
      __cxa_exception_type() const throw() __attribute__ ((__pure__));
    };

    bool
    operator==(const exception_ptr&, const exception_ptr&) throw()
    __attribute__ ((__pure__));

    bool
    operator!=(const exception_ptr&, const exception_ptr&) throw()
    __attribute__ ((__pure__));

    inline void
    swap(exception_ptr& __lhs, exception_ptr& __rhs)
    { __lhs.swap(__rhs); }

  }



  template<typename _Ex>
    exception_ptr
    copy_exception(_Ex __ex) throw()
    {
      try
 {

   throw __ex;

 }
      catch(...)
 {
   return current_exception();
 }
    }




  template<typename _Ex>
    exception_ptr
    make_exception_ptr(_Ex __ex) throw()
    { return std::copy_exception<_Ex>(__ex); }


}

}

#pragma GCC visibility pop
# 155 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/exception" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/nested_exception.h" 1 3
# 33 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/nested_exception.h" 3
#pragma GCC visibility push(default)
# 45 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/nested_exception.h" 3
extern "C++" {

namespace std
{






  class nested_exception
  {
    exception_ptr _M_ptr;

  public:
    nested_exception() throw() : _M_ptr(current_exception()) { }

    nested_exception(const nested_exception&) = default;

    nested_exception& operator=(const nested_exception&) = default;

    virtual ~nested_exception();

    void
    rethrow_nested() const __attribute__ ((__noreturn__))
    { rethrow_exception(_M_ptr); }

    exception_ptr
    nested_ptr() const
    { return _M_ptr; }
  };

  template<typename _Except>
    struct _Nested_exception : public _Except, public nested_exception
    {
      explicit _Nested_exception(_Except&& __ex)
      : _Except(static_cast<_Except&&>(__ex))
      { }
    };

  template<typename _Ex>
    struct __get_nested_helper
    {
      static const nested_exception*
      _S_get(const _Ex& __ex)
      { return dynamic_cast<const nested_exception*>(&__ex); }
    };

  template<typename _Ex>
    struct __get_nested_helper<_Ex*>
    {
      static const nested_exception*
      _S_get(const _Ex* __ex)
      { return dynamic_cast<const nested_exception*>(__ex); }
    };

  template<typename _Ex>
    inline const nested_exception*
    __get_nested_exception(const _Ex& __ex)
    { return __get_nested_helper<_Ex>::_S_get(__ex); }

  template<typename _Ex>
    void
    __throw_with_nested(_Ex&&, const nested_exception* = 0)
    __attribute__ ((__noreturn__));

  template<typename _Ex>
    void
    __throw_with_nested(_Ex&&, ...) __attribute__ ((__noreturn__));




  template<typename _Ex>
    inline void
    __throw_with_nested(_Ex&& __ex, const nested_exception* = 0)
    { throw __ex; }

  template<typename _Ex>
    inline void
    __throw_with_nested(_Ex&& __ex, ...)
    { throw _Nested_exception<_Ex>(static_cast<_Ex&&>(__ex)); }

  template<typename _Ex>
    void
    throw_with_nested(_Ex __ex) __attribute__ ((__noreturn__));



  template<typename _Ex>
    inline void
    throw_with_nested(_Ex __ex)
    {
      if (__get_nested_exception(__ex))
        throw __ex;
      __throw_with_nested(static_cast<_Ex&&>(__ex), &__ex);
    }


  template<typename _Ex>
    inline void
    rethrow_if_nested(const _Ex& __ex)
    {
      if (const nested_exception* __nested = __get_nested_exception(__ex))
        __nested->rethrow_nested();
    }


  inline void
  rethrow_if_nested(const nested_exception& __ex)
  { __ex.rethrow_nested(); }


}

}



#pragma GCC visibility pop
# 156 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/exception" 2 3
# 43 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/new" 2 3

#pragma GCC visibility push(default)

extern "C++" {

namespace std
{






  class bad_alloc : public exception
  {
  public:
    bad_alloc() throw() { }



    virtual ~bad_alloc() throw();


    virtual const char* what() const throw();
  };

  struct nothrow_t { };

  extern const nothrow_t nothrow;



  typedef void (*new_handler)();



  new_handler set_new_handler(new_handler) throw();
}
# 93 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/new" 3
void* operator new(std::size_t) throw (std::bad_alloc);
void* operator new[](std::size_t) throw (std::bad_alloc);
void operator delete(void*) throw();
void operator delete[](void*) throw();
void* operator new(std::size_t, const std::nothrow_t&) throw();
void* operator new[](std::size_t, const std::nothrow_t&) throw();
void operator delete(void*, const std::nothrow_t&) throw();
void operator delete[](void*, const std::nothrow_t&) throw();


inline void* operator new(std::size_t, void* __p) throw() { return __p; }
inline void* operator new[](std::size_t, void* __p) throw() { return __p; }


inline void operator delete (void*, void*) throw() { }
inline void operator delete[](void*, void*) throw() { }

}

#pragma GCC visibility pop
# 35 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/new_allocator.h" 2 3



namespace __gnu_cxx __attribute__ ((__visibility__ ("default")))
{


  using std::size_t;
  using std::ptrdiff_t;
# 53 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/ext/new_allocator.h" 3
  template<typename _Tp>
    class new_allocator
    {
    public:
      typedef size_t size_type;
      typedef ptrdiff_t difference_type;
      typedef _Tp* pointer;
      typedef const _Tp* const_pointer;
      typedef _Tp& reference;
      typedef const _Tp& const_reference;
      typedef _Tp value_type;

      template<typename _Tp1>
        struct rebind
        { typedef new_allocator<_Tp1> other; };

      new_allocator() throw() { }

      new_allocator(const new_allocator&) throw() { }

      template<typename _Tp1>
        new_allocator(const new_allocator<_Tp1>&) throw() { }

      ~new_allocator() throw() { }

      pointer
      address(reference __x) const { return std::__addressof(__x); }

      const_pointer
      address(const_reference __x) const { return std::__addressof(__x); }



      pointer
      allocate(size_type __n, const void* = 0)
      {
 if (__n > this->max_size())
   std::__throw_bad_alloc();

 return static_cast<_Tp*>(::operator new(__n * sizeof(_Tp)));
      }


      void
      deallocate(pointer __p, size_type)
      { ::operator delete(__p); }

      size_type
      max_size() const throw()
      { return size_t(-1) / sizeof(_Tp); }



      void
      construct(pointer __p, const _Tp& __val)
      { ::new((void *)__p) _Tp(__val); }


      template<typename... _Args>
        void
        construct(pointer __p, _Args&&... __args)
 { ::new((void *)__p) _Tp(std::forward<_Args>(__args)...); }


      void
      destroy(pointer __p) { __p->~_Tp(); }
    };

  template<typename _Tp>
    inline bool
    operator==(const new_allocator<_Tp>&, const new_allocator<_Tp>&)
    { return true; }

  template<typename _Tp>
    inline bool
    operator!=(const new_allocator<_Tp>&, const new_allocator<_Tp>&)
    { return false; }


}
# 35 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/x86_64-apple-darwin10.7.0/bits/c++allocator.h" 2 3
# 49 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/allocator.h" 2 3





namespace std __attribute__ ((__visibility__ ("default")))
{

# 65 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/allocator.h" 3
  template<typename _Tp>
    class allocator;


  template<>
    class allocator<void>
    {
    public:
      typedef size_t size_type;
      typedef ptrdiff_t difference_type;
      typedef void* pointer;
      typedef const void* const_pointer;
      typedef void value_type;

      template<typename _Tp1>
        struct rebind
        { typedef allocator<_Tp1> other; };
    };
# 91 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/allocator.h" 3
  template<typename _Tp>
    class allocator: public __gnu_cxx::new_allocator<_Tp>
    {
   public:
      typedef size_t size_type;
      typedef ptrdiff_t difference_type;
      typedef _Tp* pointer;
      typedef const _Tp* const_pointer;
      typedef _Tp& reference;
      typedef const _Tp& const_reference;
      typedef _Tp value_type;

      template<typename _Tp1>
        struct rebind
        { typedef allocator<_Tp1> other; };

      allocator() throw() { }

      allocator(const allocator& __a) throw()
      : __gnu_cxx::new_allocator<_Tp>(__a) { }

      template<typename _Tp1>
        allocator(const allocator<_Tp1>&) throw() { }

      ~allocator() throw() { }


    };

  template<typename _T1, typename _T2>
    inline bool
    operator==(const allocator<_T1>&, const allocator<_T2>&)
    { return true; }

  template<typename _Tp>
    inline bool
    operator==(const allocator<_Tp>&, const allocator<_Tp>&)
    { return true; }

  template<typename _T1, typename _T2>
    inline bool
    operator!=(const allocator<_T1>&, const allocator<_T2>&)
    { return false; }

  template<typename _Tp>
    inline bool
    operator!=(const allocator<_Tp>&, const allocator<_Tp>&)
    { return false; }




  extern template class allocator<char>;
  extern template class allocator<wchar_t>;






  template<typename _Alloc, bool = __is_empty(_Alloc)>
    struct __alloc_swap
    { static void _S_do_it(_Alloc&, _Alloc&) { } };

  template<typename _Alloc>
    struct __alloc_swap<_Alloc, false>
    {
      static void
      _S_do_it(_Alloc& __one, _Alloc& __two)
      {

 if (__one != __two)
   swap(__one, __two);
      }
    };


  template<typename _Alloc, bool = __is_empty(_Alloc)>
    struct __alloc_neq
    {
      static bool
      _S_do_it(const _Alloc&, const _Alloc&)
      { return false; }
    };

  template<typename _Alloc>
    struct __alloc_neq<_Alloc, false>
    {
      static bool
      _S_do_it(const _Alloc& __one, const _Alloc& __two)
      { return __one != __two; }
    };
# 191 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/allocator.h" 3
  template<typename _Tp,
    bool = __has_trivial_copy(typename _Tp::value_type)>
    struct __shrink_to_fit
    { static void _S_do_it(_Tp&) { } };

  template<typename _Tp>
    struct __shrink_to_fit<_Tp, true>
    {
      static void
      _S_do_it(_Tp& __v)
      {
 try
   { _Tp(__v).swap(__v); }
 catch(...) { }
      }
    };



  struct allocator_arg_t { };

  constexpr allocator_arg_t allocator_arg = allocator_arg_t();

template<typename _Tp> class __has_allocator_type_helper : __sfinae_types { template<typename _Up> struct _Wrap_type { }; template<typename _Up> static __one __test(_Wrap_type<typename _Up::allocator_type>*); template<typename _Up> static __two __test(...); public: static const bool value = sizeof(__test<_Tp>(0)) == 1; }; template<typename _Tp> struct __has_allocator_type : integral_constant<bool, __has_allocator_type_helper <typename remove_cv<_Tp>::type>::value> { };

  template<typename _Tp, typename _Alloc,
    bool = __has_allocator_type<_Tp>::value>
    struct __uses_allocator_helper
    : public false_type { };

  template<typename _Tp, typename _Alloc>
    struct __uses_allocator_helper<_Tp, _Alloc, true>
    : public integral_constant<bool, is_convertible<_Alloc,
         typename _Tp::allocator_type>::value>
    { };


  template<typename _Tp, typename _Alloc>
    struct uses_allocator
    : public integral_constant<bool,
          __uses_allocator_helper<_Tp, _Alloc>::value>
    { };




}
# 63 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/vector" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_construct.h" 1 3
# 64 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_construct.h" 3
namespace std __attribute__ ((__visibility__ ("default")))
{







  template<typename _T1, typename... _Args>
    inline void
    _Construct(_T1* __p, _Args&&... __args)
    { ::new(static_cast<void*>(__p)) _T1(std::forward<_Args>(__args)...); }
# 91 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_construct.h" 3
  template<typename _Tp>
    inline void
    _Destroy(_Tp* __pointer)
    { __pointer->~_Tp(); }

  template<bool>
    struct _Destroy_aux
    {
      template<typename _ForwardIterator>
        static void
        __destroy(_ForwardIterator __first, _ForwardIterator __last)
 {
   for (; __first != __last; ++__first)
     std::_Destroy(std::__addressof(*__first));
 }
    };

  template<>
    struct _Destroy_aux<true>
    {
      template<typename _ForwardIterator>
        static void
        __destroy(_ForwardIterator, _ForwardIterator) { }
    };






  template<typename _ForwardIterator>
    inline void
    _Destroy(_ForwardIterator __first, _ForwardIterator __last)
    {
      typedef typename iterator_traits<_ForwardIterator>::value_type
                       _Value_type;
      std::_Destroy_aux<__has_trivial_destructor(_Value_type)>::
 __destroy(__first, __last);
    }







  template <typename _Tp> class allocator;

  template<typename _ForwardIterator, typename _Allocator>
    void
    _Destroy(_ForwardIterator __first, _ForwardIterator __last,
      _Allocator& __alloc)
    {
      for (; __first != __last; ++__first)
 __alloc.destroy(std::__addressof(*__first));
    }

  template<typename _ForwardIterator, typename _Tp>
    inline void
    _Destroy(_ForwardIterator __first, _ForwardIterator __last,
      allocator<_Tp>&)
    {
      _Destroy(__first, __last);
    }


}
# 64 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/vector" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_uninitialized.h" 1 3
# 61 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_uninitialized.h" 3
namespace std __attribute__ ((__visibility__ ("default")))
{


  template<bool _TrivialValueTypes>
    struct __uninitialized_copy
    {
      template<typename _InputIterator, typename _ForwardIterator>
        static _ForwardIterator
        __uninit_copy(_InputIterator __first, _InputIterator __last,
        _ForwardIterator __result)
        {
   _ForwardIterator __cur = __result;
   try
     {
       for (; __first != __last; ++__first, ++__cur)
  std::_Construct(std::__addressof(*__cur), *__first);
       return __cur;
     }
   catch(...)
     {
       std::_Destroy(__result, __cur);
       throw;
     }
 }
    };

  template<>
    struct __uninitialized_copy<true>
    {
      template<typename _InputIterator, typename _ForwardIterator>
        static _ForwardIterator
        __uninit_copy(_InputIterator __first, _InputIterator __last,
        _ForwardIterator __result)
        { return std::copy(__first, __last, __result); }
    };
# 107 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_uninitialized.h" 3
  template<typename _InputIterator, typename _ForwardIterator>
    inline _ForwardIterator
    uninitialized_copy(_InputIterator __first, _InputIterator __last,
         _ForwardIterator __result)
    {
      typedef typename iterator_traits<_InputIterator>::value_type
 _ValueType1;
      typedef typename iterator_traits<_ForwardIterator>::value_type
 _ValueType2;

      return std::__uninitialized_copy<(__is_trivial(_ValueType1)
     && __is_trivial(_ValueType2))>::
 __uninit_copy(__first, __last, __result);
    }


  template<bool _TrivialValueType>
    struct __uninitialized_fill
    {
      template<typename _ForwardIterator, typename _Tp>
        static void
        __uninit_fill(_ForwardIterator __first, _ForwardIterator __last,
        const _Tp& __x)
        {
   _ForwardIterator __cur = __first;
   try
     {
       for (; __cur != __last; ++__cur)
  std::_Construct(std::__addressof(*__cur), __x);
     }
   catch(...)
     {
       std::_Destroy(__first, __cur);
       throw;
     }
 }
    };

  template<>
    struct __uninitialized_fill<true>
    {
      template<typename _ForwardIterator, typename _Tp>
        static void
        __uninit_fill(_ForwardIterator __first, _ForwardIterator __last,
        const _Tp& __x)
        { std::fill(__first, __last, __x); }
    };
# 164 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_uninitialized.h" 3
  template<typename _ForwardIterator, typename _Tp>
    inline void
    uninitialized_fill(_ForwardIterator __first, _ForwardIterator __last,
         const _Tp& __x)
    {
      typedef typename iterator_traits<_ForwardIterator>::value_type
 _ValueType;

      std::__uninitialized_fill<__is_trivial(_ValueType)>::
 __uninit_fill(__first, __last, __x);
    }


  template<bool _TrivialValueType>
    struct __uninitialized_fill_n
    {
      template<typename _ForwardIterator, typename _Size, typename _Tp>
        static void
        __uninit_fill_n(_ForwardIterator __first, _Size __n,
   const _Tp& __x)
        {
   _ForwardIterator __cur = __first;
   try
     {
       for (; __n > 0; --__n, ++__cur)
  std::_Construct(std::__addressof(*__cur), __x);
     }
   catch(...)
     {
       std::_Destroy(__first, __cur);
       throw;
     }
 }
    };

  template<>
    struct __uninitialized_fill_n<true>
    {
      template<typename _ForwardIterator, typename _Size, typename _Tp>
        static void
        __uninit_fill_n(_ForwardIterator __first, _Size __n,
   const _Tp& __x)
        { std::fill_n(__first, __n, __x); }
    };
# 218 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_uninitialized.h" 3
  template<typename _ForwardIterator, typename _Size, typename _Tp>
    inline void
    uninitialized_fill_n(_ForwardIterator __first, _Size __n, const _Tp& __x)
    {
      typedef typename iterator_traits<_ForwardIterator>::value_type
 _ValueType;

      std::__uninitialized_fill_n<__is_trivial(_ValueType)>::
 __uninit_fill_n(__first, __n, __x);
    }







  template<typename _InputIterator, typename _ForwardIterator,
    typename _Allocator>
    _ForwardIterator
    __uninitialized_copy_a(_InputIterator __first, _InputIterator __last,
      _ForwardIterator __result, _Allocator& __alloc)
    {
      _ForwardIterator __cur = __result;
      try
 {
   for (; __first != __last; ++__first, ++__cur)
     __alloc.construct(std::__addressof(*__cur), *__first);
   return __cur;
 }
      catch(...)
 {
   std::_Destroy(__result, __cur, __alloc);
   throw;
 }
    }

  template<typename _InputIterator, typename _ForwardIterator, typename _Tp>
    inline _ForwardIterator
    __uninitialized_copy_a(_InputIterator __first, _InputIterator __last,
      _ForwardIterator __result, allocator<_Tp>&)
    { return std::uninitialized_copy(__first, __last, __result); }

  template<typename _InputIterator, typename _ForwardIterator,
    typename _Allocator>
    inline _ForwardIterator
    __uninitialized_move_a(_InputIterator __first, _InputIterator __last,
      _ForwardIterator __result, _Allocator& __alloc)
    {
      return std::__uninitialized_copy_a(std::make_move_iterator(__first),
      std::make_move_iterator(__last),
      __result, __alloc);
    }

  template<typename _ForwardIterator, typename _Tp, typename _Allocator>
    void
    __uninitialized_fill_a(_ForwardIterator __first, _ForwardIterator __last,
      const _Tp& __x, _Allocator& __alloc)
    {
      _ForwardIterator __cur = __first;
      try
 {
   for (; __cur != __last; ++__cur)
     __alloc.construct(std::__addressof(*__cur), __x);
 }
      catch(...)
 {
   std::_Destroy(__first, __cur, __alloc);
   throw;
 }
    }

  template<typename _ForwardIterator, typename _Tp, typename _Tp2>
    inline void
    __uninitialized_fill_a(_ForwardIterator __first, _ForwardIterator __last,
      const _Tp& __x, allocator<_Tp2>&)
    { std::uninitialized_fill(__first, __last, __x); }

  template<typename _ForwardIterator, typename _Size, typename _Tp,
    typename _Allocator>
    void
    __uninitialized_fill_n_a(_ForwardIterator __first, _Size __n,
        const _Tp& __x, _Allocator& __alloc)
    {
      _ForwardIterator __cur = __first;
      try
 {
   for (; __n > 0; --__n, ++__cur)
     __alloc.construct(std::__addressof(*__cur), __x);
 }
      catch(...)
 {
   std::_Destroy(__first, __cur, __alloc);
   throw;
 }
    }

  template<typename _ForwardIterator, typename _Size, typename _Tp,
    typename _Tp2>
    inline void
    __uninitialized_fill_n_a(_ForwardIterator __first, _Size __n,
        const _Tp& __x, allocator<_Tp2>&)
    { std::uninitialized_fill_n(__first, __n, __x); }
# 332 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_uninitialized.h" 3
  template<typename _InputIterator1, typename _InputIterator2,
    typename _ForwardIterator, typename _Allocator>
    inline _ForwardIterator
    __uninitialized_copy_move(_InputIterator1 __first1,
         _InputIterator1 __last1,
         _InputIterator2 __first2,
         _InputIterator2 __last2,
         _ForwardIterator __result,
         _Allocator& __alloc)
    {
      _ForwardIterator __mid = std::__uninitialized_copy_a(__first1, __last1,
          __result,
          __alloc);
      try
 {
   return std::__uninitialized_move_a(__first2, __last2, __mid, __alloc);
 }
      catch(...)
 {
   std::_Destroy(__result, __mid, __alloc);
   throw;
 }
    }





  template<typename _InputIterator1, typename _InputIterator2,
    typename _ForwardIterator, typename _Allocator>
    inline _ForwardIterator
    __uninitialized_move_copy(_InputIterator1 __first1,
         _InputIterator1 __last1,
         _InputIterator2 __first2,
         _InputIterator2 __last2,
         _ForwardIterator __result,
         _Allocator& __alloc)
    {
      _ForwardIterator __mid = std::__uninitialized_move_a(__first1, __last1,
          __result,
          __alloc);
      try
 {
   return std::__uninitialized_copy_a(__first2, __last2, __mid, __alloc);
 }
      catch(...)
 {
   std::_Destroy(__result, __mid, __alloc);
   throw;
 }
    }




  template<typename _ForwardIterator, typename _Tp, typename _InputIterator,
    typename _Allocator>
    inline _ForwardIterator
    __uninitialized_fill_move(_ForwardIterator __result, _ForwardIterator __mid,
         const _Tp& __x, _InputIterator __first,
         _InputIterator __last, _Allocator& __alloc)
    {
      std::__uninitialized_fill_a(__result, __mid, __x, __alloc);
      try
 {
   return std::__uninitialized_move_a(__first, __last, __mid, __alloc);
 }
      catch(...)
 {
   std::_Destroy(__result, __mid, __alloc);
   throw;
 }
    }




  template<typename _InputIterator, typename _ForwardIterator, typename _Tp,
    typename _Allocator>
    inline void
    __uninitialized_move_fill(_InputIterator __first1, _InputIterator __last1,
         _ForwardIterator __first2,
         _ForwardIterator __last2, const _Tp& __x,
         _Allocator& __alloc)
    {
      _ForwardIterator __mid2 = std::__uninitialized_move_a(__first1, __last1,
           __first2,
           __alloc);
      try
 {
   std::__uninitialized_fill_a(__mid2, __last2, __x, __alloc);
 }
      catch(...)
 {
   std::_Destroy(__first2, __mid2, __alloc);
   throw;
 }
    }





  template<bool _TrivialValueType>
    struct __uninitialized_default_1
    {
      template<typename _ForwardIterator>
        static void
        __uninit_default(_ForwardIterator __first, _ForwardIterator __last)
        {
   _ForwardIterator __cur = __first;
   try
     {
       for (; __cur != __last; ++__cur)
  std::_Construct(std::__addressof(*__cur));
     }
   catch(...)
     {
       std::_Destroy(__first, __cur);
       throw;
     }
 }
    };

  template<>
    struct __uninitialized_default_1<true>
    {
      template<typename _ForwardIterator>
        static void
        __uninit_default(_ForwardIterator __first, _ForwardIterator __last)
        {
   typedef typename iterator_traits<_ForwardIterator>::value_type
     _ValueType;

   std::fill(__first, __last, _ValueType());
 }
    };

  template<bool _TrivialValueType>
    struct __uninitialized_default_n_1
    {
      template<typename _ForwardIterator, typename _Size>
        static void
        __uninit_default_n(_ForwardIterator __first, _Size __n)
        {
   _ForwardIterator __cur = __first;
   try
     {
       for (; __n > 0; --__n, ++__cur)
  std::_Construct(std::__addressof(*__cur));
     }
   catch(...)
     {
       std::_Destroy(__first, __cur);
       throw;
     }
 }
    };

  template<>
    struct __uninitialized_default_n_1<true>
    {
      template<typename _ForwardIterator, typename _Size>
        static void
        __uninit_default_n(_ForwardIterator __first, _Size __n)
        {
   typedef typename iterator_traits<_ForwardIterator>::value_type
     _ValueType;

   std::fill_n(__first, __n, _ValueType());
 }
    };




  template<typename _ForwardIterator>
    inline void
    __uninitialized_default(_ForwardIterator __first,
       _ForwardIterator __last)
    {
      typedef typename iterator_traits<_ForwardIterator>::value_type
 _ValueType;

      std::__uninitialized_default_1<__is_trivial(_ValueType)>::
 __uninit_default(__first, __last);
    }



  template<typename _ForwardIterator, typename _Size>
    inline void
    __uninitialized_default_n(_ForwardIterator __first, _Size __n)
    {
      typedef typename iterator_traits<_ForwardIterator>::value_type
 _ValueType;

      std::__uninitialized_default_n_1<__is_trivial(_ValueType)>::
 __uninit_default_n(__first, __n);
    }





  template<typename _ForwardIterator, typename _Allocator>
    void
    __uninitialized_default_a(_ForwardIterator __first,
         _ForwardIterator __last,
         _Allocator& __alloc)
    {
      _ForwardIterator __cur = __first;
      try
 {
   for (; __cur != __last; ++__cur)
     __alloc.construct(std::__addressof(*__cur));
 }
      catch(...)
 {
   std::_Destroy(__first, __cur, __alloc);
   throw;
 }
    }

  template<typename _ForwardIterator, typename _Tp>
    inline void
    __uninitialized_default_a(_ForwardIterator __first,
         _ForwardIterator __last,
         allocator<_Tp>&)
    { std::__uninitialized_default(__first, __last); }





  template<typename _ForwardIterator, typename _Size, typename _Allocator>
    void
    __uninitialized_default_n_a(_ForwardIterator __first, _Size __n,
    _Allocator& __alloc)
    {
      _ForwardIterator __cur = __first;
      try
 {
   for (; __n > 0; --__n, ++__cur)
     __alloc.construct(std::__addressof(*__cur));
 }
      catch(...)
 {
   std::_Destroy(__first, __cur, __alloc);
   throw;
 }
    }

  template<typename _ForwardIterator, typename _Size, typename _Tp>
    inline void
    __uninitialized_default_n_a(_ForwardIterator __first, _Size __n,
    allocator<_Tp>&)
    { std::__uninitialized_default_n(__first, __n); }


  template<typename _InputIterator, typename _Size,
    typename _ForwardIterator>
    _ForwardIterator
    __uninitialized_copy_n(_InputIterator __first, _Size __n,
      _ForwardIterator __result, input_iterator_tag)
    {
      _ForwardIterator __cur = __result;
      try
 {
   for (; __n > 0; --__n, ++__first, ++__cur)
     std::_Construct(std::__addressof(*__cur), *__first);
   return __cur;
 }
      catch(...)
 {
   std::_Destroy(__result, __cur);
   throw;
 }
    }

  template<typename _RandomAccessIterator, typename _Size,
    typename _ForwardIterator>
    inline _ForwardIterator
    __uninitialized_copy_n(_RandomAccessIterator __first, _Size __n,
      _ForwardIterator __result,
      random_access_iterator_tag)
    { return std::uninitialized_copy(__first, __first + __n, __result); }
# 629 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_uninitialized.h" 3
  template<typename _InputIterator, typename _Size, typename _ForwardIterator>
    inline _ForwardIterator
    uninitialized_copy_n(_InputIterator __first, _Size __n,
    _ForwardIterator __result)
    { return std::__uninitialized_copy_n(__first, __n, __result,
      std::__iterator_category(__first)); }



}
# 65 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/vector" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 1 3
# 63 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/initializer_list" 1 3
# 33 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/initializer_list" 3
       
# 34 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/initializer_list" 3



#pragma GCC visibility push(default)



namespace std
{

  template<class _E>
    class initializer_list
    {
    public:
      typedef _E value_type;
      typedef const _E& reference;
      typedef const _E& const_reference;
      typedef size_t size_type;
      typedef const _E* iterator;
      typedef const _E* const_iterator;

    private:
      iterator _M_array;
      size_type _M_len;


      constexpr initializer_list(const_iterator __a, size_type __l)
      : _M_array(__a), _M_len(__l) { }

    public:
      constexpr initializer_list() : _M_array(0), _M_len(0) { }


      constexpr size_type
      size() { return _M_len; }


      constexpr const_iterator
      begin() { return _M_array; }


      constexpr const_iterator
      end() { return begin() + size(); }
  };






  template<class _Tp>
    constexpr const _Tp*
    begin(initializer_list<_Tp> __ils)
    { return __ils.begin(); }






  template<class _Tp>
    constexpr const _Tp*
    end(initializer_list<_Tp> __ils)
    { return __ils.end(); }
}

#pragma GCC visibility pop
# 64 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 2 3

namespace std __attribute__ ((__visibility__ ("default")))
{



  template<typename _Tp, typename _Alloc>
    struct _Vector_base
    {
      typedef typename _Alloc::template rebind<_Tp>::other _Tp_alloc_type;

      struct _Vector_impl
      : public _Tp_alloc_type
      {
 typename _Tp_alloc_type::pointer _M_start;
 typename _Tp_alloc_type::pointer _M_finish;
 typename _Tp_alloc_type::pointer _M_end_of_storage;

 _Vector_impl()
 : _Tp_alloc_type(), _M_start(0), _M_finish(0), _M_end_of_storage(0)
 { }

 _Vector_impl(_Tp_alloc_type const& __a)
 : _Tp_alloc_type(__a), _M_start(0), _M_finish(0), _M_end_of_storage(0)
 { }
      };

    public:
      typedef _Alloc allocator_type;

      _Tp_alloc_type&
      _M_get_Tp_allocator()
      { return *static_cast<_Tp_alloc_type*>(&this->_M_impl); }

      const _Tp_alloc_type&
      _M_get_Tp_allocator() const
      { return *static_cast<const _Tp_alloc_type*>(&this->_M_impl); }

      allocator_type
      get_allocator() const
      { return allocator_type(_M_get_Tp_allocator()); }

      _Vector_base()
      : _M_impl() { }

      _Vector_base(const allocator_type& __a)
      : _M_impl(__a) { }

      _Vector_base(size_t __n)
      : _M_impl()
      {
 this->_M_impl._M_start = this->_M_allocate(__n);
 this->_M_impl._M_finish = this->_M_impl._M_start;
 this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
      }

      _Vector_base(size_t __n, const allocator_type& __a)
      : _M_impl(__a)
      {
 this->_M_impl._M_start = this->_M_allocate(__n);
 this->_M_impl._M_finish = this->_M_impl._M_start;
 this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
      }


      _Vector_base(_Vector_base&& __x)
      : _M_impl(__x._M_get_Tp_allocator())
      {
 this->_M_impl._M_start = __x._M_impl._M_start;
 this->_M_impl._M_finish = __x._M_impl._M_finish;
 this->_M_impl._M_end_of_storage = __x._M_impl._M_end_of_storage;
 __x._M_impl._M_start = 0;
 __x._M_impl._M_finish = 0;
 __x._M_impl._M_end_of_storage = 0;
      }


      ~_Vector_base()
      { _M_deallocate(this->_M_impl._M_start, this->_M_impl._M_end_of_storage
        - this->_M_impl._M_start); }

    public:
      _Vector_impl _M_impl;

      typename _Tp_alloc_type::pointer
      _M_allocate(size_t __n)
      { return __n != 0 ? _M_impl.allocate(__n) : 0; }

      void
      _M_deallocate(typename _Tp_alloc_type::pointer __p, size_t __n)
      {
 if (__p)
   _M_impl.deallocate(__p, __n);
      }
    };
# 179 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
  template<typename _Tp, typename _Alloc = std::allocator<_Tp> >
    class vector : protected _Vector_base<_Tp, _Alloc>
    {

      typedef typename _Alloc::value_type _Alloc_value_type;
     
     

      typedef _Vector_base<_Tp, _Alloc> _Base;
      typedef typename _Base::_Tp_alloc_type _Tp_alloc_type;

    public:
      typedef _Tp value_type;
      typedef typename _Tp_alloc_type::pointer pointer;
      typedef typename _Tp_alloc_type::const_pointer const_pointer;
      typedef typename _Tp_alloc_type::reference reference;
      typedef typename _Tp_alloc_type::const_reference const_reference;
      typedef __gnu_cxx::__normal_iterator<pointer, vector> iterator;
      typedef __gnu_cxx::__normal_iterator<const_pointer, vector>
      const_iterator;
      typedef std::reverse_iterator<const_iterator> const_reverse_iterator;
      typedef std::reverse_iterator<iterator> reverse_iterator;
      typedef size_t size_type;
      typedef ptrdiff_t difference_type;
      typedef _Alloc allocator_type;

    protected:
      using _Base::_M_allocate;
      using _Base::_M_deallocate;
      using _Base::_M_impl;
      using _Base::_M_get_Tp_allocator;

    public:





      vector()
      : _Base() { }





      explicit
      vector(const allocator_type& __a)
      : _Base(__a) { }
# 236 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      explicit
      vector(size_type __n)
      : _Base(__n)
      { _M_default_initialize(__n); }
# 249 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      vector(size_type __n, const value_type& __value,
      const allocator_type& __a = allocator_type())
      : _Base(__n, __a)
      { _M_fill_initialize(__n, __value); }
# 278 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      vector(const vector& __x)
      : _Base(__x.size(), __x._M_get_Tp_allocator())
      { this->_M_impl._M_finish =
   std::__uninitialized_copy_a(__x.begin(), __x.end(),
          this->_M_impl._M_start,
          _M_get_Tp_allocator());
      }
# 294 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      vector(vector&& __x)
      : _Base(std::move(__x)) { }
# 308 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      vector(initializer_list<value_type> __l,
      const allocator_type& __a = allocator_type())
      : _Base(__a)
      {
 _M_range_initialize(__l.begin(), __l.end(),
       random_access_iterator_tag());
      }
# 333 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      template<typename _InputIterator>
        vector(_InputIterator __first, _InputIterator __last,
        const allocator_type& __a = allocator_type())
 : _Base(__a)
        {

   typedef typename std::__is_integer<_InputIterator>::__type _Integral;
   _M_initialize_dispatch(__first, __last, _Integral());
 }







      ~vector()
      { std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
        _M_get_Tp_allocator()); }
# 361 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      vector&
      operator=(const vector& __x);
# 372 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      vector&
      operator=(vector&& __x)
      {


 this->clear();
 this->swap(__x);
 return *this;
      }
# 393 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      vector&
      operator=(initializer_list<value_type> __l)
      {
 this->assign(__l.begin(), __l.end());
 return *this;
      }
# 411 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      void
      assign(size_type __n, const value_type& __val)
      { _M_fill_assign(__n, __val); }
# 427 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      template<typename _InputIterator>
        void
        assign(_InputIterator __first, _InputIterator __last)
        {

   typedef typename std::__is_integer<_InputIterator>::__type _Integral;
   _M_assign_dispatch(__first, __last, _Integral());
 }
# 448 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      void
      assign(initializer_list<value_type> __l)
      { this->assign(__l.begin(), __l.end()); }



      using _Base::get_allocator;







      iterator
      begin()
      { return iterator(this->_M_impl._M_start); }






      const_iterator
      begin() const
      { return const_iterator(this->_M_impl._M_start); }






      iterator
      end()
      { return iterator(this->_M_impl._M_finish); }






      const_iterator
      end() const
      { return const_iterator(this->_M_impl._M_finish); }






      reverse_iterator
      rbegin()
      { return reverse_iterator(end()); }






      const_reverse_iterator
      rbegin() const
      { return const_reverse_iterator(end()); }






      reverse_iterator
      rend()
      { return reverse_iterator(begin()); }






      const_reverse_iterator
      rend() const
      { return const_reverse_iterator(begin()); }







      const_iterator
      cbegin() const
      { return const_iterator(this->_M_impl._M_start); }






      const_iterator
      cend() const
      { return const_iterator(this->_M_impl._M_finish); }






      const_reverse_iterator
      crbegin() const
      { return const_reverse_iterator(end()); }






      const_reverse_iterator
      crend() const
      { return const_reverse_iterator(begin()); }




      size_type
      size() const
      { return size_type(this->_M_impl._M_finish - this->_M_impl._M_start); }


      size_type
      max_size() const
      { return _M_get_Tp_allocator().max_size(); }
# 588 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      void
      resize(size_type __new_size)
      {
 if (__new_size > size())
   _M_default_append(__new_size - size());
 else if (__new_size < size())
   _M_erase_at_end(this->_M_impl._M_start + __new_size);
      }
# 608 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      void
      resize(size_type __new_size, const value_type& __x)
      {
 if (__new_size > size())
   insert(end(), __new_size - size(), __x);
 else if (__new_size < size())
   _M_erase_at_end(this->_M_impl._M_start + __new_size);
      }
# 640 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      void
      shrink_to_fit()
      { std::__shrink_to_fit<vector>::_S_do_it(*this); }






      size_type
      capacity() const
      { return size_type(this->_M_impl._M_end_of_storage
    - this->_M_impl._M_start); }





      bool
      empty() const
      { return begin() == end(); }
# 679 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      void
      reserve(size_type __n);
# 694 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      reference
      operator[](size_type __n)
      { return *(this->_M_impl._M_start + __n); }
# 709 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      const_reference
      operator[](size_type __n) const
      { return *(this->_M_impl._M_start + __n); }

    protected:

      void
      _M_range_check(size_type __n) const
      {
 if (__n >= this->size())
   __throw_out_of_range(("vector::_M_range_check"));
      }

    public:
# 734 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      reference
      at(size_type __n)
      {
 _M_range_check(__n);
 return (*this)[__n];
      }
# 752 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      const_reference
      at(size_type __n) const
      {
 _M_range_check(__n);
 return (*this)[__n];
      }





      reference
      front()
      { return *begin(); }





      const_reference
      front() const
      { return *begin(); }





      reference
      back()
      { return *(end() - 1); }





      const_reference
      back() const
      { return *(end() - 1); }
# 799 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      _Tp*



      data()
      { return std::__addressof(front()); }


      const _Tp*



      data() const
      { return std::__addressof(front()); }
# 825 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      void
      push_back(const value_type& __x)
      {
 if (this->_M_impl._M_finish != this->_M_impl._M_end_of_storage)
   {
     this->_M_impl.construct(this->_M_impl._M_finish, __x);
     ++this->_M_impl._M_finish;
   }
 else
   _M_insert_aux(end(), __x);
      }


      void
      push_back(value_type&& __x)
      { emplace_back(std::move(__x)); }

      template<typename... _Args>
        void
        emplace_back(_Args&&... __args);
# 856 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      void
      pop_back()
      {
 --this->_M_impl._M_finish;
 this->_M_impl.destroy(this->_M_impl._M_finish);
      }
# 876 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      template<typename... _Args>
        iterator
        emplace(iterator __position, _Args&&... __args);
# 892 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      iterator
      insert(iterator __position, const value_type& __x);
# 907 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      iterator
      insert(iterator __position, value_type&& __x)
      { return emplace(__position, std::move(__x)); }
# 924 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      void
      insert(iterator __position, initializer_list<value_type> __l)
      { this->insert(__position, __l.begin(), __l.end()); }
# 942 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      void
      insert(iterator __position, size_type __n, const value_type& __x)
      { _M_fill_insert(__position, __n, __x); }
# 960 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      template<typename _InputIterator>
        void
        insert(iterator __position, _InputIterator __first,
        _InputIterator __last)
        {

   typedef typename std::__is_integer<_InputIterator>::__type _Integral;
   _M_insert_dispatch(__position, __first, __last, _Integral());
 }
# 985 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      iterator
      erase(iterator __position);
# 1006 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      iterator
      erase(iterator __first, iterator __last);
# 1018 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      void
      swap(vector& __x)
      {
 std::swap(this->_M_impl._M_start, __x._M_impl._M_start);
 std::swap(this->_M_impl._M_finish, __x._M_impl._M_finish);
 std::swap(this->_M_impl._M_end_of_storage,
    __x._M_impl._M_end_of_storage);



 std::__alloc_swap<_Tp_alloc_type>::_S_do_it(_M_get_Tp_allocator(),
          __x._M_get_Tp_allocator());
      }







      void
      clear()
      { _M_erase_at_end(this->_M_impl._M_start); }

    protected:




      template<typename _ForwardIterator>
        pointer
        _M_allocate_and_copy(size_type __n,
        _ForwardIterator __first, _ForwardIterator __last)
        {
   pointer __result = this->_M_allocate(__n);
   try
     {
       std::__uninitialized_copy_a(__first, __last, __result,
       _M_get_Tp_allocator());
       return __result;
     }
   catch(...)
     {
       _M_deallocate(__result, __n);
       throw;
     }
 }
# 1073 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      template<typename _Integer>
        void
        _M_initialize_dispatch(_Integer __n, _Integer __value, __true_type)
        {
   this->_M_impl._M_start = _M_allocate(static_cast<size_type>(__n));
   this->_M_impl._M_end_of_storage =
     this->_M_impl._M_start + static_cast<size_type>(__n);
   _M_fill_initialize(static_cast<size_type>(__n), __value);
 }


      template<typename _InputIterator>
        void
        _M_initialize_dispatch(_InputIterator __first, _InputIterator __last,
          __false_type)
        {
   typedef typename std::iterator_traits<_InputIterator>::
     iterator_category _IterCategory;
   _M_range_initialize(__first, __last, _IterCategory());
 }


      template<typename _InputIterator>
        void
        _M_range_initialize(_InputIterator __first,
       _InputIterator __last, std::input_iterator_tag)
        {
   for (; __first != __last; ++__first)
     push_back(*__first);
 }


      template<typename _ForwardIterator>
        void
        _M_range_initialize(_ForwardIterator __first,
       _ForwardIterator __last, std::forward_iterator_tag)
        {
   const size_type __n = std::distance(__first, __last);
   this->_M_impl._M_start = this->_M_allocate(__n);
   this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
   this->_M_impl._M_finish =
     std::__uninitialized_copy_a(__first, __last,
     this->_M_impl._M_start,
     _M_get_Tp_allocator());
 }



      void
      _M_fill_initialize(size_type __n, const value_type& __value)
      {
 std::__uninitialized_fill_n_a(this->_M_impl._M_start, __n, __value,
          _M_get_Tp_allocator());
 this->_M_impl._M_finish = this->_M_impl._M_end_of_storage;
      }



      void
      _M_default_initialize(size_type __n)
      {
 std::__uninitialized_default_n_a(this->_M_impl._M_start, __n,
      _M_get_Tp_allocator());
 this->_M_impl._M_finish = this->_M_impl._M_end_of_storage;
      }
# 1147 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      template<typename _Integer>
        void
        _M_assign_dispatch(_Integer __n, _Integer __val, __true_type)
        { _M_fill_assign(__n, __val); }


      template<typename _InputIterator>
        void
        _M_assign_dispatch(_InputIterator __first, _InputIterator __last,
      __false_type)
        {
   typedef typename std::iterator_traits<_InputIterator>::
     iterator_category _IterCategory;
   _M_assign_aux(__first, __last, _IterCategory());
 }


      template<typename _InputIterator>
        void
        _M_assign_aux(_InputIterator __first, _InputIterator __last,
        std::input_iterator_tag);


      template<typename _ForwardIterator>
        void
        _M_assign_aux(_ForwardIterator __first, _ForwardIterator __last,
        std::forward_iterator_tag);



      void
      _M_fill_assign(size_type __n, const value_type& __val);
# 1187 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
      template<typename _Integer>
        void
        _M_insert_dispatch(iterator __pos, _Integer __n, _Integer __val,
      __true_type)
        { _M_fill_insert(__pos, __n, __val); }


      template<typename _InputIterator>
        void
        _M_insert_dispatch(iterator __pos, _InputIterator __first,
      _InputIterator __last, __false_type)
        {
   typedef typename std::iterator_traits<_InputIterator>::
     iterator_category _IterCategory;
   _M_range_insert(__pos, __first, __last, _IterCategory());
 }


      template<typename _InputIterator>
        void
        _M_range_insert(iterator __pos, _InputIterator __first,
   _InputIterator __last, std::input_iterator_tag);


      template<typename _ForwardIterator>
        void
        _M_range_insert(iterator __pos, _ForwardIterator __first,
   _ForwardIterator __last, std::forward_iterator_tag);



      void
      _M_fill_insert(iterator __pos, size_type __n, const value_type& __x);



      void
      _M_default_append(size_type __n);







      template<typename... _Args>
        void
        _M_insert_aux(iterator __position, _Args&&... __args);



      size_type
      _M_check_len(size_type __n, const char* __s) const
      {
 if (max_size() - size() < __n)
   __throw_length_error((__s));

 const size_type __len = size() + std::max(size(), __n);
 return (__len < size() || __len > max_size()) ? max_size() : __len;
      }





      void
      _M_erase_at_end(pointer __pos)
      {
 std::_Destroy(__pos, this->_M_impl._M_finish, _M_get_Tp_allocator());
 this->_M_impl._M_finish = __pos;
      }
    };
# 1271 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
  template<typename _Tp, typename _Alloc>
    inline bool
    operator==(const vector<_Tp, _Alloc>& __x, const vector<_Tp, _Alloc>& __y)
    { return (__x.size() == __y.size()
       && std::equal(__x.begin(), __x.end(), __y.begin())); }
# 1288 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_vector.h" 3
  template<typename _Tp, typename _Alloc>
    inline bool
    operator<(const vector<_Tp, _Alloc>& __x, const vector<_Tp, _Alloc>& __y)
    { return std::lexicographical_compare(__x.begin(), __x.end(),
       __y.begin(), __y.end()); }


  template<typename _Tp, typename _Alloc>
    inline bool
    operator!=(const vector<_Tp, _Alloc>& __x, const vector<_Tp, _Alloc>& __y)
    { return !(__x == __y); }


  template<typename _Tp, typename _Alloc>
    inline bool
    operator>(const vector<_Tp, _Alloc>& __x, const vector<_Tp, _Alloc>& __y)
    { return __y < __x; }


  template<typename _Tp, typename _Alloc>
    inline bool
    operator<=(const vector<_Tp, _Alloc>& __x, const vector<_Tp, _Alloc>& __y)
    { return !(__y < __x); }


  template<typename _Tp, typename _Alloc>
    inline bool
    operator>=(const vector<_Tp, _Alloc>& __x, const vector<_Tp, _Alloc>& __y)
    { return !(__x < __y); }


  template<typename _Tp, typename _Alloc>
    inline void
    swap(vector<_Tp, _Alloc>& __x, vector<_Tp, _Alloc>& __y)
    { __x.swap(__y); }


}
# 66 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/vector" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_bvector.h" 1 3
# 62 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_bvector.h" 3
namespace std __attribute__ ((__visibility__ ("default")))
{


  typedef unsigned long _Bit_type;
  enum { _S_word_bit = int(8 * sizeof(_Bit_type)) };

  struct _Bit_reference
  {
    _Bit_type * _M_p;
    _Bit_type _M_mask;

    _Bit_reference(_Bit_type * __x, _Bit_type __y)
    : _M_p(__x), _M_mask(__y) { }

    _Bit_reference() : _M_p(0), _M_mask(0) { }

    operator bool() const
    { return !!(*_M_p & _M_mask); }

    _Bit_reference&
    operator=(bool __x)
    {
      if (__x)
 *_M_p |= _M_mask;
      else
 *_M_p &= ~_M_mask;
      return *this;
    }

    _Bit_reference&
    operator=(const _Bit_reference& __x)
    { return *this = bool(__x); }

    bool
    operator==(const _Bit_reference& __x) const
    { return bool(*this) == bool(__x); }

    bool
    operator<(const _Bit_reference& __x) const
    { return !bool(*this) && bool(__x); }

    void
    flip()
    { *_M_p ^= _M_mask; }
  };

  struct _Bit_iterator_base
  : public std::iterator<std::random_access_iterator_tag, bool>
  {
    _Bit_type * _M_p;
    unsigned int _M_offset;

    _Bit_iterator_base(_Bit_type * __x, unsigned int __y)
    : _M_p(__x), _M_offset(__y) { }

    void
    _M_bump_up()
    {
      if (_M_offset++ == int(_S_word_bit) - 1)
 {
   _M_offset = 0;
   ++_M_p;
 }
    }

    void
    _M_bump_down()
    {
      if (_M_offset-- == 0)
 {
   _M_offset = int(_S_word_bit) - 1;
   --_M_p;
 }
    }

    void
    _M_incr(ptrdiff_t __i)
    {
      difference_type __n = __i + _M_offset;
      _M_p += __n / int(_S_word_bit);
      __n = __n % int(_S_word_bit);
      if (__n < 0)
 {
   __n += int(_S_word_bit);
   --_M_p;
 }
      _M_offset = static_cast<unsigned int>(__n);
    }

    bool
    operator==(const _Bit_iterator_base& __i) const
    { return _M_p == __i._M_p && _M_offset == __i._M_offset; }

    bool
    operator<(const _Bit_iterator_base& __i) const
    {
      return _M_p < __i._M_p
      || (_M_p == __i._M_p && _M_offset < __i._M_offset);
    }

    bool
    operator!=(const _Bit_iterator_base& __i) const
    { return !(*this == __i); }

    bool
    operator>(const _Bit_iterator_base& __i) const
    { return __i < *this; }

    bool
    operator<=(const _Bit_iterator_base& __i) const
    { return !(__i < *this); }

    bool
    operator>=(const _Bit_iterator_base& __i) const
    { return !(*this < __i); }
  };

  inline ptrdiff_t
  operator-(const _Bit_iterator_base& __x, const _Bit_iterator_base& __y)
  {
    return (int(_S_word_bit) * (__x._M_p - __y._M_p)
     + __x._M_offset - __y._M_offset);
  }

  struct _Bit_iterator : public _Bit_iterator_base
  {
    typedef _Bit_reference reference;
    typedef _Bit_reference* pointer;
    typedef _Bit_iterator iterator;

    _Bit_iterator() : _Bit_iterator_base(0, 0) { }

    _Bit_iterator(_Bit_type * __x, unsigned int __y)
    : _Bit_iterator_base(__x, __y) { }

    reference
    operator*() const
    { return reference(_M_p, 1UL << _M_offset); }

    iterator&
    operator++()
    {
      _M_bump_up();
      return *this;
    }

    iterator
    operator++(int)
    {
      iterator __tmp = *this;
      _M_bump_up();
      return __tmp;
    }

    iterator&
    operator--()
    {
      _M_bump_down();
      return *this;
    }

    iterator
    operator--(int)
    {
      iterator __tmp = *this;
      _M_bump_down();
      return __tmp;
    }

    iterator&
    operator+=(difference_type __i)
    {
      _M_incr(__i);
      return *this;
    }

    iterator&
    operator-=(difference_type __i)
    {
      *this += -__i;
      return *this;
    }

    iterator
    operator+(difference_type __i) const
    {
      iterator __tmp = *this;
      return __tmp += __i;
    }

    iterator
    operator-(difference_type __i) const
    {
      iterator __tmp = *this;
      return __tmp -= __i;
    }

    reference
    operator[](difference_type __i) const
    { return *(*this + __i); }
  };

  inline _Bit_iterator
  operator+(ptrdiff_t __n, const _Bit_iterator& __x)
  { return __x + __n; }

  struct _Bit_const_iterator : public _Bit_iterator_base
  {
    typedef bool reference;
    typedef bool const_reference;
    typedef const bool* pointer;
    typedef _Bit_const_iterator const_iterator;

    _Bit_const_iterator() : _Bit_iterator_base(0, 0) { }

    _Bit_const_iterator(_Bit_type * __x, unsigned int __y)
    : _Bit_iterator_base(__x, __y) { }

    _Bit_const_iterator(const _Bit_iterator& __x)
    : _Bit_iterator_base(__x._M_p, __x._M_offset) { }

    const_reference
    operator*() const
    { return _Bit_reference(_M_p, 1UL << _M_offset); }

    const_iterator&
    operator++()
    {
      _M_bump_up();
      return *this;
    }

    const_iterator
    operator++(int)
    {
      const_iterator __tmp = *this;
      _M_bump_up();
      return __tmp;
    }

    const_iterator&
    operator--()
    {
      _M_bump_down();
      return *this;
    }

    const_iterator
    operator--(int)
    {
      const_iterator __tmp = *this;
      _M_bump_down();
      return __tmp;
    }

    const_iterator&
    operator+=(difference_type __i)
    {
      _M_incr(__i);
      return *this;
    }

    const_iterator&
    operator-=(difference_type __i)
    {
      *this += -__i;
      return *this;
    }

    const_iterator
    operator+(difference_type __i) const
    {
      const_iterator __tmp = *this;
      return __tmp += __i;
    }

    const_iterator
    operator-(difference_type __i) const
    {
      const_iterator __tmp = *this;
      return __tmp -= __i;
    }

    const_reference
    operator[](difference_type __i) const
    { return *(*this + __i); }
  };

  inline _Bit_const_iterator
  operator+(ptrdiff_t __n, const _Bit_const_iterator& __x)
  { return __x + __n; }

  inline void
  __fill_bvector(_Bit_iterator __first, _Bit_iterator __last, bool __x)
  {
    for (; __first != __last; ++__first)
      *__first = __x;
  }

  inline void
  fill(_Bit_iterator __first, _Bit_iterator __last, const bool& __x)
  {
    if (__first._M_p != __last._M_p)
      {
 std::fill(__first._M_p + 1, __last._M_p, __x ? ~0 : 0);
 __fill_bvector(__first, _Bit_iterator(__first._M_p + 1, 0), __x);
 __fill_bvector(_Bit_iterator(__last._M_p, 0), __last, __x);
      }
    else
      __fill_bvector(__first, __last, __x);
  }

  template<typename _Alloc>
    struct _Bvector_base
    {
      typedef typename _Alloc::template rebind<_Bit_type>::other
        _Bit_alloc_type;

      struct _Bvector_impl
      : public _Bit_alloc_type
      {
 _Bit_iterator _M_start;
 _Bit_iterator _M_finish;
 _Bit_type* _M_end_of_storage;

 _Bvector_impl()
 : _Bit_alloc_type(), _M_start(), _M_finish(), _M_end_of_storage(0)
 { }

 _Bvector_impl(const _Bit_alloc_type& __a)
 : _Bit_alloc_type(__a), _M_start(), _M_finish(), _M_end_of_storage(0)
 { }
      };

    public:
      typedef _Alloc allocator_type;

      _Bit_alloc_type&
      _M_get_Bit_allocator()
      { return *static_cast<_Bit_alloc_type*>(&this->_M_impl); }

      const _Bit_alloc_type&
      _M_get_Bit_allocator() const
      { return *static_cast<const _Bit_alloc_type*>(&this->_M_impl); }

      allocator_type
      get_allocator() const
      { return allocator_type(_M_get_Bit_allocator()); }

      _Bvector_base()
      : _M_impl() { }

      _Bvector_base(const allocator_type& __a)
      : _M_impl(__a) { }


      _Bvector_base(_Bvector_base&& __x)
      : _M_impl(__x._M_get_Bit_allocator())
      {
 this->_M_impl._M_start = __x._M_impl._M_start;
 this->_M_impl._M_finish = __x._M_impl._M_finish;
 this->_M_impl._M_end_of_storage = __x._M_impl._M_end_of_storage;
 __x._M_impl._M_start = _Bit_iterator();
 __x._M_impl._M_finish = _Bit_iterator();
 __x._M_impl._M_end_of_storage = 0;
      }


      ~_Bvector_base()
      { this->_M_deallocate(); }

    protected:
      _Bvector_impl _M_impl;

      _Bit_type*
      _M_allocate(size_t __n)
      { return _M_impl.allocate((__n + int(_S_word_bit) - 1)
    / int(_S_word_bit)); }

      void
      _M_deallocate()
      {
 if (_M_impl._M_start._M_p)
   _M_impl.deallocate(_M_impl._M_start._M_p,
        _M_impl._M_end_of_storage - _M_impl._M_start._M_p);
      }
    };


}




namespace std __attribute__ ((__visibility__ ("default")))
{

# 478 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_bvector.h" 3
template<typename _Alloc>
  class vector<bool, _Alloc> : protected _Bvector_base<_Alloc>
  {
    typedef _Bvector_base<_Alloc> _Base;


    template<typename> friend class hash;


  public:
    typedef bool value_type;
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef _Bit_reference reference;
    typedef bool const_reference;
    typedef _Bit_reference* pointer;
    typedef const bool* const_pointer;
    typedef _Bit_iterator iterator;
    typedef _Bit_const_iterator const_iterator;
    typedef std::reverse_iterator<const_iterator> const_reverse_iterator;
    typedef std::reverse_iterator<iterator> reverse_iterator;
    typedef _Alloc allocator_type;

    allocator_type get_allocator() const
    { return _Base::get_allocator(); }

  protected:
    using _Base::_M_allocate;
    using _Base::_M_deallocate;
    using _Base::_M_get_Bit_allocator;

  public:
    vector()
    : _Base() { }

    explicit
    vector(const allocator_type& __a)
    : _Base(__a) { }

    explicit
    vector(size_type __n, const bool& __value = bool(),
    const allocator_type& __a = allocator_type())
    : _Base(__a)
    {
      _M_initialize(__n);
      std::fill(this->_M_impl._M_start._M_p, this->_M_impl._M_end_of_storage,
  __value ? ~0 : 0);
    }

    vector(const vector& __x)
    : _Base(__x._M_get_Bit_allocator())
    {
      _M_initialize(__x.size());
      _M_copy_aligned(__x.begin(), __x.end(), this->_M_impl._M_start);
    }


    vector(vector&& __x)
    : _Base(std::move(__x)) { }

    vector(initializer_list<bool> __l,
    const allocator_type& __a = allocator_type())
    : _Base(__a)
    {
      _M_initialize_range(__l.begin(), __l.end(),
     random_access_iterator_tag());
    }


    template<typename _InputIterator>
      vector(_InputIterator __first, _InputIterator __last,
      const allocator_type& __a = allocator_type())
      : _Base(__a)
      {
 typedef typename std::__is_integer<_InputIterator>::__type _Integral;
 _M_initialize_dispatch(__first, __last, _Integral());
      }

    ~vector() { }

    vector&
    operator=(const vector& __x)
    {
      if (&__x == this)
 return *this;
      if (__x.size() > capacity())
 {
   this->_M_deallocate();
   _M_initialize(__x.size());
 }
      this->_M_impl._M_finish = _M_copy_aligned(__x.begin(), __x.end(),
      begin());
      return *this;
    }


    vector&
    operator=(vector&& __x)
    {


      this->clear();
      this->swap(__x);
      return *this;
    }

    vector&
    operator=(initializer_list<bool> __l)
    {
      this->assign (__l.begin(), __l.end());
      return *this;
    }






    void
    assign(size_type __n, const bool& __x)
    { _M_fill_assign(__n, __x); }

    template<typename _InputIterator>
      void
      assign(_InputIterator __first, _InputIterator __last)
      {
 typedef typename std::__is_integer<_InputIterator>::__type _Integral;
 _M_assign_dispatch(__first, __last, _Integral());
      }


    void
    assign(initializer_list<bool> __l)
    { this->assign(__l.begin(), __l.end()); }


    iterator
    begin()
    { return this->_M_impl._M_start; }

    const_iterator
    begin() const
    { return this->_M_impl._M_start; }

    iterator
    end()
    { return this->_M_impl._M_finish; }

    const_iterator
    end() const
    { return this->_M_impl._M_finish; }

    reverse_iterator
    rbegin()
    { return reverse_iterator(end()); }

    const_reverse_iterator
    rbegin() const
    { return const_reverse_iterator(end()); }

    reverse_iterator
    rend()
    { return reverse_iterator(begin()); }

    const_reverse_iterator
    rend() const
    { return const_reverse_iterator(begin()); }


    const_iterator
    cbegin() const
    { return this->_M_impl._M_start; }

    const_iterator
    cend() const
    { return this->_M_impl._M_finish; }

    const_reverse_iterator
    crbegin() const
    { return const_reverse_iterator(end()); }

    const_reverse_iterator
    crend() const
    { return const_reverse_iterator(begin()); }


    size_type
    size() const
    { return size_type(end() - begin()); }

    size_type
    max_size() const
    {
      const size_type __isize =
 __gnu_cxx::__numeric_traits<difference_type>::__max
 - int(_S_word_bit) + 1;
      const size_type __asize = _M_get_Bit_allocator().max_size();
      return (__asize <= __isize / int(_S_word_bit)
       ? __asize * int(_S_word_bit) : __isize);
    }

    size_type
    capacity() const
    { return size_type(const_iterator(this->_M_impl._M_end_of_storage, 0)
         - begin()); }

    bool
    empty() const
    { return begin() == end(); }

    reference
    operator[](size_type __n)
    {
      return *iterator(this->_M_impl._M_start._M_p
         + __n / int(_S_word_bit), __n % int(_S_word_bit));
    }

    const_reference
    operator[](size_type __n) const
    {
      return *const_iterator(this->_M_impl._M_start._M_p
        + __n / int(_S_word_bit), __n % int(_S_word_bit));
    }

  protected:
    void
    _M_range_check(size_type __n) const
    {
      if (__n >= this->size())
        __throw_out_of_range(("vector<bool>::_M_range_check"));
    }

  public:
    reference
    at(size_type __n)
    { _M_range_check(__n); return (*this)[__n]; }

    const_reference
    at(size_type __n) const
    { _M_range_check(__n); return (*this)[__n]; }

    void
    reserve(size_type __n);

    reference
    front()
    { return *begin(); }

    const_reference
    front() const
    { return *begin(); }

    reference
    back()
    { return *(end() - 1); }

    const_reference
    back() const
    { return *(end() - 1); }






    void
    data() { }

    void
    push_back(bool __x)
    {
      if (this->_M_impl._M_finish._M_p != this->_M_impl._M_end_of_storage)
        *this->_M_impl._M_finish++ = __x;
      else
        _M_insert_aux(end(), __x);
    }

    void
    swap(vector& __x)
    {
      std::swap(this->_M_impl._M_start, __x._M_impl._M_start);
      std::swap(this->_M_impl._M_finish, __x._M_impl._M_finish);
      std::swap(this->_M_impl._M_end_of_storage,
  __x._M_impl._M_end_of_storage);



      std::__alloc_swap<typename _Base::_Bit_alloc_type>::
 _S_do_it(_M_get_Bit_allocator(), __x._M_get_Bit_allocator());
    }


    static void
    swap(reference __x, reference __y)
    {
      bool __tmp = __x;
      __x = __y;
      __y = __tmp;
    }

    iterator
    insert(iterator __position, const bool& __x = bool())
    {
      const difference_type __n = __position - begin();
      if (this->_M_impl._M_finish._M_p != this->_M_impl._M_end_of_storage
   && __position == end())
        *this->_M_impl._M_finish++ = __x;
      else
        _M_insert_aux(__position, __x);
      return begin() + __n;
    }

    template<typename _InputIterator>
      void
      insert(iterator __position,
      _InputIterator __first, _InputIterator __last)
      {
 typedef typename std::__is_integer<_InputIterator>::__type _Integral;
 _M_insert_dispatch(__position, __first, __last, _Integral());
      }

    void
    insert(iterator __position, size_type __n, const bool& __x)
    { _M_fill_insert(__position, __n, __x); }


    void insert(iterator __p, initializer_list<bool> __l)
    { this->insert(__p, __l.begin(), __l.end()); }


    void
    pop_back()
    { --this->_M_impl._M_finish; }

    iterator
    erase(iterator __position)
    {
      if (__position + 1 != end())
        std::copy(__position + 1, end(), __position);
      --this->_M_impl._M_finish;
      return __position;
    }

    iterator
    erase(iterator __first, iterator __last)
    {
      _M_erase_at_end(std::copy(__last, end(), __first));
      return __first;
    }

    void
    resize(size_type __new_size, bool __x = bool())
    {
      if (__new_size < size())
        _M_erase_at_end(begin() + difference_type(__new_size));
      else
        insert(end(), __new_size - size(), __x);
    }


    void
    shrink_to_fit()
    { std::__shrink_to_fit<vector>::_S_do_it(*this); }


    void
    flip()
    {
      for (_Bit_type * __p = this->_M_impl._M_start._M_p;
    __p != this->_M_impl._M_end_of_storage; ++__p)
        *__p = ~*__p;
    }

    void
    clear()
    { _M_erase_at_end(begin()); }


  protected:

    iterator
    _M_copy_aligned(const_iterator __first, const_iterator __last,
      iterator __result)
    {
      _Bit_type* __q = std::copy(__first._M_p, __last._M_p, __result._M_p);
      return std::copy(const_iterator(__last._M_p, 0), __last,
         iterator(__q, 0));
    }

    void
    _M_initialize(size_type __n)
    {
      _Bit_type* __q = this->_M_allocate(__n);
      this->_M_impl._M_end_of_storage = (__q
      + ((__n + int(_S_word_bit) - 1)
         / int(_S_word_bit)));
      this->_M_impl._M_start = iterator(__q, 0);
      this->_M_impl._M_finish = this->_M_impl._M_start + difference_type(__n);
    }





    template<typename _Integer>
      void
      _M_initialize_dispatch(_Integer __n, _Integer __x, __true_type)
      {
 _M_initialize(static_cast<size_type>(__n));
 std::fill(this->_M_impl._M_start._M_p,
    this->_M_impl._M_end_of_storage, __x ? ~0 : 0);
      }

    template<typename _InputIterator>
      void
      _M_initialize_dispatch(_InputIterator __first, _InputIterator __last,
        __false_type)
      { _M_initialize_range(__first, __last,
       std::__iterator_category(__first)); }

    template<typename _InputIterator>
      void
      _M_initialize_range(_InputIterator __first, _InputIterator __last,
     std::input_iterator_tag)
      {
 for (; __first != __last; ++__first)
   push_back(*__first);
      }

    template<typename _ForwardIterator>
      void
      _M_initialize_range(_ForwardIterator __first, _ForwardIterator __last,
     std::forward_iterator_tag)
      {
 const size_type __n = std::distance(__first, __last);
 _M_initialize(__n);
 std::copy(__first, __last, this->_M_impl._M_start);
      }



    template<typename _Integer>
      void
      _M_assign_dispatch(_Integer __n, _Integer __val, __true_type)
      { _M_fill_assign(__n, __val); }

    template<class _InputIterator>
      void
      _M_assign_dispatch(_InputIterator __first, _InputIterator __last,
    __false_type)
      { _M_assign_aux(__first, __last, std::__iterator_category(__first)); }

    void
    _M_fill_assign(size_t __n, bool __x)
    {
      if (__n > size())
 {
   std::fill(this->_M_impl._M_start._M_p,
      this->_M_impl._M_end_of_storage, __x ? ~0 : 0);
   insert(end(), __n - size(), __x);
 }
      else
 {
   _M_erase_at_end(begin() + __n);
   std::fill(this->_M_impl._M_start._M_p,
      this->_M_impl._M_end_of_storage, __x ? ~0 : 0);
 }
    }

    template<typename _InputIterator>
      void
      _M_assign_aux(_InputIterator __first, _InputIterator __last,
      std::input_iterator_tag)
      {
 iterator __cur = begin();
 for (; __first != __last && __cur != end(); ++__cur, ++__first)
   *__cur = *__first;
 if (__first == __last)
   _M_erase_at_end(__cur);
 else
   insert(end(), __first, __last);
      }

    template<typename _ForwardIterator>
      void
      _M_assign_aux(_ForwardIterator __first, _ForwardIterator __last,
      std::forward_iterator_tag)
      {
 const size_type __len = std::distance(__first, __last);
 if (__len < size())
   _M_erase_at_end(std::copy(__first, __last, begin()));
 else
   {
     _ForwardIterator __mid = __first;
     std::advance(__mid, size());
     std::copy(__first, __mid, begin());
     insert(end(), __mid, __last);
   }
      }





    template<typename _Integer>
      void
      _M_insert_dispatch(iterator __pos, _Integer __n, _Integer __x,
    __true_type)
      { _M_fill_insert(__pos, __n, __x); }

    template<typename _InputIterator>
      void
      _M_insert_dispatch(iterator __pos,
    _InputIterator __first, _InputIterator __last,
    __false_type)
      { _M_insert_range(__pos, __first, __last,
   std::__iterator_category(__first)); }

    void
    _M_fill_insert(iterator __position, size_type __n, bool __x);

    template<typename _InputIterator>
      void
      _M_insert_range(iterator __pos, _InputIterator __first,
        _InputIterator __last, std::input_iterator_tag)
      {
 for (; __first != __last; ++__first)
   {
     __pos = insert(__pos, *__first);
     ++__pos;
   }
      }

    template<typename _ForwardIterator>
      void
      _M_insert_range(iterator __position, _ForwardIterator __first,
        _ForwardIterator __last, std::forward_iterator_tag);

    void
    _M_insert_aux(iterator __position, bool __x);

    size_type
    _M_check_len(size_type __n, const char* __s) const
    {
      if (max_size() - size() < __n)
 __throw_length_error((__s));

      const size_type __len = size() + std::max(size(), __n);
      return (__len < size() || __len > max_size()) ? max_size() : __len;
    }

    void
    _M_erase_at_end(iterator __pos)
    { this->_M_impl._M_finish = __pos; }
  };


}



# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/functional_hash.h" 1 3
# 33 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/functional_hash.h" 3
       
# 34 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/functional_hash.h" 3

# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/hash_bytes.h" 1 3
# 33 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/hash_bytes.h" 3
       
# 34 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/hash_bytes.h" 3



namespace std
{







  size_t
  _Hash_bytes(const void* __ptr, size_t __len, size_t __seed);





  size_t
  _Fnv_hash_bytes(const void* __ptr, size_t __len, size_t __seed);


}
# 36 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/functional_hash.h" 2 3

namespace std __attribute__ ((__visibility__ ("default")))
{

# 49 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/functional_hash.h" 3
  template<typename _Result, typename _Arg>
    struct __hash_base
    {
      typedef _Result result_type;
      typedef _Arg argument_type;
    };


  template<typename _Tp>
    struct hash : public __hash_base<size_t, _Tp>
    {
      size_t
      operator()(_Tp __val) const;
    };


  template<typename _Tp>
    struct hash<_Tp*> : public __hash_base<size_t, _Tp*>
    {
      size_t
      operator()(_Tp* __p) const
      { return reinterpret_cast<size_t>(__p); }
    };
# 81 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/functional_hash.h" 3
  template<> inline size_t hash<bool>::operator()(bool __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<char>::operator()(char __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<signed char>::operator()(signed char __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<unsigned char>::operator()(unsigned char __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<wchar_t>::operator()(wchar_t __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<char16_t>::operator()(char16_t __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<char32_t>::operator()(char32_t __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<short>::operator()(short __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<int>::operator()(int __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<long>::operator()(long __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<long long>::operator()(long long __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<unsigned short>::operator()(unsigned short __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<unsigned int>::operator()(unsigned int __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<unsigned long>::operator()(unsigned long __val) const { return static_cast<size_t>(__val); };


  template<> inline size_t hash<unsigned long long>::operator()(unsigned long long __val) const { return static_cast<size_t>(__val); };



  struct _Hash_impl
  {
    static size_t
    hash(const void* __ptr, size_t __clength,
  size_t __seed = static_cast<size_t>(0xc70f6907UL))
    { return _Hash_bytes(__ptr, __clength, __seed); }

    template<typename _Tp>
      static size_t
      hash(const _Tp& __val)
      { return hash(&__val, sizeof(__val)); }

    template<typename _Tp>
      static size_t
      __hash_combine(const _Tp& __val, size_t __hash)
      { return hash(&__val, sizeof(__val), __hash); }
  };

  struct _Fnv_hash_impl
  {
    static size_t
    hash(const void* __ptr, size_t __clength,
  size_t __seed = static_cast<size_t>(2166136261UL))
    { return _Fnv_hash_bytes(__ptr, __clength, __seed); }

    template<typename _Tp>
      static size_t
      hash(const _Tp& __val)
      { return hash(&__val, sizeof(__val)); }

    template<typename _Tp>
      static size_t
      __hash_combine(const _Tp& __val, size_t __hash)
      { return hash(&__val, sizeof(__val), __hash); }
  };


  template<>
    inline size_t
    hash<float>::operator()(float __val) const
    {

      return __val != 0.0f ? std::_Hash_impl::hash(__val) : 0;
    }


  template<>
    inline size_t
    hash<double>::operator()(double __val) const
    {

      return __val != 0.0 ? std::_Hash_impl::hash(__val) : 0;
    }


  template<>
    __attribute__ ((__pure__)) size_t
    hash<long double>::operator()(long double __val) const;




}
# 1040 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_bvector.h" 2 3

namespace std __attribute__ ((__visibility__ ("default")))
{




  template<typename _Alloc>
    struct hash<std::vector<bool, _Alloc>>
    : public __hash_base<size_t, std::vector<bool, _Alloc>>
    {
      size_t
      operator()(const std::vector<bool, _Alloc>& __b) const;
    };


}
# 67 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/vector" 2 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/range_access.h" 1 3
# 33 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/range_access.h" 3
       
# 34 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/range_access.h" 3



namespace std __attribute__ ((__visibility__ ("default")))
{







  template<class _Container>
    inline auto
    begin(_Container& __cont) -> decltype(__cont.begin())
    { return __cont.begin(); }






  template<class _Container>
    inline auto
    begin(const _Container& __cont) -> decltype(__cont.begin())
    { return __cont.begin(); }






  template<class _Container>
    inline auto
    end(_Container& __cont) -> decltype(__cont.end())
    { return __cont.end(); }






  template<class _Container>
    inline auto
    end(const _Container& __cont) -> decltype(__cont.end())
    { return __cont.end(); }





  template<class _Tp, size_t _Nm>
    inline _Tp*
    begin(_Tp (&__arr)[_Nm])
    { return __arr; }






  template<class _Tp, size_t _Nm>
    inline _Tp*
    end(_Tp (&__arr)[_Nm])
    { return __arr + _Nm; }


}
# 68 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/vector" 2 3


# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/vector.tcc" 1 3
# 60 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/vector.tcc" 3
namespace std __attribute__ ((__visibility__ ("default")))
{


  template<typename _Tp, typename _Alloc>
    void
    vector<_Tp, _Alloc>::
    reserve(size_type __n)
    {
      if (__n > this->max_size())
 __throw_length_error(("vector::reserve"));
      if (this->capacity() < __n)
 {
   const size_type __old_size = size();
   pointer __tmp = _M_allocate_and_copy(__n,
   std::make_move_iterator(this->_M_impl._M_start),
   std::make_move_iterator(this->_M_impl._M_finish));
   std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
   _M_get_Tp_allocator());
   _M_deallocate(this->_M_impl._M_start,
   this->_M_impl._M_end_of_storage
   - this->_M_impl._M_start);
   this->_M_impl._M_start = __tmp;
   this->_M_impl._M_finish = __tmp + __old_size;
   this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
 }
    }


  template<typename _Tp, typename _Alloc>
    template<typename... _Args>
      void
      vector<_Tp, _Alloc>::
      emplace_back(_Args&&... __args)
      {
 if (this->_M_impl._M_finish != this->_M_impl._M_end_of_storage)
   {
     this->_M_impl.construct(this->_M_impl._M_finish,
        std::forward<_Args>(__args)...);
     ++this->_M_impl._M_finish;
   }
 else
   _M_insert_aux(end(), std::forward<_Args>(__args)...);
      }


  template<typename _Tp, typename _Alloc>
    typename vector<_Tp, _Alloc>::iterator
    vector<_Tp, _Alloc>::
    insert(iterator __position, const value_type& __x)
    {
      const size_type __n = __position - begin();
      if (this->_M_impl._M_finish != this->_M_impl._M_end_of_storage
   && __position == end())
 {
   this->_M_impl.construct(this->_M_impl._M_finish, __x);
   ++this->_M_impl._M_finish;
 }
      else
 {

   if (this->_M_impl._M_finish != this->_M_impl._M_end_of_storage)
     {
       _Tp __x_copy = __x;
       _M_insert_aux(__position, std::move(__x_copy));
     }
   else

     _M_insert_aux(__position, __x);
 }
      return iterator(this->_M_impl._M_start + __n);
    }

  template<typename _Tp, typename _Alloc>
    typename vector<_Tp, _Alloc>::iterator
    vector<_Tp, _Alloc>::
    erase(iterator __position)
    {
      if (__position + 1 != end())
 std::move(__position + 1, end(), __position);
      --this->_M_impl._M_finish;
      this->_M_impl.destroy(this->_M_impl._M_finish);
      return __position;
    }

  template<typename _Tp, typename _Alloc>
    typename vector<_Tp, _Alloc>::iterator
    vector<_Tp, _Alloc>::
    erase(iterator __first, iterator __last)
    {
      if (__last != end())
 std::move(__last, end(), __first);
      _M_erase_at_end(__first.base() + (end() - __last));
      return __first;
    }

  template<typename _Tp, typename _Alloc>
    vector<_Tp, _Alloc>&
    vector<_Tp, _Alloc>::
    operator=(const vector<_Tp, _Alloc>& __x)
    {
      if (&__x != this)
 {
   const size_type __xlen = __x.size();
   if (__xlen > capacity())
     {
       pointer __tmp = _M_allocate_and_copy(__xlen, __x.begin(),
         __x.end());
       std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
       _M_get_Tp_allocator());
       _M_deallocate(this->_M_impl._M_start,
       this->_M_impl._M_end_of_storage
       - this->_M_impl._M_start);
       this->_M_impl._M_start = __tmp;
       this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __xlen;
     }
   else if (size() >= __xlen)
     {
       std::_Destroy(std::copy(__x.begin(), __x.end(), begin()),
       end(), _M_get_Tp_allocator());
     }
   else
     {
       std::copy(__x._M_impl._M_start, __x._M_impl._M_start + size(),
   this->_M_impl._M_start);
       std::__uninitialized_copy_a(__x._M_impl._M_start + size(),
       __x._M_impl._M_finish,
       this->_M_impl._M_finish,
       _M_get_Tp_allocator());
     }
   this->_M_impl._M_finish = this->_M_impl._M_start + __xlen;
 }
      return *this;
    }

  template<typename _Tp, typename _Alloc>
    void
    vector<_Tp, _Alloc>::
    _M_fill_assign(size_t __n, const value_type& __val)
    {
      if (__n > capacity())
 {
   vector __tmp(__n, __val, _M_get_Tp_allocator());
   __tmp.swap(*this);
 }
      else if (__n > size())
 {
   std::fill(begin(), end(), __val);
   std::__uninitialized_fill_n_a(this->_M_impl._M_finish,
     __n - size(), __val,
     _M_get_Tp_allocator());
   this->_M_impl._M_finish += __n - size();
 }
      else
        _M_erase_at_end(std::fill_n(this->_M_impl._M_start, __n, __val));
    }

  template<typename _Tp, typename _Alloc>
    template<typename _InputIterator>
      void
      vector<_Tp, _Alloc>::
      _M_assign_aux(_InputIterator __first, _InputIterator __last,
      std::input_iterator_tag)
      {
 pointer __cur(this->_M_impl._M_start);
 for (; __first != __last && __cur != this->_M_impl._M_finish;
      ++__cur, ++__first)
   *__cur = *__first;
 if (__first == __last)
   _M_erase_at_end(__cur);
 else
   insert(end(), __first, __last);
      }

  template<typename _Tp, typename _Alloc>
    template<typename _ForwardIterator>
      void
      vector<_Tp, _Alloc>::
      _M_assign_aux(_ForwardIterator __first, _ForwardIterator __last,
      std::forward_iterator_tag)
      {
 const size_type __len = std::distance(__first, __last);

 if (__len > capacity())
   {
     pointer __tmp(_M_allocate_and_copy(__len, __first, __last));
     std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
     _M_get_Tp_allocator());
     _M_deallocate(this->_M_impl._M_start,
     this->_M_impl._M_end_of_storage
     - this->_M_impl._M_start);
     this->_M_impl._M_start = __tmp;
     this->_M_impl._M_finish = this->_M_impl._M_start + __len;
     this->_M_impl._M_end_of_storage = this->_M_impl._M_finish;
   }
 else if (size() >= __len)
   _M_erase_at_end(std::copy(__first, __last, this->_M_impl._M_start));
 else
   {
     _ForwardIterator __mid = __first;
     std::advance(__mid, size());
     std::copy(__first, __mid, this->_M_impl._M_start);
     this->_M_impl._M_finish =
       std::__uninitialized_copy_a(__mid, __last,
       this->_M_impl._M_finish,
       _M_get_Tp_allocator());
   }
      }


  template<typename _Tp, typename _Alloc>
    template<typename... _Args>
      typename vector<_Tp, _Alloc>::iterator
      vector<_Tp, _Alloc>::
      emplace(iterator __position, _Args&&... __args)
      {
 const size_type __n = __position - begin();
 if (this->_M_impl._M_finish != this->_M_impl._M_end_of_storage
     && __position == end())
   {
     this->_M_impl.construct(this->_M_impl._M_finish,
        std::forward<_Args>(__args)...);
     ++this->_M_impl._M_finish;
   }
 else
   _M_insert_aux(__position, std::forward<_Args>(__args)...);
 return iterator(this->_M_impl._M_start + __n);
      }

  template<typename _Tp, typename _Alloc>
    template<typename... _Args>
      void
      vector<_Tp, _Alloc>::
      _M_insert_aux(iterator __position, _Args&&... __args)






    {
      if (this->_M_impl._M_finish != this->_M_impl._M_end_of_storage)
 {
   this->_M_impl.construct(this->_M_impl._M_finish,
      std::move(*(this->_M_impl._M_finish - 1))
             );
   ++this->_M_impl._M_finish;



   std::move_backward(__position.base(), this->_M_impl._M_finish - 2, this->_M_impl._M_finish - 1)

                                  ;



   *__position = _Tp(std::forward<_Args>(__args)...);

 }
      else
 {
   const size_type __len =
     _M_check_len(size_type(1), "vector::_M_insert_aux");
   const size_type __elems_before = __position - begin();
   pointer __new_start(this->_M_allocate(__len));
   pointer __new_finish(__new_start);
   try
     {




       this->_M_impl.construct(__new_start + __elems_before,

          std::forward<_Args>(__args)...);



       __new_finish = 0;

       __new_finish =
  std::__uninitialized_move_a(this->_M_impl._M_start,
         __position.base(), __new_start,
         _M_get_Tp_allocator());
       ++__new_finish;

       __new_finish =
  std::__uninitialized_move_a(__position.base(),
         this->_M_impl._M_finish,
         __new_finish,
         _M_get_Tp_allocator());
     }
          catch(...)
     {
       if (!__new_finish)
  this->_M_impl.destroy(__new_start + __elems_before);
       else
  std::_Destroy(__new_start, __new_finish, _M_get_Tp_allocator());
       _M_deallocate(__new_start, __len);
       throw;
     }
   std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
   _M_get_Tp_allocator());
   _M_deallocate(this->_M_impl._M_start,
   this->_M_impl._M_end_of_storage
   - this->_M_impl._M_start);
   this->_M_impl._M_start = __new_start;
   this->_M_impl._M_finish = __new_finish;
   this->_M_impl._M_end_of_storage = __new_start + __len;
 }
    }

  template<typename _Tp, typename _Alloc>
    void
    vector<_Tp, _Alloc>::
    _M_fill_insert(iterator __position, size_type __n, const value_type& __x)
    {
      if (__n != 0)
 {
   if (size_type(this->_M_impl._M_end_of_storage
   - this->_M_impl._M_finish) >= __n)
     {
       value_type __x_copy = __x;
       const size_type __elems_after = end() - __position;
       pointer __old_finish(this->_M_impl._M_finish);
       if (__elems_after > __n)
  {
    std::__uninitialized_move_a(this->_M_impl._M_finish - __n,
           this->_M_impl._M_finish,
           this->_M_impl._M_finish,
           _M_get_Tp_allocator());
    this->_M_impl._M_finish += __n;
    std::move_backward(__position.base(), __old_finish - __n, __old_finish)
                                        ;
    std::fill(__position.base(), __position.base() + __n,
       __x_copy);
  }
       else
  {
    std::__uninitialized_fill_n_a(this->_M_impl._M_finish,
      __n - __elems_after,
      __x_copy,
      _M_get_Tp_allocator());
    this->_M_impl._M_finish += __n - __elems_after;
    std::__uninitialized_move_a(__position.base(), __old_finish,
           this->_M_impl._M_finish,
           _M_get_Tp_allocator());
    this->_M_impl._M_finish += __elems_after;
    std::fill(__position.base(), __old_finish, __x_copy);
  }
     }
   else
     {
       const size_type __len =
  _M_check_len(__n, "vector::_M_fill_insert");
       const size_type __elems_before = __position - begin();
       pointer __new_start(this->_M_allocate(__len));
       pointer __new_finish(__new_start);
       try
  {

    std::__uninitialized_fill_n_a(__new_start + __elems_before,
      __n, __x,
      _M_get_Tp_allocator());
    __new_finish = 0;

    __new_finish =
      std::__uninitialized_move_a(this->_M_impl._M_start,
      __position.base(),
      __new_start,
      _M_get_Tp_allocator());
    __new_finish += __n;

    __new_finish =
      std::__uninitialized_move_a(__position.base(),
      this->_M_impl._M_finish,
      __new_finish,
      _M_get_Tp_allocator());
  }
       catch(...)
  {
    if (!__new_finish)
      std::_Destroy(__new_start + __elems_before,
      __new_start + __elems_before + __n,
      _M_get_Tp_allocator());
    else
      std::_Destroy(__new_start, __new_finish,
      _M_get_Tp_allocator());
    _M_deallocate(__new_start, __len);
    throw;
  }
       std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
       _M_get_Tp_allocator());
       _M_deallocate(this->_M_impl._M_start,
       this->_M_impl._M_end_of_storage
       - this->_M_impl._M_start);
       this->_M_impl._M_start = __new_start;
       this->_M_impl._M_finish = __new_finish;
       this->_M_impl._M_end_of_storage = __new_start + __len;
     }
 }
    }


  template<typename _Tp, typename _Alloc>
    void
    vector<_Tp, _Alloc>::
    _M_default_append(size_type __n)
    {
      if (__n != 0)
 {
   if (size_type(this->_M_impl._M_end_of_storage
   - this->_M_impl._M_finish) >= __n)
     {
       std::__uninitialized_default_n_a(this->_M_impl._M_finish,
            __n, _M_get_Tp_allocator());
       this->_M_impl._M_finish += __n;
     }
   else
     {
       const size_type __len =
  _M_check_len(__n, "vector::_M_default_append");
       const size_type __old_size = this->size();
       pointer __new_start(this->_M_allocate(__len));
       pointer __new_finish(__new_start);
       try
  {
    __new_finish =
      std::__uninitialized_move_a(this->_M_impl._M_start,
      this->_M_impl._M_finish,
      __new_start,
      _M_get_Tp_allocator());
    std::__uninitialized_default_n_a(__new_finish, __n,
         _M_get_Tp_allocator());
    __new_finish += __n;
  }
       catch(...)
  {
    std::_Destroy(__new_start, __new_finish,
    _M_get_Tp_allocator());
    _M_deallocate(__new_start, __len);
    throw;
  }
       std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
       _M_get_Tp_allocator());
       _M_deallocate(this->_M_impl._M_start,
       this->_M_impl._M_end_of_storage
       - this->_M_impl._M_start);
       this->_M_impl._M_start = __new_start;
       this->_M_impl._M_finish = __new_finish;
       this->_M_impl._M_end_of_storage = __new_start + __len;
     }
 }
    }


  template<typename _Tp, typename _Alloc>
    template<typename _InputIterator>
      void
      vector<_Tp, _Alloc>::
      _M_range_insert(iterator __pos, _InputIterator __first,
        _InputIterator __last, std::input_iterator_tag)
      {
 for (; __first != __last; ++__first)
   {
     __pos = insert(__pos, *__first);
     ++__pos;
   }
      }

  template<typename _Tp, typename _Alloc>
    template<typename _ForwardIterator>
      void
      vector<_Tp, _Alloc>::
      _M_range_insert(iterator __position, _ForwardIterator __first,
        _ForwardIterator __last, std::forward_iterator_tag)
      {
 if (__first != __last)
   {
     const size_type __n = std::distance(__first, __last);
     if (size_type(this->_M_impl._M_end_of_storage
     - this->_M_impl._M_finish) >= __n)
       {
  const size_type __elems_after = end() - __position;
  pointer __old_finish(this->_M_impl._M_finish);
  if (__elems_after > __n)
    {
      std::__uninitialized_move_a(this->_M_impl._M_finish - __n,
      this->_M_impl._M_finish,
      this->_M_impl._M_finish,
      _M_get_Tp_allocator());
      this->_M_impl._M_finish += __n;
      std::move_backward(__position.base(), __old_finish - __n, __old_finish)
                                          ;
      std::copy(__first, __last, __position);
    }
  else
    {
      _ForwardIterator __mid = __first;
      std::advance(__mid, __elems_after);
      std::__uninitialized_copy_a(__mid, __last,
      this->_M_impl._M_finish,
      _M_get_Tp_allocator());
      this->_M_impl._M_finish += __n - __elems_after;
      std::__uninitialized_move_a(__position.base(),
      __old_finish,
      this->_M_impl._M_finish,
      _M_get_Tp_allocator());
      this->_M_impl._M_finish += __elems_after;
      std::copy(__first, __mid, __position);
    }
       }
     else
       {
  const size_type __len =
    _M_check_len(__n, "vector::_M_range_insert");
  pointer __new_start(this->_M_allocate(__len));
  pointer __new_finish(__new_start);
  try
    {
      __new_finish =
        std::__uninitialized_move_a(this->_M_impl._M_start,
        __position.base(),
        __new_start,
        _M_get_Tp_allocator());
      __new_finish =
        std::__uninitialized_copy_a(__first, __last,
        __new_finish,
        _M_get_Tp_allocator());
      __new_finish =
        std::__uninitialized_move_a(__position.base(),
        this->_M_impl._M_finish,
        __new_finish,
        _M_get_Tp_allocator());
    }
  catch(...)
    {
      std::_Destroy(__new_start, __new_finish,
      _M_get_Tp_allocator());
      _M_deallocate(__new_start, __len);
      throw;
    }
  std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
         _M_get_Tp_allocator());
  _M_deallocate(this->_M_impl._M_start,
         this->_M_impl._M_end_of_storage
         - this->_M_impl._M_start);
  this->_M_impl._M_start = __new_start;
  this->_M_impl._M_finish = __new_finish;
  this->_M_impl._M_end_of_storage = __new_start + __len;
       }
   }
      }




  template<typename _Alloc>
    void
    vector<bool, _Alloc>::
    reserve(size_type __n)
    {
      if (__n > this->max_size())
 __throw_length_error(("vector::reserve"));
      if (this->capacity() < __n)
 {
   _Bit_type* __q = this->_M_allocate(__n);
   this->_M_impl._M_finish = _M_copy_aligned(begin(), end(),
          iterator(__q, 0));
   this->_M_deallocate();
   this->_M_impl._M_start = iterator(__q, 0);
   this->_M_impl._M_end_of_storage = (__q + (__n + int(_S_word_bit) - 1)
          / int(_S_word_bit));
 }
    }

  template<typename _Alloc>
    void
    vector<bool, _Alloc>::
    _M_fill_insert(iterator __position, size_type __n, bool __x)
    {
      if (__n == 0)
 return;
      if (capacity() - size() >= __n)
 {
   std::copy_backward(__position, end(),
        this->_M_impl._M_finish + difference_type(__n));
   std::fill(__position, __position + difference_type(__n), __x);
   this->_M_impl._M_finish += difference_type(__n);
 }
      else
 {
   const size_type __len =
     _M_check_len(__n, "vector<bool>::_M_fill_insert");
   _Bit_type * __q = this->_M_allocate(__len);
   iterator __i = _M_copy_aligned(begin(), __position,
      iterator(__q, 0));
   std::fill(__i, __i + difference_type(__n), __x);
   this->_M_impl._M_finish = std::copy(__position, end(),
           __i + difference_type(__n));
   this->_M_deallocate();
   this->_M_impl._M_end_of_storage = (__q + ((__len
           + int(_S_word_bit) - 1)
          / int(_S_word_bit)));
   this->_M_impl._M_start = iterator(__q, 0);
 }
    }

  template<typename _Alloc>
    template<typename _ForwardIterator>
      void
      vector<bool, _Alloc>::
      _M_insert_range(iterator __position, _ForwardIterator __first,
        _ForwardIterator __last, std::forward_iterator_tag)
      {
 if (__first != __last)
   {
     size_type __n = std::distance(__first, __last);
     if (capacity() - size() >= __n)
       {
  std::copy_backward(__position, end(),
       this->_M_impl._M_finish
       + difference_type(__n));
  std::copy(__first, __last, __position);
  this->_M_impl._M_finish += difference_type(__n);
       }
     else
       {
  const size_type __len =
    _M_check_len(__n, "vector<bool>::_M_insert_range");
  _Bit_type * __q = this->_M_allocate(__len);
  iterator __i = _M_copy_aligned(begin(), __position,
            iterator(__q, 0));
  __i = std::copy(__first, __last, __i);
  this->_M_impl._M_finish = std::copy(__position, end(), __i);
  this->_M_deallocate();
  this->_M_impl._M_end_of_storage = (__q
         + ((__len
             + int(_S_word_bit) - 1)
            / int(_S_word_bit)));
  this->_M_impl._M_start = iterator(__q, 0);
       }
   }
      }

  template<typename _Alloc>
    void
    vector<bool, _Alloc>::
    _M_insert_aux(iterator __position, bool __x)
    {
      if (this->_M_impl._M_finish._M_p != this->_M_impl._M_end_of_storage)
 {
   std::copy_backward(__position, this->_M_impl._M_finish,
        this->_M_impl._M_finish + 1);
   *__position = __x;
   ++this->_M_impl._M_finish;
 }
      else
 {
   const size_type __len =
     _M_check_len(size_type(1), "vector<bool>::_M_insert_aux");
   _Bit_type * __q = this->_M_allocate(__len);
   iterator __i = _M_copy_aligned(begin(), __position,
      iterator(__q, 0));
   *__i++ = __x;
   this->_M_impl._M_finish = std::copy(__position, end(), __i);
   this->_M_deallocate();
   this->_M_impl._M_end_of_storage = (__q + ((__len
           + int(_S_word_bit) - 1)
          / int(_S_word_bit)));
   this->_M_impl._M_start = iterator(__q, 0);
 }
    }


}



namespace std __attribute__ ((__visibility__ ("default")))
{


  template<typename _Alloc>
    size_t
    hash<std::vector<bool, _Alloc>>::
    operator()(const std::vector<bool, _Alloc>& __b) const
    {
      size_t __hash = 0;
      using std::_S_word_bit;
      using std::_Bit_type;

      const size_t __words = __b.size() / _S_word_bit;
      if (__words)
 {
   const size_t __clength = __words * sizeof(_Bit_type);
   __hash = std::_Hash_impl::hash(__b._M_impl._M_start._M_p, __clength);
 }

      const size_t __extrabits = __b.size() % _S_word_bit;
      if (__extrabits)
 {
   _Bit_type __hiword = *__b._M_impl._M_finish._M_p;
   __hiword &= ~((~static_cast<_Bit_type>(0)) << __extrabits);

   const size_t __clength
     = (__extrabits + 8 - 1) / 8;
   if (__words)
     __hash = std::_Hash_impl::hash(&__hiword, __clength, __hash);
   else
     __hash = std::_Hash_impl::hash(&__hiword, __clength);
 }

      return __hash;
    }


}
# 71 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/vector" 2 3
# 14 "DFSController.H" 2
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 1 3
# 47 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
       
# 48 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3


# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_function.h" 1 3
# 60 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_function.h" 3
namespace std __attribute__ ((__visibility__ ("default")))
{

# 101 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_function.h" 3
  template<typename _Arg, typename _Result>
    struct unary_function
    {

      typedef _Arg argument_type;


      typedef _Result result_type;
    };




  template<typename _Arg1, typename _Arg2, typename _Result>
    struct binary_function
    {

      typedef _Arg1 first_argument_type;


      typedef _Arg2 second_argument_type;


      typedef _Result result_type;
    };
# 140 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_function.h" 3
  template<typename _Tp>
    struct plus : public binary_function<_Tp, _Tp, _Tp>
    {
      _Tp
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x + __y; }
    };


  template<typename _Tp>
    struct minus : public binary_function<_Tp, _Tp, _Tp>
    {
      _Tp
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x - __y; }
    };


  template<typename _Tp>
    struct multiplies : public binary_function<_Tp, _Tp, _Tp>
    {
      _Tp
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x * __y; }
    };


  template<typename _Tp>
    struct divides : public binary_function<_Tp, _Tp, _Tp>
    {
      _Tp
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x / __y; }
    };


  template<typename _Tp>
    struct modulus : public binary_function<_Tp, _Tp, _Tp>
    {
      _Tp
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x % __y; }
    };


  template<typename _Tp>
    struct negate : public unary_function<_Tp, _Tp>
    {
      _Tp
      operator()(const _Tp& __x) const
      { return -__x; }
    };
# 204 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_function.h" 3
  template<typename _Tp>
    struct equal_to : public binary_function<_Tp, _Tp, bool>
    {
      bool
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x == __y; }
    };


  template<typename _Tp>
    struct not_equal_to : public binary_function<_Tp, _Tp, bool>
    {
      bool
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x != __y; }
    };


  template<typename _Tp>
    struct greater : public binary_function<_Tp, _Tp, bool>
    {
      bool
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x > __y; }
    };


  template<typename _Tp>
    struct less : public binary_function<_Tp, _Tp, bool>
    {
      bool
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x < __y; }
    };


  template<typename _Tp>
    struct greater_equal : public binary_function<_Tp, _Tp, bool>
    {
      bool
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x >= __y; }
    };


  template<typename _Tp>
    struct less_equal : public binary_function<_Tp, _Tp, bool>
    {
      bool
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x <= __y; }
    };
# 268 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_function.h" 3
  template<typename _Tp>
    struct logical_and : public binary_function<_Tp, _Tp, bool>
    {
      bool
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x && __y; }
    };


  template<typename _Tp>
    struct logical_or : public binary_function<_Tp, _Tp, bool>
    {
      bool
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x || __y; }
    };


  template<typename _Tp>
    struct logical_not : public unary_function<_Tp, bool>
    {
      bool
      operator()(const _Tp& __x) const
      { return !__x; }
    };




  template<typename _Tp>
    struct bit_and : public binary_function<_Tp, _Tp, _Tp>
    {
      _Tp
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x & __y; }
    };

  template<typename _Tp>
    struct bit_or : public binary_function<_Tp, _Tp, _Tp>
    {
      _Tp
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x | __y; }
    };

  template<typename _Tp>
    struct bit_xor : public binary_function<_Tp, _Tp, _Tp>
    {
      _Tp
      operator()(const _Tp& __x, const _Tp& __y) const
      { return __x ^ __y; }
    };
# 351 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_function.h" 3
  template<typename _Predicate>
    class unary_negate
    : public unary_function<typename _Predicate::argument_type, bool>
    {
    protected:
      _Predicate _M_pred;

    public:
      explicit
      unary_negate(const _Predicate& __x) : _M_pred(__x) { }

      bool
      operator()(const typename _Predicate::argument_type& __x) const
      { return !_M_pred(__x); }
    };


  template<typename _Predicate>
    inline unary_negate<_Predicate>
    not1(const _Predicate& __pred)
    { return unary_negate<_Predicate>(__pred); }


  template<typename _Predicate>
    class binary_negate
    : public binary_function<typename _Predicate::first_argument_type,
        typename _Predicate::second_argument_type, bool>
    {
    protected:
      _Predicate _M_pred;

    public:
      explicit
      binary_negate(const _Predicate& __x) : _M_pred(__x) { }

      bool
      operator()(const typename _Predicate::first_argument_type& __x,
   const typename _Predicate::second_argument_type& __y) const
      { return !_M_pred(__x, __y); }
    };


  template<typename _Predicate>
    inline binary_negate<_Predicate>
    not2(const _Predicate& __pred)
    { return binary_negate<_Predicate>(__pred); }
# 422 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_function.h" 3
  template<typename _Arg, typename _Result>
    class pointer_to_unary_function : public unary_function<_Arg, _Result>
    {
    protected:
      _Result (*_M_ptr)(_Arg);

    public:
      pointer_to_unary_function() { }

      explicit
      pointer_to_unary_function(_Result (*__x)(_Arg))
      : _M_ptr(__x) { }

      _Result
      operator()(_Arg __x) const
      { return _M_ptr(__x); }
    };


  template<typename _Arg, typename _Result>
    inline pointer_to_unary_function<_Arg, _Result>
    ptr_fun(_Result (*__x)(_Arg))
    { return pointer_to_unary_function<_Arg, _Result>(__x); }


  template<typename _Arg1, typename _Arg2, typename _Result>
    class pointer_to_binary_function
    : public binary_function<_Arg1, _Arg2, _Result>
    {
    protected:
      _Result (*_M_ptr)(_Arg1, _Arg2);

    public:
      pointer_to_binary_function() { }

      explicit
      pointer_to_binary_function(_Result (*__x)(_Arg1, _Arg2))
      : _M_ptr(__x) { }

      _Result
      operator()(_Arg1 __x, _Arg2 __y) const
      { return _M_ptr(__x, __y); }
    };


  template<typename _Arg1, typename _Arg2, typename _Result>
    inline pointer_to_binary_function<_Arg1, _Arg2, _Result>
    ptr_fun(_Result (*__x)(_Arg1, _Arg2))
    { return pointer_to_binary_function<_Arg1, _Arg2, _Result>(__x); }


  template<typename _Tp>
    struct _Identity : public unary_function<_Tp,_Tp>
    {
      _Tp&
      operator()(_Tp& __x) const
      { return __x; }

      const _Tp&
      operator()(const _Tp& __x) const
      { return __x; }
    };

  template<typename _Pair>
    struct _Select1st : public unary_function<_Pair,
           typename _Pair::first_type>
    {
      typename _Pair::first_type&
      operator()(_Pair& __x) const
      { return __x.first; }

      const typename _Pair::first_type&
      operator()(const _Pair& __x) const
      { return __x.first; }


      template<typename _Pair2>
        typename _Pair2::first_type&
        operator()(_Pair2& __x) const
        { return __x.first; }

      template<typename _Pair2>
        const typename _Pair2::first_type&
        operator()(const _Pair2& __x) const
        { return __x.first; }

    };

  template<typename _Pair>
    struct _Select2nd : public unary_function<_Pair,
           typename _Pair::second_type>
    {
      typename _Pair::second_type&
      operator()(_Pair& __x) const
      { return __x.second; }

      const typename _Pair::second_type&
      operator()(const _Pair& __x) const
      { return __x.second; }
    };
# 541 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_function.h" 3
  template<typename _Ret, typename _Tp>
    class mem_fun_t : public unary_function<_Tp*, _Ret>
    {
    public:
      explicit
      mem_fun_t(_Ret (_Tp::*__pf)())
      : _M_f(__pf) { }

      _Ret
      operator()(_Tp* __p) const
      { return (__p->*_M_f)(); }

    private:
      _Ret (_Tp::*_M_f)();
    };



  template<typename _Ret, typename _Tp>
    class const_mem_fun_t : public unary_function<const _Tp*, _Ret>
    {
    public:
      explicit
      const_mem_fun_t(_Ret (_Tp::*__pf)() const)
      : _M_f(__pf) { }

      _Ret
      operator()(const _Tp* __p) const
      { return (__p->*_M_f)(); }

    private:
      _Ret (_Tp::*_M_f)() const;
    };



  template<typename _Ret, typename _Tp>
    class mem_fun_ref_t : public unary_function<_Tp, _Ret>
    {
    public:
      explicit
      mem_fun_ref_t(_Ret (_Tp::*__pf)())
      : _M_f(__pf) { }

      _Ret
      operator()(_Tp& __r) const
      { return (__r.*_M_f)(); }

    private:
      _Ret (_Tp::*_M_f)();
  };



  template<typename _Ret, typename _Tp>
    class const_mem_fun_ref_t : public unary_function<_Tp, _Ret>
    {
    public:
      explicit
      const_mem_fun_ref_t(_Ret (_Tp::*__pf)() const)
      : _M_f(__pf) { }

      _Ret
      operator()(const _Tp& __r) const
      { return (__r.*_M_f)(); }

    private:
      _Ret (_Tp::*_M_f)() const;
    };



  template<typename _Ret, typename _Tp, typename _Arg>
    class mem_fun1_t : public binary_function<_Tp*, _Arg, _Ret>
    {
    public:
      explicit
      mem_fun1_t(_Ret (_Tp::*__pf)(_Arg))
      : _M_f(__pf) { }

      _Ret
      operator()(_Tp* __p, _Arg __x) const
      { return (__p->*_M_f)(__x); }

    private:
      _Ret (_Tp::*_M_f)(_Arg);
    };



  template<typename _Ret, typename _Tp, typename _Arg>
    class const_mem_fun1_t : public binary_function<const _Tp*, _Arg, _Ret>
    {
    public:
      explicit
      const_mem_fun1_t(_Ret (_Tp::*__pf)(_Arg) const)
      : _M_f(__pf) { }

      _Ret
      operator()(const _Tp* __p, _Arg __x) const
      { return (__p->*_M_f)(__x); }

    private:
      _Ret (_Tp::*_M_f)(_Arg) const;
    };



  template<typename _Ret, typename _Tp, typename _Arg>
    class mem_fun1_ref_t : public binary_function<_Tp, _Arg, _Ret>
    {
    public:
      explicit
      mem_fun1_ref_t(_Ret (_Tp::*__pf)(_Arg))
      : _M_f(__pf) { }

      _Ret
      operator()(_Tp& __r, _Arg __x) const
      { return (__r.*_M_f)(__x); }

    private:
      _Ret (_Tp::*_M_f)(_Arg);
    };



  template<typename _Ret, typename _Tp, typename _Arg>
    class const_mem_fun1_ref_t : public binary_function<_Tp, _Arg, _Ret>
    {
    public:
      explicit
      const_mem_fun1_ref_t(_Ret (_Tp::*__pf)(_Arg) const)
      : _M_f(__pf) { }

      _Ret
      operator()(const _Tp& __r, _Arg __x) const
      { return (__r.*_M_f)(__x); }

    private:
      _Ret (_Tp::*_M_f)(_Arg) const;
    };



  template<typename _Ret, typename _Tp>
    inline mem_fun_t<_Ret, _Tp>
    mem_fun(_Ret (_Tp::*__f)())
    { return mem_fun_t<_Ret, _Tp>(__f); }

  template<typename _Ret, typename _Tp>
    inline const_mem_fun_t<_Ret, _Tp>
    mem_fun(_Ret (_Tp::*__f)() const)
    { return const_mem_fun_t<_Ret, _Tp>(__f); }

  template<typename _Ret, typename _Tp>
    inline mem_fun_ref_t<_Ret, _Tp>
    mem_fun_ref(_Ret (_Tp::*__f)())
    { return mem_fun_ref_t<_Ret, _Tp>(__f); }

  template<typename _Ret, typename _Tp>
    inline const_mem_fun_ref_t<_Ret, _Tp>
    mem_fun_ref(_Ret (_Tp::*__f)() const)
    { return const_mem_fun_ref_t<_Ret, _Tp>(__f); }

  template<typename _Ret, typename _Tp, typename _Arg>
    inline mem_fun1_t<_Ret, _Tp, _Arg>
    mem_fun(_Ret (_Tp::*__f)(_Arg))
    { return mem_fun1_t<_Ret, _Tp, _Arg>(__f); }

  template<typename _Ret, typename _Tp, typename _Arg>
    inline const_mem_fun1_t<_Ret, _Tp, _Arg>
    mem_fun(_Ret (_Tp::*__f)(_Arg) const)
    { return const_mem_fun1_t<_Ret, _Tp, _Arg>(__f); }

  template<typename _Ret, typename _Tp, typename _Arg>
    inline mem_fun1_ref_t<_Ret, _Tp, _Arg>
    mem_fun_ref(_Ret (_Tp::*__f)(_Arg))
    { return mem_fun1_ref_t<_Ret, _Tp, _Arg>(__f); }

  template<typename _Ret, typename _Tp, typename _Arg>
    inline const_mem_fun1_ref_t<_Ret, _Tp, _Arg>
    mem_fun_ref(_Ret (_Tp::*__f)(_Arg) const)
    { return const_mem_fun1_ref_t<_Ret, _Tp, _Arg>(__f); }




}


# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/backward/binders.h" 1 3
# 60 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/backward/binders.h" 3
namespace std __attribute__ ((__visibility__ ("default")))
{

# 99 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/backward/binders.h" 3
  template<typename _Operation>
    class binder1st
    : public unary_function<typename _Operation::second_argument_type,
       typename _Operation::result_type>
    {
    protected:
      _Operation op;
      typename _Operation::first_argument_type value;

    public:
      binder1st(const _Operation& __x,
  const typename _Operation::first_argument_type& __y)
      : op(__x), value(__y) { }

      typename _Operation::result_type
      operator()(const typename _Operation::second_argument_type& __x) const
      { return op(value, __x); }



      typename _Operation::result_type
      operator()(typename _Operation::second_argument_type& __x) const
      { return op(value, __x); }
    } __attribute__ ((__deprecated__));


  template<typename _Operation, typename _Tp>
    inline binder1st<_Operation>
    bind1st(const _Operation& __fn, const _Tp& __x)
    {
      typedef typename _Operation::first_argument_type _Arg1_type;
      return binder1st<_Operation>(__fn, _Arg1_type(__x));
    }


  template<typename _Operation>
    class binder2nd
    : public unary_function<typename _Operation::first_argument_type,
       typename _Operation::result_type>
    {
    protected:
      _Operation op;
      typename _Operation::second_argument_type value;

    public:
      binder2nd(const _Operation& __x,
  const typename _Operation::second_argument_type& __y)
      : op(__x), value(__y) { }

      typename _Operation::result_type
      operator()(const typename _Operation::first_argument_type& __x) const
      { return op(__x, value); }



      typename _Operation::result_type
      operator()(typename _Operation::first_argument_type& __x) const
      { return op(__x, value); }
    } __attribute__ ((__deprecated__));


  template<typename _Operation, typename _Tp>
    inline binder2nd<_Operation>
    bind2nd(const _Operation& __fn, const _Tp& __x)
    {
      typedef typename _Operation::second_argument_type _Arg2_type;
      return binder2nd<_Operation>(__fn, _Arg2_type(__x));
    }



}
# 732 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_function.h" 2 3
# 51 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 2 3



# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/typeinfo" 1 3
# 34 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/typeinfo" 3
       
# 35 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/typeinfo" 3







#pragma GCC visibility push(default)

extern "C++" {

namespace __cxxabiv1
{
  class __class_type_info;
}
# 83 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/typeinfo" 3
namespace std
{






  class type_info
  {
  public:




    virtual ~type_info();



    const char* name() const
    { return __name[0] == '*' ? __name + 1 : __name; }
# 118 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/typeinfo" 3
    bool before(const type_info& __arg) const
    { return (__name[0] == '*' && __arg.__name[0] == '*')
 ? __name < __arg.__name
 : __builtin_strcmp (__name, __arg.__name) < 0; }

    bool operator==(const type_info& __arg) const
    {
      return ((__name == __arg.__name)
       || (__name[0] != '*' &&
    __builtin_strcmp (__name, __arg.__name) == 0));
    }
# 139 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/typeinfo" 3
    bool operator!=(const type_info& __arg) const
    { return !operator==(__arg); }


    size_t hash_code() const throw()
    {

      return _Hash_bytes(name(), __builtin_strlen(name()),
    static_cast<size_t>(0xc70f6907UL));



    }



    virtual bool __is_pointer_p() const;


    virtual bool __is_function_p() const;







    virtual bool __do_catch(const type_info *__thr_type, void **__thr_obj,
       unsigned __outer) const;


    virtual bool __do_upcast(const __cxxabiv1::__class_type_info *__target,
        void **__obj_ptr) const;

  protected:
    const char *__name;

    explicit type_info(const char *__n): __name(__n) { }

  private:

    type_info& operator=(const type_info&);
    type_info(const type_info&);
  };







  class bad_cast : public exception
  {
  public:
    bad_cast() throw() { }



    virtual ~bad_cast() throw();


    virtual const char* what() const throw();
  };





  class bad_typeid : public exception
  {
  public:
    bad_typeid () throw() { }



    virtual ~bad_typeid() throw();


    virtual const char* what() const throw();
  };
}

#pragma GCC visibility pop

}
# 55 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 2 3

# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/tuple" 1 3
# 32 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/tuple" 3
       
# 33 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/tuple" 3





# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/utility" 1 3
# 59 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/utility" 3
       
# 60 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/utility" 3
# 70 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/utility" 3
# 1 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_relops.h" 1 3
# 68 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_relops.h" 3
namespace std __attribute__ ((__visibility__ ("default")))
{
  namespace rel_ops
  {
 
# 86 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_relops.h" 3
    template <class _Tp>
      inline bool
      operator!=(const _Tp& __x, const _Tp& __y)
      { return !(__x == __y); }
# 99 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_relops.h" 3
    template <class _Tp>
      inline bool
      operator>(const _Tp& __x, const _Tp& __y)
      { return __y < __x; }
# 112 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_relops.h" 3
    template <class _Tp>
      inline bool
      operator<=(const _Tp& __x, const _Tp& __y)
      { return !(__y < __x); }
# 125 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/bits/stl_relops.h" 3
    template <class _Tp>
      inline bool
      operator>=(const _Tp& __x, const _Tp& __y)
      { return !(__x < __y); }

 
  }

}
# 71 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/utility" 2 3






namespace std __attribute__ ((__visibility__ ("default")))
{


  template<class _Tp>
    class tuple_size;

  template<std::size_t _Int, class _Tp>
    class tuple_element;


  template<class _Tp1, class _Tp2>
    struct tuple_size<std::pair<_Tp1, _Tp2> >
    { static const std::size_t value = 2; };

  template<class _Tp1, class _Tp2>
    const std::size_t
    tuple_size<std::pair<_Tp1, _Tp2> >::value;

  template<class _Tp1, class _Tp2>
    struct tuple_element<0, std::pair<_Tp1, _Tp2> >
    { typedef _Tp1 type; };

  template<class _Tp1, class _Tp2>
    struct tuple_element<1, std::pair<_Tp1, _Tp2> >
    { typedef _Tp2 type; };

  template<std::size_t _Int>
    struct __pair_get;

  template<>
    struct __pair_get<0>
    {
      template<typename _Tp1, typename _Tp2>
      static _Tp1& __get(std::pair<_Tp1, _Tp2>& __pair)
      { return __pair.first; }

      template<typename _Tp1, typename _Tp2>
      static const _Tp1& __const_get(const std::pair<_Tp1, _Tp2>& __pair)
      { return __pair.first; }
    };

  template<>
    struct __pair_get<1>
    {
      template<typename _Tp1, typename _Tp2>
      static _Tp2& __get(std::pair<_Tp1, _Tp2>& __pair)
      { return __pair.second; }

      template<typename _Tp1, typename _Tp2>
      static const _Tp2& __const_get(const std::pair<_Tp1, _Tp2>& __pair)
      { return __pair.second; }
    };

  template<std::size_t _Int, class _Tp1, class _Tp2>
    inline typename tuple_element<_Int, std::pair<_Tp1, _Tp2> >::type&
    get(std::pair<_Tp1, _Tp2>& __in)
    { return __pair_get<_Int>::__get(__in); }

  template<std::size_t _Int, class _Tp1, class _Tp2>
    inline const typename tuple_element<_Int, std::pair<_Tp1, _Tp2> >::type&
    get(const std::pair<_Tp1, _Tp2>& __in)
    { return __pair_get<_Int>::__const_get(__in); }


}
# 39 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/tuple" 2 3

namespace std __attribute__ ((__visibility__ ("default")))
{



  template<typename _Tp>
    struct __add_c_ref
    { typedef const _Tp& type; };

  template<typename _Tp>
    struct __add_c_ref<_Tp&>
    { typedef _Tp& type; };


  template<typename _Tp>
    struct __add_ref
    { typedef _Tp& type; };

  template<typename _Tp>
    struct __add_ref<_Tp&>
    { typedef _Tp& type; };

  template<std::size_t _Idx, typename _Head, bool _IsEmpty>
    struct _Head_base;

  template<std::size_t _Idx, typename _Head>
    struct _Head_base<_Idx, _Head, true>
    : public _Head
    {
      constexpr _Head_base()
      : _Head() { }

      constexpr _Head_base(const _Head& __h)
      : _Head(__h) { }

      template<typename _UHead>
        _Head_base(_UHead&& __h)
 : _Head(std::forward<_UHead>(__h)) { }

      _Head& _M_head() { return *this; }
      const _Head& _M_head() const { return *this; }

      void
      _M_swap_impl(_Head& __h)
      {
 using std::swap;
 swap(__h, _M_head());
      }
    };

  template<std::size_t _Idx, typename _Head>
    struct _Head_base<_Idx, _Head, false>
    {
      constexpr _Head_base()
      : _M_head_impl() { }

      constexpr _Head_base(const _Head& __h)
      : _M_head_impl(__h) { }

      template<typename _UHead>
        _Head_base(_UHead&& __h)
 : _M_head_impl(std::forward<_UHead>(__h)) { }

      _Head& _M_head() { return _M_head_impl; }
      const _Head& _M_head() const { return _M_head_impl; }

      void
      _M_swap_impl(_Head& __h)
      {
 using std::swap;
 swap(__h, _M_head());
      }

      _Head _M_head_impl;
    };
# 124 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/tuple" 3
  template<std::size_t _Idx, typename... _Elements>
    struct _Tuple_impl;





  template<std::size_t _Idx>
    struct _Tuple_impl<_Idx>
    {
    protected:
      void _M_swap_impl(_Tuple_impl&) { }
    };






  template<std::size_t _Idx, typename _Head, typename... _Tail>
    struct _Tuple_impl<_Idx, _Head, _Tail...>
    : public _Tuple_impl<_Idx + 1, _Tail...>,
      private _Head_base<_Idx, _Head, std::is_empty<_Head>::value>
    {
      typedef _Tuple_impl<_Idx + 1, _Tail...> _Inherited;
      typedef _Head_base<_Idx, _Head, std::is_empty<_Head>::value> _Base;

      _Head& _M_head() { return _Base::_M_head(); }
      const _Head& _M_head() const { return _Base::_M_head(); }

      _Inherited& _M_tail() { return *this; }
      const _Inherited& _M_tail() const { return *this; }

      constexpr _Tuple_impl()
      : _Inherited(), _Base() { }

      explicit
      constexpr _Tuple_impl(const _Head& __head, const _Tail&... __tail)
      : _Inherited(__tail...), _Base(__head) { }

      template<typename _UHead, typename... _UTail>
        explicit
        _Tuple_impl(_UHead&& __head, _UTail&&... __tail)
 : _Inherited(std::forward<_UTail>(__tail)...),
   _Base(std::forward<_UHead>(__head)) { }

      constexpr _Tuple_impl(const _Tuple_impl&) = default;

      _Tuple_impl(_Tuple_impl&& __in)
      : _Inherited(std::move(__in._M_tail())),
 _Base(std::forward<_Head>(__in._M_head())) { }

      template<typename... _UElements>
        _Tuple_impl(const _Tuple_impl<_Idx, _UElements...>& __in)
 : _Inherited(__in._M_tail()), _Base(__in._M_head()) { }

      template<typename... _UElements>
        _Tuple_impl(_Tuple_impl<_Idx, _UElements...>&& __in)
 : _Inherited(std::move(__in._M_tail())),
   _Base(std::move(__in._M_head())) { }

      _Tuple_impl&
      operator=(const _Tuple_impl& __in)
      {
 _M_head() = __in._M_head();
 _M_tail() = __in._M_tail();
 return *this;
      }

      _Tuple_impl&
      operator=(_Tuple_impl&& __in)
      {
 _M_head() = std::move(__in._M_head());
 _M_tail() = std::move(__in._M_tail());
 return *this;
      }

      template<typename... _UElements>
        _Tuple_impl&
        operator=(const _Tuple_impl<_Idx, _UElements...>& __in)
        {
   _M_head() = __in._M_head();
   _M_tail() = __in._M_tail();
   return *this;
 }

      template<typename... _UElements>
        _Tuple_impl&
        operator=(_Tuple_impl<_Idx, _UElements...>&& __in)
        {
   _M_head() = std::move(__in._M_head());
   _M_tail() = std::move(__in._M_tail());
   return *this;
 }

    protected:
      void
      _M_swap_impl(_Tuple_impl& __in)
      {
 _Base::_M_swap_impl(__in._M_head());
 _Inherited::_M_swap_impl(__in._M_tail());
      }
    };


  template<typename... _Elements>
    class tuple : public _Tuple_impl<0, _Elements...>
    {
      typedef _Tuple_impl<0, _Elements...> _Inherited;

    public:
      constexpr tuple()
      : _Inherited() { }

      explicit
      constexpr tuple(const _Elements&... __elements)
      : _Inherited(__elements...) { }

      template<typename... _UElements, typename = typename
        std::enable_if<sizeof...(_UElements)
         == sizeof...(_Elements)>::type>
        explicit
        tuple(_UElements&&... __elements)
 : _Inherited(std::forward<_UElements>(__elements)...) { }

      constexpr tuple(const tuple&) = default;

      tuple(tuple&& __in)
      : _Inherited(static_cast<_Inherited&&>(__in)) { }

      template<typename... _UElements, typename = typename
        std::enable_if<sizeof...(_UElements)
         == sizeof...(_Elements)>::type>
        tuple(const tuple<_UElements...>& __in)
        : _Inherited(static_cast<const _Tuple_impl<0, _UElements...>&>(__in))
        { }

      template<typename... _UElements, typename = typename
        std::enable_if<sizeof...(_UElements)
         == sizeof...(_Elements)>::type>
        tuple(tuple<_UElements...>&& __in)
        : _Inherited(static_cast<_Tuple_impl<0, _UElements...>&&>(__in)) { }

      tuple&
      operator=(const tuple& __in)
      {
 static_cast<_Inherited&>(*this) = __in;
 return *this;
      }

      tuple&
      operator=(tuple&& __in)
      {
 static_cast<_Inherited&>(*this) = std::move(__in);
 return *this;
      }

      template<typename... _UElements, typename = typename
        std::enable_if<sizeof...(_UElements)
         == sizeof...(_Elements)>::type>
        tuple&
        operator=(const tuple<_UElements...>& __in)
        {
   static_cast<_Inherited&>(*this) = __in;
   return *this;
 }

      template<typename... _UElements, typename = typename
        std::enable_if<sizeof...(_UElements)
         == sizeof...(_Elements)>::type>
        tuple&
        operator=(tuple<_UElements...>&& __in)
        {
   static_cast<_Inherited&>(*this) = std::move(__in);
   return *this;
 }

      void
      swap(tuple& __in)
      { _Inherited::_M_swap_impl(__in); }
    };

  template<>
    class tuple<>
    {
    public:
      void swap(tuple&) { }
    };


  template<typename _T1, typename _T2>
    class tuple<_T1, _T2> : public _Tuple_impl<0, _T1, _T2>
    {
      typedef _Tuple_impl<0, _T1, _T2> _Inherited;

    public:
      constexpr tuple()
      : _Inherited() { }

      explicit
      constexpr tuple(const _T1& __a1, const _T2& __a2)
      : _Inherited(__a1, __a2) { }

      template<typename _U1, typename _U2>
        explicit
        tuple(_U1&& __a1, _U2&& __a2)
 : _Inherited(std::forward<_U1>(__a1), std::forward<_U2>(__a2)) { }

      constexpr tuple(const tuple&) = default;

      tuple(tuple&& __in)
      : _Inherited(static_cast<_Inherited&&>(__in)) { }

      template<typename _U1, typename _U2>
        tuple(const tuple<_U1, _U2>& __in)
 : _Inherited(static_cast<const _Tuple_impl<0, _U1, _U2>&>(__in)) { }

      template<typename _U1, typename _U2>
        tuple(tuple<_U1, _U2>&& __in)
 : _Inherited(static_cast<_Tuple_impl<0, _U1, _U2>&&>(__in)) { }

      template<typename _U1, typename _U2>
        tuple(const pair<_U1, _U2>& __in)
 : _Inherited(__in.first, __in.second) { }

      template<typename _U1, typename _U2>
        tuple(pair<_U1, _U2>&& __in)
 : _Inherited(std::forward<_U1>(__in.first),
       std::forward<_U2>(__in.second)) { }

      tuple&
      operator=(const tuple& __in)
      {
 static_cast<_Inherited&>(*this) = __in;
 return *this;
      }

      tuple&
      operator=(tuple&& __in)
      {
 static_cast<_Inherited&>(*this) = std::move(__in);
 return *this;
      }

      template<typename _U1, typename _U2>
        tuple&
        operator=(const tuple<_U1, _U2>& __in)
        {
   static_cast<_Inherited&>(*this) = __in;
   return *this;
 }

      template<typename _U1, typename _U2>
        tuple&
        operator=(tuple<_U1, _U2>&& __in)
        {
   static_cast<_Inherited&>(*this) = std::move(__in);
   return *this;
 }

      template<typename _U1, typename _U2>
        tuple&
        operator=(const pair<_U1, _U2>& __in)
        {
   this->_M_head() = __in.first;
   this->_M_tail()._M_head() = __in.second;
   return *this;
 }

      template<typename _U1, typename _U2>
        tuple&
        operator=(pair<_U1, _U2>&& __in)
        {
   this->_M_head() = std::forward<_U1>(__in.first);
   this->_M_tail()._M_head() = std::forward<_U2>(__in.second);
   return *this;
 }

      void
      swap(tuple& __in)
      {
 using std::swap;
 swap(this->_M_head(), __in._M_head());
 swap(this->_M_tail()._M_head(), __in._M_tail()._M_head());
      }
    };


  template<typename _T1>
    class tuple<_T1> : public _Tuple_impl<0, _T1>
    {
      typedef _Tuple_impl<0, _T1> _Inherited;

    public:
      constexpr tuple()
      : _Inherited() { }

      explicit
      constexpr tuple(const _T1& __a1)
      : _Inherited(__a1) { }

      template<typename _U1, typename = typename
        std::enable_if<std::is_convertible<_U1, _T1>::value>::type>
        explicit
        tuple(_U1&& __a1)
 : _Inherited(std::forward<_U1>(__a1)) { }

      constexpr tuple(const tuple&) = default;

      tuple(tuple&& __in)
      : _Inherited(static_cast<_Inherited&&>(__in)) { }

      template<typename _U1>
        tuple(const tuple<_U1>& __in)
 : _Inherited(static_cast<const _Tuple_impl<0, _U1>&>(__in)) { }

      template<typename _U1>
        tuple(tuple<_U1>&& __in)
 : _Inherited(static_cast<_Tuple_impl<0, _U1>&&>(__in)) { }

      tuple&
      operator=(const tuple& __in)
      {
 static_cast<_Inherited&>(*this) = __in;
 return *this;
      }

      tuple&
      operator=(tuple&& __in)
      {
 static_cast<_Inherited&>(*this) = std::move(__in);
 return *this;
      }

      template<typename _U1>
        tuple&
        operator=(const tuple<_U1>& __in)
        {
   static_cast<_Inherited&>(*this) = __in;
   return *this;
 }

      template<typename _U1>
        tuple&
        operator=(tuple<_U1>&& __in)
        {
   static_cast<_Inherited&>(*this) = std::move(__in);
   return *this;
 }

      void
      swap(tuple& __in)
      { _Inherited::_M_swap_impl(__in); }
    };



  template<std::size_t __i, typename _Tp>
    struct tuple_element;





  template<std::size_t __i, typename _Head, typename... _Tail>
    struct tuple_element<__i, tuple<_Head, _Tail...> >
    : tuple_element<__i - 1, tuple<_Tail...> > { };




  template<typename _Head, typename... _Tail>
    struct tuple_element<0, tuple<_Head, _Tail...> >
    {
      typedef _Head type;
    };


  template<typename _Tp>
    struct tuple_size;


  template<typename... _Elements>
    struct tuple_size<tuple<_Elements...> >
    {
      static const std::size_t value = sizeof...(_Elements);
    };

  template<typename... _Elements>
    const std::size_t tuple_size<tuple<_Elements...> >::value;

  template<std::size_t __i, typename _Head, typename... _Tail>
    inline typename __add_ref<_Head>::type
    __get_helper(_Tuple_impl<__i, _Head, _Tail...>& __t)
    { return __t._M_head(); }

  template<std::size_t __i, typename _Head, typename... _Tail>
    inline typename __add_c_ref<_Head>::type
    __get_helper(const _Tuple_impl<__i, _Head, _Tail...>& __t)
    { return __t._M_head(); }



  template<std::size_t __i, typename... _Elements>
    inline typename __add_ref<
                      typename tuple_element<__i, tuple<_Elements...> >::type
                    >::type
    get(tuple<_Elements...>& __t)
    { return __get_helper<__i>(__t); }

  template<std::size_t __i, typename... _Elements>
    inline typename __add_c_ref<
                      typename tuple_element<__i, tuple<_Elements...> >::type
                    >::type
    get(const tuple<_Elements...>& __t)
    { return __get_helper<__i>(__t); }


  template<std::size_t __check_equal_size, std::size_t __i, std::size_t __j,
    typename _Tp, typename _Up>
    struct __tuple_compare;

  template<std::size_t __i, std::size_t __j, typename _Tp, typename _Up>
    struct __tuple_compare<0, __i, __j, _Tp, _Up>
    {
      static bool __eq(const _Tp& __t, const _Up& __u)
      {
 return (get<__i>(__t) == get<__i>(__u) &&
  __tuple_compare<0, __i + 1, __j, _Tp, _Up>::__eq(__t, __u));
      }

      static bool __less(const _Tp& __t, const _Up& __u)
      {
 return ((get<__i>(__t) < get<__i>(__u))
  || !(get<__i>(__u) < get<__i>(__t)) &&
  __tuple_compare<0, __i + 1, __j, _Tp, _Up>::__less(__t, __u));
      }
    };

  template<std::size_t __i, typename _Tp, typename _Up>
    struct __tuple_compare<0, __i, __i, _Tp, _Up>
    {
      static bool __eq(const _Tp&, const _Up&)
      { return true; }

      static bool __less(const _Tp&, const _Up&)
      { return false; }
    };

  template<typename... _TElements, typename... _UElements>
    bool
    operator==(const tuple<_TElements...>& __t,
        const tuple<_UElements...>& __u)
    {
      typedef tuple<_TElements...> _Tp;
      typedef tuple<_UElements...> _Up;
      return (__tuple_compare<tuple_size<_Tp>::value - tuple_size<_Up>::value,
       0, tuple_size<_Tp>::value, _Tp, _Up>::__eq(__t, __u));
    }

  template<typename... _TElements, typename... _UElements>
    bool
    operator<(const tuple<_TElements...>& __t,
       const tuple<_UElements...>& __u)
    {
      typedef tuple<_TElements...> _Tp;
      typedef tuple<_UElements...> _Up;
      return (__tuple_compare<tuple_size<_Tp>::value - tuple_size<_Up>::value,
       0, tuple_size<_Tp>::value, _Tp, _Up>::__less(__t, __u));
    }

  template<typename... _TElements, typename... _UElements>
    inline bool
    operator!=(const tuple<_TElements...>& __t,
        const tuple<_UElements...>& __u)
    { return !(__t == __u); }

  template<typename... _TElements, typename... _UElements>
    inline bool
    operator>(const tuple<_TElements...>& __t,
       const tuple<_UElements...>& __u)
    { return __u < __t; }

  template<typename... _TElements, typename... _UElements>
    inline bool
    operator<=(const tuple<_TElements...>& __t,
        const tuple<_UElements...>& __u)
    { return !(__u < __t); }

  template<typename... _TElements, typename... _UElements>
    inline bool
    operator>=(const tuple<_TElements...>& __t,
        const tuple<_UElements...>& __u)
    { return !(__t < __u); }


  template<typename... _Elements>
    inline tuple<typename __decay_and_strip<_Elements>::__type...>
    make_tuple(_Elements&&... __args)
    {
      typedef tuple<typename __decay_and_strip<_Elements>::__type...>
 __result_type;
      return __result_type(std::forward<_Elements>(__args)...);
    }

  template<typename... _Elements>
    inline tuple<_Elements&&...>
    forward_as_tuple(_Elements&&... __args)
    { return tuple<_Elements&&...>(std::forward<_Elements>(__args)...); }

  template<std::size_t...> struct __index_holder { };

  template<std::size_t __i, typename _IdxHolder, typename... _Elements>
    struct __index_holder_impl;

  template<std::size_t __i, std::size_t... _Indexes, typename _IdxHolder,
    typename... _Elements>
    struct __index_holder_impl<__i, __index_holder<_Indexes...>,
          _IdxHolder, _Elements...>
    {
      typedef typename __index_holder_impl<__i + 1,
        __index_holder<_Indexes..., __i>,
        _Elements...>::type type;
    };

  template<std::size_t __i, std::size_t... _Indexes>
    struct __index_holder_impl<__i, __index_holder<_Indexes...> >
    { typedef __index_holder<_Indexes...> type; };

  template<typename... _Elements>
    struct __make_index_holder
    : __index_holder_impl<0, __index_holder<>, _Elements...> { };

  template<typename... _TElements, std::size_t... _TIdx,
    typename... _UElements, std::size_t... _UIdx>
    inline tuple<_TElements..., _UElements...>
    __tuple_cat_helper(const tuple<_TElements...>& __t,
         const __index_holder<_TIdx...>&,
                       const tuple<_UElements...>& __u,
         const __index_holder<_UIdx...>&)
    { return tuple<_TElements..., _UElements...>(get<_TIdx>(__t)...,
       get<_UIdx>(__u)...); }

  template<typename... _TElements, std::size_t... _TIdx,
    typename... _UElements, std::size_t... _UIdx>
    inline tuple<_TElements..., _UElements...>
    __tuple_cat_helper(tuple<_TElements...>&& __t,
         const __index_holder<_TIdx...>&,
         const tuple<_UElements...>& __u,
         const __index_holder<_UIdx...>&)
    { return tuple<_TElements..., _UElements...>
 (std::move(get<_TIdx>(__t))..., get<_UIdx>(__u)...); }

  template<typename... _TElements, std::size_t... _TIdx,
    typename... _UElements, std::size_t... _UIdx>
    inline tuple<_TElements..., _UElements...>
    __tuple_cat_helper(const tuple<_TElements...>& __t,
         const __index_holder<_TIdx...>&,
         tuple<_UElements...>&& __u,
         const __index_holder<_UIdx...>&)
    { return tuple<_TElements..., _UElements...>
 (get<_TIdx>(__t)..., std::move(get<_UIdx>(__u))...); }

  template<typename... _TElements, std::size_t... _TIdx,
    typename... _UElements, std::size_t... _UIdx>
    inline tuple<_TElements..., _UElements...>
    __tuple_cat_helper(tuple<_TElements...>&& __t,
         const __index_holder<_TIdx...>&,
         tuple<_UElements...>&& __u,
         const __index_holder<_UIdx...>&)
    { return tuple<_TElements..., _UElements...>
 (std::move(get<_TIdx>(__t))..., std::move(get<_UIdx>(__u))...); }

  template<typename... _TElements, typename... _UElements>
    inline tuple<_TElements..., _UElements...>
    tuple_cat(const tuple<_TElements...>& __t, const tuple<_UElements...>& __u)
    {
      return __tuple_cat_helper(__t, typename
    __make_index_holder<_TElements...>::type(),
    __u, typename
    __make_index_holder<_UElements...>::type());
    }

  template<typename... _TElements, typename... _UElements>
    inline tuple<_TElements..., _UElements...>
    tuple_cat(tuple<_TElements...>&& __t, const tuple<_UElements...>& __u)
    {
      return __tuple_cat_helper(std::move(__t), typename
     __make_index_holder<_TElements...>::type(),
     __u, typename
     __make_index_holder<_UElements...>::type());
    }

  template<typename... _TElements, typename... _UElements>
    inline tuple<_TElements..., _UElements...>
    tuple_cat(const tuple<_TElements...>& __t, tuple<_UElements...>&& __u)
    {
      return __tuple_cat_helper(__t, typename
    __make_index_holder<_TElements...>::type(),
    std::move(__u), typename
    __make_index_holder<_UElements...>::type());
    }

  template<typename... _TElements, typename... _UElements>
    inline tuple<_TElements..., _UElements...>
    tuple_cat(tuple<_TElements...>&& __t, tuple<_UElements...>&& __u)
    {
      return __tuple_cat_helper(std::move(__t), typename
    __make_index_holder<_TElements...>::type(),
    std::move(__u), typename
    __make_index_holder<_UElements...>::type());
    }

  template<typename... _Elements>
    inline tuple<_Elements&...>
    tie(_Elements&... __args)
    { return tuple<_Elements&...>(__args...); }

  template<typename... _Elements>
    inline void
    swap(tuple<_Elements...>& __x, tuple<_Elements...>& __y)
    { __x.swap(__y); }



  struct _Swallow_assign
  {
    template<class _Tp>
      const _Swallow_assign&
      operator=(const _Tp&) const
      { return *this; }
  };

  const _Swallow_assign ignore{};





  template<int... _Indexes>
    struct _Index_tuple
    {
      typedef _Index_tuple<_Indexes..., sizeof...(_Indexes)> __next;
    };


  template<std::size_t _Num>
    struct _Build_index_tuple
    {
      typedef typename _Build_index_tuple<_Num-1>::__type::__next __type;
    };

  template<>
    struct _Build_index_tuple<0>
    {
      typedef _Index_tuple<> __type;
    };


  template<class _T1, class _T2>
    template<typename _Tp, typename... _Args>
      inline _Tp
      pair<_T1, _T2>::
      __cons(tuple<_Args...>&& __tuple)
      {
 typedef typename _Build_index_tuple<sizeof...(_Args)>::__type
   _Indexes;
 return __do_cons<_Tp>(std::move(__tuple), _Indexes());
      }

  template<class _T1, class _T2>
    template<typename _Tp, typename... _Args, int... _Indexes>
      inline _Tp
      pair<_T1, _T2>::
      __do_cons(tuple<_Args...>&& __tuple,
  const _Index_tuple<_Indexes...>&)
      { return _Tp(std::forward<_Args>(get<_Indexes>(__tuple))...); }


}
# 57 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 2 3




namespace std __attribute__ ((__visibility__ ("default")))
{


template<typename _Tp> class __has_result_type_helper : __sfinae_types { template<typename _Up> struct _Wrap_type { }; template<typename _Up> static __one __test(_Wrap_type<typename _Up::result_type>*); template<typename _Up> static __two __test(...); public: static const bool value = sizeof(__test<_Tp>(0)) == 1; }; template<typename _Tp> struct __has_result_type : integral_constant<bool, __has_result_type_helper <typename remove_cv<_Tp>::type>::value> { };


  template<bool _Has_result_type, typename _Functor>
    struct _Maybe_get_result_type
    { };

  template<typename _Functor>
    struct _Maybe_get_result_type<true, _Functor>
    { typedef typename _Functor::result_type result_type; };





  template<typename _Functor>
    struct _Weak_result_type_impl
    : _Maybe_get_result_type<__has_result_type<_Functor>::value, _Functor>
    { };


  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(_ArgTypes...)>
    { typedef _Res result_type; };

  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(_ArgTypes......)>
    { typedef _Res result_type; };

  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(_ArgTypes...) const>
    { typedef _Res result_type; };

  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(_ArgTypes......) const>
    { typedef _Res result_type; };

  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(_ArgTypes...) volatile>
    { typedef _Res result_type; };

  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(_ArgTypes......) volatile>
    { typedef _Res result_type; };

  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(_ArgTypes...) const volatile>
    { typedef _Res result_type; };

  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(_ArgTypes......) const volatile>
    { typedef _Res result_type; };


  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(&)(_ArgTypes...)>
    { typedef _Res result_type; };

  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(&)(_ArgTypes......)>
    { typedef _Res result_type; };


  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(*)(_ArgTypes...)>
    { typedef _Res result_type; };

  template<typename _Res, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res(*)(_ArgTypes......)>
    { typedef _Res result_type; };


  template<typename _Res, typename _Class, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res (_Class::*)(_ArgTypes...)>
    { typedef _Res result_type; };

  template<typename _Res, typename _Class, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res (_Class::*)(_ArgTypes......)>
    { typedef _Res result_type; };


  template<typename _Res, typename _Class, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res (_Class::*)(_ArgTypes...) const>
    { typedef _Res result_type; };

  template<typename _Res, typename _Class, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res (_Class::*)(_ArgTypes......) const>
    { typedef _Res result_type; };


  template<typename _Res, typename _Class, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res (_Class::*)(_ArgTypes...) volatile>
    { typedef _Res result_type; };

  template<typename _Res, typename _Class, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res (_Class::*)(_ArgTypes......) volatile>
    { typedef _Res result_type; };


  template<typename _Res, typename _Class, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res (_Class::*)(_ArgTypes...)
      const volatile>
    { typedef _Res result_type; };

  template<typename _Res, typename _Class, typename... _ArgTypes>
    struct _Weak_result_type_impl<_Res (_Class::*)(_ArgTypes......)
      const volatile>
    { typedef _Res result_type; };





  template<typename _Functor>
    struct _Weak_result_type
    : _Weak_result_type_impl<typename remove_cv<_Functor>::type>
    { };


  template<typename _Tp>
    struct _Derives_from_unary_function : __sfinae_types
    {
    private:
      template<typename _T1, typename _Res>
 static __one __test(const volatile unary_function<_T1, _Res>*);



      static __two __test(...);

    public:
      static const bool value = sizeof(__test((_Tp*)0)) == 1;
    };


  template<typename _Tp>
    struct _Derives_from_binary_function : __sfinae_types
    {
    private:
      template<typename _T1, typename _T2, typename _Res>
 static __one __test(const volatile binary_function<_T1, _T2, _Res>*);



      static __two __test(...);

    public:
      static const bool value = sizeof(__test((_Tp*)0)) == 1;
    };


  template<typename _Tp, bool _IsFunctionType = is_function<_Tp>::value>
    struct _Function_to_function_pointer
    {
      typedef _Tp type;
    };

  template<typename _Tp>
    struct _Function_to_function_pointer<_Tp, true>
    {
      typedef _Tp* type;
    };





  template<typename _Functor, typename... _Args>
    inline
    typename enable_if<
      (!is_member_pointer<_Functor>::value
       && !is_function<_Functor>::value
       && !is_function<typename remove_pointer<_Functor>::type>::value),
      typename result_of<_Functor(_Args...)>::type
    >::type
    __invoke(_Functor& __f, _Args&&... __args)
    {
      return __f(std::forward<_Args>(__args)...);
    }


  template<typename _Functor, typename... _Args>
    inline
    typename enable_if<
      (is_pointer<_Functor>::value
       && is_function<typename remove_pointer<_Functor>::type>::value),
      typename result_of<_Functor(_Args...)>::type
    >::type
    __invoke(_Functor __f, _Args&&... __args)
    {
      return __f(std::forward<_Args>(__args)...);
    }






  template<bool _Unary, bool _Binary, typename _Tp>
    struct _Reference_wrapper_base_impl;


  template<typename _Tp>
    struct _Reference_wrapper_base_impl<false, false, _Tp>
    : _Weak_result_type<_Tp>
    { };


  template<typename _Tp>
    struct _Reference_wrapper_base_impl<true, false, _Tp>
    : unary_function<typename _Tp::argument_type,
       typename _Tp::result_type>
    { };


  template<typename _Tp>
    struct _Reference_wrapper_base_impl<false, true, _Tp>
    : binary_function<typename _Tp::first_argument_type,
        typename _Tp::second_argument_type,
        typename _Tp::result_type>
    { };



   template<typename _Tp>
    struct _Reference_wrapper_base_impl<true, true, _Tp>
    : unary_function<typename _Tp::argument_type,
       typename _Tp::result_type>,
      binary_function<typename _Tp::first_argument_type,
        typename _Tp::second_argument_type,
        typename _Tp::result_type>
    {
      typedef typename _Tp::result_type result_type;
    };







  template<typename _Tp>
    struct _Reference_wrapper_base
    : _Reference_wrapper_base_impl<
      _Derives_from_unary_function<_Tp>::value,
      _Derives_from_binary_function<_Tp>::value,
      _Tp>
    { };


  template<typename _Res, typename _T1>
    struct _Reference_wrapper_base<_Res(_T1)>
    : unary_function<_T1, _Res>
    { };

  template<typename _Res, typename _T1>
    struct _Reference_wrapper_base<_Res(_T1) const>
    : unary_function<_T1, _Res>
    { };

  template<typename _Res, typename _T1>
    struct _Reference_wrapper_base<_Res(_T1) volatile>
    : unary_function<_T1, _Res>
    { };

  template<typename _Res, typename _T1>
    struct _Reference_wrapper_base<_Res(_T1) const volatile>
    : unary_function<_T1, _Res>
    { };


  template<typename _Res, typename _T1, typename _T2>
    struct _Reference_wrapper_base<_Res(_T1, _T2)>
    : binary_function<_T1, _T2, _Res>
    { };

  template<typename _Res, typename _T1, typename _T2>
    struct _Reference_wrapper_base<_Res(_T1, _T2) const>
    : binary_function<_T1, _T2, _Res>
    { };

  template<typename _Res, typename _T1, typename _T2>
    struct _Reference_wrapper_base<_Res(_T1, _T2) volatile>
    : binary_function<_T1, _T2, _Res>
    { };

  template<typename _Res, typename _T1, typename _T2>
    struct _Reference_wrapper_base<_Res(_T1, _T2) const volatile>
    : binary_function<_T1, _T2, _Res>
    { };


  template<typename _Res, typename _T1>
    struct _Reference_wrapper_base<_Res(*)(_T1)>
    : unary_function<_T1, _Res>
    { };


  template<typename _Res, typename _T1, typename _T2>
    struct _Reference_wrapper_base<_Res(*)(_T1, _T2)>
    : binary_function<_T1, _T2, _Res>
    { };


  template<typename _Res, typename _T1>
    struct _Reference_wrapper_base<_Res (_T1::*)()>
    : unary_function<_T1*, _Res>
    { };


  template<typename _Res, typename _T1, typename _T2>
    struct _Reference_wrapper_base<_Res (_T1::*)(_T2)>
    : binary_function<_T1*, _T2, _Res>
    { };


  template<typename _Res, typename _T1>
    struct _Reference_wrapper_base<_Res (_T1::*)() const>
    : unary_function<const _T1*, _Res>
    { };


  template<typename _Res, typename _T1, typename _T2>
    struct _Reference_wrapper_base<_Res (_T1::*)(_T2) const>
    : binary_function<const _T1*, _T2, _Res>
    { };


  template<typename _Res, typename _T1>
    struct _Reference_wrapper_base<_Res (_T1::*)() volatile>
    : unary_function<volatile _T1*, _Res>
    { };


  template<typename _Res, typename _T1, typename _T2>
    struct _Reference_wrapper_base<_Res (_T1::*)(_T2) volatile>
    : binary_function<volatile _T1*, _T2, _Res>
    { };


  template<typename _Res, typename _T1>
    struct _Reference_wrapper_base<_Res (_T1::*)() const volatile>
    : unary_function<const volatile _T1*, _Res>
    { };


  template<typename _Res, typename _T1, typename _T2>
    struct _Reference_wrapper_base<_Res (_T1::*)(_T2) const volatile>
    : binary_function<const volatile _T1*, _T2, _Res>
    { };






  template<typename _Tp>
    class reference_wrapper
    : public _Reference_wrapper_base<typename remove_cv<_Tp>::type>
    {


      typedef typename _Function_to_function_pointer<_Tp>::type
 _M_func_type;

      _Tp* _M_data;
    public:
      typedef _Tp type;

      reference_wrapper(_Tp& __indata)
      : _M_data(std::__addressof(__indata))
      { }

      reference_wrapper(_Tp&&) = delete;

      reference_wrapper(const reference_wrapper<_Tp>& __inref):
      _M_data(__inref._M_data)
      { }

      reference_wrapper&
      operator=(const reference_wrapper<_Tp>& __inref)
      {
 _M_data = __inref._M_data;
 return *this;
      }

      operator _Tp&() const
      { return this->get(); }

      _Tp&
      get() const
      { return *_M_data; }

      template<typename... _Args>
 typename result_of<_M_func_type(_Args...)>::type
 operator()(_Args&&... __args) const
 {
   return __invoke(get(), std::forward<_Args>(__args)...);
 }
    };



  template<typename _Tp>
    inline reference_wrapper<_Tp>
    ref(_Tp& __t)
    { return reference_wrapper<_Tp>(__t); }


  template<typename _Tp>
    inline reference_wrapper<const _Tp>
    cref(const _Tp& __t)
    { return reference_wrapper<const _Tp>(__t); }


  template<typename _Tp>
    inline reference_wrapper<_Tp>
    ref(reference_wrapper<_Tp> __t)
    { return ref(__t.get()); }


  template<typename _Tp>
    inline reference_wrapper<const _Tp>
    cref(reference_wrapper<_Tp> __t)
    { return cref(__t.get()); }



  template<typename _MemberPointer>
    class _Mem_fn;






  template<typename _Res, typename... _ArgTypes>
    struct _Maybe_unary_or_binary_function { };


  template<typename _Res, typename _T1>
    struct _Maybe_unary_or_binary_function<_Res, _T1>
    : std::unary_function<_T1, _Res> { };


  template<typename _Res, typename _T1, typename _T2>
    struct _Maybe_unary_or_binary_function<_Res, _T1, _T2>
    : std::binary_function<_T1, _T2, _Res> { };


  template<typename _Res, typename _Class, typename... _ArgTypes>
    class _Mem_fn<_Res (_Class::*)(_ArgTypes...)>
    : public _Maybe_unary_or_binary_function<_Res, _Class*, _ArgTypes...>
    {
      typedef _Res (_Class::*_Functor)(_ArgTypes...);

      template<typename _Tp>
 _Res
 _M_call(_Tp& __object, const volatile _Class *,
  _ArgTypes... __args) const
 { return (__object.*__pmf)(std::forward<_ArgTypes>(__args)...); }

      template<typename _Tp>
 _Res
 _M_call(_Tp& __ptr, const volatile void *, _ArgTypes... __args) const
 { return ((*__ptr).*__pmf)(std::forward<_ArgTypes>(__args)...); }

    public:
      typedef _Res result_type;

      explicit _Mem_fn(_Functor __pmf) : __pmf(__pmf) { }


      _Res
      operator()(_Class& __object, _ArgTypes... __args) const
      { return (__object.*__pmf)(std::forward<_ArgTypes>(__args)...); }


      _Res
      operator()(_Class* __object, _ArgTypes... __args) const
      { return (__object->*__pmf)(std::forward<_ArgTypes>(__args)...); }


      template<typename _Tp>
 _Res
 operator()(_Tp& __object, _ArgTypes... __args) const
 {
   return _M_call(__object, &__object,
       std::forward<_ArgTypes>(__args)...);
 }

    private:
      _Functor __pmf;
    };


  template<typename _Res, typename _Class, typename... _ArgTypes>
    class _Mem_fn<_Res (_Class::*)(_ArgTypes...) const>
    : public _Maybe_unary_or_binary_function<_Res, const _Class*,
          _ArgTypes...>
    {
      typedef _Res (_Class::*_Functor)(_ArgTypes...) const;

      template<typename _Tp>
 _Res
 _M_call(_Tp& __object, const volatile _Class *,
  _ArgTypes... __args) const
 { return (__object.*__pmf)(std::forward<_ArgTypes>(__args)...); }

      template<typename _Tp>
 _Res
 _M_call(_Tp& __ptr, const volatile void *, _ArgTypes... __args) const
 { return ((*__ptr).*__pmf)(std::forward<_ArgTypes>(__args)...); }

    public:
      typedef _Res result_type;

      explicit _Mem_fn(_Functor __pmf) : __pmf(__pmf) { }


      _Res
      operator()(const _Class& __object, _ArgTypes... __args) const
      { return (__object.*__pmf)(std::forward<_ArgTypes>(__args)...); }


      _Res
      operator()(const _Class* __object, _ArgTypes... __args) const
      { return (__object->*__pmf)(std::forward<_ArgTypes>(__args)...); }


      template<typename _Tp>
 _Res operator()(_Tp& __object, _ArgTypes... __args) const
 {
   return _M_call(__object, &__object,
       std::forward<_ArgTypes>(__args)...);
 }

    private:
      _Functor __pmf;
    };


  template<typename _Res, typename _Class, typename... _ArgTypes>
    class _Mem_fn<_Res (_Class::*)(_ArgTypes...) volatile>
    : public _Maybe_unary_or_binary_function<_Res, volatile _Class*,
          _ArgTypes...>
    {
      typedef _Res (_Class::*_Functor)(_ArgTypes...) volatile;

      template<typename _Tp>
 _Res
 _M_call(_Tp& __object, const volatile _Class *,
  _ArgTypes... __args) const
 { return (__object.*__pmf)(std::forward<_ArgTypes>(__args)...); }

      template<typename _Tp>
 _Res
 _M_call(_Tp& __ptr, const volatile void *, _ArgTypes... __args) const
 { return ((*__ptr).*__pmf)(std::forward<_ArgTypes>(__args)...); }

    public:
      typedef _Res result_type;

      explicit _Mem_fn(_Functor __pmf) : __pmf(__pmf) { }


      _Res
      operator()(volatile _Class& __object, _ArgTypes... __args) const
      { return (__object.*__pmf)(std::forward<_ArgTypes>(__args)...); }


      _Res
      operator()(volatile _Class* __object, _ArgTypes... __args) const
      { return (__object->*__pmf)(std::forward<_ArgTypes>(__args)...); }


      template<typename _Tp>
 _Res
 operator()(_Tp& __object, _ArgTypes... __args) const
 {
   return _M_call(__object, &__object,
       std::forward<_ArgTypes>(__args)...);
 }

    private:
      _Functor __pmf;
    };


  template<typename _Res, typename _Class, typename... _ArgTypes>
    class _Mem_fn<_Res (_Class::*)(_ArgTypes...) const volatile>
    : public _Maybe_unary_or_binary_function<_Res, const volatile _Class*,
          _ArgTypes...>
    {
      typedef _Res (_Class::*_Functor)(_ArgTypes...) const volatile;

      template<typename _Tp>
 _Res
 _M_call(_Tp& __object, const volatile _Class *,
  _ArgTypes... __args) const
 { return (__object.*__pmf)(std::forward<_ArgTypes>(__args)...); }

      template<typename _Tp>
 _Res
 _M_call(_Tp& __ptr, const volatile void *, _ArgTypes... __args) const
 { return ((*__ptr).*__pmf)(std::forward<_ArgTypes>(__args)...); }

    public:
      typedef _Res result_type;

      explicit _Mem_fn(_Functor __pmf) : __pmf(__pmf) { }


      _Res
      operator()(const volatile _Class& __object, _ArgTypes... __args) const
      { return (__object.*__pmf)(std::forward<_ArgTypes>(__args)...); }


      _Res
      operator()(const volatile _Class* __object, _ArgTypes... __args) const
      { return (__object->*__pmf)(std::forward<_ArgTypes>(__args)...); }


      template<typename _Tp>
 _Res operator()(_Tp& __object, _ArgTypes... __args) const
 {
   return _M_call(__object, &__object,
       std::forward<_ArgTypes>(__args)...);
 }

    private:
      _Functor __pmf;
    };


  template<typename _Tp, bool>
    struct _Mem_fn_const_or_non
    {
      typedef const _Tp& type;
    };

  template<typename _Tp>
    struct _Mem_fn_const_or_non<_Tp, false>
    {
      typedef _Tp& type;
    };

  template<typename _Res, typename _Class>
    class _Mem_fn<_Res _Class::*>
    {


      template<typename _Tp>
 _Res&
 _M_call(_Tp& __object, _Class *) const
 { return __object.*__pm; }

      template<typename _Tp, typename _Up>
 _Res&
 _M_call(_Tp& __object, _Up * const *) const
 { return (*__object).*__pm; }

      template<typename _Tp, typename _Up>
 const _Res&
 _M_call(_Tp& __object, const _Up * const *) const
 { return (*__object).*__pm; }

      template<typename _Tp>
 const _Res&
 _M_call(_Tp& __object, const _Class *) const
 { return __object.*__pm; }

      template<typename _Tp>
 const _Res&
 _M_call(_Tp& __ptr, const volatile void*) const
 { return (*__ptr).*__pm; }

      template<typename _Tp> static _Tp& __get_ref();

      template<typename _Tp>
 static __sfinae_types::__one __check_const(_Tp&, _Class*);
      template<typename _Tp, typename _Up>
 static __sfinae_types::__one __check_const(_Tp&, _Up * const *);
      template<typename _Tp, typename _Up>
 static __sfinae_types::__two __check_const(_Tp&, const _Up * const *);
      template<typename _Tp>
 static __sfinae_types::__two __check_const(_Tp&, const _Class*);
      template<typename _Tp>
 static __sfinae_types::__two __check_const(_Tp&, const volatile void*);

    public:
      template<typename _Tp>
 struct _Result_type
 : _Mem_fn_const_or_non<_Res,
   (sizeof(__sfinae_types::__two)
    == sizeof(__check_const<_Tp>(__get_ref<_Tp>(), (_Tp*)0)))>
 { };

      template<typename _Signature>
 struct result;

      template<typename _CVMem, typename _Tp>
 struct result<_CVMem(_Tp)>
 : public _Result_type<_Tp> { };

      template<typename _CVMem, typename _Tp>
 struct result<_CVMem(_Tp&)>
 : public _Result_type<_Tp> { };

      explicit
      _Mem_fn(_Res _Class::*__pm) : __pm(__pm) { }


      _Res&
      operator()(_Class& __object) const
      { return __object.*__pm; }

      const _Res&
      operator()(const _Class& __object) const
      { return __object.*__pm; }


      _Res&
      operator()(_Class* __object) const
      { return __object->*__pm; }

      const _Res&
      operator()(const _Class* __object) const
      { return __object->*__pm; }


      template<typename _Tp>
 typename _Result_type<_Tp>::type
 operator()(_Tp& __unknown) const
 { return _M_call(__unknown, &__unknown); }

    private:
      _Res _Class::*__pm;
    };






  template<typename _Tp, typename _Class>
    inline _Mem_fn<_Tp _Class::*>
    mem_fn(_Tp _Class::* __pm)
    {
      return _Mem_fn<_Tp _Class::*>(__pm);
    }







  template<typename _Tp>
    struct is_bind_expression
    : public false_type { };






  template<typename _Tp>
    struct is_placeholder
    : public integral_constant<int, 0>
    { };


  template<int _Num> struct _Placeholder { };

 
# 850 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
  namespace placeholders
  {
 
    extern const _Placeholder<1> _1;
    extern const _Placeholder<2> _2;
    extern const _Placeholder<3> _3;
    extern const _Placeholder<4> _4;
    extern const _Placeholder<5> _5;
    extern const _Placeholder<6> _6;
    extern const _Placeholder<7> _7;
    extern const _Placeholder<8> _8;
    extern const _Placeholder<9> _9;
    extern const _Placeholder<10> _10;
    extern const _Placeholder<11> _11;
    extern const _Placeholder<12> _12;
    extern const _Placeholder<13> _13;
    extern const _Placeholder<14> _14;
    extern const _Placeholder<15> _15;
    extern const _Placeholder<16> _16;
    extern const _Placeholder<17> _17;
    extern const _Placeholder<18> _18;
    extern const _Placeholder<19> _19;
    extern const _Placeholder<20> _20;
    extern const _Placeholder<21> _21;
    extern const _Placeholder<22> _22;
    extern const _Placeholder<23> _23;
    extern const _Placeholder<24> _24;
    extern const _Placeholder<25> _25;
    extern const _Placeholder<26> _26;
    extern const _Placeholder<27> _27;
    extern const _Placeholder<28> _28;
    extern const _Placeholder<29> _29;
 
  }

 






  template<int _Num>
    struct is_placeholder<_Placeholder<_Num> >
    : public integral_constant<int, _Num>
    { };





  struct _No_tuple_element;






  template<int __i, typename _Tuple, bool _IsSafe>
    struct _Safe_tuple_element_impl
    : tuple_element<__i, _Tuple> { };






  template<int __i, typename _Tuple>
    struct _Safe_tuple_element_impl<__i, _Tuple, false>
    {
      typedef _No_tuple_element type;
    };





 template<int __i, typename _Tuple>
   struct _Safe_tuple_element
   : _Safe_tuple_element_impl<__i, _Tuple,
         (__i >= 0 && __i < tuple_size<_Tuple>::value)>
   { };
# 944 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
  template<typename _Arg,
    bool _IsBindExp = is_bind_expression<_Arg>::value,
    bool _IsPlaceholder = (is_placeholder<_Arg>::value > 0)>
    class _Mu;





  template<typename _Tp>
    class _Mu<reference_wrapper<_Tp>, false, false>
    {
    public:
      typedef _Tp& result_type;





      template<typename _CVRef, typename _Tuple>
 result_type
 operator()(_CVRef& __arg, _Tuple&) const volatile
 { return __arg.get(); }
    };






  template<typename _Arg>
    class _Mu<_Arg, true, false>
    {
    public:
      template<typename _CVArg, typename... _Args>
 auto
 operator()(_CVArg& __arg,
     tuple<_Args...>& __tuple) const volatile
 -> decltype(__arg(declval<_Args>()...))
 {

   typedef typename _Build_index_tuple<sizeof...(_Args)>::__type
     _Indexes;
   return this->__call(__arg, __tuple, _Indexes());
 }

    private:


      template<typename _CVArg, typename... _Args, int... _Indexes>
 auto
 __call(_CVArg& __arg, tuple<_Args...>& __tuple,
        const _Index_tuple<_Indexes...>&) const volatile
 -> decltype(__arg(declval<_Args>()...))
 {
   return __arg(std::forward<_Args>(get<_Indexes>(__tuple))...);
 }
    };






  template<typename _Arg>
    class _Mu<_Arg, false, true>
    {
    public:
      template<typename _Signature> class result;

      template<typename _CVMu, typename _CVArg, typename _Tuple>
 class result<_CVMu(_CVArg, _Tuple)>
 {



   typedef typename _Safe_tuple_element<(is_placeholder<_Arg>::value
      - 1), _Tuple>::type
     __base_type;

 public:
   typedef typename add_rvalue_reference<__base_type>::type type;
 };

      template<typename _Tuple>
 typename result<_Mu(_Arg, _Tuple)>::type
 operator()(const volatile _Arg&, _Tuple& __tuple) const volatile
 {
   return std::forward<typename result<_Mu(_Arg, _Tuple)>::type>(
       ::std::get<(is_placeholder<_Arg>::value - 1)>(__tuple));
 }
    };






  template<typename _Arg>
    class _Mu<_Arg, false, false>
    {
    public:
      template<typename _Signature> struct result;

      template<typename _CVMu, typename _CVArg, typename _Tuple>
 struct result<_CVMu(_CVArg, _Tuple)>
 {
   typedef typename add_lvalue_reference<_CVArg>::type type;
 };


      template<typename _CVArg, typename _Tuple>
 _CVArg&&
 operator()(_CVArg&& __arg, _Tuple&) const volatile
 { return std::forward<_CVArg>(__arg); }
    };






  template<typename _Tp>
    struct _Maybe_wrap_member_pointer
    {
      typedef _Tp type;

      static const _Tp&
      __do_wrap(const _Tp& __x)
      { return __x; }

      static _Tp&&
      __do_wrap(_Tp&& __x)
      { return static_cast<_Tp&&>(__x); }
    };






  template<typename _Tp, typename _Class>
    struct _Maybe_wrap_member_pointer<_Tp _Class::*>
    {
      typedef _Mem_fn<_Tp _Class::*> type;

      static type
      __do_wrap(_Tp _Class::* __pm)
      { return type(__pm); }
    };





  template<>
    struct _Maybe_wrap_member_pointer<void>
    {
      typedef void type;
    };


  template<size_t _Ind, typename... _Tp>
    inline auto
    __volget(volatile tuple<_Tp...>& __tuple)
    -> typename tuple_element<_Ind, tuple<_Tp...>>::type volatile&
    { return std::get<_Ind>(const_cast<tuple<_Tp...>&>(__tuple)); }


  template<size_t _Ind, typename... _Tp>
    inline auto
    __volget(const volatile tuple<_Tp...>& __tuple)
    -> typename tuple_element<_Ind, tuple<_Tp...>>::type const volatile&
    { return std::get<_Ind>(const_cast<const tuple<_Tp...>&>(__tuple)); }


  template<typename _Signature>
    struct _Bind;

   template<typename _Functor, typename... _Bound_args>
    class _Bind<_Functor(_Bound_args...)>
    : public _Weak_result_type<_Functor>
    {
      typedef _Bind __self_type;
      typedef typename _Build_index_tuple<sizeof...(_Bound_args)>::__type
 _Bound_indexes;

      _Functor _M_f;
      tuple<_Bound_args...> _M_bound_args;


      template<typename _Result, typename... _Args, int... _Indexes>
 _Result
 __call(tuple<_Args...>&& __args, _Index_tuple<_Indexes...>)
 {
   return _M_f(_Mu<_Bound_args>()
        (get<_Indexes>(_M_bound_args), __args)...);
 }


      template<typename _Result, typename... _Args, int... _Indexes>
 _Result
 __call_c(tuple<_Args...>&& __args, _Index_tuple<_Indexes...>) const
 {
   return _M_f(_Mu<_Bound_args>()
        (get<_Indexes>(_M_bound_args), __args)...);
 }


      template<typename _Result, typename... _Args, int... _Indexes>
 _Result
 __call_v(tuple<_Args...>&& __args,
   _Index_tuple<_Indexes...>) volatile
 {
   return _M_f(_Mu<_Bound_args>()
        (__volget<_Indexes>(_M_bound_args), __args)...);
 }


      template<typename _Result, typename... _Args, int... _Indexes>
 _Result
 __call_c_v(tuple<_Args...>&& __args,
     _Index_tuple<_Indexes...>) const volatile
 {
   return _M_f(_Mu<_Bound_args>()
        (__volget<_Indexes>(_M_bound_args), __args)...);
 }

     public:
      template<typename... _Args>
 explicit _Bind(const _Functor& __f, _Args&&... __args)
 : _M_f(__f), _M_bound_args(std::forward<_Args>(__args)...)
 { }

      template<typename... _Args>
 explicit _Bind(_Functor&& __f, _Args&&... __args)
 : _M_f(std::move(__f)), _M_bound_args(std::forward<_Args>(__args)...)
 { }

      _Bind(const _Bind&) = default;

      _Bind(_Bind&& __b)
      : _M_f(std::move(__b._M_f)), _M_bound_args(std::move(__b._M_bound_args))
      { }


      template<typename... _Args, typename _Result
 = decltype( std::declval<_Functor>()(
       _Mu<_Bound_args>()( std::declval<_Bound_args&>(),
      std::declval<tuple<_Args...>&>() )... ) )>
 _Result
 operator()(_Args&&... __args)
 {
   return this->__call<_Result>(
       std::forward_as_tuple(std::forward<_Args>(__args)...),
       _Bound_indexes());
 }


      template<typename... _Args, typename _Result
 = decltype( std::declval<const _Functor>()(
       _Mu<_Bound_args>()( std::declval<const _Bound_args&>(),
      std::declval<tuple<_Args...>&>() )... ) )>
 _Result
 operator()(_Args&&... __args) const
 {
   return this->__call_c<_Result>(
       std::forward_as_tuple(std::forward<_Args>(__args)...),
       _Bound_indexes());
 }


      template<typename... _Args, typename _Result
 = decltype( std::declval<volatile _Functor>()(
       _Mu<_Bound_args>()( std::declval<volatile _Bound_args&>(),
      std::declval<tuple<_Args...>&>() )... ) )>
 _Result
 operator()(_Args&&... __args) volatile
 {
   return this->__call_v<_Result>(
       std::forward_as_tuple(std::forward<_Args>(__args)...),
       _Bound_indexes());
 }


      template<typename... _Args, typename _Result
 = decltype( std::declval<const volatile _Functor>()(
       _Mu<_Bound_args>()( std::declval<const volatile _Bound_args&>(),
      std::declval<tuple<_Args...>&>() )... ) )>
 _Result
 operator()(_Args&&... __args) const volatile
 {
   return this->__call_c_v<_Result>(
       std::forward_as_tuple(std::forward<_Args>(__args)...),
       _Bound_indexes());
 }
    };


  template<typename _Result, typename _Signature>
    struct _Bind_result;

  template<typename _Result, typename _Functor, typename... _Bound_args>
    class _Bind_result<_Result, _Functor(_Bound_args...)>
    {
      typedef _Bind_result __self_type;
      typedef typename _Build_index_tuple<sizeof...(_Bound_args)>::__type
 _Bound_indexes;

      _Functor _M_f;
      tuple<_Bound_args...> _M_bound_args;


      template<typename _Res>
 struct __enable_if_void : enable_if<is_void<_Res>::value, int> { };
      template<typename _Res>
 struct __disable_if_void : enable_if<!is_void<_Res>::value, int> { };


      template<typename _Res, typename... _Args, int... _Indexes>
 _Result
 __call(tuple<_Args...>&& __args, _Index_tuple<_Indexes...>,
     typename __disable_if_void<_Res>::type = 0)
 {
   return _M_f(_Mu<_Bound_args>()
        (get<_Indexes>(_M_bound_args), __args)...);
 }


      template<typename _Res, typename... _Args, int... _Indexes>
 void
 __call(tuple<_Args...>&& __args, _Index_tuple<_Indexes...>,
     typename __enable_if_void<_Res>::type = 0)
 {
   _M_f(_Mu<_Bound_args>()
        (get<_Indexes>(_M_bound_args), __args)...);
 }


      template<typename _Res, typename... _Args, int... _Indexes>
 _Result
 __call(tuple<_Args...>&& __args, _Index_tuple<_Indexes...>,
     typename __disable_if_void<_Res>::type = 0) const
 {
   return _M_f(_Mu<_Bound_args>()
        (get<_Indexes>(_M_bound_args), __args)...);
 }


      template<typename _Res, typename... _Args, int... _Indexes>
 void
 __call(tuple<_Args...>&& __args, _Index_tuple<_Indexes...>,
     typename __enable_if_void<_Res>::type = 0) const
 {
   _M_f(_Mu<_Bound_args>()
        (get<_Indexes>(_M_bound_args), __args)...);
 }


      template<typename _Res, typename... _Args, int... _Indexes>
 _Result
 __call(tuple<_Args...>&& __args, _Index_tuple<_Indexes...>,
     typename __disable_if_void<_Res>::type = 0) volatile
 {
   return _M_f(_Mu<_Bound_args>()
        (__volget<_Indexes>(_M_bound_args), __args)...);
 }


      template<typename _Res, typename... _Args, int... _Indexes>
 void
 __call(tuple<_Args...>&& __args, _Index_tuple<_Indexes...>,
     typename __enable_if_void<_Res>::type = 0) volatile
 {
   _M_f(_Mu<_Bound_args>()
        (__volget<_Indexes>(_M_bound_args), __args)...);
 }


      template<typename _Res, typename... _Args, int... _Indexes>
 _Result
 __call(tuple<_Args...>&& __args, _Index_tuple<_Indexes...>,
     typename __disable_if_void<_Res>::type = 0) const volatile
 {
   return _M_f(_Mu<_Bound_args>()
        (__volget<_Indexes>(_M_bound_args), __args)...);
 }


      template<typename _Res, typename... _Args, int... _Indexes>
 void
 __call(tuple<_Args...>&& __args,
        _Index_tuple<_Indexes...>,
     typename __enable_if_void<_Res>::type = 0) const volatile
 {
   _M_f(_Mu<_Bound_args>()
        (__volget<_Indexes>(_M_bound_args), __args)...);
 }

    public:
      typedef _Result result_type;

      template<typename... _Args>
 explicit _Bind_result(const _Functor& __f, _Args&&... __args)
 : _M_f(__f), _M_bound_args(std::forward<_Args>(__args)...)
 { }

      template<typename... _Args>
 explicit _Bind_result(_Functor&& __f, _Args&&... __args)
 : _M_f(std::move(__f)), _M_bound_args(std::forward<_Args>(__args)...)
 { }

      _Bind_result(const _Bind_result&) = default;

      _Bind_result(_Bind_result&& __b)
      : _M_f(std::move(__b._M_f)), _M_bound_args(std::move(__b._M_bound_args))
      { }


      template<typename... _Args>
 result_type
 operator()(_Args&&... __args)
 {
   return this->__call<_Result>(
       std::forward_as_tuple(std::forward<_Args>(__args)...),
       _Bound_indexes());
 }


      template<typename... _Args>
 result_type
 operator()(_Args&&... __args) const
 {
   return this->__call<_Result>(
       std::forward_as_tuple(std::forward<_Args>(__args)...),
       _Bound_indexes());
 }


      template<typename... _Args>
 result_type
 operator()(_Args&&... __args) volatile
 {
   return this->__call<_Result>(
       std::forward_as_tuple(std::forward<_Args>(__args)...),
       _Bound_indexes());
 }


      template<typename... _Args>
 result_type
 operator()(_Args&&... __args) const volatile
 {
   return this->__call<_Result>(
       std::forward_as_tuple(std::forward<_Args>(__args)...),
       _Bound_indexes());
 }
    };





  template<typename _Signature>
    struct is_bind_expression<_Bind<_Signature> >
    : public true_type { };





  template<typename _Result, typename _Signature>
    struct is_bind_expression<_Bind_result<_Result, _Signature> >
    : public true_type { };

  template<typename _Functor, typename... _ArgTypes>
    struct _Bind_helper
    {
      typedef _Maybe_wrap_member_pointer<typename decay<_Functor>::type>
 __maybe_type;
      typedef typename __maybe_type::type __functor_type;
      typedef _Bind<__functor_type(typename decay<_ArgTypes>::type...)> type;
    };





  template<typename _Functor, typename... _ArgTypes>
    inline
    typename _Bind_helper<_Functor, _ArgTypes...>::type
    bind(_Functor&& __f, _ArgTypes&&... __args)
    {
      typedef _Bind_helper<_Functor, _ArgTypes...> __helper_type;
      typedef typename __helper_type::__maybe_type __maybe_type;
      typedef typename __helper_type::type __result_type;
      return __result_type(__maybe_type::__do_wrap(std::forward<_Functor>(__f)),
      std::forward<_ArgTypes>(__args)...);
    }

  template<typename _Result, typename _Functor, typename... _ArgTypes>
    struct _Bindres_helper
    {
      typedef _Maybe_wrap_member_pointer<typename decay<_Functor>::type>
 __maybe_type;
      typedef typename __maybe_type::type __functor_type;
      typedef _Bind_result<_Result,
      __functor_type(typename decay<_ArgTypes>::type...)>
 type;
    };





  template<typename _Result, typename _Functor, typename... _ArgTypes>
    inline
    typename _Bindres_helper<_Result, _Functor, _ArgTypes...>::type
    bind(_Functor&& __f, _ArgTypes&&... __args)
    {
      typedef _Bindres_helper<_Result, _Functor, _ArgTypes...> __helper_type;
      typedef typename __helper_type::__maybe_type __maybe_type;
      typedef typename __helper_type::type __result_type;
      return __result_type(__maybe_type::__do_wrap(std::forward<_Functor>(__f)),
      std::forward<_ArgTypes>(__args)...);
    }






  class bad_function_call : public std::exception
  {
  public:
    virtual ~bad_function_call() throw();
  };






  template<typename _Tp>
    struct __is_location_invariant
    : integral_constant<bool, (is_pointer<_Tp>::value
          || is_member_pointer<_Tp>::value)>
    { };

  class _Undefined_class;

  union _Nocopy_types
  {
    void* _M_object;
    const void* _M_const_object;
    void (*_M_function_pointer)();
    void (_Undefined_class::*_M_member_pointer)();
  };

  union _Any_data
  {
    void* _M_access() { return &_M_pod_data[0]; }
    const void* _M_access() const { return &_M_pod_data[0]; }

    template<typename _Tp>
      _Tp&
      _M_access()
      { return *static_cast<_Tp*>(_M_access()); }

    template<typename _Tp>
      const _Tp&
      _M_access() const
      { return *static_cast<const _Tp*>(_M_access()); }

    _Nocopy_types _M_unused;
    char _M_pod_data[sizeof(_Nocopy_types)];
  };

  enum _Manager_operation
  {
    __get_type_info,
    __get_functor_ptr,
    __clone_functor,
    __destroy_functor
  };



  template<typename _Tp>
    struct _Simple_type_wrapper
    {
      _Simple_type_wrapper(_Tp __value) : __value(__value) { }

      _Tp __value;
    };

  template<typename _Tp>
    struct __is_location_invariant<_Simple_type_wrapper<_Tp> >
    : __is_location_invariant<_Tp>
    { };



  template<typename _Functor>
    inline _Functor&
    __callable_functor(_Functor& __f)
    { return __f; }

  template<typename _Member, typename _Class>
    inline _Mem_fn<_Member _Class::*>
    __callable_functor(_Member _Class::* &__p)
    { return mem_fn(__p); }

  template<typename _Member, typename _Class>
    inline _Mem_fn<_Member _Class::*>
    __callable_functor(_Member _Class::* const &__p)
    { return mem_fn(__p); }

  template<typename _Signature>
    class function;


  class _Function_base
  {
  public:
    static const std::size_t _M_max_size = sizeof(_Nocopy_types);
    static const std::size_t _M_max_align = __alignof__(_Nocopy_types);

    template<typename _Functor>
      class _Base_manager
      {
      protected:
 static const bool __stored_locally =
 (__is_location_invariant<_Functor>::value
  && sizeof(_Functor) <= _M_max_size
  && __alignof__(_Functor) <= _M_max_align
  && (_M_max_align % __alignof__(_Functor) == 0));

 typedef integral_constant<bool, __stored_locally> _Local_storage;


 static _Functor*
 _M_get_pointer(const _Any_data& __source)
 {
   const _Functor* __ptr =
     __stored_locally? &__source._M_access<_Functor>()
                                 : __source._M_access<_Functor*>();
   return const_cast<_Functor*>(__ptr);
 }



 static void
 _M_clone(_Any_data& __dest, const _Any_data& __source, true_type)
 {
   new (__dest._M_access()) _Functor(__source._M_access<_Functor>());
 }



 static void
 _M_clone(_Any_data& __dest, const _Any_data& __source, false_type)
 {
   __dest._M_access<_Functor*>() =
     new _Functor(*__source._M_access<_Functor*>());
 }



 static void
 _M_destroy(_Any_data& __victim, true_type)
 {
   __victim._M_access<_Functor>().~_Functor();
 }


 static void
 _M_destroy(_Any_data& __victim, false_type)
 {
   delete __victim._M_access<_Functor*>();
 }

      public:
 static bool
 _M_manager(_Any_data& __dest, const _Any_data& __source,
     _Manager_operation __op)
 {
   switch (__op)
     {

     case __get_type_info:
       __dest._M_access<const type_info*>() = &typeid(_Functor);
       break;

     case __get_functor_ptr:
       __dest._M_access<_Functor*>() = _M_get_pointer(__source);
       break;

     case __clone_functor:
       _M_clone(__dest, __source, _Local_storage());
       break;

     case __destroy_functor:
       _M_destroy(__dest, _Local_storage());
       break;
     }
   return false;
 }

 static void
 _M_init_functor(_Any_data& __functor, _Functor&& __f)
 { _M_init_functor(__functor, std::move(__f), _Local_storage()); }

 template<typename _Signature>
   static bool
   _M_not_empty_function(const function<_Signature>& __f)
   { return static_cast<bool>(__f); }

 template<typename _Tp>
   static bool
   _M_not_empty_function(const _Tp*& __fp)
   { return __fp; }

 template<typename _Class, typename _Tp>
   static bool
   _M_not_empty_function(_Tp _Class::* const& __mp)
   { return __mp; }

 template<typename _Tp>
   static bool
   _M_not_empty_function(const _Tp&)
   { return true; }

      private:
 static void
 _M_init_functor(_Any_data& __functor, _Functor&& __f, true_type)
 { new (__functor._M_access()) _Functor(std::move(__f)); }

 static void
 _M_init_functor(_Any_data& __functor, _Functor&& __f, false_type)
 { __functor._M_access<_Functor*>() = new _Functor(std::move(__f)); }
      };

    template<typename _Functor>
      class _Ref_manager : public _Base_manager<_Functor*>
      {
 typedef _Function_base::_Base_manager<_Functor*> _Base;

    public:
 static bool
 _M_manager(_Any_data& __dest, const _Any_data& __source,
     _Manager_operation __op)
 {
   switch (__op)
     {

     case __get_type_info:
       __dest._M_access<const type_info*>() = &typeid(_Functor);
       break;

     case __get_functor_ptr:
       __dest._M_access<_Functor*>() = *_Base::_M_get_pointer(__source);
       return is_const<_Functor>::value;
       break;

     default:
       _Base::_M_manager(__dest, __source, __op);
     }
   return false;
 }

 static void
 _M_init_functor(_Any_data& __functor, reference_wrapper<_Functor> __f)
 {

   _Base::_M_init_functor(__functor, &__f.get());
 }
      };

    _Function_base() : _M_manager(0) { }

    ~_Function_base()
    {
      if (_M_manager)
 _M_manager(_M_functor, _M_functor, __destroy_functor);
    }


    bool _M_empty() const { return !_M_manager; }

    typedef bool (*_Manager_type)(_Any_data&, const _Any_data&,
      _Manager_operation);

    _Any_data _M_functor;
    _Manager_type _M_manager;
  };

  template<typename _Signature, typename _Functor>
    class _Function_handler;

  template<typename _Res, typename _Functor, typename... _ArgTypes>
    class _Function_handler<_Res(_ArgTypes...), _Functor>
    : public _Function_base::_Base_manager<_Functor>
    {
      typedef _Function_base::_Base_manager<_Functor> _Base;

    public:
      static _Res
      _M_invoke(const _Any_data& __functor, _ArgTypes... __args)
      {
 return (*_Base::_M_get_pointer(__functor))(
     std::forward<_ArgTypes>(__args)...);
      }
    };

  template<typename _Functor, typename... _ArgTypes>
    class _Function_handler<void(_ArgTypes...), _Functor>
    : public _Function_base::_Base_manager<_Functor>
    {
      typedef _Function_base::_Base_manager<_Functor> _Base;

     public:
      static void
      _M_invoke(const _Any_data& __functor, _ArgTypes... __args)
      {
 (*_Base::_M_get_pointer(__functor))(
     std::forward<_ArgTypes>(__args)...);
      }
    };

  template<typename _Res, typename _Functor, typename... _ArgTypes>
    class _Function_handler<_Res(_ArgTypes...), reference_wrapper<_Functor> >
    : public _Function_base::_Ref_manager<_Functor>
    {
      typedef _Function_base::_Ref_manager<_Functor> _Base;

     public:
      static _Res
      _M_invoke(const _Any_data& __functor, _ArgTypes... __args)
      {
 return __callable_functor(**_Base::_M_get_pointer(__functor))(
       std::forward<_ArgTypes>(__args)...);
      }
    };

  template<typename _Functor, typename... _ArgTypes>
    class _Function_handler<void(_ArgTypes...), reference_wrapper<_Functor> >
    : public _Function_base::_Ref_manager<_Functor>
    {
      typedef _Function_base::_Ref_manager<_Functor> _Base;

     public:
      static void
      _M_invoke(const _Any_data& __functor, _ArgTypes... __args)
      {
 __callable_functor(**_Base::_M_get_pointer(__functor))(
     std::forward<_ArgTypes>(__args)...);
      }
    };

  template<typename _Class, typename _Member, typename _Res,
    typename... _ArgTypes>
    class _Function_handler<_Res(_ArgTypes...), _Member _Class::*>
    : public _Function_handler<void(_ArgTypes...), _Member _Class::*>
    {
      typedef _Function_handler<void(_ArgTypes...), _Member _Class::*>
 _Base;

     public:
      static _Res
      _M_invoke(const _Any_data& __functor, _ArgTypes... __args)
      {
 return mem_fn(_Base::_M_get_pointer(__functor)->__value)(
     std::forward<_ArgTypes>(__args)...);
      }
    };

  template<typename _Class, typename _Member, typename... _ArgTypes>
    class _Function_handler<void(_ArgTypes...), _Member _Class::*>
    : public _Function_base::_Base_manager<
   _Simple_type_wrapper< _Member _Class::* > >
    {
      typedef _Member _Class::* _Functor;
      typedef _Simple_type_wrapper<_Functor> _Wrapper;
      typedef _Function_base::_Base_manager<_Wrapper> _Base;

     public:
      static bool
      _M_manager(_Any_data& __dest, const _Any_data& __source,
   _Manager_operation __op)
      {
 switch (__op)
   {

   case __get_type_info:
     __dest._M_access<const type_info*>() = &typeid(_Functor);
     break;

   case __get_functor_ptr:
     __dest._M_access<_Functor*>() =
       &_Base::_M_get_pointer(__source)->__value;
     break;

   default:
     _Base::_M_manager(__dest, __source, __op);
   }
 return false;
      }

      static void
      _M_invoke(const _Any_data& __functor, _ArgTypes... __args)
      {
 mem_fn(_Base::_M_get_pointer(__functor)->__value)(
     std::forward<_ArgTypes>(__args)...);
      }
    };







  template<typename _Res, typename... _ArgTypes>
    class function<_Res(_ArgTypes...)>
    : public _Maybe_unary_or_binary_function<_Res, _ArgTypes...>,
      private _Function_base
    {
      typedef _Res _Signature_type(_ArgTypes...);

      struct _Useless { };

    public:
      typedef _Res result_type;







      function() : _Function_base() { }





      function(nullptr_t) : _Function_base() { }
# 1901 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      function(const function& __x);
# 1910 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      function(function&& __x) : _Function_base()
      {
 __x.swap(*this);
      }
# 1933 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      template<typename _Functor>
 function(_Functor __f,
   typename enable_if<
      !is_integral<_Functor>::value, _Useless>::type
     = _Useless());
# 1951 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      function&
      operator=(const function& __x)
      {
 function(__x).swap(*this);
 return *this;
      }
# 1969 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      function&
      operator=(function&& __x)
      {
 function(std::move(__x)).swap(*this);
 return *this;
      }
# 1983 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      function&
      operator=(nullptr_t)
      {
 if (_M_manager)
   {
     _M_manager(_M_functor, _M_functor, __destroy_functor);
     _M_manager = 0;
     _M_invoker = 0;
   }
 return *this;
      }
# 2011 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      template<typename _Functor>
 typename enable_if<!is_integral<_Functor>::value, function&>::type
 operator=(_Functor&& __f)
 {
   function(std::forward<_Functor>(__f)).swap(*this);
   return *this;
 }


      template<typename _Functor>
 typename enable_if<!is_integral<_Functor>::value, function&>::type
 operator=(reference_wrapper<_Functor> __f)
 {
   function(__f).swap(*this);
   return *this;
 }
# 2037 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      void swap(function& __x)
      {
 std::swap(_M_functor, __x._M_functor);
 std::swap(_M_manager, __x._M_manager);
 std::swap(_M_invoker, __x._M_invoker);
      }
# 2065 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      explicit operator bool() const
      { return !_M_empty(); }
# 2078 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      _Res operator()(_ArgTypes... __args) const;
# 2091 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      const type_info& target_type() const;
# 2102 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
      template<typename _Functor> _Functor* target();


      template<typename _Functor> const _Functor* target() const;


    private:
      typedef _Res (*_Invoker_type)(const _Any_data&, _ArgTypes...);
      _Invoker_type _M_invoker;
  };


  template<typename _Res, typename... _ArgTypes>
    function<_Res(_ArgTypes...)>::
    function(const function& __x)
    : _Function_base()
    {
      if (static_cast<bool>(__x))
 {
   _M_invoker = __x._M_invoker;
   _M_manager = __x._M_manager;
   __x._M_manager(_M_functor, __x._M_functor, __clone_functor);
 }
    }

  template<typename _Res, typename... _ArgTypes>
    template<typename _Functor>
      function<_Res(_ArgTypes...)>::
      function(_Functor __f,
        typename enable_if<
   !is_integral<_Functor>::value, _Useless>::type)
      : _Function_base()
      {
 typedef _Function_handler<_Signature_type, _Functor> _My_handler;

 if (_My_handler::_M_not_empty_function(__f))
   {
     _M_invoker = &_My_handler::_M_invoke;
     _M_manager = &_My_handler::_M_manager;
     _My_handler::_M_init_functor(_M_functor, std::move(__f));
   }
      }

  template<typename _Res, typename... _ArgTypes>
    _Res
    function<_Res(_ArgTypes...)>::
    operator()(_ArgTypes... __args) const
    {
      if (_M_empty())
 __throw_bad_function_call();
      return _M_invoker(_M_functor, std::forward<_ArgTypes>(__args)...);
    }


  template<typename _Res, typename... _ArgTypes>
    const type_info&
    function<_Res(_ArgTypes...)>::
    target_type() const
    {
      if (_M_manager)
 {
   _Any_data __typeinfo_result;
   _M_manager(__typeinfo_result, _M_functor, __get_type_info);
   return *__typeinfo_result._M_access<const type_info*>();
 }
      else
 return typeid(void);
    }

  template<typename _Res, typename... _ArgTypes>
    template<typename _Functor>
      _Functor*
      function<_Res(_ArgTypes...)>::
      target()
      {
 if (typeid(_Functor) == target_type() && _M_manager)
   {
     _Any_data __ptr;
     if (_M_manager(__ptr, _M_functor, __get_functor_ptr)
  && !is_const<_Functor>::value)
       return 0;
     else
       return __ptr._M_access<_Functor*>();
   }
 else
   return 0;
      }

  template<typename _Res, typename... _ArgTypes>
    template<typename _Functor>
      const _Functor*
      function<_Res(_ArgTypes...)>::
      target() const
      {
 if (typeid(_Functor) == target_type() && _M_manager)
   {
     _Any_data __ptr;
     _M_manager(__ptr, _M_functor, __get_functor_ptr);
     return __ptr._M_access<const _Functor*>();
   }
 else
   return 0;
      }
# 2216 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
  template<typename _Res, typename... _Args>
    inline bool
    operator==(const function<_Res(_Args...)>& __f, nullptr_t)
    { return !static_cast<bool>(__f); }


  template<typename _Res, typename... _Args>
    inline bool
    operator==(nullptr_t, const function<_Res(_Args...)>& __f)
    { return !static_cast<bool>(__f); }
# 2234 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
  template<typename _Res, typename... _Args>
    inline bool
    operator!=(const function<_Res(_Args...)>& __f, nullptr_t)
    { return static_cast<bool>(__f); }


  template<typename _Res, typename... _Args>
    inline bool
    operator!=(nullptr_t, const function<_Res(_Args...)>& __f)
    { return static_cast<bool>(__f); }
# 2252 "/opt/lib/gcc/x86_64-apple-darwin10.7.0/4.6.0/../../../../include/c++/4.6.0/functional" 3
  template<typename _Res, typename... _Args>
    inline void
    swap(function<_Res(_Args...)>& __x, function<_Res(_Args...)>& __y)
    { __x.swap(__y); }


}
# 15 "DFSController.H" 2

class DFSController : public CPController {
   std::vector<NSCont*> _tab;
   NSCont* _start;
   NSCont* _exit;
 public:
   DFSController();
   void addChoice(NSCont* k);
   void fail();
   void searchWithRestart(NSCont* k,NSCont* ex);
};

void tryb(CPController& ctrl,std::tr1::function<void(void)> left,std::tr1::function<void(void)> right);
# 10 "DFSController.C" 2

DFSController::DFSController()
{
   _start = _exit = 0;
}

void DFSController::addChoice(NSCont* k)
{
   _tab.push_back(k);
}
void DFSController::fail()
{
   long ofs = _tab.size()-1;
   if (ofs >= 0) {
      NSCont* k = _tab[ofs];
      _tab[ofs] = 0;
      if (k!=__null) {
         k->call();
      }
      else
         _exit->call();
   } else
      _exit->call();
}
void DFSController::searchWithRestart(NSCont* k,NSCont* ex)
{
   _start = k;
   _exit = ex;
}

void try(CPController& ctrl,auto left,auto right)
{
   bool goLeft=false;
   NSCont* k = NSCont::takeContinuation();
   if (k->nbCalls() == 0)
      goLeft = true;
   if (goLeft) {
      ctrl->addChoice(k);
      left();
   } else {
      NSCont::releaseContinuation(k);
      right();
   }
}

void solveall(CPController& ctrl,auto start,auto exit)
{
   NSCont* k = NSCont::takeContinuation();
   if (k->nbCalls()==0) {
      NSCont* x = NSCont::takeContinuation();
      if (x->nbCalls()==0) {
         ctrl->searchWithRestart(k,x);
         start();
         ctrl->fail();
      } else {
         exit();
      }
   } else {
      start();
   }
}
