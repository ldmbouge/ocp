#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>


@interface ExprCounter : ORNOopVisit {
   NSMutableDictionary* _theSet;
}
-(id)init:(NSMutableDictionary*)theSet;
+(NSDictionary*)count:(id<ORExpr>)e;
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

@interface VariableCollector : ORNOopVisit{
   NSMutableSet* _theSet;
}
-(id)init;
+(NSMutableSet*) collect:(NSArray*) constraints;
@end
