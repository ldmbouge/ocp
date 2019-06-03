/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORConstraint.h>
#import <CPUKernel/CPLEngine.h>
#import "CPEngineI.h"


@protocol CPBitVar;
@class CPBitConflict;

struct _CPBitAntecedents;
typedef struct _CPBitAntecedents CPBitAntecedents;

typedef struct CPBVConflict{
   CPCoreConstraint*    constraint;
   ORUInt                    level;
} CPBVConflict;

@interface CPLearningEngineI : CPEngineI<CPLEngine>
{
   CPBVConflict**         _globalStore;
   ORUInt                        _size;
   ORUInt                    _capacity;
   ORInt                _backjumpLevel;
//   ORBool                       _retry;
   SemTracer*                  _tracer;
   ORUInt                 _toIncrement;
}
-(CPLearningEngineI*) initEngine: (id<ORTrail>) trail memory:(id<ORMemoryTrail>)mt tracer:(id<ORTracer>)tr;
//-(ORStatus) restoreLostConstraints:(ORUInt) level;
-(void) addConstraint:(CPCoreConstraint*)c;
-(void) addConstraint:(CPCoreConstraint *)c withJumpLevel:(ORUInt) level;
-(ORUInt) getLevel;
-(ORUInt) getBackjumpLevel;
//-(ORBool) retry;
-(ORStatus) enforceObjective;
-(NSSet*) getNewConstraints;
//-(ORStatus)   close;
@end
