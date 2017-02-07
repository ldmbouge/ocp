//
//  ORLagrangianTransform.m
//  Clo
//
//  Created by Daniel Fontaine on 10/17/13.
//
//

#import "ORLagrangianTransform.h"
#import <ORModeling/ORSoftify.h>

//#import "ORConstraintI.h"
//#import "ORModelI.h"

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
    NSMutableArray* myCstrs = [[NSMutableArray alloc] init];
    for(id<ORConstraint> cstr in cstrs) {
        id tc = [[m tau] get: cstr];
        while([[m tau] get: tc] != nil) tc = [[m tau] get: tc];
        if(tc == nil) [myCstrs addObject: cstr];
        else if([tc isKindOfClass: [NSArray class]]) [myCstrs addObjectsFromArray: tc];
        else if([tc conformsToProtocol: @protocol(ORExpr)])
            [myCstrs addObject: [ORFactory algebraicConstraint: m expr: tc]];
        else [myCstrs addObject: tc];
    }
    
    id<ORParameterizedModel> relaxedModel = [self softify: m constraints: myCstrs];
    id<ORIntRange> slackRange = RANGE(relaxedModel, 0, (ORInt)myCstrs.count-1);
    id<ORIdArray> slacks = [ORFactory idArray:  relaxedModel range: slackRange with: ^id(ORInt i) {
        id<ORSoftConstraint> c = [[relaxedModel tau] get: [myCstrs objectAtIndex: i]];
        while([[relaxedModel tau] get: c] != nil) c = [[relaxedModel tau] get: c];
        return [c slack];
    }];
    id<ORExpr> slackSum = [ORFactory sum: relaxedModel over: slackRange suchThat: nil of: ^id<ORExpr>(ORInt i) {
        id<ORVar> s = [slacks at: i];
        id<ORWeightedVar> parameterization = [relaxedModel parameterizeVar: s];
        return (id<ORExpr>)[parameterization z];
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
        return (id<ORExpr>)[c slack];
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
