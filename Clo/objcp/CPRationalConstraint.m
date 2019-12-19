
//
//  CPRationalConstraint.m
//  objcp
//
//  Created by Rémy Garcia on 09/07/2018.
//

#import <ORFoundation/ORFoundation.h>
#import "CPRationalConstraint.h"
#import "CPRationalVarI.h"
#import "CPFloatVarI.h"
#import "ORConstraintI.h"
#import "rationalUtilities.h"

@implementation CPRationalErrorOf
-(id) init:(CPFloatVarI*)x is:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x boundError]) [_x whenChangeBoundsPropagate:self];
   if(![_y bound])      [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x boundError]){
      [_y bind:[_x errorValue]];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if([_y bound]){
      [_x bindError:[_y value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWithQF(_x,_y)){
      failNow();
   }else{
      [_x updateIntervalError:maxQ([_x minErr], [_y min]) and:minQ([_x maxErr], [_y max])];
      [_y updateInterval:maxQ([_x minErr], [_y min]) and:minQ([_x maxErr], [_y max])];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x boundError] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == %@>",[_x domainError],_y];
}
@end

@implementation CPRationalErrorOfD
-(id) init:(CPDoubleVarI*)x is:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x boundError]) [_x whenChangeBoundsPropagate:self];
   if(![_y bound])      [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x boundError]){
      [_y bind:[_x errorValue]];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if([_y bound]){
      [_x bindError:[_y value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWithQD(_x,_y)){
      failNow();
   }else{
      [_x updateIntervalError:maxQ([_x minErr], [_y min]) and:minQ([_x maxErr], [_y max])];
      [_y updateInterval:maxQ([_x minErr], [_y min]) and:minQ([_x maxErr], [_y max])];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x boundError] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == %@>",[_x domainError],_y];
}
@end

@implementation CPRationalUlpOf
-(id) init:(CPFloatVarI*)x is:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
   //if(![_y bound]) [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   id<ORRationalInterval> ulp = [[ORRationalInterval alloc] init];
   float_interval x = makeFloatInterval([_x min], [_x max]);
   id<ORRational> tmp0 = [[ORRational alloc] init];
   id<ORRational> tmp1 = [[ORRational alloc] init];
   id<ORRational> tmp2 = [[ORRational alloc] init];
   
   if(x.inf == -INFINITY || x.sup == INFINITY){
      [tmp1 setNegInf];
      [tmp2 setPosInf];
      [ulp set_q:tmp1 and:tmp2];
   }else if(fabs(x.inf) == DBL_MAX || fabs(x.sup) == DBL_MAX){
      [tmp0 set_d: nextafterf(DBL_MAX, -INFINITY) - DBL_MAX];
      [tmp1 set_d: 2.0];
      tmp2 = [tmp0 div: tmp1];
      [tmp1 set: tmp2];
      [tmp2 neg];
      [ulp set_q:tmp2 and:tmp1];
   } else{
      ORDouble inf, sup;
      inf = minDbl(nextafterf(x.inf, -INFINITY) - x.inf, nextafterf(x.sup, -INFINITY) - x.sup);
      sup = maxDbl(nextafterf(x.inf, +INFINITY) - x.inf, nextafterf(x.sup, +INFINITY) - x.sup);
      
      [tmp0 set_d: inf];
      [tmp1 set_d: 2.0];
      [ulp.low set: [tmp0 div: tmp1]];
      [tmp0 set_d: sup];
      [ulp.up set: [tmp0 div: tmp1]];
   }
   
   [_y updateInterval:ulp.low and:ulp.up];

   [tmp0 release];
   [tmp1 release];
   [tmp2 release];
   [ulp release];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == ulp(%@)>",[_x domain],_y];
}
@end

@implementation CPRationalUlpOfD
-(id) init:(CPDoubleVarI*)x is:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
   //if(![_y bound]) [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   id<ORRationalInterval> ulp = [[ORRationalInterval alloc] init];
   double_interval x = makeDoubleInterval([_x min], [_x max]);
   id<ORRational> tmp0 = [[ORRational alloc] init];
   id<ORRational> tmp1 = [[ORRational alloc] init];
   id<ORRational> tmp2 = [[ORRational alloc] init];
   
   if(x.inf == -INFINITY || x.sup == INFINITY){
      [tmp1 setNegInf];
      [tmp2 setPosInf];
      [ulp set_q:tmp1 and:tmp2];
   }else if(fabs(x.inf) == DBL_MAX || fabs(x.sup) == DBL_MAX){
      [tmp0 set_d: nextafter(DBL_MAX, -INFINITY) - DBL_MAX];
      [tmp1 set_d: 2.0];
      tmp2 = [tmp0 div: tmp1];
      [tmp1 set: tmp2];
      [tmp2 neg];
      [ulp set_q:tmp2 and:tmp1];
   } else{
      ORDouble inf, sup;
      inf = minDbl(nextafter(x.inf, -INFINITY) - x.inf, nextafter(x.sup, -INFINITY) - x.sup);
      sup = maxDbl(nextafter(x.inf, +INFINITY) - x.inf, nextafter(x.sup, +INFINITY) - x.sup);
      
      [tmp0 set_d: inf];
      [tmp1 set_d: 2.0];
      [ulp.low set: [tmp0 div: tmp1]];
      [tmp0 set_d: sup];
      [ulp.up set: [tmp0 div: tmp1]];
   }
   
   [_y updateInterval:ulp.low and:ulp.up];

   [tmp0 release];
   [tmp1 release];
   [tmp2 release];
   [ulp release];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == ulp(%@)>",[_x domain],_y];
}
@end

