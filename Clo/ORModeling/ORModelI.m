/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORError.h>
#import "ORVarI.h"
#import "ORSetI.h"
#import "ORModelI.h"
#import "ORError.h"
#import "ORConcurrencyI.h"
#import "ORCopy.h"
#import "ORFlatten.h"

@implementation ORModelI
{
   NSMutableArray*          _vars;      // model variables.
   NSMutableArray*          _cStore;    // constraint store.
   NSMutableArray*          _mStore;    // mutable store  (VARS + CONSTRAINTS + Other mutables). To be concretized
   NSMutableArray*          _iStore;    // immutable store. Should _not_ be concretized.
   id<ORObjectiveFunction>  _objective;
   ORUInt                   _nbObjects; // number of objects registered with this model.
   id<ORModel>              _source;    // that's the pointer up the chain of model refinements with model operators.   
}
-(ORModelI*) initORModelI
{
   self = [super init];
   _vars   = [[NSMutableArray alloc] initWithCapacity:32];
   _cStore = [[NSMutableArray alloc] initWithCapacity:32];
   _mStore = [[NSMutableArray alloc] initWithCapacity:32];
   _iStore = [[NSMutableArray alloc] initWithCapacity:32];
   _objective = nil;
   _nbObjects = 0;
   return self;
}
-(ORModelI*)initORModelI:(ORULong)nb
{
   self = [self initORModelI];
   return self;
}
-(id<ORTracker>)tracker
{
   return self;
}
-(void) dealloc
{
   NSLog(@"ORModelI [%p] dealloc called...\n",self);
   [_source release];
   [_vars release];
   [_mStore release];
   [_cStore release];
   [_iStore release];
   [super dealloc];
}
-(void) setSource:(id<ORModel>)src
{
   [_source release];
   _source = [src retain];
}
-(id<ORModel>)source
{
   return _source;
}
-(id<ORModel>)rootModel
{
   id<ORModel> cur = self;
   while ([cur source] != NULL)
      cur = [cur source];
   return cur;
}
-(id<ORASolver>) solver
{
   return nil;
}
-(id<ORObjectiveFunction>) objective
{
   return _objective;
}
-(id<ORIdArray>) intVars
{
   __block ORInt cnt = 0;
   [_vars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      cnt += [obj conformsToProtocol:@protocol(ORIntVar)];
   }];
   id<ORIdArray> rv = [ORFactory idArray:self range:RANGE(self,0,cnt-1)];
   cnt = 0;
   [_vars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      if ([obj conformsToProtocol:@protocol(ORIntVar)]) {
         [rv set:obj at:cnt];
         cnt++;
      }
   }];
   return rv;
}
-(NSArray*) variables
{
    return [NSArray arrayWithArray: _vars];
}
-(NSArray*) constraints
{
    return [NSArray arrayWithArray: _cStore];
}
-(NSArray*) mutables
{
   return [NSArray arrayWithArray: _mStore];
}
-(NSArray*) immutables
{
   return [NSArray arrayWithArray: _iStore];
}
-(id<ORVar>) addVariable:(id<ORVar>) var
{
   [_vars addObject:var];
   return var;
}
-(id) addObject:(id) object
{
   [_mStore addObject:object];
   return object;
}
-(id) addImmutable:(id) object
{
   [_iStore addObject:object];
   return object;
}
-(id<ORConstraint>) addConstraint:(id<ORConstraint>) cstr
{
   return [self add: cstr];
}
-(void) trackImmutable: (id) obj
{
   [obj setId:_nbObjects++];
   [_iStore addObject:obj];
}
-(void) trackObject: (id) obj
{
   [obj setId:_nbObjects++];
   [_mStore addObject:obj];
}
-(void) trackVariable: (id) var
{
   [var setId:_nbObjects++];
   [_vars addObject:var];
   [_mStore addObject:var];
}
-(id<ORConstraint>) add: (id<ORConstraint>) c
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)]) {
      c = [ORFactory algebraicConstraint: self expr: (id<ORRelation>)c annotation:Default];
   }
   [_cStore addObject:c];
   return c;
}
-(id<ORConstraint>) add: (id<ORConstraint>) c annotation: (ORAnnotation) n
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      c = [ORFactory algebraicConstraint: self expr: (id<ORRelation>)c annotation:n];
   [_cStore addObject:c];
   return c;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:512] autorelease];
   [buf appendFormat:@"vars[%ld] = {\n",[_vars count]];
   for(id<ORVar> v in _vars)
      [buf appendFormat:@"\t%@\n",v];
   [buf appendFormat:@"}\n"];

   [buf appendFormat:@"mutables[%ld] = {\n",[_mStore count]];
   for(id<ORObject> v in _mStore)
      [buf appendFormat:@"\t%@\n",v];
   [buf appendFormat:@"}\n"];

   [buf appendFormat:@"immutables[%ld] = {\n",[_iStore count]];
   for(id<ORObject> v in _iStore)
      [buf appendFormat:@"\t%@\n",v];
   [buf appendFormat:@"}\n"];

   [buf appendFormat:@"cstr[%ld] = {\n",[_cStore count]];
   for(id<ORConstraint> c in _cStore)
      [buf appendFormat:@"\t%@\n",c];
   [buf appendFormat:@"}\n"];
   if (_objective != nil) {
      [buf appendFormat:@"Objective: %@\n",_objective];
   }
   return buf;
}
-(void) optimize: (id<ORObjectiveFunction>) o
{
   _objective = o;
}

