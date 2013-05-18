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
#import "ORFlatten.h"
#import "ORLPFlatten.h"
#import "ORMIPFlatten.h"


@implementation ORTau
{
   NSMapTable* _mapping;
}
-(ORTau*) initORTau
{
   self = [super init];
   _mapping = [[NSMapTable alloc] initWithKeyOptions:NSMapTableWeakMemory|NSMapTableObjectPointerPersonality
                                        valueOptions:NSMapTableWeakMemory|NSMapTableObjectPointerPersonality
                                            capacity:64];
   return self;
}
-(void) dealloc
{
   [_mapping release];
   [super dealloc];
}
-(void) set: (id) value forKey: (id) key
{
   [_mapping setObject: value forKey: key];
}
-(id) get: (id) key
{
   return [_mapping objectForKey: key];
}
-(id) copyWithZone: (NSZone*) zone
{
   ORTau* tau = [[ORTau alloc] initORTau];
   tau->_mapping = [_mapping copy];
   return tau;
}
@end

@implementation ORLambda
{
   NSMapTable* _mapping;
}
-(ORLambda*) initORLambda
{
   self = [super init];
   _mapping = [[NSMapTable alloc] initWithKeyOptions:NSMapTableWeakMemory|NSMapTableObjectPointerPersonality
                                        valueOptions:NSMapTableWeakMemory|NSMapTableObjectPointerPersonality
                                            capacity:64];
   return self;
}
-(void) dealloc
{
   [_mapping release];
   [super dealloc];
}
-(void) set: (id) value forKey: (id) key
{
   [_mapping setObject: value forKey: key];
}
-(id) get: (id) key
{
   return [_mapping objectForKey: key];
}
-(id) copyWithZone: (NSZone*) zone
{
   ORLambda* lambda = [[ORLambda alloc] initORLambda];
   lambda->_mapping = [_mapping copy];
   return lambda;
}
@end

@implementation ORModelI
{
   NSMutableArray*          _vars;      // model variables.
   NSMutableArray*          _cStore;    // constraint store.
   NSMutableArray*          _mStore;    // mutable store  (VARS + CONSTRAINTS + Other mutables). To be concretized
   NSMutableArray*          _iStore;    // immutable store. Should _not_ be concretized.
   NSMutableArray*          _memory;    // memory store.
   id<ORObjectiveFunction>  _objective;
   ORUInt                   _nbObjects; // number of objects registered with this model. (vars+mutable+cstr)
   ORUInt                   _nbImmutables; // Number of immutable objects registered with the model
   id<ORModel>              _source;    // that's the pointer up the chain of model refinements with model operators.
   NSMutableDictionary*     _cache;
   id<ORModelMappings>      _mappings;  // these are all the mappings for the models
}
-(ORModelI*) initORModelI
{
   self = [super init];
   _vars   = [[NSMutableArray alloc] initWithCapacity:32];
   _cStore = [[NSMutableArray alloc] initWithCapacity:32];
   _mStore = [[NSMutableArray alloc] initWithCapacity:32];
   _iStore = [[NSMutableArray alloc] initWithCapacity:32];
   _memory = [[NSMutableArray alloc] initWithCapacity:32];
   _cache  = [[NSMutableDictionary alloc] initWithCapacity:101];
   _mappings = [[ORModelMappings alloc] initORModelMappings];
   _objective = nil;
   _nbObjects = _nbImmutables = 0;
   return self;
}
-(ORModelI*) initORModelI: (ORUInt) nb mappings: (id<ORModelMappings>) mappings
{
   self = [self initORModelI];
   _nbObjects = nb;
   _mappings = [mappings copy];
   return self;
}
-(ORModelI*) initWithModel: (ORModelI*) src
{
   self = [super init];   
   _vars = [src->_vars copy];
   _cStore = [src->_cStore copy];
   _mStore = [src->_mStore copy];
   _iStore = [src->_iStore copy];
   _memory = [[NSMutableArray alloc] initWithCapacity:32];
   _nbObjects = src->_nbObjects;
   _nbImmutables = src->_nbImmutables;
   _objective = src->_objective;
   _source = src;
   _cache  = [[NSMutableDictionary alloc] initWithCapacity:101];
   _mappings = [src->_mappings copy];
   return self;
}
-(id<ORTau>) tau
{
   return _mappings.tau;
}
-(id<ORLambda>) lambda
{
   return _mappings.lambda;
}
-(id<ORModelMappings>) mappings
{
   return _mappings;
}