@implementation CPRationalChannel
-(id) init:(CPFloatVarI*)x with:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
   if(![_y bound]) [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x bound]){
      
      id<ORRational> tmp = [ORRational rationalWith_d:[_x value]];
      [_y bind:tmp];
      [tmp release];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if([_y bound]){
      [_x bind:[[_y value] get_d]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWithQFC(_x,_y)){
      failNow();
   }else{
      id<ORRational> xminRat = [ORRational rationalWith_d:[_x min]];
      id<ORRational> xmaxRat = [ORRational rationalWith_d:[_x max]];
      [_x updateInterval:maxFlt([_x min], [[_y min] get_sup_f]) and:minFlt([_x max], [[_y max] get_inf_f])];
      [_y updateInterval:maxQ(xminRat, [_y min]) and:minQ(xmaxRat, [_y max])];
      [xminRat release];
      [xmaxRat release];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<F:%@ == Q:%@>",[_x domain],_y];
}
@end

@implementation CPRationalChannelD
-(id) init:(CPDoubleVarI*)x with:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
   if(![_y bound]) [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x bound]){
      
      id<ORRational> tmp = [ORRational rationalWith_d:[_x value]];
      [_y bind:tmp];
      [tmp release];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if([_y bound]){
      [_x bind:[[_y value] get_d]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWithQDC(_x,_y)){
      failNow();
   }else{
      id<ORRational> xminRat = [ORRational rationalWith_d:[_x min]];
      id<ORRational> xmaxRat = [ORRational rationalWith_d:[_x max]];
      [_x updateInterval:maxDbl([_x min], [[_y min] get_sup_d]) and:minDbl([_x max], [[_y max] get_inf_d])];
      [_y updateInterval:maxQ(xminRat, [_y min]) and:minQ(xmaxRat, [_y max])];
      [xminRat release];
      [xmaxRat release];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<F:%@ == Q:%@>",[_x domain],_y];
}
@end

@implementation CPRationalEqual
-(id) init:(CPRationalVarI*)x equals:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x bound]){
      [_y bind:[_x value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if([_y bound]){
      [_x bind:[_y value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWithQ(_x,_y)){
      failNow();
   }else{
      [_x updateInterval:maxQ([_x min], [_y min]) and:minQ([_x max], [_y max])];
      [_y updateInterval:maxQ([_x min], [_y min]) and:minQ([_x max], [_y max])];
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == %@>",_x,_y];
}
@end

@implementation CPRationalEqualc
-(id) init:(CPRationalVarI*)x and:(id<ORRational>)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = [ORRational rationalWith:c];
   return self;
}
-(void) dealloc
{
   [_c release];
   [super dealloc];
}
-(void) post
{
   [_x bind:_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == %@>",_x,_c];
}
@end

@implementation CPRationalAssign{
   int _precision;
   int _rounding;
}
-(id) init:(CPRationalVarI*)x set:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([_x bound]){
      [_y bind:[_x value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }else if([_y bound]){
      [_x bind:[_y value]];
      assignTRInt(&_active, NO, _trail);
      return;
   }
   if(isDisjointWithQ(_x,_y)){
      failNow();
   }else{
      [_x updateInterval:maxQ([_x min], [_y min]) and:minQ([_x max], [_y max])];
      [_y updateInterval:maxQ([_x min], [_y min]) and:minQ([_x max], [_y max])];
   }
}
- (void)dealloc
{
   [super dealloc];
}

-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@>",_x,_y];
}
@end

@implementation CPRationalAssignC
-(id) init:(CPRationalVarI*)x set:(id<ORRational>)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
   
}
-(void) dealloc
{
   [_c release];
   [super dealloc];
}
-(void) post
{
   [_x bind:_c];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@>",_x,_c];
}
@end

@implementation CPRationalNEqual
-(id) init:(CPRationalVarI*)x nequals:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
   
}
-(void) post
{
   [self propagate];
   [_x whenBindPropagate:self];
   [_y whenBindPropagate:self];
}
-(void) propagate
{
   /*   if ([_x bound]) {
    if([_y bound]){
    if ([[_x min] eq: [_y min]])
    failNow();
    else{
    if([_x min] == [_y min]){
    [_y updateMin:fp_next_float([_y min])];
    assignTRInt(&_active, NO, _trail);
    }
    if([_x min] == [_y max]) {
    [_y updateMax:fp_previous_float([_y max])];
    assignTRInt(&_active, NO, _trail);
    }
    if([_x max] == [_y min]){
    [_y updateMin:fp_next_float([_y max])];
    assignTRInt(&_active, NO, _trail);
    }
    if([_x max] == [_y max]) {
    [_y updateMax:fp_previous_float([_y max])];
    assignTRInt(&_active, NO, _trail);
    }
    }
    return;
    }
    }else  if([_y bound]){
    if([_x min] == [_y min]){
    [_x updateMin:fp_next_float([_x min])];
    assignTRInt(&_active, NO, _trail);
    }
    if([_x min] == [_y max]) {
    [_x updateMin:fp_next_float([_x min])];
    assignTRInt(&_active, NO, _trail);
    }
    if([_x max] == [_y min]){
    [_x updateMax:fp_previous_float([_x max])];
    assignTRInt(&_active, NO, _trail);
    }
    if([_x max] == [_y max]) {
    [_x updateMax:fp_previous_float([_x max])];
    assignTRInt(&_active, NO, _trail);
    }
    }*/
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ != %@>",_x,_y];
}
@end

@implementation CPRationalNEqualc
-(id) init:(CPRationalVarI*)x and:(id<ORRational>)c
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _c = c;
   return self;
}
-(void) dealloc
{
   [_c release];
   [super dealloc];
}
-(void) post
{
   [self propagate];
   [_x whenBindPropagate:self];
   [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   /*if ([_x bound]) {
      if([_x min] == _c)
         failNow();
   }else{
      if([_x min] == _c){
         [_x updateMin:fp_next_float(_c)];
         assignTRInt(&_active, NO, _trail);
      }
      if([_x max] == _c){
         [_x updateMax:fp_previous_float(_c)];
         assignTRInt(&_active, NO, _trail);
      }
   }*/
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ != %@>",_x,_c];
}
@end

@implementation CPRationalLT
-(id) init:(CPRationalVarI*)x lt:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   [_y whenChangeBoundsPropagate:self];
   [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([[_x min] gt: [_y    max]])
      failNow();
   if(isIntersectingWithQ(_x,_y)){
      if([[_x min] gt: [_y min]]){
         [_y updateMin:[_x min]];
      }
      if([[_x max] gt: [_y max]]){
         [_x updateMax:[_y max]];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ < %@>",_x,_y];
}
@end

@implementation CPRationalGT
-(id) init:(CPRationalVarI*)x gt:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   [_y whenChangeBoundsPropagate:self];
   [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([[_x max] lt: [_y min]])
      failNow();
   if(isIntersectingWithQ(_x,_y)){
      if([[_x min] lt: [_y min]]){
         [_x updateMin:[_y min]];
      }
      if([[_x max] lt: [_y max]]){
         [_y updateMax:[_x max]];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}

-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ > %@>",_x,_y];
}
@end

@implementation CPRationalLEQ
-(id) init:(CPRationalVarI*)x leq:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   [_y whenChangeBoundsPropagate:self];
   [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([[_x min] gt: [_y    max]])
      failNow();
   if(isIntersectingWithQ(_x,_y)){
      if([[_x min] gt: [_y min]]){
         [_y updateMin:[_x min]];
      }
      if([[_x max] gt: [_y max]]){
         [_x updateMax:[_y max]];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ <= %@>",_x,_y];
}
@end

@implementation CPRationalGEQ
-(id) init:(CPRationalVarI*)x geq:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   [_y whenChangeBoundsPropagate:self];
   [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   if([[_x max] lt: [_y min]])
      failNow();
   if(isIntersectingWithQ(_x,_y)){
      if([[_x min] lt: [_y min]]){
         [_x updateMin:[_y min]];
      }
      if([[_x max] lt: [_y max]]){
         [_y updateMax:[_x max]];
      }
   }
   if([_x bound] || [_y bound]){
      assignTRInt(&_active, NO, _trail);
      return;
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ >= %@>",_x,_y];
}
@end


@implementation CPRationalTernaryAdd{
   
}
-(id) init:(CPRationalVarI*)z equals:(CPRationalVarI*)x plus:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound]) [_x whenChangeBoundsPropagate:self];
   if(![_y bound]) [_y whenChangeBoundsPropagate:self];
   if(![_z bound]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   id<ORRationalInterval> zTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> yTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> xTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> z = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> x = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> y = [[ORRationalInterval alloc] init];
   
   [x set_q: [_x min] and:[_x max]];
   [y set_q: [_y min] and:[_y max]];
   [z set_q: [_z min] and:[_z max]];
   
   @autoreleasepool {
      do {
         changed = false;
         // ============================== z
         // x + y
         [zTemp set: [x add: y]];
         
         [z set: [z proj_inter: zTemp]];
         changed |= z.changed;
         
         if([z empty]){
            gchanged |= true;
            break;
         }
         
         // ============================== x
         // z - y
         [xTemp set: [z sub: y]];
         
         [x set: [x proj_inter: xTemp]];
         changed |= x.changed;
         
         if([x empty]){
            gchanged |= true;
            break;
         }
         
         // ============================== y
         // z - x
         [yTemp set: [z sub: x]];
         
         [y set: [y proj_inter: yTemp]];
         changed |= y.changed;
         
         if([y empty]){
            gchanged |= true;
            break;
         }
         
         gchanged |= changed;
      } while(changed);
   }
   
   if(gchanged){
      [_x updateInterval:x.low and:x.up];
      [_y updateInterval:y.low and:y.up];
      [_z updateInterval:z.low and:z.up];
      if([_x bound] && [_y bound] && [_z bound])
         assignTRInt(&_active, NO, _trail);
   }
   
   [x release];
   [y release];
   [z release];
   [xTemp release];
   [yTemp release];
   [zTemp release];
}
- (void)dealloc {
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ + %@>",_z, _x, _y];
}
@end

@implementation CPRationalTernarySub{
   
}
-(id) init:(CPRationalVarI*)z equals:(CPRationalVarI*)x minus:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
   if (![_z bound]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   
   id<ORRationalInterval> zTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> yTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> xTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> z = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> x = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> y = [[ORRationalInterval alloc] init];
   
   [x set_q: [_x min] and:[_x max]];
   [y set_q: [_y min] and:[_y max]];
   [z set_q: [_z min] and:[_z max]];
   
   @autoreleasepool {
      do {
         changed = false;
         
         // ============================== z
         // x - y
         [zTemp set: [x sub: y]];
         
         [z set: [z proj_inter: zTemp]];
         changed |= z.changed;
         
         if([z empty]){
            gchanged |= true;
            break;
         }
         
         // ============================== x
         // z + y
         [xTemp set: [z add: y]];
         
         [x set: [x proj_inter: xTemp]];
         changed |= x.changed;
         
         if([x empty]){
            gchanged |= true;
            break;
         }
         
         // ============================== y
         // x - z
         [yTemp set: [x sub: z]];
         
         [y set: [y proj_inter: yTemp]];
         changed |= y.changed;
         
         if([y empty]){
            gchanged |= true;
            break;
         }
         
         gchanged |= changed;
      } while(changed);
   }
   
   if(gchanged){
      
      [_x updateInterval:x.low and:x.up];
      [_y updateInterval:y.low and:y.up];
      [_z updateInterval:z.low and:z.up];
      if([_x bound] && [_y bound] && [_z bound])
         assignTRInt(&_active, NO, _trail);
   }
   [x release];
   [y release];
   [z release];
   [xTemp release];
   [yTemp release];
   [zTemp release];
}
- (void)dealloc {
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ - %@>",_z, _x, _y];
}
@end

@implementation CPRationalTernaryMult{
   
}
-(id) init:(CPRationalVarI*)z equals:(CPRationalVarI*)x mult:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
   if (![_z bound]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   
   id<ORRationalInterval> zTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> yTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> xTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> z = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> x = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> y = [[ORRationalInterval alloc] init];
   
   [x set_q: [_x min] and:[_x max]];
   [y set_q: [_y min] and:[_y max]];
   [z set_q: [_z min] and:[_z max]];
   
   @autoreleasepool {
      do {
         changed = false;
         
         // ============================== z
         // x * y
         [zTemp set: [x mul: y]];
         
         [z set: [z proj_inter: zTemp]];
         changed |= z.changed;
         
         if([z empty]){
            gchanged |= true;
            break;
         }
         
         // ============================== x
         // z + y
         [xTemp set: [z div: y]];
         
         [x set: [x proj_inter: xTemp]];
         changed |= x.changed;
         
         if([x empty]){
            gchanged |= true;
            break;
         }
         
         // ============================== y
         // x - z
         [yTemp set: [z div: x]];
         
         [y set: [y proj_inter: yTemp]];
         changed |= y.changed;
         
         if([y empty]){
            gchanged |= true;
            break;
         }
         
         gchanged |= changed;
      } while(changed);
   }
   
   if(gchanged){
      
      [_x updateInterval:x.low and:x.up];
      [_y updateInterval:y.low and:y.up];
      [_z updateInterval:z.low and:z.up];
      if([_x bound] && [_y bound] && [_z bound])
         assignTRInt(&_active, NO, _trail);
   }
   [x release];
   [y release];
   [z release];
   [xTemp release];
   [yTemp release];
   [zTemp release];
}
- (void)dealloc {
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ - %@>",_z, _x, _y];
}
@end

@implementation CPRationalTernaryDiv{
   
}
-(id) init:(CPRationalVarI*)z equals:(CPRationalVarI*)x div:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _z = z;
   _x = x;
   _y = y;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
   if (![_z bound]) [_z whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   int gchanged,changed;
   changed = gchanged = false;
   
   id<ORRationalInterval> zTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> yTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> xTemp = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> z = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> x = [[ORRationalInterval alloc] init];
   id<ORRationalInterval> y = [[ORRationalInterval alloc] init];
   
   [x set_q: [_x min] and:[_x max]];
   [y set_q: [_y min] and:[_y max]];
   [z set_q: [_z min] and:[_z max]];
   
   @autoreleasepool {
      do {
         changed = false;
         
         // ============================== z
         // x / y
         [zTemp set: [x div: y]];
         
         [z set: [z proj_inter: zTemp]];
         changed |= z.changed;
         
         if([z empty]){
            gchanged |= true;
            break;
         }
         
         // ============================== x
         // z * y
         [xTemp set: [z mul: y]];
         
         [x set: [x proj_inter: xTemp]];
         changed |= x.changed;
         
         if([x empty]){
            gchanged |= true;
            break;
         }
         
         // ============================== y
         // x - z
         [yTemp set: [x div: z]];
         
         [y set: [y proj_inter: yTemp]];
         changed |= y.changed;
         
         if([y empty]){
            gchanged |= true;
            break;
         }
         
         gchanged |= changed;
      } while(changed);
   }
   
   if(gchanged){
      
      [_x updateInterval:x.low and:x.up];
      [_y updateInterval:y.low and:y.up];
      [_z updateInterval:z.low and:z.up];
      if([_x bound] && [_y bound] && [_z bound])
         assignTRInt(&_active, NO, _trail);
   }
   [x release];
   [y release];
   [z release];
   [xTemp release];
   [yTemp release];
   [zTemp release];
}
- (void)dealloc {
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_z,_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ = %@ - %@>",_z, _x, _y];
}
@end


@implementation CPRationalVarMinimize
{
   CPRationalVarI*  _x;
   id<ORRational>       _primalBound;
   id<ORRational>       _dualBound;
   ORInt nbPrimalUpdate;
   ORInt nbDualUpdate;
}
-(CPRationalVarMinimize*) init: (CPRationalVarI*) x
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _primalBound = [[ORRational alloc] init];
   _dualBound = [[ORRational alloc] init];
   [_primalBound set: [_x max]];
   [_dualBound setNegInf];
   nbPrimalUpdate = 0;
   nbDualUpdate = 0;
   
   return self;
}
- (void)dealloc {
   [_primalBound release];
   [_dualBound release];
   [super dealloc];
}
-(id<CPRationalVar>)var
{
   return _x;
}
-(ORBool) isMinimization
{
   return YES;
}
-(void) post
{
   if (![_x bound])
      [_x whenChangeMinDo: ^ {
         [_x updateMax: _primalBound];
      } onBehalf:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(id<ORObjectiveValue>) primalValue
{
   return [ORFactory objectiveValueRational:_x.value minimize:YES];
}
-(id<ORObjectiveValue>) dualValue
{
   return [ORFactory objectiveValueRational:_x.min minimize:NO];
}
-(id<ORObjectiveValue>) primalBound
{
   return [ORFactory objectiveValueRational:_primalBound minimize:YES];
}
-(id<ORObjectiveValue>) dualBound
{
   return [ORFactory objectiveValueRational:_dualBound minimize:YES];
}
-(ORUInt)nbUVars
{
   return [_x bound] ? 0 : 1;
}
-(void) updatePrimalBound
{
   id<ORRational>bound = [[ORRational alloc] init];
   [bound set: [_x max]]; // cpjm: always set to min to avoid overestimation of Primal
   if ([bound lt: _primalBound]){
      nbPrimalUpdate++;
      [_primalBound set: bound];
      branchAndBoundTime = [NSDate date];
      NSLog(@"PBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound,[branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbPrimalUpdate);
   }
   [bound release];
}
-(void) updateDualBound
{
   id<ORRational>bound = [[ORRational alloc] init];
   [bound set: [_x min]];
   if ([bound gt: _dualBound] && [bound lt: boundDiscardedBoxes]){
      nbDualUpdate++;
      [_dualBound set: bound];
      branchAndBoundTime = [NSDate date];
      NSLog(@"DBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbDualUpdate);
   }
   [bound release];
}
-(void) tightenPrimalBound: (id<ORObjectiveValueRational>) newBound
{
   if ([[newBound value] lt: _primalBound]){
      nbPrimalUpdate++;
      [_primalBound set: [newBound value]];
      branchAndBoundTime = [NSDate date];
      NSLog(@"PBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound,[branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbPrimalUpdate);
   }
}
-(ORStatus) tightenDualBound:(id<ORObjectiveValueRational>)newBound
{
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueRational)]) {
      id<ORRational> b = [(id<ORObjectiveValueRational>) newBound value];
      ORStatus ok = [b gt: _primalBound] ? ORFailure : ORSuspend;
      if (ok && [b gt: _dualBound] && [b gt: boundDiscardedBoxes]){
         [_dualBound set: b];
         [b release];
         nbDualUpdate++;
         branchAndBoundTime = [NSDate date];
         NSLog(@"DBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbDualUpdate);
      }
      return ok;
   } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
      id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueInt>)newBound value]];
      ORStatus ok = [b gt: _primalBound] ? ORFailure : ORSuspend;
      if (ok && [b gt: _dualBound] && [b gt: boundDiscardedBoxes]){
         [_dualBound set: b];
         [b release];
         nbDualUpdate++;
         branchAndBoundTime = [NSDate date];
         NSLog(@"DBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbDualUpdate);
      }
      return ok;
   } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
      id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueFloat>)newBound floatValue]];
      ORStatus ok = [b gt: _primalBound] ? ORFailure : ORSuspend;
      if (ok && [b gt: _dualBound] && [b gt: boundDiscardedBoxes]){
         [_dualBound set: b];
         [b release];
         nbDualUpdate++;
         branchAndBoundTime = [NSDate date];
         NSLog(@"DBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbDualUpdate);
      }
      return ok;
   } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
      id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueReal>)newBound doubleValue]];
      ORStatus ok = [b gt: _primalBound] ? ORFailure : ORSuspend;
      if (ok && [b gt: _dualBound] && [b gt: boundDiscardedBoxes]){
         [_dualBound set: b];
         [b release];
         nbDualUpdate++;
         branchAndBoundTime = [NSDate date];
         NSLog(@"DBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbDualUpdate);
      }
   }
   return ORSuspend;
}
-(void) tightenLocallyWithDualBound: (id) newBound
{
   @synchronized(self) {
      if ([newBound conformsToProtocol:@protocol(ORObjectiveValueRational)]) {
         id<ORRational> b = [((id<ORObjectiveValueRational>) newBound) value];
         [_x updateMin: b];
         [b release];
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
         id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueInt>) newBound) value]];
         [_x updateMin: b];
         [b release];
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
         id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueFloat>) newBound) value]];
         [_x updateMin: b];
         [b release];
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
         id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueReal>) newBound) value]];
         [_x updateMin: b];
         [b release];
      }
   }
}
-(ORStatus) check
{
   return tryfail(^ORStatus{
      [_x updateMax:_primalBound];
      [_x updateMin:_dualBound];
      return ORSuspend;
   }, ^ORStatus{
      return ORFailure;
   });
}
-(ORBool)   isBound
{
   return [_x bound];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"MINIMIZE(%@) with f* = %@  (dual: %@) [thread: %d]",[_x description],_primalBound,_dualBound,[NSThread threadID]];
   return buf;
}
@end

