/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "objcp/CPEngine.h"
#import "objcp/CPObjectQueue.h"

@class SemTracer;
@class SemCP;
// ====================================================================================================
// SemParallel
// ====================================================================================================

@interface SemParallel : NSObject {
   ORUInt           _nbt;
   SemCP*          _original;
   PCObjectQueue*     _queue;
   SemCP**           _clones;
   NSCondition*  _terminated;
   ORInt         _nbDone;
}
-(id)initSemParallel:(SemCP*)orig nbWorkers:(ORUInt)nbt;
-(void)runSearcher:(NSData*)model;
-(void)parallel:(CPVirtualClosure)body;
-(void)setupAndGo:(NSData*)root forCP:(SemCP*)cp searchWith:(CPVirtualClosure)body;
-(void)waitWorkers;
@end


@interface CPGenerator : ORDefaultController<ORSearchController> {
   id<ORExplorer>  _explorer;
   PCObjectQueue*      _pool;
   NSCont**             _tab;
   id<ORCheckpoint>*  _cpTab;
   int                   _sz;
   int                   _mx;
}
-(id)initCPGenerator:(id<ORSearchController>)chain explorer:(id<ORExplorer>)explorer onPool:(PCObjectQueue*)pcq;
-(ORInt)  addChoice: (NSCont*) k;
-(void)       fail;
-(BOOL) isFinitelyFailed;
-(void)       exitTryLeft;
-(void)       exitTryRight;
-(void)       exitTryallBody;
-(void)       exitTryallOnFailure;
@end

@interface CPParallelAdapter : ORNestedController<ORSearchController> {
   id<ORExplorer>     _explorer;
   PCObjectQueue*         _pool;
   BOOL             _publishing;
   CPGenerator*            _gen;
}
-(id)initCPParallelAdapter:(id<ORSearchController>)chain  explorer:(id<ORExplorer>)explorer onPool:(PCObjectQueue*)pcq;
-(ORInt)  addChoice: (NSCont*) k;
-(void)       fail;
-(void)       succeeds;
-(void)       startTry;
-(void)       startTryall;
-(void) publishWork;
-(BOOL) isFinitelyFailed;
@end
