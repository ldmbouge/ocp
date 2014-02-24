//
//  OBJCPGateway.c
//  Clo
//
//  Created by Greg Johnson on 2/23/14.
//
//

#import "OBJCPGateway.h"

@implementation OBJCPGateway:NSObject
+(OBJCPGateway*) initOBJCPGateway{
   OBJCPGateway* x = [[OBJCPGateway alloc]initExplicitOBJCPGateway];
   return x;
}

-(OBJCPGateway*) initExplicitOBJCPGateway{
   self = [super init];
   _model = [ORFactory createModel];
   return self;
}

-(objcp_context) objcp_mk_context{
   NSLog(@"Not implemented");
   return NULL;
}
-(void) objcp_del_context:(objcp_context) ctxt{
   NSLog(@"Not implemented");
}


-(objcp_expr) objcp_mk_app:(objcp_context) ctx expr:(objcp_expr) f args:(objcp_expr*) args num:(unsigned int)n{
   NSLog(@"Not implemented");
   return NULL;
}

-(objcp_var_decl) objcp_mk_var_decl:(objcp_context) ctx withName:(char*) name andType:(objcp_type) type{
   NSLog(@"Not implemented");
   return NULL;
}

-(objcp_var_decl) objcp_get_var_decl_from_name:(objcp_context) ctx withName:(char*) name{
   NSLog(@"Not implemented");
   return NULL;
}

-(objcp_expr) objcp_mk_var_from_decl:(objcp_context) ctx withDecl:(objcp_var_decl) d{
   NSLog(@"Not implemented");
   return NULL;
}

-(void) objcp_set_arith_only:(int) flag{
   NSLog(@"Not implemented");
}

-(objcp_type) objcp_mk_type:(objcp_context)ctx withName:(char*) name{
   NSLog(@"Not implemented");
   return NULL;
}

-(objcp_type) objcp_mk_bitvector_type:(objcp_context)ctx withSize:(unsigned int) size{
   NSLog(@"Not implemented");
   return NULL;
}

-(objcp_type) objcp_mk_function_type:(objcp_context)ctx withDom:(objcp_type*)domain withDomSize:(unsigned int) size andRange:(objcp_type) range{
   NSLog(@"Not implemented");
   return NULL;
}

/**
 \brief Create a backtracking point in the given logical context.
 
 The logical context can be viewed as a stack of contexts.
 The scope level is the number of elements on this stack. The stack
 of contexts is simulated using trail (undo) stacks.
 */
-(void) objcp_push:(objcp_context) ctx{
   NSLog(@"Not implemented");
}

/**
 \brief Backtrack.
 
 Restores the context from the top of the stack, and pops it off the
 stack.  Any changes to the logical context (by #yices_assert or
 other functions) between the matching #yices_push and #yices_pop
 operators are flushed, and the context is completely restored to
 what it was right before the #yices_push.
 
 \sa yices_push
 */
-(void) objcp_pop:(objcp_context) ctx{
   NSLog(@"Not implemented");
}



//objcp_assert_retractable
/**
 \brief Assert a constraint in the logical context.
 
 After an assertion, the logical context may become inconsistent.
 The method #yices_inconsistent may be used to check that.
 */
-(void) objcp_assert:(objcp_context) ctx withExpr:(objcp_expr) expr{
   NSLog(@"Not implemented");
}

-(ORBool) objcp_check:(objcp_context) ctx{
   NSLog(@"Not implemented");
   return false;
}

-(objcp_model) objcp_get_model:(objcp_context) ctx{
   NSLog(@"Not implemented");
   return NULL;
}

-(ORBool)objcp_evaluate_in_model:(objcp_model) m withExpr:(objcp_expr) expr{
   NSLog(@"Not implemented");
   return false;
}

-(ORBool) objcp_get_value:(objcp_model) m withVar:(objcp_var_decl) v{
   NSLog(@"Not implemented");
   return false;
}

//-(ORUInt) objcp_get_unsat_core:(objcp_context) ctx withId:(assertion_id*)a;
-(ORUInt) objcp_get_unsat_core_size:(objcp_context) ctx{
   NSLog(@"Not implemented");
   return 0;
}

-(objcp_expr) objcp_mk_app:(objcp_context)ctx withFun:(objcp_expr)f withArgs:(objcp_expr*)arg andNumArgs:(ORUInt)n{
   NSLog(@"Not implemented");
   return NULL;
}

-(objcp_expr) objcp_mk_bv_constant_from_array:(objcp_context) ctx withSize:(ORUInt)size fromArray:(ORInt*)bv{
   NSLog(@"Not implemented");
   return NULL;
}

//objcp_mk_and
//objcp_mk_or
//objcp_mk_not
//objcp_mk_eq
//objcp_mk_sum
//objcp_mk_mul
//objcp_mk_sub
//objcp_mk_le
//objcp_mk_lt
//objcp_mk_ge
//objcp_mk_gt
//objcp_mk_ite
//objcp_mk_num_from_string
//objcp_mk_diseq
//objcp_mk_bv_concat
-(objcp_expr) objcp_mk_bv_not:(objcp_context) ctx withArg:(objcp_expr) a1{
   NSLog(@"Not implemented");
   return NULL;
}

-(objcp_expr) objcp_mk_bv_and:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   NSLog(@"Not implemented");
   return NULL;
}

-(objcp_expr) objcp_mk_bv_or:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   NSLog(@"Not implemented");
   return NULL;
}

-(objcp_expr) objcp_mk_bv_xor:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   NSLog(@"Not implemented");
   return NULL;
}

//objcp_mk_bv_lt
//objcp_mk_bv_slt
//objcp_mk_bv_le
//objcp_mk_bv_sle
//objcp_mk_bv_gt
//objcp_mk_bv_sgt
//objcp_mk_bv_ge
//objcp_mk_bv_sge
-(objcp_expr) objcp_mk_bv_constant:(objcp_context) ctx withSize:(ORUInt)size andValue:(ORULong)value{
   NSLog(@"Not implemented");
   return NULL;
}

//objcp_mk_bv_minus
-(objcp_expr) objcp_mk_bv_add:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   NSLog(@"Not implemented");
   return NULL;
}

//objcp_mk_bv_sub
//objcp_mk_bv_mul
//objcp_mk_bv_extract
//objcp_mk_bv_sign_extend
//objcp_mk_bv_rotl
//objcp_mk_bv_rotr


@end
