
@class MDDStateValues;

@interface Node : NSObject {
@public
    TRInt _layerIndex;
    id<ORTrail> _trail;
    
    TRId* _children;
    TRInt _numChildren;
    int _minChildIndex;
    int _maxChildIndex;
    
    ORTRIdArrayI* _parents;
    TRInt _numParents;
    TRInt _maxNumParents;
    
    MDDStateValues* _topDownState;
    MDDStateValues* _bottomUpState;
    TRInt _isMergedNode;
    bool _topDownRecalcRequired;
    bool _bottomUpRecalcRequired;
}
-(id) initSinkNode: (id<ORTrail>) trail state:(MDDStateValues*)state hashWidth:(int)hashWidth;
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex state:(MDDStateValues*)state hashWidth:(int)hashWidth;
-(void) initializeBottomUpState:(MDDStateValues*)bottomUpState;
-(void) updateBottomUpState:(char*)bottomUpState;
-(void) addChild:(id)child at:(int)index inPost:(bool)inPost;
-(void) removeChildAt: (int) index inPost:(bool)inPost;
-(void) addParent: (Node*) parent inPost:(bool)inPost;
-(void) takeParentsFrom:(Node*)other;
-(int) layerIndex;
-(void) setInitialLayerIndex:(int)index;
-(void) updateLayerIndex:(int)index;
-(TRId) getState;
-(bool) isMerged;
-(void) setIsMergedNode:(bool)isMergedNode;
-(bool) topDownRecalcRequired;
-(void) setTopDownRecalcRequired:(bool)recalcRequired;
-(bool) bottomUpRecalcRequired;
-(void) setBottomUpRecalcRequired:(bool)recalcRequired;
-(bool) isChildless;
-(bool) isParentless;
-(TRId*) children;
-(int) numChildren;
-(int) numParents;
-(ORTRIdArrayI*) parents;
-(NSString*) toString;
@end

@interface OldNode : Node {
@public
    ORTRIntArrayI* _parentCounts;
    int _lastAddedParentIndex;
}
-(void) removeChild:(Node*)child numTimes:(int)childCount updatingLVC:(TRInt*)variable_count inPost:(bool)inPost;
-(void) replaceChild:(Node*)oldChild with:(Node*)newChild numTimes:(int)childCount;
-(bool) hasParent:(OldNode*)parent;
-(int) countForParent:(OldNode*)parent;
-(int) countForParentIndex:(int)parent_index;
-(int) findUniqueParentIndexFor:(OldNode*) parent addToHash:(bool)addToHash;
-(void) removeParentAt:(int)index inPost:(bool)inPost;
-(void) removeParentOnce: (OldNode*) parent inPost:(bool)inPost;
-(void) removeParentOnceAtIndex:(int)parentIndex inPost:(bool)inPost;
-(void) removeParentValue: (OldNode*) parent inPost:(bool)inPost;
@end

@class MDDArc;
@interface MDDNode : Node
-(void) addParent:(MDDArc*)parentArc inPost:(bool)inPost;
-(void) removeParentArc:(MDDArc*)parentArc inPost:(bool)inPost;
@end

@interface MDDArc : NSObject {
@protected
    id<ORTrail> _trail;
    int _arcValue;
    MDDNode* _parent;
    TRId _child;
    TRInt _arcIndexForChild; //The index used by the child to get this arc
    char* _passedTopDownState;
    char* _passedBottomUpState;
    ORUInt* _topDownMagic;
    ORUInt* _bottomUpMagic;
    size_t _numTopDownBytes;
    size_t _numBottomUpBytes;
}
-(id) initArcToSink:(id<ORTrail>)trail from:(MDDNode*)parent to:(MDDNode*)child value:(int)arcValue inPost:(bool)inPost numBottomUpBytes:(size_t)numBottomUpBytes;
-(id) initArc:(id<ORTrail>)trail from:(MDDNode*)parent to:(MDDNode*)child value:(int)arcValue inPost:(bool)inPost state:(char*)state numTopDownBytes:(size_t)numTopDownBytes numBottomUpBytes:(size_t)numBottomUpBytes;
-(MDDNode*) parent;
-(MDDNode*) child;
-(void) setChild:(MDDNode*)child inPost:(bool)inPost;
-(int) arcValue;
-(int) parentArcIndex;
-(void) updateParentArcIndex:(int)parentArcIndex inPost:(bool)inPost;
-(void) removeParent:(Node*)parentArc inPost:(bool)inPost;
-(bool) isParentless;
-(bool) isMerged;
-(void) setTopDownRecalcRequired:(bool)recalcRequired;
-(char*) topDownState;
-(char*) bottomUpState;
-(void) replaceTopDownStateWith:(char*)newState trail:(id<ORTrail>)trail;
-(void) replaceBottomUpStateWith:(char*)newState trail:(id<ORTrail>)trail;
@end

@interface NormNodePair : NSObject {
@public
    long norm;
    Node* node;
}
-(id) initNormNodePair:(long)norm node:(Node*)node;
@end

@interface BetterNodeHashTable : NSObject {
    MDDStateValues** *_stateLists;
    char** *_statePropertiesLists;
    int* _numPerHash;
    int* _maxPerHash;
    int _width;
    NSUInteger _lastCheckedHash;
    size_t _numBytes;
}
-(id) initBetterNodeHashTable:(int)width numBytes:(size_t)numBytes;
-(bool) hasNodeWithStateProperties:(char*)stateProperties hash:(NSUInteger)hash node:(Node**)existingNode;
-(void) addState:(MDDStateValues*)state;
@end
@interface NodeHashTable : NSObject {
    NSMutableArray** _nodeHashes;
    int _width;
}
-(id) initNodeHashTable:(int)width;
-(NSMutableArray*) findBucketForStateHash:(NSUInteger)stateHash;
-(Node*) nodeWithState:(id)state inBucket:(NSMutableArray*)bucket;
-(NSMutableArray**) hashTable;
@end

typedef bool (*CanCreateStateIMP)(id,SEL,char**,MDDStateValues*,int,int);
typedef NSUInteger (*HashValueIMP)(id,SEL,char*);
typedef bool (*HasNodeIMP)(id,SEL,char*,NSUInteger,Node**);
typedef int (*RemoveParentlessIMP)(id,SEL,Node*,int);
typedef void (*BuildLayerByValueIMP)(id,SEL,int);
typedef void (*AssignVariableIMP)(id,SEL,int);
typedef char* (*ComputeStateFromPropertiesIMP)(id,SEL,char*,int,int);
typedef char* (*CalculateStateFromParentsIMP)(id,SEL,Node*,int,bool*);
typedef char* (*BatchMergeStatesIMP)(id,SEL,char**,int**,int*,int,bool*,int,int);
typedef void (*ReplaceStateIMP)(id,SEL,MDDStateValues*,char*);
typedef bool (*ReplaceArcStateIMP)(id,SEL,MDDArc*,char*,int);
typedef void (*SplitNodesOnLayerIMP)(id,SEL,int);
