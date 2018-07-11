//
//  rationalUtilities.m
//  Clo
//
//  Created by remy on 05/04/2018.
//
//

#import "rationalUtilities.h"
#import <ORFoundation/ORTrail.h>

#define R_IS_ZERO(Q) (((*(Q).rational->_mp_num._mp_size) == 0)?1:0)
#define R_IS_NONZERO(Q) (((*(Q).rational->_mp_num._mp_size) == 0)?0:1)
#define R_IS_POSITIVE(Q) ((0 <= (*(Q).rational->_mp_num._mp_size))?1:0)
#define R_IS_NEGATIVE(Q) (((*(Q).rational->_mp_num._mp_size) <= 0)?1:0)
#define R_IS_STRICTLY_POSITIVE(Q) ((0 < (*(Q).rational->_mp_num._mp_size))?1:0)
#define R_IS_STRICTLY_NEGATIVE(Q) (((*(Q).rational->_mp_num._mp_size) < 0)?1:0)

#define R_SET_POS_ONE(Q) { mpq_set_ui(((Q)->_rational),1UL,1UL); Q->_type = 1; }
#define R_SET_NEG_ONE(Q) { mpq_set_si(((Q)->_rational),-1L,1UL); (Q)->_type = -1; }

#define RI_SET_ZERO(RIA) { R_SET_ZERO((RIA).low); R_SET_ZERO((RIA).up); }
#define RI_SET_POS_INF(RIA)  { R_SET_POS_INF((RIA).low); R_SET_POS_INF((RIA).up); }
#define RI_SET_NEG_INF(RIA)  { R_SET_NEG_INF((RIA).low); R_SET_NEG_INF((RIA).up); }

