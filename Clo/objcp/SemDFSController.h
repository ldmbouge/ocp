/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORTrailI.h>
#import <ORFoundation/cont.h>
#import <objcp/CPTypes.h>
#import <objcp/CPController.h>
#import <objcp/CPTracer.h>


@interface SemDFSController : ORDefaultController <NSCopying,ORSearchController,CPStealing> {
@private
   NSCont**        _tab;
   ORInt              _sz;
   ORInt             _mx;
   Checkpoint**  _cpTab;
   SemTracer*   _tracer;
   Checkpoint*  _atRoot;
   id<CPEngine> _solver;
}
-(id)   initSemController:(id<ORTracer>)tracer andSolver:(id<CPEngine>)solver;
-(void) dealloc;
-(void) setup;
-(void) cleanup;
-(ORInt) addChoice:(NSCont*)k;
-(void) trust;
-(void) fail;
-(CPHeist*)steal;
@end
