/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPTypes.h>
#import <objcp/CPData.h>
#import <objcp/CPConstraintI.h>

@protocol CPIntVar;
@protocol CPIntVarArray;
typedef id<ORIntVar>(^CPRewriter)(id<ORExpr>);

@protocol CPLinear<NSObject>
-(void)setIndependent:(ORInt)idp;
-(void)addIndependent:(ORInt)idp;
-(void)addTerm:(id<ORIntVar>)x by:(ORInt)c;
@end

@interface CPLinear : NSObject<CPLinear> {
   struct CPTerm {
      id<ORIntVar>  _var;
      ORInt        _coef;
   };
   struct CPTerm* _terms;
   ORInt             _nb;
   ORInt            _max;
   ORInt          _indep;
}
-(CPLinear*)initCPLinear:(ORInt)mxs;
-(void)dealloc;
-(void)setIndependent:(ORInt)idp;
-(void)addIndependent:(ORInt)idp;
-(void)addTerm:(id<ORIntVar>)x by:(ORInt)c;
-(ORInt)independent;
-(NSString*)description;
-(id<ORIntVarArray>)scaledViews;
-(id<ORIntVar>)oneView;
-(ORInt)size;
-(ORInt)min;
-(ORInt)max;
-(ORStatus)postEQZ:(id<CPEngine>)fdm consistency:(CPConsistency)cons;
-(ORStatus)postLEQZ:(id<CPEngine>)fdm consistency:(CPConsistency)cons;
@end

@interface CPExprConstraintI : CPActiveConstraint<NSCoding> {
   CPEngineI*      _fdm;
   id<ORRelation> _expr;
   CPConsistency     _c;
}
-(id) initCPExprConstraintI:(id<CPEngine>)fdm expr:(id<CPRelation>)x  consistency: (CPConsistency) c;
-(void) dealloc;
-(ORStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end