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
        
        id<ORIntVarArray> variables = [ORFactory intVarArray:mdl range: RANGE(mdl, 1, 20) domain: RANGE(mdl, 0, 20)];
         
         struct SequenceInfo {
         int length;
         int lastIndex;
         int lower;
         int upper;
         id<ORIntSet> countedValues;
         };
         
         struct SequenceInfo sequenceConstraints[7];
         
         sequenceConstraints[0].length = 7;
         sequenceConstraints[0].lower = 1;
         sequenceConstraints[0].upper = 5;
         sequenceConstraints[0].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@0, @2, @9, @11, @13, nil]];
         
         sequenceConstraints[1].length = 7;
         sequenceConstraints[1].lower = 4;
         sequenceConstraints[1].upper = 5;
         sequenceConstraints[1].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@0, @1, @2, @4, @5, @6, @10, @11, @12, @14, @16, @18, @19, nil]];
         
         sequenceConstraints[2].length = 8;
         sequenceConstraints[2].lower = 1;
         sequenceConstraints[2].upper = 6;
         sequenceConstraints[2].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @15, @16, @17, @18, @19, nil]];
         
         sequenceConstraints[3].length = 5;
         sequenceConstraints[3].lower = 1;
         sequenceConstraints[3].upper = 1;
         sequenceConstraints[3].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@1, nil]];
         
         sequenceConstraints[4].length = 9;
         sequenceConstraints[4].lower = 1;
         sequenceConstraints[4].upper = 6;
         sequenceConstraints[4].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@1, @3, @5, @8, @10, @11, @12, @15, @16, @19, nil]];
         
         sequenceConstraints[5].length = 5;
         sequenceConstraints[5].lower = 1;
         sequenceConstraints[5].upper = 2;
         sequenceConstraints[5].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@2, @4, @5, @6, @8, @12, @18, nil]];
         
         sequenceConstraints[6].length = 2;
         sequenceConstraints[6].lower = 0;
         sequenceConstraints[6].upper = 1;
         sequenceConstraints[6].countedValues = [ORFactory intSet:mdl set:[NSSet setWithObjects:@0, @3, @5, @6, @7, @8, @9, @10, @11, @12, @13, @15, @16, @17, @18, nil]];
         
         
         
         
         for (int sequenceConstraintIndex = 0; sequenceConstraintIndex < 7; sequenceConstraintIndex++) {
             struct SequenceInfo sequenceConstraint = sequenceConstraints[sequenceConstraintIndex];
         
             int minFirstIndex = 0;
             int minLastIndex = sequenceConstraint.length-1;
             int maxFirstIndex = sequenceConstraint.length;
             int maxLastIndex = sequenceConstraint.length*2-1;
         
             //Sequence using dynamically built state size of 'length' variables
             id<ORMDDSpecs> mddStateSpecs = [ORFactory MDDSpecs: mdl variables:variables stateSize: sequenceConstraint.length*2];
             for (int index = minFirstIndex; index < minLastIndex; index++) {
                 [mddStateSpecs addStateInt:index withDefaultValue:-1];
             }
             [mddStateSpecs addStateInt:minLastIndex withDefaultValue:0];
             for (int index = sequenceConstraint.length; index < maxLastIndex; index++) {
                 [mddStateSpecs addStateInt:index withDefaultValue:-1];
             }
             [mddStateSpecs addStateInt:maxLastIndex withDefaultValue:0];
         
             id<ORExpr> arcExists = [[[ORFactory getStateValue:mdl lookup:1] eq:@(-1) track:mdl]
                                     lor: [[ORFactory expr: [[[ORFactory getStateValue:mdl lookup:maxLastIndex] sub: [ORFactory getStateValue:mdl lookup:minFirstIndex]] plus:[sequenceConstraint.countedValues contains:[ORFactory valueAssignment:mdl]] track:mdl] geq:[ORFactory integer:mdl value:sequenceConstraint.lower] track:mdl]
                                           land:
                                           [ORFactory expr: [[[ORFactory getStateValue:mdl lookup:minLastIndex] sub: [ORFactory getStateValue:mdl lookup:maxFirstIndex]] plus:[sequenceConstraint.countedValues contains:[ORFactory valueAssignment:mdl]] track:mdl] leq:[ORFactory integer:mdl value:sequenceConstraint.upper] track:mdl] track:mdl] track:mdl];
         
         
             [mddStateSpecs setArcExistsFunction: arcExists];
         
             for (int index = minFirstIndex; index < minLastIndex; index++) {
                 id<ORExpr> transitionFunction = [ORFactory getStateValue:mdl lookup:(index+1)];
                 [mddStateSpecs addTransitionFunction: transitionFunction toStateValue:index];   //Slide all to the left one
             }
             id<ORExpr> minLastIndexTransitionFunction = [[ORFactory getStateValue:mdl lookup:minLastIndex] plus:[sequenceConstraint.countedValues contains:[ORFactory valueAssignment:mdl]] track:mdl];
             [mddStateSpecs addTransitionFunction:minLastIndexTransitionFunction toStateValue:minLastIndex];
         
             for (int index = maxFirstIndex; index < maxLastIndex; index++) {
                 id<ORExpr> transitionFunction = [ORFactory getStateValue:mdl lookup:(index+1)];
                 [mddStateSpecs addTransitionFunction: transitionFunction toStateValue:index];
             }
             id<ORExpr> maxLastIndexTransitionFunction = [[ORFactory getStateValue:mdl lookup:maxLastIndex] plus:[sequenceConstraint.countedValues contains:[ORFactory valueAssignment:mdl]] track:mdl];
             [mddStateSpecs addTransitionFunction:maxLastIndexTransitionFunction toStateValue:maxLastIndex];
         
             for (int index = 0; index < sequenceConstraint.length; index++) {
                 id<ORExpr> minRelaxationFunction = [ORFactory expr:[ORFactory getLeftStateValue:mdl lookup:minFirstIndex+index] min:[ORFactory getRightStateValue:mdl lookup:minFirstIndex+index] track:mdl];
                 id<ORExpr> maxRelaxationFunction = [ORFactory expr:[ORFactory getLeftStateValue:mdl lookup:maxFirstIndex+index] max:[ORFactory getRightStateValue:mdl lookup:maxFirstIndex+index] track:mdl];
                 [mddStateSpecs addRelaxationFunction: minRelaxationFunction toStateValue: (minFirstIndex + index)];
                 [mddStateSpecs addRelaxationFunction: maxRelaxationFunction toStateValue: (maxFirstIndex + index)];
             }
         
             for (int index = minFirstIndex; index <= maxLastIndex; index++) {
                 id<ORExpr> stateDifferential = [[[ORFactory getLeftStateValue:mdl lookup:index] sub:[ORFactory getRightStateValue:mdl lookup:index] track:mdl] absTrack:mdl];;
                 [mddStateSpecs addStateDifferentialFunction:stateDifferential toStateValue:index];
             }
         
             [mdl add: mddStateSpecs];
         }
        
        /*//Sequence using an NSMutableArray
         typedef enum {
         countArray
         } SequenceState;
         
         
         id<ORMDDSpecs> mddStateSpecs = [ORFactory MDDSpecs: mdl variables:variables stateSize: 3];
         [mddStateSpecs addStateIntArray: countArray withDefaultValues: 0];
         
         id<ORExpr> arcExists = [[ORFactory expr: [[ORFactory getStateValue:mdl lookup:countArray arrayIndex:sequenceLastIndex1] sub: [ORFactory getStateValue:mdl lookup:countArray arrayIndex:zero]] geq:sequenceLower1 track:mdl]
         land:
         [ORFactory expr: [[ORFactory getStateValue:mdl lookup:countArray arrayIndex:sequenceLastIndex1] sub: [ORFactory getStateValue:mdl lookup:countArray arrayIndex:zero]] leq:sequenceUpper1 track: mdl]];
         
         [mddStateSpecs setArcExistsFunction: arcExists];
         
         id<ORExpr> countArrayTransitionFunction = [[ORFactory copyIntArrayShiftedToLeft: [ORFactory getStateValue:mdl lookup:countArray] track:mdl] editIntArrayIndex:[sequenceLength1 sub:1 track:mdl] setTo:[[ORFactory getStateValue:mdl lookup:countArray] getIndexFromIntArray:[sequenceLength1 sub:1 track:mdl] track:mdl] track:mdl];
         [mddStateSpecs addTransitionFunction: countArrayTransitionFunction toStateValue: countArray];
         
         
         id<ORExpr> countArrayRelaxationFunction;
         [mddStateSpecs addRelaxationFunction: countArrayRelaxationFunction toStateValue: countArray];
         
         id<ORExpr> countArrayStateDifferential = zero;
         
         [mddStateSpecs addStateDifferentialFunction: countArrayStateDifferential toStateValue: countArray];
         
         [mdl add: mddStateSpecs];*/
        
        ORLong startWC  = [ORRuntimeMonitor wctime];
        ORLong startCPU = [ORRuntimeMonitor cputime];
        
        [notes ddWidth:4];
        [notes ddRelaxed: true];
        id<CPProgram> cp = [ORFactory createCPMDDProgram:mdl annotation: notes];
        
        [cp solve: ^{
            [cp labelArray: variables];
            
            for (int i = 1; i <= [variables count]; i++) {
                printf("%d  ",[cp intValue: [variables at:i]]);
            }
            printf("\n");
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
