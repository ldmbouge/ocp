
/************************************************/
/* fpi.h :                                      */
/*   projection functions for                   */
/*   floating point constraints                 */
/*                                              */
/* copyright Claude Michel                      */
/* Improvements: Laurent Michel  ;-)            */
/************************************************/


/* Minimum and maximum values a `signed long long int' can hold.  */
#ifndef LLONG_MAX
#   define LLONG_MAX    9223372036854775807LL
#endif
#ifndef LLONG_MIN
#   define LLONG_MIN    (-LLONG_MAX - 1LL)
#endif

/* Maximum value an `unsigned long long int' can hold.  (Minimum is 0.)  */
#ifndef ULLONG_MAX
#   define ULLONG_MAX   18446744073709551615ULL
#endif

typedef union {
   short short_nb;
   int int_nb;
   long long llong_nb;
   unsigned short ushort_nb;
   unsigned int uint_nb;
   unsigned long long ullong_nb;
   float float_nb;
   double double_nb;
   long double ldouble_nb;
} fp_number;

typedef long double internal_float;
typedef long double internal_double;

typedef struct {
   float inf;
   float sup;
} float_interval;

typedef struct {
   internal_float inf;
   internal_float sup;
} internal_float_interval;

typedef struct {
   double inf;
   double sup;
} double_interval;

typedef struct {
   internal_double inf;
   internal_double sup;
} internal_double_interval;

typedef struct {
   long double inf;
   long double sup;
} ldouble_interval;

typedef struct {
   short inf;
   short sup;
} short_interval;

typedef struct {
   unsigned short inf;
   unsigned short sup;
} ushort_interval;

typedef struct {
   int inf;
   int sup;
} int_interval;

typedef struct {
   unsigned int inf;
   unsigned int sup;
} uint_interval;

typedef struct {
   long long inf;
   long long sup;
} llong_interval;

typedef struct {
   unsigned long long inf;
   unsigned long long sup;
} ullong_interval;

#ifdef __APPLE__
#define isinff(x) isinf(x)
#define isinfl(x) isinf(x)
#endif

#ifdef _NO_FPI_
#pragma GCC visibility push(hidden)
#endif

extern void fp_set_precision_and_rounding(int precision, int rounding_mode);

extern float fp_next_float(float x);
extern double fp_next_double(double x);
extern long double fp_next_ldouble(long double x);

extern float fp_nextn_float(float x, unsigned int n);
extern double fp_nextn_double(double x, unsigned int n);
extern long double fp_nextn_ldouble(long double x, unsigned int n);

extern float fp_previous_float(float x);
extern double fp_previous_double(double x);
extern long double fp_previous_ldouble(long double x);

extern float fp_previousn_float(float x, unsigned int n);
extern double fp_previousn_double(double x, unsigned int n);
extern long double fp_previousn_ldouble(long double x, unsigned int n);

extern float fp_nextafterf(float x, float direction);
extern double fp_nextafter(double x, double direction);
extern long double fp_nextafterl(long double x, long double direction);

extern float infinityf(void);
extern double infinity(void);
extern long double infinityl(void);

extern float maxnormalf(void);
extern double maxnormal(void);
extern long double maxnormall(void);

extern float minnormalf(void);
extern double minnormal(void);
extern long double minnormall(void);

extern float maxdenormalf(void);
extern double maxdenormal(void);
extern long double maxdenormall(void);

extern float mindenormalf(void);
extern double mindenormal(void);
extern long double mindenormall(void);

extern int is_infinityf(float v);
extern int is_infinity(double v);
extern int is_infinityl(long double v);

extern int is_signedf(float v);
extern int is_signed(double v);
extern int is_signedl(long double v);

extern int is_odd_floatf(float v);
extern int is_odd_float(double v);
extern int is_odd_floatl(long double v);

extern int is_plus_zerof(float v);
extern int is_plus_zero(double v);
extern int is_plus_zerol(long double v);

extern int is_minus_zerof(float v);
extern int is_minus_zero(double v);
extern int is_minus_zerol(long double v);

extern int is_eqf(float v1, float v2);
extern int is_eq(double v1, double v2);
extern int is_eql(long double v1, long double v2);

extern int is_negativef(float v);
extern int is_negative(double v);
extern int is_negativel(long double v);

extern int is_positivef(float v);
extern int is_positive(double v);
extern int is_positivel(long double v);


