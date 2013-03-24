/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORError.h>
#import <ORModeling/ORSolver.h>
#import "ORModelI.h"

@implementation ORModelI
{
   NSMutableArray*          _vars;
   NSMutableArray*          _mStore;
   NSMutableArray*          _oStore;
   // pvh to clean once generalized
   id<ORObjectiveFunction>  _objective;
   ORUInt                   _name;
   NSMutableDictionary*     _cMap;
   NSMutableSet*            _ccSet;  // used only while constructing _cMap
   id<ORConstraint>         _cc;     // used only while constructing _cMap
}
-(ORModelI*) initORModelI
{
   self = [super init];
   _vars  = [[NSMutableArray alloc] init];
   _mStore = [[NSMutableArray alloc] initWithCapacity:32];
   _oStore = [[NSMutableArray alloc] initWithCapacity:32];
   _objective = nil;
   _name = 0;
   _cMap = [[NSMutableDictionary alloc] initWithCapacity:32];
   _ccSet = [[NSMutableSet alloc] initWithCapacity:32];
   _cc = NULL;
   return self;
}

-(void) dealloc
{
   NSLog(@"ORModelI [%p] dealloc called...\n",self);
   [_vars release];
   [_mStore release];
   [_oStore release];
   [_cMap release];
   [super dealloc];
}
-(void) captureVariable: (id<ORVar>) x
{
   [_vars addObject:x];
   [_oStore addObject:x];
}
-(void) setId: (ORUInt) name
{
   _name = name;
}
-(id<ORSolver>) solver
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
    return [NSArray arrayWithArray: _mStore];
}
-(NSArray*) objects
{
   return [NSArray arrayWithArray: _oStore];
}
-(id<ORSolution>) captureSolution
{
   return [[ORSolutionI alloc] initSolution:self];
}
-(id<ORSolutionPool>) solutions
{
   return [((id<ORASolver>) _impl) globalSolutionPool];
}
-(id<ORSolution>) bestSolution
{
   return [[self solutions] best];
}
-(void) addVariable:(id<ORVar>) var
{
   [self captureVariable: var];   
}
-(void )addObject:(id) object
{
   [self trackObject:object];
}
-(void) addConstraint:(id<ORConstraint>) cstr
{
   [self trackConstraint:cstr];
   [self add: cstr];
   if (_cc)
      [_ccSet addObject:cstr];
}
-(void) compiling:(id<ORConstraint>)cstr
{
   _cc = cstr;
   [_ccSet removeAllObjects];
}
-(NSSet*)compiledMap
{
   NSSet* rv = [[NSSet alloc] initWithSet:_ccSet];
   [self mappedConstraints:_cc toSet:rv];
   return rv;
}
-(void) restore: (id<ORSolution>) s
{
   NSArray* av = [self variables];
   [av enumerateObjectsUsingBlock:^(id<ORSavable> obj, NSUInteger idx, BOOL *stop) {
      [obj restore:[s value:obj]];
   }];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:512] autorelease];
   [buf appendFormat:@"vars[%ld] = {\n",[_vars count]];
   for(id<ORVar> v in _vars)
      [buf appendFormat:@"\t%@\n",v];
   [buf appendFormat:@"}\n"];

   [buf appendFormat:@"objects[%ld] = {\n",[_oStore count]];
   for(id<ORObject> v in _oStore)
      [buf appendFormat:@"\t%@\n",v];
   [buf appendFormat:@"}\n"];
   
   [buf appendFormat:@"cstr[%ld] = {\n",[_mStore count]];
   for(id<ORConstraint> c in _mStore)
      [buf appendFormat:@"\t%@\n",c];
   [buf appendFormat:@"}\n"];
   [buf appendFormat:@"map: %@",_cMap];
   return buf;
}
-(NSSet*) constraintsFor:(id<ORConstraint>)c
{
   return [_cMap objectForKey:@([c getId])];
}
-(void) mappedConstraints:(id<ORConstraint>)c toSet:(NSSet*)soc
{
   [_cMap setObject:soc forKey:@([c getId])];
}
-(NSDictionary*) cMap
{
   return _cMap;
}
-(id<ORConstraint>) add: (id<ORConstraint>) c
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      c = [ORFactory algebraicConstraint: self expr: (id<ORRelation>)c annotation:Default];
   ORConstraintI* cstr = (ORConstraintI*) c;
   [cstr setId: (ORUInt) [_mStore count]];
   [_mStore addObject:c];
   return c;
}

-(id<ORConstraint>) add: (id<ORConstraint>) c annotation: (ORAnnotation) n
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      c = [ORFactory algebraicConstraint: self expr: (id<ORRelation>)c annotation:n];
   
   ORConstraintI* cstr = (ORConstraintI*) c;
   [cstr setId: (ORUInt) [_mStore count]];
   [_mStore addObject:c];
   return c;
}

