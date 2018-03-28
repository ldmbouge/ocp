/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/CPConcretizer.h>
#import <ORProgram/ORProgram.h>
#import <CPUKernel/CPEngine.h>
#import <objcp/CPFactory.h>
#import <objcp/CPConstraint.h>
#import <objcp/CPBitConstraint.h>
#import <ORFoundation/ORVisit.h>
#import <objcp/CPBasicConstraint.h> //order ?

@implementation ORCPConcretizer

-(ORCPConcretizer*) initORCPConcretizer: (id<CPCommonProgram>) solver annotation:(id<ORAnnotation>)notes
{
   self = [super init];
   _solver = [solver retain];
   _engine = [_solver engine];
   _gamma = [solver gamma];
   _notes = notes;
   return self;
}
-(void) dealloc
{
   [_solver release];
   [super dealloc];
}
-(BOOL)isConcretized:(id<ORObject>)obj
{
   return _gamma[obj.getId] != nil;
}
-(BOOL)mustConcretize:(id<ORObject>)obj
{
   return _gamma[obj.getId] == nil;
}
-(id)gamma:(id<ORObject>)obj
{
   return _gamma[obj.getId];
}
- (void)doesNotRecognizeSelector:(SEL)aSelector
{
   NSLog(@"DID NOT RECOGNIZE a selector %@",NSStringFromSelector(aSelector));
   @throw [[ORExecutionError alloc] initORExecutionError:"ORCPConcretizer missing a selector"];
   //return [super doesNotRecognizeSelector:aSelector];
}
// Helper function
-(id) concreteVar: (id<ORVar>) x
{
   [x visit:self];
   return _gamma[x.getId];
}
-(id) scaleVar:(id<ORVar>) x coef:(ORInt)a
{
   [x visit:self];
   return [CPFactory intVar:_gamma[x.getId] scale:a];
}
-(id) concreteArray: (id<ORVarArray>) x
{
   [x visit: self];
   return _gamma[x.getId];
}

-(id) concreteIdArray: (id<ORIdArray>) x
{
   [x visit: self];
   return _gamma[x.getId];
}

-(id)concreteMatrix: (id<ORIntVarMatrix>) m
{
   [m visit:self];
   return _gamma[m.getId];
}
// visit interface

-(void) visitTrailableInt: (id<ORTrailableInt>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORTrailableInt> n = [ORFactory trailableInt:_engine value: [v value]];
      _gamma[v.getId] = n;
   }
}
-(void) visitIntSet: (id<ORIntSet>) v
{}
-(void) visitIntRange:(id<ORIntRange>) v
{}
-(void) visitRealRange:(id<ORRealRange>)v
{}
-(void) visitFloatRange:(id<ORFloatRange>)v
{}
-(void) visitDoubleRange:(id<ORDoubleRange>)v
{}
-(void) visitLDoubleRange:(id<ORLDoubleRange>)v
{}
-(void) visitUniformDistribution:(id) v
{}

-(void) visitIntVar: (id<ORIntVar>) v
{
   if (!_gamma[v.getId]) 
      _gamma[v.getId] = [CPFactory intVar: _engine domain: [v domain]];
}

-(void) visitRealVar: (id<ORRealVar>) v
{
   if (!_gamma[v.getId])
      _gamma[v.getId] = [CPFactory realVar: _engine bounds: [v domain]];
}

-(void) visitRealParam:(id<ORRealParam>)v
{
    if (!_gamma[v.getId])
        _gamma[v.getId] = [CPFactory realParam: _engine initialValue: [v initialValue]];
}

-(void) visitFloatVar: (id<ORFloatVar>) v
{
    if (!_gamma[v.getId])
        _gamma[v.getId] = [CPFactory floatVar: _engine bounds: [v domain]];
}

-(void) visitDoubleVar: (id<ORDoubleVar>) v
{
    if (!_gamma[v.getId])
        _gamma[v.getId] = [CPFactory doubleVar: _engine bounds: [v domain]];
}

-(void) visitLDoubleVar: (id<ORLDoubleVar>) v
{
    if (!_gamma[v.getId])
        _gamma[v.getId] = [CPFactory ldoubleVar: _engine bounds: [v domain]];
}

-(void) visitBitVar: (id<ORBitVar>) v
{
   if (_gamma[v.getId] == NULL) 
      _gamma[v.getId] = [CPFactory bitVar:_engine withLow:[v low] andUp:[v up] andLength:[v bitLength]];
}

-(void) visitAffineVar:(id<ORIntVar>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntVar> mBase = [v base];
      [mBase visit: self];
      ORInt a = [v scale];
      ORInt b = [v shift];
      _gamma[v.getId] = [CPFactory intVar:(id<CPIntVar>) _gamma[mBase.getId] scale:a shift:b];
   }
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntVar> mBase = [v base];
      [mBase visit:self];
      ORInt lit = [v literal];
      _gamma[v.getId] = [CPFactory reifyView:(id<CPIntVar>) _gamma[mBase.getId] eqi:lit];
   }
}
-(void) visitIdArray: (id<ORIdArray>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntRange> R = [v range];
      id<ORIdArray> dx = [ORFactory idArray: _engine range: R];
      ORInt low = R.low;
      ORInt up = R.up;
      for(ORInt i = low; i <= up; i++) {
         [v[i] visit: self];
         dx[i] = _gamma[[v[i] getId]];
      }
      _gamma[v.getId] = dx;
   }
}
-(void) visitIntArray:(id<ORIntArray>) v
{
}
-(void) visitDoubleArray:(id<ORDoubleArray>) v
{
}
-(void) visitLDoubleArray:(id<ORDoubleArray>) v
{
}
-(void) visitFloatArray:(id<ORFloatArray>) v
{
}
-(void) visitIntMatrix: (id<ORIntMatrix>) v
{
}

-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   if (_gamma[v.getId] == NULL) {
      ORInt nb = (ORInt) [v count];
      for(ORInt k = 0; k < nb; k++)
         [[v flat: k] visit: self];
      id<ORIdMatrix> n = [ORFactory idMatrix: _engine with: v];
      for(ORInt k = 0; k < nb; k++)
         [n setFlat: _gamma[[[v flat: k] getId]] at: k];
      _gamma[v.getId] = n;
   }
}

-(void) visitTable:(id<ORTable>) v
{
}
-(void) visitGroup:(id<ORGroup>)g
{
   if (_gamma[g.getId] == NULL) {
      id<CPGroup> cg = nil;
      NSMutableSet* ov = nil;
      NSSet* vars = nil;
      switch([g type]) {
         case BergeGroup:
            cg = [CPFactory bergeGroup:_engine];
            break;
         case GuardedGroup: {
            id<CPIntVar> cGuard = [self concreteVar:[g guard]];
            cg = [CPFactory group:_engine guard:cGuard];
         } break;
         case CDGroup:
            cg = [CPFactory group:_engine];  // TOFIX:ldm
            break;
         case Group3B:
            ov = [[NSMutableSet alloc] init];
            @autoreleasepool {
            vars = [g variables];
               for(id<ORFloatVar> v in vars){
                  if([_notes isKBEligeble:v])
                     [ov addObject:v];
               }
            }
            if([_notes hasFilteringPercent])
               cg = [CPFactory group3B: _engine tracer:[_solver tracer] percent:[_notes kbpercent] avars:ov gamma:_solver];
            else
               cg = [CPFactory group3B: _engine tracer:[_solver tracer] avars:ov gamma:_solver];
            [ov release];
            break;
         default:
          cg = [CPFactory group:_engine];
         break;
      }
      [_engine add:cg]; // We want to have the group posted before posting the constraints of the group.
      id<CPEngine> old = _engine;
      _engine = (id)cg;
      [g enumerateObjectWithBlock:^(id<ORConstraint> ck) {
         [ck visit:self];
      }];
      _engine = old;
      _gamma[g.getId] = cg;
   }
}