extern int is_nanf(float value);
extern int is_nan(double value);
extern int is_nanl(long double value);

extern void fpi_sets(int fpu_precision, int fpu_rounding, short_interval *result, short_interval *value);
extern void fpi_seti(int fpu_precision, int fpu_rounding, int_interval *result, int_interval *value);
extern void fpi_setll(int fpu_precision, int fpu_rounding, llong_interval *result, llong_interval *value);
extern void fpi_setus(int fpu_precision, int fpu_rounding, ushort_interval *result, ushort_interval *value);
extern void fpi_setui(int fpu_precision, int fpu_rounding, uint_interval *result, uint_interval *value);
extern void fpi_setull(int fpu_precision, int fpu_rounding, ullong_interval *result, ullong_interval *value);
extern void fpi_setf(int fpu_precision, int fpu_rounding, float_interval *result, float_interval *value);
extern void fpi_set(int fpu_precision, int fpu_rounding, double_interval *result, double_interval *value);
extern void fpi_setl(int fpu_precision, int fpu_rounding, ldouble_interval *result, ldouble_interval *value);

extern int nb_ulpf(float v1, float v2);
extern int nb_ulp(double v1, double v2);
extern int nb_ulpl(long double v1, long double v2);

extern float fp_fp_ulpf(float x);
extern double fp_fp_ulp(double x);
extern long double fp_fp_ulpl(long double x);

extern unsigned long long fpi_GetCosStartPeriod(long double *x_base_inf, long double *x_base_sup, long double x);
extern unsigned long long fpi_GetTanStartPeriod(long double *x_base_inf, long double *x_base_sup, long double x);


#define _FPU_PC_FIELD   0x0300
#define _FPU_RC_FIELD   0x0C00
#define _FPU_RPC_FIELD  0x0F00

#define FE_SINGLE  0x0000
#define FE_FLOAT   0x0000
#define FE_DOUBLE  0x0200
#define FE_LDOUBLE 0x0300

#ifdef __NOSYNC_WITH_FPU_INTERRUPTS
#define __get_fpu_cw(cw)  __asm__("fstcw %0" : "=m" (*&cw))
#else
#define __get_fpu_cw(cw)  __asm__("fnstcw %0" : "=m" (*&cw))
#endif

#define FE_PC_ANY   0x1000
#define FE_RD_ANY   0x2000

extern void fpu_insure_precision_and_rounding(unsigned int precision_rounding);
extern void fpu_insure_precision(unsigned int precision);
extern void fpu_insure_rounding(unsigned int rounding);

extern long double fpu_inf_predecessorl(int precision, long double x_in);
extern long double fpu_sup_successorl(int precision, long double x_in);
extern long double fpu_coerce_infl(int precision, long double x_in);
extern long double fpu_coerce_supl(int precision, long double x_in);
extern int fpu_lsbl(int precision, long double x);
extern long double fpu_mid_predecessorl(int precision, long double x_in);
extern long double fpu_mid_successorl(int precision, long double x_in);

extern double fpu_get_pred_midf(float x);
extern long double fpu_get_pred_mid(double x);
extern double fpu_get_next_midf(float x);
extern long double fpu_get_next_mid(double x);
extern int fpu_lsbf(float x);
extern int fpu_lsb(double x);

extern char *fpu_round_to_string(int fpu_rounding);
extern char *fpu_precision_to_string(int fpu_precision);

extern float fpi_halfpif_inf, fpi_halfpif_sup, fpi_pif_inf, fpi_pif_sup, 
  fpi_threequaterpif_inf, fpi_threequaterpif_sup, fpi_twopif_inf, fpi_twopif_sup;

extern double fpi_halfpid_inf, fpi_halfpid_sup, fpi_pid_inf, fpi_pid_sup, 
  fpi_threequaterpid_inf, fpi_threequaterpid_sup, fpi_twopid_inf, fpi_twopid_sup;

extern long double fpi_halfpil_inf, fpi_halfpil_sup, fpi_pil_inf, fpi_pil_sup, 
  fpi_threequaterpil_inf, fpi_threequaterpil_sup, fpi_twopil_inf, fpi_twopil_sup;

extern unsigned long long fpi_ScaleTo2Pi(long double *x_base_inf, long double *x_base_sup, long double x);
extern unsigned long long fpi_GetTanStartPeriod(long double *x_base_inf, long double *x_base_sup, long double x);

