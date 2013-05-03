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
   @package
   ORInt _ndId;  // node id
   ORInt _cnt;
}
+(id)newCommandList:(ORInt)node;
-(ORCommandList*) initCPCommandList: (ORInt) node;
-(void)dealloc;
-(void)letgo;
-(id)grab;
-(void)insert: (id<ORCommand>) c;
-(id<ORCommand>)removeFirst;
-(ORBool)empty;
-(ORBool)equalTo:(ORCommandList*)cList;
-(ORInt) getNodeId;
-(void) setNodeId:(ORInt)nid;
-(ORBool)apply:(BOOL(^)(id<ORCommand>))clo;
-(ORInt)length;
@end

inline static ORCommandList* grab(ORCommandList* l)
{
   l->_cnt +=1;
   return l;
}
inline static ORBool commandsEqual(ORCommandList* c1,ORCommandList* c2)
{
   return c1->_ndId == c2->_ndId;
}