#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>


@interface ORExprPlaceHolderI : ORExprI<ORExpr,NSCoding>{
   ORInt index_;
   id<ORTracker> tracker_;
}
-(id<ORExpr>)initORExprPlaceHolderI:(ORInt) index withTracker:(id<ORTracker>) tracker;
-(id<ORExpr>)bind:(NSArray*)args;
-(id<ORTracker>) tracker;
-(NSString*)description;
-(void)visit:(ORVisitor*)v;
@end

@interface  ORVisitorSMT : ORNOopVisit
-(void) visitExprPlaceHolderI:(ORExprPlaceHolderI*)e;
@end

@interface ExprCounter : ORNOopVisit {
   NSMutableDictionary* _theSet;
}
-(id)init:(NSMutableDictionary*)theSet;
+(NSDictionary*)count:(id<ORExpr>)e;
@end

@interface ExprCloneAndSubstitue : ORVisitorSMT
{
id<ORExpr> _rv;
}
-(id)initWithValues:(NSArray*)values;
-(id<ORExpr>) result;
@end


@interface ExprSimplifier : ORNOopVisit {
   NSMutableDictionary* _theSet;
   NSMutableDictionary* _alphas;
   id<ORExpr> _rv;
   id<ORGroup> _g;
}
-(id)init:(NSMutableDictionary*)theSet matching:(NSMutableDictionary*)alpha;
-(id)init:(NSMutableDictionary*)theSet;
-(id)init:(NSMutableDictionary*)theSet group:(id<ORGroup>)g;
-(id<ORExpr>) result;
+(id<ORExpr>)simplify:(id<ORExpr>)e  used:(NSMutableDictionary*) m matching:(NSMutableDictionary*)alpha;
+(NSArray*)simplifyAll:(NSArray*)e;
+(NSArray*)simplifyAll:(NSArray*)e group:(id<ORGroup>) g;
@end

@interface InequalityConstraintsCollector : ORNOopVisit{
   NSMutableDictionary* _theSet;
   NSMutableDictionary* _hasInequalities;
}
-(id)init;
+(NSMutableDictionary*) collect:(NSArray*) constraints;
+(NSDictionary*) collectKind:(NSArray*) constraints;
@end

@interface VariableLocalOccCollector : ORNOopVisit{
   NSMutableDictionary* _theSet;
}
-(id)init;
+(id<ORIntArray>) collect:(NSArray*) constraints with:(NSArray*) vars tracker:(id<ORTracker>) tracker;
@end