-(id<ORObjectiveFunction>) minimizeVar: (id<ORIntVar>) x
{
   _objective = [[ORMinimizeVarI alloc] initORMinimizeVarI: x];
   [self trackObject: _objective];
   return _objective;
}

-(id<ORObjectiveFunction>) maximizeVar: (id<ORIntVar>) x
{
   _objective = [[ORMaximizeVarI alloc] initORMaximizeVarI: x];
   [self trackObject: _objective];
    return _objective;
}

-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e
{
   _objective = [[ORMaximizeExprI alloc] initORMaximizeExprI: e];
   [self trackObject: _objective];
    return _objective;
}
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e
{
   _objective = [[ORMinimizeExprI alloc] initORMinimizeExprI: e];
   [self trackObject: _objective];
    return _objective;
}

-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef
{
   _objective = [[ORMaximizeLinearI alloc] initORMaximizeLinearI: array coef: coef];
   [self trackObject: _objective];
    return _objective;
}
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef
{
   _objective = [[ORMinimizeLinearI alloc] initORMinimizeLinearI: array coef: coef];
   [self trackObject: _objective];
    return _objective;
}
-(void)  applyOnVar: (void(^)(id<ORObject>)) doVar
         onMutables: (void(^)(id<ORObject>)) doMutable
       onImmutables:(void(^)(id<ORObject>)) doImmutable
      onConstraints:(void(^)(id<ORObject>)) doCons
        onObjective:(void(^)(id<ORObject>)) doObjective
{
   for(id<ORObject> c in _mStore)
      doMutable(c);
   for(id<ORObject> c in _iStore)
      doImmutable(c);
   for(id<ORObject> c in _vars)
      doVar(c);
   for(id<ORObject> c in _cStore)
      doCons(c);
   doObjective(_objective);
}
-(void) visit: (id<ORVisitor>) visitor
{
   for(id<ORObject> c in _mStore)
      [c visit: visitor];
   for(id<ORObject> c in _iStore)
      [c visit: visitor];
   for(id<ORObject> c in _vars)
      [c visit: visitor];
   for(id<ORObject> c in _cStore)
      [c visit: visitor];
   [_objective visit: visitor];
}
-(id) copyWithZone:(NSZone*)zone
{
   ORCopy* copier = [[ORCopy alloc] initORCopy: zone];
   ORModelI* m = (ORModelI*)[copier copyModel: self];
   [copier release];
   return m;
}
-(id<ORModel>)flatten
{
   id<ORModel> flatModel = [ORFactory createModel];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:self];
   id<ORModelTransformation> flat = [ORFactory createFlattener:batch];
   [flat apply: self];
   [batch release];
   [flatModel setSource:self];
   return flatModel;
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_vars];
   [aCoder encodeObject:_mStore];
   [aCoder encodeObject:_iStore];
   [aCoder encodeObject:_cStore];
   [aCoder encodeObject:_objective];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _vars = [[aDecoder decodeObject] retain];
   _mStore = [[aDecoder decodeObject] retain];
   _iStore = [[aDecoder decodeObject] retain];
   _cStore = [[aDecoder decodeObject] retain];
   _objective = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}
@end

@implementation ORBatchModel
{
   ORModelI* _target;
   ORModelI* _src;
}
-(ORBatchModel*)init: (ORModelI*) theModel source:(ORModelI*)src
{
   self = [super init];
   _target = theModel;
   _src    = src;
   return self;
}
-(id<ORVar>) addVariable: (id<ORVar>) var
{
   [_target addVariable: var];
   return var;
}
-(id) addObject: (id) object
{
   [_target addObject: object];
   return object;
}
-(id) addImmutable:(id)object
{
   [_target addImmutable:object];
   return object;
}

