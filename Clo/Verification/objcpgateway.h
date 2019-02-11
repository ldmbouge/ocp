#ifndef OBJCPGATEWAY_H
#define OBJCPGATEWAY_H

#import <ORUtilities/ORUtilities.h>
//#import <Foundation/NSData.h>
//#import <Foundation/NSString.h>

//#import <ORFoundation/ORAVLTree.h>
#import <ORFoundation/ORFactory.h>
//#import <ORFoundation/ORSetI.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORProgram/CPProgram.h>
//#import <objcp/CPObjectQueue.h>
#import <objcp/CPFactory.h>

//#import <objcp/CPConstraint.h>
#import <objcp/CPBitMacros.h>

//#import <objcp/CPBitArray.h>
//#import <objcp/CPBitArrayDom.h>
//#import <objcp/CPBitConstraint.h>



#include "/usr/local/include/gmp.h"



@protocol CPProgram;

typedef enum {OR_BOOL, OR_INT, OR_REAL, OR_BV, OR_FLOAT, OR_DOUBLE} objcp_var_type;

static const char*  typeName[] = {"Bool","Int","Real","BitVec","FloatingPoint"};
static objcp_var_type  typeObj[] = {OR_BOOL, OR_INT, OR_REAL, OR_BV, OR_FLOAT};

// A context stores a collection of declarations and assertions.
typedef void* objcp_context;

/**
 \brief Variable declaration
 
 A declaration consists of a name and a type (such as
 <tt>x::bool</tt>).  An instance of the declaration represents the
 term <tt>x</tt>. Instances are also called name
 expressions. Instances can be created using
 #objcp_mk_bool_var_from_decl or #objcp_mk_var_from_decl.
 */
typedef void* objcp_var_decl;

// objcp types (abstract syntax tree)
typedef void* objcp_type;

/**
 \brief Model.
 
 A model assigns constant values to variables defined in a context.
 The context must be known to be consistent for a model to be available.
 The model is constructed by calling #objcp_check (or its relatives) then
 #objcp_get_model.
 */
typedef void* objcp_model;

//-(objcp_expr) objcp expressions (abstract syntax tree)
typedef void* objcp_expr;

/**
 \brief Assertion index, to identify retractable assertions.
 */
typedef int assertion_id;


@interface OBJCPGateway : NSObject{
@private
   id<ORModel> _model;
   NSMutableDictionary* _types;
   NSMutableDictionary* _declarations;
   NSMutableDictionary* _instances;
   id<ORBitVar> _true;
   id<ORBitVar> _false;
}
+(objcp_var_type) sortName2Type:(const char *) name;
+(OBJCPGateway*) initOBJCPGateway;
-(OBJCPGateway*) initExplicitOBJCPGateway;
-(id<ORModel>) getModel;

-(objcp_context) objcp_mk_context;
-(void) objcp_del_context:(objcp_context) ctxt;

-(objcp_expr) objcp_mk_app:(objcp_context) ctx expr:(objcp_expr) f args:(objcp_expr*) args num:(unsigned int)n;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type args:(id) a0,...;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type withSize:(unsigned int) size;
-(objcp_var_decl) objcp_mk_var_decl:(objcp_context) ctx withName:(char*) name andType:(objcp_type) type;
-(objcp_var_decl) objcp_get_var_decl:(objcp_context) ctx withExpr:(objcp_expr)t;
-(objcp_var_decl) objcp_get_var_decl_from_name:(objcp_context) ctx withName:(const char*) name;
-(objcp_expr) objcp_mk_var_from_decl:(objcp_context) ctx withDecl:(objcp_var_decl) d;
-(void) objcp_set_arith_only:(int) flag;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withName:(char*) name;
-(objcp_type) objcp_mk_bitvector_type:(objcp_context)ctx withSize:(unsigned int) size;
-(objcp_type) objcp_mk_function_type:(objcp_context)ctx withDom:(objcp_type*)domain withDomSize:(unsigned long) size andRange:(objcp_type) range;
-(int)        objcp_get_mpq_value:(objcp_model) m withDecl:(objcp_var_decl) d andVal:(mpq_t) value;

/**
 \brief Create a backtracking point in the given logical context.
 
 The logical context can be viewed as a stack of contexts.
 The scope level is the number of elements on this stack. The stack
 of contexts is simulated using trail (undo) stacks.
 */
-(void) objcp_push:(objcp_context) ctx;

/**
 \brief Backtrack.
 
 Restores the context from the top of the stack, and pops it off the
 stack.  Any changes to the logical context (by #yices_assert or
 other functions) between the matching #yices_push and #yices_pop
 operators are flushed, and the context is completely restored to
 what it was right before the #yices_push.
 
 \sa yices_push
 */
-(void) objcp_pop:(objcp_context) ctx;//-(objcp_expr) objcp_assert_retractable
/**
 \brief Assert a constraint in the logical context.
 
 After an assertion, the logical context may become inconsistent.
 The method #yices_inconsistent may be used to check that.
 */