-(void) visitCDGroup:(id<ORCDGroup>)g
{
   if (_gamma[g.getId] == NULL) {
      NSArray* avm  = g.varMap;
      ORInt low=FDMAXINT,up=FDMININT;
      for(id<ORIdArray> varOfClause in avm) {
         id<ORIntRange> r = varOfClause.range;
         low = min(low,r.low);
         up  = max(up,r.up);
      }
      id<CPVarArray> oVars = (id)[ORFactory idArray:_engine
                                              range:RANGE(_engine,low,up)
                                               with:^id<ORVar> PNONNULL(ORInt k) {
         return _gamma[k];
      }];
      NSMutableArray* cvm = [[NSMutableArray alloc] initWithCapacity:avm.count];
      for(id<ORVarArray> acm in avm) {
         id<CPVarArray> ccm = [CPFactory varArray:_engine range:acm.range];
         for(ORInt i=acm.range.low;i <= acm.range.up;i++) {
            id<ORVar> av = acm[i];
            if (av) {
               id<CPVar> cv = _gamma[getId(av)];
               ccm[i] = cv;
            }
         }
         [cvm addObject:ccm];
      }
      id<CPGroup> cg = [CPFactory cdisj: _engine originals: oVars varmap:cvm];
      [_engine add:cg];
      id<CPEngine> old = _engine;
      _engine = (id)cg;
      [g enumerateObjectWithBlock:^(id<ORGroup> ck) {
         [ck visit:self];
      }];
      _engine = old;
      _gamma[g.getId] = cg;
   }
}
-(void) visit3BGroup:(id<OR3BGroup>)g
{
   if (_gamma[g.getId] == NULL) {
      CP3BGroup* cg = nil;
      NSMutableSet* ov = [[NSMutableSet alloc] init];
      NSSet* vars = [g variables];
      for(id<ORFloatVar> v in vars){
         if([_notes isKBEligeble:v])
            [ov addObject:v];
      }
      [vars release];
      if([_notes hasFilteringPercent])
         cg = [CPFactory group3B: _engine tracer:[_solver tracer] percent:[_notes kbpercent] avars:ov gamma:_solver];
      else
         cg = [CPFactory group3B: _engine tracer:[_solver tracer] avars:ov gamma:_solver];
      [ov release];
      [_engine add:cg]; // We want to have the group posted before posting the constraints of the group.
      id<CPEngine> old = _engine;
      _engine = (id)cg;
      [g enumerateObjectWithBlock:^(id<ORConstraint> ck) {
         [ck visit:self];
      }];
      _engine = old;
      _gamma[g.getId] = cg;
   }
}
-(void) visitFail:(id<ORFail>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPConstraint> cc = [CPFactory fail:_engine];
      [_engine add:cc];
      _gamma[cstr.getId] = cc;
   }
}

