/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPTypes.h>
#import <CPUKernel/CPConstraintI.h>
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
-(ORInt)min;
-(ORInt)max;
@end

@interface ORIntLinear : NSObject<ORIntLinear> {
   struct CPTerm {
      id<ORIntVar>  _var;
      ORInt        _coef;
   };
   struct CPTerm* _terms;
   ORInt             _nb;
   ORInt            _max;
   ORInt          _indep;
}
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
-(id<ORIntVarArray>)scaledViews:(id<ORAddToModel>)model annotation:(ORCLevel)note;
-(id<ORIntVar>)oneView:(id<ORAddToModel>)model;
-(ORInt)size;
-(ORInt)min;
-(ORInt)max;
-(BOOL)isZero;
-(BOOL)isOne;
@end

@interface ORLinearFlip : NSObject<ORIntLinear> {
   id<ORIntLinear> _real;
}
-(ORLinearFlip*)initORLinearFlip:(id<ORIntLinear>)r;
-(void)setIndependent:(ORInt)idp;
-(void)addIndependent:(ORInt)idp;
-(void)addTerm:(id<ORIntVar>)x by:(ORInt)c;
-(BOOL)isZero;
-(BOOL)isOne;
@end

