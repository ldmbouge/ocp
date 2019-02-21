#ifndef OBJCPGATEWAY_H
#define OBJCPGATEWAY_H

#import <ORUtilities/ORUtilities.h>

#import <ORFoundation/ORFactory.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORProgram/CPProgram.h>
#import <objcp/CPFactory.h>
#import "ORCmdLineArgs.h"

#import <objcp/CPBitMacros.h>


@protocol CPProgram;
@class OBJCPGateway;

typedef enum {QF_LRA,QF_LIA,QF_RDL,QF_IDL,QF_BV,QF_FP,QF_UF} logic;
typedef enum {OR_BOOL, OR_INT, OR_REAL, OR_BV, OR_FLOAT, OR_DOUBLE} objcp_var_type;

static const char*  typeName[] = {"Bool","Int","Real","BitVec","FloatingPoint"};
static objcp_var_type  typeObj[] = {OR_BOOL, OR_INT, OR_REAL, OR_BV, OR_FLOAT};
#define NB_TYPE 5

static const char* logicString[] = {"QF_LRA","QF_LIA","QF_RDL","QF_IDL","QF_BV","QF_FP","QF_UF"};
static logic logicObj[] = {QF_LRA,QF_LIA,QF_RDL,QF_IDL,QF_BV,QF_FP,QF_UF};
#define NB_LOGIC 7

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

@protocol LogicHandler <NSObject>
-(id<ORVarArray>) getVariables;
-(id<CPProgram>) getProgram;
-(void) launchHeuristic;
-(void) setOptions:(ORCmdLineArgs*)options;
-(void) printSolutions;
@end

@interface AbstractLogicHandler : NSObject<LogicHandler>
{
@protected
   id<ORModel>    _model;
   id<CPProgram>  _program;
   ORCmdLineArgs* _options;
   id<ORVarArray> _vars;
}
-(AbstractLogicHandler*) init:(id<ORModel>)m;
-(AbstractLogicHandler*) init:(id<ORModel>)m withOptions:(ORCmdLineArgs*)options;
-(void) printSolutions;
@end

@interface IntLogicHandler : AbstractLogicHandler
{
   @protected
   id<CPHeuristic> _heuristic;
}
@end

@interface BoolLogicHandler : IntLogicHandler
@end

@interface FloatLogicHandler : AbstractLogicHandler
@end

@interface BVLogicHandler : AbstractLogicHandler
{
@protected
   id<CPHeuristic> _heuristic;
}
@end

@interface ConstantWrapper : NSObject
{
   @package
   NSString* _strv;
   ORUInt _width;
   ORUInt _base;
   fp_number _value;
   objcp_var_type _type;
}
-(ConstantWrapper*) init:(const char*) strv width:(ORUInt)width base:(ORUInt)base;
-(ConstantWrapper*) initWithFloat:(float) v;
-(ConstantWrapper*) initWithDouble:(double) v;
-(objcp_var_type) type;
-(ORBool) isEqual:(ConstantWrapper*) v;
-(ORFloat) floatValue;
-(ORDouble) doubleValue;
-(ORInt) intValue;
-(objcp_expr) makeVariable;
-(NSString*) description;
+(void)setObjcpGateway:(OBJCPGateway*) obj;
@end

@interface OBJCPGateway : NSObject{
@private
   id<ORModel> _model;
   NSMutableDictionary* _types;
   NSMutableDictionary* _declarations;
   NSMutableDictionary* _instances;
   ORCmdLineArgs* _options;
   logic _logic;
}
+(objcp_var_type) sortName2Type:(const char *) name;
+(OBJCPGateway*) initOBJCPGateway:(ORCmdLineArgs*)opt;
-(OBJCPGateway*) initExplicitOBJCPGateway:(ORCmdLineArgs*)opt;
-(id<ORModel>) getModel;
-(objcp_context) objcp_mk_context;
-(void) objcp_del_context:(objcp_context) ctxt;
-(objcp_expr) objcp_mk_app:(objcp_context) ctx expr:(objcp_expr) f args:(objcp_expr*) args num:(unsigned int)n;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type args:(id) a0,...;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type withSize:(unsigned int) size;
-(objcp_var_decl) objcp_mk_var_decl:(objcp_context) ctx withName:(char*) name andType:(objcp_type) type;
-(objcp_expr) objcp_mk_var_from_type:(objcp_var_type) type  andName:(NSString*) name andSize:(ORUInt) size withValue:(fp_number)value;
-(objcp_var_decl) objcp_get_var_decl:(objcp_context) ctx withExpr:(objcp_expr)t;
-(objcp_var_decl) objcp_get_var_decl_from_name:(objcp_context) ctx withName:(const char*) name;
-(objcp_expr) objcp_mk_var_from_decl:(objcp_context) ctx withDecl:(objcp_var_decl) d;
-(void) objcp_set_arith_only:(int) flag;
-(void) objcp_set_logic:(const char*) logic;
-(objcp_type) objcp_mk_type:(objcp_context)ctx withName:(char*) name;
-(objcp_type) objcp_mk_function_type:(objcp_context)ctx withDom:(objcp_type*)domain withDomSize:(unsigned long) size andRange:(objcp_type) range;
-(objcp_expr) objcp_mk_var_from_type:(objcp_var_type) type andName:(NSString*) name andSize:(ORUInt) size;
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
@end


@interface OBJCPGateway (Int)
-(id<ORIntVar>) objcp_mk_minus:(objcp_context)ctx var:(objcp_expr)var;
-(id<ORIntVar>) objcp_mk_plus:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORIntVar>) objcp_mk_sub:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORIntVar>) objcp_mk_times:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORIntVar>) objcp_mk_div:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORIntVar>) objcp_mk_eq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORIntVar>) objcp_mk_geq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORIntVar>) objcp_mk_leq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORIntVar>) objcp_mk_gt:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
-(id<ORIntVar>) objcp_mk_lt:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right;
@end

@interface OBJCPGateway (Bool)
-(id<ORIntVar>) objcp_mk_and:(objcp_context)ctx left:(id<ORIntVar>)b0 right:(id<ORIntVar>)b1;
-(id<ORIntVar>) objcp_mk_or:(objcp_context)ctx left:(id<ORIntVar>)b0 right:(id<ORIntVar>)b1;
-(id<ORIntVar>) objcp_mk_implies:(objcp_context)ctx left:(id<ORIntVar>)b0 right:(id<ORIntVar>)b1;
-(id<ORIntVar>) objcp_mk_not:(objcp_context)ctx expr:(id<ORIntVar>)b0;
@end

@interface OBJCPGateway (BV)
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


@interface OBJCPGateway (ORFloat)
-(id<ORDoubleVar>) objcp_mk_to_fp:(id<ORFloatVar>)var;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x eq:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x lt:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x gt:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x leq:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x geq:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x add:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x sub:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x mul:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx x:(objcp_expr)x div:(objcp_expr)y;
-(objcp_expr) objcp_mk_fp:(objcp_expr)ctx neg:(objcp_expr)x;
-(ConstantWrapper*) objcp_mk_fp_constant:(objcp_expr)ctx s:(ConstantWrapper*)s e:(ConstantWrapper*)e m:(ConstantWrapper*)m;
@end

#endif

