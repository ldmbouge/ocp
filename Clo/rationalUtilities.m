//
//  rationalUtilities.m
//  Clo
//
//  Created by remy on 05/04/2018.
//
//

#import "rationalUtilities.h"
#import <ORFoundation/ORTrail.h>
#import <ORFoundation/ORTrailI.h>
#import <ORFoundation/ORVisit.h>

#define R_IS_ZERO(Q) (((*(Q).rational->_mp_num._mp_size) == 0)?1:0)
#define R_IS_NONZERO(Q) (((*(Q).rational->_mp_num._mp_size) == 0)?0:1)
#define R_IS_POSITIVE(Q) ((0 <= (*(Q).rational->_mp_num._mp_size))?1:0)
#define R_IS_NEGATIVE(Q) (((*(Q).rational->_mp_num._mp_size) <= 0)?1:0)
#define R_IS_STRICTLY_POSITIVE(Q) ((0 < (*(Q).rational->_mp_num._mp_size))?1:0)
#define R_IS_STRICTLY_NEGATIVE(Q) (((*(Q).rational->_mp_num._mp_size) < 0)?1:0)


@implementation ORRational
-(id)init:(id<ORMemoryTrail>) mt
{
   self = [super init];
   mpq_init(_rational);
   _type = 0;
   _mt = mt;
   [_mt track:self];
   return self;
}
-(id)init
{
   self = [super init];
   mpq_init(_rational);
   _type = 0;
   return self;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitRationalI: self];
}
-(void)dealloc{
   mpq_clear(_rational);
   [super dealloc];
}
-(void)print{
   NSLog(@"%s", [self get_str]);
}
-(rational_ptr)rational{
   return _rational;
}
-(id)setNAN
{
   mpz_set_ui(mpq_numref(_rational),0UL);
   mpz_set_ui(mpq_denref(_rational),0UL);
   _type = 3;
   
   return self;
}
-(id)setZero
{
   mpq_set_ui(_rational,0UL,1UL);
   _type = 0;
   
   return self;
}
-(id)setOne
{
   mpq_set_ui(_rational,1UL,1UL);
   _type = 1;
   
   return self;

}
-(id)setMinusOne
{
   mpq_set_si(_rational,-1L,1UL);
   _type = 1;
   
   return self;
}
-(id)setPosInf
{
   mpz_set_ui(mpq_numref(_rational),1UL);
   mpz_set_ui(mpq_denref(_rational),0UL);
   _type = 2;
   
   return self;

}
-(id)setNegInf
{
   mpz_set_si(mpq_numref(_rational),-1L);
   mpz_set_ui(mpq_denref(_rational),0UL);
   _type = -2;
   
   return self;
}
-(BOOL)isNAN
{
   //return [self eq: [ORRational rationalWith_d:NAN]];
   return self.type == 3;
}
-(BOOL)isZero
{
   return [self eq: [ORRational rationalWith_d:0]];
}
-(BOOL)isOne
{
   return [self eq: [ORRational rationalWith_d:1]];
}
-(BOOL)isMinusOne
{
   return [self eq: [ORRational rationalWith_d:-1]];
}
-(BOOL)isPosInf
{
   return [self eq: [ORRational rationalWith_d:+INFINITY]];
}
-(BOOL)isNegInf
{
   return [self eq: [ORRational rationalWith_d:-INFINITY]];
}
-(void)setRational:(rational_t)rational
{
   mpq_set(_rational, rational);
   mpq_canonicalize(_rational);
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
   //[buf appendFormat:@"%s",[self get_str]];
   /* DEBUG only */
   [buf appendFormat:@"%s [%d]",[self get_str], _type];
   return buf;
}
-(id)set:(ORRational*)r{
   mpq_set(_rational, r->_rational);
   _type = r.type;
   return self;
}
-(id)set_q:(rational_t)r{
   mpq_set(_rational, r);
   return self;
}
-(id)set_t:(int)t{
   _type = t;
   return self;
}
-(void)trailRational:(ORTrailI*)trail
{
   if (trail->_seg[trail->_cSeg]->top >= NBSLOT-1) [trail resize];
   struct Slot* s = trail->_seg[trail->_cSeg]->tab + trail->_seg[trail->_cSeg]->top;
   s->ptr = &_rational;
   s->code = TAGRational;
   init_q(s->rationalVal);
   set_q(s->rationalVal, _rational);
   ++trail->_seg[trail->_cSeg]->top;
}
-(void)trailType:(ORTrailI*)trail
{
   if (trail->_seg[trail->_cSeg]->top >= NBSLOT-1) [trail resize];
   struct Slot* s = trail->_seg[trail->_cSeg]->tab + trail->_seg[trail->_cSeg]->top;
   s->ptr = &_type;
   s->code = TAGInt;
   s->intVal = _type;
   ++trail->_seg[trail->_cSeg]->top;
}
+(ORRational*)rationalWith:(id<ORRational>)r
{
   ORRational* result = [[ORRational alloc] init];
   [result set:r];
   return result;
}
+(ORRational*)rationalWith_d:(double)d
{
   ORRational* result = [[ORRational alloc] init];
   [result set_d:d];
   return result;
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
-(id)set:(long)num and:(long)den{
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
-(BOOL)cmp:(long)num and:(long)den{
   return mpq_cmp_ui(_rational, num, den);
}
-(BOOL)lt:(id<ORRational>)r{
   /* x < y */
   if(_type == 3 || r.type == 3){
      return 0;
   } else if(_type == 2 || r.type == -2){
      return 0;
   } else if((_type == r.type) && (_type == -2 || _type == 2)){
      return 0;
   } else if(_type == -2){
      return 1;
   } else if(_type <= 1 && r.type == 2){
      return 1;
   } else{
      return (mpq_cmp(_rational, r.rational) < 0);
   }
}
-(BOOL)gt:(id<ORRational>)r{
   /* x > y */
   if(_type == 3 || r.type == 3){
      return 0;
   } else if(_type == -2 || r.type == 2){
      return 0;
   } else if(_type == r.type && (_type == 2 || _type == -2)){
      return 0;
   } else if(_type == 2){
      return 1;
   } else if(_type >= -1 && r.type == -2){
      return 1;
   } else{
      return (mpq_cmp(_rational, r.rational) > 0);
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
      return (mpq_cmp(_rational, r.rational) <= 0);
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
      return (mpq_cmp(_rational, r.rational) >= 0);
   }
}
-(BOOL)eq:(id<ORRational>)r{
   /* x == y */
   if(_type == 3 || r.type == 3){
      return 0;
   } else if(_type != r.type){
      return 0;
   } else if((_type == -2 || _type == 2) &&
             (_type == r.type)){
      return 1;
   } else {
      return mpq_equal(_rational, r.rational);
   }
}
-(BOOL)neq:(id<ORRational>)r{
   /* x != y */
   return ![self eq:r];
}
@end

@implementation ORRationalInterval
-(id)init:(id<ORMemoryTrail>) mt
{
   self = [super init];
   _low = [[ORRational alloc] init: mt];
   _up = [[ORRational alloc] init: mt];
   return self;
}
-(id)init
{
   self = [super init];
   _low = [[ORRational alloc] init];
   _up = [[ORRational alloc] init];
   return self;
}
-(void)dealloc{
   [_low release];
   [_up release];
   [super dealloc];
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
-(id)set_q:(id<ORRational>)low and:(id<ORRational>)up
{
   [_low set:low];
   [_up set:up];
   
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
-(ORRationalInterval*)add:(ORRationalInterval*)ri{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   z.low = [_low add: ri.low];
   z.up = [_up add: ri.up];
   return z;
}
-(ORRationalInterval*)sub:(ORRationalInterval*)ri{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   z.low = [_low sub: ri.up];
   z.up = [_up sub: ri.low];
   return z;
}
-(ORRationalInterval*)mul:(ORRationalInterval*)ri{
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
         z.up = [_low mul: ri.low];
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
-(ORRationalInterval*)div:(ORRationalInterval*)ri{
//   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
//   ORRational* one = [ORRational rationalWith_d:1.0];
//   if(![ri.low isZero] && ![ri.up isZero]){
//      z.low = [one div: ri.up];
//      z.up  = [one div: ri.low];
//   } else if(![ri.low isZero] && [ri.up isZero]){
//      [z.low setNegInf];
//      z.up = [one div: ri.low];
//   } else if([ri.low isZero] && ![ri.up isZero]){
//      z.low = [one div: ri.up];
//      [z.up setPosInf];
//   } else {
//      [z.low setNegInf];
//      [z.up setPosInf];
//   }
//   [one release];
//
//   z = [self mul: z];
//
//   return z;
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
      else {                                                /* 0 in B */
         /* ADD 3 new cases for 0 in B */
         if (ri.up.type == 0 && ri.low.type == 0) {
            [z.low setNegInf];
            [z.up setPosInf];
         } else if (ri.low.type == 0) {
            z.low = [_low div: ri.up];
            [z.up setPosInf];
         } else if (ri.up.type == 0){
            [z.low setNegInf];
            z.up = [_low div: ri.low];
         } else {
            [z.low setNegInf];
            [z.up setPosInf];
         }
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
      else {                                               /* 0 in B */
         /* ADD 3 new cases for 0 in B */
         if (ri.up.type == 0 && ri.low.type == 0) {
            [z.low setNegInf];
            [z.up setPosInf];
         } else if (ri.low.type == 0) {
            [z.low setNegInf];
            z.up = [_up div: ri.up];
         } else if (ri.up.type == 0){
            z.low = [_up div: ri.low];
            [z.up setPosInf];
         } else {
            [z.low setNegInf];
            [z.up setPosInf];
         }
      }
   }
   else {                                                /* 0 in A */
      if (ri.low.type > 0) {     /* B >  0 */
         z.low = [_low div: ri.low];
         z.up = [_up div: ri.low];
      }
      else if (ri.up.type < 0) {       /* B <  0 */
         z.low = [_up div: ri.up];
         z.up = [_low div: ri.up];
      }
      else {                                              /* 0 in B */
         [z.low setNegInf];
         [z.up setPosInf];
      }
   }
   return z;
}
-(ORRationalInterval*)neg{
   ORRationalInterval* z = [[ORRationalInterval alloc] init: _low.mt];
   z.low = [_up neg];
   z.up = [_low neg];
   
   return z;
}
-(ORRationalInterval*)abs{
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
   return [_low gt: _up];
}
-(ORRationalInterval*)union:(ORRationalInterval*)ri{
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
-(ORRationalInterval*)intersection:(ORRationalInterval*)ri{
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
-(ORRationalInterval*)proj_inter:(ORRationalInterval*)ri{
   ORRationalInterval* z = [[ORRationalInterval alloc] init:_low.mt];
   [z set: self];
   z.changed = 0;
   
   /* check if DISJOINT */
   if([self.up lt: ri.low] || [ri.up lt: self.low]){
      [z setNAN];
      return z;
   }

   if([self empty] || [ri empty] || [ri.low isNAN] || [ri.up isNAN]){
      [z setNAN];
      return z;
   }
   
   ORRational* plow = [[ORRational alloc] init];
   ORRational* pup = [[ORRational alloc] init];
   ORRational* epsilon = [[ORRational alloc] init];
   
   if([_low lt: ri.low]){
      [z.low set: ri.low];
      z.changed = 1;
   }
   
   if([_up gt: ri.up]){
      [z.up set: ri.up];
      z.changed |= 2;
   }
   
   if([z empty]){
      [z set: self];
      z.changed = 0;
      return z;
   }
   
   if(z.changed){
      int both = 0;
      plow = [[_low sub:z.low] div:_low];
      pup = [[_up sub:z.up] div:_up];
      [epsilon set:5 and:100];
      
      if([plow leq: epsilon]){
         both++;
         [z.low set: _low];
      }
      if([pup leq: epsilon]){
         both++;
         [z.up set: _up];
      }
      if(both == 2)
         z.changed = 0;
   }
   [plow release];
   [pup release];
   [epsilon release];
   return z;
}
-(ORRationalInterval*)proj_inter:(ORRational*)inf and:(ORRational*)sup{
   ORRationalInterval* z = [[ORRationalInterval alloc] init:_low.mt];
   [z set: self];
   z.changed = 0;
   
   /* check if DISJOINT */
   if([self.up lt: inf] || [sup lt: self.low]){
      [z setNAN];
      return z;
   }
   
   if([self empty] || [inf isNAN] || [sup isNAN]){
      [z setNAN];
      return z;
   }
   
   if([_low lt: inf]){
      [z.low set: inf];
      z.changed = 1;
   }
   
   if([_up gt: sup]){
      [z.up set: sup];
      z.changed |= 2;
   }
   
   if([z empty]){
      [z set: self];
      z.changed = 0;
      return z;
   }
   
   if(z.changed){
      ORRational* pup = [[ORRational alloc] init];
      ORRational* plow = [[ORRational alloc] init];
      ORRational* epsilon = [[ORRational alloc] init];
      int both = 0;
      
      plow = [[_low sub: z.low] div: _low];
      pup = [[_up sub: z.up] div: _up];
      [epsilon set:5 and:100];

      if([plow leq: epsilon]){
         both++;
         [z.low set: _low];
      }
      if([pup leq: epsilon]){
         both++;
         [z.up set: _up];
      }
      if(both == 2)
         z.changed = 0;
      
      [plow release];
      [pup release];
      [epsilon release];
   }
   return z;
}
@end
