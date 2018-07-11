//
//  rationalUtilities.h
//  Clo
//
//  Created by remy on 05/04/2018.
//
//

//#import <ORFoundation/ORTrail.h>
#include "gmp.h"

@protocol ORMemoryTrail;

@protocol ORRational<NSObject>
-(mpq_t*)rational;
-(int)type;
-(void)setType:(int)type;
-(id<ORMemoryTrail>)mt;
-(void)setNAN;
-(void)setZero;
-(void)setOne;
-(void)setPosInf;
-(void)setNegInf;
-(BOOL)isNAN;
-(BOOL)isZero;
-(BOOL)isOne;
-(BOOL)isMinusOne;
-(BOOL)isPosInf;
-(BOOL)isNegInf;
-(id)set:(id<ORRational>)r;
-(id)set_d:(double)d;
-(id)set:(int)num and:(int)den;
-(id<ORRational>)add:(id<ORRational>)r;
-(id<ORRational>)sub:(id<ORRational>)r;
-(id<ORRational>)mul:(id<ORRational>)r;
-(id<ORRational>)div:(id<ORRational>)r;
-(id<ORRational>)neg;
-(id<ORRational>)abs;
-(BOOL)cmp:(id<ORRational>)r;
-(BOOL)cmp:(long int)num and:(long int)den;
-(BOOL)lt:(id<ORRational>)r;
-(BOOL)gt:(id<ORRational>)r;
-(BOOL)leq:(id<ORRational>)r;
-(BOOL)geq:(id<ORRational>)r;
-(BOOL)eq:(id<ORRational>)r;
-(BOOL)neq:(id<ORRational>)r;
@end

@protocol ORRationalInterval
-(id<ORRational>)low;
-(id<ORRational>)up;
-(void)setLow:(id<ORRational>)l;
-(void)setUp:(id<ORRational>)u;
-(int)changed;
-(void)setChanged:(int)c;
-(BOOL)empty;
-(void)setNAN;
-(void)setZero;
-(void)setPosInf;
-(void)setNegInf;
@end

@interface ORRational : NSObject <ORRational> {
   mpq_t _rational;
   /* type :
    -2   -INFINITY
    -1   Negative number
    0   Zero
    1   Positive number
    2   INFINITY
    3   NaN
    */
   int _type;
   id<ORMemoryTrail> _mt;
}
-(id)init:(id<ORMemoryTrail>) mt;
-(id)init;
-(void)dealloc;  // call clear
-(void)print;
-(mpq_ptr)rational;
-(int)type;
-(id<ORMemoryTrail>)mt;
-(void)setNAN;
-(void)setZero;
-(void)setOne;
-(void)setPosInf;
-(void)setNegInf;
-(BOOL)isNAN;
-(BOOL)isZero;
-(BOOL)isOne;
-(BOOL)isMinusOne;
-(BOOL)isPosInf;
-(BOOL)isNegInf;
-(void)setType:(int)type;
-(void)setRational:(mpq_t*)rational;
-(id)set:(id<ORRational>)r;
-(id)set_d:(double)d;
-(id)set:(int)num and:(int)den;
-(id<ORRational>)get;
-(char*)get_str;
-(double)get_d;
-(id<ORRational>)add:(id<ORRational>)r;
-(id<ORRational>)sub:(id<ORRational>)r;
-(id<ORRational>)mul:(id<ORRational>)r;
-(id<ORRational>)div:(id<ORRational>)r;
-(id<ORRational>)neg;
-(id<ORRational>)abs;
-(BOOL)cmp:(id<ORRational>)r;
-(BOOL)cmp:(long int)num and:(long int)den;
-(BOOL)lt:(id<ORRational>)r;
-(BOOL)gt:(id<ORRational>)r;
-(BOOL)leq:(id<ORRational>)r;
-(BOOL)geq:(id<ORRational>)r;
-(BOOL)eq:(id<ORRational>)r;
-(BOOL)neq:(id<ORRational>)r;
@end

@interface ORRationalInterval : NSObject <ORRationalInterval> {
   id<ORRational> _low;
   id<ORRational> _up;
   int _changed;
}
-(id)init:(id<ORMemoryTrail>) mt;
-(void)dealloc;  // call clear
-(id<ORRational>)low;
-(id<ORRational>)up;
-(void)setLow:(id<ORRational>)l;
-(void)setUp:(id<ORRational>)u;
-(int)changed;
-(void)setChanged:(int)c;
-(id)set:(id<ORRationalInterval>)ri;
-(id)set_d:(double)low and:(double)up;
-(id)set_q:(id<ORRational>)low and:(id<ORRational>)up;
-(void)setNAN;
-(void)setZero;
-(void)setPosInf;
-(void)setNegInf;
-(id<ORRationalInterval>)add:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)sub:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)mul:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)div:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)neg;
-(id<ORRationalInterval>)abs;
-(BOOL)cmp:(id<ORRationalInterval>)ri;
-(BOOL)lt:(id<ORRationalInterval>)ri;
-(BOOL)gt:(id<ORRationalInterval>)ri;
-(BOOL)leq:(id<ORRationalInterval>)ri;
-(BOOL)geq:(id<ORRationalInterval>)ri;
-(BOOL)eq:(id<ORRationalInterval>)ri;
-(BOOL)neq:(id<ORRationalInterval>)ri;
-(BOOL)empty;
-(id<ORRationalInterval>)union:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)intersection:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)proj_inter:(id<ORRationalInterval>)ri;
-(id<ORRationalInterval>)proj_inter:(id<ORRational>)inf and:(id<ORRational>)sup;
@end

/*id<ORRational> a = [x add: y.min];
[mt track:a];*/

static inline ORRational* minQ(ORRational* a,ORRational* b) { return [a lt: b] ? a : b;}
static inline ORRational* maxQ(ORRational* a,ORRational* b) { return [a gt: b] ? a : b;}
