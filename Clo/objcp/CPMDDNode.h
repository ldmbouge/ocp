#import <ORFoundation/ORFoundation.h>

@class MDDArc;
@interface MDDNode : NSObject {
@public
    MDDStateValues* _topDownState;
    MDDStateValues* _bottomUpState;
@private
    id<ORTrail> _trail;
    
    int _layer;
    TRInt _indexOnLayer;
    
    int _minChildIndex;
    int _maxChildIndex;
    TRInt _numChildren;
    TRId __strong *_children;
    
    TRInt _numParents;
    TRInt _maxNumParents;
    ORTRIdArrayI* _parents;
    
    TRInt _isMergedNode;
    TRInt _isDeleted;
    
    bool _inTopDownQueue;
    bool _inBottomUpQueue;
}
-(id) initSinkNode:(id<ORTrail>)trail defaultBottomUpState:(MDDStateValues*)bottomUpState layer:(int)layer numTopDownBytes:(size_t)numTopDownBytes hashWidth:(int)hashWidth;
-(id) initNode: (id<ORTrail>)trail minChildIndex:(int)minChildIndex maxChildIndex:(int)maxChildIndex state:(MDDStateValues*)state layer:(int)layer indexOnLayer:(int)indexOnLayer numBottomUpBytes:(size_t)numBottomUpBytes hashWidth:(int)hashWidth;

-(void) updateTopDownState:(char*)bottomUpState;
-(void) updateBottomUpState:(char*)bottomUpState;

-(void) addParent:(MDDArc*)parentArc inPost:(bool)inPost;
-(void) removeParent:(MDDArc*)parentArc inPost:(bool)inPost;
-(void) takeParentsFrom:(MDDNode*)other;

-(void) addChild:(MDDArc*)childArc at:(int)index inPost:(bool)inPost;
-(void) removeChildAt:(int)index inPost:(bool)inPost;

-(int) layer;
-(int) indexOnLayer;
-(void) updateIndexOnLayer:(int)index;

-(TRId*) children;
-(int) numChildren;
-(bool) isChildless;

-(ORTRIdArrayI*) parents;
-(int) numParents;
-(bool) isParentless;

-(bool) isMerged;
-(void) setIsMergedNode:(bool)isMergedNode;
-(bool) isDeleted;
-(void) deleteNode;
-(bool) candidateForSplitting;

-(bool) inQueue:(bool)topDown;
-(bool) inTopDownQueue;
-(bool) inBottomUpQueue;
-(void) addToQueue:(bool)topDown;
-(void) addToTopDownQueue;
-(void) addToBottomUpQueue;
-(void) removeFromQueue:(bool)topDown;
@end

@interface MDDArc : NSObject {
@protected
    id<ORTrail> _trail;
    
    MDDNode* _parent;
    int _arcValue;
    
    TRId _child;
    TRInt _parentArcIndex;
    
    size_t _numTopDownBytes;
    char* _passedTopDownState;
    ORUInt* _topDownMagic;
}
-(id) initArc:(id<ORTrail>)trail from:(MDDNode*)parent to:(MDDNode*)child value:(int)arcValue inPost:(bool)inPost state:(char*)state numTopDownByte:(size_t)numTopDownBytes;

-(void) updateChildTo:(MDDNode*)child inPost:(bool)inPost;
-(void) setChild:(MDDNode*)child inPost:(bool)inPost;
-(void) updateParentArcIndex:(int)parentArcIndex inPost:(bool)inPost;
-(void) deleteArc:(bool)inPost;

-(void) replaceTopDownStateWith:(char*)newState trail:(id<ORTrail>)trail;

-(MDDNode*) parent;
-(MDDNode*) child;
-(int) arcValue;
-(int) parentArcIndex;
-(char*) topDownState;
@end