@implementation CPRationalVarMaximize
{
   CPRationalVarI*  _x;
   id<ORRational>   _primalBound;
   id<ORRational>   _dualBound;
   ORInt nbPrimalUpdate;
   ORInt nbDualUpdate;
}

-(CPRationalVarMaximize*) init: (CPRationalVarI*) x
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _primalBound = [[ORRational alloc] init];
   _dualBound = [[ORRational alloc] init];
   [_primalBound setNegInf];
   [_dualBound set: [_x max]];
   nbPrimalUpdate = 0;
   nbDualUpdate = 0;
   
   return self;
}
- (void)dealloc {
   [_primalBound release];
   [_dualBound release];
   [super dealloc];
}
-(id<CPRationalVar>)var
{
   return _x;
}
-(ORBool)   isMinimization
{
   return NO;
}
-(void) post
{
   if (![_x bound])
      [_x whenChangeMaxDo: ^ {
         [_x updateMin: _primalBound];
      } onBehalf:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(id<ORObjectiveValue>) primalValue
{
   return [ORFactory objectiveValueRational:_x.value minimize:NO];
}
-(id<ORObjectiveValue>) dualValue
{
   return [ORFactory objectiveValueRational:_x.max minimize:YES];
}

-(id<ORObjectiveValue>) primalBound
{
   return [ORFactory objectiveValueRational:_primalBound minimize:NO];
}
-(id<ORObjectiveValue>) dualBound
{
   return [ORFactory objectiveValueRational:_dualBound minimize:NO];
}
-(ORUInt)nbUVars
{
   return [_x bound] ? 0 : 1;
}
-(void) updatePrimalBound
{
   id<ORRational>bound = [[ORRational alloc] init];
   [bound set: [_x min]]; // cpjm: always set to min to avoid overestimation of Primal
   if ([bound gt: _primalBound]){
      nbPrimalUpdate++;
      [_primalBound set: bound];
      branchAndBoundTime = [NSDate date];
      NSLog(@"PBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound,[branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbPrimalUpdate);
   }
   [bound release];
}
-(void) updateDualBound
{
   id<ORRational>bound = [[ORRational alloc] init];
   [bound set: [_x max]];
   if ([bound lt: _dualBound] && [bound gt: boundDiscardedBoxes]){
      nbDualUpdate++;
      [_dualBound set: bound];
      branchAndBoundTime = [NSDate date];
      NSLog(@"DBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbDualUpdate);
   }
   [bound release];
}

-(void) tightenPrimalBound: (id<ORObjectiveValueRational>) newBound
{
   if ([[newBound value] gt: _primalBound]){
      nbPrimalUpdate++;
      [_primalBound set: [newBound value]];
      branchAndBoundTime = [NSDate date];
      NSLog(@"PBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound,[branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbPrimalUpdate);
   }
}

-(ORStatus) tightenDualBound:(id<ORObjectiveValue>)newBound
{
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueRational)]) {
      id<ORRational> b = [(id<ORObjectiveValueRational>) newBound value];
      ORStatus ok = [b lt: _primalBound] ? ORFailure : ORSuspend;
      if (ok && [b lt: _dualBound] && [b gt: boundDiscardedBoxes]){
         [_dualBound set: b];
         [b release];
         nbDualUpdate++;
         branchAndBoundTime = [NSDate date];
         NSLog(@"DBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbDualUpdate);
      }
      return ok;
   } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
      id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueInt>)newBound value]];
      ORStatus ok = [b lt: _primalBound] ? ORFailure : ORSuspend;
      if (ok && [b lt: _dualBound] && [b gt: boundDiscardedBoxes]){
         [_dualBound set: b];
         [b release];
         nbDualUpdate++;
         branchAndBoundTime = [NSDate date];
         NSLog(@"DBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbDualUpdate);
      }
      return ok;
   } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
      id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueFloat>)newBound floatValue]];
      ORStatus ok = [b lt: _primalBound] ? ORFailure : ORSuspend;
      if (ok && [b lt: _dualBound] && [b gt: boundDiscardedBoxes]){
         [_dualBound set: b];
         [b release];
         nbDualUpdate++;
         branchAndBoundTime = [NSDate date];
         NSLog(@"DBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbDualUpdate);
      }
      return ok;
   } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
      id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueReal>)newBound doubleValue]];
      ORStatus ok = [b lt: _primalBound] ? ORFailure : ORSuspend;
      if (ok && [b lt: _dualBound] && [b gt: boundDiscardedBoxes]){
         [_dualBound set: b];
         [b release];
         nbDualUpdate++;
         branchAndBoundTime = [NSDate date];
         NSLog(@"DBOUND: [%@,%@] -- %.3fs (%d)", _primalBound, _dualBound, [branchAndBoundTime timeIntervalSinceDate:branchAndBoundStart], nbDualUpdate);
      }
   }
   return ORSuspend;
}

