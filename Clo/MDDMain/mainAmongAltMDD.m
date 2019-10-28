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

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        
        id<ORModel> mdl = [ORFactory createModel];
        id<ORAnnotation> notes= [ORFactory annotation];
        id<ORMutableInteger> nbSolutions = [ORFactory mutable: mdl value: 0];
        
        id<ORIntVarArray> variables = [ORFactory intVarArray:mdl range: RANGE(mdl, 1, 50) domain: RANGE(mdl, 1, 5)];
        
        NSSet* even = [NSSet setWithObjects:@2, @4, nil];
        NSSet* five = [NSSet setWithObjects:@5, nil];
        NSSet* middle = [NSSet setWithObjects:@2, @3, @4, nil];
        NSSet* ends = [NSSet setWithObjects:@1, @5, nil];
        NSSet* onetwo = [NSSet setWithObjects:@1, @2, nil];
        id<ORIntSet> countedValues1 = [ORFactory intSet: mdl set: even];
        id<ORIntSet> countedValues2 = [ORFactory intSet: mdl set: five];
        id<ORIntSet> countedValues3 = [ORFactory intSet: mdl set: middle];
        id<ORIntSet> countedValues4 = [ORFactory intSet: mdl set: ends];
        id<ORIntSet> countedValues5 = [ORFactory intSet: mdl set: onetwo];
        id<ORInteger> lower1 = [ORFactory integer:mdl value:5];
        id<ORInteger> upper1 = [ORFactory integer:mdl value:10];
        id<ORInteger> lower2 = [ORFactory integer:mdl value:2];
        id<ORInteger> upper2 = [ORFactory integer:mdl value:3];
        id<ORInteger> lower3 = [ORFactory integer:mdl value:30];
        id<ORInteger> upper3 = [ORFactory integer:mdl value:40];
        id<ORInteger> lower4 = [ORFactory integer:mdl value:5];
        id<ORInteger> upper4 = [ORFactory integer:mdl value:15];
        id<ORInteger> lower5 = [ORFactory integer:mdl value:11];
        id<ORInteger> upper5 = [ORFactory integer:mdl value:12];
        
        /*
         id<ORAltMDDSpecs> mddObjectiveSpecs = [ORFactory AltMDDSpecs: mdl variables: variables];
         [mddObjectiveSpecs setAsMaximize];
         [mddObjectiveSpecs setBottomUpInformationAsInt];
         [mddObjectiveSpecs setTopDownInformationAsInt];
         
         id<ORExpr> addEdgeToTopDown = [[ORFactory parentInformation:mdl] plus:[ORFactory valueAssignment:mdl] track:mdl];
         id<ORExpr> addEdgeToBottomUp = [[ORFactory parentInformation:mdl] plus:[ORFactory valueAssignment:mdl] track:mdl];
         
         [mddObjectiveSpecs setTopDownInfoEdgeAddition: addEdgeToTopDown];
         [mddObjectiveSpecs setBottomUpInfoEdgeAddition: addEdgeToBottomUp];
         [mddObjectiveSpecs setInformationMergeToMax:mdl];
         
         //[mdl add: mddObjectiveSpecs];
         */
         
         //Among, all path lengths
         id<ORAltMDDSpecs> mddStateSpecs1 = [ORFactory AltMDDSpecs: mdl variables: variables];
         [mddStateSpecs1 setBottomUpInformationAsSet];
         [mddStateSpecs1 addToBottomUpInfoSet: 0];
         [mddStateSpecs1 setTopDownInformationAsSet];
         [mddStateSpecs1 addToTopDownInfoSet: 0];
         
         
         
         //if for each v in Idown(s), v' in Iup(t), v + e + v' not in [l,u], delete
         id<ORExpr> deleteEdgeWhen1 = [[[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues1 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetLT:lower1 track:mdl] lor:
         [[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues1 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetGT:upper1 track:mdl] track:mdl];
         
         //Add e to each v in Idown(s)
         id<ORExpr> addEdgeToTopDown1 = [[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues1 contains: [ORFactory valueAssignment:mdl]] track:mdl];
         //Add e to each v in Iup(t)
         id<ORExpr> addEdgeToBottomUp1 =[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues1 contains: [ORFactory valueAssignment:mdl]] track:mdl];
         //Possibly should rename parentInformation here.  In theory, can just use same function since when it makes the closures for these, it should just be passing it the 'source' node and an edge.  The source node in top-down is the parent of an edge.  The source node in bottom-up is the child of an edge.
         
         [mddStateSpecs1 setEdgeDeletionCondition: deleteEdgeWhen1];
         [mddStateSpecs1 setTopDownInfoEdgeAddition: addEdgeToTopDown1];
         [mddStateSpecs1 setBottomUpInfoEdgeAddition: addEdgeToBottomUp1];
         [mddStateSpecs1 setInformationMergeToUnion:mdl];
         
         [mdl add: mddStateSpecs1];
         
         id<ORAltMDDSpecs> mddStateSpecs2 = [ORFactory AltMDDSpecs: mdl variables: variables];
         [mddStateSpecs2 setBottomUpInformationAsSet];
         [mddStateSpecs2 addToBottomUpInfoSet: 0];
         [mddStateSpecs2 setTopDownInformationAsSet];
         [mddStateSpecs2 addToTopDownInfoSet: 0];
         
         
         
         //if for each v in Idown(s), v' in Iup(t), v + e + v' not in [l,u], delete
         id<ORExpr> deleteEdgeWhen2 = [[[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues2 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetLT:lower2 track:mdl] lor:
         [[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues2 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetGT:upper2 track:mdl] track:mdl];
         
         //Add e to each v in Idown(s)
         id<ORExpr> addEdgeToTopDown2 = [[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues2 contains: [ORFactory valueAssignment:mdl]] track:mdl];
         //Add e to each v in Iup(t)
         id<ORExpr> addEdgeToBottomUp2 =[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues2 contains: [ORFactory valueAssignment:mdl]] track:mdl];
         //Possibly should rename parentInformation here.  In theory, can just use same function since when it makes the closures for these, it should just be passing it the 'source' node and an edge.  The source node in top-down is the parent of an edge.  The source node in bottom-up is the child of an edge.
         
         [mddStateSpecs2 setEdgeDeletionCondition: deleteEdgeWhen2];
         [mddStateSpecs2 setTopDownInfoEdgeAddition: addEdgeToTopDown2];
         [mddStateSpecs2 setBottomUpInfoEdgeAddition: addEdgeToBottomUp2];
         [mddStateSpecs2 setInformationMergeToUnion:mdl];
         
         [mdl add: mddStateSpecs2];
         
         id<ORAltMDDSpecs> mddStateSpecs3 = [ORFactory AltMDDSpecs: mdl variables: variables];
         [mddStateSpecs3 setBottomUpInformationAsSet];
         [mddStateSpecs3 addToBottomUpInfoSet: 0];
         [mddStateSpecs3 setTopDownInformationAsSet];
         [mddStateSpecs3 addToTopDownInfoSet: 0];
         
         
         
         //if for each v in Idown(s), v' in Iup(t), v + e + v' not in [l,u], delete
         id<ORExpr> deleteEdgeWhen3 = [[[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues3 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetLT:lower3 track:mdl] lor:
         [[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues3 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetGT:upper3 track:mdl] track:mdl];
         
         //Add e to each v in Idown(s)
         id<ORExpr> addEdgeToTopDown3 = [[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues3 contains: [ORFactory valueAssignment:mdl]] track:mdl];
         //Add e to each v in Iup(t)
         id<ORExpr> addEdgeToBottomUp3 =[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues3 contains: [ORFactory valueAssignment:mdl]] track:mdl];
         //Possibly should rename parentInformation here.  In theory, can just use same function since when it makes the closures for these, it should just be passing it the 'source' node and an edge.  The source node in top-down is the parent of an edge.  The source node in bottom-up is the child of an edge.
         
         [mddStateSpecs3 setEdgeDeletionCondition: deleteEdgeWhen3];
         [mddStateSpecs3 setTopDownInfoEdgeAddition: addEdgeToTopDown3];
         [mddStateSpecs3 setBottomUpInfoEdgeAddition: addEdgeToBottomUp3];
         [mddStateSpecs3 setInformationMergeToUnion:mdl];
         
         [mdl add: mddStateSpecs3];
         
         id<ORAltMDDSpecs> mddStateSpecs4 = [ORFactory AltMDDSpecs: mdl variables: variables];
         [mddStateSpecs4 setBottomUpInformationAsSet];
         [mddStateSpecs4 addToBottomUpInfoSet: 0];
         [mddStateSpecs4 setTopDownInformationAsSet];
         [mddStateSpecs4 addToTopDownInfoSet: 0];
         
         
         
         //if for each v in Idown(s), v' in Iup(t), v + e + v' not in [l,u], delete
         id<ORExpr> deleteEdgeWhen4 = [[[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues4 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetLT:lower4 track:mdl] lor:
         [[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues4 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetGT:upper4 track:mdl] track:mdl];
         
         //Add e to each v in Idown(s)
         id<ORExpr> addEdgeToTopDown4 = [[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues4 contains: [ORFactory valueAssignment:mdl]] track:mdl];
         //Add e to each v in Iup(t)
         id<ORExpr> addEdgeToBottomUp4 =[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues4 contains: [ORFactory valueAssignment:mdl]] track:mdl];
         //Possibly should rename parentInformation here.  In theory, can just use same function since when it makes the closures for these, it should just be passing it the 'source' node and an edge.  The source node in top-down is the parent of an edge.  The source node in bottom-up is the child of an edge.
         
         [mddStateSpecs4 setEdgeDeletionCondition: deleteEdgeWhen4];
         [mddStateSpecs4 setTopDownInfoEdgeAddition: addEdgeToTopDown4];
         [mddStateSpecs4 setBottomUpInfoEdgeAddition: addEdgeToBottomUp4];
         [mddStateSpecs4 setInformationMergeToUnion:mdl];
         
         [mdl add: mddStateSpecs4];
         
         id<ORAltMDDSpecs> mddStateSpecs5 = [ORFactory AltMDDSpecs: mdl variables: variables];
         [mddStateSpecs5 setBottomUpInformationAsSet];
         [mddStateSpecs5 addToBottomUpInfoSet: 0];
         [mddStateSpecs5 setTopDownInformationAsSet];
         [mddStateSpecs5 addToTopDownInfoSet: 0];
         
         
         
         //if for each v in Idown(s), v' in Iup(t), v + e + v' not in [l,u], delete
         id<ORExpr> deleteEdgeWhen5 = [[[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues5 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetLT:lower5 track:mdl] lor:
         [[[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues5 contains: [ORFactory valueAssignment:mdl]] track:mdl] toEachInSetPlusEachInSet: [ORFactory childInformation:mdl] track:mdl] eachInSetGT:upper5 track:mdl] track:mdl];
         
         //Add e to each v in Idown(s)
         id<ORExpr> addEdgeToTopDown5 = [[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues5 contains: [ORFactory valueAssignment:mdl]] track:mdl];
         //Add e to each v in Iup(t)
         id<ORExpr> addEdgeToBottomUp5 =[[ORFactory parentInformation:mdl] toEachInSetPlus:[countedValues5 contains: [ORFactory valueAssignment:mdl]] track:mdl];
         //Possibly should rename parentInformation here.  In theory, can just use same function since when it makes the closures for these, it should just be passing it the 'source' node and an edge.  The source node in top-down is the parent of an edge.  The source node in bottom-up is the child of an edge.
         
         [mddStateSpecs5 setEdgeDeletionCondition: deleteEdgeWhen5];
         [mddStateSpecs5 setTopDownInfoEdgeAddition: addEdgeToTopDown5];
         [mddStateSpecs5 setBottomUpInfoEdgeAddition: addEdgeToBottomUp5];
         [mddStateSpecs5 setInformationMergeToUnion:mdl];
         
         [mdl add: mddStateSpecs5];
         
        ORLong startWC  = [ORRuntimeMonitor wctime];
        ORLong startCPU = [ORRuntimeMonitor cputime];
        
        [notes ddWidth:4];
        [notes ddRelaxed: true];
        id<CPProgram> cp = [ORFactory createCPAltMDDProgram:mdl annotation: notes];
        
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
