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

@protocol ORDoubleLinear <NSObject,ORLinear>
-(void) setIndependent: (ORDouble) idp;
-(void) addIndependent: (ORDouble) idp;
-(void) addTerm: (id<ORVar>) x by: (ORDouble) c;
-(void) addLinear: (id<ORDoubleLinear>) lts;
-(void) scaleBy: (ORDouble) s;
-(ORInt) size;
-(id<ORVar>) var: (ORInt) k;
-(ORDouble) coef: (ORInt) k;
-(ORDouble) independent;
-(ORDouble) dmin;
-(ORDouble) dmax;
-(BOOL) isZero;
@end

@interface ORDoubleLinear :  NSObject<ORDoubleLinear> {
    struct ORDoubleTerm {
        id<ORVar>   _var;
        ORDouble    _coef;
    };
    struct ORDoubleTerm* _terms;
    ORInt             _nb;
    ORInt            _max;
    ORDouble          _indep;
    ORRelationType _type;
}
-(ORDoubleLinear*) initORDoubleLinear: (ORInt) mxs;
-(ORDoubleLinear*) initORDoubleLinear: (ORInt) mxs type:(ORRelationType) t;
-(void) dealloc;
-(void) setIndependent: (ORDouble) idp;
-(void) addIndependent: (ORDouble) idp;
-(void) addTerm: (id<ORVar>) x by: (ORDouble) c;
-(void) addLinear: (ORDoubleLinear*) lts;
-(void) scaleBy: (ORDouble) s;
-(BOOL) isZero;
-(ORDouble) independent;
-(NSString*) description;
-(ORDouble) dmin;
-(ORDouble) dmax;
-(id<ORVarArray>)  variables:  (id<ORAddToModel>)  model;
-(id<ORDoubleArray>)  coefficients: (id<ORAddToModel>) model;
-(ORInt) size;
-(id<ORConstraint>) postLEQZ: (id<ORAddToModel>) model;
-(id<ORConstraint>) postGEQZ: (id<ORAddToModel>) model;
-(id<ORConstraint>) postLTZ: (id<ORAddToModel>) model;
-(id<ORConstraint>) postGTZ: (id<ORAddToModel>) model;
-(id<ORConstraint>) postEQZ: (id<ORAddToModel>) model;
-(id<ORConstraint>) postNEQZ:(id<ORAddToModel>)model;
-(id<ORConstraint>) postDISJ:(id<ORAddToModel>)model;
-(void)  postMinimize: (id<ORAddToModel>) model;
-(void)  postMaximize: (id<ORAddToModel>) model;
-(void) visit:(id<ORDoubleLinear>) right;
@end

@interface ORDoubleLinearFlip : NSObject<ORDoubleLinear> {
    id<ORDoubleLinear> _double;
}
-(id) initORDoubleLinearFlip: (id<ORDoubleLinear>) r;
-(void) setIndependent: (ORDouble) idp;
-(void) addIndependent: (ORDouble) idp;
-(void) addTerm: (id<ORVar>) x by: (ORDouble) c;
-(BOOL) isZero;
-(ORDouble) dmin;
-(ORDouble) dmax;
@end

