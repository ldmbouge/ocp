#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>


@interface ExprCounter : ORVisitor {
   NSMutableDictionary* _theSet;
}
-(id)init:(NSMutableDictionary*)theSet;
+(NSDictionary*)count:(id<ORExpr>)e;
@end


@interface ExprSimplifier : ORVisitor {
   NSMutableDictionary* _theSet;
   NSMutableDictionary* _alphas;
   id<ORExpr> _rv;
}
-(id)init:(NSMutableDictionary*)theSet matching:(NSMutableDictionary*)alpha;
-(id<ORExpr>) result;
+(id<ORExpr>)simplify:(id<ORExpr>)e  used:(NSMutableDictionary*) m matching:(NSMutableDictionary*)alpha;
+(NSArray*)simplifyAll:(NSArray*)e;
@end
