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
        id<ORIntSet> countedValues1 = [ORFactory intSet: mdl set: even];
        id<ORInteger> lower1 = [ORFactory integer:mdl value:5];
        id<ORInteger> upper1 = [ORFactory integer:mdl value:5];
        
        id<ORInteger> zero = [ORFactory integer:mdl value:0];
        id<ORInteger> one = [ORFactory integer:mdl value:1];
        
        id<ORIntVarArray> variables = [ORFactory intVarArray:mdl range: RANGE(mdl, 1, 10) domain: RANGE(mdl, 1, 5)];
        id<ORAltMDDSpecs> mddStateSpecs = [ORFactory AltMDDSpecs: mdl variables: variables];
        id<ORInteger> sequenceSize = [ORFactory integer:mdl value:5];
        [mddStateSpecs setBottomUpInformationAsMinMaxArrayWithSize:1 andDefaultValue:0];
        [mddStateSpecs setTopDownInformationAsMinMaxArrayWithSize:1 andDefaultValue:0];
        
        id<ORExpr> sizeOfTopDownArray = [ORFactory sizeOfArray:[ORFactory minParentInformation:mdl] track:mdl];
        id<ORExpr> sizeOfBottomUpArray = [ORFactory sizeOfArray:[ORFactory minChildInformation:mdl] track:mdl];
        id<ORExpr> lastIndexOfTopDownArray = [sizeOfTopDownArray sub:one track:mdl];
        id<ORExpr> lastIndexOfBottomUpArray = [sizeOfBottomUpArray sub:one track:mdl];
        
        
        id<ORExpr> edgeIsUsed;
        
        id<ORExpr> lastValueInMaxTopDown = [[ORFactory maxParentInformation:mdl] arrayIndex:lastIndexOfTopDownArray track:mdl];
        id<ORExpr> lastValueInMinTopDown = [[ORFactory minParentInformation:mdl] arrayIndex:lastIndexOfTopDownArray track:mdl];
        id<ORExpr> lastValueInMaxBottomUp = [[ORFactory maxChildInformation:mdl] arrayIndex:lastIndexOfBottomUpArray track:mdl];
        id<ORExpr> lastValueInMinBottomUp = [[ORFactory minChildInformation:mdl] arrayIndex:lastIndexOfBottomUpArray track:mdl];
        
        id<ORExpr> valueIsCounted = [countedValues1 contains:[ORFactory valueAssignment:mdl]];
        id<ORExpr> lowerMinusEdge = [lower1 sub:valueIsCounted track:mdl];
        id<ORExpr> upperMinusEdge = [upper1 sub:valueIsCounted track:mdl];
        
        
        //This is overkill.  Only need to check at 'end' of each sequence
        for (int amountOfSequenceInTopDown = [sequenceSize value] -1; amountOfSequenceInTopDown < [sequenceSize value]; amountOfSequenceInTopDown++) {
            id<ORExpr> amountOfSequenceInTopDownExpr = [ORFactory integer:mdl value:amountOfSequenceInTopDown];
            id<ORExpr> a = [[sizeOfTopDownArray sub:amountOfSequenceInTopDownExpr track:mdl] sub:one];
            id<ORExpr> c = [[sizeOfBottomUpArray sub:sequenceSize track:mdl] plus:amountOfSequenceInTopDownExpr track:mdl];
            //The top-down information is an array of min and max counts of counted values.  To find the used expressions
            
            id<ORExpr> aValueInMaxTopDown = [[ORFactory maxParentInformation:mdl] arrayIndex:a track:mdl];
            id<ORExpr> aValueInMinTopDown = [[ORFactory minParentInformation:mdl] arrayIndex:a track:mdl];
            id<ORExpr> cValueInMaxBottomUp = [[ORFactory maxChildInformation:mdl] arrayIndex:c track:mdl];
            id<ORExpr> cValueInMinBottomUp = [[ORFactory minChildInformation:mdl] arrayIndex:c track:mdl];
            
            //Edge Is Used when  a and c are in the scope of array AND the size of the highest possible seuqence count using this edge and those a,b values is greater than lower bound AND the size of the lowest possible sequence count using this edge and those a,b values is less then upper bound
            if (amountOfSequenceInTopDown == 0) {
                edgeIsUsed = [[[a geq:zero track:mdl] land: [c geq:zero track:mdl] track:mdl] land:
                              [[[[lastValueInMaxTopDown sub:aValueInMinTopDown track:mdl] plus: [lastValueInMaxBottomUp sub:cValueInMinBottomUp track:mdl] track:mdl] geq:lowerMinusEdge track:mdl] land:
                               [[[lastValueInMinTopDown sub:aValueInMaxTopDown track:mdl] plus: [lastValueInMinBottomUp sub:cValueInMaxBottomUp track:mdl] track:mdl] leq:upperMinusEdge track:mdl]                                                                                                                                                                                                               track:mdl] track:mdl];
            } else {
                edgeIsUsed = [edgeIsUsed lor:[[[a geq:zero track:mdl] land: [c geq:zero track:mdl] track:mdl] land:
                                              [[[[lastValueInMaxTopDown sub:aValueInMinTopDown track:mdl] plus: [lastValueInMaxBottomUp sub:cValueInMinBottomUp track:mdl] track:mdl] geq:lowerMinusEdge track:mdl] land:
                                               [[[lastValueInMinTopDown sub:aValueInMaxTopDown track:mdl] plus: [lastValueInMinBottomUp sub:cValueInMaxBottomUp track:mdl] track:mdl] leq:upperMinusEdge track:mdl]                                                                                                                                                                                                               track:mdl] track:mdl] track:mdl];
            }
        }
        
        id<ORExpr> deleteEdgeWhen = [edgeIsUsed negTrack:mdl];
        
        id<ORExpr> addEdgeToArray = [[ORFactory parentInformation:mdl] appendToArray:[[[ORFactory parentInformation:mdl] arrayIndex:[[ORFactory sizeOfArray:[ORFactory parentInformation:mdl] track:mdl] sub:@1 track:mdl] track:mdl] plus:[countedValues1 contains: [ORFactory valueAssignment:mdl]] track:mdl] track:mdl];
        
        [mddStateSpecs setEdgeDeletionCondition: deleteEdgeWhen];
        [mddStateSpecs setTopDownInfoEdgeAdditionMin:addEdgeToArray max:addEdgeToArray];
        [mddStateSpecs setBottomUpInfoEdgeAdditionMin:addEdgeToArray max:addEdgeToArray];
        [mddStateSpecs setInformationMergeToMinAndMaxArrays:mdl];
        
        [mdl add: mddStateSpecs];
        
        /*
         This was a different attempt of how to write deleteEdgeWhen.  Definitely worse than what's above.
         
         id<ORExpr> c_value_plus_a = [ORFactory expr:[ORFactory integer:mdl value:(int)[variables count]] sub:sequenceSize track:mdl];         //Could replace [variables count] with sizeOfTopDownArray + sizeOfBottomUpArray +1, but that seems too verbose --Actually this might not be right.  Need to check this.
         
         id<ORExpr> deleteEdgeWhen = [[ORFactory iterateOverRangeCombineWithOr:[ORFactory expr:zero min:[[sizeOfTopDownArray sub:sequenceSize track:mdl] plus:one track:mdl] track:mdl] to:sizeOfTopDownArray expression:
         [ORFactory ifExpr:[[[c_value_plus_a sub: ITERATOR track:mdl] geq: zero track:mdl] lor:[[c_value_plus_a sub:ITERATOR track:mdl] leq:d track:mdl] track:mdl] then:
         [[[[[ORFactory maxParentInformation] arrayIndex:lastIndexOfTopDownArray track:mdl] sub: [ORFactory minParentInformation] arrayIndex:ITERATOR track:mdl] plus: [[[ORFactory maxChildInformation] arrayIndex:lastIndexOfBottomUpArray track:mdl] sub:[[ORFactory minChildInformation] arrayIndex:[c_value_plus_a sub:ITERATOR track:mdl] track:mdl] track:mdl] geq:[lower1 sub:[countedValues1 contains:[ORFactory valueAssignment:mdl] track:mdl] track:mdl] track:mdl] land:
         [[[[[ORFactory minParentInformation] arrayIndex:lastIndexOfTopDownArray track:mdl] sub: [ORFactory maxParentInformation] arrayIndex:ITERATOR track:mdl] max:zero track:mdl] plus: [[[[ORFactory minChildInformation] arrayIndex:lastIndexOfBottomUpArray track:mdl] sub:[[ORFactory maxChildInformation] arrayIndex:[c_value_plus_a sub:ITERATOR track:mdl] track:mdl] track:mdl] max:zero track:mdl] leq:[upper1 sub:[countedValues1 contains:[ORFactory valueAssignment:mdl] track:mdl] track:mdl] track:mdl]]
         elseReturn:false] track:mdl] negate:mdl];*/
        /*TODO:  So logically, that deleteEdgeWhen "should" work.  It basically iterates over all ranges that use that edge and if it finds one that is able to use this edge, then it cannot delete the edge.  Still have the following stuff to do to make this functional though:
         1. Implement this "iterateOverRangeCombineWithOr" function.
         2. Extension of 1, but figure out how to represent this ITERATOR within iterateOverRangeCombineWithOr visitor functions.  Really not sure how this will work.
         3. Implement arrayIndex: track:. (should be easy)
         4. Implement maxParentInformation, minParentInformation, maxChildInformation, and minChildInformation.  Not clear how this will actually work?  Does the deleteEdge need to be a special one that is able to handle these min and max informations?  Current one just has a single parent and a single child.  Alternatively, make it so that parentInformation is an array of size 2, index 0 is min, index 1 is max (same with childInformation).  Make sure existing parentInformation and childInformation do not break because of this change.
         I think "that's it".  Last two should be fairly doable. The first one should be fine with the exception that I may need to re-evaluate that function depending on how #2 works.  That is my biggest concern right now.  How do we do an iterator within an ORExpr s.t. we can use the iterator value in the visitor AND do an OR expression over the results.  My first consideration was to do the iterating outside of the ORExpr and merely "build" a large ORExpr in main that would be a series of OR statements across all 'sequenceSize' checks.  The problem that keeps this from working is that this iterator itself needs to use a variable value that isn't known yet (changes on each layer of the MDD).  It's possible that there's a way we can specify how to BUILD the deleteEdgeWhen expression s.t. whenever it needs to use deleteEdgeWhen, it first calls deleteEdgeWhenBuilder which builds out this expression as specified, and THEN it can use deleteEdgeWhen.  This may prove to be more costly however and I'm not sure if this will simplify or just further complicate things.
         Oh, I'm also not positive b+d+1 is numVariables after all.  May be off by 1 or 2.  Should double-check this if we end up ever using this method of deleteEdgeWhen
         */
        
        
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