@implementation ORRational
-(id)init:(id<ORMemoryTrail>) mt{
   mpq_init(_rational);
   _type = 0;
   _mt = mt;
   [_mt track:self];
   return self;
}
-(id)init
{
   mpq_init(_rational);
   _type = 0;
   return self;
}
-(void)dealloc{
   mpq_clear(_rational);
   [super dealloc];
}
-(void)print{
   NSLog(@"%s", [self get_str]);
}
-(mpq_ptr)rational{
   return _rational;
}
-(void)setNAN
{
   mpz_set_ui(mpq_numref(_rational),0UL);
   mpz_set_ui(mpq_denref(_rational),0UL);
   _type = 3;
}
-(void)setZero
{
   mpq_set_ui((_rational),0UL,1UL);
   _type = 0;
}
-(void)setOne
{
   mpq_set_d((_rational),1);
   _type = 1;
}
-(void)setPosInf
{
   mpz_set_ui(mpq_numref(_rational),1UL);
   mpz_set_ui(mpq_denref(_rational),0UL);
   _type = 2;
}
-(void)setNegInf
{
   mpz_set_si(mpq_numref(_rational),-1L);
   mpz_set_ui(mpq_denref(_rational),0UL);
   _type = -2;
}
-(BOOL)isNAN
{
   ORRational* z = [[ORRational alloc] init:_mt];
   [z setNAN];
   return [self eq: z];
}
-(BOOL)isZero
{
   ORRational* z = [[ORRational alloc] init:_mt];
   [z setZero];
   return [self eq: z];
}
-(BOOL)isOne
{
   ORRational* z = [[ORRational alloc] init:_mt];
   [z setOne];
   return [self eq: z];
}
-(BOOL)isMinusOne
{
   ORRational* z = [[ORRational alloc] init:_mt];
   [z setOne];
   z = [z neg];
   return [self eq: z];
}
-(BOOL)isPosInf
{
   ORRational* z = [[ORRational alloc] init:_mt];
   [z setPosInf];
   return [self eq: z];
}
-(BOOL)isNegInf
{
   ORRational* z = [[ORRational alloc] init:_mt];
   [z setNegInf];
   return [self eq: z];
}
-(void)setRational:(mpq_t*)rational
{
   mpq_set(_rational, *rational);
}
-(int)type{
   return _type;
}
-(id<ORMemoryTrail>)mt{
   return _mt;
}
-(void)setType:(int)type{
   _type = type;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"%s",[self get_str]];
   return buf;
}
-(id)set:(id<ORRational>)r{
   mpq_set(_rational, *r.rational);
   mpq_canonicalize(_rational);
   _type = r.type;
   return self;
}
-(id)set_d:(double)d{
   if (d == -INFINITY) {
      [self setNegInf];
   } else if (d == +INFINITY) {
      [self setPosInf];
   } else if (isnan(d)){
      [self setNAN];
   } else {
      mpq_set_d(_rational, d);
      _type = mpq_sgn(_rational);
      mpq_canonicalize(_rational);
   }
   return self;
}
-(id)set:(int)num and:(int)den{
   mpz_t nz, dz;
   mpz_inits(nz, dz, NULL);
   mpz_set_d(nz, num);
   mpz_set_d(dz, den);
   mpq_set_num(_rational, nz);
   mpq_set_den(_rational, dz);
   mpq_canonicalize(_rational);
   _type = mpq_sgn(_rational);
   mpz_clears(nz, dz, NULL);
   
   return self;
}
-(id<ORRational>)get{
   return self;
}
-(char*)get_str{
   switch (_type) {
      case -2:
         return "-INF";
         break;
      case 2:
         return "+INF";
         break;
      case 3:
         return "NaN";
         break;
      default:
         return mpq_get_str(NULL, 10, _rational);
         break;
   }
}
-(double)get_d{
   switch (_type) {
      case -2:
         return -INFINITY;
         break;
      case 2:
         return INFINITY;
         break;
      case 3:
         return NAN;
         break;
      default:
         return mpq_get_d(_rational);
         break;
   }
}
-(id<ORRational>)add:(ORRational*)r
{
   ORRational* z = [[ORRational alloc] init: _mt];
   /* x = NaN || y = NaN */
   if(_type == 3 || r.type == 3){
      /* z = NaN */
      [z setNAN];
   }
   /* (x = -inf && y = inf) || (x = inf && y = -inf) */
   else if((_type == -2 && r.type == 2) || (_type == 2 && r.type == -2)){
      /* z = NaN */
      [z setNAN];
   }
   /* (x = -inf || y = -inf) */
   else if(_type == -2 || r.type == -2){
      /* z = -inf */
      [z setNegInf];
   }
   /* (x = inf || y = inf) */
   else if((_type == 2 || r.type == 2)){
      /* z = inf */
      [z setPosInf];
   }
   /* x = Q && y = Q */
   else {
      mpq_add(z.rational, _rational, r.rational);
      z->_type = mpq_sgn(z.rational);
   }
   return z;
}
-(id<ORRational>)sub:(ORRational*)r{
   ORRational* z = [[ORRational alloc] init: _mt];
   /* x = NaN || y = NaN */
   if(_type == 3 || r.type == 3){
      /* z = NaN */
      [z setNAN];
   }
   /* (x = -inf && y = -inf) || (x = inf && y = inf) */
   else if((_type == -2 && r.type == -2) || (_type == 2 && r.type == 2)){
      /* z = NaN */
      [z setNAN];
   }
   /* (x = -inf || y = inf) */
   else if((_type == -2) || (r.type == 2)){
      /* z = -inf */
      [z setNegInf];
   }
   /* (x = inf || y = -inf) */
   else if((_type == 2) || (r.type == -2)){
      /* z = inf */
      [z setPosInf];
   }
   /* x = Q && y = Q */
   else {
      mpq_sub(z->_rational, _rational, r->_rational);
      z->_type = mpq_sgn(z->_rational);
   }
   return z;
}
-(id<ORRational>)mul:(ORRational*)r
{
   ORRational* z = [[ORRational alloc] init: _mt];
   /* x = NaN || y = NaN */
   if(_type == 3 || r.type == 3){
      /* z = NaN */
      [z setNAN];
   }
   /*
    (x =  0    && y = -inf) ||
    (x = -inf  && y =  0)   ||
    (x =  inf  && y =  0)   ||
    (x =  0    && y =  inf)
    */
   else if((_type == -2 && r.type == 0) || (_type == 0 && r.type == -2) || (_type == 2 && r.type == 0) || (_type == 0 && r.type == 2)){
      /* z = NaN */
      [z setNAN];
   }
   /*
    (x = -inf && (y = PR || y =  inf)) ||
    (y = -inf && (x = PR || x =  inf)) ||
    (x = inf  && (y = NR || y = -inf)) ||
    (y = inf  && (x = NR || x = -inf))
    */
   else if((_type == -2  && (r.type ==  1 || r.type ==  2)) ||
           (r.type == -2  && (_type ==  1 || _type ==  2)) ||
           (_type ==  2  && (r.type == -1 || r.type == -2)) ||
           (r.type ==  2  && (_type == -1 || _type == -2))){
      /* z = -inf */
      [z setNegInf];
   }
   /*
    (x = -inf && (y = -inf || y = NR)) ||
    (y = -inf && (x = -inf || x = NR)) ||
    (x = inf  && (y =  inf || y = PR)) ||
    (y = inf  && (x =  inf || x = PR))
    */
   else if((_type == -2  && (r.type == -2 || r.type == -1)) ||
           (r.type == -2  && (_type == -2 || _type == -1)) ||
           (_type ==  2  && (r.type ==  2 || r.type ==  1)) ||
           (r.type ==  2  && (_type ==  2 || _type ==  1))){
      /* z = inf */
      [z setPosInf];
   }
   /* x = Q && y = Q */
   else {
      mpq_mul(z->_rational, _rational, r->_rational);
      z->_type = mpq_sgn(z->_rational);
   }
   return z;
}
-(id<ORRational>)div:(ORRational*)r{
   ORRational* z = [[ORRational alloc] init: _mt];
   /* x = NaN || y = NaN */
   if(_type == 3 || r.type == 3){
      /* z = NaN */
      [z setNAN];
   }
   /*
    (x = -inf  && y = -inf) ||
    (x = -inf  && y =  inf) ||
    (x =  inf  && y = -inf) ||
    (x =  inf  && y =  inf) ||
    (y =  0)
    */
   else if((_type == -2 && r.type ==  2) ||
           (_type == -2 && r.type == -2) ||
           (_type ==  2 && r.type ==  2) ||
           (_type ==  2 && r.type == -2) ||
           (r.type ==  0)){
      /* z = NaN */
      [z setNAN];
   }
   /*
    (x = -inf && y = PR) ||
    (x =  inf && y = NR)
    */
   else if((_type == -2 && r.type == 1) ||
           (_type == 2 && r.type == -1)){
      /* z = -inf */
      [z setNegInf];
   }
   /*
    (x = -inf && y = NR) ||
    (x =  inf && y = PR)
    */
   else if((_type == -2 && r.type == -1) ||
           (_type ==  2 && r.type ==  1)){
      /* z = inf */
      [z setPosInf];
   } else if(r.type == -2 || r.type == 2) {
      /* z = 0 */
      [z setZero];
   }
   /* x = Q && y = Q */
   else {
      mpq_div(z->_rational, _rational, r.rational);
      z->_type = mpq_sgn(z->_rational);
   }
   return z;
}
-(id<ORRational>)neg{
   /* z = -x */
   ORRational* z = [[ORRational alloc] init: _mt];
   switch (_type) {
      case -2:
         [z setPosInf];
         break;
      case 2:
         [z setNegInf];
         break;
      case 3:
         [z setNAN];
         break;
      default:
         mpq_neg(z->_rational, _rational);
         z.type = - _type;
         break;
   }
   return z;
}
-(id<ORRational>)abs
{
   ORRational* z = [[ORRational alloc] init: _mt];
   if(_type == 3){
      [z setNAN];
   } else if(_type == -2){
      [z setPosInf];
   } else if(_type == 2){
      [z setNegInf];
   } else {
      mpq_abs(z->_rational, _rational);
      z->_type = mpq_sgn(_rational);
   }
   return z;
}
-(BOOL)cmp:(id<ORRational>)r{
   if([self eq:r]){
      return 0;
   } else if([self gt: r]){
      return 1;
   } else {
      return -1;
   }
}
-(BOOL)cmp:(long int)num and:(long int)den{
   return mpq_cmp_ui(_rational, num, den);
}
-(BOOL)lt:(id<ORRational>)r{
   /* x < y */
   if(_type == 3 || r.type == 3){
      return 0;
   } else if(_type == 2 || r.type == -2){
      return 0;
   } else if((_type == r.type) && (_type == -2)){
      return 0;
   } else if(_type == -2 || r.type == 2){
      return 1;
   } else{
      return (mpq_cmp(_rational, *r.rational) < 0);
   }
}
-(BOOL)gt:(id<ORRational>)r{
   /* x > y */
   if(_type == 3 || r.type == 3){
      return 0;
   } else if(_type == -2 || r.type == 2){
      return 0;
   } else if(_type == r.type && (_type == 2)){
      return 0;
   } else if(_type == 2){
      return 1;
   } else{
      return (mpq_cmp(_rational, *r.rational) > 0);
   }
}
-(BOOL)leq:(id<ORRational>)r{
   /* x <= y */
   if(_type == 3 || r.type == 3){
      return 0;
   } else if((_type == -2 || _type == 2) && (_type == r.type)){
      return 1;
   } else if(_type == 2 || r.type == -2){
      return 0;
   } else if(_type == -2){
      return 1;
   } else{
      return (mpq_cmp(_rational, *r.rational) <= 0);
   }
}
-(BOOL)geq:(id<ORRational>)r{
   /* x >= y */
   if(_type == 3 || r.type == 3){
      return 0;
   } else if((_type == -2 || _type == 2) &&
             (_type == r.type)){
      return 1;
   } else if(_type == -2 || r.type == 2){
      return 0;
   } else if(_type == 2){
      return 1;
   } else{
      return (mpq_cmp(_rational, *r.rational) >= 0);
   }
}
-(BOOL)eq:(id<ORRational>)r{
   /* x == y */
   if(_type == 3 || r.type == 3){
      return 0;
   } else if(_type != r.type){
      return 0;
   } else if((_type == -2 || _type == -2) &&
             (_type == r.type)){
      return 1;
   } else {
      return mpq_equal(_rational, *r.rational);
   }
}
-(BOOL)neq:(id<ORRational>)r{
   /* x != y */
   return ![self eq:r];
}
@end

