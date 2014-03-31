/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>

@class LSPropagator;
@class LSIntVar;
@protocol LSVar;
@protocol LSIntVar;
@protocol LSConstraint;

@protocol LSEngine <NSObject,ORSearchEngine>
-(void)add:(LSPropagator*)i;
-(id<LSConstraint>)addConstraint:(id<LSConstraint>)cstr;
-(void)label:(id<LSIntVar>)x with:(ORInt)v;
-(void)notify:(id<LSVar>)x;
-(void)atomic:(ORClosure)block;
@end
