//
//  objcpgatewayaux.m
//  Verification
//
//  Created by zitoun on 5/23/19.
//

#import <Foundation/Foundation.h>
#import "objcpgatewayAux.h"

@implementation OBJCPGatewayAux

-(void) addConstraints
{
   if([_options is3Bfiltering]){
      NSArray* arr = _toadd;
      id<ORGroup> g = [ORFactory group:_model type:Group3B];
      for(id<ORExpr> e in arr){
         [g add:e];
      }
      [_model add:g];
   }else{
      NSArray* arr = _toadd;
      for(id<ORExpr> e in arr){
         [_model add:e];
      }
   }
}
@end


@implementation OBJCPGatewayI (Int)
-(id<ORExpr>) objcp_mk_eq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   if([(id)left isKindOfClass:[ConstantWrapper class]] && [(id)right isKindOfClass:[ConstantWrapper class]])
      return [ORFactory intVar:_model value:([(ConstantWrapper*)left isEqual: (ConstantWrapper*)right])];
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   if([lv.class conformsToProtocol:@protocol(ORVar)] && [rv.class conformsToProtocol:@protocol(ORVar)]){
      if(rv.getId == lv.getId) return [ORFactory intVar:_model value:1];
      if([lv vtype] == ORTBit && [rv vtype] == ORTBit)
         return [self objcp_mk_bv_eq:ctx left:lv right:rv];
      if([lv vtype] == ORTFloat || [lv vtype] == ORTDouble)
         return [self objcp_mk_fp:ctx x:lv eq:rv];
      id<ORIntVar> lvi = (id<ORIntVar>) lv;
      id<ORIntVar> rvi = (id<ORIntVar>) rv;
      if([lvi low] == [lvi up] && [rvi low] == [rvi up] && [lvi low] == [rvi low])
         return [ORFactory intVar:_model value:1];
   }
   id<ORExpr> res = [ORFactory boolVar:_model];
   [_toadd addObject:[res eq:[lv eq:rv]]];
   return res;
}
-(id<ORIntVar>) objcp_mk_minus:(objcp_context)ctx var:(objcp_expr)var
{
   id<ORIntVar> v = (id<ORIntVar>)[self getVariable:var];
   id<ORIntVar> res = [ORFactory intVar:_model domain:RANGE(_model, -v.up, -v.low)];
   [_toadd addObject:[res eq:[v minus]]];
   return res;
}
-(id<ORExpr>) objcp_mk_plus:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   id<ORExpr> res = [ORFactory intVar:_model];
   [_toadd addObject:[res eq:[lv plus:rv]]];
   return res;
}
-(id<ORExpr>) objcp_mk_sub:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   id<ORExpr> res = [ORFactory intVar:_model];
   [_toadd addObject:[res eq:[lv sub:rv]]];
   return res;
}
-(id<ORExpr>) objcp_mk_times:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   id<ORExpr> res = [ORFactory intVar:_model];
   [_toadd addObject:[res eq:[lv mul:rv]]];
   return res;
}
-(id<ORExpr>) objcp_mk_div:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   id<ORExpr> res = [ORFactory intVar:_model];
   [_toadd addObject:[res eq:[lv div:rv]]];
   return res;
}
-(id<ORExpr>) objcp_mk_geq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   id<ORExpr> res = [ORFactory intVar:_model];
   [_toadd addObject:[res eq:[lv geq:rv]]];
   return res;
}
-(id<ORExpr>) objcp_mk_leq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   id<ORExpr> res = [ORFactory intVar:_model];
   [_toadd addObject:[res eq:[lv leq:rv]]];
   return res;
}
-(id<ORExpr>) objcp_mk_gt:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   id<ORExpr> res = [ORFactory intVar:_model];
   [_toadd addObject:[res eq:[lv gt:rv]]];
   return res;
}
-(id<ORExpr>) objcp_mk_lt:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   id<ORExpr> res = [ORFactory intVar:_model];
   [_toadd addObject:[res eq:[lv gt:rv]]];
   return res;
}
@end

@implementation OBJCPGatewayI (Bool)

