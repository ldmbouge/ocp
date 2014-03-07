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
-(id<ORModel>) getModel{
   return _model;
}

-(objcp_context) objcp_mk_context{
   NSLog(@"Make context not implemented");
   return NULL;
}
-(void) objcp_del_context:(objcp_context) ctxt{
   NSLog(@"delete context not implemented");
}


-(objcp_expr) objcp_mk_app:(objcp_context) ctx expr:(objcp_expr) f args:(objcp_expr*) args num:(unsigned int)n{
   NSLog(@"Make app not implemented");
   return NULL;
}

-(objcp_var_decl) objcp_mk_var_decl:(objcp_context) ctx withName:(char*) name andType:(objcp_type) type{
   NSLog(@"Make variable declaration not implemented");
   return NULL;
}

-(objcp_var_decl) objcp_get_var_decl:(objcp_context) ctx withExpr:(objcp_expr)t{
   NSLog(@"Get variable declaration not implemented");
   return NULL;
}

-(objcp_var_decl) objcp_get_var_decl_from_name:(objcp_context) ctx withName:(char*) name{
   NSLog(@"Get variable declaration from name not implemented");
   return NULL;
}

-(objcp_expr) objcp_mk_var_from_decl:(objcp_context) ctx withDecl:(objcp_var_decl) d{
   NSLog(@"Make var from declaration not implemented");
   return NULL;
}

-(void) objcp_set_arith_only:(int) flag{
   NSLog(@"Set arith only not implemented");
}

-(objcp_type) objcp_mk_type:(objcp_context)ctx withName:(char*) name{
   NSLog(@"Make type with name not implemented");
   return NULL;
}

-(objcp_type) objcp_mk_bitvector_type:(objcp_context)ctx withSize:(unsigned int) size{
   NSLog(@"Making bit vector of size %d\n",size);
   ORUInt wordlength = (size / 32) + ((size % 32 != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   return bv;
}

-(objcp_type) objcp_mk_function_type:(objcp_context)ctx withDom:(objcp_type*)domain withDomSize:(unsigned int) size andRange:(objcp_type) range{
   NSLog(@"Make function type not implemented");
   return NULL;
}
-(int)  objcp_get_mpq_value:(objcp_model) m withDecl:(objcp_var_decl) d andVal:(mpq_t) value{
NSLog(@"Get mpq value not implemented");
return 0;
}

/**
 \brief Create a backtracking point in the given logical context.
 
 The logical context can be viewed as a stack of contexts.
 The scope level is the number of elements on this stack. The stack
 of contexts is simulated using trail (undo) stacks.
 */
-(void) objcp_push:(objcp_context) ctx{
   NSLog(@"Push context not implemented");
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
   NSLog(@"Pop context not implemented");
}



//objcp_assert_retractable
/**
 \brief Assert a constraint in the logical context.
 
 After an assertion, the logical context may become inconsistent.
 The method #yices_inconsistent may be used to check that.
 */
-(void) objcp_assert:(objcp_context) ctx withExpr:(objcp_expr) expr{
   NSLog(@"Assert not implemented");
}

-(ORBool) objcp_check:(objcp_context) ctx{
   NSLog(@"Checking CP Model\n");
   __block ORBool sat = false;
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram: _model];
   id<CPEngine> engine = [cp engine];
   id<CPBitVarHeuristic> h =[cp createBitVarFF];
   id<ORExplorer> explorer = [cp explorer];
   
   [cp solve: ^{
      [cp labelBitVarHeuristic:h];
      NSLog(@"Number propagations: %d",[engine nbPropagation]);
      NSLog(@"     Number choices: %d",[explorer nbChoices]);
      NSLog(@"    Number Failures: %d", [explorer nbFailures]);
      sat = true;
   }];
   return sat;
}

-(objcp_model) objcp_get_model:(objcp_context) ctx{
   NSLog(@"Get Model not implemented");
   return NULL;
}

-(ORBool)objcp_evaluate_in_model:(objcp_model) m withExpr:(objcp_expr) expr{
   NSLog(@"Evaluate in Model not implemented");
   return false;
}

-(ORBool) objcp_get_value:(objcp_model) m withVar:(objcp_var_decl) v{
   NSLog(@"Get value not implemented");
   return false;
}

//-(ORUInt) objcp_get_unsat_core:(objcp_context) ctx withId:(assertion_id*)a;
-(ORUInt) objcp_get_unsat_core_size:(objcp_context) ctx{
   NSLog(@"Get unsat core size not implemented");
   return 0;
}

-(objcp_expr) objcp_mk_app:(objcp_context)ctx withFun:(objcp_expr)f withArgs:(objcp_expr*)arg andNumArgs:(ORUInt)n{
   NSLog(@"Make bitvector not implemented");
   return NULL;
}

-(objcp_expr) objcp_mk_bv_constant_from_array:(objcp_context) ctx withSize:(ORUInt)size fromArray:(ORUInt*)bv{
   id<ORBitVar> bitv = [ORFactory bitVar:_model low:bv up:bv bitLength:size];
   //TODO:Shift/mask to create BV pattern
   return bitv;
}

//objcp_mk_and
//objcp_mk_or
//objcp_mk_not
-(objcp_expr) objcp_mk_eq:(objcp_context)ctx withArg:(objcp_expr)arg1 andArg:(objcp_expr)arg2{
   NSLog(@"Make eq constraint not implemented");
   return NULL;
}
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
   
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / 32) + ((size % 32 != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [ORFactory bit:(id<ORBitVar>)a1 not:bv];
   NSLog(@"Added BVNOT Constraint\n");
   return bv;
}

-(objcp_expr) objcp_mk_bv_and:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / 32) + ((size % 32 != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [ORFactory bit:(id<ORBitVar>)a1 and:(id<ORBitVar>)a2 eq:bv];
   NSLog(@"Added BVAND Constraint\n");
   return NULL;
}

-(objcp_expr) objcp_mk_bv_or:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / 32) + ((size % 32 != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [ORFactory bit:(id<ORBitVar>)a1 or:(id<ORBitVar>)a2 eq:bv];
   NSLog(@"Added BVOR Constraint\n");
   return NULL;
}

-(objcp_expr) objcp_mk_bv_xor:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / 32) + ((size % 32 != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [ORFactory bit:(id<ORBitVar>)a1 xor:(id<ORBitVar>)a2 eq:bv];
   NSLog(@"Added BVXOR Constraint\n");
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
-(objcp_expr) objcp_mk_bv_constant:(objcp_context) ctx withSize:(ORUInt)size andValue:(ORUInt)value{
   NSLog(@"Making bit vector of size %d\n",size);
   id<ORBitVar> bitv = [ORFactory bitVar:_model low:&value up:&value bitLength:size];
   NSLog(@"Added BV Constant\n");
   return bitv;
}

//objcp_mk_bv_minus
-(objcp_expr) objcp_mk_bv_add:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / 32) + ((size % 32 != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   id<ORBitVar> cin = [ORFactory bitVar:_model low:low up:up bitLength:size];
   id<ORBitVar> cout = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [ORFactory bit:(id<ORBitVar>)a1 plus:a2 withCarryIn:cin eq:bv withCarryOut:cout];
   NSLog(@"Added BVAdd Constraint\n");
   return bv;
}
//objcp_mk_bv_sub
//objcp_mk_bv_mul
//objcp_mk_bv_extract
//objcp_mk_bv_sign_extend
//objcp_mk_bv_rotl
//objcp_mk_bv_rotr


@end
