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
#import "CPEvents.h"

@interface SemDFSController : CPDefaultController <NSCopying,CPSearchController,CPStealing> {
@private
   NSCont**        _tab;
   CPInt              _sz;
   CPInt             _mx;
   Checkpoint**  _cpTab;
   SemTracer*   _tracer;
   Checkpoint*  _atRoot;
   id<CPSolver> _solver;
}
-(id)   initSemController:(id<CPTracer>)tracer andSolver:(id<CPSolver>)solver;
-(void) dealloc;
-(void) setup;
-(void) cleanup;
-(CPInt) addChoice:(NSCont*)k;
-(void) fail;
-(CPHeist*)steal;
@end
