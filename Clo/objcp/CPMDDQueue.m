/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <objcp/CPMDDQueue.h>

@implementation CircularQueue
-(id) initCircularQueue:(int)size {
    self = [super init];
    
    _size = size;
    _front = 0;
    _rear = 0;
    _count = 0;
    _queue = (id __strong *)calloc(sizeof(id), _size);
    
    return self;
}
-(void) dealloc {
    for (int i = 0; i < _size; i++) {
        _queue[i] = nil;
    }
    free(_queue);
    [super dealloc];
}
-(void) clear {
    _front = 0;
    _rear = 0;
    _count = 0;
}
-(bool) isEmpty {
    return _count == 0;
}
-(void) retractIndex:(int)index forward:(bool)isForward {
    [_queue[index] release];
    if (index == _front) {
        _queue[index] = nil;
        _front++;
        if (_front == _size) {
            _front = 0;
        }
    } else if (index == _rear-1) {
        _queue[index] = nil;
        _rear--;
        if (_rear < 0) {
            _rear += _size;
        }
    } else {
        _queue[index] = _queue[_front];
        [_queue[index] addToQueue:isForward index:index];
        _queue[_front] = nil;
        _front++;
        if (_front == _size) {
            _front = 0;
        }
    }
    _count--;
    return;
}
-(int) enqueue:(id)object {
    if (_count == _size) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CircularQueue: Method enqueue called when at max size."];
    }
    int index = _rear;
    _queue[_rear] = [object retain];
    _rear = (_rear + 1) % _size;
    _count++;
    return index;
}
-(id) dequeue {
    id removedValue = _queue[_front];
    _queue[_front] = nil;
    _front = (_front + 1) % _size;
    _count--;
    return removedValue;
}
-(int) count {
    return _count;
}
-(bool) hasDeletedNode {
    for (int i = 0; i < _count; i++) {
        int index = (_front + i) % _size;
        if ([_queue[index] isDeleted]) {
            return true;
        }
    }
    return false;
}
-(bool) hasUnmarkedNodeFor:(bool)isForward {
    for (int i = 0; i < _count; i++) {
        int index = (_front + i) % _size;
        if (![_queue[index] inQueue:isForward]) {
            return true;
        }
    }
    return false;
}
@end

@implementation CPMDDQueue
-(id) initCPMDDQueue:(int)numLayers width:(int)width isForward:(bool)isForward {
    self = [super init];
    
    _numLayers = numLayers;
    _width = width;
    _isForward = isForward;
    _layerQueues = (CircularQueue* __strong *)calloc(sizeof(CircularQueue*), _numLayers);
    for (int i = 0; i < _numLayers; i++) {
        _layerQueues[i] = [[CircularQueue alloc] initCircularQueue:_width];
    }
    _numNodes = 0;
    _currentLayer = _isForward ? 0 : _numLayers-1;
    
    return self;
}
-(void) dealloc {
    for (int i = 0; i < _numLayers; i++) {
        [_layerQueues[i] release];
        _layerQueues[i] = nil;
    }
    free(_layerQueues);
    [super dealloc];
}

-(void) reboot {
    _currentLayer = _isForward ? 0 : _numLayers-1;
}
-(void) rebootTo:(int)layer {
    _currentLayer = layer;
}
-(void) clear {
    if (_numNodes) {
        for (int i = 0; i < _numLayers; i++) {
            for (int j = [_layerQueues[i] count]; j > 0; j--) {
                MDDNode* node = [_layerQueues[i] dequeue];
                [node removeFromQueue:_isForward];
                [node release];
            }
        }
        _numNodes = 0;
    }
}
-(bool) isEmpty {
    return _numNodes == 0;
}
-(void) retract:(MDDNode*)node {
    if ([node inQueue:_isForward]) {
        [_layerQueues[[node layer]] retractIndex:[node indexInQueue:_isForward] forward:_isForward];
        [node removeFromQueue:_isForward];
        _numNodes--;
    }
}
-(void) enqueue:(MDDNode*)node {
    if (![node inQueue:_isForward]) {
        [node addToQueue:_isForward index: [_layerQueues[[node layer]] enqueue:node]];
        _numNodes++;
    }
}
-(MDDNode*) dequeue {
    while (_currentLayer >= 0 && _currentLayer < _numLayers && [_layerQueues[_currentLayer] isEmpty]) {
        _currentLayer = _currentLayer + (_isForward ? 1 : -1);
    }
    if (_currentLayer < 0 || _currentLayer == _numLayers) {
        return nil;
    }
    _numNodes--;
    MDDNode* removedNode = [_layerQueues[_currentLayer] dequeue];
    [removedNode removeFromQueue:_isForward];
    [removedNode release];
    return removedNode;
}
-(int) numOnLayer:(int)layer {
    return [_layerQueues[layer] count];
}
-(bool) hasDeletedNodeOnLayer:(int)layer {
    return [_layerQueues[layer] hasDeletedNode];
}
-(bool) hasUnmarkedNodeOnLayer:(int)layer {
    return [_layerQueues[layer] hasUnmarkedNodeFor:_isForward];
}
@end