extern void fpi_narrows(short_interval *Result, short_interval *new_X, int *change);
extern void fpi_narrowi(int_interval *Result, int_interval *new_X, int *change);
extern void fpi_narrowll(llong_interval *Result, llong_interval *new_X, int *change);
extern void fpi_narrowus(ushort_interval *Result, ushort_interval *new_X, int *change);
extern void fpi_narrowui(uint_interval *Result, uint_interval *new_X, int *change);
extern void fpi_narrowull(ullong_interval *Result, ullong_interval *new_X, int *change);

extern void fpi_narrowpercents(short_interval *Result, short_interval *new_X, int *change, double percent, double *reduced_percent);
extern void fpi_narrowpercenti(int_interval *Result, int_interval *new_X, int *change, double percent, double *reduced_percent);
extern void fpi_narrowpercentll(llong_interval *Result, llong_interval *new_X, int *change, double percent, double *reduced_percent);
extern void fpi_narrowpercentus(ushort_interval *Result, ushort_interval *new_X, int *change, double percent, double *reduced_percent);
extern void fpi_narrowpercentui(uint_interval *Result, uint_interval *new_X, int *change, double percent, double *reduced_percent);
extern void fpi_narrowpercentull(ullong_interval *Result, ullong_interval *new_X, int *change, double percent, double *reduced_percent);

/* Functions to compute alpha and zref */
extern float fpi_alphaf(float zinf, float zsup, float *zref);
extern double fpi_alpha(double zinf, double zsup, double *zref);
extern long double fpi_alphal(long double zinf, long double zsup, long double *zref);

/* Constraints based on substraction property */
extern void fpi_sub_invsub_boundsf(int fpu_precision, int fpu_rounding, float_interval *ResultX, float_interval *ResultY, float_interval *Z);
extern void fpi_sub_invsub_bounds(int fpu_precision, int fpu_rounding, double_interval *ResultX, double_interval *ResultY, double_interval *Z);
extern void fpi_sub_invsub_boundsl(int fpu_precision, int fpu_rounding, ldouble_interval *ResultX, ldouble_interval *ResultY, ldouble_interval *Z);
extern void fpi_add_invsub_boundsf(int fpu_precision, int fpu_rounding, float_interval *ResultX, float_interval *ResultY, float_interval *Z);
extern void fpi_add_invsub_bounds(int fpu_precision, int fpu_rounding, double_interval *ResultX, double_interval *ResultY, double_interval *Z);
extern void fpi_add_invsub_boundsl(int fpu_precision, int fpu_rounding, ldouble_interval *ResultX, ldouble_interval *ResultY, ldouble_interval *Z);

/* Temporary workaround */
extern void fpi_sub_invsub_bounds_invxf(int fpu_precision, int fpu_rounding, float_interval *ResultX, float_interval *Z);
extern void fpi_sub_invsub_bounds_invyf(int fpu_precision, int fpu_rounding, float_interval *ResultY, float_interval *Z);
extern void fpi_add_invsub_bounds_invxf(int fpu_precision, int fpu_rounding, float_interval *ResultX, float_interval *Z);
extern void fpi_sub_invsub_bounds_invx(int fpu_precision, int fpu_rounding, double_interval *ResultX, double_interval *Z);
extern void fpi_sub_invsub_bounds_invy(int fpu_precision, int fpu_rounding, double_interval *ResultY, double_interval *Z);
extern void fpi_add_invsub_bounds_invx(int fpu_precision, int fpu_rounding, double_interval *ResultX, double_interval *Z);
extern void fpi_sub_invsub_bounds_invxl(int fpu_precision, int fpu_rounding, ldouble_interval *ResultX, ldouble_interval *Z);
extern void fpi_sub_invsub_bounds_invyl(int fpu_precision, int fpu_rounding, ldouble_interval *ResultY, ldouble_interval *Z);
extern void fpi_add_invsub_bounds_invxl(int fpu_precision, int fpu_rounding, ldouble_interval *ResultX, ldouble_interval *Z);

/* SSE operations */
extern float fpi_addf_sse(float x, float y);
extern float fpi_subf_sse(float x, float y);
extern float fpi_multf_sse(float x, float y);
extern float fpi_divf_sse(float x, float y);
extern float fpi_sqrtf_sse(float x);

