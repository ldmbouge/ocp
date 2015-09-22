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

@protocol ORRealLinear <NSObject,ORLinear>
-(void) setIndependent: (ORDouble) idp;
-(void) addIndependent: (ORDouble) idp;
-(void) addTerm: (id<ORVar>) x by: (ORDouble) c;
-(void) addLinear: (id<ORRealLinear>) lts;
-(void) scaleBy: (ORInt) s;
-(ORInt) size;
-(id<ORVar>) var: (ORInt) k;
-(ORDouble) coef: (ORInt) k;
-(ORDouble) independent;
-(ORDouble) fmin;
-(ORDouble) fmax;
-(BOOL)isZero;
-(BOOL)isOne;
@end

@interface ORRealLinear :  NSObject<ORRealLinear> {
   struct ORDoubleTerm {
      id<ORVar>   _var;
      ORDouble    _coef;
   };
   struct ORDoubleTerm* _terms;
   ORInt             _nb;
   ORInt            _max;
   ORDouble          _indep;
}
-(ORRealLinear*) initORRealLinear: (ORInt) mxs;
-(void) dealloc;
-(void) setIndependent: (ORDouble) idp;
-(void) addIndependent: (ORDouble) idp;
-(void) addTerm: (id<ORVar>) x by: (ORDouble) c;
-(void) addLinear: (ORRealLinear*) lts;
-(void) scaleBy: (ORDouble) s;
-(ORDouble) independent;
-(NSString*) description;
-(ORDouble) fmin;
-(ORDouble) fmax;
-(BOOL)isZero;
-(BOOL)isOne;

-(id<ORVarArray>)  variables:  (id<ORAddToModel>)  model;
-(id<ORDoubleArray>)  coefficients: (id<ORAddToModel>) model;
-(ORInt) size;
-(id<ORConstraint>) postLEQZ: (id<ORAddToModel>) model;
-(id<ORConstraint>) postEQZ: (id<ORAddToModel>) model;
-(id<ORConstraint>) postNEQZ:(id<ORAddToModel>)model;
-(id<ORConstraint>) postDISJ:(id<ORAddToModel>)model;
-(void)  postMinimize: (id<ORAddToModel>) model;
-(void)  postMaximize: (id<ORAddToModel>) model;
@end

@interface ORRealLinearFlip : NSObject<ORRealLinear> {
   id<ORRealLinear> _real;
}
-(id) initORRealLinearFlip: (id<ORRealLinear>) r;
-(void) setIndependent: (ORDouble) idp;
-(void) addIndependent: (ORDouble) idp;
-(void) addTerm: (id<ORVar>) x by: (ORDouble) c;
-(ORDouble) fmin;
-(ORDouble) fmax;
-(BOOL)isZero;
-(BOOL)isOne;
@end

