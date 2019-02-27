/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import "CPProgram.h"

@class CPCoreSolver;

@protocol ORSplitVisitor
-(void) applyIntSplit :(id<CPVar>) var;
-(void) applyFloatSplit :(id<CPVar>) var;
-(void) applyDoubleSplit :(id<CPVar>) var;
@end

@protocol ORAbsVisitor
-(void) applyIntAbs:(id<CPVar>) var;
-(void) applyFloatAbs:(id<CPVar>) var;
-(void) applyDoubleAbs:(id<CPVar>) var;
-(ORDouble) rate;
@end

@interface ORSplitVisitor : ORObject<ORSplitVisitor>
-(ORSplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v;
@end

@interface OR3WaySplitVisitor : ORObject<ORSplitVisitor>
-(OR3WaySplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v;
@end

@interface OR5WaySplitVisitor : ORObject<ORSplitVisitor>
-(OR5WaySplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v;
@end

@interface OR6WaySplitVisitor : ORObject<ORSplitVisitor>
-(OR6WaySplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v;
@end

@interface ORDeltaSplitVisitor : ORObject<ORSplitVisitor>
-(ORDeltaSplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v nb:(ORInt) n;
@end

@interface OREnumSplitVisitor : ORObject<ORSplitVisitor>
-(OREnumSplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v nb:(ORInt) n;
@end

@interface ORAbsSplitVisitor : ORObject<ORSplitVisitor>
-(ORAbsSplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v other:(id<CPVar>)o;
@end

@interface ORAbsVisitor : ORObject<ORAbsVisitor>
-(ORAbsVisitor*) init:(id<CPVar>) v;
@end

