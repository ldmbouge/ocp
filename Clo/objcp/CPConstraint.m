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
#import "CPCircuitI.h"
#import "CPTableI.h"

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

+(id<CPConstraint>) table: (CPTableI*) table on: (CPIntVarArrayI*) x
{
    id<CPConstraint> o = [[CPTableCstrI alloc] initCPTableCstrI: x table: table];
    [[[x cp] solver] trackObject:o];
    return o;
    
}
@end

