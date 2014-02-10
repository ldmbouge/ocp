/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSEngine.h>

@class LSPrioritySpace;
@class LSPropagator;

@interface LSEngineI : NSObject<ORSearchEngine,LSEngine> {
   NSMutableArray* _vars;
   NSMutableArray* _objs;
   NSMutableArray* _cstr;
   NSMutableArray* _invs;
   ORUInt        _nbObjects;
   ORBool          _closed;
   LSPrioritySpace* _pSpace;
}
-(LSEngineI*)initEngine;
-(void)dealloc;
-(ORStatus)close;
-(LSPrioritySpace*)space;
-(void)add:(LSPropagator*)i;
-(NSMutableArray*)variables;
-(NSMutableArray*)invariants;
-(ORUInt)nbObjects;
@end
