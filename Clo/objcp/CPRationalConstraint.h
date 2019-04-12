//
//  CPRationalConstraint.h
//  Clo
//
//  Created by Rémy Garcia on 09/07/2018.
//

#import <Foundation/Foundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPVar.h>
#import <objcp/CPRationalDom.h>


@class CPRationalVarI;
@class CPFloatVarI;

@interface CPRationalEqual : CPCoreConstraint {
   CPRationalVarI* _x;
   CPRationalVarI* _y;
}
-(id) init:(id)x equals:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalErrorOf : CPCoreConstraint {
   CPFloatVarI* _x;
   CPRationalVarI* _y;
}
-(id) init:(id)x is:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalChannel : CPCoreConstraint {
   CPFloatVarI* _x;
   CPRationalVarI* _y;
}
-(id) init:(id)x with:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalEqualc : CPCoreConstraint {
   CPRationalVarI* _x;
   id<ORRational>      _c;
}
-(id) init:(id)x and:(id<ORRational>)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalNEqual : CPCoreConstraint {
   CPRationalVarI* _x;
   CPRationalVarI* _y;
}
-(id) init:(id)x nequals:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalNEqualc : CPCoreConstraint {
   CPRationalVarI* _x;
   id<ORRational>      _c;
}
-(id) init:(id)x and:(id)c;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalLT : CPCoreConstraint {
   CPRationalVarI* _x;
   CPRationalVarI* _y;
}
-(id) init:(id)x lt:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalGT : CPCoreConstraint {
   CPRationalVarI* _x;
   CPRationalVarI* _y;
}
-(id) init:(id)x gt:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalLEQ : CPCoreConstraint {
   CPRationalVarI* _x;
   CPRationalVarI* _y;
}
-(id) init:(id)x leq:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalGEQ : CPCoreConstraint {
   CPRationalVarI* _x;
   CPRationalVarI* _y;
}
-(id) init:(id)x geq:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalTernaryAdd : CPCoreConstraint { // z = x + y
   CPRationalVarI* _z;
   CPRationalVarI* _x;
   CPRationalVarI* _y;
}
-(id) init:(id)z equals:(id)x plus:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalTernarySub : CPCoreConstraint { // z = x + y
   CPRationalVarI* _z;
   CPRationalVarI* _x;
   CPRationalVarI* _y;
}
-(id) init:(id)z equals:(id)x minus:(id)y ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalVarMinimize : CPCoreConstraint<ORSearchObjectiveFunction>
-(id) init: (id<CPRationalVar>) x;
-(void) post;
-(ORStatus) check;
-(ORBool) isBound;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
-(id<ORRationalVar>) var;
@end

@interface CPRationalVarMaximize : CPCoreConstraint<ORSearchObjectiveFunction>
-(id) init: (id<CPRationalVar>) x;
-(void) post;
-(ORStatus) check;
-(ORBool) isBound;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
-(id<ORRationalVar>) var;
@end

@interface CPRationalAbs : CPCoreConstraint {
@private
   CPRationalVarI* _x;
   CPRationalVarI* _res;
}
-(id) init:(id<CPRationalVar>)res eq:(id<CPRationalVar>)x ;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end
