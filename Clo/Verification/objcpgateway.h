#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/objcp.h>
#import "ORCmdLineArgs.h"
#import "ExprSimplifier.h"
#import <math.h>

#define E_SIZE 8
#define M_SIZE 23
#define ED_SIZE 11
#define MD_SIZE 52

@protocol CPProgram;
@class OBJCPGateway;

@protocol LogicHandler <NSObject>
-(id<ORVarArray>) getVariables;
-(id<CPProgram>) getProgram;
-(void) launchHeuristic;
-(void) setOptions:(ORCmdLineArgs*)options;
-(void) printSolutions;
-(ORBool) checkAllbound;
@end

typedef enum {QF_LRA,QF_LIA,QF_RDL,QF_IDL,QF_BV,QF_FP,QF_UF,QF_BVFP} logic;
typedef enum {OR_BOOL, OR_INT, OR_REAL, OR_BV, OR_FLOAT, OR_DOUBLE} objcp_var_type;

static const char*  typeName[] = {"Bool","Int","Real","BitVec","FloatingPoint","Float32"};
static objcp_var_type  typeObj[] = {OR_BOOL, OR_INT, OR_REAL, OR_BV, OR_FLOAT,OR_FLOAT};
#define NB_TYPE 6

static const char* logicString[] = {"QF_LRA","QF_LIA","QF_RDL","QF_IDL","QF_BV","QF_FP","QF_UF","QF_BVFP"};
static logic logicObj[] = {QF_LRA,QF_LIA,QF_RDL,QF_IDL,QF_BV,QF_FP,QF_UF,QF_BVFP};
#define NB_LOGIC 8

typedef void* objcp_context;
typedef void* objcp_var_decl;
typedef void* objcp_type;
typedef void* objcp_model;
typedef void* objcp_expr;
typedef int assertion_id;

@interface OBJCPType : NSObject{
@private
   NSString* _name;
   objcp_var_type _type;
   ORInt    _size;
}
-(OBJCPType*)initExplicit:(NSString*)name withType:(objcp_var_type)type;
-(OBJCPType*)initExplicitWithName:(NSString*)name withType:(objcp_var_type)type andSize:(ORInt)size;
-(NSString*) getName;
-(objcp_var_type) getType;
-(id)copyWithZone:(NSZone *)zone;
-(NSString*) description;
@end

@interface OBJCPDecl : NSObject{
@private
   NSString*   _name;
   OBJCPType*  _type;
   ORInt       _size;
   id<ORVar>   _var;
}
-(OBJCPDecl*)initExplicit:(NSString*)name withType:(OBJCPType*)type;
-(OBJCPDecl*)initExplicitWithSize:(NSString*)name withType:(OBJCPType*)type andSize:(ORInt)size;
-(NSString*) getName;
-(OBJCPType*) getType;
-(ORUInt) getSize;
-(id<ORVar>) getVariable;
-(id)copyWithZone:(NSZone *)zone;
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
-(AbstractLogicHandler*) init:(id<ORModel>)m withOptions:(ORCmdLineArgs *)options withDeclaration:(NSMutableDictionary *)decl;
-(void) printSolutions;
-(void) printSolutionsI;
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
-(ORUInt) uintValue;
-(ORULong) ulongValue;
-(objcp_expr) makeVariable;
-(NSString*) description;
+(void)setObjcpGateway:(OBJCPGateway*) obj;
@end

@interface OBJCPGateway : NSObject{
@private
   id<ORModel> _model;
   NSMutableArray*      _toadd;
   NSMutableDictionary* _types;
   NSMutableDictionary* _declarations;
   NSMutableDictionary* _exprDeclarations;
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
-(void) countUsage:(const char*) n;
@end


@interface OBJCPGateway (Int)
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

@interface OBJCPGateway (Bool)
-(objcp_expr) objcp_mk_and:(objcp_context)ctx left:(id<ORExpr>)b0 right:(id<ORExpr>)b1;
-(objcp_expr) objcp_mk_or:(objcp_context)ctx left:(id<ORExpr>)b0 right:(id<ORExpr>)b1;
-(objcp_expr) objcp_mk_implies:(objcp_context)ctx left:(id<ORExpr>)b0 right:(id<ORExpr>)b1;
-(objcp_expr) objcp_mk_not:(objcp_context)ctx expr:(id<ORExpr>)b0;
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


static inline void i2bs(char str[], int len, unsigned long v){
   unsigned long mask = 0x01UL << (len-2);
   //printf("size = %lu %lu %X\n", sizeof(unsigned long long), v, v);
   for (int i = 0; i < len-1; i++, mask>>=1) {
      str[i] = ((v & mask) ? 1 : 0) + '0';
   }
   str[len-1] = '\0';
}
