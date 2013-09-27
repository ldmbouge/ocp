/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <objcp/CPObjectQueue.h>

@class SemTracer;
@class SemCP;
@protocol CPSemanticProgram;

@interface CPGenerator : ORDefaultController<ORSearchController> {
   id<CPSemanticProgram>   _solver;
   id<ORTracer>        _tracer;
   PCObjectQueue*      _pool;
   NSCont**             _tab;
   id<ORCheckpoint>*  _cpTab;
   int                   _sz;
   int                   _mx;
   id<ORPost>          _model;
}
-(id)initCPGenerator:(id<ORSearchController>)chain explorer:(id<CPSemanticProgram>)solver onPool:(PCObjectQueue*)pcq post:(id<ORPost>)model;
-(ORInt)  addChoice: (NSCont*) k;
-(void)       fail;
-(ORBool) isFinitelyFailed;
-(void)       exitTry;
-(void)       exitTryall;
@end

@interface CPParallelAdapter : ORNestedController<ORSearchController> {
   id<CPSemanticProgram>  _solver;
   PCObjectQueue*           _pool;
   BOOL               _publishing;
   CPGenerator*              _gen;
}
-(id)initCPParallelAdapter:(id<ORSearchController>)chain  explorer:(id<CPSemanticProgram>)solver onPool:(PCObjectQueue*)pcq;
-(ORInt)  addChoice: (NSCont*) k;
-(void)       fail;
-(void)       succeeds;
-(void)       startTry;
-(void)       startTryall;
-(void) publishWork;
-(ORBool) isFinitelyFailed;
@end
