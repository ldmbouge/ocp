/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#ifndef Clo_ORSTask_h
#define Clo_ORSTask_h

#import <Foundation/Foundation.h>
@protocol CPCommonProgram;

@protocol ORSTask<NSObject>
-(void)execute;
-(PNONNULL id<ORTracker>  __unsafe_unretained)tracker;
@end

void* PNONNULL equal(PNONNULL id<CPCommonProgram> solver,PNONNULL id<ORIntVar> x,ORInt v);
void* PNONNULL diff(PNONNULL id<CPCommonProgram> solver,PNONNULL id<ORIntVar> x,ORInt v);
void* PNONNULL firstFail(PNONNULL id<CPCommonProgram> solver,PNONNULL id<ORIntVarArray> x);
void* PNONNULL labelArray(PNONNULL id<CPCommonProgram> solver,PNONNULL id<ORIntVarArray> x);
void* PNONNULL firstFailMDD(PNONNULL id<CPCommonProgram> solver,PNONNULL id<ORIntVarArray> x);
void* PNONNULL labelArrayMDD(PNONNULL id<CPCommonProgram> solver,PNONNULL id<ORIntVarArray> x);
void* PNONNULL sequence(PNONNULL id<CPCommonProgram> solver,int n,void* PNONNULL*PNONNULL s);
void* PNONNULL alts(PNONNULL id<CPCommonProgram> solver,int n,void*PNONNULL* PNONNULL s);
void* PNONNULL whileDo(PNONNULL __unsafe_unretained id<CPCommonProgram> solver,
                        bool(^PNONNULL cond)(void),
                        void* PNONNULL (^PNONNULL body)(void));

void* PNONNULL forallDo(PNONNULL __unsafe_unretained id<CPCommonProgram> solver,
                         PNONNULL __unsafe_unretained id<ORIntRange> R,
                         void* PNONNULL(^PNONNULL body)(NSInteger)
                         );
void* PNONNULL Do(PNONNULL __unsafe_unretained id<CPCommonProgram> solver,void(^PNONNULL body)(void));
void* PNONNULL limitSolutionsDo(PNONNULL __unsafe_unretained id<CPCommonProgram> solver,
                                 ORInt k,
                                 void* PNONNULL(^PNONNULL body)(void));



#endif

