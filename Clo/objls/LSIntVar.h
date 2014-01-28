/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSVar.h>

@protocol LSEngine;
@class LSPropagator;

typedef enum LSStatus {
   LSFinal   = 0,
   LSPending = 1
} LSStatus;

@interface LSIntVar : ORObject<LSVar> {
   LSEngineI*    _engine;
   ORInt          _value;
   enum LSStatus _status;
   NSMutableSet*    _outbound;
}
-(id)initWithEngine:(id<LSEngine>)engine andValue:(ORInt)v;
-(void)dealloc;
-(void)setValue:(ORInt)v;
-(ORInt)value;
-(ORInt)incr;
-(ORInt)decr;
-(id)addListener:(LSPropagator*)p term:(ORInt)k;
@end
