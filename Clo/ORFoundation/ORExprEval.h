//
//  ORExprEval.h
//  Clo
//
//  Created by Daniel Fontaine on 9/18/13.
//
//

#import <Foundation/Foundation.h>
#import "ORVisit.h"
#import "ORConstraint.h"

@interface ORIntExprEval : ORNOopVisit<NSObject>
-(id) initORIntExprEval: (id<ORASolver>)solver;
-(ORInt) intValue: (id<ORExpr>)e;
@end

@interface ORFloatExprEval : ORNOopVisit<NSObject>
-(id) initORFloatExprEval: (id<ORASolver>)solver;
-(ORFloat) floatValue: (id<ORExpr>)e;
@end