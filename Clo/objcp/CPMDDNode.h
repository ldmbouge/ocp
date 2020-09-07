#import <ORFoundation/ORFoundation.h>

@class MDDArc;
@interface MDDNode : NSObject {
@public
    MDDStateValues* _forwardState;
    MDDStateValues* _reverseState;
    MDDStateValues* _combinedState;
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
    
    bool _inForwardQueue;
    int _forwardQueueIndex;
    bool _inReverseQueue;
    int _reverseQueueIndex;
    
    bool* _forwardDelta;
    int _forwardDeltaMagic;
    int _forwardDeltaPass;
    bool* _reverseDelta;
    int _reverseDeltaMagic;
    int _reverseDeltaPass;
    
    int _childrenChangedMagic;
}
-(id) initSinkNode:(id<ORTrail>)trail defaultReverseState:(MDDStateValues*)reverseState layer:(int)layer numForwardBytes:(int)numForwardBytes numCombinedBytes:(int)numCombinedBytes;
-(id) initNode: (id<ORTrail>)trail minChildIndex:(int)minChildIndex maxChildIndex:(int)maxChildIndex state:(MDDStateValues*)state layer:(int)layer indexOnLayer:(int)indexOnLayer numReverseBytes:(int)numReverseBytes numCombinedBytes:(int)numCombinedBytes;

-(void) updateForwardState:(char*)reverseState;
-(void) updateReverseState:(char*)reverseState;
-(void) updateCombinedState:(char*)combinedState;

-(void) setForwardPropertyDelta:(bool*)delta passIteration:(int)passIteration;
-(bool*) forwardDeltaForPassIteration:(int)passIteration;
-(void) setReversePropertyDelta:(bool*)delta passIteration:(int)passIteration;
-(bool*) reverseDeltaForPassIteration:(int)passIteration;

-(char*) reverseProperties;

-(void) addParent:(MDDArc*)parentArc inPost:(bool)inPost;
-(void) removeParent:(MDDArc*)parentArc inPost:(bool)inPost;
-(void) takeParentsFrom:(MDDNode*)other;

-(void) addChild:(MDDArc*)childArc at:(int)index inPost:(bool)inPost;
-(void) removeChildAt:(int)index inPost:(bool)inPost;

-(int) layer;
-(int) indexOnLayer;
-(void) setIndexOnLayer:(int)index;
-(void) updateIndexOnLayer:(int)index;

-(TRId*) children;
-(int) numChildren;
-(bool) isChildless;

-(ORTRIdArrayI*) parents;
-(int) numParents;
-(bool) isParentless;

-(bool) isMerged;
-(void) setIsMergedNode:(bool)isMergedNode inCreation:(bool)inCreation;
-(bool) isDeleted;
-(void) deleteNode;
-(bool) candidateForSplitting;
-(bool) parentsChanged;
-(bool) childrenChanged;
-(void) updateChildrenMagic;

-(bool) inQueue:(bool)forward;
-(int) indexInQueue:(bool)forward;
-(void) addToQueue:(bool)forward index:(int)index;
-(void) removeFromQueue:(bool)forward;
@end

@interface MDDArc : NSObject {
@protected
    id<ORTrail> _trail;
    
    MDDStateSpecification* _spec;
    
    int _hashWidth;
    short _bytesPerMagic;
    
    MDDNode* _parent;
    int _arcValue;
    
    TRId _child;
    TRInt _parentArcIndex;
    
    int _numForwardBytes;
    char* _passedForwardState;
    ORUInt* _forwardMagic;
    
    bool _forwardCache;
    bool _reverseCache;
    
    TRInt _needToRecalcEquivalenceClasses;
    TRInt* _equivalenceClasses;
    TRInt _combinedEquivalenceClass;
    
    TRInt _forwardHash;
}
-(id) initArcWithoutCache:(id<ORTrail>)trail from:(MDDNode*)parent to:(MDDNode*)child value:(int)arcValue inPost:(bool)inPost;
-(id) initArc:(id<ORTrail>)trail from:(MDDNode*)parent to:(MDDNode*)child value:(int)arcValue inPost:(bool)inPost state:(char*)state spec:(MDDStateSpecification*)spec;

-(void) updateChildTo:(MDDNode*)child inPost:(bool)inPost;
-(void) setChild:(MDDNode*)child inPost:(bool)inPost;
-(void) updateParentArcIndex:(int)parentArcIndex inPost:(bool)inPost;
-(void) deleteArc:(bool)inPost;

-(void) replaceForwardStateWith:(char*)newState trail:(id<ORTrail>)trail;

-(MDDNode*) parent;
-(MDDNode*) child;
-(int) arcValue;
-(int) parentArcIndex;
-(char*) forwardState;

-(int) calcHash;
-(void) setHash;
-(void) updateHash;
-(int) hashValue;

-(void) recalcEquivalenceClasses;
-(int) equivalenceClassFor:(int)constraint;
-(int) combinedEquivalenceClasses;
@end
