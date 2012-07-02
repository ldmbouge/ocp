/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

@implementation CPFactory (Constraint)

// alldifferent
+(id<CPConstraint>) alldifferent: (id<CPIntVarArray>) x
{
    return [CPFactory alldifferent: x consistency: DomainConsistency];
}
+(id<CPConstraint>) alldifferent: (CPIntVarArrayI*) x consistency: (CPConsistency) c
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
            @throw [[CPExecutionError alloc] initCPExecutionError: "Range Consistency Not Implemented on alldifferent"];            
            break;
        default:
            @throw [[CPExecutionError alloc] initCPExecutionError: "Consistency Not Implemented on alldifferent"]; 
    }
    [[x solver] trackObject: o];
    return o;
}

// cardinality
+(id<CPConstraint>) cardinality: (id<CPIntVarArray>) x low: (id<CPIntArray>) low up: (id<CPIntArray>) up
{
    return [CPFactory cardinality: x low: low up: up consistency: ValueConsistency];
}
+(id<CPConstraint>) cardinality: (CPIntVarArrayI*) x low: (id<CPIntArray>) low up: (id<CPIntArray>) up consistency: (CPConsistency) c
{ 
    id<CPConstraint> o;
    switch (c) {
        case ValueConsistency:
            o = [[CPCardinalityCst alloc] initCardinalityCst: x low: low up: up]; 
            break;
        case RangeConsistency:
            @throw [[CPExecutionError alloc] initCPExecutionError: "Range Consistency Not Implemented on cardinality"];            
            break;
        case DomainConsistency: 
            o = [[CPCardinalityDC alloc] initCPCardinalityDC: x low: low up: up]; 
            break;
        default:
            @throw [[CPExecutionError alloc] initCPExecutionError: "Consistency Not Implemented on alldifferent"]; 
    }
    [[x solver] trackObject: o];
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

+(id<CPConstraint>) sumbool: (id<CPIntVarArray>) x geq: (CPInt) c
{
    id<CPConstraint> o = [[CPSumBoolGeq alloc] initCPSumBoolGeq: x geq: c];
    [[[x cp] solver] trackObject: o];
    return o;
}

+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (CPInt) c 
{
   return [self sum:x eq:c consistency:RangeConsistency];
}

+(id<CPConstraint>) sum: (id<CPIntVarArray>) x eq: (CPInt) c consistency: (CPConsistency)cons
{
   id<CPConstraint> o = [[CPEquationBC alloc] initCPEquationBC: x equal: c];
   [[[x cp] solver] trackObject: o];
   return o;
}

+(id<CPConstraint>) sum: (id<CPIntVarArray>) x leq: (CPInt) c
{
   id<CPConstraint> o = [[CPINEquationBC alloc] initCPINEquationBC: x lequal: c];
   [[[x cp] solver] trackObject: o];
   return o;
}

+(id<CPConstraint>) circuit: (CPIntVarArrayI*) x
{
    id<CPConstraint> o = [[CPCircuitI alloc] initCPCircuitI:x];
    [[[x cp] solver] trackObject: o];
    return o;
}

+(id<CPConstraint>) nocycle: (CPIntVarArrayI*) x
{
    id<CPConstraint> o = [[CPCircuitI alloc] initCPNoCycleI:x];
    [[[x cp] solver] trackObject: o];
    return o;
}
+(id<CPConstraint>) equal: (id<CPIntVar>) x to: (id<CPIntVar>) y plus:(int) c
{
   id<CPConstraint> o = [[CPEqualBC alloc] initCPEqualBC:x and:y and:c];
   [[[x cp] solver] trackObject:o];
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
   [[[x cp] solver] trackObject:o];
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
+(id<CPConstraint>) table: (CPTableI*) table on: (CPIntVarArrayI*) x
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
+(id<CPConstraint>) expr: (id<CPExpr>)e 
{
   id<CPConstraint> o = [[CPExprConstraintI alloc] initCPExprConstraintI:e consistency:ValueConsistency];
   [[[e cp] solver] trackObject:o];
   return o;
}
+(id<CPConstraint>) expr: (id<CPExpr>)e  consistency: (CPConsistency) c
{
   id<CPConstraint> o = [[CPExprConstraintI alloc] initCPExprConstraintI:e consistency:c];
   [[[e cp] solver] trackObject:o];
   return o;
}
+(id<CPConstraint>) assignment: (id<CPIntVarArray>) x matrix: (id<CPIntMatrix>) matrix
{
    id<CPConstraint> o = [[CPAssignment alloc] initCPAssignment: x matrix: matrix];
    [[[x cp] solver] trackObject:o];
    return o;
    
}
@end

