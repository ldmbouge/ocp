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


@interface DFSController : CPDefaultController <NSCopying,CPSearchController> {
@private
   NSCont**          _tab;
   CPInt              _sz;
   CPInt              _mx;
   id<ORTracer>   _tracer;
   CPInt          _atRoot;
}
-(id)   initDFSController:(id<ORTracer>)tracer;
-(void) dealloc;
-(void) setup;
-(void) cleanup;
-(CPInt) addChoice:(NSCont*)k;
-(void) trust;
-(void) fail;
@end