-(void) visitRestrict: (id<ORRestrict>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> x = [self concreteVar: [cstr var]];
      id<CPConstraint> concrete = [CPFactory restrict: x to: [cstr restriction]];
      [_engine add: concrete];
      _gamma[cstr.getId] = concrete;
   }
}
-(void) visitLinearGeq: (id<ORLinearGeq>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVarArray> ex = [cstr vars];
        id<ORIntArray>    ec = [cstr coefs];
        ORInt c = [cstr cst];
        id<CPIntVarArray> vx = [CPFactory intVarArray:_engine range:ex.range with:^id<CPIntVar>(ORInt k) {
            return [CPFactory intVar:_gamma[ex[k].getId] scale: - [ec at:k] shift:0];
        }];
        id<CPConstraint> concreteCstr = [CPFactory sum:vx leq: -c];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitLinearLeq: (id<ORLinearLeq>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> ex = [cstr vars];
      id<ORIntArray>    ec = [cstr coefs];
      ORInt c = [cstr cst];
      id<CPIntVarArray> vx = [CPFactory intVarArray:_engine range:ex.range with:^id<CPIntVar>(ORInt k) {
         return [CPFactory intVar:_gamma[ex[k].getId] scale:[ec at:k] shift:0];
      }];
      id<CPConstraint> concreteCstr = [CPFactory sum:vx leq: c];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitLinearEq: (id<ORLinearEq>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      switch([cstr count]) {
         case 3: {
            // [ldm] We concretize for CP. So we can specialize for small arity constraints (like a ternary sum).
            id<ORIntVarArray> ex = [cstr vars];
            id<ORIntArray>    ec = [cstr coefs];
            ORInt c = [cstr cst];
            ORCLevel annotation = [_notes levelFor:cstr];
            id<CPIntVar> xp = [CPFactory intVar:_gamma[getId(ex[0])] scale:[ec at:0] shift: - c ];
            id<CPIntVar> yp = [CPFactory intVar:_gamma[getId(ex[1])] scale:[ec at:1] ];
            id<CPIntVar> zp = [CPFactory intVar:_gamma[getId(ex[2])] scale:-[ec at:2]];
            id<CPConstraint> concreteCstr = [CPFactory equal3:zp to:xp plus:yp annotation:annotation];
            [_engine add:concreteCstr];
            _gamma[getId(cstr)] = concreteCstr;
         }break;
         default: {
            id<ORIntVarArray> ex = [cstr vars];
            id<ORIntArray>    ec = [cstr coefs];
            ORInt c = [cstr cst];
            id<CPIntVarArray> vx = [CPFactory intVarArray:_engine range:ex.range with:^id<CPIntVar>(ORInt k) {
               return [CPFactory intVar:_gamma[ex[k].getId] scale:[ec at:k] shift:0];
            }];
            id<CPConstraint> concreteCstr = [CPFactory sum:vx eq: c];
            [_engine add:concreteCstr];
            _gamma[cstr.getId] = concreteCstr;
         }
      }
   }
}

-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      ORCLevel n = [_notes levelFor: cstr];
      id<CPIntVarArray> cax = [self concreteArray:(id)[cstr array]];
      id<CPConstraint> concreteCstr = [CPFactory alldifferent: _engine over: cax annotation: n];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitRegular:(id<ORRegular>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError:"No concretization for regular (it is decomposed)"];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      id<ORIntArray> low = [cstr low];
      id<ORIntArray> up = [cstr up];
      ORCLevel n = [_notes levelFor:cstr];
      [ax visit: self];
      [low visit: self];
      [up visit: self];
      id<CPConstraint> concreteCstr = [CPFactory cardinality: _gamma[ax.getId] low: low up: up annotation: n];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for Packing constraints"];
}
-(void) visitMultiknapsack: (id<ORMultiKnapsack>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for MultiKnapsack constraints"];
}
-(void) visitMultiknapsackOne: (id<ORMultiKnapsackOne>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for MultiKnapsackOne constraints"];
}
-(void) visitMeetAtmost: (id<ORMeetAtmost>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for MeetAtmost constraints"];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for Algebraic constraints"];
}
-(void) visitRealWeightedVar:(id<ORWeightedVar>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<CPRealVar>  z = [self concreteVar:[cstr z]];
        id<CPIntVar>    x = [self concreteVar:[cstr x]];
        id<ORParameter> w = [cstr weight];
        [w visit: self];
        id<CPRealVar> xv = [CPFactory realVar:_engine castFrom:x];
        id<CPConstraint> concreteCstr = [CPFactory realWeightedVar: z equal: xv weight: _gamma[w.getId]];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> array = [cstr array];
      id<ORTable> table = [cstr table];
      [array visit: self];
      [table visit: self];
      id<CPConstraint> concreteCstr = [CPFactory table: table on: _gamma[array.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitCircuit:(id<ORCircuit>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory circuit: _gamma[ax.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitPath:(id<ORPath>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory path:_gamma[ax.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSubCircuit:(id<ORCircuit>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory subCircuit: _gamma[ax.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitNocycle:(id<ORNoCycle>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> ax = [cstr array];
      [ax visit: self];
      id<CPConstraint> concreteCstr = [CPFactory path: _gamma[ax.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitLexLeq:(id<ORLexLeq>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray: [cstr x]];
      id<CPIntVarArray> y = [self concreteArray: [cstr y]];
      id<CPConstraint> concrete = [CPFactory lex: x leq: y];
      [_engine add: concrete];
      _gamma[cstr.getId] = concrete;
   }
}
-(void) visitPackOne:(id<ORPackOne>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> item = [cstr item];
      id<ORIntArray> itemSize = [cstr itemSize];
      ORInt bin = [cstr bin];
      id<ORIntVar> binSize = [cstr binSize];
      [item visit: self];
      [itemSize visit: self];
      [binSize visit: self];
      id<CPConstraint> concreteCstr = [CPFactory packOne: _gamma[item.getId] itemSize: itemSize bin: bin binSize: _gamma[binSize.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVarArray> item = [cstr item];
      id<ORIntArray> weight = [cstr weight];
      id<ORIntVar> capacity = [cstr capacity];
      [item visit: self];
      [weight visit: self];
      [capacity visit: self];
      id<CPConstraint> concreteCstr = [CPFactory knapsack: _gamma[item.getId] weight: weight capacity: _gamma[capacity.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray: [cstr x]];
      id<ORIntMatrix> matrix = [cstr matrix];
      [matrix visit: self];
      id<CPIntVar> cost = [self concreteVar: [cstr cost]];
      id<CPConstraint> concreteCstr = [CPFactory assignment: _engine array: x matrix: matrix cost: cost];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
   NSLog(@"Objective v.getId: %d",v.getId);
   NSLog(@"visitMinimizeVar: %@",_gamma[v.getId]);
   if (_gamma[v.getId] == NULL) {
      id<ORVar> o = [v var];
      [o visit: self];
      id<CPConstraint> concreteCstr = NULL;
      if ([o conformsToProtocol:@protocol(ORIntVar)])
         concreteCstr = [CPFactory minimize: _gamma[o.getId]];
      else
         concreteCstr = [CPFactory realMinimize: _gamma[o.getId]];
      _gamma[v.getId] = concreteCstr;
      [_engine add: concreteCstr];
      [_engine setObjective: _gamma[v.getId]];
   }
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORVar> o = [v var];
      [o visit: self];
      id<CPConstraint> concreteCstr = NULL;
      if ([o conformsToProtocol:@protocol(ORIntVar)])
         concreteCstr = [CPFactory maximize: _gamma[o.getId]];
      else
         concreteCstr = [CPFactory realMaximize: _gamma[o.getId]];
      _gamma[v.getId] = concreteCstr;
      [_engine add: concreteCstr];
      [_engine setObjective: _gamma[v.getId]];
   }
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of minimizeExpr not yet implemented"]; 
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of maximizeExpr not yet implemented"];    
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of minimizeLinear not yet implemented"]; 
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of minimizeLinear not yet implemented"]; 
}

-(void) visitRealEqualc: (id<ORRealEqualc>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORRealVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory realEqualc: (id<CPIntVar>) _gamma[left.getId]  to: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitEqualc: (id<OREqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory equalc: (id<CPIntVar>) _gamma[left.getId]  to: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitNEqualc: (id<ORNEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory notEqualc: (id<CPIntVar>) _gamma[left.getId]  to: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
      
   }
}
-(void) visitLEqualc: (id<ORLEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory lEqualc: (id<CPIntVar>) _gamma[left.getId]  to: cst];
      [_engine add: concreteCstr];
   }
}
-(void) visitGEqualc: (id<ORGEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      ORInt cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory gEqualc: (id<CPIntVar>) _gamma[left.getId]   to: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitEqual: (id<OREqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> left  = [self concreteVar:[cstr left]];
      id<CPIntVar> right = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory equal: left
                                                    to: right
                                                  plus: [cstr cst]
                                            annotation: [_notes levelFor:cstr]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitAffine: (id<ORAffine>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> y = [self concreteVar:[cstr left]];
      id<CPIntVar> x = [self concreteVar:[cstr right]];
      id<CPConstraint> concrete = [CPFactory affine:y equal:[cstr coef] times:x plus:[cstr cst]
                                         annotation:[_notes levelFor:cstr]];
      [_engine add:concrete];
      _gamma[cstr.getId] = concrete;
   }
}

-(void) visitNEqual: (id<ORNEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      ORInt cst = [cstr cst];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory notEqual: (id<CPIntVar>) _gamma[left.getId]  to: (id<CPIntVar>) _gamma[right.getId] plus: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSoftNEqual:(id<ORSoftNEqual>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVar> left = [cstr left];
        id<ORIntVar> right = [cstr right];
        id<ORVar> slack = [cstr slack];
        //ORInt cst = [cstr cst];
        [left visit: self];
        [right visit: self];
        [slack visit: self];
        id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[slack.getId] with: _gamma[left.getId] eq: _gamma[right.getId] annotation: Default];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitLEqual: (id<ORLEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> left  = [self scaleVar:[cstr left] coef:[cstr coefLeft]];
      id<CPIntVar> right = [self scaleVar:[cstr right] coef:[cstr coefRight]];
      id<CPConstraint> concreteCstr = [CPFactory lEqual: left  to: right plus: [cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitPlus: (id<ORPlus>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      ORCLevel annotation = [_notes levelFor:cstr];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory equal3: (id<CPIntVar>) _gamma[res.getId]
                                                     to: (id<CPIntVar>) _gamma[left.getId] 
                                                   plus: (id<CPIntVar>) _gamma[right.getId]
                                             annotation:annotation
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitMult: (id<ORMult>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory mult: (id<CPIntVar>) _gamma[left.getId] 
                by: (id<CPIntVar>) _gamma[right.getId]
                equal: (id<CPIntVar>) _gamma[res.getId]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSquare: (id<ORSquare>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPIntVar> op  = [self concreteVar:[cstr op]];
      ORCLevel annotation = [_notes levelFor:cstr];
      id<CPConstraint> concrete = [CPFactory square:op equal:res annotation:annotation];
      [_engine add:concrete];
      _gamma[cstr.getId] = concrete;
   }
}
-(void) visitRealSquare: (id<ORSquare>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPRealVar> res = [self concreteVar:[cstr res]];
      id<CPRealVar> op  = [self concreteVar:[cstr op]];
      ORCLevel annotation = [_notes levelFor:cstr];
      id<CPConstraint> concrete = [CPFactory realSquare:op equal:res annotation:annotation];
      [_engine add:concrete];
      _gamma[cstr.getId] = concrete;
   }
}
-(void) visitMod: (id<ORMod>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPIntVar> left = [self concreteVar:[cstr left]];
      id<CPIntVar> right = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr  = [CPFactory mod:left mod:right equal:res];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitModc: (id<ORModc>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPIntVar> left = [self concreteVar:[cstr left]];
      ORCLevel annotation = [_notes levelFor:cstr];
      ORInt right = [cstr right];
      id<CPConstraint> concreteCstr  = [CPFactory mod:left modi:right equal:res annotation:annotation];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitMin:(id<ORMin>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPIntVar> left = [self concreteVar:[cstr left]];
      id<CPIntVar> right = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr  = [CPFactory min:left and:right equal:res];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }   
}

-(void) visitMax:(id<ORMin>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPIntVar> left = [self concreteVar:[cstr left]];
      id<CPIntVar> right = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr  = [CPFactory max:left and:right equal:res];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }   
}

-(void) visitAbs: (id<ORAbs>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      [res visit: self];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory abs: (id<CPIntVar>) _gamma[left.getId] 
                                               equal: (id<CPIntVar>) _gamma[res.getId]
                                          annotation: DomainConsistency
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitOr: (id<OROr>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) _gamma[left.getId] 
                                                      or: (id<CPIntVar>) _gamma[right.getId]
                                                   equal: (id<CPIntVar>) _gamma[res.getId]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitAnd:( id<ORAnd>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) _gamma[left.getId] 
                                                     and: (id<CPIntVar>) _gamma[right.getId]
                                                   equal: (id<CPIntVar>) _gamma[res.getId]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitImply: (id<ORImply>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> res = [cstr res];
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [res visit: self];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) _gamma[left.getId] 
                                                   imply: (id<CPIntVar>) _gamma[right.getId]
                                                   equal: (id<CPIntVar>) _gamma[res.getId]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitBinImply: (id<ORBinImply>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> left = [cstr left];
      id<ORIntVar> right = [cstr right];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) _gamma[left.getId]
                                                   imply: (id<CPIntVar>) _gamma[right.getId]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitElementCst: (id<ORElementCst>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntArray> array = [cstr array];
      id<ORIntVar> idx = [cstr idx];
      id<ORIntVar> res = [cstr res];
      [array visit: self];
      [idx visit: self];
      [res visit: self];
      id<CPConstraint> concreteCstr = [CPFactory element: (id<CPIntVar>) _gamma[idx.getId]
                                             idxCstArray: array
                                                   equal: (id<CPIntVar>) _gamma[res.getId]
                                              annotation: [_notes levelFor:cstr]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitRealElementCst: (id<ORRealElementCst>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORDoubleArray> array = [cstr array];
      id<ORIntVar> idx = [cstr idx];
      id<ORRealVar> res = [cstr res];
      [array visit: self];
      [idx visit: self];
      [res visit: self];
      id<CPConstraint> concreteCstr = [CPFactory realElement: (id<CPIntVar>) _gamma[idx.getId]
                                                  idxCstArray: array
                                                        equal: (id<CPRealVar>) _gamma[res.getId]
                                                   annotation: [_notes levelFor:cstr]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitElementVar: (id<ORElementVar>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> array = [self concreteArray:[cstr array]];
      id<CPIntVar> idx = [self concreteVar:[cstr idx]];
      id<CPIntVar> res = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory element: idx
                                             idxVarArray: array
                                                   equal: res
                                              annotation: [_notes levelFor:cstr]
                                       ];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitElementBitVar: (id<ORElementBitVar>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIdArray> array = [self concreteIdArray:[cstr array]];
      id<CPBitVar> idx = [self concreteVar:[cstr idx]];
      id<CPBitVar> res = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory element: idx
                                          idxBitVarArray: array
                                                   equal: res
                                              annotation: DomainConsistency
                                       ];
      
      
      
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitElementMatrixVar:(id<ORElementMatrixVar>)cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError:"reached elementMatrixVar in CPConcretizer"];
}
-(void) visitImplyEqualc: (id<ORImplyEqualc>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVar> b = [cstr b];
        id<ORIntVar> x = [cstr x];
        ORInt cst = [cstr cst];
        [b visit: self];
        [x visit: self];
        id<CPConstraint> concreteCstr = [CPFactory imply: _gamma[b.getId] with: _gamma[x.getId] eqi: cst];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] eqi: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyEqual: (id<ORReifyEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      id<ORIntVar> y = [cstr y];
      ORCLevel annotation = [_notes levelFor:cstr];
      [b visit: self];
      [x visit: self];
      [y visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] eq: _gamma[y.getId] annotation: annotation];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
   
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] neqi: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      id<ORIntVar> y = [cstr y];
      ORCLevel annotation = [_notes levelFor:cstr];
      [b visit: self];
      [x visit: self];
      [y visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] neq: _gamma[y.getId] annotation: annotation];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] leqi: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> b = [self concreteVar:[cstr b]];
      id<CPIntVar> x = [self concreteVar:[cstr x]];
      id<CPIntVar> y = [self concreteVar:[cstr y]];      
      id<CPConstraint> concreteCstr = [CPFactory reify: b with: x leq: y annotation: Default];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORIntVar> x = [cstr x];
      ORInt cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory reify: _gamma[b.getId] with: _gamma[x.getId] geqi: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> b = [self concreteVar:[cstr b]];
      id<CPIntVar> x = [self concreteVar:[cstr x]];
      id<CPIntVar> y = [self concreteVar:[cstr y]];
      id<CPConstraint> concreteCstr = [CPFactory reify: b with: y leq: x annotation: Default];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifySumBoolEqualc: (id<ORReifySumBoolEqc>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> b = [self concreteVar:[cstr b]];
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      ORCLevel lvl = [_notes levelFor:cstr];
      id<CPConstraint> concreteCstr = [CPFactory reify:b array:x eqi:[cstr cst] annotation:lvl];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitReifySumBoolGEqualc: (id<ORReifySumBoolGEqc>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> b = [self concreteVar:[cstr b]];
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      ORCLevel lvl = [_notes levelFor:cstr];
      id<CPConstraint> concreteCstr = [CPFactory reify:b array:x geqi:[cstr cst] annotation:lvl];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitHReifySumBoolEqualc: (id<ORReifySumBoolEqc>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> b = [self concreteVar:[cstr b]];
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      ORCLevel lvl = [_notes levelFor:cstr];
      id<CPConstraint> concreteCstr = [CPFactory hreify:b array:x eqi:[cstr cst] annotation:lvl];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitHReifySumBoolGEqualc: (id<ORReifySumBoolEqc>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> b = [self concreteVar:[cstr b]];
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      ORCLevel lvl = [_notes levelFor:cstr];
      id<CPConstraint> concreteCstr = [CPFactory hreify:b array:x geqi:[cstr cst] annotation:lvl];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitClause:(id<ORClause>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPIntVar> tv = [self concreteVar:[cstr targetValue]];
      id<CPConstraint> concreteCstr = [CPFactory clause:x eq:tv];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
      
   }
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sumbool:x eq:[cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSumBoolNEqualc: (id<ORSumBoolNEqc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sumbool:x neq:[cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>) cstr
{
   if (_gamma[cstr.getId] == NULL) 
      @throw [[ORExecutionError alloc] initORExecutionError: "SumBoolLEqualc not yet implemented"];
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sumbool:x geq:[cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSumEqualc:(id<ORSumEqc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sum:x eq:[cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSumLEqualc:(id<ORSumLEqc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
      id<CPConstraint> concreteCstr = [CPFactory sum:x leq:[cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitSumGEqualc:(id<ORSumGEqc>) cstr
{
}
-(void) visitRealLinearEq:(id<ORRealLinearEq>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPRealVarArray> x = (id)[ORFactory idArray:_engine range:av.range with:^id(ORInt k) {
            id<CPVar> theCPVar = [self concreteVar:[av at:k]];
            if ([theCPVar conformsToProtocol:@protocol(CPIntVar)])
                return [CPFactory realVar:_engine castFrom:(id)theCPVar];
            else
                return theCPVar;
        }];
        id<ORDoubleArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory realSum:x coef:c eqi:[cstr cst]];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatAssignC:(id<ORFloatAssignC>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORFloatVar> left = [cstr left];
      ORFloat cst = [cstr cst];
      [left visit: self];
      id<CPConstraint> concreteCstr = [CPFactory floatAssignC:_gamma[left.getId]  to: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitFloatEqualc:(id<ORFloatEqualc>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORFloatVar> left = [cstr left];
        ORFloat cst = [cstr cst];
        [left visit: self];
        id<CPConstraint> concreteCstr = [CPFactory floatEqualc:_gamma[left.getId]  to: cst];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatNEqualc:(id<ORFloatNEqualc>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORFloatVar> left = [cstr left];
        ORFloat cst = [cstr cst];
        [left visit: self];
        id<CPConstraint> concreteCstr = [CPFactory floatNEqualc: _gamma[left.getId]  to: cst];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatLinearEq:(id<ORFloatLinearEq>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORVarArray> av = [cstr vars];
      id<CPFloatVarArray> x = [self concreteArray:av];
      id<ORFloatArray> c = [cstr coefs];
      id<CPConstraint> concreteCstr = [CPFactory floatSum:x coef:c eqi:[cstr cst] annotation:_notes];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitFloatAssign:(id<ORFloatAssign>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORFloatVar> left = [cstr left];
      id<ORFloatVar> right = [cstr right];
      [left visit: self];
      [right visit: self];
      id<CPConstraint> concreteCstr = [CPFactory floatAssign:_gamma[left.getId]  to:_gamma[right.getId]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitFloatLinearNEq:(id<ORFloatLinearNEq>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPFloatVarArray> x = [self concreteArray:av];
        id<ORFloatArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory floatSum:x coef:c neqi:[cstr cst] annotation:_notes];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatLinearLT:(id<ORFloatLinearLT>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPFloatVarArray> x = [self concreteArray:av];
        id<ORFloatArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory floatSum:x coef:c lt:[cstr cst] annotation:_notes];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatLinearGT:(id<ORFloatLinearGT>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPFloatVarArray> x = [self concreteArray:av];
        id<ORFloatArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory floatSum:x coef:c gt:[cstr cst] annotation:_notes];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatLinearLEQ:(id<ORFloatLinearLEQ>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPFloatVarArray> x = [self concreteArray:av];
        id<ORFloatArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory floatSum:x coef:c leq:[cstr cst] annotation:_notes];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatLinearGEQ:(id<ORFloatLinearGEQ>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPFloatVarArray> x = [self concreteArray:av];
        id<ORFloatArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory floatSum:x coef:c geq:[cstr cst] annotation:_notes];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatMult:(id<ORFloatMult>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORFloatVar> res = [cstr res];
        id<ORFloatVar> left = [cstr left];
        id<ORFloatVar> right = [cstr right];
        [res visit: self];
        [left visit: self];
        [right visit: self];
        id<CPConstraint> concreteCstr = [CPFactory floatMult: (id<CPFloatVar>)_gamma[left.getId]
                                                     by: (id<CPFloatVar>) _gamma[right.getId]
                                                  equal: (id<CPFloatVar>) _gamma[res.getId]
                                                   annotation:_notes
                                         ];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatDiv:(id<ORFloatDiv>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORFloatVar> res = [cstr res];
        id<ORFloatVar> left = [cstr left];
        id<ORFloatVar> right = [cstr right];
        [res visit: self];
        [left visit: self];
        [right visit: self];
        id<CPConstraint> concreteCstr = [CPFactory floatDiv: (id<CPFloatVar>) _gamma[left.getId]
            by: (id<CPFloatVar>) _gamma[right.getId]
            equal: (id<CPFloatVar>) _gamma[res.getId]
            annotation:_notes
         ];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}

-(void) visitFloatReifyEqualc: (id<ORFloatReifyEqualc>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVar> b = [cstr b];
        id<ORFloatVar> x = [cstr x];
        ORFloat cst = [cstr cst];
        [b visit: self];
        [x visit: self];
        id<CPConstraint> concreteCstr = [CPFactory floatReify:(id<CPIntVar>)_gamma[b.getId] with:(id<CPFloatVar>)_gamma[x.getId] eqi: cst];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatReifyEqual: (id<ORFloatReifyEqual>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVar> b = [cstr b];
        id<ORFloatVar> x = [cstr x];
        id<ORFloatVar> y = [cstr y];
        ORCLevel annotation = [_notes levelFor:cstr];
        [b visit: self];
        [x visit: self];
        [y visit: self];
        id<CPConstraint> concreteCstr = [CPFactory floatReify: _gamma[b.getId] with: _gamma[x.getId] eq: _gamma[y.getId] annotation: annotation];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
    
}
-(void) visitFloatReifyNEqualc: (id<ORFloatReifyNEqualc>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVar> b = [cstr b];
        id<ORFloatVar> x = [cstr x];
        ORFloat cst = [cstr cst];
        [b visit: self];
        [x visit: self];
        id<CPConstraint> concreteCstr = [CPFactory floatReify: _gamma[b.getId] with: _gamma[x.getId] neqi: cst];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatReifyNEqual: (id<ORFloatReifyNEqual>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVar> b = [cstr b];
        id<ORFloatVar> x = [cstr x];
        id<ORFloatVar> y = [cstr y];
        ORCLevel annotation = [_notes levelFor:cstr];
        [b visit: self];
        [x visit: self];
        [y visit: self];
        id<CPConstraint> concreteCstr = [CPFactory floatReify: _gamma[b.getId] with: _gamma[x.getId] neq: _gamma[y.getId] annotation: annotation];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatReifyLEqualc: (id<ORFloatReifyLEqualc>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVar> b = [cstr b];
        id<ORFloatVar> x = [cstr x];
        ORFloat cst = [cstr cst];
        [b visit: self];
        [x visit: self];
        id<CPConstraint> concreteCstr = [CPFactory floatReify: _gamma[b.getId] with: _gamma[x.getId] leqi: cst];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatReifyLThenc: (id<ORFloatReifyLThenc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORFloatVar> x = [cstr x];
      ORFloat cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory floatReify: _gamma[b.getId] with: _gamma[x.getId] lti: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitFloatReifyLEqual: (id<ORFloatReifyLEqual>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<CPIntVar> b = [self concreteVar:[cstr b]];
        id<CPFloatVar> x = [self concreteVar:[cstr x]];
        id<CPFloatVar> y = [self concreteVar:[cstr y]];
        id<CPConstraint> concreteCstr = [CPFactory floatReify: b with: x leq: y annotation: Default];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatReifyGEqualc: (id<ORFloatReifyGEqualc>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORIntVar> b = [cstr b];
        id<ORFloatVar> x = [cstr x];
        ORFloat cst = [cstr cst];
        [b visit: self];
        [x visit: self];
        id<CPConstraint> concreteCstr = [CPFactory floatReify: _gamma[b.getId] with: _gamma[x.getId] geqi: cst];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitFloatReifyGThenc: (id<ORFloatReifyGThenc>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntVar> b = [cstr b];
      id<ORFloatVar> x = [cstr x];
      ORFloat cst = [cstr cst];
      [b visit: self];
      [x visit: self];
      id<CPConstraint> concreteCstr = [CPFactory floatReify: _gamma[b.getId] with: _gamma[x.getId] gti: cst];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitFloatReifyGEqual: (id<ORFloatReifyGEqual>) cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<CPIntVar> b = [self concreteVar:[cstr b]];
        id<CPFloatVar> x = [self concreteVar:[cstr x]];
        id<CPFloatVar> y = [self concreteVar:[cstr y]];
        id<CPConstraint> concreteCstr = [CPFactory floatReify: b with: y leq: x annotation: Default];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}

-(void) visitFloatReifyLThen: (id<ORFloatReifyLThen>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> b = [self concreteVar:[cstr b]];
      id<CPFloatVar> x = [self concreteVar:[cstr x]];
      id<CPFloatVar> y = [self concreteVar:[cstr y]];
      id<CPConstraint> concreteCstr = [CPFactory floatReify: b with: y lt: x annotation: Default];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitFloatReifyGThen: (id<ORFloatReifyGThen>) cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPIntVar> b = [self concreteVar:[cstr b]];
      id<CPFloatVar> x = [self concreteVar:[cstr x]];
      id<CPFloatVar> y = [self concreteVar:[cstr y]];
      id<CPConstraint> concreteCstr = [CPFactory floatReify: b with: y gt: x annotation: Default];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
//------
-(void) visitDoubleEqualc:(id<ORDoubleEqualc>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORDoubleVar> left = [cstr left];
        ORDouble cst = [cstr cst];
        [left visit: self];
        id<CPConstraint> concreteCstr = [CPFactory doubleEqualc:_gamma[left.getId]  to: cst];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitDoubleNEqualc:(id<ORDoubleNEqualc>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORDoubleVar> left = [cstr left];
        ORDouble cst = [cstr cst];
        [left visit: self];
        id<CPConstraint> concreteCstr = [CPFactory doubleNEqualc: _gamma[left.getId]  to: cst];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitDoubleLinearEq:(id<ORDoubleLinearEq>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPDoubleVarArray> x = [self concreteArray:av];
        id<ORDoubleArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory doubleSum:x coef:c eqi:[cstr cst]];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}

-(void) visitDoubleLinearNEq:(id<ORDoubleLinearNEq>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPDoubleVarArray> x = [self concreteArray:av];
        id<ORDoubleArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory doubleSum:x coef:c neqi:[cstr cst]];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitDoubleLinearLT:(id<ORDoubleLinearLT>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPDoubleVarArray> x = [self concreteArray:av];
        id<ORDoubleArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory doubleSum:x coef:c lt:[cstr cst]];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitDoubleLinearGT:(id<ORDoubleLinearGT>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPDoubleVarArray> x = [self concreteArray:av];
        id<ORDoubleArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory doubleSum:x coef:c gt:[cstr cst]];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitDoubleLinearLEQ:(id<ORDoubleLinearLEQ>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPDoubleVarArray> x = [self concreteArray:av];
        id<ORDoubleArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory doubleSum:x coef:c leq:[cstr cst]];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitDoubleLinearGEQ:(id<ORDoubleLinearGEQ>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORVarArray> av = [cstr vars];
        id<CPDoubleVarArray> x = [self concreteArray:av];
        id<ORDoubleArray> c = [cstr coefs];
        id<CPConstraint> concreteCstr = [CPFactory doubleSum:x coef:c geq:[cstr cst]];
        [_engine add:concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitDoubleMult:(id<ORDoubleMult>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORDoubleVar> res = [cstr res];
        id<ORDoubleVar> left = [cstr left];
        id<ORDoubleVar> right = [cstr right];
        [res visit: self];
        [left visit: self];
        [right visit: self];
        id<CPConstraint> concreteCstr = [CPFactory doubleMult: (id<CPDoubleVar>) _gamma[left.getId]
                                                          by: (id<CPDoubleVar>) _gamma[right.getId]
                                                       equal: (id<CPDoubleVar>) _gamma[res.getId]
                                         ];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void) visitDoubleDiv:(id<ORDoubleDiv>)cstr
{
    if (_gamma[cstr.getId] == NULL) {
        id<ORDoubleVar> res = [cstr res];
        id<ORDoubleVar> left = [cstr left];
        id<ORDoubleVar> right = [cstr right];
        [res visit: self];
        [left visit: self];
        [right visit: self];
        id<CPConstraint> concreteCstr = [CPFactory doubleDiv: (id<CPDoubleVar>) _gamma[left.getId]
                                                         by: (id<CPDoubleVar>) _gamma[right.getId]
                                                      equal: (id<CPDoubleVar>) _gamma[res.getId]
                                         ];
        [_engine add: concreteCstr];
        _gamma[cstr.getId] = concreteCstr;
    }
}
-(void)visitRealLinearLeq:(id<ORRealLinearLeq>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORVarArray> av = [cstr vars];
      id<CPRealVarArray> x = (id)[ORFactory idArray:_engine range:av.range with:^id(ORInt k) {
         id<CPVar> theCPVar = [self concreteVar:[av at:k]];
         if ([theCPVar conformsToProtocol:@protocol(CPIntVar)])
            return [CPFactory realVar:_engine castFrom:(id)theCPVar];
         else
            return theCPVar;
      }];
      id<ORDoubleArray> c = [cstr coefs];
      id<CPConstraint> concreteCstr = [CPFactory realSum:x coef:c leqi:[cstr cst]];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void)visitRealLinearGeq:(id<ORRealLinearGeq>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORVarArray> av = [cstr vars];
      id<CPRealVarArray> x = (id)[ORFactory idArray:_engine range:av.range with:^id(ORInt k) {
         id<CPVar> theCPVar = [self concreteVar:[av at:k]];
         if ([theCPVar conformsToProtocol:@protocol(CPIntVar)])
            return [CPFactory realVar:_engine castFrom:(id)theCPVar];
         else
            return theCPVar;
      }];
      id<ORDoubleArray> c = [cstr coefs];
      id<CPConstraint> concreteCstr = [CPFactory realSum:x coef:c geqi:[cstr cst]];
      [_engine add:concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitEqualAt:(id<ORBitEqualAt>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPConstraint> concreteCstr = [CPFactory bitEqualAt:x at:[cstr bit] to:[cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitEqualc:(id<ORBitEqualc>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPConstraint> concreteCstr = [CPFactory bitEqualc:x to:[cstr cst]];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

// Bit
-(void) visitBitEqual:(id<ORBitEqual>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory bitEqual:x to:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitOr:(id<ORBitOr>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitOR:x bor:y equals:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitAnd:(id<ORBitAnd>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitAND:x band:y equals:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitBitNot:(id<ORBitNot>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory bitNOT:x equals:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitXor:(id<ORBitXor>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitXOR:x bxor:y equals:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitShiftL:(id<ORBitShiftL>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      ORInt p = [cstr places];
      id<CPConstraint> concreteCstr = [CPFactory bitShiftL:x by:p equals:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitShiftL_BV:(id<ORBitShiftL_BV>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> places = [self concreteVar:[cstr places]];
      
      id<CPConstraint> concreteCstr;
      if(![places bound])
      {
         concreteCstr = [CPFactory bitShiftLBV:(CPBitVarI*)x by:(CPBitVarI*)places equals:(CPBitVarI*)y];
      }
      else
      {
         ORUInt p = [(CPBitVarI*)places getLow][0]._val;
         concreteCstr = [CPFactory bitShiftL:x by:p equals:y];
      }
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitShiftR:(id<ORBitShiftR>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      ORInt p = [cstr places];
      id<CPConstraint> concreteCstr = [CPFactory bitShiftR:x by:p equals:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitShiftR_BV:(id<ORBitShiftR_BV>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> places = [self concreteVar:[cstr places]];
      
      id<CPConstraint> concreteCstr;
      if(![places bound])
      {
         concreteCstr = [CPFactory bitShiftRBV:x by:places equals:y];
      }
      else
      {
         ORUInt p = [(CPBitVarI*)places getLow][0]._val;
         concreteCstr = [CPFactory bitShiftR:x by:p equals:y];
      }
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitShiftRA:(id<ORBitShiftRA>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      ORInt p = [cstr places];
      id<CPConstraint> concreteCstr = [CPFactory bitShiftRA:x by:p equals:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitShiftRA_BV:(id<ORBitShiftRA_BV>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> places = [self concreteVar:[cstr places]];

      id<CPConstraint> concreteCstr;
      if(![places bound])
      {
         concreteCstr = [CPFactory bitShiftRABV:x by:places equals:y];
      }
      else
      {
         ORUInt p = [(CPBitVarI*)places getLow][0]._val;
         concreteCstr = [CPFactory bitShiftRA:x by:p equals:y];
      }
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitRotateL:(id<ORBitRotateL>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      ORInt p = [cstr places];
      id<CPConstraint> concreteCstr = [CPFactory bitRotateL:x by:p equals:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitNegative:(id<ORBitNegative>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitNegative:x equals:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitSum:(id<ORBitSum>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPBitVar> ci = [self concreteVar:[cstr in]];
      id<CPBitVar> co = [self concreteVar:[cstr out]];
      id<CPConstraint> concreteCstr = [CPFactory bitADD:x plus:y withCarryIn:ci equals:z withCarryOut:co];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitSubtract:(id<ORBitSubtract>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitSubtract:x minus:y equals:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitMultiply:(id<ORBitMultiply>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitMultiply:x times:y equals:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitDivide:(id<ORBitDivide>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> q = [self concreteVar:[cstr res]];
      id<CPBitVar> r = [self concreteVar: [cstr rem]];
      id<CPConstraint> concreteCstr = [CPFactory bitDivide:x dividedby:y equals:q rem:r];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitIf:(id<ORBitIf>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> w = [self concreteVar:[cstr res]];
      id<CPBitVar> x = [self concreteVar:[cstr trueIf]];
      id<CPBitVar> y = [self concreteVar:[cstr equals]];
      id<CPBitVar> z = [self concreteVar:[cstr zeroIfXEquals]];
      id<CPConstraint> concreteCstr = [CPFactory bitIF:w equalsOneIf:x equals:y andZeroIfXEquals:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitBitCount:(id<ORBitCount>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPIntVar> p = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory bitCount:x count:p];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitBitChannel:(id<ORBitChannel>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPIntVar> p = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory bitChannel:x channel:p];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitBitZeroExtend:(id<ORBitZeroExtend>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory bitZeroExtend:x extendTo:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitBitSignExtend:(id<ORBitSignExtend>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPConstraint> concreteCstr = [CPFactory bitSignExtend:x extendTo:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitBitExtract:(id<ORBitExtract>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];

      ORUInt lsb = [cstr lsb];
      ORUInt msb = [cstr msb];
      id<CPConstraint> concreteCstr = [CPFactory bitExtract:x from:lsb to:msb eq:y];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitConcat:(id<ORBitConcat>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitConcat:x concat:y eq:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitLogicalEqual:(id<ORBitLogicalEqual>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitLogicalEqual:x EQ:y eval:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitLT:(id<ORBitLT>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitLT:x LT:y eval:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitBitLE:(id<ORBitLE>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitLE:x LE:y eval:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitSLE:(id<ORBitSLE>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitSLE:x SLE:y eval:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitSLT:(id<ORBitSLT>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitSLT:x SLT:y eval:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitITE:(id<ORBitITE>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> i = [self concreteVar:[cstr left]];
      id<CPBitVar> t = [self concreteVar:[cstr right1]];
      id<CPBitVar> e = [self concreteVar:[cstr right2]];
      id<CPBitVar> r = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitITE:i then:t else:e result:r];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitLogicalAnd:(id<ORBitLogicalAnd>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntRange> R = [[cstr left] range];
      id<CPBitVarArray> x = [CPFactory bitVarArray:_solver range:R];
      ORInt low = R.low;
      ORInt up = R.up;
      for(ORInt i = low; i <= up; i++) {
         x[i] = [self concreteVar:[cstr left][i]];
      }
      id<CPBitVar> r = [self concreteVar:[cstr res]];
      
      id<CPConstraint> concreteCstr = [CPFactory bitLogicalAnd:x eval:r];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitLogicalOr:(id<ORBitLogicalOr>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<ORIntRange> R = [[cstr left] range];
      id<CPBitVarArray> x = [CPFactory bitVarArray:_solver range:R];
      ORInt low = R.low;
      ORInt up = R.up;
      for(ORInt i = low; i <= up; i++) {
         x[i] = [self concreteVar:[cstr left][i]];
      }
      id<CPBitVar> r = [self concreteVar:[cstr res]];
      
      id<CPConstraint> concreteCstr = [CPFactory bitLogicalOr:x eval:r];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}
-(void) visitBitOrb:(id<ORBitOrb>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> r = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitOrb:x bor:y eval:r];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitNotb:(id<ORBitNotb>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> r = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitNotb:x eval:r];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitEqualb:(id<ORBitEqualb>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> r = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitEqualb:x equal:y eval:r];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitBitDistinct:(id<ORBitDistinct>)cstr
{
   if (_gamma[cstr.getId] == NULL) {
      id<CPBitVar> x = [self concreteVar:[cstr left]];
      id<CPBitVar> y = [self concreteVar:[cstr right]];
      id<CPBitVar> z = [self concreteVar:[cstr res]];
      id<CPConstraint> concreteCstr = [CPFactory bitDistinct:x distinctFrom:y eval:z];
      [_engine add: concreteCstr];
      _gamma[cstr.getId] = concreteCstr;
   }
}

-(void) visitIntegerI: (id<ORInteger>) e
{}
//
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   if (_gamma[e.getId] == NULL) 
      _gamma[e.getId] = [ORFactory mutable: _engine value: [e initialValue]];
}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{
   if (_gamma[e.getId] == NULL)
      _gamma[e.getId] = [ORFactory mutableDouble: _engine value: [e initialValue]];
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
   if (_gamma[e.getId] == NULL) 
      _gamma[e.getId] = [ORFactory double: _engine value: [e doubleValue]];
}
-(void) visitExprPlusI: (id<ORExpr>) e
{}
-(void) visitExprMinusI: (id<ORExpr>) e
{}
-(void) visitExprMulI: (id<ORExpr>) e
{}
-(void) visitExprDivI: (id<ORExpr>) e
{}
-(void) visitExprModI: (id<ORExpr>) e
{}
-(void) visitExprEqualI: (id<ORExpr>) e
{}
-(void) visitExprNEqualI: (id<ORExpr>) e
{}
-(void) visitExprLEqualI: (id<ORExpr>) e
{}
-(void) visitExprGEqualI: (id<ORExpr>) e
{}
-(void) visitExprLThenI: (id<ORExpr>) e
{}
-(void) visitExprGThenI: (id<ORExpr>) e
{}
-(void) visitExprSumI: (id<ORExpr>) e
{}
-(void) visitExprProdI: (id<ORExpr>) e
{}
-(void) visitExprAbsI:(id<ORExpr>) e
{}
-(void) visitExprSquareI:(id<ORExpr>)e
{}
-(void) visitExprNegateI:(id<ORExpr>) e
{}
-(void) visitExprCstSubI: (id<ORExpr>) e
{}
-(void) visitExprCstDoubleSubI:(id<ORExpr>)e
{}
-(void) visitExprDisjunctI:(id<ORExpr>) e
{}
-(void) visitExprConjunctI: (id<ORExpr>) e
{}
-(void) visitExprImplyI: (id<ORExpr>) e
{}
-(void) visitExprAggOrI: (id<ORExpr>) e
{}
-(void) visitExprAggAndI: (id<ORExpr>) e
{}
-(void) visitExprAggMinI: (id<ORExpr>) e
{}
-(void) visitExprAggMaxI: (id<ORExpr>) e
{}
-(void) visitExprVarSubI: (id<ORExpr>) e
{}
@end


@implementation ORCPSearchConcretizer {
   id<CPEngine>        _engine;
   id*                 _gamma;
}

-(ORCPSearchConcretizer*) initORCPConcretizer: (id<CPEngine>) engine gamma:(id<ORGamma>)gamma
{
   self = [super init];
   _engine = engine;
   _gamma = [gamma gamma];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
- (void)doesNotRecognizeSelector:(SEL)aSelector
{
   NSLog(@"DID NOT RECOGNIZE a selector %@",NSStringFromSelector(aSelector));
   @throw [[ORExecutionError alloc] initORExecutionError:"ORCPConcretizer missing a selector"];
}
// Helper function
-(id) concreteVar: (id<ORVar>) x
{
   [x visit:self];
   return _gamma[x.getId];
}
-(void) visitEqualc: (id<OREqualc>) cstr
{
   id<CPIntVar> left = [self concreteVar:[cstr left]];
   [_engine tryEnforce:^{
      [left bind:[cstr cst]];
   }];
}
-(void) visitNEqualc: (id<ORNEqualc>) cstr
{
   id<CPIntVar> left = [self concreteVar:[cstr left]];
   [_engine tryEnforce:^{
      [left remove:[cstr cst]];
   }];
}
-(void) visitLEqualc:(id<ORLEqualc>)cstr
{
   id<CPIntVar> left = [self concreteVar:cstr.left];
   [_engine tryEnforce:^{
      [left updateMax:cstr.cst];
   }];
}
-(void) visitGEqualc:(id<ORGEqualc>)cstr
{
   id<CPIntVar> left = [self concreteVar:cstr.left];
   [_engine tryEnforce:^{
      [left updateMin:cstr.cst];
   }];
}
-(void) visitBitEqualAt:(id<ORBitEqualAt>)cstr
{
   id<CPBitVar> left = [self concreteVar:cstr.left];
   [_engine tryEnforce:^{
      [left bind:cstr.bit to:cstr.cst];
   }];
}


-(void) visitIntVar: (id<ORIntVar>) v
{
   if (!_gamma[v.getId]) {
      if ([v hasDenseDomain])
         _gamma[v.getId] = [CPFactory intVar: _engine bounds: [v domain]];
      else
         _gamma[v.getId] = [CPFactory intVar: _engine domain: [v domain]];
   }
}

-(void) visitRealVar: (id<ORRealVar>) v
{
   if (!_gamma[v.getId])
      _gamma[v.getId] = [CPFactory realVar: _engine bounds: [v domain]];
}

-(void) visitBitVar: (id<ORBitVar>) v
{
   if (_gamma[v.getId] == NULL)
      _gamma[v.getId] = [CPFactory bitVar:_engine withLow:[v low] andUp:[v up] andLength:[v bitLength]];
}

-(void) visitAffineVar:(id<ORIntVar>) v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntVar> mBase = [v base];
      [mBase visit: self];
      ORInt a = [v scale];
      ORInt b = [v shift];
      _gamma[v.getId] = [CPFactory intVar:(id<CPIntVar>) _gamma[mBase.getId] scale:a shift:b];
   }
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
   if (_gamma[v.getId] == NULL) {
      id<ORIntVar> mBase = [v base];
      [mBase visit:self];
      ORInt lit = [v literal];
      _gamma[v.getId] = [CPFactory reifyView:(id<CPIntVar>) _gamma[mBase.getId] eqi:lit];
   }
}

@end

