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
-(void) count:(id) c
{
   ORInt cpt = 0;
   id v = [_theSet objectForKey:[NSValue valueWithPointer:c]];
   if(v != nil)
      cpt = [v intValue];
   cpt++;
   [_theSet setObject:@(cpt) forKey:[NSValue valueWithPointer:c]];
}
-(void) visitExprUnaryMinusI:  (ORExprUnaryMinusI *) c
{
   [self count:c];
   [[c operand] visit:self];
}
-(void) visitExprMulI: (ORExprBinaryI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprDivI: (ORExprBinaryI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprPlusI: (ORExprBinaryI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprMinusI: (ORExprBinaryI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprEqualI: (ORExprBinaryI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprNotEqualI: (ORExprBinaryI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprGEqualI: (ORExprBinaryI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprLThenI: (ORExprLEqualI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprLGthenI: (ORExprBinaryI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprDisjunctI: (ORExprLogiqueI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprConjunctI: (ORExprLogiqueI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprImplyI: (ORExprLogiqueI*) c
{
   [self count:c];
   [[c left] visit:self];
   [[c right] visit:self];
}
-(void) visitExprNegateI: (ORExprNegateI*) c
{
   [self count:c];
   [[c operand] visit:self];
}
-(void) visitExprSqrtI: (ORExprSqrtI*) c
{
   [self count:c];
   [[c operand] visit:self];
}
-(void) visitExprToFloatI: (ORExprToFloatI*) c
{
   [self count:c];
   [[c operand] visit:self];
}
-(void) visitExprToDoubleI: (ORExprToDoubleI*) c
{
   [self count:c];
   [[c operand] visit:self];
}
-(void) visitExprAbsI: (ORExprAbsI*) c
{
   [self count:c];
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
   if(alpha != nil)
      [((id<ORModel>)[e tracker]) add:[alpha eq:e]];
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
      _rv = [self simplify:_rv with:[op minus]];
   }else _rv = alpha;
}
-(void) visitExprSqrtI:  (ORExprSqrtI *) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:_rv with:[op sqrt]];
   }else _rv = alpha;
}
-(void) visitExprToFloatI:  (ORExprToFloatI *) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:_rv with:[op toFloat]];
   }else _rv = alpha;
}
-(void) visitExprToDoubleI:  (ORExprToDoubleI *) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:_rv with:[op toDouble]];
   }else _rv = alpha;
}
-(void) visitExprAbsI:  (ORExprAbsI *) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> op = [self doIt:c.operand];
      _rv = [self simplify:_rv with:[op abs]];
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
-(void) visitExprEqualI: (ORExprBinaryI*) c
{
   id<ORExpr> alpha = [_alphas objectForKey:[NSValue valueWithPointer:c]];
   if(alpha == nil){
      id<ORExpr> nL = [self doIt:c.left];
      id<ORExpr> nR = [self doIt:c.right];
      if([nL isVariable] && ![nR isVariable])
         [_alphas setObject:nL forKey:[NSValue valueWithPointer:nR]];
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
