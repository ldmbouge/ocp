/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORLinear.h>

@protocol ORIntLinear<NSObject,ORLinear>
-(void)setIndependent:(ORInt)idp;
-(void)addIndependent:(ORInt)idp;
-(void)addTerm:(id<ORIntVar>)x by:(ORInt)c;
-(void)addLinear:(id<ORIntLinear>)lts;
-(void)scaleBy:(ORInt)s;
-(ORInt)size;
-(id<ORIntVar>)var:(ORInt)k;
-(ORInt)coef:(ORInt)k;
-(ORInt)independent;
-(BOOL)isZero;
-(BOOL)isOne;
-(BOOL)clausalForm;
-(ORInt)min;
-(ORInt)max;
@end

@interface ORIntLinear : NSObject<ORIntLinear> 
-(ORIntLinear*)initORLinear:(ORInt)mxs;
-(void)dealloc;
-(void)setIndependent:(ORInt)idp;
-(void)addIndependent:(ORInt)idp;
-(void)addTerm:(id<ORIntVar>)x by:(ORInt)c;
-(void)addLinear:(ORIntLinear*)lts;
-(void)scaleBy:(ORInt)s;
-(ORInt)independent;
-(NSString*)description;

-(id<ORIntVarArray>) variables: (id<ORAddToModel>) model;
-(id<ORIntArray>) coefficients: (id<ORAddToModel>) model;
-(id<ORIntVarArray>)scaledViews:(id<ORAddToModel>)model;
-(id<ORIntVar>)oneView:(id<ORAddToModel>)model;
-(ORInt)size;
-(ORInt)min;
-(ORInt)max;
-(BOOL)isZero;
-(BOOL)isOne;
-(BOOL)clausalForm;
@end

@interface ORLinearFlip : NSObject<ORIntLinear> 
-(ORLinearFlip*)initORLinearFlip:(id<ORIntLinear>)r;
-(void)setIndependent:(ORInt)idp;
-(void)addIndependent:(ORInt)idp;
-(void)addTerm:(id<ORIntVar>)x by:(ORInt)c;
-(BOOL)isZero;
-(BOOL)isOne;
@end
