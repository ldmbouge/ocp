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
typedef id<CPIntVar>(^CPRewriter)(id<CPExpr>);

@protocol CPLinear<NSObject>
-(void)setIndependent:(CPInt)idp;
-(void)addIndependent:(CPInt)idp;
-(void)addTerm:(id<CPIntVar>)x by:(CPInt)c;
@end

@interface CPLinear : NSObject<CPLinear> {
   struct CPTerm {
      id<CPIntVar>  _var;
      CPInt        _coef;
   };
   struct CPTerm* _terms;
   CPInt             _nb;
   CPInt            _max;
   CPInt          _indep;
}
-(CPLinear*)initCPLinear:(CPInt)mxs;
-(void)dealloc;
-(void)setIndependent:(CPInt)idp;
-(void)addIndependent:(CPInt)idp;
-(void)addTerm:(id<CPIntVar>)x by:(CPInt)c;
-(CPInt)independent;
-(NSString*)description;
-(id<CPIntVarArray>)scaledViews;
-(id<CPIntVar>)oneView;
-(CPInt)size;
-(CPInt)min;
-(CPInt)max;
-(ORStatus)postEQZ:(id<CPSolver>)fdm consistency:(CPConsistency)cons;
-(ORStatus)postLEQZ:(id<CPSolver>)fdm consistency:(CPConsistency)cons;
@end

@interface CPExprConstraintI : CPActiveConstraint<NSCoding> {
   CPSolverI*      _fdm;
   id<CPRelation> _expr;
   CPConsistency     _c;
}
-(id) initCPExprConstraintI:(id<CPSolver>)fdm expr:(id<CPRelation>)x  consistency: (CPConsistency) c;
-(void) dealloc;
-(ORStatus)post;
-(NSSet*)allVars;
-(CPUInt)nbUVars;
@end