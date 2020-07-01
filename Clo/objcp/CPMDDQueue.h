/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <objcp/CPMDDNode.h>

@interface CircularQueue : NSObject {
@protected
    int _front;
    int _rear;
    int _count;
    int _size;
    id __strong *_queue;
}
-(id) initCircularQueue:(int)size;
-(void) clear;
-(bool) isEmpty;
-(void) retractIndex:(int)index forward:(bool)isForward;
-(int) enqueue:(id)object;
-(id) dequeue;
-(int) count;
-(bool) hasDeletedNode;
-(bool) hasUnmarkedNodeFor:(bool)isForward;
@end

@interface CPMDDQueue : NSObject {
@protected
    int _numLayers;
    int _width;
    bool _isForward;
    CircularQueue* __strong *_layerQueues;
    int _numNodes;
    int _currentLayer;
}
-(id) initCPMDDQueue:(int)numLayers width:(int)width isForward:(bool)isForward;
-(void) reboot;
-(void) rebootTo:(int)layer;
-(void) clear;
-(bool) isEmpty;
-(void) retract:(MDDNode*)node;
-(void) enqueue:(MDDNode*)node;
-(MDDNode*) dequeue;
-(int) numOnLayer:(int)layer;
-(bool) hasDeletedNodeOnLayer:(int)layer;
-(bool) hasUnmarkedNodeOnLayer:(int)layer;
@end
