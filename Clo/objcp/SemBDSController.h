/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "cont.h"
#import "CPExplorerI.h"
#import "CPController.h"
#import "CPTypes.h"
#import "CPTrail.h"
#import "CPTracer.h"
#import "CPSolver.h"
#import "CPController.h"


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

@interface SemBDSController : CPDefaultController<NSCopying,CPSearchController> {
@private
   BDSStack*        _tab;
   BDSStack*       _next;
   CPInt          _maxDisc;
   CPInt           _nbDisc;
   SemTracer*    _tracer;
   Checkpoint*   _atRoot;
   id<CPSolver> _solver;   
}
-(id)   initSemBDSController:(id<CPTracer>)tracer andSolver:(id<CPSolver>)solver;
-(void) dealloc;
-(void)       setup;
-(void)       cleanup;
-(CPInt) addChoice:(NSCont*)k;
-(void) fail;
@end
