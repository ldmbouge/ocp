/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "objcp/CPSolver.h"
#import "objcp/CPObjectQueue.h"
#import "objcp/CPController.h"

@class SemTracer;
@class SemCP;
// ====================================================================================================
// SemParallel
// ====================================================================================================

@interface SemParallel : NSObject {
   CPUInt           _nbt;
   SemCP*          _original;
   PCObjectQueue*     _queue;
   SemCP**           _clones;
   NSCondition*  _terminated;
   CPInt         _nbDone;
}
-(id)initSemParallel:(SemCP*)orig nbWorkers:(CPUInt)nbt;
-(void)runSearcher:(NSData*)model;
-(void)parallel:(CPVirtualClosure)body;
-(void)setupAndGo:(NSData*)root forCP:(SemCP*)cp searchWith:(CPVirtualClosure)body;
-(void)waitWorkers;
@end
