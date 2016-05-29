/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

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
#import "CPRealConstraint.h"
#import "CPIntSetConstraint.h"


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
+(id<ORConstraint>) alldifferent: (id<CPIntVarArray>) x annotation: (ORCLevel) c
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
+(id<ORConstraint>) alldifferent: (id<CPEngine>) engine over: (id<CPIntVarArray>) x annotation: (ORCLevel) c
{
   id<ORConstraint> o;
   switch (c) {
      case DomainConsistency:
         //NSLog(@"Domain Consistency");
         o = [[CPAllDifferentDC alloc] initCPAllDifferentDC: engine over: x];
         break;
      case ValueConsistency:
         //NSLog(@"Value Consistency");
         o = [[CPAllDifferenceVC alloc] initCPAllDifferenceVC: engine over: x];
         break;
      case RangeConsistency:
         @throw [[ORExecutionError alloc] initORExecutionError: "Range Consistency Not Implemented on alldifferent"];
         break;
      default:
         //NSLog(@"Default Consistency");
         o = [[CPAllDifferentDC alloc] initCPAllDifferentDC: engine over: x];
         break;
   }
   [[x tracker] trackMutable: o];
   return o;
   
}
// cardinality
+(id<ORConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up
{
    return [CPFactory cardinality: x low: low up: up annotation: ValueConsistency];
}
+(id<ORConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up annotation: (ORCLevel) c
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
          o = [[CPCardinalityDC alloc] initCPCardinalityDC: x low: low up: up];
          break;
    }
    [[x tracker ] trackMutable: o];
    return o;
}

+(id<ORConstraint>) minimize: (id<CPIntVar>) x
{
    id<ORConstraint> o = [[CPIntVarMinimize alloc] init: x];
    [[x engine] trackMutable: o];
    return o;
}

+(id<ORConstraint>) maximize: (id<CPIntVar>) x
{
    id<ORConstraint> o = [[CPIntVarMaximize alloc] init: x];
    [[x engine] trackMutable: o];
    return o;
}