-(void) tightenLocallyWithDualBound: (id) newBound
{
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueRational)]) {
      id<ORRational> b = [((id<ORObjectiveValueRational>) newBound) value];
      [_x updateMax: b];
      [b release];
   }
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
      id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueInt>) newBound) value]];
      [_x updateMax: b];
      [b release];
   }
   else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
      id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueFloat>) newBound) value]];
      [_x updateMax: b];
      [b release];
   }
   else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
      id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueReal>) newBound) value]];
      [_x updateMax: b];
      [b release];
   }
}

-(ORStatus) check
{
   @try {
      [_x updateMin:_primalBound];
   }
   @catch (ORFailException* e) {
      [e release];
      return ORFailure;
   }
   return ORSuspend;
}

-(ORBool)   isBound
{
   return [_x bound];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"MAXIMIZE(%@) with f* = %@  (dual: %@) [thread: %d]",[_x description],_primalBound,_dualBound,[NSThread threadID]];
   return buf;
}
@end

@implementation CPRationalAbs{
   id<ORRationalInterval> _xi;
   id<ORRationalInterval> _resi;
}
-(id) init:(CPRationalVarI*)res eq:(CPRationalVarI*)x //res = |x|
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _res = res;
   _xi = [[ORRationalInterval alloc] init];
   [_xi set_q:[x min] and:[x max]];
   _resi = [[ORRationalInterval alloc] init];
   [_resi set_q:[res min] and:[res max]];
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_res bound])  [_res whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   @autoreleasepool {
      if([_x bound]){
         if([_res bound]){
            if(([[_res value] neq:  [[_x value] neg]]) && ([[_res value] neq: [_x value]])) failNow();
            assignTRInt(&_active, NO, _trail);
         }else{
            [_res bind:[[_x value] abs]];
            assignTRInt(&_active, NO, _trail);
         }
      }else if([_res bound]){
         if([_x member:[[_res value] neg]]){
            if([_x member:[_res value]])
               [_x updateInterval:[[_res value] neg] and:[_res value]];
            else
               [_x bind:[[_res value] neg]];
         }else if([_x member:[_res value]])
            [_x bind:[_res value]];
         else
            failNow();
      }else {
         id<ORRational> zero = [[ORRational alloc] init];
         [zero setZero];
         [_xi set_q:[_x min] and:[_x max]];
         [_resi set_q:[_res min] and:[_res max]];
         id<ORRationalInterval> resTmp = [[ORRationalInterval alloc] init];
         if([_x member: zero]){
            [resTmp.low set:zero];
         } else {
            [resTmp.low set: minQ([_xi.low abs], [_xi.up abs])];
         }
         [resTmp.up set: maxQ([_xi.low abs], [_xi.up abs])];
         [_resi set: [_resi proj_inter: resTmp]];
         if(_resi.changed)
            [_res updateInterval:_resi.low and:_resi.up];
         
         [_xi set_q:[_x min] and:[_x max]];
         id<ORRationalInterval> xTmp = [[ORRationalInterval alloc] init];
         if([_x member: zero]){
            [xTmp.low set: [_resi.up neg]];
            [xTmp.up set: _resi.up];
         } else if([[_x min] gt: zero]){
            [xTmp.low set: _resi.low];
            [xTmp.up set: _resi.up];
         } else {
            [xTmp.low set: [_resi.up neg]];
            [xTmp.up set: [_resi.low neg]];
         }
         [_xi set: [_xi proj_inter: xTmp]];
         if(_xi.changed)
            [_x updateInterval:_xi.low and:_xi.up];
         [zero release];
         [resTmp release];
         [xTmp release];
      }
   }
}
- (void)dealloc {
   [_xi release];
   [_resi release];
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_res,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_res bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == |%@|>",_res,_x];
}
@end

