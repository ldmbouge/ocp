/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import <Foundation/NSObject.h>
#import "CP.h"

@class CoreCPI;
@class CP;

@interface CPExprI: NSObject<CPExpr>
-(id<CPExpr>) add: (id<CPExpr>) e; 
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface CPIntegerI : CPExprI<NSCoding,CPInteger> {
	CPInt _value;
}
-(CPIntegerI*) initCPIntegerI: (CPInt) value;
-(CPInt)  value;
-(void) setValue: (CPInt) value;
-(void) incr;
-(void) decr;
-(CPInt)   min;
-(id<CP>) cp;
@end

@interface CPRuntimeMonitor : NSObject 
+(CPInt) cputime;
+(CPInt) microseconds;
@end;

@interface CPStreamManager : NSObject 
+(void) initialize;
+(void) setDeterministic;
+(void) setRandomized;
+(CPInt) deterministic;
+(void) initSeed: (unsigned short*) seed;
@end

  
@interface CPRandomStream : NSObject {
  unsigned short _seed[3];
}
-(CPRandomStream*) init;
-(void) dealloc;
-(CPInt) next;
@end;

@interface CPZeroOneStream : NSObject {
  unsigned short _seed[3];
}
-(CPZeroOneStream*) init;
-(void) dealloc;
-(double) next;
@end;

@interface CPUniformDistribution : NSObject {
  CPRange         _range;
  CPRandomStream* _stream;
  CPInt       _size;
}
-(CPUniformDistribution*) initCPUniformDistribution: (CPRange) r;
-(void) dealloc;
-(CPInt) next;
@end;



