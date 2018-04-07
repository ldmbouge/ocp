/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
#import "ORConstraintI.h"
#import "ORFlatten.h"
#import "ORLPFlatten.h"
#import "ORMIPFlatten.h"

#import <objc/runtime.h>

#if __clang_major__==3 && __clang_minor__==6
#define _Nonnull
#endif


@implementation ORTau
{
   NSMapTable* _mapping;
}
-(ORTau*) initORTau
{
   self = [super init];
   _mapping = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsOpaqueMemory
                                        valueOptions:NSPointerFunctionsOpaqueMemory
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
   if (key==nil)
      return;
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
-(NSString*)description
{
   NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
   @autoreleasepool {
      NSEnumerator* i = [_mapping keyEnumerator];
      id key;
      [buf appendString:@"{"];
      while ((key = [i nextObject]) !=nil) {
         id obj = [_mapping objectForKey:key];
         [buf appendFormat:@"%@ -> %@,",key,obj];
      }
      [buf appendString:@"}"];
   }
   return buf;
}
@end

@implementation ORLambda
{
   NSMapTable* _mapping;
}
-(ORLambda*) initORLambda
{
   self = [super init];
   _mapping = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsOpaqueMemory
                                        valueOptions:NSPointerFunctionsOpaqueMemory
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
-(NSString*)description
{
   NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
   @autoreleasepool {
      NSEnumerator* i = [_mapping keyEnumerator];
      id key;
      [buf appendString:@"{"];
      while ((key = [i nextObject]) !=nil) {
         id obj = [_mapping objectForKey:key];
         [buf appendFormat:@"%@ -> %@,",key,obj];
      }
      [buf appendString:@"}"];
   }
   return buf;
}
@end

@implementation ORModelMappings
{
@protected
   id<ORTau> _tau;
   id<ORLambda> _lambda;
}

-(ORModelMappings*) initORModelMappings
{
   self = [super init];
   _tau = [[ORTau alloc] initORTau];
   _lambda = [[ORLambda alloc] initORLambda];
   return self;
}

-(ORModelMappings*) initORModelMappings: (id<ORModelMappings>) mappings
{
   self = [super init];
   _tau = [mappings.tau copy];
   _lambda = [mappings.lambda copy];
   return self;
}

-(void) dealloc
{
   [super dealloc];
}

-(void) setTau: (id<ORTau>) tau
{
   _tau = tau;
}
-(void) setLambda: (id<ORLambda>) lambda
{
   _lambda = lambda;
}
-(id<ORTau>) tau
{
   return _tau;
}
-(id<ORLambda>) lambda
{
   return _lambda;
}
-(id) copyWithZone: (NSZone*) zone
{
   ORModelMappings* map = [[ORModelMappings alloc] initORModelMappings];
   map->_tau = [_tau copy];
   map->_lambda = [_lambda copy];
   return map;
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
   _source = nil;
   return self;
}
-(ORModelI*) initORModelI: (ORUInt) nb mappings: (id<ORModelMappings>) mappings
{
   self = [self initORModelI];
   _nbObjects = nb;
   if (mappings) {
      [_mappings release];
      _mappings = [mappings copy];
   }
   return self;
}
-(ORModelI*) initWithModel: (ORModelI*) src
{
   self = [super init];   
   _vars = [src->_vars mutableCopy];
   _cStore = [src->_cStore mutableCopy];
   _mStore = [src->_mStore mutableCopy];
   _iStore = [src->_iStore mutableCopy];
   _memory = [[NSMutableArray alloc] initWithCapacity:32];
   _nbObjects = src->_nbObjects;
   _nbImmutables = src->_nbImmutables;
   _objective = src->_objective;
   _source = [src retain];
   _cache  = [[NSMutableDictionary alloc] initWithCapacity:101];
   _mappings = [src->_mappings copy];
   return self;
}
-(ORModelI*) initWithModel: (ORModelI*) src relax: (NSArray*)cstrs
{
    self = [super init];
    _vars = [src->_vars mutableCopy];
    NSMutableArray* cStore = [src->_cStore mutableCopy];
    [cStore removeObjectsInArray: cstrs];
    _cStore = cStore;
    _mStore = [src->_mStore mutableCopy];
    _iStore = [src->_iStore mutableCopy];
    _memory = [[NSMutableArray alloc] initWithCapacity:32];
    _nbObjects = src->_nbObjects;
    _nbImmutables = src->_nbImmutables;
    _objective = src->_objective;
    _source = [src retain];
    _cache  = [[NSMutableDictionary alloc] initWithCapacity:101];
    _mappings = [src->_mappings copy];
    return self;
}
-(void)setCurrent:(id<ORConstraint>)cstr
{}
-(id<ORTau>) tau
{
   return _mappings.tau;
}
-(id<ORLambda>) lambda
{
   return _mappings.lambda;
}
-(id<ORModelMappings>) modelMappings
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
   NSLog(@"ORModelI [%p] dealloc called...  source (%p) RC[%lu]\n",self,_source,(unsigned long)[_source retainCount]);
   [_source release];
   [_vars release];
   [_mStore release];
   [_cStore release];
   [_iStore release];
   [_cache release];
   [_mappings release];
   [_memory release];
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
-(id)memoize:(id) obj
{
   id mo = [_cache objectForKey:obj];
   if (mo == NULL) {
      [_cache setObject:obj forKey:obj];
      mo = obj;
   } else {
      BOOL inMutable = [_mStore containsObject:obj];
      BOOL inImm     = [_iStore containsObject:obj];
      [_memory removeObject:obj];
      if (inMutable) [_mStore removeObject:obj];
      if (inImm)     [_iStore removeObject:obj];
   }
   return mo;
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
-(id<ORObjectiveFunction>) objective
{
   return _objective;
}
-(id<ORIdArray>) intVars
{
   ORInt cnt = 0;
   for(id<ORVar> xk in _vars) 
     cnt += [xk conformsToProtocol:@protocol(ORIntVar)];
   id<ORIdArray> rv = [ORFactory idArray:self range:RANGE(self,0,cnt-1)];
   cnt = 0;
   for(id<ORVar> xk in _vars)
     if ([xk conformsToProtocol:@protocol(ORIntVar)]) {
       [rv set:xk at:cnt];
       cnt++;
     }
   return rv;
}
-(id<ORRealVarArray>)realVars
{
   ORInt k=0,nbReal = 0;
   for(id<ORVar> xk in _vars)
      nbReal += [xk conformsToProtocol:@protocol(ORRealVar)];
   id<ORIdArray> rv = [ORFactory idArray:self range:RANGE(self,0,nbReal-1)];
   for(id<ORVar> xk in _vars)
      if ([xk conformsToProtocol:@protocol(ORRealVar)])
         rv[k++] = xk;
   return (id<ORRealVarArray>)rv;
}
-(id<ORBitVarArray>)bitVars
{
   ORInt k=0,nbBV = 0;
   for(id<ORVar> xk in _vars)
      nbBV += [xk conformsToProtocol:@protocol(ORBitVar)];
   id<ORIdArray> rv = [ORFactory idArray:self range:RANGE(self,0,nbBV-1)];
   for(id<ORVar> xk in _vars)
      if ([xk conformsToProtocol:@protocol(ORBitVar)])
         rv[k++] = xk;
   return (id<ORBitVarArray>)rv;
}

-(NSArray*) variables
{
   // [ldm] Why copy them out. NSArray is immutable anyhow.
   return _vars;//[NSArray arrayWithArray: _vars];
}
-(NSArray*) constraints
{
   return _cStore;//[NSArray arrayWithArray: _cStore];
}
-(NSArray*) mutables
{
   return _mStore;//[NSArray arrayWithArray: _mStore];
}
-(NSArray*) immutables
{
   return _iStore;//[NSArray arrayWithArray: _iStore];
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
   [obj release];
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
      [obj release];
      return obj;
   } else {
      if (co != obj)
         [obj release];
      return co;
   }
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
   //printf("T(%p) mStore(%p) SZ: %lu  --- NBO = %d\n",[NSThread currentThread],_mStore,[_mStore count],_nbObjects);fflush(stdout);
   [_mStore addObject:obj];
   [_memory addObject:obj];
   [obj release];
   return obj;
}
-(id) trackVariable: (id) var
{
   [var setId:_nbObjects++];
   [_vars addObject:var];
   [_mStore addObject:var];
   [_memory addObject:var];
   [var release];
   return var;
}
-(id<ORConstraint>) add: (id<ORConstraint>) c
{
   [c close];
   if ([[c class] conformsToProtocol:@protocol(ORRelation)]) {
      c = [ORFactory algebraicConstraint: self expr: (id<ORRelation>)c];
   }
   if (c.getId == -1)
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

-(id<ORObjectiveFunction>) minimizeVar: (id<ORVar>) x
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
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
{
    _objective = [[ORMaximizeLinearI alloc] initORMaximizeLinearI: array coef: coef];
    return [self trackObjective: _objective];
}
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
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
   // DAN
   for(id<ORObject> c in _vars)
      doVar(c);
   for(id<ORObject> c in _mStore)
      doMutable(c);
   for(id<ORObject> c in _iStore)
      doImmutable(c);
//   for(id<ORObject> c in _vars)
//      doVar(c);
   for(id<ORObject> c in _cStore)
      doCons(c);
   doObjective(_objective);
   
}
-(void) visit: (ORVisitor*) visitor
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
-(id<ORModel>) relaxConstraints: (NSArray*) cstrs {
    id<ORModel> relaxation = [[ORModelI alloc] initWithModel: self relax: cstrs];
    return relaxation;
}
-(id<ORModel>) flatten:(id<ORAnnotation>)ncpy
{
   id<ORModel> flatModel = [ORFactory createModel:_nbObjects mappings: _mappings];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:self annotation:ncpy];
   id<ORModelTransformation> flat = [ORFactory createFlattener:batch];
   [flat apply: self with:ncpy];
   [batch release];
   [flatModel setSource:self];
   [flat release];
   return flatModel;
}
-(id<ORModel>) lsflatten:(id<ORAnnotation>)ncpy
{
   id<ORModel> flatModel = [ORFactory createModel:_nbObjects mappings: _mappings];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:self annotation:ncpy];
   id<ORModelTransformation> flat = [ORFactory createLSFlattener:batch];
   [flat apply: self with:ncpy];
   [batch release];
   [flatModel setSource:self];
   [flat release];
   return flatModel;
}
-(id<ORModel>) lpflatten:(id<ORAnnotation>)ncpy
{
   id<ORModel> flatModel = [ORFactory createModel:_nbObjects mappings: _mappings];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:self annotation:ncpy];
   id<ORModelTransformation> flat = [ORFactory createLPFlattener:batch];
   [flat apply: self with:ncpy];
   [batch release];
   [flatModel setSource:self];
   [flat release];
   return flatModel;
}
-(id<ORModel>) mipflatten:(id<ORAnnotation>)ncpy
{
   id<ORModel> flatModel = [ORFactory createModel:_nbObjects mappings: _mappings];
   id<ORAddToModel> batch  = [ORFactory createBatchModel: flatModel source:self annotation:ncpy];
   id<ORModelTransformation> flat = [ORFactory createMIPFlattener:batch];
   [flat apply: self with:ncpy];
   [batch release];
   [flatModel setSource:self];
   [flat release];
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
   id<ORAnnotation> _notes;
   id<ORConstraint> _current;  // reference to the source constraint being current during a model transformation.
}
-(ORBatchModel*)init: (ORModelI*) theModel source:(ORModelI*)src annotation:(id<ORAnnotation>)notes 
{
   self = [super init];
   _target = theModel;
   _src    = src;
   _notes  = notes;
   _current = nil;
   //NSLog(@"size: %zu",class_getInstanceSize([ORBatchModel class]));
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
-(id<ORModelMappings>) modelMappings
{
   return [_target modelMappings];
}
-(void) setCurrent:(id<ORConstraint>)cstr
{
   _current = cstr;
}
-(id<ORConstraint>) addConstraint: (id<ORConstraint>) cstr
{
   if (cstr && (id)cstr != [NSNull null]) {
      [_target add: cstr];
      [_target.modelMappings.tau set:cstr forKey:_current];
      [_notes transfer: _current toConstraint: cstr];
   }
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
-(id)inCache:(id)obj
{
   return[_target inCache:obj];
}
-(id)addToCache:(id)obj
{
   return [_target addToCache:obj];
}
-(id)memoize:(id) obj
{
   return [_target memoize:obj];
}

-(id<ORObjectiveFunction>) minimizeVar: (id<ORVar>) x
{
   return [_target minimizeVar:x];
}
-(id<ORObjectiveFunction>) maximizeVar:(id<ORVar>) x
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
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
{
    return [_target minimize: array coef: coef];
}
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
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

@implementation ORParameterizedModelI
{
    NSMapTable* _paramMap;
    NSMutableArray* _params;
}
-(ORParameterizedModelI*) initORParamModelI
{
    self = [super initORModelI];
    _paramMap = [[NSMapTable alloc] init];
    _params = [[NSMutableArray alloc] initWithCapacity: 32];
    return self;
}
-(ORParameterizedModelI*) initORParamModelI: (ORUInt) nb mappings: (id<ORModelMappings>) mappings
{
    self = [self initORModelI:nb mappings: mappings];
    _paramMap = [[NSMapTable alloc] init];
    _params = [[NSMutableArray alloc] initWithCapacity: 32];
    return self;
}
-(ORParameterizedModelI*) initWithParamModel: (ORParameterizedModelI*) src
{
    self = [super initWithModel: src];
    _paramMap = [[NSMapTable alloc] init];
    _params = [[NSMutableArray alloc] initWithCapacity: 32];
    return self;
}
-(ORParameterizedModelI*) initWithModel: (ORModelI*) src relax: (NSArray*)cstrs
{
    self = [super initWithModel: src relax: cstrs];
    _paramMap = [[NSMapTable alloc] init];
    _params = [[NSMutableArray alloc] initWithCapacity: 32];
    return self;
}
-(void) dealloc
{
    NSLog(@"ORParameterizedModelI [%p] dealloc called...\n",self);
    [super dealloc];
}
-(id) copyWithZone:(NSZone*)zone
{
    ORModelI* clone = [[ORParameterizedModelI allocWithZone:zone] initWithParamModel:self];
    return clone;
}
-(NSArray*) softConstraints
{
    NSArray* cstrs = [self constraints];
    NSMutableArray* softCstrs = [[NSMutableArray alloc] initWithCapacity: 64];
    for(id<ORConstraint> c in cstrs)
        if([c conformsToProtocol: @protocol(ORSoftConstraint)])
            [softCstrs addObject: c];
    return softCstrs;
}
-(NSArray*) hardConstraints
{
    NSArray* cstrs = [self constraints];
    NSMutableArray* hardCstrs = [[NSMutableArray alloc] initWithCapacity: 64];
    for(id<ORConstraint> c in cstrs)
        if(![c conformsToProtocol: @protocol(ORSoftConstraint)])
            [hardCstrs addObject: c];
    return hardCstrs;
}
-(id<ORVarArray>) slacks {
    NSArray* softCstrs = [self softConstraints];
    id<ORIntRange> slackRange = RANGE(self, 0, (ORInt)softCstrs.count-1);
    id<ORVarArray> slacks = (id<ORVarArray>)[ORFactory idArray: self range: slackRange with: ^id(ORInt i) {
        id<ORSoftConstraint> c = [softCstrs objectAtIndex: i];
        return [c slack];
    }];
    return slacks;
}
-(NSArray*) parameters
{
    return _params;
}
-(void) addParameter: (id<ORParameter>)p {
    [_params addObject: p];
}
-(id<ORWeightedVar>) parameterization: (id<ORVar>)x
{
    return [_paramMap objectForKey: x];
}
-(id<ORWeightedVar>) parameterizeVar: (id<ORVar>)x
{
    id<ORWeightedVar> c = [[ORRealWeightedVarI alloc] initRealWeightedVar: x];
    [_paramMap setObject: c forKey: x];
    [_params addObject: [c weight]];
    [self add: c];
    return c;
}
@end

typedef void(^ArrayEnumBlock)(id,NSUInteger,BOOL*);

@implementation ORBatchGroup {
   id<ORAddToModel>     _target;
   id<ORGroup>        _theGroup;
   id<ORConstraint>    _current;
}
-(ORBatchGroup*)init: (id<ORAddToModel>) model group:(id<ORGroup>)group
{
   self = [super init];
   _target = model;
   _theGroup = group;
   _current = nil;
   return self;
}
-(void)setCurrent:(id<ORConstraint>)cstr
{
   _current = cstr;
}
-(id<ORTracker>)tracker
{
   return [_target tracker];
}
-(id<ORModelMappings>) modelMappings
{
   return [_target modelMappings];
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
-(id<ORObjectiveFunction>) minimizeVar: (id<ORVar>) x
{
   return [_target minimizeVar:x];
}
-(id<ORObjectiveFunction>) maximizeVar: (id<ORVar>) x
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
-(id<ORObjectiveFunction>) minimize: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
{
    return [_target minimize: array coef: coef];
}
-(id<ORObjectiveFunction>) maximize: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
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

-(ORInt) size
{
    return (ORInt)[_all count];
}

-(void) emptyPool
{
    [_all removeAllObjects];
}

-(void) enumerateWith:(void(^)(id<ORConstraint>))block
{
  [_all enumerateObjectsUsingBlock:^(id  _Nonnull obj,BOOL * _Nonnull stop) {
      block(obj);
    }];
}
@end

@implementation OROrderedConstraintSetI
-(id) init
{
    self = [super init];
    _all = [[NSMutableArray alloc] initWithCapacity:64];
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

-(id<ORConstraint>) at:(ORInt)index {
    return [_all objectAtIndex: index];
}

-(void) enumerateWith:(void(^)(id<ORConstraint>))block
{
    [_all enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
        block(obj);
    }];
}

@end

