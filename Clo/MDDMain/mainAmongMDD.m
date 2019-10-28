/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
#import <objcp/CPConstraint.h>
#import <ORFoundation/ORFoundation.h>
#import <ORSchedulingProgram/ORSchedulingProgram.h>


int main (int argc, const char * argv[])
{
    @autoreleasepool {
        
        id<ORModel> mdl = [ORFactory createModel];
        id<ORAnnotation> notes= [ORFactory annotation];
        id<ORMutableInteger> nbSolutions = [ORFactory mutable: mdl value: 0];
        
        
        NSSet* even = [NSSet setWithObjects:@2, @4, nil];
        NSSet* five = [NSSet setWithObjects:@5, nil];
//        NSSet* middle = [NSSet setWithObjects:@2, @3, @4, nil];
//        NSSet* ends = [NSSet setWithObjects:@1, @5, nil];
//        NSSet* onetwo = [NSSet setWithObjects:@1, @2, nil];
        id<ORIntSet> countedValues1 = [ORFactory intSet: mdl set: even];
        id<ORIntSet> countedValues2 = [ORFactory intSet: mdl set: five];
//        id<ORIntSet> countedValues3 = [ORFactory intSet: mdl set: middle];
//        id<ORIntSet> countedValues4 = [ORFactory intSet: mdl set: ends];
//        id<ORIntSet> countedValues5 = [ORFactory intSet: mdl set: onetwo];
        id<ORInteger> lower1 = [ORFactory integer:mdl value:5];
        id<ORInteger> upper1 = [ORFactory integer:mdl value:10];
        id<ORInteger> lower2 = [ORFactory integer:mdl value:2];
        id<ORInteger> upper2 = [ORFactory integer:mdl value:3];
//        id<ORInteger> lower3 = [ORFactory integer:mdl value:30];
//        id<ORInteger> upper3 = [ORFactory integer:mdl value:40];
//        id<ORInteger> lower4 = [ORFactory integer:mdl value:5];
//        id<ORInteger> upper4 = [ORFactory integer:mdl value:15];
//        id<ORInteger> lower5 = [ORFactory integer:mdl value:11];
//        id<ORInteger> upper5 = [ORFactory integer:mdl value:12];
        
        id<ORInteger> zero = [ORFactory integer:mdl value:0];
        
        typedef enum {
         minCount,
         maxCount,
         remaining
        } AmongState;
         
        
         id<ORIntVarArray> variables = [ORFactory intVarArray:mdl range: RANGE(mdl, 1, 50) domain: RANGE(mdl, 1, 5)];
         id<ORMDDSpecs> mddStateSpecs = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
         [mddStateSpecs addStateInt: minCount withDefaultValue: 0];
         [mddStateSpecs addStateInt: maxCount withDefaultValue: 0];
         [mddStateSpecs addStateInt: remaining withDefaultValue: 50];
        
         id<ORExpr> arcExists = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues1 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper1 track:mdl]
         land:
         [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues1 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower1 track: mdl] track: mdl];
         
         [mddStateSpecs setArcExistsFunction: arcExists];
         
         //self["minCount"] = parent["minCount"] + (parentValue in countedValues)
        id<ORExpr> minCountTransitionFunction = [[ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues1 contains:[ORFactory valueAssignment:mdl]] track: mdl];
        //self["maxCount"] = parent["maxCount"] + (parentValue in countedValues)
         id<ORExpr> maxCountTransitionFunction = [[ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues1 contains:[ORFactory valueAssignment:mdl]] track: mdl];
         //self["remaining"] = parent["remaining"] - 1
         id<ORExpr> remainingTransitionFunction = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
         [mddStateSpecs addTransitionFunction: minCountTransitionFunction toStateValue: minCount];
         [mddStateSpecs addTransitionFunction: maxCountTransitionFunction toStateValue: maxCount];
         [mddStateSpecs addTransitionFunction: remainingTransitionFunction toStateValue: remaining];
         id<ORExpr> minCountRelaxationFunction = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] min:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl];
         id<ORExpr> maxCountRelaxationFunction = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] max:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl];
         id<ORExpr> remainingRelaxationFunction = [ORFactory getLeftStateValue:mdl lookup:remaining];
         [mddStateSpecs addRelaxationFunction: minCountRelaxationFunction toStateValue: minCount];
         [mddStateSpecs addRelaxationFunction: maxCountRelaxationFunction toStateValue: maxCount];
         [mddStateSpecs addRelaxationFunction: remainingRelaxationFunction toStateValue: remaining];
        
         id<ORExpr> minCountStateDifferential = [[[ORFactory getLeftStateValue:mdl lookup:minCount] sub:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl] absTrack:mdl];
         id<ORExpr> maxCountStateDifferential = [[[ORFactory getLeftStateValue:mdl lookup:maxCount] sub:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl] absTrack:mdl];
         id<ORExpr> remainingStateDifferential = zero;
         
         [mddStateSpecs addStateDifferentialFunction: minCountStateDifferential toStateValue: minCount];
         [mddStateSpecs addStateDifferentialFunction: maxCountStateDifferential toStateValue: maxCount];
         [mddStateSpecs addStateDifferentialFunction: remainingStateDifferential toStateValue: remaining];
         
         [mdl add: mddStateSpecs];
         
         
         id<ORMDDSpecs> mddStateSpecs2 = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
         [mddStateSpecs2 addStateInt: minCount withDefaultValue: 0];
         [mddStateSpecs2 addStateInt: maxCount withDefaultValue: 0];
         [mddStateSpecs2 addStateInt: remaining withDefaultValue: 50];
         
         id<ORExpr> arcExists2 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues2 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper2 track:mdl]
         land:
         [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues2 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower2 track: mdl] track: mdl];
         
         [mddStateSpecs2 setArcExistsFunction: arcExists2];
         
         id<ORExpr> minCountTransitionFunction2 = [[ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues2 contains:[ORFactory valueAssignment:mdl]] track: mdl];
         id<ORExpr> maxCountTransitionFunction2 = [[ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues2 contains:[ORFactory valueAssignment:mdl]] track: mdl];
         id<ORExpr> remainingTransitionFunction2 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
         
         [mddStateSpecs2 addTransitionFunction: minCountTransitionFunction2 toStateValue: minCount];
         [mddStateSpecs2 addTransitionFunction: maxCountTransitionFunction2 toStateValue: maxCount];
         [mddStateSpecs2 addTransitionFunction: remainingTransitionFunction2 toStateValue: remaining];
         
         id<ORExpr> minCountRelaxationFunction2 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] min:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl];
         id<ORExpr> maxCountRelaxationFunction2 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] max:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl];
         id<ORExpr> remainingRelaxationFunction2 = [ORFactory getLeftStateValue:mdl lookup:remaining];
         [mddStateSpecs2 addRelaxationFunction: minCountRelaxationFunction2 toStateValue: minCount];
         [mddStateSpecs2 addRelaxationFunction: maxCountRelaxationFunction2 toStateValue: maxCount];
         [mddStateSpecs2 addRelaxationFunction: remainingRelaxationFunction2 toStateValue: remaining];
        
         id<ORExpr> minCountStateDifferential2 = [[[ORFactory getLeftStateValue:mdl lookup:minCount] sub:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl] absTrack:mdl];
         id<ORExpr> maxCountStateDifferential2 = [[[ORFactory getLeftStateValue:mdl lookup:maxCount] sub:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl] absTrack:mdl];
         id<ORExpr> remainingStateDifferential2 = zero;
         
         [mddStateSpecs2 addStateDifferentialFunction: minCountStateDifferential2 toStateValue: minCount];
         [mddStateSpecs2 addStateDifferentialFunction: maxCountStateDifferential2 toStateValue: maxCount];
         [mddStateSpecs2 addStateDifferentialFunction: remainingStateDifferential2 toStateValue: remaining];
         
         [mdl add: mddStateSpecs2];
         
         /*
         id<ORMDDSpecs> mddStateSpecs3 = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
         [mddStateSpecs3 addStateInt: minCount withDefaultValue: 0];
         [mddStateSpecs3 addStateInt: maxCount withDefaultValue: 0];
         [mddStateSpecs3 addStateInt: remaining withDefaultValue: 50];
         
         id<ORExpr> arcExists3 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues3 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper3 track:mdl]
         land:
         [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues3 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower3 track: mdl] track: mdl];
         
         [mddStateSpecs3 setArcExistsFunction: arcExists3];
         
         id<ORExpr> minCountTransitionFunction3 = [[ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues3 contains:[ORFactory valueAssignment:mdl]] track: mdl];
         id<ORExpr> maxCountTransitionFunction3 = [[ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues3 contains:[ORFactory valueAssignment:mdl]] track: mdl];
         id<ORExpr> remainingTransitionFunction3 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
         
         [mddStateSpecs3 addTransitionFunction: minCountTransitionFunction3 toStateValue: minCount];
         [mddStateSpecs3 addTransitionFunction: maxCountTransitionFunction3 toStateValue: maxCount];
         [mddStateSpecs3 addTransitionFunction: remainingTransitionFunction3 toStateValue: remaining];
         
         id<ORExpr> minCountRelaxationFunction3 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] min:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl];
         id<ORExpr> maxCountRelaxationFunction3 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] max:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl];
         id<ORExpr> remainingRelaxationFunction3 = [ORFactory getLeftStateValue:mdl lookup:remaining];
         [mddStateSpecs3 addRelaxationFunction: minCountRelaxationFunction3 toStateValue: minCount];
         [mddStateSpecs3 addRelaxationFunction: maxCountRelaxationFunction3 toStateValue: maxCount];
         [mddStateSpecs3 addRelaxationFunction: remainingRelaxationFunction3 toStateValue: remaining];
        
         id<ORExpr> minCountStateDifferential3 = [[[ORFactory getLeftStateValue:mdl lookup:minCount] sub:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl] absTrack:mdl];
         id<ORExpr> maxCountStateDifferential3 = [[[ORFactory getLeftStateValue:mdl lookup:maxCount] sub:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl] absTrack:mdl];
         id<ORExpr> remainingStateDifferential3 = zero;
         
         [mddStateSpecs3 addStateDifferentialFunction: minCountStateDifferential3 toStateValue: minCount];
         [mddStateSpecs3 addStateDifferentialFunction: maxCountStateDifferential3 toStateValue: maxCount];
         [mddStateSpecs3 addStateDifferentialFunction: remainingStateDifferential3 toStateValue: remaining];
         
         //[mdl add: mddStateSpecs3];
         
         
         
         id<ORMDDSpecs> mddStateSpecs4 = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
         [mddStateSpecs4 addStateInt: minCount withDefaultValue: 0];
         [mddStateSpecs4 addStateInt: maxCount withDefaultValue: 0];
         [mddStateSpecs4 addStateInt: remaining withDefaultValue: 50];
         
         id<ORExpr> arcExists4 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues4 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper4 track:mdl]
         land:
         [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues4 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower4 track: mdl] track: mdl];
         
         [mddStateSpecs4 setArcExistsFunction: arcExists4];
         
         id<ORExpr> minCountTransitionFunction4 = [[ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues4 contains:[ORFactory valueAssignment:mdl]] track: mdl];
         id<ORExpr> maxCountTransitionFunction4 = [[ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues4 contains:[ORFactory valueAssignment:mdl]] track: mdl];
         id<ORExpr> remainingTransitionFunction4 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
         
         [mddStateSpecs4 addTransitionFunction: minCountTransitionFunction4 toStateValue: minCount];
         [mddStateSpecs4 addTransitionFunction: maxCountTransitionFunction4 toStateValue: maxCount];
         [mddStateSpecs4 addTransitionFunction: remainingTransitionFunction4 toStateValue: remaining];
         
         id<ORExpr> minCountRelaxationFunction4 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] min:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl];
         id<ORExpr> maxCountRelaxationFunction4 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] max:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl];
         id<ORExpr> remainingRelaxationFunction4 = [ORFactory getLeftStateValue:mdl lookup:remaining];
         [mddStateSpecs4 addRelaxationFunction: minCountRelaxationFunction4 toStateValue: minCount];
         [mddStateSpecs4 addRelaxationFunction: maxCountRelaxationFunction4 toStateValue: maxCount];
         [mddStateSpecs4 addRelaxationFunction: remainingRelaxationFunction4 toStateValue: remaining];
        
         id<ORExpr> minCountStateDifferential4 = [[[ORFactory getLeftStateValue:mdl lookup:minCount] sub:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl] absTrack:mdl];
         id<ORExpr> maxCountStateDifferential4 = [[[ORFactory getLeftStateValue:mdl lookup:maxCount] sub:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl] absTrack:mdl];
         id<ORExpr> remainingStateDifferential4 = zero;
         
         [mddStateSpecs4 addStateDifferentialFunction: minCountStateDifferential4 toStateValue: minCount];
         [mddStateSpecs4 addStateDifferentialFunction: maxCountStateDifferential4 toStateValue: maxCount];
         [mddStateSpecs4 addStateDifferentialFunction: remainingStateDifferential4 toStateValue: remaining];
         
         //[mdl add: mddStateSpecs4];
         
         
         id<ORMDDSpecs> mddStateSpecs5 = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
         [mddStateSpecs5 addStateInt: minCount withDefaultValue: 0];
         [mddStateSpecs5 addStateInt: maxCount withDefaultValue: 0];
         [mddStateSpecs5 addStateInt: remaining withDefaultValue: 50];
         
         id<ORExpr> arcExists5 = [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues5 contains:[ORFactory valueAssignment:mdl]] track:mdl] leq: upper5 track:mdl]
         land:
         [[[ORFactory expr: [ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues5 contains:[ORFactory valueAssignment:mdl]] track:mdl] plus: [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl] track: mdl] geq: lower5 track: mdl] track: mdl];
         
         [mddStateSpecs5 setArcExistsFunction: arcExists5];
         
         id<ORExpr> minCountTransitionFunction5 = [[ORFactory getStateValue:mdl lookup:minCount] plus: [countedValues5 contains:[ORFactory valueAssignment:mdl]] track: mdl];
         id<ORExpr> maxCountTransitionFunction5 = [[ORFactory getStateValue:mdl lookup:maxCount] plus: [countedValues5 contains:[ORFactory valueAssignment:mdl]] track: mdl];
         id<ORExpr> remainingTransitionFunction5 = [[ORFactory getStateValue:mdl lookup:remaining] sub: @1 track: mdl];
         
         [mddStateSpecs5 addTransitionFunction: minCountTransitionFunction5 toStateValue: minCount];
         [mddStateSpecs5 addTransitionFunction: maxCountTransitionFunction5 toStateValue: maxCount];
         [mddStateSpecs5 addTransitionFunction: remainingTransitionFunction5 toStateValue: remaining];
         
         id<ORExpr> minCountRelaxationFunction5 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:minCount] min:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl];
         id<ORExpr> maxCountRelaxationFunction5 = [ORFactory expr: [ORFactory getLeftStateValue:mdl lookup:maxCount] max:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl];
         id<ORExpr> remainingRelaxationFunction5 = [ORFactory getLeftStateValue:mdl lookup:remaining];
         [mddStateSpecs5 addRelaxationFunction: minCountRelaxationFunction5 toStateValue: minCount];
         [mddStateSpecs5 addRelaxationFunction: maxCountRelaxationFunction5 toStateValue: maxCount];
         [mddStateSpecs5 addRelaxationFunction: remainingRelaxationFunction5 toStateValue: remaining];
        
         id<ORExpr> minCountStateDifferential5 = [[[ORFactory getLeftStateValue:mdl lookup:minCount] sub:[ORFactory getRightStateValue:mdl lookup:minCount] track:mdl] absTrack:mdl];
         id<ORExpr> maxCountStateDifferential5 = [[[ORFactory getLeftStateValue:mdl lookup:maxCount] sub:[ORFactory getRightStateValue:mdl lookup:maxCount] track:mdl] absTrack:mdl];
         id<ORExpr> remainingStateDifferential5 = zero;
         
         [mddStateSpecs5 addStateDifferentialFunction: minCountStateDifferential5 toStateValue: minCount];
         [mddStateSpecs5 addStateDifferentialFunction: maxCountStateDifferential5 toStateValue: maxCount];
         [mddStateSpecs5 addStateDifferentialFunction: remainingStateDifferential5 toStateValue: remaining];
         
         
         //[mdl add: mddStateSpecs5];
        
        */
        ORLong startWC  = [ORRuntimeMonitor wctime];
        ORLong startCPU = [ORRuntimeMonitor cputime];
        
        [notes ddWidth:4];
        [notes ddRelaxed: false];
        id<CPProgram> cp = [ORFactory createCPMDDProgram:mdl annotation: notes];
        
        [cp solve: ^{
            [cp labelArray: variables];
            for (int i = 1; i <= [variables count]; i++) {
                printf("%d  ",[cp intValue: [variables at:i]]);
            }
            [nbSolutions incr: cp];
        }
         ];
        
        ORLong endWC  = [ORRuntimeMonitor wctime];
        ORLong endCPU = [ORRuntimeMonitor cputime];
        
        printf("\nTook %lld WC and %lld CPU\n\n",(endWC-startWC),(endCPU-startCPU));
        
        printf("GOT %d solutions\n",[nbSolutions intValue:cp]);
        NSLog(@"Solver status: %@\n",cp);
        NSLog(@"Quitting");
    }
    
    return 0;
}
