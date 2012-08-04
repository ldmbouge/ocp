/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORTrail.h>
#import <ORFoundation/cont.h>
#import <objcp/CPTypes.h>
#import <objcp/CPController.h>
#import <objcp/CPTracer.h>

@interface BDSStack : NSObject {
   struct BDSNode {
      NSCont*     _cont;
      Checkpoint*   _cp;
      CPInt         _disc;
   }; 
@private   
   struct BDSNode* _tab;
   CPInt        _mx;
   CPInt        _sz;
}
-(id)initBDSStack:(CPInt)mx;
-(void)pushCont:(NSCont*)k cp:(Checkpoint*)cp discrepancies:(CPInt)d;
-(struct BDSNode)pop;
-(CPInt)size;
-(bool)empty;
@end

@interface SemBDSController : ORDefaultController<NSCopying,ORSearchController> {
@private
   BDSStack*        _tab;
   BDSStack*       _next;
   CPInt          _maxDisc;
   CPInt           _nbDisc;
   SemTracer*    _tracer;
   Checkpoint*   _atRoot;
   id<CPEngine> _solver;   
}
-(id)   initSemBDSController:(id<ORTracer>)tracer andSolver:(id<CPEngine>)solver;
-(void) dealloc;
-(void)       setup;
-(void)       cleanup;
-(CPInt) addChoice:(NSCont*)k;
-(void) trust;
-(void) fail;
@end
