/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/cont.h>
#import <ORFoundation/ORController.h>
#import <ORFoundation/ORTracer.h>
#import "ORTrailI.h"

@interface ORSemDFSController : ORDefaultController <NSCopying,ORSearchController,ORStealing> {
@private
   NSCont**            _tab;
   ORInt                _sz;
   ORInt                _mx;
   id<ORCheckpoint>* _cpTab;
   SemTracer*       _tracer;
   id<ORCheckpoint> _atRoot;
   id<OREngine>     _solver;
}
-(id)   initSemController:(id<ORTracer>)tracer andSolver:(id<OREngine>)solver;
-(void) dealloc;
-(void) setup;
-(void) cleanup;
-(ORInt) addChoice:(NSCont*)k;
-(void) trust;
-(void) fail;
-(ORHeist*)steal;
@end
