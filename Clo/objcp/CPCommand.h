/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPData.h>
/**
 * This is a simple Command protocol to record "decisions" that must be redone
 * when redoing a different semantic path. 
 * Constraints are commands. 
 * Other commands could be: going to atomic mode, setting a controller, etc.... 
 */

@protocol CPCommand <NSObject,NSCoding>
-(ORStatus) doIt;
@end

@interface CPCommandList : NSObject<NSCoding> {
   struct CNode {
      id<CPCommand>    _c;
      struct CNode*    _next;
   };
   struct CNode* _head;
   CPInt     _ndId;  // node id
}
-(CPCommandList*)initCPCommandList;
-(CPCommandList*)initCPCommandList:(CPInt)node;
-(void)dealloc;
-(void)insert:(id<CPCommand>)c;
-(id<CPCommand>)removeFirst;
-(bool)empty;
-(bool)equalTo:(CPCommandList*)cList;
-(CPInt)getNodeId;
-(bool)apply:(bool(^)(id<CPCommand>))clo;
@end
