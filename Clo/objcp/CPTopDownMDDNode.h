
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
    
    MDDStateValues* _state;
    TRInt _isMergedNode;
    bool _recalcRequired;
}
-(id) initNode: (id<ORTrail>) trail hashWidth:(int)hashWidth;
-(id) initNode: (id<ORTrail>) trail minChildIndex:(int) minChildIndex maxChildIndex:(int) maxChildIndex state:(MDDStateValues*)state hashWidth:(int)hashWidth;
-(void) addChild:(id)child at:(int)index inPost:(bool)inPost;
-(void) removeChildAt: (int) index;
-(void) takeParentsFrom:(Node*)other;
-(int) layerIndex;
-(void) setInitialLayerIndex:(int)index;
-(void) updateLayerIndex:(int)index;
-(TRId) getState;
-(bool) isMergedNode;
-(void) setIsMergedNode:(bool)isMergedNode;
-(bool) recalcRequired;
-(void) setRecalcRequired:(bool)recalcRequired;
-(bool) isChildless;
-(bool) isParentless;
-(TRId*) children;
-(int) numChildren;
-(int) numParents;
-(ORTRIdArrayI*) parents;
@end

@interface OldNode : Node {
@public
    ORTRIntArrayI* _parentCounts;
}
-(void) removeChild:(Node*)child numTimes:(int)childCount updatingIVC:(int*)initial_variable_count;
-(void) removeChild:(Node*)child numTimes:(int)childCount updatingLVC:(TRInt*)variable_count;
-(void) replaceChild:(Node*)oldChild with:(Node*)newChild numTimes:(int)childCount;
-(void) addFirstParent: (Node*) parent;
-(void) addParent:(OldNode*) parent inPost:(bool)inPost;
-(bool) hasParent:(OldNode*)parent;
-(int) countForParent:(OldNode*)parent;
-(int) countForParentIndex:(int)parent_index;
-(int) findUniqueParentIndexFor:(OldNode*) parent addToHash:(bool)addToHash;
-(void) removeParentAt:(int)index inPost:(bool)inPost;
-(void) removeParentOnce: (OldNode*) parent inPost:(bool)inPost;
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
    MDDNode* _child;
    TRInt _arcIndexForChild; //The index used by the child to get this arc
}
-(id) initArc:(id<ORTrail>)trail from:(MDDNode*)parent to:(MDDNode*)child value:(int)arcValue inPost:(bool)inPost;
-(MDDNode*) parent;
-(MDDNode*) child;
-(void) setChild:(MDDNode*)child;
-(int) arcValue;
-(int) parentArcIndex;
-(void) updateParentArcIndex:(int)parentArcIndex;
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
