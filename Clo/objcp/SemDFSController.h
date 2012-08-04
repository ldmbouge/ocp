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
-(id)   initSemController:(id<ORTracer>)tracer andSolver:(id<CPSolver>)solver;
-(void) dealloc;
-(void) setup;
-(void) cleanup;
-(CPInt) addChoice:(NSCont*)k;
-(void) trust;
-(void) fail;
-(CPHeist*)steal;
@end
