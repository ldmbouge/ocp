#import <Foundation/Foundation.h>
#import <ORFoundation/ORVisit.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORFoundation/ORVisit.h>

@interface ORDDExpressionEquivalenceChecker : ORNOopVisit {
@protected
    NSString* _firstString;
    NSArray* _firstGetStates;
    NSString* _secondString;
    NSArray* _secondGetStates;
    NSMutableString* _currentString;
    NSMutableArray* _currentGetStates;
}
-(ORDDExpressionEquivalenceChecker*) initORDDExpressionEquivalenceChecker;
-(NSMutableArray*) checkEquivalence:(id<ORExpr>)first and:(id<ORExpr>)second;
@end

@interface ORDDUpdateSpecs : ORNOopVisit {
@protected
    NSDictionary* _mapping;
}
-(ORDDUpdateSpecs*) initORDDUpdateSpecs:(NSDictionary*)mapping;
-(void) updateSpecs:(id<ORExpr>)e;
@end

@interface ORDDClosureGenerator : ORNOopVisit {
@protected
    DDClosure current;
}
-(ORDDClosureGenerator*) initORDDClosureGenerator;
-(DDClosure) computeClosure:(id<ORExpr>)e;
-(DDClosure) recursiveVisitor:(id<ORExpr>)e;
@end

@interface ORDDMergeClosureGenerator : ORNOopVisit {
@protected
    DDMergeClosure current;
}
-(ORDDMergeClosureGenerator*) initORDDMergeClosureGenerator;
-(DDMergeClosure) computeClosure:(id<ORExpr>)e;
-(DDMergeClosure) recursiveVisitor:(id<ORExpr>)e;
@end

@interface ORAltMDDParentChildEdgeClosureGenerator : ORNOopVisit {
@protected
    AltMDDDeleteEdgeCheckClosure current;
}
-(ORAltMDDParentChildEdgeClosureGenerator*) initORAltMDDParentChildEdgeClosureGenerator;
-(AltMDDDeleteEdgeCheckClosure) computeClosure:(id<ORExpr>)e;
-(AltMDDDeleteEdgeCheckClosure) recursiveVisitor:(id<ORExpr>)e;
@end
@interface ORAltMDDLeftRightClosureGenerator : ORNOopVisit {
@protected
    AltMDDMergeInfoClosure current;
}
-(ORAltMDDLeftRightClosureGenerator*) initORAltMDDLeftRightClosureGenerator;
-(AltMDDMergeInfoClosure) computeClosure:(id<ORExpr>)e;
-(AltMDDMergeInfoClosure) recursiveVisitor:(id<ORExpr>)e;
@end
@interface ORAltMDDParentEdgeClosureGenerator : ORNOopVisit {
@protected
    AltMDDAddEdgeClosure current;
}
-(ORAltMDDParentEdgeClosureGenerator*) initORAltMDDParentEdgeClosureGenerator;
-(AltMDDAddEdgeClosure) computeClosure:(id<ORExpr>)e;
-(AltMDDAddEdgeClosure) recursiveVisitor:(id<ORExpr>)e;
@end