/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>

/**
 * This is a simple Command protocol to record "decisions" that must be redone
 * when redoing a different semantic path.
 * Constraints are commands.
 * Other commands could be: going to atomic mode, setting a controller, etc....
 */

@protocol ORConstraint;

@interface ORCommandList : NSObject<NSCoding,NSCopying> {
   struct CNode* _head;
   @package
   ORInt _ndId;  // node id
   ORInt _fh;
   ORInt _th;
   ORInt _cnt;
}
+(id)newCommandList:(ORInt)node from:(ORInt)fh to:(ORInt)th;
-(ORCommandList*) initCPCommandList: (ORInt) node from:(ORInt)fh to:(ORInt)th;
-(void)dealloc;
-(void)letgo;
-(id)grab;
-(void)insert: (id<ORConstraint>) c;
-(id<ORConstraint>)removeFirst;
-(ORBool)empty;
-(ORBool)equalTo:(ORCommandList*)cList;
-(void)setMemoryTo:(ORInt)ml;
-(ORInt) memoryFrom;
-(ORInt) memoryTo;
-(ORInt) getNodeId;
-(void) setNodeId:(ORInt)nid;
-(ORBool)apply:(BOOL(^)(id<ORConstraint>))clo;
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
