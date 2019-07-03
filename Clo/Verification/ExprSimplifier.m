//
//  ExprSimplifier.m
//  Verification
//
//  Created by zitoun on 3/13/19.
//

#import "ExprSimplifier.h"


@implementation ExprCounter
+(NSDictionary*)count:(id<ORExpr>)e
{
   NSMutableDictionary* rv = [[NSMutableDictionary alloc] initWithCapacity:4];
   ExprCounter* vc = [[ExprCounter alloc] init:rv];
   [e visit:vc];
   [vc release];
   return rv;
}
-(id)init:(NSMutableDictionary*)theSet
{
   self = [super init];
   _theSet = theSet;
   return self;
}
-(ORInt) count:(id) c
{
   ORInt cpt = 0;
   id v = [_theSet objectForKey:[NSValue valueWithPointer:c]];
   if(v != nil)
      cpt = [v intValue];
   cpt++;
   [_theSet setObject:@(cpt) forKey:[NSValue valueWithPointer:c]];
   return cpt;
}
-(void) visitFloatVar:(id<ORFloatVar>)v
{
}
-(void) visitDoubleVar:(id<ORDoubleVar>)v
{
}
-(void) visitIntVar:(id<ORIntVar>)v
{
}
-(void) visitExprUnaryMinusI:  (ORExprUnaryMinusI *) c
{
   if([self count:c] < 2)
      [[c operand] visit:self];
}
-(void) visitExprMulI: (ORExprBinaryI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprDivI: (ORExprBinaryI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprPlusI: (ORExprBinaryI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprMinusI: (ORExprBinaryI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprAssignI:(ORExprBinaryI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprEqualI: (ORExprBinaryI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprNotEqualI: (ORExprBinaryI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprLEqualI: (ORExprBinaryI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprGEqualI: (ORExprBinaryI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprLThenI: (ORExprLEqualI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprLGthenI: (ORExprBinaryI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprDisjunctI: (ORExprLogiqueI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprConjunctI: (ORExprLogiqueI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprImplyI: (ORExprLogiqueI*) c
{
   if([self count:c] < 2){
      [[c left] visit:self];
      [[c right] visit:self];
   }
}
-(void) visitExprNegateI: (ORExprNegateI*) c
{
   if([self count:c] < 2)
      [[c operand] visit:self];
}
-(void) visitExprSqrtI: (ORExprSqrtI*) c
{
   if([self count:c] < 2)
      [[c operand] visit:self];
}
-(void) visitExprIsZeroI: (ORExprIsZeroI*) c
{
   if([self count:c] < 2)
      [[c operand] visit:self];
}
-(void) visitExprIsPositiveI: (ORExprIsPositiveI*) c
{
   if([self count:c] < 2)
      [[c operand] visit:self];
}
-(void) visitExprIsInfiniteI: (ORExprIsInfiniteI*) c
{
   if([self count:c] < 2)
      [[c operand] visit:self];
}
-(void) visitExprIsNormalI: (ORExprIsNormalI*) c
{
   if([self count:c] < 2)
      [[c operand] visit:self];
}
-(void) visitExprIsSubnormalI: (ORExprIsSubnormalI*) c
{
   if([self count:c] < 2)
      [[c operand] visit:self];
}
-(void) visitExprToFloatI: (ORExprToFloatI*) c
{
   if([self count:c] < 2)
      [[c operand] visit:self];
}
-(void) visitExprToDoubleI: (ORExprToDoubleI*) c
{
   if([self count:c] < 2)
      [[c operand] visit:self];
}
-(void) visitExprAbsI: (ORExprAbsI*) c
{
   if([self count:c] < 2)
      [[c operand] visit:self];
}
@end


@implementation ExprSimplifier
+(id<ORExpr>)simplify:(id<ORExpr>)e used:(NSMutableDictionary*) used matching:(NSMutableDictionary*) alphas
{
   id<ORExpr> rv = e;
   ExprCounter* counter = [[ExprCounter alloc] init:used];
   [e visit:counter];
   [counter release];
   if([used count]){
      ExprSimplifier* simplifier = [[ExprSimplifier alloc] init:used matching:alphas];
      [e visit:simplifier];
      rv = [simplifier result];
      [simplifier release];
   }
   return rv;
}
+(NSArray*)simplifyAll:(NSArray*)es
{
   NSMutableArray* res = [[NSMutableArray alloc] init];
   NSMutableDictionary* used = [[NSMutableDictionary alloc] init];
   ExprCounter* counter = [[ExprCounter alloc] init:used];
   for(id<ORExpr> e in es){
      [e visit:counter];
   }
   [counter release];
   if([used count]){
      ExprSimplifier* simplifier = [[ExprSimplifier alloc] init:used];
      for(id<ORExpr> e in es){
         [e visit:simplifier];
         [res addObject:[simplifier result]];
         simplifier->_rv = nil;
      }
      [simplifier release];
   }
   [used release];
   return res;
}
+(NSArray*)simplifyAll:(NSArray*)es group:(id<ORGroup>)g
{
   NSMutableArray* res = [[NSMutableArray alloc] init];
   NSMutableDictionary* used = [[NSMutableDictionary alloc] init];
   ExprCounter* counter = [[ExprCounter alloc] init:used];
   for(id<ORExpr> e in es){
      [e visit:counter];
   }
   [counter release];
   if([used count]){
      ExprSimplifier* simplifier = [[ExprSimplifier alloc] init:used group:g];
      for(id<ORExpr> e in es){
         [e visit:simplifier];
         [res addObject:[simplifier result]];
         simplifier->_rv = nil;
      }
      [simplifier release];
   }
   [used release];
   return res;
}
-(id) init:(NSMutableDictionary*)theSet
{
   self = [self init:theSet matching:[[NSMutableDictionary alloc] init]];
   return self;
}
-(id) init:(NSMutableDictionary*)theSet group:(id<ORGroup>)g
{
   self = [self init:theSet matching:[[NSMutableDictionary alloc] init]];
   _g = g;
   return self;
}
-(id)init:(NSMutableDictionary*)theSet matching:(NSMutableDictionary *)alpha
{
   self = [super init];
   _theSet = theSet;
   _alphas = alpha;
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(id<ORExpr>) result
{
   return _rv;
}
-(id<ORExpr>)doIt:(id<ORExpr>)e
{
   id<ORExpr> old = _rv;
   _rv = nil;
   [e visit:self];
   id<ORExpr> retVal = _rv;
   _rv = old;
   return retVal;
}
-(id<ORExpr>) createAlphaFrom: (id<ORExpr>) e
{
   id<ORExpr> alpha = nil;
   switch (e.vtype) {
      case ORTBool:
         alpha = [ORFactory boolVar:[e tracker]];
         break;
      case ORTInt:
         alpha = [ORFactory intVar:[e tracker]];
         break;
      case ORTFloat:
         alpha = [ORFactory floatVar:[e tracker]];
         break;
      case ORTDouble:
         alpha = [ORFactory doubleVar:[e tracker]];
         break;
      default:
         break;
   }
   if(alpha != nil){
      if(_g == nil)
         [((id<ORModel>)[e tracker]) add:[alpha eq:e]];
      else
         [_g add:[alpha eq:e]];
   }
   return alpha;
}
-(id<ORExpr>) simplify:(id<ORExpr>) e with:(id<ORExpr>) ne
{
   id res = nil;
   id v = [_theSet objectForKey:[NSValue valueWithPointer:e]];
   if(v == nil || [v intValue] <= 1){
      res = ne;
   }else{
      //get alpha or create a new one
      id alpha = [_alphas objectForKey:[NSValue valueWithPointer:e]];
      if(alpha == nil){
         alpha = [self createAlphaFrom:ne];
         [_alphas setObject:alpha forKey:[NSValue valueWithPointer:e]];
      }
      res = alpha;
   }
   return res;
}
-(void) visitIntegerI: (id<ORInteger>) e
{
   _rv = e;
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{
   _rv = e;
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e
{
   _rv = e;
}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{
   _rv = e;
}
-(void) visitDouble: (id<ORDoubleNumber>) e
{
   _rv = e;
}
-(void) visitFloat: (id<ORFloatNumber>) e
{
   _rv = e;
}
-(void) visitFloatVar: (id<ORFloatVar>) v
{
   _rv = v;
}
-(void) visitIntVar: (id<ORIntVar>) v
{
   _rv = v;
}
-(void) visitDoubleVar: (id<ORDoubleVar>) v
{
   _rv = v;
}
-(void) visitBitVar: (id<ORBitVar>) v
{
   _rv = v;
}
-(void) visitRealVar: (id<ORRealVar>) v
{
   _rv = v;
}
-(void) visitExprUnaryMinusI:  (ORExprUnaryMinusI *) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:c with:[op minus]];
   }else _rv = alpha;
}
-(void) visitExprSqrtI:  (ORExprSqrtI *) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:c with:[op sqrt]];
   }else _rv = alpha;
}
-(void) visitExprIsZeroI: (ORExprIsZeroI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:c with:[op isZero]];
   }else _rv = alpha;
}
-(void) visitExprIsPositiveI: (ORExprIsPositiveI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:c with:[op isPositive]];
   }else _rv = alpha;
}
-(void) visitExprIsInfiniteI: (ORExprIsInfiniteI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:c with:[op isInfinite]];
   }else _rv = alpha;
}
-(void) visitExprIsNormalI: (ORExprIsNormalI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:c with:[op isNormal]];
   }else _rv = alpha;
}
-(void) visitExprIsSubnormalI: (ORExprIsSubnormalI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:c with:[op isSubnormal]];
   }else _rv = alpha;
}
-(void) visitExprToFloatI:  (ORExprToFloatI *) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:c with:[op toFloat]];
   }else _rv = alpha;
}
-(void) visitExprToDoubleI:  (ORExprToDoubleI *) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:c with:[op toDouble]];
   }else _rv = alpha;
}
-(void) visitExprAbsI:  (ORExprAbsI *) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:c with:[op abs]];
   }else _rv = alpha;
}
-(void) visitExprMulI: (ORExprBinaryI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL mul:nR]];
   }else _rv = alpha;
}
-(void) visitExprDivI: (ORExprBinaryI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL div:nR]];
   }else _rv = alpha;
}
-(void) visitExprPlusI: (ORExprBinaryI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL plus:nR]];
   }else _rv = alpha;
}
-(void) visitExprMinusI: (ORExprBinaryI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL sub:nR]];
   }else _rv = alpha;
}
-(void) visitExprAssignI: (ORExprBinaryI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL eq:nR]];
   }else _rv = alpha;
}
-(void) visitExprEqualI: (ORExprBinaryI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      //   [hzi]: I should had a _eq_to in case we have x == expr and expr is already factorized.
//      if([nL isVariable] && ![nR isVariable])
//         [_alphas setObject:nL forKey:[NSValue valueWithPointer:c.right]];
//      else if([nR isVariable] && ![nL isVariable])
//         [_alphas setObject:nR forKey:[NSValue valueWithPointer:c.left]];
      _rv = [self simplify:c with:[nL eq:nR]];
   }else _rv = alpha;
}
-(void) visitExprNotEqualI: (ORExprBinaryI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL neq:nR]];
   }else _rv = alpha;
}
-(void) visitExprLEqualI: (ORExprBinaryI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL leq:nR]];
   }else _rv = alpha;
}
-(void) visitExprGEqualI: (ORExprBinaryI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL geq:nR]];
   }else _rv = alpha;
}
-(void) visitExprLThenI: (ORExprLThenI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL lt:nR]];
   }else _rv = alpha;
}
-(void) visitExprGThenI: (ORExprGThenI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL gt:nR]];
   }else _rv = alpha;
}
-(void) visitExprDisjunctI: (ORExprLogiqueI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL lor:nR]];
   }else _rv = alpha;
}
-(void) visitExprConjunctI: (ORExprLogiqueI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL land:nR]];
   }else _rv = alpha;
}
-(void) visitExprImplyI: (ORExprLogiqueI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      _rv = [self simplify:c with:[nL imply:nR]];
   }else _rv = alpha;
}
-(void) visitExprNegateI: (ORExprNegateI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:c with:[op neg]];
   }else _rv = alpha;
}
@end


