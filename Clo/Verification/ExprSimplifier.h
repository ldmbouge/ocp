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
}
-(id)init:(NSMutableDictionary*)theSet;
-(id<ORExpr>) result;
+(id<ORExpr>)simplify:(id<ORExpr>)e;
@end
