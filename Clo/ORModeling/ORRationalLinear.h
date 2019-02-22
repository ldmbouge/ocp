//
//  ORRationalLinear.h
//  Clo
//
//  Created by Rémy Garcia on 09/07/2018.
//

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

@protocol ORRationalLinear<NSObject,ORLinear>
-(void)setIndependent:(id<ORRational>)idp;
-(void)addIndependent:(id<ORRational>)idp;
-(void)addTerm:(id<ORRationalVar>)x by:(ORInt)c;
-(void)addLinear:(id<ORRationalLinear>)lts;
-(void)scaleBy:(ORInt)s;
-(ORInt)size;
-(id<ORRationalVar>)var:(ORInt)k;
-(ORInt)coef:(ORInt)k;
-(id<ORRational>)independent;
-(BOOL)isZero;
-(BOOL)isOne;
-(BOOL)clausalForm;
-(id<ORRational>)qmin;
-(id<ORRational>)qmax;
@end

@interface ORRationalLinear : NSObject<ORRationalLinear>
-(ORRationalLinear*)initORRationalLinear:(ORInt)mxs;
-(void)dealloc;
-(void)setIndependent:(id<ORRational>)idp;
-(void)addIndependent:(id<ORRational>)idp;
-(void)addTerm:(id<ORRationalVar>)x by:(ORInt)c;
-(void)addLinear:(ORRationalLinear*)lts;
-(void)scaleBy:(ORInt)s;
-(id<ORRational>)independent;
-(NSString*)description;

-(id<ORRationalVarArray>) variables: (id<ORAddToModel>) model;
-(id<ORRationalArray>) coefficients: (id<ORAddToModel>) model;
//-(id<ORRationalVarArray>)scaledViews:(id<ORAddToModel>)model;
//-(id<ORRationalVar>)oneView:(id<ORAddToModel>)model;
-(ORInt)size;
-(id<ORRational>)qmin;
-(id<ORRational>)qmax;
-(BOOL)isZero;
-(BOOL)isOne;
-(BOOL)clausalForm;
@end

@interface ORRationalLinearFlip : NSObject<ORRationalLinear>
-(ORRationalLinearFlip*)initORRationalLinearFlip:(id<ORRationalLinear>)r;
-(void)setIndependent:(id<ORRational>)idp;
-(void)addIndependent:(id<ORRational>)idp;
-(void)addTerm:(id<ORRationalVar>)x by:(ORInt)c;
-(BOOL)isZero;
-(BOOL)isOne;
@end