-(objcp_expr) objcp_mk_and:(objcp_context)ctx left:(id<ORExpr>)b0 right:(id<ORExpr>)b1
{
   if([b0.class conformsToProtocol:@protocol(ORIntVar)]){
      if([b1.class conformsToProtocol:@protocol(ORIntVar)]){
         if([(id<ORIntVar>)b0 low] && [(id<ORIntVar>)b1 low]) return [ORFactory intVar:_model value:1];
         if(![(id<ORIntVar>)b0 up] || ![(id<ORIntVar>)b1 up]) return [ORFactory intVar:_model value:0];
      }
      if([(id<ORIntVar>)b0 low]) return b1;
   }
   if([b1.class conformsToProtocol:@protocol(ORIntVar)] && [(id<ORIntVar>)b1 low]){
      return b0;
   }
   id<ORExpr> res = [ORFactory boolVar:_model];
   [_toadd addObject:[res eq:[b0 land:b1]]];
   return res;
}

-(objcp_expr) objcp_mk_or:(objcp_context)ctx left:(id<ORExpr>)b0 right:(id<ORExpr>)b1
{
   if([b0.class conformsToProtocol:@protocol(ORIntVar)]){
      if([b1.class conformsToProtocol:@protocol(ORIntVar)]){
         if([(id<ORIntVar>)b0 low] || [(id<ORIntVar>)b1 low]) return [ORFactory intVar:_model value:1];
         if(![(id<ORIntVar>)b0 up] && ![(id<ORIntVar>)b1 up]) return [ORFactory intVar:_model value:0];
      }
      if([(id<ORIntVar>)b0 low]) return b1;
   }
   if([b1.class conformsToProtocol:@protocol(ORIntVar)] && [(id<ORIntVar>)b1 low]){
      return b0;
   }
   id<ORExpr> res = [ORFactory boolVar:_model];
   [_toadd addObject:[res eq:[b0 lor:b1]]];
    return res;
}

-(objcp_expr) objcp_mk_not:(objcp_context)ctx expr:(id<ORExpr>)b0
{
   if([b0.class conformsToProtocol:@protocol(ORIntVar)]){
      if([(id<ORIntVar>)b0 low]) return [ORFactory intVar:_model value:1];
      if(![(id<ORIntVar>)b0 up]) return [ORFactory intVar:_model value:0];
   }
   id<ORExpr> res = [ORFactory boolVar:_model];
   [_toadd addObject:[res eq:[b0 neg]]];
    return res;
}

-(objcp_expr) objcp_mk_implies:(objcp_context)ctx left:(id<ORExpr>)b0 right:(id<ORExpr>)b1
{
   if([b0.class conformsToProtocol:@protocol(ORIntVar)]){
      if([b1.class conformsToProtocol:@protocol(ORIntVar)]){
         if([(id<ORIntVar>)b0 low] && ![(id<ORIntVar>)b1 up]) return [ORFactory intVar:_model value:0];
         if(![(id<ORIntVar>)b0 up] || [(id<ORIntVar>)b1 low]) return [ORFactory intVar:_model value:1];
      }
      if([(id<ORIntVar>)b0 low]) return b1;
   }
   if([b1.class conformsToProtocol:@protocol(ORIntVar)] && [(id<ORIntVar>)b1 low]){
      return b0;
   }
   id<ORExpr> res = [ORFactory boolVar:_model];
   [_toadd addObject:[res eq:[b0 imply:b1]]];
   return res;
}
@end

