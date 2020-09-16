//
//  objcpgatewayI.h
//  Clo
//
//  Created by zitoun on 5/27/19.
//
#import "objcpgateway.h"
@protocol OBJCPGateway;

@interface OBJCPGatewayI : NSObject<OBJCPGateway>{
@protected
   id<ORModel> _model;
   NSMutableArray*      _toadd;
   NSMutableDictionary* _types;
   NSMutableArray* _declarations;
   NSMutableDictionary* _exprDeclarations;
   NSMutableDictionary* _instances;
   ORCmdLineArgs* _options;
   logic _logic;
   id<ORIntVar> _trueVar;
}
-(OBJCPGatewayI*) initExplicitOBJCPGateway:(ORCmdLineArgs*)opt;
-(id<ORModel>) getModel;
-(NSMutableDictionary*) getCurrentDeclarations;
-(objcp_context) objcp_mk_context;
-(void) objcp_del_context:(objcp_context) ctxt;
-(objcp_expr) objcp_mk_app:(objcp_context) ctx expr:(objcp_expr) f args:(objcp_expr*) args num:(unsigned int)n;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type args:(id) a0,...;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type withSize:(unsigned int) size;
-(objcp_var_decl) objcp_mk_var_decl:(objcp_context) ctx withName:(char*) name andType:(objcp_type) type isArg:(ORBool)isarg;
-(objcp_expr) objcp_mk_var_from_type:(objcp_var_type) type  andName:(NSString*) name andSize:(ORUInt) size withValue:(fp_number)value;
-(objcp_var_decl) objcp_get_var_decl:(objcp_context) ctx withExpr:(objcp_expr)t;
-(objcp_var_decl) objcp_get_var_decl_from_name:(objcp_context) ctx withName:(const char*) name;
-(objcp_expr) objcp_mk_var_from_decl:(objcp_context) ctx withDecl:(objcp_var_decl) d;
-(void) objcp_set_arith_only:(int) flag;
-(void) objcp_set_logic:(const char*) logic;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withName:(char*) name;
-(objcp_type) objcp_mk_function_type:(objcp_context)ctx withDom:(objcp_type*)domain withDomSize:(unsigned long) size andRange:(objcp_type) range;
-(objcp_expr) objcp_mk_var_from_type:(objcp_var_type) type andName:(NSString*) name andSize:(ORUInt) size isArg:(ORBool)isarg;
-(void) objcp_push:(objcp_context) ctx;
-(void) objcp_pop:(objcp_context) ctx;
-(void) objcp_assert:(objcp_context) ctx withExpr:(objcp_expr) expr;
-(ORBool) objcp_check:(objcp_context) ctx;
-(objcp_model) objcp_get_model:(objcp_context) ctx;
-(ORBool)objcp_evaluate_in_model:(objcp_model) m withExpr:(objcp_expr) expr;
-(ORBool) objcp_get_value:(objcp_model) m withVar:(objcp_var_decl) v;
-(ORUInt) objcp_get_unsat_core:(objcp_context) ctx withId:(assertion_id*)a;
-(ORUInt) objcp_get_unsat_core_size:(objcp_context) ctx;
-(objcp_expr) objcp_mk_app:(objcp_context)ctx withFun:(objcp_expr)f withArgs:(objcp_expr*)arg andNumArgs:(ORULong)n;
-(objcp_expr) objcp_mk_constant:(objcp_context)ctx fromString:(const char*) rep width:(ORUInt) width base:(ORUInt)base;
-(void) countUsage:(const char*) n;
@end


@interface OBJCPGatewayI (Int) <OBJCPIntGateway>
-(id<ORExpr>) objcp_mk_minus:(objcp_context)ctx var:(objcp_expr)var;
-(id<ORExpr>) objcp_mk_plus:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORExpr>) objcp_mk_sub:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORExpr>) objcp_mk_times:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORExpr>) objcp_mk_div:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORExpr>) objcp_mk_eq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORExpr>) objcp_mk_geq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORExpr>) objcp_mk_leq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORExpr>) objcp_mk_gt:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORExpr>) objcp_mk_lt:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
@end

@interface OBJCPGatewayI (Bool)  <OBJCPBoolGateway>
-(objcp_expr) objcp_mk_and:(objcp_context)ctx left:(id<ORExpr>)b0 right:(id<ORExpr>)b1;
-(objcp_expr) objcp_mk_or:(objcp_context)ctx left:(id<ORExpr>)b0 right:(id<ORExpr>)b1;
-(objcp_expr) objcp_mk_implies:(objcp_context)ctx left:(id<ORExpr>)b0 right:(id<ORExpr>)b1;
-(objcp_expr) objcp_mk_not:(objcp_context)ctx expr:(id<ORExpr>)b0;
@end

