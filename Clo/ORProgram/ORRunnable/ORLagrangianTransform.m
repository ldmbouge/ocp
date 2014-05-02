//
//  ORLagrangianTransform.m
//  Clo
//
//  Created by Daniel Fontaine on 10/17/13.
//
//

#import "ORLagrangianTransform.h"
#import "ORSoftify.h"
#import "ORConstraintI.h"
#import "ORModelI.h"

@protocol ORLocator
-(id)object;
-(id)key;
@end

@interface ORPQueue : NSObject
-(ORPQueue*)init:(BOOL(^)(id,id))cmp;
-(void)buildHeap;
-(id<ORLocator>)addObject:(id)obj forKey:(id)key;
-(id<ORLocator>)insertObject:(id)obj withKey:(id)key;
-(void)update:(id<ORLocator>)loc toKey:(id)key;
-(id)peekAtKey;
-(id)peekAtObject;
-(id)extractBest;
-(ORInt)size;
-(BOOL)empty;
-(NSString*)description;
@end

@interface ORPQLocator : NSObject<ORLocator> {
    id _key;
    id _object;
    @package
    ORInt _ofs;
}
-(id)initWithObject:(id)obj andKey:(id)key;
-(id)key;
-(id)object;
-(void)updateKey:(id)k;
@end

@implementation ORPQLocator
-(id)initWithObject:(id)obj andKey:(id)key
{
    self = [super init];
    _key    = [key retain];
    _object = [obj retain];
    return self;
}
-(void)dealloc
{
    //NSLog(@"Deallocating(%p): %@",self,self);
    [_key release];
    [_object release];
    [super dealloc];
}
-(id)key
{
    return _key;
}
-(id)object
{
    return _object;
}
-(void)updateKey:(id)k
{
    [_key release];
    _key = [k retain];
}
-(NSString*)description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"<%@ -> %@>",[_key description],[_object description]];
    return buf;
}
@end

@implementation ORPQueue {
    BOOL (^better)(id,id);
    ORInt  _mxs;
    ORInt  _sz;
    ORPQLocator** _tab;
}
static inline ORInt parent(ORInt i) { return (i-1) / 2;}
static inline ORInt left(ORInt i)   { return i * 2 + 1;}
static inline ORInt right(ORInt i)  { return i * 2 + 2;}
static void heapify(ORPQueue* pq,ORInt i)
{
    do {
        const ORInt l = left(i);
        const ORInt r = right(i);
        ORInt m;
        if (l < pq->_sz && pq->better(pq->_tab[l].key,pq->_tab[i].key))
            m = l;
        else m = i;
        if (r < pq->_sz && pq->better(pq->_tab[r].key,pq->_tab[m].key))
            m = r;
        if (i != m) {
            ORPQLocator* x = pq->_tab[i];
            pq->_tab[i] = pq->_tab[m];
            pq->_tab[m] = x;
            pq->_tab[i]->_ofs = i;
            pq->_tab[m]->_ofs = m;
            i = m;
        } else break;
    } while(TRUE);
}
-(ORPQueue*)init:(BOOL(^)(id,id))cmp
{
    self = [super init];
    better = [cmp copy];
    _mxs   = 32;
    _sz    = 0;
    _tab   = malloc(sizeof(ORPQLocator*)*_mxs);
    return self;
}
-(void)dealloc
{
    [better release];
    for(ORInt i=0;i<_sz;i++)
        [_tab[i] release];
    free(_tab);
    [super dealloc];
}
-(NSString*)description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    for(ORInt i=0;i<_sz;i++)
        [buf appendFormat:@"%2d : %@\n",i,[_tab[i] description]];
    return buf;
}
-(void)buildHeap
{
    for(ORInt i=_sz /2 ;i >= 0;--i)
        heapify(self, i);
}
-(void)resize
{
    ORPQLocator** new = malloc(sizeof(ORPQLocator*)*_mxs * 2);
    for(ORInt i=0;i<_mxs;i++)
        new[i] = _tab[i];
    _mxs <<= 1;
    free(_tab);
    _tab = new;
}
-(id<ORLocator>)addObject:(id)obj forKey:(id)key
{
    if (_sz >= _mxs - 1)
        [self resize];
    id<ORLocator> rv = _tab[_sz] = [[ORPQLocator alloc] initWithObject:obj andKey:key];
    _tab[_sz++]->_ofs = _sz;
    return rv;
}
-(id<ORLocator>)insertObject:(id)obj withKey:(id)key
{
    if (_sz >= _mxs - 1)
        [self resize];
    ORPQLocator* toInsert = [[ORPQLocator alloc] initWithObject:obj andKey:key];
    ORInt i = _sz++;
    while(i> 0 && better(key,_tab[parent(i)].key)) {
        _tab[i] = _tab[parent(i)];
        _tab[i]->_ofs = i;
        i = parent(i);
    }
    _tab[i] = toInsert;
    _tab[i]->_ofs = i;
    return toInsert;
}
-(void)update:(ORPQLocator*)loc toKey:(id)key
{
    if (better(key,loc.key)) {
        ORInt i = loc->_ofs;
        while(i > 0 && better(key,_tab[parent(i)].key)) {
            _tab[i] = _tab[parent(i)];
            _tab[i]->_ofs = i;
            i = parent(i);
        }
        _tab[i] = loc;
        _tab[i]->_ofs = i;
    } else
        heapify(self,loc->_ofs);
    [loc updateKey:key];
}
-(id)peekAtKey
{
    return _tab[0].key;
}
-(id)peekAtObject
{
    return _tab[0].object;
}
-(id)extractBest
{
    ORPQLocator* t = _tab[0];
    _tab[0] = _tab[--_sz];
    _tab[0]->_ofs = 0;
    heapify(self, 0);
    id rv = [t object];
    [t release];
    return rv;
}
-(ORInt)size
{
    return _sz;
}
-(BOOL)empty
{
    return _sz==0;
}
@end
@interface ORHyperGraphEdge : NSObject {
    NSSet* _vertices;
    BOOL _isTouched;
    id _obj;
}