extern double fpi_add_sse(double x, double y);
extern double fpi_sub_sse(double x, double y);
extern double fpi_mult_sse(double x, double y);
extern double fpi_div_sse(double x, double y);
extern double fpi_sqrt_sse(double x);

/* FP numbers to integer conversions (subject to rounding mode) (use SSE) */

extern short fpi_float_to_short_sse(float x);
extern unsigned short fpi_float_to_ushort_sse(float x); 
extern short fpi_double_to_short_sse(double x);
extern unsigned short fpi_double_to_ushort_sse(double x); 
extern short fpi_ldouble_to_short_sse(long double x);
extern unsigned short fpi_ldouble_to_ushort_sse(long double x);
extern int fpi_float_to_int_sse(float x);
extern unsigned int fpi_float_to_uint_sse(float x);
extern int fpi_double_to_int_sse(double x);
extern unsigned int fpi_double_to_uint_sse(double x);
extern int fpi_ldouble_to_int_sse(long double x);
extern unsigned int fpi_ldouble_to_uint_sse(long double x);
extern long long int fpi_float_to_llong_sse(float x);
extern unsigned long long int fpi_float_to_ullong_sse(float x);
extern long long int fpi_double_to_llong_sse(double x);
extern unsigned long long int fpi_double_to_ullong_sse(double x);
extern long long int fpi_ldouble_to_llong_sse(long double x);
extern unsigned long long int fpi_ldouble_to_ullong_sse(long double x);




 


 
extern void fpi_narrowf(float_interval *Result, float_interval *new_X, int *change);
extern void fpi_narrowd(double_interval *Result, double_interval *new_X, int *change);
extern void fpi_narrowl(ldouble_interval *Result, ldouble_interval *new_X, int *change);

 
extern void fpi_narrowpercentf(float_interval *Result, float_interval *new_X, int *change, double percent, double *reduced_percent);
extern void fpi_narrowpercentd(double_interval *Result, double_interval *new_X, int *change, double percent, double *reduced_percent);
extern void fpi_narrowpercentl(ldouble_interval *Result, ldouble_interval *new_X, int *change, double percent, double *reduced_percent);


 
extern void fpi_equalf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_equald(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_equall(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);

 
extern void fpi_lessthanf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_lessthand(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_lessthanl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);

 
extern void fpi_lessthan_invf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_lessthan_invd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_lessthan_invl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);

 
extern void fpi_morethanf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_morethand(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_morethanl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);

 
extern void fpi_morethan_invf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_morethan_invd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_morethan_invl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);

 
extern void fpi_lesseqf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_lesseqd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_lesseql(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);

 
extern void fpi_lesseq_invf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_lesseq_invd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_lesseq_invl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);

 
extern void fpi_moreeqf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_moreeqd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_moreeql(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);

 
extern void fpi_moreeq_invf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_moreeq_invd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_moreeq_invl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);

 
extern void fpi_noteqf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X, float_interval *Y);
extern void fpi_noteqd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X, double_interval *Y);
extern void fpi_noteql(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X, ldouble_interval *Y);

 
extern void fpi_fabsf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_fabsd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_fabsl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);

 
extern void fpi_fabs_invf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_fabs_invd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_fabs_invl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);

 
extern void fpi_minusf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_minusd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_minusl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);




 


    
extern void fpi_ftod(int fpu_precision, int fpu_rounding, double_interval *Result, float_interval *X);
extern void fpi_ftod_inv(int fpu_precision, int fpu_rounding, float_interval *Result, double_interval *Y);  
extern void fpi_ftol(int fpu_precision, int fpu_rounding, ldouble_interval *Result, float_interval *X);
extern void fpi_ftol_inv(int fpu_precision, int fpu_rounding, float_interval *Result, ldouble_interval *Y);    
extern void fpi_dtof(int fpu_precision, int fpu_rounding, float_interval *Result, double_interval *X);
extern void fpi_dtof_inv(int fpu_precision, int fpu_rounding, double_interval *Result, float_interval *Y);    
extern void fpi_dtol(int fpu_precision, int fpu_rounding, ldouble_interval *Result, double_interval *X);
extern void fpi_dtol_inv(int fpu_precision, int fpu_rounding, double_interval *Result, ldouble_interval *Y);    
extern void fpi_ltof(int fpu_precision, int fpu_rounding, float_interval *Result, ldouble_interval *X);
extern void fpi_ltof_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, float_interval *Y);  
extern void fpi_ltod(int fpu_precision, int fpu_rounding, double_interval *Result, ldouble_interval *X);
extern void fpi_ltod_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, double_interval *Y);    



 