@implementation InequalityConstraintsCollector{
   ORInt isNegate;
}
-(InequalityConstraintsCollector*)init
{
   self = [super init];
   _theSet = [[NSMutableDictionary alloc] init];
   _hasInequalities = [[NSMutableDictionary alloc] init];
   isNegate = 0;
   return self;
}
-(void) dealloc
{
   for(NSMutableArray* s in _theSet)
      [s release];
   [_theSet release];
   [_hasInequalities release];
   [super dealloc];
}
-(void) doIt:(id<ORExpr>) e with:(id<ORExpr>) left or:(id<ORExpr>) right  negate:(id<ORExpr>) ne
{
   id<ORExpr> re = (isNegate%2)?ne:e;
   id<ORExpr> key = (isNegate%2)?right:left;
   [self doIt:re with:key];
}

-(void) doIt:(id<ORExpr>) e with:(id<ORExpr>) left
{
   id val = [_theSet objectForKey:@(left.getId)];
   if(val == nil){
      val = [[NSMutableArray alloc] init];
      [val addObject:e];
      [_theSet setObject:val forKey:@(left.getId)];
   }else
      [val addObject:e];
}
//0-none
//1-leq
//2-geq
//3-both
-(void) hasIneq:(id<ORExpr>)x with:(ORRelationType) type
{
   int id_x = [((id<ORVar>)x) getId];
   id v = [_hasInequalities objectForKey:@(id_x)];
   int nv = (type == ORRLEq || isNegate%2)? 1 : 2;
   int lv = nv;
   switch ([v intValue]) {
      case 1: lv = (nv == 1) ? 1 : 3;
         break;
      case 2: lv = (nv == 2) ? 2 : 3;
         break;
      case 3: lv = 3;
      default:
         break;
   }
   [_hasInequalities setObject:@(lv) forKey:@(id_x)];
}
-(void) visitGroup:(id<ORGroup>)g
{
   [g enumerateObjectWithBlock:^(id<ORConstraint> c) {
      [c visit:self];
   }];
}
-(void) visitAlgebraicConstraint:(id<ORAlgebraicConstraint>)cstr
{
   id<ORExpr> e = [cstr expr];
   [e visit:self];
}
-(void) visitExprLThenI:(ORExprBinaryI*)e
{
   id<ORExpr> l = [e left];
   id<ORExpr> r = [e right];
   if([r isVariable])
      [self hasIneq:r with:ORRGEq];
   if([l isVariable])
      [self hasIneq:l with:ORRLEq];
   if([r isVariable] && [l isVariable]){
      [self doIt:e with:l or:r negate:[l geq:r]];
   }
}
-(void) visitExprLEqualI:(ORExprBinaryI*)e
{
   id<ORExpr> l = [e left];
   id<ORExpr> r = [e right];
   if([r isVariable])
      [self hasIneq:r with:ORRGEq];
   if([l isVariable])
      [self hasIneq:l with:ORRLEq];
   if([r isVariable] && [l isVariable]){
      [self doIt:e with:l or:r negate:[l gt:r]];
   }
}
-(void) visitExprGThenI:(ORExprBinaryI*)e
{
   id<ORExpr> l = [e left];
   id<ORExpr> r = [e right];
   if([r isVariable])
      [self hasIneq:r with:ORRLEq];
   if([l isVariable])
      [self hasIneq:l with:ORRGEq];
   if([r isVariable] && [l isVariable]){
      [self doIt:e with:r or:l negate:[l leq:r]];
   }
}
-(void) visitExprGEqualI:(ORExprBinaryI*)e
{
   id<ORExpr> l = [e left];
   id<ORExpr> r = [e right];
   if([r isVariable])
      [self hasIneq:r with:ORRGEq];
   if([l isVariable])
      [self hasIneq:l with:ORRLEq];
   if([r isVariable] && [l isVariable]){
      [self doIt:e with:r or:l negate:[l lt:r]];
   }
}
-(void) visitExprAssignI:(ORExprBinaryI*)e
{
   id<ORExpr> l = [e left];
   id<ORExpr> r = [e right];
   if([r isVariable] && [l isVariable] && !(isNegate%2)){
      [self doIt:e with:l];
      [self doIt:e with:r];
   }else{
      [l visit:self];
      [r visit:self];
   }
}
-(void) visitExprEqualI:(ORExprBinaryI*)e
{
   id<ORExpr> l = [e left];
   id<ORExpr> r = [e right];
   if([r isVariable] && [l isVariable] && !(isNegate%2)){
      [self doIt:e with:l];
      [self doIt:e with:r];
   }else{
      [l visit:self];
      [r visit:self];
   }
}
-(void) visitExprNEqualI:(ORExprBinaryI*)e
{
   id<ORExpr> l = [e left];
   id<ORExpr> r = [e right];
   if([r isVariable] && [l isVariable] && (isNegate%2)){
      [self doIt:e with:l];
      [self doIt:e with:r];
   }else{
      [l visit:self];
      [r visit:self];
   }
}
-(void) visitExprNegateI:(ORExprNegateI*)e
{
   isNegate++;
   [[e operand] visit:self];
   isNegate--;
}
//-(void) visitExprImplyI:(ORExprLogiqueI*)e
//{
//   [[e left] visit:self];
//   [[e right] visit:self];
//}
-(void) visitExprConjunctI: (ORExprLogiqueI*) e
{
   if(!(isNegate%2)){
      [[e left] visit:self];
      [[e right] visit:self];
   }
}
-(void) visitExprDisjunctI: (ORExprLogiqueI*) e
{
   if(isNegate%2){
      [[e left] visit:self];
      [[e right] visit:self];
   }
}
-(void) visitExprIsPositiveI:(ORExprIsPositiveI*)c
{}
-(void) visitExprIsZeroI:(ORExprIsZeroI*)c
{}
-(void) visitExprIsInfiniteI:(ORExprIsInfiniteI*)c
{}
-(void) visitExprIsNormalI:(ORExprIsNormalI*)c
{}
-(void) visitExprIsSubnormalI:(ORExprIsSubnormalI*)c
{}