@implementation CPRationalUnaryMinus{
   int _precision;
   int _rounding;
   id<ORRationalInterval> _xi;
   id<ORRationalInterval> _yi;
}
-(id) init:(CPRationalVarI*)x eqm:(CPRationalVarI*)y
{
   self = [super initCPCoreConstraint: [x engine]];
   _x = x;
   _y = y;
   _xi = [[ORRationalInterval alloc] init];
   [_xi set_q:[x min] and:[x max]];
   _yi = [[ORRationalInterval alloc] init];
   [_yi set_q:[y min] and:[y max]];
   _precision = 1;
   _rounding = FE_TONEAREST;
   return self;
}
-(void) post
{
   [self propagate];
   if(![_x bound])  [_x whenChangeBoundsPropagate:self];
   if(![_y bound])  [_y whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   @autoreleasepool {
      if([_x bound]){
         if([_y bound]){
            if([[_x value] neq: [[_y value] neg]]) failNow();
            assignTRInt(&_active, NO, _trail);
         }else{
            [_y bind:[[_x value] neg]];
            assignTRInt(&_active, NO, _trail);
         }
      }else if([_y bound]){
         [_x bind:[[_y value] neg]];
         assignTRInt(&_active, NO, _trail);
      }else {
         [_xi set_q:[_x min] and:[_x max]];
         [_yi set_q:[_y min] and:[_y max]];
         id<ORRationalInterval> inter = [[ORRationalInterval alloc] init];
         
         
         [inter set: [_yi proj_inter:[_xi neg]]];
         if(inter.changed)
            [_y updateInterval:inter.low and:inter.up];
         
         [_yi set_q:[_y min] and:[_y max]];
         [inter set: [_xi proj_inter:[_yi neg]]];
         if(inter.changed)
            [_x updateInterval:inter.low and:inter.up];
         
         [inter release];
      }
   }
}

-(void) dealloc
{
   [_xi release];
   [_yi release];
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(NSArray*)allVarsArray
{
   return [[[NSArray alloc] initWithObjects:_x,_y,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound];
}
-(NSString*)description
{
   return [NSString stringWithFormat:@"<%@ == -%@>",_x,_y];
}
@end