extern void fpi_float_to_short(int fpu_precision, int fpu_rounding, short_interval *Result, float_interval *X);

extern void fpi_float_to_short_inv(int fpu_precision, int fpu_rounding, float_interval *Result, short_interval *Y);

extern void fpi_short_to_float(int fpu_precision, int fpu_rounding, float_interval *Result, short_interval *X);

extern void fpi_short_to_float_inv(int fpu_precision, int fpu_rounding, short_interval *Result, float_interval *Y);
 



extern void fpi_double_to_short(int fpu_precision, int fpu_rounding, short_interval *Result, double_interval *X);

extern void fpi_double_to_short_inv(int fpu_precision, int fpu_rounding, double_interval *Result, short_interval *Y);

extern void fpi_short_to_double(int fpu_precision, int fpu_rounding, double_interval *Result, short_interval *X);

extern void fpi_short_to_double_inv(int fpu_precision, int fpu_rounding, short_interval *Result, double_interval *Y);
 



extern void fpi_ldouble_to_short(int fpu_precision, int fpu_rounding, short_interval *Result, ldouble_interval *X);

extern void fpi_ldouble_to_short_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, short_interval *Y);

extern void fpi_short_to_ldouble(int fpu_precision, int fpu_rounding, ldouble_interval *Result, short_interval *X);

extern void fpi_short_to_ldouble_inv(int fpu_precision, int fpu_rounding, short_interval *Result, ldouble_interval *Y);
 



extern void fpi_float_to_int(int fpu_precision, int fpu_rounding, int_interval *Result, float_interval *X);

extern void fpi_float_to_int_inv(int fpu_precision, int fpu_rounding, float_interval *Result, int_interval *Y);

extern void fpi_int_to_float(int fpu_precision, int fpu_rounding, float_interval *Result, int_interval *X);

extern void fpi_int_to_float_inv(int fpu_precision, int fpu_rounding, int_interval *Result, float_interval *Y);
 



extern void fpi_double_to_int(int fpu_precision, int fpu_rounding, int_interval *Result, double_interval *X);

extern void fpi_double_to_int_inv(int fpu_precision, int fpu_rounding, double_interval *Result, int_interval *Y);

extern void fpi_int_to_double(int fpu_precision, int fpu_rounding, double_interval *Result, int_interval *X);

extern void fpi_int_to_double_inv(int fpu_precision, int fpu_rounding, int_interval *Result, double_interval *Y);
 



extern void fpi_ldouble_to_int(int fpu_precision, int fpu_rounding, int_interval *Result, ldouble_interval *X);

extern void fpi_ldouble_to_int_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, int_interval *Y);

extern void fpi_int_to_ldouble(int fpu_precision, int fpu_rounding, ldouble_interval *Result, int_interval *X);

extern void fpi_int_to_ldouble_inv(int fpu_precision, int fpu_rounding, int_interval *Result, ldouble_interval *Y);
 



extern void fpi_float_to_llong(int fpu_precision, int fpu_rounding, llong_interval *Result, float_interval *X);

extern void fpi_float_to_llong_inv(int fpu_precision, int fpu_rounding, float_interval *Result, llong_interval *Y);

extern void fpi_llong_to_float(int fpu_precision, int fpu_rounding, float_interval *Result, llong_interval *X);

extern void fpi_llong_to_float_inv(int fpu_precision, int fpu_rounding, llong_interval *Result, float_interval *Y);
 



extern void fpi_double_to_llong(int fpu_precision, int fpu_rounding, llong_interval *Result, double_interval *X);

extern void fpi_double_to_llong_inv(int fpu_precision, int fpu_rounding, double_interval *Result, llong_interval *Y);

extern void fpi_llong_to_double(int fpu_precision, int fpu_rounding, double_interval *Result, llong_interval *X);

extern void fpi_llong_to_double_inv(int fpu_precision, int fpu_rounding, llong_interval *Result, double_interval *Y);
 



extern void fpi_ldouble_to_llong(int fpu_precision, int fpu_rounding, llong_interval *Result, ldouble_interval *X);

extern void fpi_ldouble_to_llong_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, llong_interval *Y);

extern void fpi_llong_to_ldouble(int fpu_precision, int fpu_rounding, ldouble_interval *Result, llong_interval *X);