-(NSDictionary*) result
{
   return [_theSet copy];
}
-(NSDictionary*) hasInequalities
{
   return [_hasInequalities copy];
}
+(NSDictionary*) collect:(NSArray*) constraints
{
   InequalityConstraintsCollector* collector = [[InequalityConstraintsCollector alloc] init];
   for(id<ORConstraint> c in constraints){
      [c visit:collector];
   }
   NSDictionary* r = [collector result];
   [collector release];
   return r;
}
+(NSDictionary*) collectKind:(NSArray*) constraints
{
   InequalityConstraintsCollector* collector = [[InequalityConstraintsCollector alloc] init];
   for(id<ORConstraint> c in constraints){
      [c visit:collector];
   }
   NSDictionary* r = [collector hasInequalities];
   [collector release];
   return r;
}
@end

@implementation VariableLocalOccCollector
{
   NSMutableDictionary* _rv;
}
-(VariableLocalOccCollector*)init
{
   self = [super init];
   _theSet = [[NSMutableDictionary alloc] init];
   _rv = [[NSMutableDictionary alloc] init];
   return self;
}
-(void) dealloc
{
   [_theSet release];
   [_rv release];
   [super dealloc];
}

-(void)doIt:(ORExprBinaryI*)e
{
   [_rv removeAllObjects];
   [[e left] visit:self];
   [[e right] visit:self];
   for(id k in [_rv keyEnumerator]){
      ORInt bd = [_rv[k] intValue];
      if(_theSet[k] != nil)
         bd = max(bd, [_theSet[k] intValue]);
      [_theSet setObject:@(bd) forKey:k];
   }
}
-(void) visitAlgebraicConstraint:(id<ORAlgebraicConstraint>)cstr
{
   id<ORExpr> e = [cstr expr];
   [e visit:self];
}
-(void) visitFloatVar:(id<ORFloatVar>)v
{
   ORInt r = 0;
   if(_rv[@(v.getId)] != nil)
      r = [_rv[@(v.getId)] intValue];
   _rv[@(v.getId)] = @(r + 1);

}
-(void) visitDoubleVar:(id<ORDoubleVar>)v
{
   ORInt r = 0;
   if(_rv[@(v.getId)] != nil)
      r = [_rv[@(v.getId)] intValue];
   _rv[@(v.getId)] = @(r + 1);
}
-(void) visitIntVar:(id<ORIntVar>)v
{
}
-(void) visitExprUnaryMinusI:  (ORExprUnaryMinusI *) c
{
   [[c operand] visit:self];
}
-(void) visitExprMulI: (ORExprBinaryI*) c
{
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprDivI: (ORExprBinaryI*) c
{
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprPlusI: (ORExprBinaryI*) c
{
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprMinusI: (ORExprBinaryI*) c
{
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprAssignI:(ORExprBinaryI*)e
{
   [self doIt:e];
}
-(void) visitExprEqualI:(ORExprBinaryI*)e
{
   [self doIt:e];
}
-(void) visitExprNEqualI:(ORExprBinaryI*)e
{
   [self doIt:e];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
   [self doIt:e];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) e
{
   [self doIt:e];
}
-(void) visitExprLThenI: (ORExprBinaryI*) e
{
   [self doIt:e];
}
-(void) visitExprLGthenI: (ORExprBinaryI*) e
{
   [self doIt:e];
}
-(void) visitExprNegateI:(ORExprNegateI*)e
{
   [[e operand] visit:self];
}
-(void) visitExprImplyI:(ORExprLogiqueI*)e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprConjunctI: (ORExprLogiqueI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprDisjonctI: (ORExprLogiqueI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprSqrtI: (ORExprSqrtI*) c
{
   [[c operand] visit:self];
}
-(void) visitExprIsZeroI: (ORExprIsZeroI*) c
{
   [[c operand] visit:self];
}
-(void) visitExprIsPositiveI: (ORExprIsPositiveI*) c
{
   [[c operand] visit:self];
}
-(void) visitExprIsInfiniteI: (ORExprIsInfiniteI*) c
{
   [[c operand] visit:self];
}
-(void) visitExprIsNormalI: (ORExprIsNormalI*) c
{
   [[c operand] visit:self];
}
-(void) visitExprIsSubnormalI: (ORExprIsSubnormalI*) c
{
   [[c operand] visit:self];
}
-(void) visitExprToFloatI: (ORExprToFloatI*) c
{
   [[c operand] visit:self];
}
-(void) visitExprToDoubleI: (ORExprToDoubleI*) c
{
   [[c operand] visit:self];
}
-(void) visitExprAbsI: (ORExprAbsI*) c
{
   [[c operand] visit:self];
}
-(NSDictionary*) result
{
   return [_theSet copy];
}
+(id<ORIntArray>) collect:(NSArray*) constraints with:(NSArray*) vars tracker:(id<ORTracker>) tracker
{
   VariableLocalOccCollector* collector = [[VariableLocalOccCollector alloc] init];
   for(id<ORConstraint> c in constraints){
      [c visit:collector];
   }
   NSDictionary* r = [collector result];
   ORInt maxId = 0;
   for(id<ORObject> c in vars){
      maxId = ([c getId]>maxId)? [c getId] : maxId;
   }
   id<ORIntArray> _loccurences = [ORFactory intArray:tracker range:RANGE(tracker,0,maxId) value:0];
   id keys = [r keyEnumerator];
   for (id k in keys){
      id v = (0);
      if(r[k] != nil)
         v = r[k];
      _loccurences[[k intValue]] = v;
   }
   [collector release];
   [r release];
   return _loccurences;
}
@end
