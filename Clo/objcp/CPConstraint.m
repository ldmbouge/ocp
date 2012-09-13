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
#import "CPLinear.h"
#import "CPAssignmentI.h"
#import "CPLexConstraint.h"
#import "CPBinPacking.h"
#import "CPKnapsack.h"
#import "CPLinear.h"

@implementation CPFactory (Constraint)

// alldifferent
+(id<ORConstraint>) alldifferent: (id<CPSolver>) cp over: (id<ORIntVarArray>) x
{
   id<ORConstraint> o = [[CPAllDifferentDC alloc] initCPAllDifferentDC: cp over: x];
   [cp trackObject: o];
   return o;
}
+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x
{
    return [CPFactory alldifferent: x consistency: DomainConsistency];
}
+(id<ORConstraint>) alldifferent: (id<ORIntVarArray>) x consistency: (CPConsistency) c
{
    id<ORConstraint> o;
    switch (c) {
        case DomainConsistency: 
            o = [[CPAllDifferentDC alloc] initCPAllDifferentDC:x];
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
    [[x tracker] trackObject: o];
    return o;
}
+(id<ORConstraint>) alldifferent: (id<CPSolver>) solver over: (id<ORIntVarArray>) x consistency: (CPConsistency) c
{
   id<ORConstraint> o;
   switch (c) {
      case DomainConsistency:
         o = [[CPAllDifferentDC alloc] initCPAllDifferentDC: solver over: x];
         break;
      case ValueConsistency:
         o = [[CPAllDifferenceVC alloc] initCPAllDifferenceVC: solver over: x];
         break;
      case RangeConsistency:
         @throw [[ORExecutionError alloc] initORExecutionError: "Range Consistency Not Implemented on alldifferent"];
         break;
      default:
         @throw [[ORExecutionError alloc] initORExecutionError: "Consistency Not Implemented on alldifferent"];
   }
   [[x tracker] trackObject: o];
   return o;
   
}
// cardinality
+(id<ORConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up
{
    return [CPFactory cardinality: x low: low up: up consistency: ValueConsistency];
}
+(id<ORConstraint>) cardinality: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up consistency: (CPConsistency) c
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
    [[x tracker ] trackObject: o];
    return o;
}

+(id<ORConstraint>) minimize: (id<ORIntVar>) x
{
    id<ORConstraint> o = [[CPIntVarMinimize alloc] initCPIntVarMinimize: x];
    [[x solver] trackObject: o];
    return o;
}

+(id<ORConstraint>) maximize: (id<ORIntVar>) x
{
    id<ORConstraint> o = [[CPIntVarMaximize alloc] initCPIntVarMaximize: x];
    [[x solver] trackObject: o];
    return o;
}

+(id<ORConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x eqi: (ORInt) i
{
   id<ORConstraint> o = [[CPReifyEqualcDC alloc] initCPReifyEqualcDC: b when: x eq: i];
   [[x solver] trackObject: o];
   return o;
}

+(id<ORIntVar>) reifyView: (CPIntVarI*) x eqi:(ORInt)c
{
   id<ORIntVar> litView = [[CPEQLitView alloc] initEQLitViewFor:x equal:c];
   id<CPIntVarNotifier> mc = [x delegate];
   if (mc == x) {
      mc = [[CPIntVarMultiCast alloc] initVarMC:2];
      [mc addVar: x];
      [mc release]; // we no longer need the local ref. The addVar call has increased the retain count.
   }
   CPLiterals* literals = [mc findLiterals:x];
   [literals addPositive: litView forValue:c];
   return litView;
}

+(id<ORConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x eq: (id<ORIntVar>) y consistency:(CPConsistency)c
{
   switch(c) {
      case ValueConsistency:
      case RangeConsistency: {
         id<ORConstraint> o = [[CPReifyEqualBC alloc] initCPReifyEqualBC: b when: x eq: y];
         [[x solver] trackObject: o];
         return o;
      }
      case DomainConsistency: {
         id<ORConstraint> o = [[CPReifyEqualDC alloc] initCPReifyEqualDC: b when: x eq: y];
         [[x solver] trackObject: o];
         return o;
      }
   }
}

+(id<ORConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x neq: (ORInt) i
{
    id<ORConstraint> o = [[CPReifyNotEqualcDC alloc] initCPReifyNotEqualcDC: b when: x neq: i];
    [[[x solver] engine] trackObject: o];
    return o;
}

+(id<ORConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x leq: (ORInt) i
{
   id<ORConstraint> o = [[CPReifyLEqualDC alloc] initCPReifyLEqualDC: b when: x leq: i];
   [[[x solver] engine] trackObject: o];
   return o;
}

+(id<ORConstraint>) reify: (id<ORIntVar>) b with: (id<ORIntVar>) x geq: (ORInt) i
{
   id<ORConstraint> o = [[CPReifyGEqualDC alloc] initCPReifyGEqualDC: b when: x geq: i];
   [[[x solver] engine] trackObject: o];
   return o;
}

+(id<ORConstraint>) sumbool: (id<ORIntVarArray>) x geq: (ORInt) c
{
    id<ORConstraint> o = [[CPSumBoolGeq alloc] initCPSumBool: x geq: c];
    [[x tracker] trackObject: o];
    return o;
}

+(id<ORConstraint>) sumbool: (id<ORIntVarArray>) x eq: (ORInt) c
{
   id<ORConstraint> o = [[CPSumBoolEq alloc] initCPSumBool: x eq: c];
   [[x tracker] trackObject: o];
   return o;
}

+(id<ORConstraint>) sum: (id<ORIntVarArray>) x eq: (ORInt) c
{
   return [self sum:x eq:c consistency:RangeConsistency];
}

+(id<ORConstraint>) sum: (id<ORIntVarArray>) x eq: (ORInt) c consistency: (CPConsistency)cons
{
   id<ORConstraint> o = [[CPEquationBC alloc] initCPEquationBC: x equal: c];
   [[x tracker] trackObject: o];
   return o;
}

+(id<ORConstraint>) sum: (id<ORIntVarArray>) x leq: (ORInt) c
{
   id<ORConstraint> o = [[CPINEquationBC alloc] initCPINEquationBC: x lequal: c];
   [[x tracker] trackObject: o];
   return o;
}

+(id<ORConstraint>) boolean:(id<ORIntVar>)x or:(id<ORIntVar>)y equal:(id<ORIntVar>)b
{
   id<ORConstraint> o = [[CPOrDC alloc] initCPOrDC:b equal:x or:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) boolean:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)b
{
   id<ORConstraint> o = [[CPAndDC alloc] initCPAndDC:b equal:x and:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<ORConstraint>) boolean:(id<ORIntVar>)x imply:(id<ORIntVar>)y equal:(id<ORIntVar>)b
{
   id<ORConstraint> o = [[CPImplyDC alloc] initCPImplyDC:b equal:x imply:y];
   [[x tracker] trackObject:o];
   return o;   
}

+(id<ORConstraint>) circuit: (id<ORIntVarArray>) x
{
    id<ORConstraint> o = [[CPCircuitI alloc] initCPCircuitI:x];
    [[x tracker] trackObject: o];
    return o;
}

+(id<ORConstraint>) packing: (id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize binSize: (id<ORIntArray>) binSize;
{
   id<ORIntRange> R = [binSize range];
   id<ORIntVarArray> load = [CPFactory intVarArray: [x solver] range: R];
   ORInt low = [R low];
   ORInt up = [R up];
   for(ORInt i = low; i <= up; i++) 
      load[i] = [CPFactory intVar: [x solver] domain: RANGE([x tracker],0,[binSize at:i])];
   id<ORConstraint> o = [CPFactory packing: x itemSize: itemSize load: load];  // [ldm] this already tracks o.
   return o;
}

typedef struct _CPPairIntId {
   ORInt        _int;
   id           _id;
} CPPairIntId;

int compareCPPairIntId(const CPPairIntId* r1,const CPPairIntId* r2)
{
   return r2->_int - r1->_int;
}

+(void) sortIntVarInt: (id<ORIntVarArray>) x size: (id<ORIntArray>) size sorted: (id<ORIntVarArray>*) sx sortedSize: (id<ORIntArray>*) sortedSize
{
   id<ORIntRange> R = [x range];
   int nb = [R up] - [R low] + 1;
   ORInt low = [R low];
   ORInt up = [R up];
   CPPairIntId* toSort = (CPPairIntId*) alloca(sizeof(CPPairIntId) * nb);
   int k = 0;
   for(ORInt i = low; i <= up; i++)
      toSort[k++] = (CPPairIntId){[size at: i],x[i]};
   qsort(toSort,nb,sizeof(CPPairIntId),(int(*)(const void*,const void*)) &compareCPPairIntId);
   
   *sx = [CPFactory intVarArray: [x solver] range: R with: ^id<ORIntVar>(int i) { return toSort[i - low]._id; }];
   *sortedSize = [CPFactory intArray:[x solver] range: R with: ^ORInt(ORInt i) { return toSort[i - low]._int; }];
}

+(id<ORConstraint>) packing: (id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize load: (id<ORIntArray>) load;
{
   id<ORIntVarArray> sortedItem;
   id<ORIntArray> sortedSize;
   [CPFactory sortIntVarInt: x size: itemSize sorted: &sortedItem sortedSize: &sortedSize];
//   NSLog(@"%@",sortedItem);
//   NSLog(@"%@",sortedSize);
   id<ORConstraint> o = [[CPBinPackingI alloc] initCPBinPackingI: sortedItem itemSize: sortedSize binSize: load];
   [[x tracker] trackObject: o];
   return o;
}

+(id<ORConstraint>) packOne: (id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize
{
   id<ORConstraint> o = [[CPOneBinPackingI alloc] initCPOneBinPackingI: item itemSize: itemSize bin: b binSize: binSize];
   [[item tracker] trackObject: o];
   return o;
}
+(id<ORConstraint>) knapsack: (id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c
{
   id<ORConstraint> o = [[CPKnapsack alloc] initCPKnapsackDC:x weights:w capacity:c];
   [[x tracker] trackObject: o];
   return o;
}
+(id<ORConstraint>) nocycle: (id<ORIntVarArray>) x
{
    id<ORConstraint> o = [[CPCircuitI alloc] initCPNoCycleI:x];
    [[x tracker] trackObject: o];
    return o;
}
+(id<ORConstraint>) equal: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(int) c
{
   id<ORConstraint> o = [[CPEqualBC alloc] initCPEqualBC:x and:y and:c];
   [[x tracker] trackObject:o];
   return o;   
}
+(id<ORConstraint>) equal: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(int) c consistency: (CPConsistency)cons
{
   id<ORConstraint> o = nil;
   switch(cons) {
      case DomainConsistency:
         o = [[CPEqualDC alloc] initCPEqualDC:x and:y and:c];break;
      default: 
         o = [[CPEqualBC alloc] initCPEqualBC:x and:y and:c];break;
   }
   [[x tracker] trackObject:o];
   return o;   
}
+(id<ORConstraint>) equal3: (id<ORIntVar>) x to: (id<ORIntVar>) y plus:(id<ORIntVar>) z consistency: (CPConsistency)cons
{
   id<ORConstraint> o = nil;
   switch(cons) {
      case DomainConsistency:
         o = [[CPEqual3DC alloc] initCPEqual3DC:y plus:z equal:x];break;
      default: 
         // TOFIX
         o = [[CPEqual3DC alloc] initCPEqual3DC:y plus:z equal:x];break;
         //o = [[CPEqualBC alloc] initCPEqualBC:y and:z and:x];break;
   }
   [[x solver] trackObject:o];
   return o;   
}
+(id<ORConstraint>) equalc: (id<ORIntVar>) x to:(int) c
{
   id<ORConstraint> o = [[CPEqualc alloc] initCPEqualc:x and:c];
   [[x solver] trackObject:o];
   return o;      
}
+(id<ORConstraint>) notEqual:(id<ORIntVar>)x to:(id<ORIntVar>)y plus:(int)c
{
   id<ORConstraint> o = [[CPNotEqual alloc] initCPNotEqual:x and:y and:c];
   [[x solver] trackObject:o];
   return o;
}
+(id<ORConstraint>) notEqual:(id<ORIntVar>)x to:(id<ORIntVar>)y 
{
   id<ORConstraint> o = [[CPBasicNotEqual alloc] initCPBasicNotEqual:x and:y];
   [[x solver] trackObject:o];
   return o;
}
+(id<ORConstraint>) notEqualc:(id<ORIntVar>)x to:(ORInt)c 
{
   id<ORConstraint> o = [[CPDiffc alloc] initCPDiffc:x and:c];
   [[x solver] trackObject:o];
   return o;
}
+(id<ORConstraint>) lEqual: (id<ORIntVar>)x to: (id<ORIntVar>) y
{
   id<ORConstraint> o = [[CPLEqualBC alloc] initCPLEqualBC:x and:y];
   [[x solver] trackObject:o];
   return o;   
}
+(id<ORConstraint>) lEqualc: (id<ORIntVar>)x to: (ORInt) c
{
   id<ORConstraint> o = [[CPLEqualc alloc] initCPLEqualc:x and:c];
   [[x solver] trackObject:o];
   return o;   
}
+(id<ORConstraint>) less: (id<ORIntVar>)x to: (id<ORIntVar>) y
{
   id<ORIntVar> yp = [self intVar:y shift:-1];
   return [self lEqual:x to:yp];
}
+(id<ORConstraint>) mult: (id<ORIntVar>)x by:(id<ORIntVar>)y equal:(id<ORIntVar>)z
{
   id<ORConstraint> o = [[CPMultBC alloc] initCPMultBC:x times:y equal:z];
   [[x solver] trackObject:o];
   return o;   
}
+(id<ORConstraint>) abs: (id<ORIntVar>)x equal:(id<ORIntVar>)y consistency:(CPConsistency)c
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
   [[x solver] trackObject:o];
   return o;   
}
+(id<ORConstraint>) element:(id<ORIntVar>)x idxCstArray:(id<ORIntArray>)c equal:(id<ORIntVar>)y
{
   id<ORConstraint> o = [[CPElementCstBC alloc] initCPElementBC:x indexCstArray:c equal:y];
   [[x solver] trackObject:o];
   return o;
}
+(id<ORConstraint>) element:(id<ORIntVar>)x idxVarArray:(id<ORIntVarArray>)c equal:(id<ORIntVar>)y
{
   id<ORConstraint> o = [[CPElementVarBC alloc] initCPElementBC:x indexVarArray:c equal:y];
   [[x solver] trackObject:o];
   return o;
}
+(id<ORConstraint>) table: (ORTableI*) table on: (id<ORIntVarArray>) x
{
    id<ORConstraint> o = [[CPTableCstrI alloc] initCPTableCstrI: x table: table];
    [[x solver] trackObject:o];
    return o;
}
+(id<ORConstraint>) table: (ORTableI*) table on: (CPIntVarI*) x : (CPIntVarI*) y : (CPIntVarI*) z;
{
    id<ORConstraint> o = [[CPTableCstrI alloc] initCPTableCstrI: table on: x : y : z];
    [[x solver] trackObject:o];
    return o;    
}
+(id<ORConstraint>) assignment: (id<ORIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<ORIntVar>) cost
{
   id<ORConstraint> o = [[CPAssignment alloc] initCPAssignment: x matrix: matrix cost: cost];
   [[x solver] trackObject:o];
   return o;
}
+(id<ORConstraint>) lex:(id<ORIntVarArray>)x leq:(id<ORIntVarArray>)y
{
   id<ORConstraint> o = [[CPLexConstraint alloc] initCPLexConstraint:x and:y];
   [[x solver] trackObject:o];
   return o;
}

+(id<ORConstraint>) relation2Constraint: (id<ORSolver>) solver expr: (id<ORRelation>) e consistency: (CPConsistency) c
{
   CPExprConstraintI* wrapper = [[CPExprConstraintI alloc] initCPExprConstraintI: solver expr: e consistency: c];
   [solver trackObject:wrapper];
   return wrapper;
}
+(id<ORConstraint>) relation2Constraint: (id<ORSolver>) solver expr: (id<ORRelation>) e
{
   CPExprConstraintI* wrapper = [[CPExprConstraintI alloc] initCPExprConstraintI: solver expr:e consistency: RangeConsistency];
   [solver trackObject:wrapper];
   return wrapper;

}
@end