extern void fpi_llong_to_ldouble_inv(int fpu_precision, int fpu_rounding, llong_interval *Result, ldouble_interval *Y);
 




extern void fpi_float_to_ushort(int fpu_precision, int fpu_rounding, ushort_interval *Result, float_interval *X);

extern void fpi_float_to_ushort_inv(int fpu_precision, int fpu_rounding, float_interval *Result, ushort_interval *Y);

extern void fpi_ushort_to_float(int fpu_precision, int fpu_rounding, float_interval *Result, ushort_interval *X);

extern void fpi_ushort_to_float_inv(int fpu_precision, int fpu_rounding, ushort_interval *Result, float_interval *Y);
 



extern void fpi_double_to_ushort(int fpu_precision, int fpu_rounding, ushort_interval *Result, double_interval *X);

extern void fpi_double_to_ushort_inv(int fpu_precision, int fpu_rounding, double_interval *Result, ushort_interval *Y);

extern void fpi_ushort_to_double(int fpu_precision, int fpu_rounding, double_interval *Result, ushort_interval *X);

extern void fpi_ushort_to_double_inv(int fpu_precision, int fpu_rounding, ushort_interval *Result, double_interval *Y);
 



extern void fpi_ldouble_to_ushort(int fpu_precision, int fpu_rounding, ushort_interval *Result, ldouble_interval *X);

extern void fpi_ldouble_to_ushort_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ushort_interval *Y);

extern void fpi_ushort_to_ldouble(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ushort_interval *X);

extern void fpi_ushort_to_ldouble_inv(int fpu_precision, int fpu_rounding, ushort_interval *Result, ldouble_interval *Y);
 



extern void fpi_float_to_uint(int fpu_precision, int fpu_rounding, uint_interval *Result, float_interval *X);

extern void fpi_float_to_uint_inv(int fpu_precision, int fpu_rounding, float_interval *Result, uint_interval *Y);

extern void fpi_uint_to_float(int fpu_precision, int fpu_rounding, float_interval *Result, uint_interval *X);

extern void fpi_uint_to_float_inv(int fpu_precision, int fpu_rounding, uint_interval *Result, float_interval *Y);
 



extern void fpi_double_to_uint(int fpu_precision, int fpu_rounding, uint_interval *Result, double_interval *X);

extern void fpi_double_to_uint_inv(int fpu_precision, int fpu_rounding, double_interval *Result, uint_interval *Y);

extern void fpi_uint_to_double(int fpu_precision, int fpu_rounding, double_interval *Result, uint_interval *X);

extern void fpi_uint_to_double_inv(int fpu_precision, int fpu_rounding, uint_interval *Result, double_interval *Y);
 



extern void fpi_ldouble_to_uint(int fpu_precision, int fpu_rounding, uint_interval *Result, ldouble_interval *X);

extern void fpi_ldouble_to_uint_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, uint_interval *Y);

extern void fpi_uint_to_ldouble(int fpu_precision, int fpu_rounding, ldouble_interval *Result, uint_interval *X);

extern void fpi_uint_to_ldouble_inv(int fpu_precision, int fpu_rounding, uint_interval *Result, ldouble_interval *Y);
 



extern void fpi_float_to_ullong(int fpu_precision, int fpu_rounding, ullong_interval *Result, float_interval *X);

extern void fpi_float_to_ullong_inv(int fpu_precision, int fpu_rounding, float_interval *Result, ullong_interval *Y);

extern void fpi_ullong_to_float(int fpu_precision, int fpu_rounding, float_interval *Result, ullong_interval *X);

extern void fpi_ullong_to_float_inv(int fpu_precision, int fpu_rounding, ullong_interval *Result, float_interval *Y);
 



extern void fpi_double_to_ullong(int fpu_precision, int fpu_rounding, ullong_interval *Result, double_interval *X);

extern void fpi_double_to_ullong_inv(int fpu_precision, int fpu_rounding, double_interval *Result, ullong_interval *Y);

extern void fpi_ullong_to_double(int fpu_precision, int fpu_rounding, double_interval *Result, ullong_interval *X);

extern void fpi_ullong_to_double_inv(int fpu_precision, int fpu_rounding, ullong_interval *Result, double_interval *Y);
 



extern void fpi_ldouble_to_ullong(int fpu_precision, int fpu_rounding, ullong_interval *Result, ldouble_interval *X);