-(ORUInt)nbObjects
{
   return _nbObjects;
}
-(ORUInt)nbImmutables
{
   return _nbImmutables;
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
   [_cache release];
   [_mappings release];
   [super dealloc];
}
-(id)inCache:(id)obj
{
   return [_cache objectForKey:obj];
}
-(id) addToCache:(id)obj
{
   [_cache setObject:obj forKey:obj];
   return obj;
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
-(id) addMutable:(id) object
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
-(id) trackObject:(id) obj
{
   [_memory addObject:obj];
   return obj;
}
-(id) trackImmutable: (id) obj
{
   id co = [self inCache:obj];
   if (!co) {
      [obj setId:_nbImmutables++];
      if ([obj conformsToProtocol:@protocol(NSCopying)]) {
         [self addToCache:obj];
      }
      [_iStore addObject:obj];
      [_memory addObject:obj];
      return obj;
   } else return co;
}
-(id) trackConstraintInGroup:(id)obj
{
   [obj setId:_nbObjects++];
   return obj;
}
-(id) trackObjective:(id) obj
{
   [obj setId:_nbObjects++];
   [_memory addObject:obj];
   return obj;
}
-(id) trackMutable: (id) obj
{
   [obj setId:_nbObjects++];
   [_mStore addObject:obj];
   [_memory addObject:obj];
   return obj;
}
-(id) trackVariable: (id) var
{
   [var setId:_nbObjects++];
   [_vars addObject:var];
   [_mStore addObject:var];
   [_memory addObject:var];
   return var;
}
-(id<ORConstraint>) add: (id<ORConstraint>) c
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)]) {
      c = [ORFactory algebraicConstraint: self expr: (id<ORRelation>)c annotation:Default];
   }
   if (c.getId == -1)
      [c setId:_nbObjects++];
   [_cStore addObject:c];
   return c;
}
-(id<ORConstraint>) add: (id<ORConstraint>) c annotation: (ORAnnotation) n
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      c = [ORFactory algebraicConstraint: self expr: (id<ORRelation>)c annotation:n];
   [c setId:_nbObjects++];
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
   return [self trackObjective: _objective];
}

-(id<ORObjectiveFunction>) maximizeVar: (id<ORIntVar>) x
{
   _objective = [[ORMaximizeVarI alloc] initORMaximizeVarI: x];
   return [self trackObjective: _objective];
}

-(id<ORObjectiveFunction>) maximize: (id<ORExpr>) e
{
   _objective = [[ORMaximizeExprI alloc] initORMaximizeExprI: e];
   return [self trackObjective: _objective];
}
-(id<ORObjectiveFunction>) minimize: (id<ORExpr>) e
{
   _objective = [[ORMinimizeExprI alloc] initORMinimizeExprI: e];
   return [self trackObjective: _objective];
}

-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef
{
   _objective = [[ORMaximizeLinearI alloc] initORMaximizeLinearI: array coef: coef];
   return [self trackObjective: _objective];
}
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) array coef: (id<ORFloatArray>) coef
{
   _objective = [[ORMinimizeLinearI alloc] initORMinimizeLinearI: array coef: coef];
   return [self trackObjective: _objective];
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
   ORModelI* clone = [[ORModelI allocWithZone:zone] initWithModel:self];
   return clone;
}
-(id<ORModel>) flatten
{
   id<ORModel> flatModel = [ORFactory createModel:_nbObjects mappings: _mappings];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:self];
   id<ORModelTransformation> flat = [ORFactory createFlattener:batch];
   [flat apply: self];
   [batch release];
   [flatModel setSource:self];
   return flatModel;
}
-(id<ORModel>) lpflatten
{
   id<ORModel> flatModel = [ORFactory createModel:_nbObjects mappings: _mappings];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:self];
   id<ORModelTransformation> flat = [ORFactory createLPFlattener:batch];
   [flat apply: self];
   [batch release];
   [flatModel setSource:self];
   return flatModel;
}
-(id<ORModel>) mipflatten
{
   id<ORModel> flatModel = [ORFactory createModel:_nbObjects mappings: _mappings];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:self];
   id<ORModelTransformation> flat = [ORFactory createMIPFlattener:batch];
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
-(id) addMutable: (id) object
{
   if (object)
      [_target addMutable: object];
   return object;
}
-(id) addImmutable:(id)object
{
   [_target addImmutable:object];
   return object;
}

-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr
{
   if (cstr && (id)cstr != [NSNull null])
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
-(id) trackObject: (id) obj
{
   return [_target trackObject:obj];
}
-(id) trackConstraintInGroup:(id)obj
{
   return [_target trackConstraintInGroup:obj];
}
-(id) trackObjective: (id) obj
{
   return [_target trackObjective:obj];
}
-(id) trackMutable: (id) obj
{
   return [_target trackMutable:obj];
}
-(id) trackImmutable:(id)obj
{
   return [_target trackImmutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_target trackVariable: obj];
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
-(id) addMutable:(id)object
{
   return [_target addMutable:object];
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
-(id) trackObject: (id) obj
{
   return [_target trackObject:obj];
}
-(id) trackConstraintInGroup:(id)obj
{
   return [_target trackConstraintInGroup:obj];
}
-(id) trackObjective: (id) obj
{
   return [_target trackObjective:obj];
}
-(id) trackMutable: (id) obj
{
   return [_target trackMutable:obj];
}
-(id) trackVariable: (id) obj
{
   return [_target trackVariable:obj];
}
-(id) trackImmutable:(id)obj
{
   return [_target trackImmutable:obj];
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
   // pvh this is buggy
//   [_all release];
   [super dealloc];
}

-(void) addSolution:(id<ORSolution>)s
{
    //[_all addObject:s];
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

