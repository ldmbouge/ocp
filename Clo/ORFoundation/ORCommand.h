/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORFoundation.h"

/**
 * This is a simple Command protocol to record "decisions" that must be redone
 * when redoing a different semantic path.
 * Constraints are commands.
 * Other commands could be: going to atomic mode, setting a controller, etc....
 */

@protocol ORCommand <NSObject,NSCoding>
-(ORStatus) doIt;
@end

@interface ORCommandList : NSObject<NSCoding,NSCopying> {
   struct CNode {
      id<ORCommand>    _c;
      struct CNode*    _next;
   };
   struct CNode* _head;
   ORInt _ndId;  // node id
}
-(ORCommandList*) initCPCommandList;
-(ORCommandList*) initCPCommandList: (ORInt) node;
-(void)dealloc;
-(void)insert: (id<ORCommand>) c;
-(id<ORCommand>)removeFirst;
-(bool)empty;
-(bool)equalTo:(ORCommandList*)cList;
-(ORInt) getNodeId;
-(bool)apply:(bool(^)(id<ORCommand>))clo;
@end