extern void fpi_ldouble_to_ullong_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ullong_interval *Y);

extern void fpi_ullong_to_ldouble(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ullong_interval *X);

extern void fpi_ullong_to_ldouble_inv(int fpu_precision, int fpu_rounding, ullong_interval *Result, ldouble_interval *Y);
 



 





extern void fpi_tanl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);





extern void fpi_tanl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y, ldouble_interval *X);



extern void fpi_sinl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);



extern void fpi_sinl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y, ldouble_interval *X);



extern void fpi_cosl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);



extern void fpi_cosl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y, ldouble_interval *X);



 


extern void fpi_addf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X, float_interval *Y);
extern void fpi_addd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X, double_interval *Y);
extern void fpi_addl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X, ldouble_interval *Y);

extern void fpi_addxf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Z, float_interval *Y);
extern void fpi_addxd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Z, double_interval *Y);
extern void fpi_addxl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Z, ldouble_interval *Y);

extern void fpi_addyf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Z, float_interval *X);
extern void fpi_addyd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Z, double_interval *X);
extern void fpi_addyl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Z, ldouble_interval *X);


extern void fpi_subf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X, float_interval *Y);
extern void fpi_subd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X, double_interval *Y);
extern void fpi_subl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X, ldouble_interval *Y);

extern void fpi_subxf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Z, float_interval *Y);
extern void fpi_subxd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Z, double_interval *Y);
extern void fpi_subxl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Z, ldouble_interval *Y);

extern void fpi_subyf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Z, float_interval *X);
extern void fpi_subyd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Z, double_interval *X);
extern void fpi_subyl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Z, ldouble_interval *X);

extern void fpi_multf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X, float_interval *Y);
extern void fpi_multd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X, double_interval *Y);
extern void fpi_multl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X, ldouble_interval *Y);

extern void fpi_multxf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Z, float_interval *Y);
extern void fpi_multxd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Z, double_interval *Y);
extern void fpi_multxl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Z, ldouble_interval *Y);

extern void fpi_multyf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Z, float_interval *X);
extern void fpi_multyd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Z, double_interval *X);
extern void fpi_multyl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Z, ldouble_interval *X);


extern void fpi_divf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X, float_interval *Y);
extern void fpi_divd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X, double_interval *Y);
extern void fpi_divl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X, ldouble_interval *Y);

extern void fpi_divxf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Z, float_interval *Y);
extern void fpi_divxd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Z, double_interval *Y);
extern void fpi_divxl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Z, ldouble_interval *Y);

extern void fpi_divyf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Z, float_interval *X);
extern void fpi_divyd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Z, double_interval *X);
extern void fpi_divyl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Z, ldouble_interval *X);




 



extern void fpi_sqrtf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_sqrtd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_sqrtl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);

extern void fpi_sqrtf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_sqrtd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_sqrtl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);

extern void fpi_xxf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_xxd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_xxl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);

extern void fpi_xxf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_xxd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_xxl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);

