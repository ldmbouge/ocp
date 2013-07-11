/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORMIPFlatten.h"
#import "ORModelI.h"
#import "ORVarI.h"
#import "ORDecompose.h"
#import "ORFloatLinear.h"
#import "ORFlatten.h"

@implementation ORMIPFlatten {
   id<ORAddToModel> _into;
   NSMapTable*     _mapping;
   id              _result;
   id<ORTau>        _tau;
}

-(id)initORMIPFlatten: (id<ORAddToModel>) into
{
   self = [super init];
   _into = into;
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

-(id<ORAddToModel>) target
{
   return _into;
}
-(id) flattenIt: (id) obj
{
   id fo = [_mapping objectForKey:obj];
   if (fo)
      return fo;
   else {
      id pr = _result;  // flattenIt must work if reentrant.
      _result = NULL;
      [obj visit: self];
      id rv = _result;
      _result = pr;     // restore what used to be result.
      if (rv == NULL)
         [_mapping setObject:[NSNull null] forKey:obj];
      else
         [_mapping setObject:rv forKey:obj];
      return rv;
   }
}
-(void) apply: (id<ORModel>) m
{
   _tau = m.tau;
   [m applyOnVar:^(id<ORVar> x) {
      [_into addVariable: [self flattenIt: x]];
   }
      onMutables:^(id<ORObject> x) {
         [_into addMutable:[self flattenIt:x]];
      }
    onImmutables:^(id<ORObject> x) {
       [_into addImmutable: x];
    }
   onConstraints:^(id<ORConstraint> c) {
      [_into addConstraint:[self flattenIt:c]];
   }
     onObjective:^(id<ORObjectiveFunction> o) {
        [self flattenIt:o];
     }];
}

+(id<ORConstraint>) flattenExpression:(id<ORExpr>)expr into:(id<ORAddToModel>)model annotation:(ORAnnotation)note
{
   id<ORLinear> terms = [ORNormalizer normalize: expr into: model annotation:note];
   id<ORConstraint> cstr = NULL;
   switch ([expr type]) {
      case ORRBad:
         assert(NO);
      case ORREq:
      {
         cstr = [terms postEQZ: model annotation: note];
      }
         break;
      case ORRNEq:
      {
         @throw [[ORExecutionError alloc] initORExecutionError: "No != constraint supported in LP yet"];
      }
         break;
      case ORRLEq:
      {
         cstr = [terms postLEQZ: model annotation: note];
      }
         break;
      default:
         assert(terms == nil);
         break;
   }
   [terms release];
   return cstr;
}

-(void) visitFloatVar: (ORFloatVarI*) v
{
   _result = v;
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   _result = e;
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   _result = e;
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{
   _result = e;
}
-(void) visitIntArray:(id<ORIntArray>)v
{
   _result = v;
}
-(void) visitFloatArray:(id<ORFloatArray>)v
{
   _result = v;
}
-(void) visitIntMatrix:(id<ORIntMatrix>)v
{
   _result = v;
}
-(void) visitTrailableInt:(id<ORTrailableInt>)v
{
   _result = v;
}
-(void) visitIntSet:(id<ORIntSet>)v
{
   _result = v;
}
-(void) visitIntRange:(id<ORIntRange>)v
{
   _result = v;
}
-(void) visitFloatRange:(id<ORFloatRange>)v
{
   _result = v;
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   _result = v;
}
-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   _result = v;
}
-(void) visitTable:(id<ORTable>) v
{
   _result = v;
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   _result = [ORMIPFlatten flattenExpression:[cstr expr] into: _into annotation:[cstr annotation]];
   [_tau set: _result forKey: cstr];
}
-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
   _result = [_into minimize:[v var]];
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   _result = [_into maximize:[v var]];
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   ORFloatLinear* terms = [ORNormalizer floatLinearFrom: [v expr] model: _into annotation: Default];
   _result = [_into minimize: [terms variables: _into] coef: [terms coefficients: _into]];
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   ORFloatLinear* terms = [ORNormalizer floatLinearFrom: [v expr] model: _into annotation: Default];
   _result = [_into maximize: [terms variables: _into] coef: [terms coefficients: _into]];
}

@end


