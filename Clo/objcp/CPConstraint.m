/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

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

@implementation CPFactory (Constraint)

// alldifferent
+(id<CPConstraint>) alldifferent: (id<CPIntVarArray>) x
{
    return [CPFactory alldifferent: x consistency: DomainConsistency];
}
+(id<CPConstraint>) alldifferent: (id<CPIntVarArray>) x consistency: (CPConsistency) c
{
    id<CPConstraint> o;
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

// cardinality
+(id<CPConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<CPIntArray>) low up: (id<CPIntArray>) up
{
    return [CPFactory cardinality: x low: low up: up consistency: ValueConsistency];
}
+(id<CPConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<CPIntArray>) low up: (id<CPIntArray>) up consistency: (CPConsistency) c
{ 
    id<CPConstraint> o;
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

+(id<CPConstraint>) minimize: (id<CPIntVar>) x
{
    id<CPConstraint> o = [[CPIntVarMinimize alloc] initCPIntVarMinimize: x];
    [[[x cp] solver] trackObject: o];
    return o;
}

+(id<CPConstraint>) maximize: (id<CPIntVar>) x
{
    id<CPConstraint> o = [[CPIntVarMaximize alloc] initCPIntVarMaximize: x];
    [[[x cp] solver] trackObject: o];
    return o;
}

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x eq: (CPInt) i
{
    id<CPConstraint> o = [[CPReifyEqualDC alloc] initCPReifyEqualDC: b when: x eq: i];
    [[[x cp] solver] trackObject: o];
    return o;
}

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x neq: (CPInt) i
{
    id<CPConstraint> o = [[CPReifyNotEqualDC alloc] initCPReifyNotEqualDC: b when: x neq: i];
    [[[x cp] solver] trackObject: o];
    return o;
}

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x leq: (CPInt) i
{
   id<CPConstraint> o = [[CPReifyLEqualDC alloc] initCPReifyLEqualDC: b when: x leq: i];
   [[[x cp] solver] trackObject: o];
   return o;
}

+(id<CPConstraint>) reify: (id<CPIntVar>) b with: (id<CPIntVar>) x geq: (CPInt) i
{
   id<CPConstraint> o = [[CPReifyGEqualDC alloc] initCPReifyGEqualDC: b when: x geq: i];
   [[[x cp] solver] trackObject: o];
   return o;
}

+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x geq: (CPInt) c
{
    id<CPConstraint> o = [[CPSumBoolGeq alloc] initCPSumBool: x geq: c];
    [[x tracker] trackObject: o];
    return o;
}

+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x eq: (CPInt) c
{
   id<CPConstraint> o = [[CPSumBoolEq alloc] initCPSumBool: x eq: c];
   [[x tracker] trackObject: o];
   return o;
}

+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (CPInt) c
{
   return [self sum:x eq:c consistency:RangeConsistency];
}

+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (CPInt) c consistency: (CPConsistency)cons
{
   id<CPConstraint> o = [[CPEquationBC alloc] initCPEquationBC: x equal: c];
   [[x tracker] trackObject: o];
   return o;
}

+(id<CPConstraint>) sum: (id<CPIntVarArray>) x leq: (CPInt) c
{
   id<CPConstraint> o = [[CPINEquationBC alloc] initCPINEquationBC: x lequal: c];
   [[x tracker] trackObject: o];
   return o;
}

+(id<CPConstraint>) boolean:(id<CPIntVar>)x or:(id<CPIntVar>)y equal:(id<CPIntVar>)b
{
   id<CPConstraint> o = [[CPOrDC alloc] initCPOrDC:b equal:x or:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<CPConstraint>) boolean:(id<CPIntVar>)x and:(id<CPIntVar>)y equal:(id<CPIntVar>)b
{
   id<CPConstraint> o = [[CPAndDC alloc] initCPAndDC:b equal:x and:y];
   [[x tracker] trackObject:o];
   return o;
}
+(id<CPConstraint>) boolean:(id<CPIntVar>)x imply:(id<CPIntVar>)y equal:(id<CPIntVar>)b
{
   id<CPConstraint> o = [[CPImplyDC alloc] initCPImplyDC:b equal:x imply:y];
   [[x tracker] trackObject:o];
   return o;   
}

+(id<CPConstraint>) circuit: (id<CPIntVarArray>) x
{
    id<CPConstraint> o = [[CPCircuitI alloc] initCPCircuitI:x];
    [[x tracker] trackObject: o];
    return o;
}

+(id<CPConstraint>) packing: (id<CPIntVarArray>) x itemSize: (id<CPIntArray>) itemSize binSize: (id<CPIntArray>) binSize;
{
   CPRange R = [binSize range];
   id<CPIntVarArray> load = [CPFactory intVarArray: [x cp] range: R];
   for(CPInt i = R.low; i <= R.up; i++) 
      load[i] = [CPFactory intVar: [x cp] domain:(CPRange){0,[binSize at:i]}];
   id<CPConstraint> o = [CPFactory packing: x itemSize: itemSize load: load];
   [[x tracker] trackObject: o];
   return o;
}

typedef struct _CPPairIntId {
   CPInt        _int;
   id           _id;
} CPPairIntId;

int compareCPPairIntId(const CPPairIntId* r1,const CPPairIntId* r2)
{
   return r2->_int - r1->_int;
}

+(void) sortIntVarInt: (id<CPIntVarArray>) x size: (id<CPIntArray>) size sorted: (id<CPIntVarArray>*) sx sortedSize: (id<CPIntArray>*) sortedSize
{
   CPRange R = [x range];
   int nb = R.up - R.low + 1;
   int low = R.low;
   CPPairIntId* toSort = (CPPairIntId*) alloca(sizeof(CPPairIntId) * nb);
   int k = 0;
   for(CPInt i = R.low; i <= R.up; i++)
      toSort[k++] = (CPPairIntId){[size at: i],x[i]};
   qsort(toSort,nb,sizeof(CPPairIntId),(int(*)(const void*,const void*)) &compareCPPairIntId);
   
   *sx = [CPFactory intVarArray: [x cp] range: R with: ^id<CPIntVar>(int i) { return toSort[i - low]._id; }];
   *sortedSize = [CPFactory intArray:[x cp] range: R with: ^ORInt(ORInt i) { return toSort[i - low]._int; }];
}

+(id<CPConstraint>) packing: (id<CPIntVarArray>) x itemSize: (id<CPIntArray>) itemSize load: (id<CPIntArray>) load;
{
   id<CPIntVarArray> sortedItem;
   id<CPIntArray> sortedSize;
   [CPFactory sortIntVarInt: x size: itemSize sorted: &sortedItem sortedSize: &sortedSize];
   NSLog(@"%@",sortedItem);
   NSLog(@"%@",sortedSize);
   id<CPConstraint> o = [[CPBinPackingI alloc] initCPBinPackingI: sortedItem itemSize: sortedSize binSize: load];
   [[x tracker] trackObject: o];
   return o;
}

+(id<CPConstraint>) packOne: (id<CPIntVarArray>) item itemSize: (id<CPIntArray>) itemSize bin: (CPInt) b binSize: (id<CPIntVar>) binSize
{
   id<CPConstraint> o = [[CPOneBinPackingI alloc] initCPOneBinPackingI: item itemSize: itemSize bin: b binSize: binSize];
   [[item tracker] trackObject: o];
   return o;
   
}
+(id<CPConstraint>) nocycle: (id<CPIntVarArray>) x
{
    id<CPConstraint> o = [[CPCircuitI alloc] initCPNoCycleI:x];
    [[x tracker] trackObject: o];
    return o;
}
+(id<CPConstraint>) equal: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(int) c
{
   id<CPConstraint> o = [[CPEqualBC alloc] initCPEqualBC:x and:y and:c];
   [[x tracker] trackObject:o];
   return o;   
}
+(id<CPConstraint>) equal: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(int) c consistency: (CPConsistency)cons
{
   id<CPConstraint> o = nil;
   switch(cons) {
      case DomainConsistency:
         o = [[CPEqualDC alloc] initCPEqualDC:x and:y and:c];break;
      default: 
         o = [[CPEqualBC alloc] initCPEqualBC:x and:y and:c];break;
   }
   [[x tracker] trackObject:o];
   return o;   
}
+(id<CPConstraint>) equal3: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(id<CPIntVar>) z consistency: (CPConsistency)cons
{
   id<CPConstraint> o = nil;
   switch(cons) {
      case DomainConsistency:
         o = [[CPEqual3DC alloc] initCPEqual3DC:y plus:z equal:x];break;
      default: 
         // TOFIX
         o = [[CPEqual3DC alloc] initCPEqual3DC:y plus:z equal:x];break;
         //o = [[CPEqualBC alloc] initCPEqualBC:y and:z and:x];break;
   }
   [[[x cp] solver] trackObject:o];
   return o;   
}
+(id<CPConstraint>) equalc: (id<CPIntVar>) x to:(int) c
{
   id<CPConstraint> o = [[CPEqualc alloc] initCPEqualc:x and:c];
   [[[x cp] solver] trackObject:o];
   return o;      
}
+(id<CPConstraint>) notEqual:(id<CPIntVar>)x to:(id<CPIntVar>)y plus:(int)c
{
   id<CPConstraint> o = [[CPNotEqual alloc] initCPNotEqual:x and:y and:c];
   [[[x cp] solver] trackObject:o];
   return o;
}
+(id<CPConstraint>) notEqual:(id<CPIntVar>)x to:(id<CPIntVar>)y 
{
   id<CPConstraint> o = [[CPBasicNotEqual alloc] initCPBasicNotEqual:x and:y];
   [[[x cp] solver] trackObject:o];
   return o;
}
+(id<CPConstraint>) notEqualc:(id<CPIntVar>)x to:(CPInt)c 
{
   id<CPConstraint> o = [[CPDiffc alloc] initCPDiffc:x and:c];
   [[[x cp] solver] trackObject:o];
   return o;
}
+(id<CPConstraint>) lEqual: (id<CPIntVar>)x to: (id<CPIntVar>) y
{
   id<CPConstraint> o = [[CPLEqualBC alloc] initCPLEqualBC:x and:y];
   [[[x cp] solver] trackObject:o];
   return o;   
}
+(id<CPConstraint>) lEqualc: (id<CPIntVar>)x to: (CPInt) c
{
   id<CPConstraint> o = [[CPLEqualc alloc] initCPLEqualc:x and:c];
   [[[x cp] solver] trackObject:o];
   return o;   
}
+(id<CPConstraint>) less: (id<CPIntVar>)x to: (id<CPIntVar>) y
{
   id<CPIntVar> yp = [self intVar:y shift:-1];
   return [self lEqual:x to:yp];
}
+(id<CPConstraint>) mult: (id<CPIntVar>)x by:(id<CPIntVar>)y equal:(id<CPIntVar>)z
{
   id<CPConstraint> o = [[CPMultBC alloc] initCPMultBC:x times:y equal:z];
   [[[x cp] solver] trackObject:o];
   return o;   
}
+(id<CPConstraint>) abs: (id<CPIntVar>)x equal:(id<CPIntVar>)y consistency:(CPConsistency)c
{
   id<CPConstraint> o = nil;
   switch (c) {
      case DomainConsistency:
         o = [[CPAbsDC alloc] initCPAbsDC:x equal:y];
         break;
      default: 
         o = [[CPAbsBC alloc] initCPAbsBC:x equal:y];
         break;
   }
   [[[x cp] solver] trackObject:o];
   return o;   
}
+(id<CPConstraint>) element:(id<CPIntVar>)x idxCstArray:(id<CPIntArray>)c equal:(id<CPIntVar>)y
{
   id<CPConstraint> o = [[CPElementCstBC alloc] initCPElementBC:x indexCstArray:c equal:y];
   [[[x cp] solver] trackObject:o];
   return o;
}
+(id<CPConstraint>) element:(id<CPIntVar>)x idxVarArray:(id<CPIntVarArray>)c equal:(id<CPIntVar>)y
{
   id<CPConstraint> o = [[CPElementVarBC alloc] initCPElementBC:x indexVarArray:c equal:y];
   [[[x cp] solver] trackObject:o];
   return o;
}
+(id<CPConstraint>) table: (CPTableI*) table on: (id<CPIntVarArray>) x
{
    id<CPConstraint> o = [[CPTableCstrI alloc] initCPTableCstrI: x table: table];
    [[[x cp] solver] trackObject:o];
    return o;
}
+(id<CPConstraint>) table: (CPTableI*) table on: (CPIntVarI*) x : (CPIntVarI*) y : (CPIntVarI*) z;
{
    id<CPConstraint> o = [[CPTableCstrI alloc] initCPTableCstrI: table on: x : y : z];
    [[[x cp] solver] trackObject:o];
    return o;    
}
+(id<CPConstraint>) assignment: (id<CPIntVarArray>) x matrix: (id<CPIntMatrix>) matrix cost: (id<CPIntVar>) cost
{
   id<CPConstraint> o = [[CPAssignment alloc] initCPAssignment: x matrix: matrix cost: cost];
   [[[x cp] solver] trackObject:o];
   return o;
}
+(id<CPConstraint>) lex:(id<CPIntVarArray>)x leq:(id<CPIntVarArray>)y
{
   id<CPConstraint> o = [[CPLexConstraint alloc] initCPLexConstraint:x and:y];
   [[[x cp] solver] trackObject:o];
   return o;
}

@end

