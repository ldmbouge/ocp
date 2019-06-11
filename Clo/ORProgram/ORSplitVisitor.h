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

@interface CPVisitorI : ORVisitor<CPVisitor>
@end

@interface ORSplitVisitor : CPVisitorI<CPVisitor>
-(ORSplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v;
@end

@interface OR3WaySplitVisitor : CPVisitorI<CPVisitor>
-(OR3WaySplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v;
@end

@interface OR5WaySplitVisitor : CPVisitorI<CPVisitor>
-(OR5WaySplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v;
@end

@interface OR6WaySplitVisitor : CPVisitorI<CPVisitor>
-(OR6WaySplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v;
@end

@interface ORDeltaSplitVisitor : CPVisitorI<CPVisitor>
-(ORDeltaSplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v nb:(ORInt) n;
@end

@interface OREnumSplitVisitor : CPVisitorI<CPVisitor>
-(OREnumSplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v nb:(ORInt) n;
@end

@interface ORAbsSplitVisitor : CPVisitorI<CPVisitor>
-(ORAbsSplitVisitor*) initWithProgram:(CPCoreSolver*) p variable:(id<ORVar>) v other:(id<ORVar>)o;
@end

@interface ORAbsVisitor : CPVisitorI<CPVisitor>
-(ORAbsVisitor*) init:(id<CPVar>) v;
-(ORDouble) rate;
@end

@interface CPDensityVisitor : CPVisitorI<CPVisitor>
-(ORLDouble) result;
@end

@interface CPCardinalityVisitor : CPVisitorI<CPVisitor>
-(ORDouble) result;
@end
