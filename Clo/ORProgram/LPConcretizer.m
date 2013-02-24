/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORSet.h>
#import <objmp/LPSolverI.h>
#import "LPProgram.h"
#import "LPConcretizer.h"

static int nbRows = 7;
static int nbColumns = 12;

int b[7] = { 18209, 7692, 1333, 924, 26638, 61188, 13360 };
float c[12] = { 96, 76, 56, 11, 86, 10, 66, 86, 83, 12, 9, 81 };
float coef[7][12] = {
   { 19,   1,  10,  1,   1,  14, 152, 11,  1,   1, 1, 1},
   {  0,   4,  53,  0,   0,  80,   0,  4,  5,   0, 0, 0},
   {  4, 660,   3,  0,  30,   0,   3,  0,  4,  90, 0, 0},
   {  7,   0,  18,  6, 770, 330,   7,  0,  0,   6, 0, 0},
   {  0,  20,   0,  4,  52,   3,   0,  0,  0,   5, 4, 0},
   {  0,   0,  40, 70,   4,  63,   0,  0, 60,   0, 4, 0},
   {  0,  32,   0,  0,   0,   5,   0,  3,  0, 660, 0, 9}};


int maini()
{
   
   @try {
      
      LPSolverI* lp = [LPFactory solver];
      [lp print];
      
      LPVariableI* x[nbColumns];
      for(ORInt i = 0; i < nbColumns; i++)
         x[i] = [lp createVariable];
      
      LPLinearTermI* obj = [lp createLinearTerm];
      for(ORInt i = 0; i < nbColumns; i++)
         [obj add: c[i] times: x[i]];
      LPObjectiveI* o = [lp postObjective: [lp createMaximize: obj]];
      
      LPConstraintI* c[nbRows];
      for(ORInt i = 0; i < nbRows; i++) {
         LPLinearTermI* t = [lp createLinearTerm];
         for(ORInt j = 0; j < nbColumns; j++)
            [t add: coef[i][j] times: x[j]];
         c[i] = [lp postConstraint: [lp createLEQ: t rhs: b[i]]];
      }
      
      [lp solve];
      [lp print];
      
      printf("Status: %d \n",[lp status]);
      printf("objective: %f \n",[o value]);
      for(ORInt i = 0; i < nbColumns; i++)
         printf("Value of %d is %f \n",i,[x[i] value]);
      for(ORInt i = 0; i < nbRows; i++)
         printf("Dual of %d is %f \n",i,[c[i] dual]);
      
      [lp release];
      
      printf("This works my friend\n");
   }
   @catch (NSException* ee) {
      printf("ExecutionError: %s \n",[[ee reason] cStringUsingEncoding: NSASCIIStringEncoding]);
   }
   return 0;
}


@implementation ORLPConcretizer
{
   id<LPProgram> _program;
   LPSolverI*    _lpsolver;
}
-(ORLPConcretizer*) initORLPConcretizer: (id<LPProgram>) program
{
   maini();
   self = [super init];
   _program = [program retain];
   _lpsolver = [program solver];
   return self;
}
-(void) dealloc
{
   NSLog(@"LP Concretizer released");
   [_program release];
   [super dealloc];
}

// Helper function
-(id) concreteVar: (id<ORVar>) x
{
   [x visit:self];
   return [x dereference];
}

-(id) concreteArray: (id<ORIntVarArray>) x
{
   [x visit: self];
   return [x dereference];
}

// visit interface

