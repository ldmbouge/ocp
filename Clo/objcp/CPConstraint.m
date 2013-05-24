/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPTypes.h"
#import "CPError.h"
#import "CPFactory.h"
#import "CPConstraint.h"
#import "CPAllDifferentDC.h"
#import "CPCardinality.h"
#import "CPCardinalityDC.h"
#import "CPValueConstraint.h"
#import "CPEquationBC.h"
#import "CPElement.h"
#import "CPCircuitI.h"
#import "CPTableI.h"
#import "CPAssignmentI.h"
#import "CPLexConstraint.h"
#import "CPBinPacking.h"
#import "CPKnapsack.h"

@implementation CPFactory (Constraint)

// alldifferent
+(id<ORConstraint>) alldifferent: (id<CPEngine>) cp over: (id<CPIntVarArray>) x
{
   id<ORConstraint> o = [[CPAllDifferentDC alloc] initCPAllDifferentDC: cp over: x];
   [cp trackMutable: o];
   return o;
}
+(id<ORConstraint>) alldifferent: (id<CPIntVarArray>) x
{
    return [CPFactory alldifferent: x annotation: DomainConsistency];
}
+(id<ORConstraint>) alldifferent: (id<CPIntVarArray>) x annotation: (ORAnnotation) c
{
    id<ORConstraint> o;
    switch (c) {
        case DomainConsistency: 
            o = [[CPAllDifferentDC alloc] initCPAllDifferentDC:[x tracker] over:x];
            break;
        case ValueConsistency:
            o = [[CPAllDifferenceVC alloc] initCPAllDifferenceVC:x]; 
            break;
        case RangeConsistency:
            @throw [[ORExecutionError alloc] initORExecutionError: "Range Consistency Not Implemented on alldifferent"];            
            break;
        default:
            @throw [[ORExecutionError alloc] initORExecutionError: "Consistency Not Implemented on alldifferent"]; 
    }
    [[x tracker] trackMutable: o];
    return o;
}
+(id<ORConstraint>) alldifferent: (id<CPEngine>) engine over: (id<CPIntVarArray>) x annotation: (ORAnnotation) c
{
   id<ORConstraint> o;
   switch (c) {
      case DomainConsistency:
         o = [[CPAllDifferentDC alloc] initCPAllDifferentDC: engine over: x];
         break;
      case ValueConsistency:
         o = [[CPAllDifferenceVC alloc] initCPAllDifferenceVC: engine over: x];
         break;
      case RangeConsistency:
         @throw [[ORExecutionError alloc] initORExecutionError: "Range Consistency Not Implemented on alldifferent"];
         break;
      default:
         @throw [[ORExecutionError alloc] initORExecutionError: "Consistency Not Implemented on alldifferent"];
   }
   [[x tracker] trackMutable: o];
   return o;
   
}
// cardinality
+(id<ORConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up
{
    return [CPFactory cardinality: x low: low up: up annotation: ValueConsistency];
}
+(id<ORConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up annotation: (ORAnnotation) c
{ 
    id<ORConstraint> o;
    switch (c) {
        case ValueConsistency:
            o = [[CPCardinalityCst alloc] initCardinalityCst: x low: low up: up]; 
            break;
        case RangeConsistency:
            @throw [[ORExecutionError alloc] initORExecutionError: "Range Consistency Not Implemented on cardinality"];            
            break;
        case DomainConsistency: 
            o = [[CPCardinalityDC alloc] initCPCardinalityDC: x low: low up: up]; 
            break;
        default:
            @throw [[ORExecutionError alloc] initORExecutionError: "Consistency Not Implemented on alldifferent"]; 
    }
    [[x tracker ] trackMutable: o];
    return o;
}

+(id<ORConstraint>) minimize: (id<CPIntVar>) x
{
    id<ORConstraint> o = [[CPIntVarMinimize alloc] initCPIntVarMinimize: x];
    [[x engine] trackMutable: o];
    return o;
}

+(id<ORConstraint>) maximize: (id<CPIntVar>) x
{
    id<ORConstraint> o = [[CPIntVarMaximize alloc] initCPIntVarMaximize: x];
    [[x engine] trackMutable: o];
    return o;
}

+(id<ORConstraint>) circuit: (id<CPIntVarArray>) x
{
   id<ORConstraint> o = [[CPCircuitI alloc] initCPCircuitI:x];
   [[x tracker] trackMutable: o];
   return o;
}

+(id<ORConstraint>) packOne: (id<CPIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<CPIntVar>) binSize
{
   id<ORConstraint> o = [[CPOneBinPackingI alloc] initCPOneBinPackingI: item itemSize: itemSize bin: b binSize: binSize];
   [[item tracker] trackMutable: o];
   return o;
}
+(id<ORConstraint>) knapsack: (id<CPIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<CPIntVar>)c
{
   id<ORConstraint> o = [[CPKnapsack alloc] initCPKnapsackDC:x weights:w capacity:c];
   [[x tracker] trackMutable: o];
   return o;
}
+(id<ORConstraint>) nocycle: (id<CPIntVarArray>) x
{
   id<ORConstraint> o = [[CPCircuitI alloc] initCPNoCycleI:x];
   [[x tracker] trackMutable: o];
   return o;
}

+(id<ORConstraint>) table: (ORTableI*) table on: (id<CPIntVarArray>) x
{
   id<ORConstraint> o = [[CPTableCstrI alloc] initCPTableCstrI: x table: table];
   [[x tracker] trackMutable: o];
   return o;
}
+(id<ORConstraint>) table: (ORTableI*) table on: (CPIntVarI*) x : (CPIntVarI*) y : (CPIntVarI*) z;
{
   id<ORConstraint> o = [[CPTableCstrI alloc] initCPTableCstrI: table on: x : y : z];
   [[x tracker] trackMutable: o];
   return o;
}
+(id<ORConstraint>) assignment: (id<CPEngine>) engine array: (id<CPIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<CPIntVar>) cost
{
   id<ORConstraint> o = [[CPAssignment alloc] initCPAssignment: engine array: x matrix: matrix cost: cost];
   [[x tracker] trackMutable: o];
   return o;
}
+(id<ORConstraint>) lex:(id<CPIntVarArray>)x leq:(id<CPIntVarArray>)y
{
   id<ORConstraint> o = [[CPLexConstraint alloc] initCPLexConstraint:x and:y];
   [[x tracker] trackMutable:o];
   return o;
}

+(id<CPIntVar>) reifyView: (CPIntVarI*) x eqi:(ORInt)c
{
   id<CPIntVarNotifier> mc = [x delegate];
   if (mc == nil) {
      mc = [[CPIntVarMultiCast alloc] initVarMC:2 root:x];
      [mc release]; // we no longer need the local ref. The addVar call has increased the retain count.
   }
   CPLiterals* literals = [mc findLiterals:x];
   id<CPIntVar> litView = [literals positiveForValue:c];
   if (!litView) {
      litView = [[CPEQLitView alloc] initEQLitViewFor:x equal:c];
      [literals addPositive: litView forValue:c];
   }
   return litView;
}

+(id<ORConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x eqi: (ORInt) i
{
   id<ORConstraint> o = [[CPReifyEqualcDC alloc] initCPReifyEqualcDC: b when: x eq: i];
   [[x engine] trackMutable: o];
   return o;
}

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x neq: (id<CPIntVar>) y annotation:(ORAnnotation)c
{
   switch(c) {
      case ValueConsistency:
      case RangeConsistency: {
         id<CPConstraint> o = [[CPReifyNEqualBC alloc] initCPReify: b when: x neq: y];
         [[x tracker] trackMutable: o];
         return o;
      }
      case DomainConsistency: {
         id<CPConstraint> o = [[CPReifyNEqualDC alloc] initCPReify: b when: x neq: y];
         [[x tracker] trackMutable: o];
         return o;
      }
      default:assert(0);return nil;
   }
}

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x eq: (id<CPIntVar>) y annotation:(ORAnnotation)c
{
   switch(c) {
      case ValueConsistency:
      case Default:
      case RangeConsistency: {
         id<CPConstraint> o = [[CPReifyEqualBC alloc] initCPReifyEqualBC: b when: x eq: y];
         [[x tracker] trackMutable: o];
         return o;
      }
      case DomainConsistency: {
         id<CPConstraint> o = [[CPReifyEqualDC alloc] initCPReifyEqualDC: b when: x eq: y];
         [[x tracker] trackMutable: o];
         return o;
      }
      default:assert(0);return nil;
   }
}

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x neqi: (ORInt) i
{
    id<CPConstraint> o = [[CPReifyNotEqualcDC alloc] initCPReifyNotEqualcDC: b when: x neq: i];
    [[x tracker] trackMutable: o];
    return o;
}

+(id<ORConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x leqi: (ORInt) i
{
   id<ORConstraint> o = [[CPReifyLEqualDC alloc] initCPReifyLEqualDC: b when: x leqi: i];
   [[x tracker] trackMutable: o];
   return o;
}

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x leq:(id<CPIntVar>)y annotation:(ORAnnotation)c
{
   id<CPConstraint> o = [[CPReifyLEqualBC alloc] initCPReifyLEqualBC:b when:x leq:y];
   [[x tracker] trackMutable:o];
   return o;
}

+(id<ORConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x geqi: (ORInt) i
{
   id<ORConstraint> o = [[CPReifyGEqualDC alloc] initCPReifyGEqualDC: b when: x geq: i];
   [[x tracker] trackMutable: o];
   return o;
}

+(id<ORConstraint>) sumbool: (id<CPIntVarArray>) x geq: (ORInt) c
{
    id<ORConstraint> o = [[CPSumBoolGeq alloc] initCPSumBool: x geq: c];
    [[x tracker] trackMutable: o];
    return o;
}

+(id<ORConstraint>) sumbool: (id<CPIntVarArray>) x eq: (ORInt) c
{
   id<ORConstraint> o = [[CPSumBoolEq alloc] initCPSumBool: x eq: c];
   [[x tracker] trackMutable: o];
   return o;
}

+(id<ORConstraint>) sum: (id<CPIntVarArray>) x eq: (ORInt) c
{
   return [self sum:x eq:c annotation:RangeConsistency];
}

+(id<ORConstraint>) sum: (id<CPIntVarArray>) x eq: (ORInt) c annotation: (ORAnnotation)cons
{
   id<ORConstraint> o = [[CPEquationBC alloc] initCPEquationBC: x equal: c];
   [[x tracker] trackMutable: o];
   return o;
}

+(id<ORConstraint>) sum: (id<CPIntVarArray>) x leq: (ORInt) c
{
   id<ORConstraint> o = [[CPINEquationBC alloc] initCPINEquationBC: x lequal: c];
   [[x tracker] trackMutable: o];
   return o;
}

+(id<ORConstraint>) boolean:(id<CPIntVar>)x or:(id<CPIntVar>)y equal:(id<CPIntVar>)b
{
   id<ORConstraint> o = [[CPOrDC alloc] initCPOrDC:b equal:x or:y];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) boolean:(id<CPIntVar>)x and:(id<CPIntVar>)y equal:(id<CPIntVar>)b
{
   id<ORConstraint> o = [[CPAndDC alloc] initCPAndDC:b equal:x and:y];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) boolean:(id<CPIntVar>)x imply:(id<CPIntVar>)y equal:(id<CPIntVar>)b
{
   id<ORConstraint> o = [[CPImplyDC alloc] initCPImplyDC:b equal:x imply:y];
   [[x tracker] trackMutable:o];
   return o;   
}

+(id<ORConstraint>) equal: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(int) c
{
   id<ORConstraint> o = [[CPEqualBC alloc] initCPEqualBC:x and:y and:c];
   [[x tracker] trackMutable:o];
   return o;   
}
+(id<ORConstraint>) equal: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(int) c annotation: (ORAnnotation)cons
{
   id<ORConstraint> o = nil;
   switch(cons) {
      case DomainConsistency:
         o = [[CPEqualDC alloc] initCPEqualDC:x and:y and:c];break;
      default: 
         o = [[CPEqualBC alloc] initCPEqualBC:x and:y and:c];break;
   }
   [[x tracker] trackMutable:o];
   return o;   
}
+(id<ORConstraint>) affine:(id<CPIntVar>)y equal:(ORInt)a times:(id<CPIntVar>)x plus:(ORInt)b annotation:(ORAnnotation)cons
{
   id<ORConstraint> o  = nil;
   switch(cons) {
      case DomainConsistency:
         o = [[CPAffineAC alloc] initCPAffineAC:y equal:a times:x plus:b];break;
      default:
         o = [[CPAffineBC alloc] initCPAffineBC:y equal:a times:x plus:b];break;
   }
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) equal3: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(id<CPIntVar>) z annotation: (ORAnnotation)cons
{
   id<ORConstraint> o = nil;
   switch(cons) {
      case DomainConsistency:
         o = [[CPEqual3DC alloc] initCPEqual3DC:y plus:z equal:x];break;
      default: 
         o = [[CPEqual3BC alloc] initCPEqual3BC:y plus:z equal:x];break;
   }
   [[x tracker] trackMutable:o];
   return o;   
}
+(id<ORConstraint>) equalc: (id<CPIntVar>) x to:(int) c
{
   id<ORConstraint> o = [[CPEqualc alloc] initCPEqualc:x and:c];
  [[x tracker] trackMutable:o];
   return o;      
}
+(id<ORConstraint>) notEqual:(id<CPIntVar>)x to:(id<CPIntVar>)y plus:(int)c
{
   id<ORConstraint> o = [[CPNotEqual alloc] initCPNotEqual:x and:y and:c];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) notEqual:(id<CPIntVar>)x to:(id<CPIntVar>)y 
{
   id<ORConstraint> o = [[CPBasicNotEqual alloc] initCPBasicNotEqual:x and:y];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) notEqualc:(id<CPIntVar>)x to:(ORInt)c 
{
   id<ORConstraint> o = [[CPDiffc alloc] initCPDiffc:x and:c];
  [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) lEqual: (id<CPIntVar>)x to: (id<CPIntVar>) y
{
   id<ORConstraint> o = [[CPLEqualBC alloc] initCPLEqualBC:x and:y plus:0];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) lEqual: (id<CPIntVar>)x to: (id<CPIntVar>) y plus:(ORInt)c
{
   id<ORConstraint> o = [[CPLEqualBC alloc] initCPLEqualBC:x and:y plus:c];
   [[x tracker] trackMutable:o];
   return o;   
}
+(id<ORConstraint>) lEqualc: (id<CPIntVar>)x to: (ORInt) c
{
   id<ORConstraint> o = [[CPLEqualc alloc] initCPLEqualc:x and:c];
   [[x tracker] trackMutable:o];
   return o;   
}
+(id<ORConstraint>) gEqualc: (id<CPIntVar>)x to: (ORInt) c
{
   id<ORConstraint> o = [[CPGEqualc alloc] initCPGEqualc:x and:c];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) less: (id<CPIntVar>)x to: (id<CPIntVar>) y
{
   id<CPIntVar> yp = [self intVar:y shift:-1];
   return [self lEqual:x to:yp plus:0];
}
+(id<ORConstraint>) mult: (id<CPIntVar>)x by:(id<CPIntVar>)y equal:(id<CPIntVar>)z
{
   id<ORConstraint> o = [[CPMultBC alloc] initCPMultBC:x times:y equal:z];
   [[x tracker] trackMutable:o];
   return o;   
}
+(id<ORConstraint>) square: (id<CPIntVar>)x equal:(id<CPIntVar>)z annotation:(ORAnnotation)c
{
   id<ORConstraint> o = nil;
   switch (c) {
      case DomainConsistency:
         o = [[CPSquareDC alloc] initCPSquareDC:z equalSquare:x];
         break;
      default:
         o = [[CPSquareBC alloc] initCPSquareBC:z equalSquare:x];
         break;
   }
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) mod: (id<CPIntVar>)x modi:(ORInt)c equal:(id<CPIntVar>)y annotation:(ORAnnotation)note
{
   id<ORConstraint> o = NULL;
   switch(note) {
      case DomainConsistency:
         o = [[CPModcDC alloc] initCPModcDC:x mod:c equal:y];
         break;
      default:
         o = [[CPModcBC alloc] initCPModcBC:x mod:c equal:y];
         break;
   }
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) mod: (id<CPIntVar>)x mod:(id<CPIntVar>)y equal:(id<CPIntVar>)z
{
   id<ORConstraint> o = [[CPModBC alloc] initCPModBC:x mod:y equal:z];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) abs: (id<CPIntVar>)x equal:(id<CPIntVar>)y annotation:(ORAnnotation)c
{
   id<ORConstraint> o = nil;
   switch (c) {
      case DomainConsistency:
         o = [[CPAbsDC alloc] initCPAbsDC:x equal:y];
         break;
      default: 
         o = [[CPAbsBC alloc] initCPAbsBC:x equal:y];
         break;
   }
   [[x tracker] trackMutable:o];
   return o;   
}
+(id<ORConstraint>) element:(id<CPIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<CPIntVar>)y annotation:(ORAnnotation)n
{
   id<ORConstraint> o = nil;
   switch(n) {
      case DomainConsistency:
         //o = [[CPElementCstBC alloc] initCPElementBC:x indexCstArray:c equal:y];
         o = [[CPElementCstAC alloc] initCPElementAC:x indexCstArray:c equal:y]; // tocheck
         break;
      default:
         o = [[CPElementCstBC alloc] initCPElementBC:x indexCstArray:c equal:y];
         break;
   }
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) element:(id<CPIntVar>)x idxVarArray:(id<CPIntVarArray>)array equal:(id<CPIntVar>)y annotation:(ORAnnotation)n
{
   id<ORConstraint> o = nil;
   switch(n) {
      case DomainConsistency:
         o = [[CPElementVarAC alloc] initCPElementAC:x indexVarArray:array equal:y];
         break;
      default:
         o = [[CPElementVarBC alloc] initCPElementBC:x indexVarArray:array equal:y];
         break;
   }
   [[x tracker] trackMutable:o];
   return o;
}
+(id<ORConstraint>) restrict:(id<CPIntVar>)x to:(id<ORIntSet>)r
{
   id<ORConstraint> o = [[CPRestrictI alloc] initRestrict:x to:r];
   [[x tracker] trackMutable:o];
   return o;
}
@end


@implementation CPSearchFactory 
+(id<CPConstraint>) equalc: (id<CPIntVar>) x to:(int) c
{
   return [[CPEqualc alloc] initCPEqualc:x and:c];
}
+(id<CPConstraint>) notEqualc:(id<CPIntVar>)x to:(ORInt)c
{
   return [[CPDiffc alloc] initCPDiffc:x and:c];
}
+(id<CPConstraint>) lEqualc: (id<CPIntVar>)x to: (ORInt) c
{
   return [[CPLEqualc alloc] initCPLEqualc:x and:c];
}
@end

