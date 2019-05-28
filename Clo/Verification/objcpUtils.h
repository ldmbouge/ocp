#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"



#define E_SIZE 8
#define M_SIZE 23
#define ED_SIZE 11
#define MD_SIZE 52

typedef enum {QF_LRA,QF_LIA,QF_RDL,QF_IDL,QF_BV,QF_FP,QF_UF,QF_BVFP} logic;
typedef enum {OR_BOOL, OR_INT, OR_REAL, OR_BV, OR_FLOAT, OR_DOUBLE} objcp_var_type;

static const char*  typeName[] = {"Bool","Int","Real","BitVec","FloatingPoint","Float32"};
static objcp_var_type  typeObj[] = {OR_BOOL, OR_INT, OR_REAL, OR_BV, OR_FLOAT,OR_FLOAT};
#define NB_TYPE 6

static const char* logicString[] = {"QF_LRA","QF_LIA","QF_RDL","QF_IDL","QF_BV","QF_FP","QF_UF","QF_BVFP"};
static logic logicObj[] = {QF_LRA,QF_LIA,QF_RDL,QF_IDL,QF_BV,QF_FP,QF_UF,QF_BVFP};
#define NB_LOGIC 8


@protocol LogicHandler <NSObject>
-(id<ORVarArray>) getVariables;
-(id<CPProgram>) getProgram;
-(void) launchHeuristic;
-(void) setOptions:(ORCmdLineArgs*)options;
-(void) printSolutions;
-(ORBool) checkAllbound;
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


static inline void i2bs(char str[], int len, unsigned long v){
   unsigned long mask = 0x01UL << (len-2);
   //printf("size = %lu %lu %X\n", sizeof(unsigned long long), v, v);
   for (int i = 0; i < len-1; i++, mask>>=1) {
      str[i] = ((v & mask) ? 1 : 0) + '0';
   }
   str[len-1] = '\0';
}
