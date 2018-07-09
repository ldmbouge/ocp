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
-(void)setIndependent:(ORRational)idp;
-(void)addIndependent:(ORRational)idp;
-(void)addTerm:(id<ORRationalVar>)x by:(ORRational)c;
-(void)addLinear:(id<ORRationalLinear>)lts;
-(void)scaleBy:(ORRational)s;
-(ORRational)size;
-(id<ORRationalVar>)var:(ORRational)k;
-(ORRational)coef:(ORRational)k;
-(ORRational)independent;
-(BOOL)isZero;
-(BOOL)isOne;
-(BOOL)clausalForm;
-(ORRational)min;
-(ORRational)max;
@end

@interface ORRationalLinear : NSObject<ORRationalLinear>
-(ORRationalLinear*)initORLinear:(ORRational)mxs;
-(void)dealloc;
-(void)setIndependent:(ORRational)idp;
-(void)addIndependent:(ORRational)idp;
-(void)addTerm:(id<ORRationalVar>)x by:(ORRational)c;
-(void)addLinear:(ORRationalLinear*)lts;
-(void)scaleBy:(ORRational)s;
-(ORRational)independent;
-(NSString*)description;

-(id<ORRationalVarArray>) variables: (id<ORAddToModel>) model;
-(id<ORRationalArray>) coefficients: (id<ORAddToModel>) model;
-(id<ORRationalVarArray>)scaledViews:(id<ORAddToModel>)model;
-(id<ORRationalVar>)oneView:(id<ORAddToModel>)model;
-(ORRational)size;
-(ORRational)min;
-(ORRational)max;
-(BOOL)isZero;
-(BOOL)isOne;
-(BOOL)clausalForm;
@end

@interface ORLinearFlip : NSObject<ORRationalLinear>
-(ORLinearFlip*)initORLinearFlip:(id<ORRationalLinear>)r;
-(void)setIndependent:(ORRational)idp;
-(void)addIndependent:(ORRational)idp;
-(void)addTerm:(id<ORRationalVar>)x by:(ORRational)c;
-(BOOL)isZero;
-(BOOL)isOne;
@end
