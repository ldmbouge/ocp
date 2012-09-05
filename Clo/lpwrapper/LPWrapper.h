#import <Foundation/NSObject.h>
#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>

typedef enum { LPinfeasible, LPoptimal, LPsuboptimal, LPunbounded, LPerror} LPOutcome;
typedef enum { LPgeq, LPleq, LPeq } LPConstraintType;
typedef enum { LPminimize, LPmaximize } LPObjectiveType;

@protocol LPConstraint;
@protocol LPVariable;

typedef ORFloat (^LPInt2Float)(ORInt);
typedef id<LPVariable> (^LPInt2Var)(ORInt);

typedef struct IRange {
   int low;
   int up;
} IRange;

@protocol LPVariable <NSObject>
-(ORInt)    idx;
-(ORFloat)   low;
-(ORFloat)   up;
-(bool)     hasBounds;
-(ORFloat)   value;
-(ORFloat)   reducedCost;
@end

@protocol LPConstraint <NSObject>
-(LPConstraintType)    type;
-(ORInt)               size;
-(id<LPVariable>*)     var;
-(ORInt*)              col;
-(ORFloat*)             coef;
-(ORFloat)              rhs;
-(ORInt)               idx;
-(ORFloat)              dual;
@end

@protocol LPObjective  <NSObject>
-(LPObjectiveType)     type;
-(ORInt)                 size;
-(ORInt*)                col;
-(ORFloat*)             coef;
-(ORFloat)              value;
@end


@protocol LPColumn <NSObject>
-(ORInt)    idx;
-(ORFloat) low;
-(ORFloat) up;
-(ORFloat) objCoef;
-(ORInt) size;
-(ORInt*) cstrIdx;
-(ORFloat*) coef;
@end

@protocol LPLinearTerm <NSObject>
-(ORInt) size;
-(ORFloat) cst;
-(void) add: (ORFloat) cst;
-(void) add: (ORFloat) coef times: (id<LPVariable>) var;
@end

@protocol LPSolverWrapper <NSObject>

-(void) addVariable: (id<LPVariable>) var;
-(void) addConstraint: (id<LPConstraint>) cstr;
-(void) delConstraint: (id<LPConstraint>) cstr;
-(void) delVariable: (id<LPVariable>) var;
-(void) addObjective: (id<LPObjective>) obj;
-(void) addColumn: (id<LPColumn>) col;

-(void) close;
-(LPOutcome) solve;

-(LPOutcome) status;
-(double) value: (id<LPVariable>) var;
-(double) lowerBound: (id<LPVariable>) var;
-(double) upperBound: (id<LPVariable>) var;
-(double) reducedCost: (id<LPVariable>) var;
-(double) dual: (id<LPConstraint>) cstr;
-(double) objectiveValue;

-(void) setBounds: (id<LPVariable>) var low: (ORFloat) low up: (ORFloat) up;
-(void) setUnboundUpperBound: (id<LPVariable>) var;
-(void) setUnboundLowerBound: (id<LPVariable>) var;

-(void) updateLowerBound: (id<LPVariable>) var lb: (ORFloat) lb;
-(void) updateUpperBound: (id<LPVariable>) var ub: (ORFloat) ub;
-(void) removeLastConstraint;
-(void) removeLastVariable;

-(void) setIntParameter: (const char*) name val: (ORInt) val;
-(void) setFloatParameter: (const char*) name val: (ORFloat) val;
-(void) setStringParameter: (const char*) name val: (char*) val;

-(void) print;
-(void) printModelToFile: (char*) fileName;

//-(CotLPAbstractBasis)* getBasis() ;
//-(void) setBasis(CotLPAbstractBasis* basis) ;

@end

