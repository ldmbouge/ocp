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

@interface CPRationalEqual : CPCoreConstraint {
   CPRationalVarI* _x;
   CPRationalVarI* _y;
}
-(id) init:(id)x equals:(id)y;
-(void) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@interface CPRationalEqualc : CPCoreConstraint {
   CPRationalVarI* _x;
   ORRational*      _c;
}
-(id) init:(id)x and:(ORRational*)c;
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