@implementation OBJCPGatewayAux (Float)
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x eq:(id<ORExpr>)y
{
   id<ORExpr> res = [ORFactory boolVar:_model];
   [_toadd addObject:[res eq:[x eq:y]]];
   return res;
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x lt:(id<ORExpr>)y
{
   id<ORExpr> res = [ORFactory boolVar:_model];
   [_toadd addObject:[res eq:[x lt:y]]];
   return res;
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x gt:(id<ORExpr>)y
{
   id<ORExpr> res = [ORFactory boolVar:_model];
   [_toadd addObject:[res eq:[x gt:y]]];
   return res;
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x leq:(id<ORExpr>)y
{
   id<ORExpr> res = [ORFactory boolVar:_model];
   [_toadd addObject:[res eq:[x leq:y]]];
   return res;
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x geq:(id<ORExpr>)y
{
   id<ORExpr> res = [ORFactory boolVar:_model];
   [_toadd addObject:[res eq:[x geq:y]]];
   return res;
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx neg:(id<ORExpr>)x
{
   id<ORExpr> res;
   if([x conformsToProtocol:@protocol(ORFloatVar)]){
      res = [ORFactory floatVar:_model];
   }else{
      res = [ORFactory doubleVar:_model];
   }
   [_toadd addObject:[res eq:[x minus]]];
   return res;
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx sqrt:(id<ORExpr>)x
{
   id<ORExpr> res;
   if([x conformsToProtocol:@protocol(ORFloatVar)]){
      res = [ORFactory floatVar:_model];
   }else{
      res = [ORFactory doubleVar:_model];
   }
   [_toadd addObject:[res eq:[x sqrt]]];
   return res;
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx abs:(id<ORExpr>)x
{
   id<ORExpr> res;
   if([x conformsToProtocol:@protocol(ORFloatVar)]){
      res = [ORFactory floatVar:_model];
   }else{
      res = [ORFactory doubleVar:_model];
   }
   [_toadd addObject:[res eq:[x abs]]];
   return res;
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x add:(id<ORExpr>)y
{
   id<ORExpr> res;
   if([x conformsToProtocol:@protocol(ORFloatVar)]){
      res = [ORFactory floatVar:_model];
   }else{
      res = [ORFactory doubleVar:_model];
   }
   [_toadd addObject:[res eq:[x plus:y]]];
   return res;
}

-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x sub:(id<ORExpr>)y
{
   id<ORExpr> res;
   if([x conformsToProtocol:@protocol(ORFloatVar)]){
      res = [ORFactory floatVar:_model];
   }else{
      res = [ORFactory doubleVar:_model];
   }
   [_toadd addObject:[res eq:[x sub:y]]];
   return res;
}

-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x mul:(id<ORExpr>)y
{
   id<ORExpr> res;
   if([x conformsToProtocol:@protocol(ORFloatVar)]){
      res = [ORFactory floatVar:_model];
   }else{
      res = [ORFactory doubleVar:_model];
   }
   [_toadd addObject:[res eq:[x mul:y]]];
   return res;
}

-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x div:(id<ORExpr>)y
{
   id<ORExpr> res;
   if([x conformsToProtocol:@protocol(ORFloatVar)]){
      res = [ORFactory floatVar:_model];
   }else{
      res = [ORFactory doubleVar:_model];
   }
   [_toadd addObject:[res eq:[x div:y]]];
   return res;
}

-(ConstantWrapper*) objcp_mk_fp_constant:(objcp_expr)ctx s:(ConstantWrapper*)s e:(ConstantWrapper*)e m:(ConstantWrapper*)m
{
   assert((e->_width == E_SIZE && m->_width == M_SIZE) || (e->_width == ED_SIZE && m->_width == MD_SIZE));
   if(e->_width == E_SIZE && m->_width == M_SIZE){
      float f = floatFromParts([m uintValue],[e uintValue],[s uintValue]);
      NSLog(@"%16.16e",f);
      return [[ConstantWrapper alloc] initWithFloat:f];
   }
   if(e->_width == ED_SIZE && m->_width == MD_SIZE){
      double f = doubleFromParts([m ulongValue],[e uintValue],[s uintValue]);
      NSLog(@"%20.20e",f);
      return [[ConstantWrapper alloc] initWithDouble:f];
   }
   return nil;
}
-(id<ORExpr>) objcp_mk_to_fp:(id<ORExpr>)x to:(objcp_var_type) t
{
   id<ORExpr> res;
   if([(id)x isKindOfClass:[ConstantWrapper class]])
      x = (id<ORExpr>)[(ConstantWrapper*)x makeVariable];
   if(t == OR_DOUBLE){
      res = [ORFactory doubleVar:_model];
      [_toadd addObject:[res eq:[x toDouble]]];
   }else{
      res = [ORFactory floatVar:_model];
      [_toadd addObject:[res eq:[x toFloat]]];
   }
   return res;
}
@end