-(void) visitTrailableInt: (id<ORTrailableInt>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitIntSet: (id<ORIntSet>) v
{
   if ([v dereference] == NULL) {
      id<ORIntSet> i = [ORFactory intSet: _lpsolver];
      [i makeImpl];
      [v copyInto: i];
      [v setImpl: i];
   }
}
-(void) visitIntRange:(id<ORIntRange>) v
{
   [v makeImpl];
}

// pvh: this is bogus right now but this is easy for testing
-(void) visitIntVar: (id<ORIntVar>) v
{
   if ([v dereference] == NULL) {
      LPVariableI* cv = [_lpsolver createVariable];
      [v setImpl: cv];
   }
}

-(void) visitFloatVar: (id<ORFloatVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet for Float Variables"];
}

-(void) visitBitVar: (id<ORBitVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([v dereference] == NULL) {
//      id<CPBitVar> cv = [CPFactory bitVar:_engine withLow:[v low] andUp:[v up] andLength:[v bitLength]];
//     [v setImpl:cv];
//   }
}

-(void) visitAffineVar:(id<ORIntVar>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([v dereference] == NULL) {
//      id<ORIntVar> mBase = [v base];
//      [mBase visit: self];
//      ORInt a = [v scale];
//      ORInt b = [v shift];
//      id<CPIntVar> cv = [CPFactory intVar:(id<CPIntVar>)[mBase dereference] scale:a shift:b];
//      [v setImpl: cv];
//   }
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([v dereference] == NULL) {
//      id<ORIntVar> mBase = [v base];
//      [mBase visit:self];
//      ORInt lit = [v literal];
//      id<CPIntVar> cv = [CPFactory reifyView:(id<CPIntVar>)[mBase dereference] eqi:lit];
//      [v setImpl:cv];
//   }
}

-(void) visitIdArray: (id<ORIdArray>) v
{
   if ([v dereference] == NULL) {
      id<ORIntRange> R = [v range];
      id<ORIdArray> dx = [ORFactory idArray: _lpsolver range: R];
      [dx makeImpl];
      ORInt low = R.low;
      ORInt up = R.up;
      for(ORInt i = low; i <= up; i++) {
         [v[i] visit: self];
         dx[i] = [v[i] dereference];
      }
      [v setImpl: dx];
   }
}

-(void) visitIntArray:(id<ORIntArray>) v
{
   if ([v dereference] == NULL) {
      id<ORIntRange> R = [v range];
      id<ORIntArray> dx = [ORFactory intArray: _lpsolver range: R with: ^ORInt(ORInt i) { return [v at: i]; }];
      [dx makeImpl];
      [v setImpl: dx];
   }
}
-(void) visitIntMatrix: (id<ORIntMatrix>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([v dereference] == NULL) {
//      id<ORIntMatrix> n = [ORFactory intMatrix: _engine with: v];
//      [n makeImpl];
//      [v setImpl: n];
//   }
}

-(void) visitIdMatrix: (id<ORIdMatrix>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([v dereference] == NULL) {
//      ORInt nb = (ORInt) [v count];
//      for(ORInt k = 0; k < nb; k++)
//         [[v flat: k] visit: self];
//      id<ORIdMatrix> n = [ORFactory idMatrix: _engine withDereferenced: v];
//      [n makeImpl];
//      [v setImpl: n];
//   }
}

-(void) visitTable:(id<ORTable>) v
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([v dereference] == NULL) {
//      id<ORTable> n = [ORFactory table: _engine with: v];
//      [n makeImpl];
//      [v setImpl: n];
//   }
}
-(void) visitGroup:(id<ORGroup>)g
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([g dereference] == NULL) {
//      id<CPGroup> cg = nil;
//      switch([g type]) {
//        case BergeGroup:
//            cg = [CPFactory bergeGroup:_engine];
//            break;
//         default:
//            cg = [CPFactory group:_engine];
//            break;
//      }
//      [_engine add:cg]; // Do this first!!!! We want to have the group posted before posting the constraints of the group.
//      [g enumerateObjectWithBlock:^(id<ORConstraint> ck) {
//         [ck visit:self];
//         [cg add:[ck dereference]];
//      }];
//      [g setImpl:cg];
//   }
}


-(void) visitRestrict: (id<ORRestrict>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVar> x = [self concreteVar: [cstr var]];
//      id<CPConstraint> concrete = [CPFactory restrict: x to: [cstr restriction]];
//      [cstr setImpl:concrete];
//      [_engine add: concrete];
//   }
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVarArray> ax = [cstr array];
//      ORAnnotation n = [cstr annotation];
//      [ax visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory alldifferent: _engine over: [ax dereference] annotation: n];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVarArray> ax = [cstr array];
//      id<ORIntArray> low = [cstr low];
//      id<ORIntArray> up = [cstr up];
//      ORAnnotation n = [cstr annotation];
//      [ax visit: self];
//      [low visit: self];
//      [up visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory cardinality: [ax dereference] low: [low dereference] up: [up dereference] annotation: n];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitPacking: (id<ORPacking>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for Algebraic constraints"];
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization for Algebraic constraints"];
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVarArray> array = [cstr array];
//      id<ORTable> table = [cstr table];
//      [array visit: self];
//      [table visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory table: [table dereference] on: [array dereference]];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitCircuit:(id<ORCircuit>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVarArray> ax = [cstr array];
//      [ax visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory circuit: [ax dereference]];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitNoCycle:(id<ORNoCycle>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVarArray> ax = [cstr array];
//      [ax visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory nocycle: [ax dereference]];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitLexLeq:(id<ORLexLeq>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVarArray> x = [self concreteArray: [cstr x]];
//      id<CPIntVarArray> y = [self concreteArray: [cstr y]];
//      id<CPConstraint> concrete = [CPFactory lex: x leq: y];
//      [cstr setImpl:concrete];
//      [_engine add: concrete];
//   }
}
-(void) visitPackOne:(id<ORPackOne>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVarArray> item = [cstr item];
//      id<ORIntArray> itemSize = [cstr itemSize];
//      ORInt bin = [cstr bin];
//      id<ORIntVar> binSize = [cstr binSize];
//      [item visit: self];
//      [itemSize visit: self];
//      [binSize visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory packOne: [item dereference] itemSize: [itemSize dereference] bin: bin binSize: [binSize dereference]];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitKnapsack:(id<ORKnapsack>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVarArray> item = [cstr item];
//      id<ORIntArray> weight = [cstr weight];
//      id<ORIntVar> capacity = [cstr capacity];
//      [item visit: self];
//      [weight visit: self];
//      [capacity visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory knapsack: [item dereference] weight: [weight dereference] capacity: [capacity dereference]];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitAssignment:(id<ORAssignment>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr impl] == NULL) {
//      id<CPIntVarArray> x = [self concreteArray: [cstr x]];
//      id<ORIntMatrix> matrix = [cstr matrix];
//      [matrix visit: self];
//      id<CPIntVar> cost = [self concreteVar: [cstr cost]];
//      id<CPConstraint> concreteCstr = [CPFactory assignment: _engine array: x matrix: [matrix dereference] cost: cost];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}

-(void) visitMinimize: (id<ORObjectiveFunction>) v
{
   if ([v dereference] == NULL) {
      id<ORIntVar> o = [v var];
      [o visit: self];
      LPObjectiveI* concreteObj = [_lpsolver createObjectiveMinimize: [o dereference]];
      [v setImpl: concreteObj];
      [_lpsolver solve];
   }
}
-(void) visitMaximize: (id<ORObjectiveFunction>) v
{
   if ([v dereference] == NULL) {
      id<ORIntVar> o = [v var];
      [o visit: self];
      LPObjectiveI* concreteObj = [_lpsolver createObjectiveMaximize: [o dereference]];
      [v setImpl: concreteObj];
      [_lpsolver postObjective: concreteObj];
   }
}
-(void) visitEqualc: (id<OREqualc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory equalc: (id<CPIntVar>) [left dereference]  to: cst];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitNEqualc: (id<ORNEqualc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory notEqualc: (id<CPIntVar>) [left dereference]  to: cst];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitLEqualc: (id<ORLEqualc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory lEqualc: (id<CPIntVar>) [left dereference]  to: cst];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitGEqualc: (id<ORGEqualc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory gEqualc: (id<CPIntVar>) [left dereference]  to: cst];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitEqual: (id<OREqual>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVar> left  = [self concreteVar:[cstr left]];
//      id<CPIntVar> right = [self concreteVar:[cstr right]];
//      id<CPConstraint> concreteCstr = [CPFactory equal: left
//                                                    to: right
//                                                  plus: [cstr cst]
//                                            annotation: [cstr annotation]];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}

-(void) visitAffine: (id<ORAffine>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVar> y = [self concreteVar:[cstr left]];
//      id<CPIntVar> x = [self concreteVar:[cstr right]];
//      id<CPConstraint> concrete = [CPFactory affine:y equal:[cstr coef] times:x plus:[cstr cst] annotation:[cstr annotation]];
//      [cstr setImpl: concrete];
//      [_engine add:concrete];
//   }
}

-(void) visitNEqual: (id<ORNEqual>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory notEqual: (id<CPIntVar>) [left dereference] to: (id<CPIntVar>) [right dereference] plus: cst];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitLEqual: (id<ORLEqual>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      ORInt cst = [cstr cst];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory lEqual: (id<CPIntVar>) [left dereference] to: (id<CPIntVar>) [right dereference] plus: cst];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitPlus: (id<ORPlus>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      ORAnnotation annotation = [cstr annotation];
//      [res visit: self];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory equal3: (id<CPIntVar>) [res dereference]
//                                                     to: (id<CPIntVar>) [left dereference]
//                                                   plus: (id<CPIntVar>) [right dereference]
//                                             annotation:annotation
//                                       ];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitMult: (id<ORMult>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      [res visit: self];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory mult: (id<CPIntVar>) [left dereference]
//                                                   by: (id<CPIntVar>) [right dereference]
//                                                equal: (id<CPIntVar>) [res dereference]
//                                       ];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitSquare: (id<ORSquare>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] ==NULL) {
//      id<CPIntVar> res = [self concreteVar:[cstr res]];
//      id<CPIntVar> op  = [self concreteVar:[cstr op]];
//      ORAnnotation annotation = [cstr annotation];
//      id<CPConstraint> concrete = [CPFactory square:op equal:res annotation:annotation];
//      [cstr setImpl:concrete];
//      [_engine add:concrete];
//   }
}


-(void) visitMod: (id<ORMod>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVar> res = [self concreteVar:[cstr res]];
//      id<CPIntVar> left = [self concreteVar:[cstr left]];
//      id<CPIntVar> right = [self concreteVar:[cstr right]];
//      id<CPConstraint> concreteCstr  = [CPFactory mod:left mod:right equal:res];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitModc: (id<ORModc>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVar> res = [self concreteVar:[cstr res]];
//      id<CPIntVar> left = [self concreteVar:[cstr left]];
//      ORInt right = [cstr right];
//      id<CPConstraint> concreteCstr  = [CPFactory mod:left modi:right equal:res];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}


-(void) visitAbs: (id<ORAbs>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      [res visit: self];
//      [left visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory abs: (id<CPIntVar>) [left dereference]
//                                               equal: (id<CPIntVar>) [res dereference]
//                                          annotation: DomainConsistency
//                                       ];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitOr: (id<OROr>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      [res visit: self];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) [left dereference]
//                                                      or: (id<CPIntVar>) [right dereference]
//                                                   equal: (id<CPIntVar>) [res dereference]
//                                       ];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitAnd:( id<ORAnd>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      [res visit: self];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) [left dereference]
//                                                     and: (id<CPIntVar>) [right dereference]
//                                                   equal: (id<CPIntVar>) [res dereference]
//                                       ];
//      
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitImply: (id<ORImply>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> res = [cstr res];
//      id<ORIntVar> left = [cstr left];
//      id<ORIntVar> right = [cstr right];
//      [res visit: self];
//      [left visit: self];
//      [right visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory boolean: (id<CPIntVar>) [left dereference]
//                                                   imply: (id<CPIntVar>) [right dereference]
//                                                   equal: (id<CPIntVar>) [res dereference]
//                                       ];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitElementCst: (id<ORElementCst>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntArray> array = [cstr array];
//      id<ORIntVar> idx = [cstr idx];
//      id<ORIntVar> res = [cstr res];
//      [array visit: self];
//      [idx visit: self];
//      [res visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory element: (id<CPIntVar>) [idx dereference]
//                                             idxCstArray: [array dereference]
//                                                   equal: (id<CPIntVar>) [res dereference]
//                                              annotation: [cstr annotation]
//                                       ];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitElementVar: (id<ORElementVar>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVarArray> array = [self concreteArray:[cstr array]];
//      id<CPIntVar> idx = [self concreteVar:[cstr idx]];
//      id<CPIntVar> res = [self concreteVar:[cstr res]];
//      id<CPConstraint> concreteCstr = [CPFactory element: idx
//                                             idxVarArray: array
//                                                   equal: res
//                                              annotation: [cstr annotation]
//                                       ];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitReifyEqualc: (id<ORReifyEqualc>) cstr
{
   
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      ORInt cst = [cstr cst];
//      [b visit: self];
//      [x visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] eqi: cst];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitReifyEqual: (id<ORReifyEqual>) cstr
{
   
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      id<ORIntVar> y = [cstr y];
//      ORAnnotation annotation = [cstr annotation];
//      [b visit: self];
//      [x visit: self];
//      [y visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] eq: [y dereference] annotation: annotation];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
//   
}
-(void) visitReifyNEqualc: (id<ORReifyNEqualc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      ORInt cst = [cstr cst];
//      [b visit: self];
//      [x visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] neqi: cst];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitReifyNEqual: (id<ORReifyNEqual>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      id<ORIntVar> y = [cstr y];
//      ORAnnotation annotation = [cstr annotation];
//      [b visit: self];
//      [x visit: self];
//      [y visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] neq: [y dereference] annotation: annotation];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitReifyLEqualc: (id<ORReifyLEqualc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      ORInt cst = [cstr cst];
//      [b visit: self];
//      [x visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] leqi: cst];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitReifyLEqual: (id<ORReifyLEqual>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVar> b = [self concreteVar:[cstr b]];
//      id<CPIntVar> x = [self concreteVar:[cstr x]];
//      id<CPIntVar> y = [self concreteVar:[cstr y]];
//      id<CPConstraint> concreteCstr = [CPFactory reify: b with: x leq: y annotation: Default];
//      [cstr setImpl:concreteCstr];
//      [_engine add:concreteCstr];
//   }
}
-(void) visitReifyGEqualc: (id<ORReifyGEqualc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<ORIntVar> b = [cstr b];
//      id<ORIntVar> x = [cstr x];
//      ORInt cst = [cstr cst];
//      [b visit: self];
//      [x visit: self];
//      id<CPConstraint> concreteCstr = [CPFactory reify: [b dereference] with: [x dereference] geqi: cst];
//      [cstr setImpl: concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitReifyGEqual: (id<ORReifyGEqual>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVar> b = [self concreteVar:[cstr b]];
//      id<CPIntVar> x = [self concreteVar:[cstr x]];
//      id<CPIntVar> y = [self concreteVar:[cstr y]];
//      id<CPConstraint> concreteCstr = [CPFactory reify: b with: y leq: x annotation: Default];
//      [cstr setImpl:concreteCstr];
//      [_engine add:concreteCstr];
//   }
}
-(void) visitSumBoolEqualc: (id<ORSumBoolEqc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
//      id<CPConstraint> concreteCstr = [CPFactory sumbool:x eq:[cstr cst]];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitSumBoolLEqualc:(id<ORSumBoolLEqc>) cstr
{
   @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL)
//      @throw [[ORExecutionError alloc] initORExecutionError: "SumBoolLEqualc not yet implemented"];
}
-(void) visitSumBoolGEqualc:(id<ORSumBoolGEqc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
//      id<CPConstraint> concreteCstr = [CPFactory sumbool:x geq:[cstr cst]];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitSumEqualc:(id<ORSumEqc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
//      id<CPConstraint> concreteCstr = [CPFactory sum:x eq:[cstr cst]];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitSumLEqualc:(id<ORSumLEqc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPIntVarArray> x = [self concreteArray:[cstr vars]];
//      id<CPConstraint> concreteCstr = [CPFactory sum:x leq:[cstr cst]];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitSumGEqualc:(id<ORSumGEqc>) cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
}

-(void) visitLinearEq: (id<ORLinearEq>) c
{
   if ([c dereference] == NULL) {
      id<ORIntVarArray> x = [c vars];
      id<ORIntArray> a = [c coefs];
      ORInt cst = [c cst];
      [x visit: self];
      id<LPVariableArray> dx = [x dereference];
      [a visit: self];
      id<ORIntArray> da = [a dereference];
      NSLog(@" array %@ ",dx);
      LPConstraintI* concreteCstr = [_lpsolver createEQ: dx coef: da cst: -cst];
      [c setImpl:concreteCstr];
      [_lpsolver postConstraint: concreteCstr];
   }
}
-(void) visitLinearLeq: (id<ORLinearLeq>) c
{
   if ([c dereference] == NULL) {
      id<ORIntVarArray> x = [c vars];
      id<ORIntArray> a = [c coefs];
      ORInt cst = [c cst];
      [x visit: self];
      id<LPVariableArray> dx = [x dereference];
      [a visit: self];
      id<ORIntArray> da = [a dereference];
      NSLog(@" array leq %@ ",da);
      LPConstraintI* concreteCstr = [_lpsolver createLEQ: dx coef: da cst: -cst];
      [c setImpl:concreteCstr];
      [_lpsolver postConstraint: concreteCstr];
   }
}

// Bit
-(void) visitBitEqual:(id<ORBitEqual>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPBitVar> x = [self concreteVar:[cstr left]];
//      id<CPBitVar> y = [self concreteVar:[cstr right]];
//      id<CPConstraint> concreteCstr = [CPFactory bitEqual:x to:y];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}

-(void) visitBitOr:(id<ORBitOr>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPBitVar> x = [self concreteVar:[cstr left]];
//      id<CPBitVar> y = [self concreteVar:[cstr right]];
//      id<CPBitVar> z = [self concreteVar:[cstr res]];
//      id<CPConstraint> concreteCstr = [CPFactory bitOR:x or:y equals:z];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}

-(void) visitBitAnd:(id<ORBitAnd>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPBitVar> x = [self concreteVar:[cstr left]];
//      id<CPBitVar> y = [self concreteVar:[cstr right]];
//      id<CPBitVar> z = [self concreteVar:[cstr res]];
//      id<CPConstraint> concreteCstr = [CPFactory bitAND:x and:y equals:z];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}
-(void) visitBitNot:(id<ORBitNot>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPBitVar> x = [self concreteVar:[cstr left]];
//      id<CPBitVar> y = [self concreteVar:[cstr right]];
//      id<CPConstraint> concreteCstr = [CPFactory bitNOT:x equals:y];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}

-(void) visitBitXor:(id<ORBitXor>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPBitVar> x = [self concreteVar:[cstr left]];
//      id<CPBitVar> y = [self concreteVar:[cstr right]];
//      id<CPBitVar> z = [self concreteVar:[cstr res]];
//      id<CPConstraint> concreteCstr = [CPFactory bitXOR:x xor:y equals:z];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}

-(void) visitBitShiftL:(id<ORBitShiftL>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPBitVar> x = [self concreteVar:[cstr left]];
//      id<CPBitVar> y = [self concreteVar:[cstr right]];
//      ORInt p = [cstr places];
//      id<CPConstraint> concreteCstr = [CPFactory bitShiftL:x by:p equals:y];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}

-(void) visitBitRotateL:(id<ORBitRotateL>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPBitVar> x = [self concreteVar:[cstr left]];
//      id<CPBitVar> y = [self concreteVar:[cstr right]];
//      ORInt p = [cstr places];
//      id<CPConstraint> concreteCstr = [CPFactory bitRotateL:x by:p equals:y];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}

-(void) visitBitSum:(id<ORBitSum>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPBitVar> x = [self concreteVar:[cstr left]];
//      id<CPBitVar> y = [self concreteVar:[cstr right]];
//      id<CPBitVar> z = [self concreteVar:[cstr res]];
//      id<CPBitVar> ci = [self concreteVar:[cstr in]];
//      id<CPBitVar> co = [self concreteVar:[cstr out]];
//      id<CPConstraint> concreteCstr = [CPFactory bitADD:x plus:y withCarryIn:ci equals:z withCarryOut:co];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}

-(void) visitBitIf:(id<ORBitIf>)cstr
{
      @throw [[ORExecutionError alloc] initORExecutionError: "No concretization yet"];
//   if ([cstr dereference] == NULL) {
//      id<CPBitVar> w = [self concreteVar:[cstr res]];
//      id<CPBitVar> x = [self concreteVar:[cstr trueIf]];
//      id<CPBitVar> y = [self concreteVar:[cstr equals]];
//      id<CPBitVar> z = [self concreteVar:[cstr zeroIfXEquals]];
//      id<CPConstraint> concreteCstr = [CPFactory bitIF:w equalsOneIf:x equals:y andZeroIfXEquals:z];
//      [cstr setImpl:concreteCstr];
//      [_engine add: concreteCstr];
//   }
}

//
-(void) visitIntegerI: (id<ORInteger>) e
{
   if ([e dereference] == NULL) {
      id<ORInteger> n = [ORFactory integer: _lpsolver value: [e value]];
      [n makeImpl];
      [e setImpl: n];
   }
}
-(void) visitExprPlusI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprMinusI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprMulI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprModI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprNEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprLEqualI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprSumI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprProdI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprAbsI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprNegateI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprCstSubI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprDisjunctI:(id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprConjunctI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprImplyI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprAggOrI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
-(void) visitExprVarSubI: (id<ORExpr>) e
{
   @throw [[ORExecutionError alloc] initORExecutionError: "concretization of experession not yet implemented"];
}
@end