extern void fpi_xx_xyf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y, float_interval *X);
extern void fpi_xx_xyd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y, double_interval *X);
extern void fpi_xx_xyl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y, ldouble_interval *X);





 



 
extern int fpi_is_true_setf(float_interval *X, float_interval *Y);
extern int fpi_is_true_setd(double_interval *X, double_interval *Y);
extern int fpi_is_true_setl(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_false_setf(float_interval *X, float_interval *Y);
extern int fpi_is_false_setd(double_interval *X, double_interval *Y);
extern int fpi_is_false_setl(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_true_equalf(float_interval *X, float_interval *Y);
extern int fpi_is_true_equald(double_interval *X, double_interval *Y);
extern int fpi_is_true_equall(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_false_equalf(float_interval *X, float_interval *Y);
extern int fpi_is_false_equald(double_interval *X, double_interval *Y);
extern int fpi_is_false_equall(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_true_lessthanf(float_interval *X, float_interval *Y);
extern int fpi_is_true_lessthand(double_interval *X, double_interval *Y);
extern int fpi_is_true_lessthanl(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_false_lessthanf(float_interval *X, float_interval *Y);
extern int fpi_is_false_lessthand(double_interval *X, double_interval *Y);
extern int fpi_is_false_lessthanl(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_true_morethanf(float_interval *X, float_interval *Y);
extern int fpi_is_true_morethand(double_interval *X, double_interval *Y);
extern int fpi_is_true_morethanl(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_false_morethanf(float_interval *X, float_interval *Y);
extern int fpi_is_false_morethand(double_interval *X, double_interval *Y);
extern int fpi_is_false_morethanl(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_true_lesseqf(float_interval *X, float_interval *Y);
extern int fpi_is_true_lesseqd(double_interval *X, double_interval *Y);
extern int fpi_is_true_lesseql(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_false_lesseqf(float_interval *X, float_interval *Y);
extern int fpi_is_false_lesseqd(double_interval *X, double_interval *Y);
extern int fpi_is_false_lesseql(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_true_moreeqf(float_interval *X, float_interval *Y);
extern int fpi_is_true_moreeqd(double_interval *X, double_interval *Y);
extern int fpi_is_true_moreeql(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_false_moreeqf(float_interval *X, float_interval *Y);
extern int fpi_is_false_moreeqd(double_interval *X, double_interval *Y);
extern int fpi_is_false_moreeql(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_true_noteqf(float_interval *X, float_interval *Y);
extern int fpi_is_true_noteqd(double_interval *X, double_interval *Y);
extern int fpi_is_true_noteql(ldouble_interval *X, ldouble_interval *Y);

 
extern int fpi_is_false_noteqf(float_interval *X, float_interval *Y);
extern int fpi_is_false_noteqd(double_interval *X, double_interval *Y);
extern int fpi_is_false_noteql(ldouble_interval *X, ldouble_interval *Y);





 


extern void fpi_logf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_logd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_logl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);

extern void fpi_logf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_logd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_logl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);


extern void fpi_expf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_expd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_expl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);

extern void fpi_expf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_expd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_expl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);



extern void init_acos(void);



extern void fpi_acosf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_acosd(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_acosl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);

extern void fpi_acosf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_acosd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_acosl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);


extern void fpi_asinf(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *X);
extern void fpi_asind(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *X);
extern void fpi_asinl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);



extern void init_asin(void);



 
extern float fpi_min_asinf(int fpu_precision, int fpu_rounding);
extern double fpi_min_asind(int fpu_precision, int fpu_rounding);
extern long double fpi_min_asinl(int fpu_precision, int fpu_rounding);
   
 
extern float fpi_max_asinf(int fpu_precision, int fpu_rounding);
extern double fpi_max_asind(int fpu_precision, int fpu_rounding);
extern long double fpi_max_asinl(int fpu_precision, int fpu_rounding);

extern void fpi_asinf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, float_interval *Y);
extern void fpi_asind_inv(int fpu_precision, int fpu_rounding, double_interval *Result, double_interval *Y);
extern void fpi_asinl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);




 



extern void fpi_cbrtf(int fpu_precision, int fpu_rounding, ldouble_interval *Result, float_interval *X);
extern void fpi_cbrtd(int fpu_precision, int fpu_rounding, ldouble_interval *Result, double_interval *X);
extern void fpi_cbrtl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);

extern void fpi_cbrtf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, ldouble_interval *Y);
extern void fpi_cbrtd_inv(int fpu_precision, int fpu_rounding, double_interval *Result, ldouble_interval *Y);
extern void fpi_cbrtl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);


extern void fpi_atanf(int fpu_precision, int fpu_rounding, ldouble_interval *Result, float_interval *X);
extern void fpi_atand(int fpu_precision, int fpu_rounding, ldouble_interval *Result, double_interval *X);
extern void fpi_atanl(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *X);



extern void init_atan(void);



 
extern float fpi_min_atanf(int fpu_precision, int fpu_rounding);
extern double fpi_min_atand(int fpu_precision, int fpu_rounding);
extern long double fpi_min_atanl(int fpu_precision, int fpu_rounding);
   
 
extern float fpi_max_atanf(int fpu_precision, int fpu_rounding);
extern double fpi_max_atand(int fpu_precision, int fpu_rounding);
extern long double fpi_max_atanl(int fpu_precision, int fpu_rounding);

extern void fpi_atanf_inv(int fpu_precision, int fpu_rounding, float_interval *Result, ldouble_interval *Y);
extern void fpi_atand_inv(int fpu_precision, int fpu_rounding, double_interval *Result, ldouble_interval *Y);
extern void fpi_atanl_inv(int fpu_precision, int fpu_rounding, ldouble_interval *Result, ldouble_interval *Y);

#ifdef _NO_FPI_
#pragma GCC visibility pop
#endif