-(void) optimize: (id<ORObjectiveFunction>) o
{
   _objective = o;
}

-(id<ORObjectiveFunction>) minimize: (id<ORIntVar>) x
{
   _objective = [[ORMinimizeVarI alloc] initORMinimizeVarI: x];
   return _objective;
}

-(id<ORObjectiveFunction>) maximize: (id<ORIntVar>) x
{
   _objective = [[ORMaximizeVarI alloc] initORMaximizeVarI: x];
    return _objective;
}

-(id<ORObjectiveFunction>) maximizeExpr: (id<ORExpr>) e
{
   _objective = [[ORMaximizeExprI alloc] initORMaximizeExprI: e];
    return _objective;
}
-(id<ORObjectiveFunction>) minimizeExpr: (id<ORExpr>) e
{
   _objective = [[ORMinimizeExprI alloc] initORMinimizeExprI: e];
    return _objective;
}

-(id<ORObjectiveFunction>) maximize: (id<ORIntVarArray>) array coef: (id<ORIntArray>) coef
{
   _objective = [[ORMaximizeLinearI alloc] initORMaximizeLinearI: array coef: (id<ORIntArray>) coef];
    return _objective;
}
-(id<ORObjectiveFunction>) minimize: (id<ORIntVarArray>) array coef: (id<ORIntArray>) coef
{
   _objective = [[ORMinimizeLinearI alloc] initORMinimizeLinearI: array coef: (id<ORIntArray>) coef];
    return _objective;
}


-(void) trackObject: (id) obj;
{
   [_oStore addObject:obj];
}
-(void) trackVariable: (id) var;
{
   [var setId: (ORUInt) [_vars count]];
   [_vars addObject:var];
   [_oStore addObject:var];
}
-(void) trackConstraint:(id)obj
{
   [_oStore addObject:obj];
}
-(void)  applyOnVar: (void(^)(id<ORObject>)) doVar
          onObjects: (void(^)(id<ORObject>)) doObjs
      onConstraints:(void(^)(id<ORObject>)) doCons
        onObjective:(void(^)(id<ORObject>)) doObjective
{
   for(id<ORObject> c in _vars)
      doVar(c);
   for(id<ORObject> c in _oStore)
      doObjs(c);
   for(id<ORObject> c in _mStore)
      doCons(c);
   doObjective(_objective);
}
-(void) visit: (id<ORVisitor>) visitor
{
   for(id<ORObject> c in _vars)
      [c visit: visitor];
   for(id<ORObject> c in _oStore)
      [c visit: visitor];
   for(id<ORObject> c in _mStore)
      [c visit: visitor];
   [_objective visit: visitor];
}
- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_vars];
   [aCoder encodeObject:_oStore];
   [aCoder encodeObject:_mStore];
   [aCoder encodeObject:_objective];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _vars = [[aDecoder decodeObject] retain];
   _oStore = [[aDecoder decodeObject] retain];
   _mStore = [[aDecoder decodeObject] retain];
   _objective = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}
@end

@implementation ORBatchModel
{
   ORModelI* _target;
   ORModelI* _src;
   id<ORConstraint>     _cc;
   NSMutableSet*     _ccSet;
}
-(ORBatchModel*)init: (ORModelI*) theModel source:(ORModelI*)src
{
   self = [super init];
   _target = theModel;
   _src    = src;
   _cc     = NULL;
   _ccSet  = [[NSMutableSet alloc] initWithCapacity:32];
   return self;
}
-(void) addVariable: (id<ORVar>) var
{
   [_target addVariable: var];
}
-(void) addObject: (id) object
{
   [_target trackObject: object];
}
-(void) addConstraint: (id<ORConstraint>) cstr
{
   [_target trackConstraint:cstr];
   [_target add: cstr];
   if (_cc) {
      [_ccSet addObject:cstr];
   }
}
-(id<ORModel>) model
{
   return _target;
}
-(id<ORObjectiveFunction>) minimize: (id<ORIntVar>) x
{
   return [_target minimize:x];
}
-(id<ORObjectiveFunction>) maximize:(id<ORIntVar>) x
{
   return [_target maximize: x];
}
-(id<ORObjectiveFunction>) minimizeExpr: (id<ORExpr>) x
{
   return [_target minimizeExpr: x];
}
-(id<ORObjectiveFunction>) maximizeExpr:(id<ORExpr>) x
{
   return [_target maximizeExpr: x];
}
-(id<ORObjectiveFunction>) minimize: (id<ORIntVarArray>) array coef: (id<ORIntArray>) coef
{
   return [_target minimize: array coef: coef];
}
-(id<ORObjectiveFunction>) maximize: (id<ORIntVarArray>) array coef: (id<ORIntArray>) coef
{
  return [_target maximize: array coef: coef];
}

