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
        
        int minDomain = 1;
        int maxDomain = 10;
        
        id<ORIntVarArray> variables = [ORFactory intVarArray:mdl range: RANGE(mdl, 1, 10) domain: RANGE(mdl, minDomain,maxDomain)];
        id<ORMDDSpecs> mddStateSpecs = [ORFactory MDDSpecs: mdl variables:variables stateSize: (maxDomain-minDomain+1)];
        for (int index = 0; index < (maxDomain-minDomain+1); index++) {
            [mddStateSpecs addStateBool:index withDefaultValue:true];
            
            id<ORExpr> transitionFunction = [[ORFactory getStateValue:mdl lookup:index] land: [[ORFactory valueAssignment:mdl] eq:@(index+minDomain)] track: mdl];
            [mddStateSpecs addTransitionFunction: transitionFunction toStateValue: index];
            
            id<ORExpr> relaxationFunction = [ORFactory expr: [[ORFactory getLeftStateValue:mdl lookup:index] eq:@true track:mdl] lor:[[ORFactory getRightStateValue:mdl lookup:index] eq:@true track:mdl] track:mdl];
            [mddStateSpecs addRelaxationFunction: relaxationFunction toStateValue: index];
            
            id<ORExpr> stateDifferential = [[[ORFactory getLeftStateValue:mdl lookup:index] sub:[ORFactory getRightStateValue:mdl lookup:index] track:mdl] absTrack:mdl];
            [mddStateSpecs addStateDifferentialFunction: stateDifferential toStateValue: index];
        }
        
        id<ORExpr> arcExists = [ORFactory getStateValue:mdl lookupExpr:[[ORFactory valueAssignment:mdl] sub:@(minDomain) track:mdl]];
        [mddStateSpecs setArcExistsFunction: arcExists];
        
        
        [mdl add: mddStateSpecs];
        
        
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