@interface OBJCPGatewayI (BV)  <OBJCPBVGateway>
-(objcp_expr) objcp_mk_bv_constant_from_array:(objcp_context) ctx withSize:(ORUInt)size fromArray:(ORUInt*)bv;
-(objcp_expr) objcp_mk_true:(objcp_context)ctx;
-(objcp_expr) objcp_mk_false:(objcp_context)ctx;
-(objcp_expr) objcp_mk_and:(objcp_context)ctx withArgs:(objcp_expr *)args andNumArgs:(ORULong)numArgs;
-(objcp_expr) objcp_mk_ite:(objcp_context)ctx if:(objcp_expr) c then:(objcp_expr) t else:(objcp_expr)e ;
-(objcp_expr) objcp_mk_diseq:(objcp_context)ctx var:(objcp_expr)arg1 neq:(objcp_expr)arg2;
-(objcp_expr) objcp_mk_bv_concat:(objcp_context)ctx withArg:(objcp_expr)arg1 andArg:(objcp_context)arg2;
-(objcp_expr) objcp_mk_bv_eq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(objcp_expr) objcp_mk_bv_not:(objcp_context) ctx withArg:(objcp_expr) a1;
-(objcp_expr) objcp_mk_bv_and:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_or:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_xor:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_lt:(objcp_expr)ctx x:(objcp_expr)x lt:(objcp_expr)y;
-(objcp_expr) objcp_mk_bv_shl:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_shrl:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_shra:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_le:(objcp_context)ctx x:(objcp_expr)x le:(objcp_expr) y;
-(objcp_expr) objcp_mk_bv_sle:(objcp_expr)ctx x:(objcp_expr)x sle:(objcp_expr)y;
-(objcp_expr) objcp_mk_bv_slt:(objcp_expr)ctx x:(objcp_expr)x slt:(objcp_expr)y;
-(objcp_expr) objcp_mk_bv_gt:(objcp_expr)ctx x:(objcp_expr)x gt:(objcp_expr)y;
-(objcp_expr) objcp_mk_bv_sgt:(objcp_expr)ctx x:(objcp_expr)x sgt:(objcp_expr)y;
-(objcp_expr) objcp_mk_bv_ge:(objcp_expr)ctx x:(objcp_expr)x ge:(objcp_expr)y;
-(objcp_expr) objcp_mk_bv_sge:(objcp_expr)ctx x:(objcp_expr)x sge:(objcp_expr)y;
-(objcp_expr) objcp_mk_bv_constant:(objcp_context) ctx withSize:(ORUInt)size andValue:(ORUInt)value;
-(objcp_expr) objcp_mk_bv_minus:(objcp_context) ctx withArg:(objcp_expr) a1;
-(objcp_expr) objcp_mk_bv_add:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_sub:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_mul:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_div:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_rem:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_sdiv:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_srem:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;

-(objcp_expr) objcp_mk_bv_extract:(objcp_context)ctx from:(ORUInt)msb downTo:(ORUInt)lsb in:(objcp_expr)a1;
-(objcp_expr) objcp_mk_bv_sign_extend:(objcp_context)ctx withArg:(objcp_expr)a1 andAmount:(ORUInt)amt;
-(objcp_expr) objcp_mk_bv_rotl:(objcp_context) ctx withArg:(objcp_expr) a1 andAmount:(ORUInt)a2;
-(objcp_expr) objcp_mk_bv_rotr:(objcp_context) ctx withArg:(objcp_expr) a1 andAmount:(ORUInt)a2;
-(objcp_expr) objcp_mk_bv_zero_extend:(objcp_context)ctx withArg:(objcp_expr)a1 andAmount:(ORUInt)amt;
@end


@interface OBJCPGatewayI (ORFloat)  <OBJCPFloatGateway>
-(id<ORExpr>) objcp_mk_to_fp:(id<ORExpr>)var to:(objcp_var_type) t;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x eq:(id<ORExpr>)y;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x lt:(id<ORExpr>)y;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x gt:(id<ORExpr>)y;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x leq:(id<ORExpr>)y;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x geq:(id<ORExpr>)y;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x add:(id<ORExpr>)y;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x sub:(id<ORExpr>)y;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x mul:(id<ORExpr>)y;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x div:(id<ORExpr>)y;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx neg:(id<ORExpr>)x;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx abs:(id<ORExpr>)x;
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx sqrt:(id<ORExpr>)x;
-(ConstantWrapper*) objcp_mk_fp_constant:(objcp_expr)ctx s:(ConstantWrapper*)s e:(ConstantWrapper*)e m:(ConstantWrapper*)m;
@end
