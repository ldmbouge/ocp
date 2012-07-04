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
#import "ORTrail.h"
#import "CPTracer.h"

@interface DFSController : CPDefaultController <NSCopying,CPSearchController> {
@private
   NSCont**        _tab;
   CPInt              _sz;
   CPInt             _mx;
   id<CPTracer> _tracer;
   CPInt    _atRoot;
}
-(id)   initDFSController:(id<CPTracer>)tracer;
-(void) dealloc;
-(void) setup;
-(void) cleanup;
-(CPInt) addChoice:(NSCont*)k;
-(void) fail;
@end

