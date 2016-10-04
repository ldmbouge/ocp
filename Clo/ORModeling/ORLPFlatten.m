/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORLPFlatten.h"
#import "ORModelI.h"
#import "ORVarI.h"
#import "ORDecompose.h"
#import "ORRealDecompose.h"

@implementation ORLPFlatten {
    id<ORAddToModel> _into;
    NSMapTable*     _mapping;
    id              _result;
    id<ORAnnotation> _notes;
    id<ORTau>       _tau;
}

-(id)initORLPFlatten: (id<ORAddToModel>) into
{
    self = [super init];
    _into = into;
    _notes = nil;
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

static BOOL _alreadyAdded;

-(void) apply: (id<ORModel>) m  with:(id<ORAnnotation>)notes
{
    _notes = notes;
    _tau = [_into modelMappings].tau;
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
       _alreadyAdded = NO;
       id<ORConstraint> fc = [self flattenIt:c];
       if (!_alreadyAdded)
          [_into addConstraint:fc];
       //assert(_alreadyAdded == YES);
    }
      onObjective:^(id<ORObjectiveFunction> o) {
         [self flattenIt:o];
      }];
}

+(id<ORConstraint>) flattenExpression:(id<ORExpr>)expr into:(id<ORAddToModel>)model
{
    id<ORLinear> terms = [ORNormalizer normalize: expr into: model];
    id<ORConstraint> cstr = NULL;
    switch ([expr type]) {
       case ORRBad:
          assert(NO);
       case ORREq:
       {
          cstr = [terms postEQZ: model];
          _alreadyAdded = YES;
       }
          break;
       case ORRNEq:
       {
          @throw [[ORExecutionError alloc] initORExecutionError: "No != constraint supported in LP yet"];
       }
          break;
       case ORRLEq:{
          cstr = [terms postLEQZ: model];
          _alreadyAdded = YES;
       }break;
       case ORRGEq: {
          cstr = [terms postGEQZ:model];
          _alreadyAdded = YES;
       }break;
       default:
          assert(terms == nil);
          break;
    }
    [terms release];
    return cstr;
}

-(void) visitIntVar: (ORIntVarI*) v
{
    _result = v;
}
-(void) visitRealVar: (ORRealVarI*) v
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
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{
    _result = e;
}

-(void) visitIntArray:(id<ORIntArray>)v
{
    _result = v;
}
-(void) visitDoubleArray:(id<ORDoubleArray>)v
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
-(void) visitRealRange:(id<ORRealRange>)v
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
-(void) visitLinearEq: (id<ORLinearEq>) c
{
   _result = c;
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) c
{
   _result = c;
}
-(void) visitLinearLeq: (id<ORLinearLeq>) c
{
   _result = c;
}


-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
    _result = [ORLPFlatten flattenExpression:[cstr expr] into: _into];
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
    ORRealLinear* terms = [ORNormalizer realLinearFrom: [v expr] model: _into];
    _result = [_into minimize: [terms variables: _into] coef: [terms coefficients: _into]];
    [terms release];
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) v
{
    ORRealLinear* terms = [ORNormalizer realLinearFrom: [v expr] model: _into];
    _result = [_into maximize: [terms variables: _into] coef: [terms coefficients: _into]];
    [terms release];
}

@end

