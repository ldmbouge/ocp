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
-(__nonnull id<ORTracker>  __unsafe_unretained)tracker;
@end

void* __nonnull equal(__nonnull id<CPCommonProgram> solver,__nonnull id<ORIntVar> x,ORInt v);
void* __nonnull diff(__nonnull id<CPCommonProgram> solver,__nonnull id<ORIntVar> x,ORInt v);
void* __nonnull firstFail(__nonnull id<CPCommonProgram> solver,__nonnull id<ORIntVarArray> x);
void* __nonnull sequence(__nonnull id<CPCommonProgram> solver,int n,void* __nonnull*__nonnull s);
void* __nonnull alts(__nonnull id<CPCommonProgram> solver,int n,void*__nonnull* __nonnull s);
void* __nonnull whileDo(__nonnull __unsafe_unretained id<CPCommonProgram> solver,
                        bool(^__nonnull cond)(),
                        void* __nonnull (^__nonnull body)());

void* __nonnull forallDo(__nonnull __unsafe_unretained id<CPCommonProgram> solver,
                         __nonnull __unsafe_unretained id<ORIntRange> R,
                         void* __nonnull(^__nonnull body)(NSInteger)
                         );
void* __nonnull Do(__nonnull __unsafe_unretained id<CPCommonProgram> solver,void(^__nonnull body)());
void* __nonnull limitSolutionsDo(__nonnull __unsafe_unretained id<CPCommonProgram> solver,
                                 ORInt k,
                                 void* __nonnull(^__nonnull body)());



#endif