-(void) trackObject: (id) obj
{
   [_target trackObject:obj];
}
-(void) trackVariable: (id) obj
{
   [_target trackVariable: obj];
}
-(void) trackConstraint: (id) obj
{
   [_target trackConstraint: obj];
}
-(void) compiling:(id<ORConstraint>)cstr
{
   _cc = cstr;
   [_ccSet removeAllObjects];
}
-(NSSet*)compiledMap
{
   NSSet* rv = [[NSSet alloc] initWithSet:_ccSet];
   [_src mappedConstraints:_cc toSet:rv];
   return rv;
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
-(void) addVariable: (id<ORVar>) var
{
   [_target addVariable:var];
}
-(void) addObject:(id)object
{
   [_target addObject:object];
}
-(void) addConstraint: (id<ORConstraint>) cstr
{
   [_theGroup add:cstr];
}
-(id<ORObjectiveFunction>) minimize: (id<ORIntVar>) x
{
   return [_target minimize:x];
}
-(id<ORObjectiveFunction>) maximize: (id<ORIntVar>) x
{
   return [_target maximize:x];
}
-(id<ORObjectiveFunction>) minimizeExpr: (id<ORExpr>) x
{
   return [_target minimizeExpr: x];
}
-(id<ORObjectiveFunction>) maximizeExpr:(id<ORExpr>) x
{
   return [_target maximizeExpr: x];
}
-(id<ORObjectiveFunction>) minimize: (id<ORIntVarArray>) array coef: (id<ORIntArray>) coef
{
   return [_target minimize: array coef: coef];
}
-(id<ORObjectiveFunction>) maximize: (id<ORIntVarArray>) array coef: (id<ORIntArray>) coef
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
-(void)trackConstraint:(id)obj
{
   [_target trackConstraint:obj];
}
-(void) compiling:(id<ORConstraint>)cstr
{
}
-(NSSet*)compiledMap
{
   return NULL;
}
@end

@implementation ORSolutionI {
   NSArray*                _shots;
   id<ORObjectiveValue> _objValue;
}
-(ORSolutionI*) initSolution: (id<ORModel>) model
{
   self = [super init];
   NSArray* av = [model variables];
   ORULong sz = [av count];
   NSMutableArray* snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
   [av enumerateObjectsUsingBlock: ^void(id obj, NSUInteger idx, BOOL *stop) {
      id<ORSavable> shot = [obj snapshot];
      if (shot)
         [snapshots addObject: shot];
      [shot release];
   }];
   _shots = snapshots;
   if ([model objective])
      _objValue = [[model objective] value];
   else
      _objValue = nil;
   return self;
}
-(void) dealloc
{
   [_shots release];
   [_objValue release];
   [super dealloc];
}
-(BOOL)isEqual:(id)object
{
   if ([object isKindOfClass:[self class]]) {
      ORSolutionI* other = object;
      if (_objValue && other->_objValue) {
         if ([_objValue isEqual:other->_objValue]) {
            return [_shots isEqual:other->_shots];
         } else return NO;
      } else return NO;
   }
   else
      return NO;
}
-(NSUInteger)hash
{
   return [_shots hash];
}
-(id<ORObjectiveValue>)objectiveValue
{
   return _objValue;
}
-(id<ORSnapshot>) value:(id)var
{
   NSUInteger idx = [var getId];
   if (idx < [_shots count])
      return [_shots objectAtIndex:idx];
   else return nil;
}
-(ORInt) intValue: (id) var
{
   return [[_shots objectAtIndex:[var getId]] intValue];   
}
-(BOOL) boolValue: (id) var
{
   return [[_shots objectAtIndex:[var getId]] boolValue];   
}
-(NSUInteger) count
{
   return [_shots count];   
}
- (void) encodeWithCoder: (NSCoder *)aCoder
{
   [aCoder encodeObject:_shots];
   [aCoder encodeObject:_objValue];
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
   self = [super init];
   _shots = [[aDecoder decodeObject] retain];
   _objValue = [aDecoder decodeObject];
   return self;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   if (_objValue)
      [buf appendFormat:@"SOL[%@](",_objValue];
   else
      [buf appendString:@"SOL("];
   NSUInteger last = [_shots count] - 1;
   [_shots enumerateObjectsUsingBlock:^(id<ORSnapshot> obj, NSUInteger idx, BOOL *stop) {
      [buf appendFormat:@"%@%c",obj,idx < last ? ',' : ')'];
   }];
   return buf;
}
@end


@implementation ORSolutionPoolI
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

-(void) addSolution:(id<ORSolution>)s
{
   [_all addObject:s];
}

-(void) enumerateWith:(void(^)(id<ORSolution>))block
{
   [_all enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
      block(obj);
   }];
}

-(NSString*) description
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
      } else {
         id<ORObjectiveValue> nv = [obj objectiveValue];
         if ([nv key] < [bestSoFar key]) {
            bestSoFar = nv;
            sel = obj;
         }
      }
   }];
   return [sel retain];
}
@end