-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr
{
   [_target add: cstr];
   return cstr;
}
-(id<ORModel>) model
{
   return _target;
}
-(id<ORTracker>)tracker
{
   return _target;
}
-(id<ORObjectiveFunction>) minimizeVar: (id<ORIntVar>) x
{
   return [_target minimizeVar:x];
}
-(id<ORObjectiveFunction>) maximizeVar:(id<ORIntVar>) x
{
   return [_target maximizeVar: x];
}
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) x
{
   return [_target minimize: x];
}
-(id<ORObjectiveFunction>) maximize:(id<ORExpr>) x
{
   return [_target maximize: x];
}
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef
{
   return [_target minimize: array coef: coef];
}
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef
{
  return [_target maximize: array coef: coef];
}

-(void) trackObject: (id) obj
{
   [_target trackObject:obj];
}
-(void) trackImmutable:(id)obj
{
   [_target trackImmutable:obj];
}
-(void) trackVariable: (id) obj
{
   [_target trackVariable: obj];
}
@end


typedef void(^ArrayEnumBlock)(id,NSUInteger,BOOL*);

@implementation ORBatchGroup {
   id<ORAddToModel>     _target;
   id<ORGroup>        _theGroup;
}
-(ORBatchGroup*)init: (id<ORAddToModel>) model group:(id<ORGroup>)group
{
   self = [super init];
   _target = model;
   _theGroup = group;
   return self;
}
-(id<ORTracker>)tracker
{
   return [_target tracker];
}
-(id<ORVar>) addVariable: (id<ORVar>) var
{
   [_target addVariable:var];
   return var;
}
-(id) addObject:(id)object
{
   return [_target addObject:object];
}
-(id) addImmutable:(id)object
{
   return [_target addImmutable:object];
}
-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr
{
   [_theGroup add:cstr];
   return cstr;
}
-(id<ORObjectiveFunction>) minimizeVar: (id<ORIntVar>) x
{
   return [_target minimizeVar:x];
}
-(id<ORObjectiveFunction>) maximizeVar: (id<ORIntVar>) x
{
   return [_target maximizeVar:x];
}
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) x
{
   return [_target minimize: x];
}
-(id<ORObjectiveFunction>) maximize:(id<ORExpr>) x
{
   return [_target maximize: x];
}
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef
{
   return [_target minimize: array coef: coef];
}
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef
{
   return [_target maximize: array coef: coef];
}

-(id<ORAddToModel>) model
{
   return _target;
}
-(void) trackObject: (id) obj
{
   [_target trackObject:obj];
}
-(void) trackVariable: (id) obj
{
   [_target trackVariable:obj];
}
-(void) trackImmutable:(id)obj
{
   [_target trackImmutable:obj];
}
@end

@implementation ORSolutionPoolI
-(id) init
{
    self = [super init];
    _all = [[NSMutableSet alloc] initWithCapacity:64];
    _solutionAddedInformer = (id<ORSolutionInformer>)[[ORInformerI alloc] initORInformerI];
    return self;
}

-(void) dealloc
{
   NSLog(@"dealloc ORSolutionPoolI");
   [_all release];
   [super dealloc];
}

-(void) addSolution:(id<ORSolution>)s
{
 //   [_all addObject:s];
    [_solutionAddedInformer notifyWithSolution: s];
}

-(void) enumerateWith:(void(^)(id<ORSolution>))block
{
   [_all enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
      block(obj);
   }];
}

-(id<ORInformer>)solutionAdded 
{
    return _solutionAddedInformer;
}

-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"pool["];
   [_all enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
      [buf appendFormat:@"\t%@\n",obj];
   }];
   [buf appendFormat:@"]"];
   return buf;
}

-(id<ORSolution>) best
{
   __block id<ORSolution> sel = nil;
   __block id<ORObjectiveValue> bestSoFar = nil;
   [_all enumerateObjectsUsingBlock:^(id<ORSolution> obj, BOOL *stop) {
      if (bestSoFar == nil) {
         bestSoFar = [obj objectiveValue];
         sel = obj;
      }
      else {
         id<ORObjectiveValue> nv = [obj objectiveValue];
         if ([bestSoFar compare: nv] == 1) {
            bestSoFar = nv;
            sel = obj;
         }
      }
   }];
   return [sel retain];
}
@end

@implementation ORConstraintSetI
-(id) init
{
    self = [super init];
    _all = [[NSMutableSet alloc] initWithCapacity:64];
    return self;
}

-(void) dealloc
{
    [_all release];
    [super dealloc];
}

-(id<ORConstraint>) addConstraint:(id<ORConstraint>)c
{
   [_all addObject: c];
   return c;
}

-(ORInt) size {
    return (ORInt)[_all count];
}

-(void) enumerateWith:(void(^)(id<ORConstraint>))block
{
    [_all enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        block(obj);
    }];
}
@end