+(id<ORConstraint>) circuit: (id<CPIntVarArray>) x
{
   id<ORConstraint> o = [[CPCircuit alloc] initCPCircuit:x];
   [[x tracker] trackMutable: o];
   return o;
}
+(id<ORConstraint>) subCircuit: (id<CPIntVarArray>) x
{
   id<ORConstraint> o = [[CPSubCircuit alloc] initCPSubCircuit:x];
   [[x tracker] trackMutable: o];
   return o;
}
+(id<ORConstraint>) nocycle:(id<CPIntVarArray>)x
{
   assert(NO);
   return nil;
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

+(id<ORConstraint>) path: (id<CPIntVarArray>) x
{
   id<ORConstraint> o = [[CPPath alloc] initCPPath:x];
   [[x tracker] trackMutable: o];
   return o;
}

+(id<ORConstraint>) table: (ORTableI*) table on: (id<CPIntVarArray>) x
{
   id<ORConstraint> o = [[CPTableCstrI alloc] initCPTableCstrI: x table: table];
   [[x tracker] trackMutable: o];
   return o;
}
+(id<ORConstraint>) table: (ORTableI*) table on: (CPIntVar*) x : (CPIntVar*) y : (CPIntVar*) z;
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

+(id<CPIntVar>) reifyView: (CPIntVar*) x eqi: (ORInt) c
{
   CPMultiCast* mc = [x delegate];
   if (mc == nil) {
      mc = [[CPMultiCast alloc] initVarMC:2 root:x];
      [mc release]; // we no longer need the local ref. The addVar call has increased the retain count.
   }
   CPLiterals* literals = [mc findLiterals:x];
   if (memberDom(x, c)) {
      CPEQLitView* litView = [literals positiveForValue: c];
      if (!litView) {
         litView = [[CPEQLitView alloc] initEQLitViewFor:x equal:c];
         [literals addPositive: litView forValue:c];
      }
      return litView;
   } else {
      return [CPFactory intVar:[x engine] value:0];
   }
}

+(id<ORConstraint>) imply: (id<CPIntVar>) b with: (id<CPIntVar>) x eqi: (ORInt) i
{
    id<ORConstraint> o = [[CPImplyEqualcDC alloc] initCPImplyEqualcDC: b when: x eq: i];
    [[x engine] trackMutable: o];
    return o;
}

+(id<ORConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x eqi: (ORInt) i
{
   id<ORConstraint> o = [[CPReifyEqualcDC alloc] initCPReifyEqualcDC: b when: x eq: i];
   [[x engine] trackMutable: o];
   return o;
}

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x neq: (id<CPIntVar>) y annotation:(ORCLevel)c
{
   switch(c) {
      case ValueConsistency:
      case Default:
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
      default:
         @throw [[ORExecutionError alloc] initORExecutionError:"reached default switch case in reify:neq:"];
         return nil;
   }
}

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x eq: (id<CPIntVar>) y annotation:(ORCLevel)c
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
      default:
         @throw [[ORExecutionError alloc] initORExecutionError:"reached default switch case in reify:eq:"];
         return nil;
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

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x leq:(id<CPIntVar>)y annotation:(ORCLevel)c
{
   id<CPConstraint> o = [[CPReifyLEqualBC alloc] initCPReifyLEqualBC:b when:x leq:y];
   [[x tracker] trackMutable:o];
   return o;
}

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x geqi: (ORInt) i
{
   id<CPConstraint> o = [[CPReifyGEqualDC alloc] initCPReifyGEqualDC: b when: x geq: i];
   [[x tracker] trackMutable: o];
   return o;
}
+(id<CPConstraint>) reify:(id<CPIntVar>) b array:(id<CPIntVarArray>)x eqi:(ORInt) c annotation:(ORCLevel)note
{
   id<CPConstraint> o = [[CPReifySumBoolEq alloc] init:b array:x eqi:c];
   [[b tracker] trackMutable:o];
   return o;
}
+(id<CPConstraint>) reify:(id<CPIntVar>) b array:(id<CPIntVarArray>)x geqi:(ORInt) c annotation:(ORCLevel)note
{
   id<CPConstraint> o = [[CPReifySumBoolGEq alloc] init:b array:x geqi:c];
   [[b tracker] trackMutable:o];
   return o;
}
+(id<CPConstraint>) hreify:(id<CPIntVar>) b array:(id<CPIntVarArray>)x eqi:(ORInt) c annotation:(ORCLevel)note
{
   id<CPConstraint> o = [[CPHReifySumBoolEq alloc] init:b array:x eqi:c];
   [[b tracker] trackMutable:o];
   return o;
}
+(id<CPConstraint>) hreify:(id<CPIntVar>) b array:(id<CPIntVarArray>)x geqi:(ORInt) c annotation:(ORCLevel)note
{
   id<CPConstraint> o = [[CPHReifySumBoolGEq alloc] init:b array:x geqi:c];
   [[b tracker] trackMutable:o];
   return o;
}
+(id<CPConstraint>) clause:(id<CPIntVarArray>) x eq:(id<CPIntVar>)tv
{
   id<CPConstraint> o = [[CPClause alloc] initCPClause:x equal:tv];
   [[x tracker] trackMutable:o];
   return o;
}

+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x geq: (ORInt) c
{
    id<CPConstraint> o = [[CPSumBoolGeq alloc] initCPSumBool: x geq: c];
    [[x tracker] trackMutable: o];
    return o;
}

+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x eq: (ORInt) c
{
   id<CPConstraint> o = [[CPSumBoolEq alloc] initCPSumBool: x eq: c];
   [[x tracker] trackMutable: o];
   return o;
}

+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (ORInt) c
{
   return [self sum:x eq:c annotation:RangeConsistency];
}

+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (ORInt) c annotation: (ORCLevel)cons
{
   id<CPConstraint> o = [[CPEquationBC alloc] initCPEquationBC: x equal: c];
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
+(id<ORConstraint>) equal: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(int) c annotation: (ORCLevel)cons
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
+(id<ORConstraint>) affine:(id<CPIntVar>)y equal:(ORInt)a times:(id<CPIntVar>)x plus:(ORInt)b annotation:(ORCLevel)cons
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
+(id<ORConstraint>) equal3: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(id<CPIntVar>) z annotation: (ORCLevel)cons
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
+(id<ORConstraint>) square: (id<CPIntVar>)x equal:(id<CPIntVar>)z annotation:(ORCLevel)c
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
+(id<ORConstraint>) mod: (id<CPIntVar>)x modi:(ORInt)c equal:(id<CPIntVar>)y annotation:(ORCLevel)note
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
+(id<CPConstraint>) min: (id<CPIntVar>)x and:(id<CPIntVar>)y equal:(id<CPIntVar>)z
{
   id<CPConstraint> o = [[CPMinBC alloc] initCPMin:x and:y equal:z];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<CPConstraint>) max: (id<CPIntVar>)x and:(id<CPIntVar>)y equal:(id<CPIntVar>)z
{
   id<CPConstraint> o = [[CPMaxBC alloc] initCPMax:x and:y equal:z];
   [[x tracker] trackMutable:o];
   return o;
}

+(id<ORConstraint>) abs: (id<CPIntVar>)x equal:(id<CPIntVar>)y annotation:(ORCLevel)c
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
+(id<ORConstraint>) element:(id<CPIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<CPIntVar>)y annotation:(ORCLevel)n
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
+(id<ORConstraint>) element:(id<CPIntVar>)x idxVarArray:(id<CPIntVarArray>)array equal:(id<CPIntVar>)y annotation:(ORCLevel)n
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
+(id<CPConstraint>) fail:(id<CPEngine>)engine
{
   id<CPConstraint> c = [[CPFalse alloc] init:engine];
   [engine trackMutable:c];
   return c;
}
+(id<CPConstraint>) restrict:(id<CPIntVar>)x to:(id<ORIntSet>)r
{
   id<CPConstraint> o = [[CPRestrictI alloc] initRestrict:x to:r];
   [[x tracker] trackMutable:o];
   return o;
}

+(id<ORConstraint>) relaxation: (NSArray*) mv var: (NSArray*) cv relaxation: (id<ORRelaxation>) relaxation
{
   id<ORConstraint> o = [[CPRelaxation alloc] initCPRelaxation: mv var: cv relaxation: relaxation];
   [[cv[0] tracker] trackMutable:o];
   return o;
}
@end

@implementation CPFactory (ORReal)
+(id<CPConstraint>) realSquare: (id<CPRealVar>)x equal:(id<CPRealVar>)z annotation:(ORCLevel)c
{
   id<CPConstraint> o = [[CPRealSquareBC alloc] initCPRealSquareBC:z equalSquare:x];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<CPConstraint>) realWeightedVar: (id<CPRealVar>)z equal:(id<CPRealVar>)x weight: (id<CPRealParam>)w
{
    id<CPConstraint> o = [[CPRealWeightedVarBC alloc] initCPRealWeightedVarBC: z equal: x weight: w];
    [[x tracker] trackMutable: o];
    return o;
}
+(id<CPConstraint>) realSum:(id<CPRealVarArray>)x coef:(id<ORDoubleArray>)coefs eqi:(ORDouble)c
{
   id<CPConstraint> o = [[CPRealEquationBC alloc] init:x coef:coefs eqi:c];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<CPConstraint>) realSum:(id<CPRealVarArray>)x coef:(id<ORDoubleArray>)coefs leqi:(ORDouble)c
{
   id<CPConstraint> o = [[CPRealINEquationBC alloc] init:x coef:coefs leqi:c];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<CPConstraint>) realSum:(id<CPRealVarArray>)x coef:(id<ORDoubleArray>)coefs geqi:(ORDouble)c
{
   id<ORDoubleArray> fc = [ORFactory doubleArray:[x tracker] range:coefs.range with:^ORDouble(ORInt k) {
      return - [coefs at:k];
   }];
   id<CPConstraint> o = [[CPRealINEquationBC alloc] init:x coef:fc leqi: -c];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<CPConstraint>) realEqualc: (id<CPIntVar>) x to:(ORDouble) c
{
   id<CPConstraint> o = [[CPRealEqualc alloc] init:x and:c];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<CPConstraint>) realElement:(id<CPIntVar>)x idxCstArray:(id<ORDoubleArray>)c equal:(id<CPRealVar>)y annotation:(ORCLevel)n
{
   id<CPConstraint> o = nil;
   o = [[CPRealElementCstBC alloc] init:x indexCstArray:c equal:y];
   [[x tracker] trackMutable:o];
   return o;
}
+(id<CPConstraint>) realMinimize: (id<CPRealVar>) x
{
   id<CPConstraint> o = [[CPRealVarMinimize alloc] init: x];
   [[x engine] trackMutable: o];
   return o;
}
+(id<CPConstraint>) realMaximize: (id<CPRealVar>) x
{
   id<CPConstraint> o = [[CPRealVarMaximize alloc] init: x];
   [[x engine] trackMutable: o];
   return o;
}
@end

@implementation CPFactory (ORIntSet)
+(id<CPConstraint>) inter:(id<CPIntSetVar>)x with:(id<CPIntSetVar>)y eq:(id<CPIntSetVar>)z
{
   id<CPConstraint> o = [[CPISInterAC alloc] init:x inter:y eq:z];
   [[x engine] trackMutable:o];
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