@property(readonly) NSSet* vertices;
@property(readwrite) BOOL isTouched;
@property(assign) id object;

-(id) initWithVertices: (NSSet*)vertices;
@end

@implementation ORHyperGraphEdge
@synthesize vertices = _vertices;
@synthesize isTouched = _isTouched;
@synthesize object = _obj;

-(id) initWithVertices: (NSSet*)vertices {
    self = [super init];
    if(self) {
        _vertices = [vertices mutableCopy];
        _isTouched = NO;
    }
    return  self;
}

-(void) dealloc {
    [_vertices release];
    [super dealloc];
}

@end

@interface ORHyperGraph : NSObject {
    NSMutableSet* _vertices;
    NSMutableSet* _edges;
}
@property(readonly) NSSet* vertices;
@property(readonly) NSSet* edges;
-(id) initWithVertices: (NSSet*)vertices;
-(void) addVertex: (id)v;
-(void) addEdge: (ORHyperGraphEdge*)e;
-(void) mergeVertices: (NSSet*) toMerge;
-(void) mergeVertices: (NSSet*) toMerge asVertex: (id)v;
@end

@implementation ORHyperGraph
@synthesize  vertices = _vertices;
@synthesize edges = _edges;

-(id) initWithVertices: (NSSet*)vertices {
    self = [super init];
    if(self) {
        _vertices = [vertices mutableCopy];
        _edges = [[NSMutableSet alloc] init];
    }
    return  self;
}

-(void) addVertex: (id)v {
    [_vertices addObject: v];
}

-(void) addEdge: (ORHyperGraphEdge*)e {
    [_edges addObject: e];
}
-(void) dealloc {
    while([_edges count] > 0) {
        ORHyperGraphEdge* e = [_edges anyObject];
        [_edges removeObject: e];
        [e release];
    }
    [_edges release];
    [_vertices release];
    [super dealloc];
}

-(void) mergeVertices: (NSSet*) toMerge {
    [self mergeVertices: toMerge asVertex: [toMerge anyObject]];
}

-(void) mergeVertices: (NSSet*) toMerge asVertex: (id)v {
    NSMutableSet* edgesToRemove = [[NSMutableSet alloc] init];
    [_vertices minusSet: toMerge];
    [_vertices addObject: v];
    for(ORHyperGraphEdge* e in _edges) {
        if([e.vertices isSubsetOfSet: toMerge]) [edgesToRemove addObject: e];
        else if([e.vertices intersectsSet: toMerge]) {
            [(NSMutableSet*)e.vertices minusSet: toMerge];
            [(NSMutableSet*)e.vertices addObject: v];
        }
    }
    [_edges minusSet: edgesToRemove];
}

