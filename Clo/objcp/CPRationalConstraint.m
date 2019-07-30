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
-(void) post
{
   [self propagate];
   [_x whenBindPropagate:self];
   [_x whenChangeBoundsPropagate:self];
}
-(void) propagate
{
   /*   if ([_x bound]) {
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
   
   do {
      changed = false;
      // ============================== ez
      // ex + ey
      zTemp = [x add: y];
      
      z = [z proj_inter: zTemp];
      changed |= z.changed;
      
      if([z empty]){
         gchanged |= true;
         break;
      }
      
      // ============================== ex
      // ez - ey
      xTemp = [z sub: y];
      
      x = [x proj_inter: xTemp];
      changed |= x.changed;
      
      if([x empty]){
         gchanged |= true;
         break;
      }
      
      // ============================== ey
      // ez - ex
      yTemp = [z sub: x];
      
      y = [y proj_inter: yTemp];
      changed |= y.changed;
      
      if([y empty]){
         gchanged |= true;
         break;
      }
      
      gchanged |= changed;
   } while(changed);
   
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
   
   do {
      changed = false;
      
      // ============================== ez
      // ex - ey
      zTemp = [x sub: y];
      
      z = [z proj_inter: zTemp];
      changed |= z.changed;
      
      if([z empty]){
         gchanged |= true;
         break;
      }
      
      // ============================== ex
      // ez + ey
      xTemp = [z add: y];
      
      x = [x proj_inter: xTemp];
      changed |= x.changed;
      
      if([x empty]){
         gchanged |= true;
         break;
      }
      
      // ============================== ey
      // ex - ez
      yTemp = [x sub: z];
      
      y = [y proj_inter: yTemp];
      changed |= y.changed;
      
      if([y empty]){
         gchanged |= true;
         break;
      }
      
      gchanged |= changed;
   } while(changed);
   
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
   
   do {
      changed = false;
      
      // ============================== ez
      // ex * ey
      zTemp = [x mul: y];
      
      z = [z proj_inter: zTemp];
      changed |= z.changed;
      
      if([z empty]){
         gchanged |= true;
         break;
      }
      
      // ============================== ex
      // ez + ey
      xTemp = [z div: y];
      
      x = [x proj_inter: xTemp];
      changed |= x.changed;
      
      if([x empty]){
         gchanged |= true;
         break;
      }
      
      // ============================== ey
      // ex - ez
      yTemp = [z div: x];
      
      y = [y proj_inter: yTemp];
      changed |= y.changed;
      
      if([y empty]){
         gchanged |= true;
         break;
      }
      
      gchanged |= changed;
   } while(changed);
   
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
   
   do {
      changed = false;
      
      // ============================== ez
      // ex / ey
      zTemp = [x div: y];
      
      z = [z proj_inter: zTemp];
      changed |= z.changed;
      
      if([z empty]){
         gchanged |= true;
         break;
      }
      
      // ============================== ex
      // ez * ey
      xTemp = [z mul: y];
      
      x = [x proj_inter: xTemp];
      changed |= x.changed;
      
      if([x empty]){
         gchanged |= true;
         break;
      }
      
      // ============================== ey
      // ex - ez
      yTemp = [x div: z];
      
      y = [y proj_inter: yTemp];
      changed |= y.changed;
      
      if([y empty]){
         gchanged |= true;
         break;
      }
      
      gchanged |= changed;
   } while(changed);
   
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
}
-(CPRationalVarMinimize*) init: (CPRationalVarI*) x
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _primalBound = [ORRational rationalWith:[x max]];
   _dualBound = [ORRational rationalWith:[x min]];
   return self;
}
- (void)dealloc {
   [super dealloc];
   [_primalBound release];
   [_dualBound release];
}
-(id<CPRationalVar>)var
{
   return _x;
}
-(void) post
{
   if (![_x bound])
      [_x whenChangeMinDo: ^ {
         //[_x updateMax: nextafterf(_primalBound,-INFINITY)];
         [_x updateMax: [_primalBound sub: [ORRational rationalWith_d:1]]];
      } onBehalf:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
-(ORUInt)nbUVars
{
   return [_x bound] ? 0 : 1;
}
-(ORBool)   isMinimization
{
   return YES;
}
-(void) updatePrimalBound
{
   id<ORRational> bound = [_x min];
   @synchronized(self) {
      if ([bound lt: _primalBound]){
         //_primalBound = nextafterf(bound,-INFINITY);
         _primalBound = [bound sub: [ORRational rationalWith_d:1]];
         NSLog(@"primal bound: %@",_primalBound);
      }
   }
}
-(void) updateDualBound
{
   id<ORRational> bound = [_x min];
   @synchronized (self) {
      if ([bound gt: _dualBound]){
         [_dualBound set: bound];
         NSLog(@"dual bound: %@",_dualBound);
      }
   }
}
-(void) tightenPrimalBound: (id<ORObjectiveValueRational>) newBound
{
   @synchronized(self) {
      if ([[newBound value] lt: _primalBound])
         _primalBound = [newBound value];
   }
}
-(ORStatus) tightenDualBound:(id<ORObjectiveValueRational>)newBound
{
   @synchronized (self) {
      if ([newBound conformsToProtocol:@protocol(ORObjectiveValueRational)]) {
         id<ORRational> b = [(id<ORObjectiveValueRational>)newBound value];
         ORStatus ok = [b gt: _primalBound] ? ORFailure : ORSuspend;
         if (ok && [b gt: _dualBound])
            _dualBound = b;
         return ok;
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
         id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueInt>)newBound value]];
         ORStatus ok = [b gt: _primalBound] ? ORFailure : ORSuspend;
         if (ok && [b gt: _dualBound])
            _dualBound = b;
         return ok;
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
         id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueFloat>)newBound value]];
         ORStatus ok = [b gt: _primalBound] ? ORFailure : ORSuspend;
         if (ok && [b gt: _dualBound])
            _dualBound = b;
         return ok;
      } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
         id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueReal>)newBound doubleValue]];
         ORStatus ok = [b gt: _primalBound] ? ORFailure : ORSuspend;
         if (ok && [b gt: _dualBound])
            _dualBound = b;
         return ok;
      } else return ORFailure;
   }
}
-(void) tightenLocallyWithDualBound: (id) newBound
{
   @synchronized(self) {
      if ([newBound conformsToProtocol:@protocol(ORObjectiveValueRational)]) {
         id<ORRational> b = [((id<ORObjectiveValueRational>) newBound) value];
         [_x updateMin: b];
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
         id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueInt>) newBound) value]];
         [_x updateMin: b];
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
         id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueFloat>) newBound) value]];
         [_x updateMin: b];
      }
      else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
         id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueReal>) newBound) value]];
         [_x updateMin: b];
      }
   }
}

-(id<ORObjectiveValue>) primalValue
{
   return [ORFactory objectiveValueRational:[_x value] minimize:YES];
}
-(id<ORObjectiveValue>) dualValue
{
   return [ORFactory objectiveValueRational:[_x min] minimize:NO];
   // dual bound ordering is opposite of primal bound. (if we minimize in primal, we maximize in dual).
}
-(id<ORObjectiveValue>) primalBound
{
   return [ORFactory objectiveValueRational:_primalBound minimize:YES];
}
-(id<ORObjectiveValue>) dualBound
{
   return [ORFactory objectiveValueRational:_dualBound minimize:YES];
}

-(ORStatus) check
{
   return tryfail(^ORStatus{
      //[_x updateMax:nextafterf(_primalBound,-INFINITY)];
      [_x updateMax:[_primalBound sub: [ORRational rationalWith_d:1]]];
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
   [buf appendFormat:@"MINIMIZE(%@) with f* = %@  (dual: %@)",[_x description],_primalBound,_dualBound];
   return buf;
}
@end

@implementation CPRationalVarMaximize
{
   CPRationalVarI*  _x;
   id<ORRational>   _primalBound;
   id<ORRational>   _dualBound;
}

-(CPRationalVarMaximize*) init: (CPRationalVarI*) x
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _primalBound = [[ORRational alloc] init];
   _dualBound = [[ORRational alloc] init];
   [_primalBound setNegInf];
   [_dualBound set: [_x max]];
   
   return self;
}
- (void)dealloc {
   [super dealloc];
   [_primalBound release];
   [_dualBound release];
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
   //NSLog(@"##### x = [%@, %@] %@", [_x min], [_x max], [[_x min] eq: [_x max]]?@"=":@"!=");
   [bound set: [_x min]]; // cpjm: always set to min to avoid overestimation of Primal
   if ([bound gt: _primalBound]){
      [_primalBound set: bound];
      //NSLog(@"primal bound: %@",_primalBound);
      NSLog(@"%@ -- %@", _primalBound, _dualBound);
   }
}
-(void) updateDualBound
{
   id<ORRational>bound = [[ORRational alloc] init];
   [bound set: [_x max]];
   if ([bound lt: _dualBound]){
      [_dualBound set: bound];
      //NSLog(@"dual bound: %@",_dualBound);
      NSLog(@"%@ -- %@", _primalBound, _dualBound);
   }
}

//-(void) tightenPrimalBound: (id<ORObjectiveValueRational>) newBound
//{
//   if ([[newBound value] gt: _primalBound]){
//      _primalBound = [newBound value];
//      //NSLog(@"primal bound: %@",_primalBound);
//      NSLog(@"%@ -- %@", _primalBound, _dualBound);
//   }
//}

-(void) tightenPrimalBound: (id<ORRational>) bound
{
   //NSLog(@"##### x = [%@, %@] %@", [_x min], [_x max], [[_x min] eq: [_x max]]?@"=":@"!=");
   if ([bound gt: _primalBound]){
      [_primalBound set: bound];
      //NSLog(@"primal bound: %@",_primalBound);
      NSLog(@"%@ -- %@", _primalBound, _dualBound);
   }
}

-(ORStatus) tightenDualBound:(id<ORObjectiveValue>)newBound
{
      if ([newBound conformsToProtocol:@protocol(ORObjectiveValueRational)]) {
         id<ORRational> b = [(id<ORObjectiveValueRational>) newBound value];
         ORStatus ok = [b lt: _primalBound] ? ORFailure : ORSuspend;
         if (ok && [b lt: _dualBound]){
            [_dualBound set: b];
            //NSLog(@"dual bound: %@",_dualBound);
            NSLog(@"%@ -- %@", _primalBound, _dualBound);
         }
         return ok;
      } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
         id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueInt>)newBound value]];
         ORStatus ok = [b lt: _primalBound] ? ORFailure : ORSuspend;
         if (ok && [b lt: _dualBound]){
            [_dualBound set: b];
            //NSLog(@"dual bound: %@",_dualBound);
            NSLog(@"%@ -- %@", _primalBound, _dualBound);
         }
         return ok;
      } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
         id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueFloat>)newBound floatValue]];
         ORStatus ok = [b lt: _primalBound] ? ORFailure : ORSuspend;
         if (ok && [b lt: _dualBound]){
            [_dualBound set: b];
            //NSLog(@"dual bound: %@",_dualBound);
            NSLog(@"%@ -- %@", _primalBound, _dualBound);
         }
         return ok;
      } else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
         id<ORRational> b = [ORRational rationalWith_d:[(id<ORObjectiveValueReal>)newBound doubleValue]];
         ORStatus ok = [b lt: _primalBound] ? ORFailure : ORSuspend;
         if (ok && [b lt: _dualBound]){
            [_dualBound set: b];
            //NSLog(@"dual bound: %@",_dualBound);
            NSLog(@"%@ -- %@", _primalBound, _dualBound);
         }
      } //else return ORSuspend;
   return ORSuspend;
}

-(void) tightenLocallyWithDualBound: (id) newBound
{
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueRational)]) {
      id<ORRational> b = [((id<ORObjectiveValueRational>) newBound) value];
      [_x updateMax: b];
   }
   if ([newBound conformsToProtocol:@protocol(ORObjectiveValueInt)]) {
      id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueInt>) newBound) value]];
      [_x updateMax: b];
   }
   else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueFloat)]) {
      id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueFloat>) newBound) value]];
      [_x updateMax: b];
   }
   else if ([newBound conformsToProtocol:@protocol(ORObjectiveValueReal)]) {
      id<ORRational> b = [ORRational rationalWith_d:[((id<ORObjectiveValueReal>) newBound) value]];
      [_x updateMax: b];
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
      _resi = [_resi proj_inter: resTmp];
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
      _xi = [_xi proj_inter: xTmp];
      if(_xi.changed)
         [_x updateInterval:_xi.low and:_xi.up];
      [zero release];
      [resTmp release];
      [xTmp release];
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

