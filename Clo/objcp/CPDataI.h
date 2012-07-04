/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/NSObject.h>
#import "CP.h"

@class CoreCPI;
@class CP;


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