@implementation ORRationalInterval
-(id)init:(id<ORMemoryTrail>) mt{
   self = [super init];
   _low = [[ORRational alloc] init: mt];
   _up = [[ORRational alloc] init: mt];
   [mt track:self];
   return self;
}
-(void)dealloc{
   [super dealloc];
   [_low release];
   [_up release];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"[%@,%@]",_low, _up];
   return buf;
}
-(id<ORRational>)low
{
   return _low;
}
-(id<ORRational>)up
{
   return _up;
}
-(void)setLow:(id<ORRational>)l
{
   [_low set: l];
}
-(void)setUp:(id<ORRational>)u
{
   [_up set: u];
}
-(int)changed
{
   return _changed;
}
-(void)setChanged:(int)c
{
   _changed = c;
}
-(id)set:(id<ORRationalInterval>)ri{
   [self set_q:ri.low and:ri.up];
   
   return self;
}
-(id)set_d:(double)low and:(double)up{
   [_low set_d:low];
   [_up set_d:up];
   
   return self;
}
-(id)set_q:(id<ORRational>)low and:(id<ORRational>)up{
   [low set:low];
   [up set:up];
   
   return self;
}
-(void)setNAN
{
   [_low setNAN];
   [_up setNAN];
}
-(void)setZero
{
   [_low setZero];
   [_up setZero];
}
-(void)setPosInf
{
   [_low setPosInf];
   [_up setPosInf];
}
-(void)setNegInf
{
   [_low setNegInf];
   [_up setNegInf];
}
-(id<ORRationalInterval>)add:(id<ORRationalInterval>)ri{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   z.low = [_low add: ri.low];
   z.up = [_up add: ri.up];
   return z;
}
-(id<ORRationalInterval>)sub:(id<ORRationalInterval>)ri{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   z.low = [_low add: ri.up];
   z.up = [_up add: ri.low];
   return z;
}
-(id<ORRationalInterval>)mul:(id<ORRationalInterval>)ri{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   if(_low.type >= 0 ) {                            /* A >= 0 */
      if (ri.low.type >= 0) {                          /* B >= 0 */
         z.low = [_low mul: ri.low];
         z.up = [_up mul: ri.up];
      }
      else if (ri.up.type <= 0) {                          /* B <= 0 */
         z.low = [_up mul: ri.low];
         z.up = [_low mul: ri.up];
      }
      else {                                              /* 0 in B */
         z.low = [_up mul: ri.low];
         z.up = [_up mul: ri.up];
      }
   }
   else if (_up.type <= 0) {                            /* A <= 0 */
      if (ri.low.type >= 0) {                          /* B >= 0 */
         z.low = [_low mul: ri.up];
         z.up = [_up mul: ri.low];
      }
      else if (ri.up.type <= 0) {                          /* B <= 0 */
         z.low = [_up mul: ri.up];
         z.up = [_low mul: ri.low];
      }
      else {                                              /* 0 in B */
         z.low = [_low mul: ri.up];
         z.up = [_low mul: ri.low];
      }
   }
   else {                                                /* 0 in A */
      if (ri.low.type >= 0) {                          /* B >= 0 */
         z.low = [_low mul: ri.up];
         z.up = [_up mul: ri.up];
      }
      else if (ri.up.type <= 0) {                          /* B <= 0 */
         z.low = [_up mul: ri.low];
         z.up = [_low mul: _low];
      }
      else {                                              /* 0 in B */
         ORRationalInterval* tmp = [[ORRationalInterval alloc] init: _low.mt];
         tmp.low = [_low mul: ri.up];
         tmp.up = [_up mul: ri.low];
         
         if([tmp.low lt: tmp.up]){
            [z.low set: tmp.low];
         } else {
            [z.low set: tmp.up];
         }
         
         tmp.low = [_low mul: ri.low];
         tmp.up = [_up mul: ri.up];
         
         if([tmp.low gt: tmp.up]){
            [z.up set: tmp.low];
         } else {
            [z.up set: tmp.up];
         }
      }
   }
   return z;
}
-(id<ORRationalInterval>)div:(id<ORRationalInterval>)ri{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   if (_low.type >= 0) {                            /* A >= 0 */
      if (ri.low.type > 0) {     /* B >  0 */
         z.low = [_low div: ri.up];
         z.up = [_up div: ri.low];
      }
      else if (ri.up.type < 0) {       /* B <  0 */
         z.low = [_up div: ri.up];
         z.up = [_low div: ri.low];
      }
      else                                                /* 0 in B */
         if(_low.type == 0){
            [ri setNAN];
         } else{
            [ri.low setNegInf];
            [ri.up setPosInf];
         }
      
   }
   else if (_up.type <= 0) {                            /* A <= 0 */
      if (ri.low.type > 0) {     /* B >  0 */
         z.low = [_low div: ri.low];
         z.up = [_up div: ri.up];
      }
      else if (ri.up.type < 0) {       /* B <  0 */
         z.low = [_up div: ri.low];
         z.up = [_low div: ri.up];
      }
      else                                                /* 0 in B */
         if(_up.type == 0){
            [ri setNAN];
         } else{
            [ri.low setNegInf];
            [ri.up setPosInf];
         }
   }
   else {                                                /* 0 in A */
      if (ri.low.type > 0) {     /* B >  0 */
         z.low = [_low div: ri.low];
         z.up = [_up div: ri.low];
      }
      else if (ri.up.type < 0) {       /* B <  0 */
         z.low = [_up div: ri.up];
         z.up = [_low div: ri.low];
      }
      else                                                /* 0 in B */
         [ri setNAN];
   }
   return z;
}
-(id<ORRationalInterval>)neg{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   z.low = [_up neg];
   z.up = [_low neg];
   
   return z;
}
-(id<ORRationalInterval>)abs{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   z.low = [_low abs];
   z.up = [_up abs];
   
   return z;
}
-(BOOL)cmp:(id<ORRationalInterval>)ri{
   if([self eq: ri]){
      return 0;
   } else if([self gt: ri]){
      return 1;
   } else {
      return -1;
   }
}
-(BOOL)lt:(id<ORRationalInterval>)ri{
   return [_low lt: ri.low] && [_up lt: ri.up];
}
-(BOOL)gt:(id<ORRationalInterval>)ri{
   return [_low gt: ri.low] && [_up gt: ri.up];
}
-(BOOL)leq:(id<ORRationalInterval>)ri{
   return [_low leq: ri.low] && [_up leq: ri.up];
}
-(BOOL)geq:(id<ORRationalInterval>)ri{
   return [_low geq: ri.low] && [_up geq: ri.up];
}
-(BOOL)eq:(id<ORRationalInterval>)ri{
   return [_low eq: ri.low] && [_up eq: ri.up];
}
-(BOOL)neq:(id<ORRationalInterval>)ri{
   return ![self eq: ri];
}
-(BOOL)empty{
   return (_low.type == 3 || _up.type == 3)  ||
   (_low.type == 2 && _up.type < 2)   ||
   (_up.type == -2 && _low.type > -2) ||
   [_low gt: _up];
}
-(id<ORRationalInterval>)union:(id<ORRationalInterval>)ri{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   if([self empty] || [ri empty]){
      [z setNAN];
   } else {
      /* lower bound */
      if(_low.type == -2 || ri.low.type == -2){
         [z.low setNegInf];
      } else if(_low.type == 2 || ri.low.type == 2){
         [z.low setPosInf];
      } else if([_low leq: ri.low]){
         [z.low set: _low];
      } else {
         [z.low set: ri.low];
      }
      /* upper bound */
      if(_up.type == -2 || ri.up.type == -2){
         [z.up setNegInf];
      } else if(_up.type == 2 || ri.up.type == 2){
         [z.up setPosInf];
      } else if([_up geq: ri.up]){
         [z.up set: _up];
      } else {
         [z.up set: ri.up];
      }
      
      if([z empty])
         [z setNAN];
   }
   return z;
}
-(id<ORRationalInterval>)intersection:(id<ORRationalInterval>)ri{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   if([self empty] || [ri empty]){
      [z setNAN];
   } else {
      /* lower bound */
      if(_low.type == -2 || ri.low.type == -2){
         [z.low setNegInf];
      } else if(_low.type == 2 || ri.low.type == 2){
         [z.low setPosInf];
      } else if([_low leq: ri.low]){
         [z.low set: ri.low];
      } else {
         [z.low set: _low];
      }
      /* upper bound */
      if(_up.type == -2 || ri.up.type == -2){
         [z.up setNegInf];
      } else if(_up.type == 2 || ri.up.type == 2){
         [z.up setPosInf];
      } else if([_up geq: ri.up]){
         [z.up set: ri.up];
      } else {
         [z.up set: _up];
      }
      
      if([z empty])
         [z setNAN];
   }
   return z;
}
-(id<ORRationalInterval>)proj_inter:(id<ORRationalInterval>)ri{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   if([self empty] || [ri empty]){
      [z setNAN];
      return z;
   }
   
   z.changed = 0;
   ORRational* o_size = [[ORRational alloc] init];
   ORRational* n_size = [[ORRational alloc] init];
   
   o_size = [_up sub: _low];
   
   if([_low lt: ri.low]){
      [z.low set: ri.low];
      z.changed = 1;
   }
   
   if([_up gt: ri.up]){
      [z.up set: ri.low];
      z.changed |= 2;
   }
   
   if([z empty]){
      [z set: self];
      z.changed = 0;
      return z;
   }
   
   if(z.changed){
      n_size = [[o_size sub: [_up sub: _low]] div: o_size];
      [o_size set_d: 0.05];
      
      if([n_size leq: o_size]){
         z.changed = 0;
         [z set: self];
      }
   }
   [o_size release];
   [n_size release];
   return z;
}
-(id<ORRationalInterval>)proj_inter:(id<ORRational>)inf and:(id<ORRational>)sup{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   if([self empty] || inf.type == 3 || sup.type == 3){
      [z setNAN];
      return z;
   }
   
   int changed = 0;
   ORRational* o_size = [[ORRational alloc] init: _low.mt];
   ORRational* n_size = [[ORRational alloc] init: _low.mt];
   
   o_size = [_up sub: _low];
   
   if([_low lt: inf]){
      [z.low set: inf];
      changed = 1;
   }
   
   if([_up gt: sup]){
      [z.up set: sup];
      changed |= 2;
   }
   
   if([z empty]){
      [z set: self];
      return z;
   }
   
   if(changed){
      n_size = [[o_size sub: [_up sub: _low]] div: o_size];
      [o_size set_d: 0.05];
      
      if([n_size leq: o_size]){
         changed = 0;
         [z set: self];
      }
   }
   [o_size release];
   [n_size release];
   return z;
}
@end