@end

@interface ORLagrangianTransform(Private)
+(ORHyperGraph*) buildHyperGraph: (id<ORModel>)m;
@end

@implementation ORLagrangianTransform

-(id<ORParameterizedModel>) apply: (id<ORModel>)m relaxing: (NSArray*)cstrs
{
    // Lookup constraints wrt this model
//    NSMutableArray* myCstrs = [[NSMutableArray alloc] init];
//    for(id<ORConstraint> cstr in cstrs) {
//        NSArray* tc = [[m tau] get: cstr];
//        if(tc == nil) [myCstrs addObject: cstr];
//        else [myCstrs addObjectsFromArray: tc];
//    }
    
    // SURROGATE
        NSMutableArray* myCstrs = [[NSMutableArray alloc] init];
        for(id<ORConstraint> cstr in cstrs) {
            id tc = [[m tau] get: cstr];
            if(tc == nil) [myCstrs addObject: cstr];
            else if([tc isKindOfClass: [NSArray class]]) {
                [myCstrs addObjectsFromArray: tc];
            }
            else [myCstrs addObject: tc];
        }
    
    id<ORParameterizedModel> relaxedModel = [self softify: m constraints: myCstrs];
    id<ORIntRange> slackRange = RANGE(relaxedModel, 0, (ORInt)myCstrs.count-1);
    id<ORIdArray> slacks = [ORFactory idArray:  relaxedModel range: slackRange with: ^id(ORInt i) {
        id<ORSoftConstraint> c = [[relaxedModel tau] get: [myCstrs objectAtIndex: i]];
        return [c slack];
    }];
    id<ORExpr> slackSum = [ORFactory sum: relaxedModel over: slackRange suchThat: nil of: ^id<ORExpr>(ORInt i) {
        id<ORVar> s = [slacks at: i];
        id<ORWeightedVar> parameterization = [relaxedModel parameterizeVar: s];
        return [parameterization z];
    }];
    id<ORExpr> prevObjective = [((id<ORObjectiveFunctionExpr>)[relaxedModel objective]) expr];
    if(prevObjective) [relaxedModel minimize: [prevObjective plus: slackSum track: relaxedModel]]; // Changed sub to plus
    else [relaxedModel minimize: slackSum];
    [relaxedModel setSource: m];
    return relaxedModel;
}

-(id<ORParameterizedModel>) softify: (id<ORModel>)m constraints: (NSArray*) cstrs {
    ORSoftify* softify = [[ORSoftify alloc] initORSoftify];
    [softify apply: m toConstraints: cstrs];
    id<ORParameterizedModel> relaxedModel = [softify target];
    return relaxedModel;
}

+(NSArray*) minCutPhase: (ORHyperGraph*) G vertex: (id<NSObject>) a {
    NSMutableSet* A = [[NSMutableSet alloc] initWithObjects: a, nil];
    NSMutableArray* cut = [[NSMutableArray alloc] init];
    
    // Initialize Priority Queue
    ORPQueue* pqueue = [[ORPQueue alloc] init: ^BOOL(id a, id b) { return [a intValue] >= [b intValue]; }];
    NSMapTable* locators = [[NSMapTable alloc] init];
    for(id<NSObject> v in G.vertices) {
        if(v != a) [locators setObject: [pqueue addObject: v forKey: @(0)] forKey: v];
    }
    for(ORHyperGraphEdge* e in G.edges) e.isTouched = NO;
    
    // Do initial Priority Queue update
    void (^priorityUpdate)(id<NSObject>) = ^(id<NSObject> v) {
        for(ORHyperGraphEdge* e in G.edges) {
            if(!e.isTouched && [e.vertices containsObject: v]) {
                for(id<NSObject> w in e.vertices) {
                    if([A containsObject: w]) continue;
                    id<ORLocator> loc = [locators objectForKey: w];
                    NSNumber* newKey = @([[loc key] intValue] + 1);
                    [pqueue update: loc toKey: newKey];
                }
                [cut addObject: e];
                e.isTouched = YES;
            }
        }
    };
    priorityUpdate(a);
    
    NSMutableSet* lastVertices = [[NSMutableSet alloc] init];
    while([A count] != [G.vertices count]) {
        id<NSObject> v = [pqueue extractBest];
        if([G.vertices count] - [A count] <= 2) [lastVertices addObject: v];
        [A addObject: v];
        priorityUpdate(v);
    }
    
    // Merge last vertices. Ensure 'a' remains in G
    if(lastVertices.count == 1) [lastVertices addObject: a];
    if([lastVertices containsObject: a]) [G mergeVertices: lastVertices asVertex: a];
    else [G mergeVertices: lastVertices];
    
    [A release];
    [locators release];
    [pqueue release];
    return cut;
}

