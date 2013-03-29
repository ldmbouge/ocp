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

@protocol ORFloatLinear <NSObject>
-(void) setIndependent: (ORFloat) idp;
-(void) addIndependent: (ORFloat) idp;
-(void) addTerm: (id<ORVar>) x by: (ORFloat) c;
-(void) addLinear: (id<ORFloatLinear>) lts;
-(void) scaleBy: (ORInt) s;
-(ORInt) size;
-(id<ORVar>) var: (ORInt) k;
-(ORFloat) coef: (ORInt) k;
-(ORFloat) independent;
@end

@interface ORFloatLinear :  NSObject<ORFloatLinear> {
   struct CPFloatTerm {
      id<ORVar>  _var;
      ORFloat    _coef;
   };
   struct CPFloatTerm* _terms;
   ORInt             _nb;
   ORInt            _max;
   ORFloat          _indep;
}
-(ORFloatLinear*) initORFloatLinear: (ORInt) mxs;
-(void) dealloc;
-(void) setIndependent: (ORFloat) idp;
-(void) addIndependent: (ORFloat) idp;
-(void) addTerm: (id<ORVar>) x by: (ORFloat) c;
-(void) addLinear: (ORFloatLinear*) lts;
-(void) scaleBy: (ORFloat) s;
-(ORFloat) independent;
-(NSString*) description;

-(id<ORVarArray>)  variables:  (id<ORAddToModel>)  model;
-(id<ORFloatArray>)  coefficients: (id<ORAddToModel>) model;
-(ORInt) size;
-(id<ORConstraint>)  postLinearLeq: (id<ORAddToModel>) model annotation: (ORAnnotation) cons;
-(id<ORConstraint>)  postLinearEq: (id<ORAddToModel>) model annotation: (ORAnnotation) cons;
-(void)  postMinimize: (id<ORAddToModel>) model annotation: (ORAnnotation) cons;
-(void)  postMaximize: (id<ORAddToModel>) model annotation: (ORAnnotation) cons;
@end

@interface ORFloatLinearFlip : NSObject<ORFloatLinear> {
   id<ORFloatLinear> _real;
}
-(ORFloatLinearFlip*) initORFloatLinearFlip: (id<ORFloatLinear>) r;
-(void) setIndependent: (ORFloat) idp;
-(void) addIndependent: (ORFloat) idp;
-(void) addTerm: (id<ORVar>) x by: (ORFloat) c;
@end