-(assertion_id) objcp_assert_retractable:(objcp_context) ctx withExpr:(objcp_expr) expr;
-(void) objcp_assert:(objcp_context) ctx withExpr:(objcp_expr) expr;
-(ORBool) objcp_check:(objcp_context) ctx;
-(objcp_model) objcp_get_model:(objcp_context) ctx;
-(ORBool)objcp_evaluate_in_model:(objcp_model) m withExpr:(objcp_expr) expr;
-(ORBool) objcp_get_value:(objcp_model) m withVar:(objcp_var_decl) v;
-(ORUInt) objcp_get_unsat_core:(objcp_context) ctx withId:(assertion_id*)a;
-(ORUInt) objcp_get_unsat_core_size:(objcp_context) ctx;
-(objcp_expr) objcp_mk_app:(objcp_context)ctx withFun:(objcp_expr)f withArgs:(objcp_expr*)arg andNumArgs:(ORULong)n;

+(ORInt) intValue:(objcp_expr) e;
@end

@interface OBJCPGateway (BV)
-(objcp_expr) objcp_mk_bv_constant_from_array:(objcp_context) ctx withSize:(ORUInt)size fromArray:(ORUInt*)bv;

-(objcp_expr) objcp_mk_true:(objcp_context)ctx;
-(objcp_expr) objcp_mk_false:(objcp_context)ctx;

-(objcp_expr) objcp_mk_and:(objcp_context)ctx withArgs:(objcp_expr *)args andNumArgs:(ORULong)numArgs;
-(objcp_expr) objcp_mk_or:(objcp_context)ctx withArgs:(objcp_expr *)args andNumArgs:(ORULong)numArgs;
-(objcp_expr) objcp_mk_not:(objcp_context)ctx withArg:(objcp_expr)arg1;

-(objcp_expr) objcp_mk_eq:(objcp_context)ctx withArg:(objcp_expr)arg1 andArg:(objcp_expr)arg2;

//-(objcp_expr) objcp_mk_sum
//-(objcp_expr) objcp_mk_mul
//-(objcp_expr) objcp_mk_sub
//-(objcp_expr) objcp_mk_le
//-(objcp_expr) objcp_mk_lt
//-(objcp_expr) objcp_mk_ge
//-(objcp_expr) objcp_mk_gt
-(objcp_expr) objcp_mk_ite:(objcp_context)ctx if:(objcp_expr) c then:(objcp_expr) t else:(objcp_expr)e ;
//-(objcp_expr) objcp_mk_num_from_string
-(objcp_expr) objcp_mk_diseq:(objcp_context)ctx var:(objcp_expr)arg1 neq:(objcp_expr)arg2;
-(objcp_expr) objcp_mk_bv_concat:(objcp_context)ctx withArg:(objcp_expr)arg1 andArg:(objcp_context)arg2;
-(objcp_expr) objcp_mk_bv_not:(objcp_context) ctx withArg:(objcp_expr) a1;
-(objcp_expr) objcp_mk_bv_and:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_or:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_xor:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_lt:(objcp_expr)ctx x:(objcp_expr)x lt:(objcp_expr)y;

//Shift Left
-(objcp_expr) objcp_mk_bv_shl:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
//Shift Right Logical
-(objcp_expr) objcp_mk_bv_shrl:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_shra:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;

-(objcp_expr) objcp_mk_bv_le:(objcp_expr)ctx x:(objcp_expr)x le:(objcp_expr)y;
-(objcp_expr) objcp_mk_bv_sle:(objcp_expr)ctx x:(objcp_expr)x sle:(objcp_expr)y;
-(objcp_expr) objcp_mk_bv_slt:(objcp_expr)ctx x:(objcp_expr)x slt:(objcp_expr)y;
//-(objcp_expr) objcp_mk_bv_gt
//-(objcp_expr) objcp_mk_bv_sgt
//-(objcp_expr) objcp_mk_bv_ge
//-(objcp_expr) objcp_mk_bv_sge
-(objcp_expr) objcp_mk_bv_constant:(objcp_context) ctx withSize:(ORUInt)size andValue:(ORUInt)value;
-(objcp_expr) objcp_mk_bv_minus:(objcp_context) ctx withArg:(objcp_expr) a1;
-(objcp_expr) objcp_mk_bv_add:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_sub:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_mul:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_div:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;
-(objcp_expr) objcp_mk_bv_rem:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2;

-(objcp_expr) objcp_mk_bv_extract:(objcp_context)ctx from:(ORUInt)msb downTo:(ORUInt)lsb in:(objcp_expr)a1;
-(objcp_expr) objcp_mk_bv_sign_extend:(objcp_context)ctx withArg:(objcp_expr)a1 andAmount:(ORUInt)amt;
-(objcp_expr) objcp_mk_bv_rotl:(objcp_context) ctx withArg:(objcp_expr) a1 andAmount:(ORUInt)a2;
-(objcp_expr) objcp_mk_bv_rotr:(objcp_context) ctx withArg:(objcp_expr) a1 andAmount:(ORUInt)a2;
-(objcp_expr) objcp_mk_bv_zero_extend:(objcp_context)ctx withArg:(objcp_expr)a1 andAmount:(ORUInt)amt;
@end


@interface OBJCPGateway (ORFloat)
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x lt:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x gt:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x leq:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x geq:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x add:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x sub:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x mul:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x div:(objcp_expr)y;
@end
#endif