+(NSArray*) minCut: (ORHyperGraph*) G vertex: (id<NSObject>) a {
    NSArray* minCut = nil;
    while([G.vertices count] > 1) {
        NSArray* cut = [ORLagrangianTransform minCutPhase: G vertex: a];
        if(minCut == nil || [cut count] < [minCut count]) { [minCut release]; minCut = cut; }
        else [cut release];
    }
    return minCut;
}

+(NSArray*) coupledConstraints: (id<ORModel>)m {
    ORHyperGraph* G = [ORLagrangianTransform buildHyperGraph: m];
    id a = [G.vertices anyObject];
    NSArray* minCut = [ORLagrangianTransform minCut: G vertex: a];
    NSArray* objArray = [minCut valueForKey: @"object"];
    [G release];
    [minCut release];
    return objArray;
}

+(ORHyperGraph*) buildHyperGraph: (id<ORModel>)m {
    NSSet* vars = [NSSet setWithArray: [m variables]];
    ORHyperGraph* G = [[ORHyperGraph alloc] initWithVertices: vars];
    for(id<ORConstraint> c in [m constraints]) {
        ORHyperGraphEdge* e = [[ORHyperGraphEdge alloc] initWithVertices: [c allVars]];
        e.object = c;
        [G addEdge: e];
    }
    return G;
}

@end

@implementation ORLagrangianViolationTransform
-(id<ORParameterizedModel>) softify: (id<ORModel>)m constraints: (NSArray*) cstrs {
    ORViolationSoftify* softify = [[ORViolationSoftify alloc] initORSoftify];
    [softify apply: m toConstraints: cstrs];
    id<ORParameterizedModel> relaxedModel = [softify target];
    return relaxedModel;
}
@end

@implementation ORSoftifyTransform
-(id<ORModel>) apply: (id<ORModel>)m relaxing: (NSArray*)cstrs
{
    // Lookup constraints wrt this model
    NSMutableArray* myCstrs = [[NSMutableArray alloc] init];
    for(id<ORConstraint> cstr in cstrs) {
        NSArray* tc = [[m tau] get: cstr];
        if(tc == nil) [myCstrs addObject: cstr];
        else [myCstrs addObjectsFromArray: tc];
    }
    ORViolationSoftify* softify = [[ORViolationSoftify alloc] initORSoftify];
    [softify apply: m toConstraints: myCstrs];
    id<ORModel> relaxedModel = [softify target];
    id<ORIntRange> slackRange = RANGE(relaxedModel, 0, (ORInt)myCstrs.count-1);
    id<ORExpr> slackSum = [ORFactory sum: relaxedModel over: slackRange suchThat: nil of: ^id<ORExpr>(ORInt i) {
        id<ORSoftConstraint> c = [[relaxedModel tau] get: [myCstrs objectAtIndex: i]];
        return [c slack];
    }];
    id<ORExpr> prevObjective = [((id<ORObjectiveFunctionExpr>)[relaxedModel objective]) expr];
    if(prevObjective) [relaxedModel minimize: [prevObjective plus: slackSum track: relaxedModel]]; // Changed sub to plus
    else [relaxedModel minimize: slackSum];
    [relaxedModel setSource: m];
    return relaxedModel;
}
@end

@implementation ORFactory (ORLagrangianTransform)
+(ORLagrangianTransform*) lagrangianTransform {
    return [[ORLagrangianTransform alloc] init];
}
+(ORLagrangianTransform*) lagrangianViolationTransform {
    return [[ORLagrangianViolationTransform alloc] init];
}
+(ORSoftifyTransform*) softifyModelTransform {
    return [[ORSoftifyTransform alloc] init];
}
@end
