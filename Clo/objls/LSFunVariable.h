/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSVar.h>
#import <objls/LSFactory.h>
#import <objls/LSConstraint.h>

@interface LSFunVariable : ORObject<LSFunction>
-(LSFunVariable*)init:(id<LSEngine>)engine with:(id<LSIntVar>)var;
-(void)post;
-(id<LSIntVar>)evaluation;
-(id<LSGradient>)increase:(id<LSIntVar>)x;
-(id<LSGradient>)decrease:(id<LSIntVar>)x;
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
-(id<LSIntVarArray>)variables;
@end

@interface LSFunOr : ORObject<LSFunction>
-(LSFunOr*)init:(id<LSEngine>)engine withTerms:(id<ORIdArray>)terms;
-(void)post;
-(id<LSIntVar>)evaluation;
-(id<LSGradient>)increase:(id<LSIntVar>)x;
-(id<LSGradient>)decrease:(id<LSIntVar>)x;
-(ORInt)deltaWhenAssign:(id<LSIntVar>)x to:(ORInt)v;
-(ORInt)deltaWhenSwap:(id<LSIntVar>)x with:(id<LSIntVar>)y;
-(id<LSIntVarArray>)variables;
@end