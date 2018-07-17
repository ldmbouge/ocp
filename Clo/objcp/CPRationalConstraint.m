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
      [_y updateInterval:[_x minErr] and:[_x maxErr]];
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
      
      ORRational* tmp = [ORRational rationalWith_d:[_x value]];
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
      [_x updateInterval:maxFlt([_x min], [[_y min] get_d]) and:minFlt([_x max], [[_y max] get_d])];
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
-(id) init:(CPRationalVarI*)x and:(ORRational*)c
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
   return [NSString stringWithFormat:@"<%@ <= %@>",_x,_y];
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
   ORRationalInterval* zTemp = [[ORRationalInterval alloc] init];
   ORRationalInterval* yTemp = [[ORRationalInterval alloc] init];
   ORRationalInterval* xTemp = [[ORRationalInterval alloc] init];
   ORRationalInterval* z = [[ORRationalInterval alloc] init];
   ORRationalInterval* x = [[ORRationalInterval alloc] init];
   ORRationalInterval* y = [[ORRationalInterval alloc] init];

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
      
      // ============================== ex
      // ez - ey
      xTemp = [z sub: y];
      
      x = [x proj_inter: xTemp];
      changed |= x.changed;
      
      // ============================== ey
      // ez - ex
      yTemp = [z sub: x];
      
      y = [y proj_inter: yTemp];
      changed |= y.changed;

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
   
   ORRationalInterval* zTemp = [[ORRationalInterval alloc] init];
   ORRationalInterval* yTemp = [[ORRationalInterval alloc] init];
   ORRationalInterval* xTemp = [[ORRationalInterval alloc] init];
   ORRationalInterval* z = [[ORRationalInterval alloc] init];
   ORRationalInterval* x = [[ORRationalInterval alloc] init];
   ORRationalInterval* y = [[ORRationalInterval alloc] init];
   
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
      
      // ============================== ex
      // ez + ey
      xTemp = [z add: y];
      
      x = [x proj_inter: xTemp];
      changed |= x.changed;
      
      // ============================== ey
      // ex - ez
      yTemp = [x sub: z];
      
      y = [y proj_inter: yTemp];
      changed |= y.changed;
      
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
