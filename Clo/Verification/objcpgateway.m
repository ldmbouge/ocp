//
//  OBJCPGateway.c
//  Clo
//
//  Created by Greg Johnson on 2/23/14.
//
//

#import "objcpgateway.h"
#include "gmp.h"

@interface OBJCPType : NSObject{
@private
   NSString* _name;
   objcp_var_type _type;
   ORInt    _size;
}
-initExplicit:(NSString*)name withType:(objcp_var_type)type;
-initExplicitWithName:(NSString*)name withType:(objcp_var_type)type andSize:(ORInt)size;
-(NSString*) getName;
-(objcp_var_type) getType;
-(id)copyWithZone:(NSZone *)zone;
-(NSString*) description;
@end


@implementation ConstantWrapper
static OBJCPGateway *objcpgw;

-(ConstantWrapper*) init:(const char*) strv width:(ORUInt)width base:(ORUInt)base
{
   self = [super init];
   _strv = [NSString stringWithUTF8String:strv];
   _width = width;
   _base = base;
   char * pEnd;
   _value.llong_nb = strtol(strv, &pEnd, _base);
   switch (base) {
      case 10:
         _type = (width == 0) ? OR_INT : OR_BV;
         break;
      case 16:
      case 2:
      default:
         _type = OR_BV;
         break;
   }
   return self;
}
-(NSString*) description
{
   return [NSString stringWithFormat:@"_v:%@; _w:%d; _b:%d",_strv,_width,_base];
}
-(ConstantWrapper*) initWithFloat:(float) v
{
   self = [super init];
   _base = 10;
   _strv = [NSString stringWithFormat:@"%16.16e", v];
   _value.float_nb = v;
   _type = OR_FLOAT;
   return self;
}
-(ConstantWrapper*) initWithDouble:(double) v
{
   self = [super init];
   _base = 10;
   _strv = [NSString stringWithFormat:@"%16.16e", v];
   _value.double_nb = v;
   _type = OR_DOUBLE;
   return self;
}
-(objcp_var_type) type
{
   return _type;
}
-(ORBool) isEqual:(ConstantWrapper*) v
{
   return _type == v->_type && _value.int_nb == v->_value.int_nb;
}
-(ORFloat) floatValue
{
   return _value.float_nb;
}
-(ORDouble) doubleValue
{
   return _value.double_nb;
}
-(ORInt) intValue
{
   return _value.int_nb;
}
-(ORUInt) uintValue
{
   return _value.uint_nb;
}
-(ORULong) ulongValue
{
   return _value.ullong_nb;
}
-(objcp_expr) makeVariable
{
   return [objcpgw objcp_mk_var_from_type:_type andName:nil andSize:_width withValue:_value];
}
+(void) setObjcpGateway:(OBJCPGateway*) obj
{
   objcpgw = obj;
}
@end

@implementation AbstractLogicHandler
-(AbstractLogicHandler*) init:(id<ORModel>)m
{
   self = [self init:m withOptions:nil];
   return self;
}
-(AbstractLogicHandler*) init:(id<ORModel>)m withOptions:(ORCmdLineArgs *)options
{
   self = [super init];
   _model = m;
   _vars = [self getVariables];
   if(options == nil){
      int argc = 2;
      const char* argv[] = {};
      _options = [ORCmdLineArgs newWith:argc argv:argv];
   }else{
      _options = options;
   }
   _program = [_options makeProgram:_model];
   return self;
}
- (id<ORVarArray>)getVariables
{
   @throw [[ORExecutionError alloc] initORExecutionError: "AbstractLogicHandler is an abstract class"];
}
-(id<CPProgram>) getProgram
{
   return _program;
}
- (void)launchHeuristic
{
     @throw [[ORExecutionError alloc] initORExecutionError: "AbstractLogicHandler is an abstract class"];
}
- (void)setOptions:(ORCmdLineArgs *)options
{
   _options = options;
}
-(void) printSolutions
{
   [self printSolutionsI];
   [self checkAllbound];
}
-(void) printSolutionsI
{
    @throw [[ORExecutionError alloc] initORExecutionError: "AbstractLogicHandler is an abstract class"];
}
-(void) checkAllbound
{
   NSArray* vars = [_model variables];
   for(id<ORVar> v in vars)
      if(![_program bound:v])
         NSLog(@"la variable %@ n'est pas bound : %@",v,[_program concretize:v]);
//      assert([_program bound:v]);
}
@end

@implementation IntLogicHandler
-(IntLogicHandler*) init:(id<ORModel>) m withOptions:(ORCmdLineArgs *)options
{
   self = [super init:m withOptions:options];
   _heuristic = [_options makeHeuristic:_program restricted:(id<ORIntVarArray>)[self getVariables]];
   return self;
}
-(id<ORVarArray>) getVariables
{
   return [_model intVars];
}
- (void)launchHeuristic
{
   [_program labelHeuristic:_heuristic];
}
-(void) printSolutionsI
{
   for(id<ORVar> v in _vars){
      NSLog(@"%@ : %d (%s) %@",v,[_program intValue:v],[_program bound:v] ? "YES" : "NO",[_program concretize:v]);
   }
}
@end

@implementation BoolLogicHandler
@end

@implementation FloatLogicHandler
-(id<ORVarArray>) getVariables
{
   return [_model floatVars];
}
- (void)launchHeuristic
{
   [_options launchHeuristic:_program restricted:_vars];
}
-(void) printSolutionsI
{
   for(id<ORVar> v in _vars){
      NSLog(@"%@ : %20.20e (%s)",v,[_program floatValue:v],[_program bound:v] ? "YES" : "NO");
   }
}
@end

@implementation BVLogicHandler
-(BVLogicHandler*) init:(id<ORModel>) m withOptions:(ORCmdLineArgs *)options
{
   self = [super init];
   _model = m;
   _vars = [self getVariables];
   if(options == nil){
      int argc = 2;
      const char* argv[] = {};
      _options = [ORCmdLineArgs newWith:argc argv:argv];
   }else{
      _options = options;
   }
   _program = [ORFactory createCPProgramBackjumpingDFS:_model];
   _heuristic = [_program createDDeg];
   return self;
}
-(id<ORVarArray>) getVariables
{
   return [_model bitVars];
}
@end

@implementation OBJCPType
-initExplicit:(NSString*)name withType:(objcp_var_type)type{
   self = [self initExplicitWithName:name withType:type andSize:1];
   return self;
}
-initExplicitWithName:(NSString*)name withType:(objcp_var_type)type andSize:(ORInt)size
{
   self=[super init];
   _name = name;
   _type = type;
   _size = size;
   return self;
}
-(NSString*) getName{
   return _name;
}
-(objcp_var_type) getType{
   return _type;
}
-(ORInt) getSize{
   return _size;
}
-(id) copyWithZone:(NSZone *)zone{
   OBJCPType* newObject = [[OBJCPType alloc] initExplicitWithName:_name withType:_type andSize:_size];
   return newObject;
}
-(NSString*) description
{
   return [NSString stringWithFormat:@"name:%@;type:%s",_name,typeName[_type]];
}
@end

@interface OBJCPDecl : NSObject{
@private
   NSString*   _name;
   OBJCPType*  _type;
   ORInt       _size;
   id<ORVar>   _var;
}
-initExplicit:(NSString*)name withType:(OBJCPType*)type;
-initExplicitWithSize:(NSString*)name withType:(OBJCPType*)type andSize:(ORInt)size;
-(NSString*) getName;
-(OBJCPType*) getType;
-(ORUInt) getSize;
-(id)copyWithZone:(NSZone *)zone;
@end

@implementation OBJCPDecl
-(OBJCPDecl*)initExplicit:(NSString*)name withType:(OBJCPType*)type{
   self= [ self initExplicitWithSize:name withType:type andSize:1];
   return self;
}
-(OBJCPDecl*)initExplicitWithSize:(NSString*)name withType:(OBJCPType*)type andSize:(ORInt)size
{
   self=[super init];
   _name = name;
   _type = (OBJCPType*)type;
   _size = size;
   _var = nil;
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithFormat:@"Objective CP Declaration for %@ to variable %@",_name,_var];
   return string;
}
-(NSString*) getName{
   return _name;
}
-(OBJCPType*) getType
{
   return _type;
}
-(id<ORVar>) getVar
{
   return _var;
}
-(ORUInt) getSize
{
   return _size;
}
-(void) setVar:(id<ORVar>) var
{
   _var = var;
}
-(id) copyWithZone:(NSZone *)zone
{
   OBJCPDecl* newObject = [[OBJCPDecl alloc] initExplicitWithSize:_name withType:_type andSize:_size];
   return newObject;
}
@end

@implementation OBJCPGateway:NSObject
+(OBJCPGateway*) initOBJCPGateway
{
   OBJCPGateway* x = [[OBJCPGateway alloc] initExplicitOBJCPGateway:nil];
   return x;
}
+(OBJCPGateway*) initOBJCPGateway:(ORCmdLineArgs*) opt
{
   OBJCPGateway* x = [[OBJCPGateway alloc] initExplicitOBJCPGateway:opt];
   return x;
}
-(OBJCPGateway*) initExplicitOBJCPGateway:(ORCmdLineArgs*) opt
{
   self = [super init];
   _model = [ORFactory createModel];
   _declarations = [[NSMutableDictionary alloc] initWithCapacity:10];
   _instances = [[NSMutableDictionary alloc] initWithCapacity:10];
   _types = [[NSMutableDictionary alloc] initWithCapacity:10];
   _options = opt;
   [ConstantWrapper setObjcpGateway:self];
   return self;
}
+(objcp_var_type) sortName2Type:(const char *) name
{
   ORInt i;
   for(i = 0; i < NB_TYPE; i++){
      if(strcmp(name,typeName[i]) == 0){
         break;
      }
   }
   return (i<NB_TYPE) ? typeObj[i] : 0;
}
+(logic) logicFromString:(const char *) name
{
   ORInt i;
   for(i = 0; i < NB_LOGIC; i++){
      if(strcmp(name,logicString[i]) == 0){
         break;
      }
   }
   return (i<NB_LOGIC) ? logicObj[i] : 0;
}
-(id<ORModel>) getModel
{
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
-(objcp_var_decl) objcp_mk_var_decl:(objcp_context) ctx withName:(char*) name andType:(objcp_type) type
{
   NSString* nameString =[[NSString alloc] initWithUTF8String:name];
   OBJCPType* t = (OBJCPType*) type;
   OBJCPDecl* d = [[OBJCPDecl alloc] initExplicitWithSize:nameString withType:type andSize:[t getSize]];
   [_declarations  setObject:d forKey:nameString];
   return (void*)t;
}
-(objcp_var_decl) objcp_get_var_decl:(objcp_context) ctx withExpr:(objcp_expr)t{
   NSLog(@"Get variable declaration not implemented");
   return NULL;
}
-(objcp_var_decl) objcp_get_var_decl_from_name:(objcp_context) ctx withName:(const char*) name{
   NSString *key = [[NSString alloc] initWithUTF8String:name];
   
   OBJCPDecl* d = [_declarations objectForKey:key];
   return d;
}
//create or return variable from declaration
-(objcp_expr) objcp_mk_var_from_decl:(objcp_context) ctx withDecl:(objcp_var_decl) d
{
   OBJCPDecl* decl = d;
   NSString* name = [decl getName];
   ORUInt size = [decl getSize];
   objcp_var_type type = [[decl getType] getType];
   objcp_expr res = [decl getVar];
   if(res == nil){
      res = [self objcp_mk_var_from_type:type andName:name andSize:size];
      [decl setVar:res];
   }
   return res;
}
#warning need to encapsulate fp_number in struct to factorise next function
-(objcp_expr) objcp_mk_var_from_type:(objcp_var_type) type  andName:(NSString*) name andSize:(ORUInt) size withValue:(fp_number)value
{
   objcp_expr res = nil;
   switch (type) {
      case OR_BOOL:
      case OR_INT:
         res = [ORFactory intVar:_model bounds:RANGE(_model,value.int_nb,value.int_nb) name:name];
         break;
      case OR_REAL:
         res = [ORFactory double:_model value:value.double_nb];
         break;
      case OR_BV:
      {
         res = [ORFactory bitVar:_model low:&(value.uint_nb) up:&(value.uint_nb) bitLength:size name:name];
         break;
      }
      case OR_FLOAT:
         res = [ORFactory float:_model value:value.float_nb];
         break;
      case OR_DOUBLE:
         res = [ORFactory double:_model value:value.double_nb];
         break;
      default:
         break;
   }
   return res;
}

-(objcp_expr) objcp_mk_var_from_type:(objcp_var_type) type andName:(NSString*) name andSize:(ORUInt) size
{
   objcp_expr res = nil;
   switch (type) {
      case OR_BOOL:
         res = [ORFactory intVar:_model domain:RANGE(_model,0,1) name:name];
         break;
      case OR_INT:
         res = [ORFactory intVar:_model bounds:RANGE(_model,-MAXINT,MAXINT) name:name];
         break;
      case OR_REAL:
         res = [ORFactory realVar:_model name:name];
         break;
      case OR_BV:
      {
         unsigned int wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
         ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
         ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
         for(int i=0; i< wordlength;i++){
            low[i] = 0;
            up[i] = CP_UMASK;
         }
          if (size%BITSPERWORD != 0)
              up[0] >>= BITSPERWORD - (size % BITSPERWORD);
         res = [ORFactory bitVar:_model low:low up:up bitLength:size name:name];
         break;
      }
      case OR_FLOAT:
         res = [ORFactory floatVar:_model name:name];
         break;
      case OR_DOUBLE:
         res = [ORFactory doubleVar:_model name:name];
         break;
      default:
         break;
   }
   return res;
}
-(void) objcp_set_arith_only:(int) flag
{
   NSLog(@"Set arith only not implemented");
}
-(void) objcp_set_logic:(const char*) logic
{
   _logic = [OBJCPGateway logicFromString:logic];
}

+(id<LogicHandler>) logicToHandler:(logic) l withModel:(id<ORModel>) model withOptions:(ORCmdLineArgs*) options
{
   switch(l){
      case  QF_BV    : return [[BVLogicHandler alloc] init:model withOptions:options];
      case  QF_LIA     : return [[IntLogicHandler alloc] init:model withOptions:options];
      case  QF_FP     : return [[FloatLogicHandler alloc] init:model withOptions:options];
      case QF_LRA    : //should return reallogichandler
      default         : return [[AbstractLogicHandler alloc] init:model withOptions:options];
   }
}
-(objcp_type) objcp_mk_type:(objcp_context)ctx withName:(char*) name
{
   return NULL;
}
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type
{
   return [self objcp_mk_type:ctx withType:type withSize:1];
}
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type args:(id) a0,...
{
   va_list args;
   va_start(args, a0);
   NSMutableArray* argsObj = [[NSMutableArray alloc] init];
   for (id arg = a0; arg != nil; arg = va_arg(args,id))
   {
      [argsObj addObject:arg];
   }
   va_end(args);
   objcp_type res = nil;
   if ([argsObj count] == 1) res = [self objcp_mk_type:ctx withType:type withSize:[a0 intValue]];
   else if ([argsObj count] == 2 && type == OR_FLOAT) {
      unsigned int e,m;
      e = [argsObj[0] intValue];
      m = [argsObj[1] intValue];
      res = [self objcp_mk_float_type:ctx e:e m:m];
   }
   [argsObj release];
   return res;
}
-(objcp_type) objcp_mk_float_type:(objcp_context)ctx e:(unsigned int)e m:(unsigned int)m
{
   objcp_var_type type = OR_DOUBLE;
   if(e == 8 || m == 24)
      type = OR_FLOAT;
   return [self objcp_mk_type:ctx withType:type];
}
-(objcp_type) objcp_mk_bitvector_type:(objcp_context)ctx withSize:(unsigned int) size
{
   return [self objcp_mk_type:ctx withType:OR_BV withSize:size];
}
-(objcp_type) objcp_mk_type:(objcp_context)ctx withType:(objcp_var_type) type withSize:(unsigned int) size
{
   NSString* nameString =[[NSString alloc] initWithUTF8String:"unnamed"];
   OBJCPType* t = [[OBJCPType alloc] initExplicitWithName:nameString withType:type andSize:size];
   [_types setObject:t forKey:(void*)t];
   return (void*)t;
}
-(objcp_type) objcp_mk_function_type:(objcp_context)ctx withDom:(objcp_type*)domain withDomSize:(unsigned long) size andRange:(objcp_type) range
{
   NSLog(@"Make function type not implemented");
   return NULL;
}

/**
  [hzi] it is needed ???
 \brief Create a backtracking point in the given logical context.
 
 The logical context can be viewed as a stack of contexts.
 The scope level is the number of elements on this stack. The stack
 of contexts is simulated using trail (undo) stacks.
 */
-(void) objcp_push:(objcp_context) ctx{
   NSLog(@"Push context not implemented");
}

/**
 [hzi] it is needed ???
 \brief Backtrack.
 
 Restores the context from the top of the stack, and pops it off the
 stack.  Any changes to the logical context (by #yices_assert or
 other functions) between the matching #yices_push and #yices_pop
 operators are flushed, and the context is completely restored to
 what it was right before the #yices_push.
 */
-(void) objcp_pop:(objcp_context) ctx{
   NSLog(@"Pop context not implemented");
}

-(void) objcp_assert:(objcp_context) ctx withExpr:(objcp_expr) expr
{
   id<ORIntVar> trueVar = [ORFactory intVar:_model value:1];
   [_model add:[(id<ORExpr>)expr eq:trueVar]];
}
-(ORBool) objcp_check:(objcp_context) ctx
{
   @autoreleasepool {
//      printf("model : %s",[[NSString stringWithFormat:@"%@",_model] UTF8String]);
      NSLog(@"%@",_model);
      id<LogicHandler> lh = [OBJCPGateway logicToHandler:_logic withModel:_model withOptions:_options];
      [_options measure:^struct ORResult(){
         id<CPProgram> cp = [lh getProgram];
         __block bool found = false;
         [cp solveOn:^(id<CPCommonProgram> p) {
            [lh launchHeuristic];
            NSLog(@"Valeurs solutions : \n");
            [lh printSolutions];
         } withTimeLimit:[_options timeOut]];
         struct ORResult r = REPORT(found, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         return r;
      }];
   }
   return true;
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

-(ORUInt) objcp_get_unsat_core:(objcp_context) ctx withId:(assertion_id*)a{
   NSLog(@"Get unsat core size not implemented");
   return 0;
}
-(ORUInt) objcp_get_unsat_core_size:(objcp_context) ctx{
   NSLog(@"Get unsat core size not implemented");
   return 0;
}

-(objcp_expr) objcp_mk_app:(objcp_context)ctx withFun:(objcp_expr)f withArgs:(objcp_expr*)arg andNumArgs:(ORULong)n
{
   NSLog(@"Make bitvector not implemented");
   return NULL;
}

-(objcp_expr) objcp_mk_constant:(objcp_context)ctx fromString:(const char*) rep width:(ORUInt) width base:(ORUInt)base
{
   return [[ConstantWrapper alloc] init:rep width:width base:base];
}
-(id<ORVar>) getVariable:(objcp_expr)e
{
   if([(id)e isKindOfClass:[ConstantWrapper class]])
      return (id<ORVar>)[(ConstantWrapper*)e makeVariable];
   return  (id<ORVar>)e;
}
@end

@implementation OBJCPGateway (Int)
-(id<ORExpr>) objcp_mk_eq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   if([(id)left isKindOfClass:[ConstantWrapper class]] && [(id)right isKindOfClass:[ConstantWrapper class]])
      return [ORFactory intVar:_model value:([(ConstantWrapper*)left isEqual: (ConstantWrapper*)right])];
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   if([lv.class conformsToProtocol:@protocol(ORVar)] && [rv.class conformsToProtocol:@protocol(ORVar)]){
      if(getId(rv) == getId(lv)) return [ORFactory intVar:_model value:1];
      if([lv vtype] == ORTBit && [rv vtype] == ORTBit)
         return [self objcp_mk_bv_eq:ctx left:lv right:rv];
      if([lv vtype] == ORTFloat || [lv vtype] == ORTDouble)
         return [self objcp_mk_fp:ctx x:lv eq:rv];
      id<ORIntVar> lvi = (id<ORIntVar>) lv;
      id<ORIntVar> rvi = (id<ORIntVar>) rv;
      if([lvi low] == [lvi up] && [rvi low] == [rvi up] && [lvi low] == [rvi low])
         return [ORFactory intVar:_model value:1];
   }
//   id<ORIntVar> res = [ORFactory boolVar:_model];
//   [_model add:[ORFactory reify:_model boolean:res with:lvi eq:rvi]];
   return [lv eq:rv];
}
-(id<ORIntVar>) objcp_mk_minus:(objcp_context)ctx var:(objcp_expr)var
{
   id<ORIntVar> v = (id<ORIntVar>)[self getVariable:var];
   id<ORIntVar> res = [ORFactory intVar:_model domain:RANGE(_model, -v.up, -v.low)];
   [_model add:[res eq:[v minus]]];
   return res;
}
-(id<ORExpr>) objcp_mk_plus:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
//   id<ORIntVar> res = [ORFactory intVar:_model bounds:RANGE(_model,-MAXINT,MAXINT)];
//   [_model add:[[lv plus:rv] eq:res]];
   return [lv plus:rv];
}
-(id<ORExpr>) objcp_mk_sub:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
//   id<ORIntVar> res = [ORFactory intVar:_model bounds:RANGE(_model,-MAXINT,MAXINT)];
//   [_model add:[[lv sub:rv] eq:res]];
   return [lv sub:rv];
}
-(id<ORExpr>) objcp_mk_times:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
//   id<ORIntVar> lv = (id<ORIntVar>)[self getVariable:left];
//   id<ORIntVar> rv = (id<ORIntVar>)[self getVariable:right];
//   id<ORIntVar> res = [ORFactory intVar:_model bounds:RANGE(_model,-MAXINT,MAXINT)];
//   [_model add:[[lv mul:rv] eq:res]];
   return [lv mul:rv];
}
-(id<ORExpr>) objcp_mk_div:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
//   id<ORIntVar> lv = (id<ORIntVar>)[self getVariable:left];
//   id<ORIntVar> rv = (id<ORIntVar>)[self getVariable:right];
//   id<ORIntVar> res = [ORFactory intVar:_model bounds:RANGE(_model,-MAXINT,MAXINT)];
//   [_model add:[[lv div:rv] eq:res]];
   return [lv div:rv];
}
-(id<ORExpr>) objcp_mk_geq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
//   id<ORIntVar> lv = (id<ORIntVar>)[self getVariable:left];
//   id<ORIntVar> rv = (id<ORIntVar>)[self getVariable:right];
//   id<ORIntVar> res = [ORFactory boolVar:_model];
//   [_model add:[ORFactory reify:_model boolean:res with:lv geq:rv]];
   return [lv geq:rv];
}
-(id<ORExpr>) objcp_mk_leq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
//   id<ORIntVar> lv = (id<ORIntVar>)[self getVariable:left];
//   id<ORIntVar> rv = (id<ORIntVar>)[self getVariable:right];
//   id<ORIntVar> res = [ORFactory boolVar:_model];
//   [_model add:[ORFactory reify:_model boolean:res with:lv leq:rv]];
   return [lv leq:rv];
}
-(id<ORExpr>) objcp_mk_gt:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
//   id<ORIntVar> lv = (id<ORIntVar>)[self getVariable:left];
//   id<ORIntVar> rv = (id<ORIntVar>)[self getVariable:right];
//   id<ORIntVar> res = [ORFactory boolVar:_model];
//   id<ORIntVar> nextr = [ORFactory intVar:_model bounds:RANGE(_model, lv.low + 1, rv.up + 1)];
//   [_model add:[nextr eq:[rv plus:@(1)]]];
//   [_model add:[ORFactory reify:_model boolean:res with:lv geq:nextr]];
   return [lv gt:rv];
}
-(id<ORExpr>) objcp_mk_lt:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
//   id<ORIntVar> lv = (id<ORIntVar>)[self getVariable:left];
//   id<ORIntVar> rv = (id<ORIntVar>)[self getVariable:right];
//   id<ORIntVar> res = [ORFactory boolVar:_model];
//   id<ORIntVar> nextl = [ORFactory intVar:_model bounds:RANGE(_model, lv.low + 1, lv.up + 1)];
//   [_model add:[nextl eq:[lv plus:@(1)]]];
//   [_model add:[ORFactory reify:_model boolean:res with:nextl leq:rv]];
   return [lv lt:rv];
}
@end

@implementation OBJCPGateway (Bool)

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
//   if([b0 low] && [b1 low])
//      return [ORFactory intVar:_model value:1];
//   if([b0 low]) return b1;
//   if([b1 low]) return b0;
//      id<ORIntVar> res;
//   if(![b0 up] || ![b1 up])
//      res = [ORFactory intVar:_model value:0];
//   else
//      res = [ORFactory boolVar:_model];
//   id<ORIntVarArray> bvar = [ORFactory intVarArray:_model range:RANGE(_model,0,1)];
//   bvar[0] = b0;
//   bvar[1] = b1;
//   [_model add:[[b0 land:b1] eq:res]];
//   return res;
   return [b0 land:b1];
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
//   id<ORIntVar> res;
//   if([b0 low] || [b1 low])
//      res = [ORFactory intVar:_model value:1];
//   else if(![b0 up] && ![b1 up])
//      res = [ORFactory intVar:_model value:0];
//   else
//      res = [ORFactory boolVar:_model];
//   id<ORIntVarArray> bvar = [ORFactory intVarArray:_model range:RANGE(_model,0,1)];
//   bvar[0] = b0;
//   bvar[1] = b1;
//   [_model add:[[b0 lor:b1] eq:res]];
//   return res;
   return [b0 lor:b1];
}

-(objcp_expr) objcp_mk_not:(objcp_context)ctx expr:(id<ORExpr>)b0
{
   if([b0.class conformsToProtocol:@protocol(ORIntVar)]){
         if([(id<ORIntVar>)b0 low]) return [ORFactory intVar:_model value:1];
         if(![(id<ORIntVar>)b0 up]) return [ORFactory intVar:_model value:0];
   }
//   if([b0 low]) return [ORFactory intVar:_model value:0];
//   if(![b0 up]) return [ORFactory intVar:_model value:1];
//   id<ORIntVar> res = [ORFactory boolVar:_model];
//   [_model add:[[b0 neg] eq:res]];
//   return res;
   return [b0 neg];
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

//   id<ORIntVar> res;
//   if(![b0 up] || [b1 low])
//      res = [ORFactory intVar:_model value:1];
//   else if([b0 low] && ![b1 up])
//      res = [ORFactory intVar:_model value:0];
//   else
//      res = [ORFactory boolVar:_model];
//   [_model add:[[b0 imply:b1] eq:res]];
//   return res;
   return [b0 imply:b1];
}
@end


@implementation OBJCPGateway (BV)

-(objcp_context) objcp_mk_bv_eq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
//   if([(id<ORBitVar>)left low] == [(id<ORBitVar>)left up] && [(id<ORBitVar>)right low] == [(id<ORBitVar>)right up]){
//      if([(id<ORBitVar>)left low] == [(id<ORBitVar>)right low]) return [ORFactory intVar:_model value:1];
//      if([(id<ORBitVar>)left low] != [(id<ORBitVar>)right low]) return [ORFactory intVar:_model value:0];
//   }
   ORUInt low = 0;   ORUInt up = 1;
   id<ORBitVar> bv = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   [_model add:[ORFactory bit:(id<ORBitVar>)left EQ:(id<ORBitVar>)right eval:(id<ORBitVar>)bv]];
   id<ORIntVar> res = [ORFactory boolVar:_model];
   [_model add:[ORFactory bit:bv booleq:res]];
   return res;
}

-(objcp_expr) objcp_mk_bv_constant_from_array:(objcp_context) ctx withSize:(ORUInt)size fromArray:(ORUInt*)bv
{
   ORUInt wordLength = size/BITSPERWORD + ((size % BITSPERWORD ==0) ? 0 : 1);
   ORUInt* pattern = alloca(sizeof(ORUInt)*wordLength);
   for (int i = 0; i<wordLength; i++)
      pattern[i] = 0;
   
   for (int i=0; i<size; i++) {
      pattern[wordLength-(i/BITSPERWORD)-1] |= bv[i] << i%BITSPERWORD;
   }
   id<ORBitVar> bitv = [ORFactory bitVar:_model low:pattern up:pattern bitLength:size];
   return bitv;
}


-(objcp_expr) objcp_mk_bv_constant:(objcp_context)ctx fromConstant:(ConstantWrapper*) c
{
   id<ORBitVar> ret = nil;
   if (c->_width != 0) {
      mpz_t tmp;
      int i;
      unsigned int *bits = malloc(sizeof(int) * c->_width);
      mpz_init(tmp);
      mpz_set_str(tmp, [c->_strv UTF8String], c->_base);
      for (i = 0; i < c->_width; ++i) {
         bits[i] = mpz_tstbit(tmp, i);
      }
      mpz_clear(tmp);
      ret = [self objcp_mk_bv_constant_from_array:ctx withSize:c->_width fromArray:bits];
      free(bits);
   }
   return ret;
}

-(objcp_expr) objcp_mk_true:(objcp_context)ctx
{
   return [ORFactory intVar:_model value:1];
}

-(objcp_expr) objcp_mk_false:(objcp_context)ctx
{
   return [ORFactory intVar:_model value:0];
}

//name it's not correct
-(objcp_expr) objcp_mk_and:(objcp_context)ctx withArgs:(objcp_expr *)args andNumArgs:(ORULong)numArgs
{
   ORUInt* zero = alloca(sizeof(ORUInt));
   ORUInt* one = alloca(sizeof(ORUInt));
   
   *zero = 0;
   *one = 1;
   
   id<ORBitVar> result = [ORFactory bitVar:_model low:zero up:one bitLength:1];
   id<ORIntRange> range = [ORFactory intRange:_model low:0 up:(ORUInt)numArgs-1];
   id<ORBitVarArray> arguments = [ORFactory bitVarArray:_model range:range];
   for (int i = 0; i<numArgs; i++)
      arguments[i] = args[i];
   [_model add:[ORFactory bit:arguments logicalAndEval:result]];
   
   return result;
}

-(objcp_expr) objcp_mk_le:(objcp_context)ctx x:(objcp_expr)x le:(objcp_expr) y{ return NULL;}
-(objcp_expr) objcp_mk_lt:(objcp_context)ctx x:(objcp_expr)x lt:(objcp_expr) y
{
   ORUInt* low = alloca(sizeof(ORUInt));
   ORUInt* up = alloca(sizeof(ORUInt));
   *low = 0;
   *up = 0x00000001;
   
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:1];
   
   [_model add:[ORFactory bit:(id<ORBitVar>)x LT:(id<ORBitVar>)y eval:(id<ORBitVar>)bv]];
   return bv;
}
-(objcp_expr) objcp_mk_bv_ge:(objcp_context)ctx x:(objcp_expr)x ge:(objcp_expr) y{
    return [self objcp_mk_bv_lt:ctx x:y lt:x];
}
-(objcp_expr) objcp_mk_bv_gt:(objcp_context)ctx x:(objcp_expr)x gt:(objcp_expr) y{
    return [self objcp_mk_bv_le:ctx x:y le:x];

}
-(objcp_expr) objcp_mk_bv_sge:(objcp_context)ctx x:(objcp_expr)x sge:(objcp_expr) y{
    return [self objcp_mk_bv_slt:ctx x:y slt:x];
}
-(objcp_expr) objcp_mk_bv_sgt:(objcp_context)ctx x:(objcp_expr)x sgt:(objcp_expr) y{
    return [self objcp_mk_bv_sle:ctx x:y sle:x];
    
}
/**
 \brief Return an expression representing <tt>(if c t e)</tt>.
 */
-(objcp_expr) objcp_mk_ite:(objcp_context)ctx if:(objcp_expr)c then:(objcp_expr) t else:(objcp_expr)e
{
//   id<ORIntVar> b = [self getVariable:c];
   id<ORVar> tv = [self getVariable:t];
   id<ORVar> ev = [self getVariable:e];
   id<ORExpr> res = nil;
//   if([b low] == [b up])
//      return ([b low]) ? t : e;
   if([tv.class conformsToProtocol:@protocol(ORIntVar)] && [ev.class conformsToProtocol:@protocol(ORIntVar)]){
      res = [ORFactory intVar:_model bounds:RANGE(_model, min([(id<ORIntVar>)t low],[(id<ORIntVar>)e low]),max([(id<ORIntVar>)t up], [(id<ORIntVar>)e up]))];
   }else if([tv.class conformsToProtocol:@protocol(ORFloatVar)] && [ev.class conformsToProtocol:@protocol(ORFloatVar)]){
      res = [ORFactory floatVar:_model low:minFlt([(id<ORFloatVar>)t low],[(id<ORFloatVar>)e low]) up:maxFlt([(id<ORFloatVar>)t up],[(id<ORFloatVar>)e up])];
   }else if([tv.class conformsToProtocol:@protocol(ORDoubleVar)] && [ev.class conformsToProtocol:@protocol(ORDoubleVar)]){
      res = [ORFactory doubleVar:_model low:minDbl([(id<ORDoubleVar>)t low],[(id<ORDoubleVar>)e low]) up:maxDbl([(id<ORDoubleVar>)t up],[(id<ORDoubleVar>)e up])];
   }else if([tv.class conformsToProtocol:@protocol(ORBitVar)]){
         res = [ORFactory bitVar:_model withLength:max([(id<ORBitVar>)tv bitLength],[(id<ORBitVar>)ev bitLength])];
         id<ORBitVar> bv = [ORFactory bitVar:_model withLength:1];
         if([((id<ORExpr>)c).class conformsToProtocol:@protocol(ORIntVar)])
            [_model add:[ORFactory bit:bv booleq:(id<ORIntVar>)c]];
         else {//complex expr
            id<ORIntVar> b = [ORFactory intVar:_model domain:RANGE(_model,0,1)];
            [_model add:[b eq:c]];
            [_model add:[ORFactory bit:bv booleq:(id<ORIntVar>)b]];
         }
         [_model add:[ORFactory bit:bv then:(id<ORBitVar>)tv else:(id<ORBitVar>)ev result:(id<ORBitVar>)res]];
         return res;
      }
   
   [_model add:[(id<ORExpr>)c imply:[res eq:tv]]];
   [_model add:[[(id<ORExpr>)c neg] imply:[res eq:ev]]];
   return res;
}

//objcp_mk_num_from_string
-(objcp_expr) objcp_mk_diseq:(objcp_context)ctx var:(objcp_expr)arg1 neq:(objcp_expr)arg2{
   ORUInt* low = alloca(sizeof(ORUInt));
   ORUInt* up = alloca(sizeof(ORUInt));
   *low = 0;
   *up = 0x00000001;
   
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:1];
   id<ORBitVar> areEqual = [ORFactory bitVar:_model low:low up:up bitLength:1];
   [_model add:[ORFactory bit:(id<ORBitVar>)arg1 equalb:(id<ORBitVar>)arg2 eval:areEqual]];
   [_model add:[ORFactory bit:areEqual notb:bv]];
   return bv;
}
-(objcp_expr) objcp_mk_bv_concat:(objcp_context)ctx withArg:(objcp_expr)arg1 andArg:(objcp_context)arg2{
   int xSize = [(id<ORBitVar>)arg1 bitLength];
   int ySize = [(id<ORBitVar>)arg2 bitLength];
   int size = xSize + ySize;
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
//      if (i == (wordlength-1)) {
       if (i == 0) {
         up[i] >>= BITSPERWORD - (size % BITSPERWORD);
      }
   }
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:(id<ORBitVar>)arg1 concat:(id<ORBitVar>)arg2 eq:bv]];
   return bv;
}

-(objcp_expr) objcp_mk_bv_not:(objcp_context) ctx withArg:(objcp_expr) a1
{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:(id<ORBitVar>)a1 bnot:bv]];
   return bv;
}

-(objcp_expr) objcp_mk_bv_and:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);

   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:(id<ORBitVar>)a1 band:(id<ORBitVar>)a2 eq:bv]];
   return bv;
}

-(objcp_expr) objcp_mk_bv_or:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);

   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[_model add:[ORFactory bit:(id<ORBitVar>)a1 bor:(id<ORBitVar>)a2 eq:bv]]];
   return bv;
}

-(objcp_expr) objcp_mk_bv_xor:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);

   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:(id<ORBitVar>)a1 bxor:(id<ORBitVar>)a2 eq:bv]];
   return bv;
}

-(objcp_expr) objcp_mk_bv_lt:(objcp_context)ctx x:(objcp_expr)x lt:(objcp_expr) y{
   ORUInt low = 0;   ORUInt up = 1;
   id<ORBitVar> bv = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   [_model add:[ORFactory bit:(id<ORBitVar>)x LT:y eval:bv]];
   id<ORIntVar> res = [ORFactory boolVar:_model];
   [_model add:[ORFactory bit:bv booleq:res]];
   return res;
}
-(objcp_expr) objcp_mk_bv_le:(objcp_context)ctx x:(objcp_expr)x le:(objcp_expr) y
{
   ORUInt low = 0;   ORUInt up = 1;
   id<ORBitVar> bv = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   [_model add:[ORFactory bit:(id<ORBitVar>)x LE:(id<ORBitVar>)y eval:(id<ORBitVar>)bv]];
   id<ORIntVar> res = [ORFactory boolVar:_model];
   [_model add:[ORFactory bit:bv booleq:res]];
   return res;
}

-(objcp_expr) objcp_mk_bv_shl:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[wordlength-1] >>= BITSPERWORD-(size%BITSPERWORD);

   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:(id<ORBitVar>)a1 shiftLByBV:(id<ORBitVar>)a2 eq:bv]];
   return bv;
}
-(objcp_expr) objcp_mk_bv_shrl:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
    up[wordlength-1] >>= BITSPERWORD-(size%BITSPERWORD);

   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:(id<ORBitVar>)a1 shiftRByBV:(id<ORBitVar>)a2 eq:bv]];
   return bv;
}
-(objcp_expr) objcp_mk_bv_shra:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
    up[wordlength-1] >>= BITSPERWORD-(size%BITSPERWORD);

   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:(id<ORBitVar>)a1 shiftRAByBV:(id<ORBitVar>)a2 eq:bv]];
   return bv;
}
-(objcp_expr) objcp_mk_bv_sle:(objcp_context)ctx x:(objcp_expr)x sle:(objcp_expr) y{
//   ORUInt low = 0;
//   ORUInt up = 1;
//
//   id<ORBitVar> bv = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
//   [_model add:[ORFactory bit:(id<ORBitVar>)x SLE:(id<ORBitVar>)y eval:(id<ORBitVar>)bv]];
//   return bv;
   int size = [(id<ORBitVar>)x bitLength];

   ORUInt low;
   ORUInt up;
   low = 0;
   up = 0x1;

   id<ORBitVar> bv = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   id<ORBitVar> xSign = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   id<ORBitVar> ySign = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   id<ORBitVar> temp = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   id<ORBitVar> notbv = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   id<ORBitVar> result = [ORFactory bitVar:_model low:&low up:&up bitLength:1];

   [_model add:[ORFactory bit:(id<ORBitVar>)y LT:(id<ORBitVar>)x eval:(id<ORBitVar>)bv]];

   [_model add:[ORFactory bit:(id<ORBitVar>)x from:size-1 to:size-1 eq:xSign]];
   [_model add:[ORFactory bit:(id<ORBitVar>)y from:size-1 to:size-1 eq:ySign]];
   [_model add:[ORFactory bit:(id<ORBitVar>)xSign bxor:ySign eq:temp]];
   [_model add:[ORFactory bit:(id<ORBitVar>)bv notb:notbv]];
   [_model add:[ORFactory bit:(id<ORBitVar>)temp bxor:notbv eq:result]];

   return result;
}

-(objcp_expr) objcp_mk_bv_slt:(objcp_context)ctx x:(objcp_expr)x slt:(objcp_expr) y{
   int size = [(id<ORBitVar>)x bitLength];
   ORUInt low;
   ORUInt up;
   low = 0;
   up = 0x1;

   id<ORBitVar> bv = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   id<ORBitVar> xSign = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   id<ORBitVar> ySign = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   id<ORBitVar> temp = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   id<ORBitVar> notbv = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   id<ORBitVar> result = [ORFactory bitVar:_model low:&low up:&up bitLength:1];



   [_model add:[ORFactory bit:(id<ORBitVar>)y LE:(id<ORBitVar>)x eval:(id<ORBitVar>)bv]];

   [_model add:[ORFactory bit:(id<ORBitVar>)x from:size-1 to:size-1 eq:xSign]];
   [_model add:[ORFactory bit:(id<ORBitVar>)y from:size-1 to:size-1 eq:ySign]];
   [_model add:[ORFactory bit:(id<ORBitVar>)xSign bxor:ySign eq:temp]];
   [_model add:[ORFactory bit:(id<ORBitVar>)bv notb:notbv]];
   [_model add:[ORFactory bit:(id<ORBitVar>)temp bxor:notbv eq:result]];

   return result;
}

-(objcp_expr) objcp_mk_bv_constant:(objcp_context) ctx withSize:(ORUInt)size andValue:(ORUInt)value
{
   id<ORBitVar> bitv = [ORFactory bitVar:_model low:&value up:&value bitLength:size];
   return bitv;
}

-(objcp_expr) objcp_mk_bv_minus:(objcp_context) ctx withArg:(objcp_expr) a1{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);

   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:(id<ORBitVar>)a1 negative:bv]];
   return bv;
}

-(objcp_expr) objcp_mk_bv_add:(objcp_context) ctx withArg:(objcp_expr) lv andArg:(objcp_expr)rv
{
   id<ORBitVar> a1 = (id<ORBitVar>)[self getVariable:lv];
   id<ORBitVar> a2 = (id<ORBitVar>)[self getVariable:rv];
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* cinUp = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      cinUp[i] = up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0){
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);
      cinUp[0] >>= BITSPERWORD-(size%BITSPERWORD);
   }
   
   id<ORBitVar> bv;
   id<ORBitVar> cin;
   id<ORBitVar> cout;
      bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
      cin = [ORFactory bitVar:_model low:low up:cinUp bitLength:size];
      cout = [ORFactory bitVar:_model low:low up:up bitLength:size];
      [_model add:[ORFactory bit:(id<ORBitVar>)a1 plus:a2 withCarryIn:cin eq:bv withCarryOut:cout]];

   return bv;
}

-(objcp_expr) objcp_mk_bv_sub:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD == 0) ? 0: 1);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   id<ORBitVar> bv;
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);
      bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
      [_model add:[ORFactory bit:a1 minus:a2 eq:bv]];
   return bv;
}

-(objcp_expr) objcp_mk_bv_mul:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   ORUInt zWordlength = ((size * 2)/ BITSPERWORD) + (((size * 2) % BITSPERWORD == 0) ? 0: 1);
   ORUInt* low = alloca(sizeof(ORUInt)*zWordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*zWordlength);
   for(int i=0; i< zWordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);
   id<ORBitVar> result;
   id<ORBitVar> bv;

   result = [ORFactory bitVar:_model low:low up:up bitLength:(size*2)];
   bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:a1 times:a2 eq:result]];
   [_model add:[ORFactory bit:result from:0 to:size-1 eq:bv]];

   return bv;
}

-(objcp_expr) objcp_mk_bv_div:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD == 0) ? 0: 1);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);
   id<ORBitVar> q;
   id<ORBitVar> r;
   
   q = [ORFactory bitVar:_model low:low up:up bitLength:size];
   r = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:a1 dividedby:a2 eq:q rem:r]];
   
   return q;
}

-(objcp_expr) objcp_mk_bv_sdiv:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
    int size = [(id<ORBitVar>)a1 bitLength];
    
    ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD == 0) ? 0: 1);
    ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
    ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
    for(int i=0; i< wordlength;i++){
        low[i] = 0;
        up[i] = CP_UMASK;
    }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);
    id<ORBitVar> q;
    id<ORBitVar> r;

    q = [ORFactory bitVar:_model low:low up:up bitLength:size];
    r = [ORFactory bitVar:_model low:low up:up bitLength:size];

    [_model add:[ORFactory bit:a1 dividedbysigned:a2 eq:q rem:r]];
    return q;
}

-(objcp_expr) objcp_mk_bv_rem:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD == 0) ? 0: 1);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);
   id<ORBitVar> q;
   id<ORBitVar> r;
   
   q = [ORFactory bitVar:_model low:low up:up bitLength:size];
   r = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:a1 dividedby:a2 eq:q rem:r]];
   
   return r;
}

-(objcp_expr) objcp_mk_bv_srem:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
    int size = [(id<ORBitVar>)a1 bitLength];
    
    ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD == 0) ? 0: 1);
    ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
    ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
    for(int i=0; i< wordlength;i++){
        low[i] = 0;
        up[i] = CP_UMASK;
    }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);
    id<ORBitVar> q;
    id<ORBitVar> r;
    
    q = [ORFactory bitVar:_model low:low up:up bitLength:size];
    r = [ORFactory bitVar:_model low:low up:up bitLength:size];
    [_model add:[ORFactory bit:a1 dividedbysigned:a2 eq:q rem:r]];
    
    return r;
}

-(objcp_expr) objcp_mk_bv_extract:(objcp_context)ctx from:(ORUInt)msb downTo:(ORUInt)lsb in:(objcp_expr)bv{
   ORUInt size = msb - lsb + 1;
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);

   id<ORBitVar> bv2 = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:bv from:lsb to:msb eq:bv2]];
   return bv2;
}

-(objcp_expr) objcp_mk_bv_rotl:(objcp_context) ctx withArg:(objcp_expr) a1 andAmount:(ORUInt)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);

   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
  [_model add:[ORFactory bit:(id<ORBitVar>)a1 rotateLBy:(ORUInt)a2 eq:bv]];
   return bv;
}

-(objcp_expr) objcp_mk_bv_rotr:(objcp_context) ctx withArg:(objcp_expr) a1 andAmount:(ORUInt)amt{
   return NULL;
}

-(objcp_expr) objcp_mk_bv_zero_extend:(objcp_context)ctx withArg:(objcp_expr)arg1 andAmount:(ORUInt)amt{
   int size = [(id<ORBitVar>)arg1 bitLength] + amt;
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if(size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);

   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:(id<ORBitVar>)arg1 zeroExtendTo:(id<ORBitVar>)bv]];
   return bv;
}

-(objcp_expr) objcp_mk_bv_sign_extend:(objcp_context)ctx withArg:(objcp_expr)arg1 andAmount:(ORUInt)amt{
   int size = [(id<ORBitVar>)arg1 bitLength] + amt;
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
   for(int i=0; i< wordlength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
   if (size%BITSPERWORD != 0)
      up[0] >>= BITSPERWORD-(size%BITSPERWORD);
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
   [_model add:[ORFactory bit:(id<ORBitVar>)arg1 signExtendTo:(id<ORBitVar>)bv]];
   return bv;
}

@end

@implementation OBJCPGateway (ORFloat)
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x eq:(id<ORExpr>)y
{
//   id<ORIntVar> bv = [ORFactory boolVar:_model];
//   if([(id)x conformsToProtocol:@protocol(ORFloatVar)]){
//      [_model add:[ORFactory floatReify:_model boolean:bv with:(id<ORFloatVar>)x eq:(id<ORFloatVar>)y]];
//   }else if([(id)x conformsToProtocol:@protocol(ORDoubleVar)]){
//      [_model add:[ORFactory doubleReify:_model boolean:bv with:(id<ORDoubleVar>)x eq:(id<ORDoubleVar>)y]];
//   }else{//expr
//      [_model add:[bv eq:[(id<ORExpr>)x eq:(id<ORExpr>)y]]];
//   }
   return [x eq:y];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x lt:(id<ORExpr>)y
{
//   id<ORIntVar> bv = [ORFactory boolVar:_model];
//   if([(id)x conformsToProtocol:@protocol(ORFloatVar)]){
//      [_model add:[ORFactory floatReify:_model boolean:bv with:(id<ORFloatVar>)x lt:(id<ORFloatVar>)y]];
//   }else if([(id)x conformsToProtocol:@protocol(ORDoubleVar)]){
//      [_model add:[ORFactory doubleReify:_model boolean:bv with:(id<ORDoubleVar>)x lt:(id<ORDoubleVar>)y]];
//   }else{
//      [_model add:[bv eq:[(id<ORExpr>)x lt:(id<ORExpr>)y]]];
//   }
   return [x lt:y];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x gt:(id<ORExpr>)y
{
//   id<ORIntVar> bv = [ORFactory boolVar:_model];
//   if([(id)x conformsToProtocol:@protocol(ORFloatVar)]){
//      [_model add:[ORFactory floatReify:_model boolean:bv with:(id<ORFloatVar>)x gt:(id<ORFloatVar>)y]];
//   }else if([(id)x conformsToProtocol:@protocol(ORDoubleVar)]){
//      [_model add:[ORFactory doubleReify:_model boolean:bv with:(id<ORDoubleVar>)x gt:(id<ORDoubleVar>)y]];
//   }else{
//      [_model add:[bv eq:[(id<ORExpr>)x gt:(id<ORExpr>)y]]];
//   }
   return [x gt:y];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x leq:(id<ORExpr>)y
{
//   id<ORIntVar> bv = [ORFactory boolVar:_model];
//   if([(id)x conformsToProtocol:@protocol(ORFloatVar)]){
//      [_model add:[ORFactory floatReify:_model boolean:bv with:(id<ORFloatVar>)x leq:(id<ORFloatVar>)y]];
//   }else if([(id)x conformsToProtocol:@protocol(ORDoubleVar)]){
//      [_model add:[ORFactory doubleReify:_model boolean:bv with:(id<ORDoubleVar>)x leq:(id<ORDoubleVar>)y]];
//   }else{
//      [_model add:[bv eq:[(id<ORExpr>)x leq:(id<ORExpr>)y]]];
//   }
   return [x leq:y];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x geq:(id<ORExpr>)y
{
//   id<ORIntVar> bv = [ORFactory boolVar:_model];
//   if([(id)x conformsToProtocol:@protocol(ORFloatVar)]){
//      [_model add:[ORFactory floatReify:_model boolean:bv with:(id<ORFloatVar>)x geq:(id<ORFloatVar>)y]];
//   }else if([(id)x conformsToProtocol:@protocol(ORDoubleVar)]){
//      [_model add:[ORFactory doubleReify:_model boolean:bv with:(id<ORDoubleVar>)x geq:(id<ORDoubleVar>)y]];
//   }else{
//      [_model add:[bv eq:[(id<ORExpr>)x geq:(id<ORExpr>)y]]];
//   }
   return [x geq:y];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx neg:(id<ORExpr>)x
{
//   id<ORFloatVar> fpx = (id<ORFloatVar>) x;
//   id<ORFloatVar> res = [ORFactory floatVar:_model]; //should make minus double constraint
//   [_model add:[res eq:[fpx minus]]];
   return [x minus];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x add:(id<ORExpr>)y
{
//   id<ORExpr> res;
//   if([(id)x conformsToProtocol:@protocol(ORFloatVar)]){
//      res = [ORFactory floatVar:_model];
//   }else{//we must be ordoublevar in this branch
//      res = [ORFactory doubleVar:_model];
//   }
//   [_model add:[res eq:[x plus:y]]];
//   return res;
   return [x plus:y];
}

-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x sub:(id<ORExpr>)y
{
//   id<ORExpr> res;
//   if([(id)x conformsToProtocol:@protocol(ORFloatVar)]){
//      res = [ORFactory floatVar:_model];
//   }else{//we must be ordoublevar in this branch
//      res = [ORFactory doubleVar:_model];
//   }
//   [_model add:[res eq:[x sub:y]]];
//   return res;
   return [x sub:y];
}

-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x mul:(id<ORExpr>)y
{
//   id<ORExpr> res;
//   if([(id)x conformsToProtocol:@protocol(ORFloatVar)]){
//      res = [ORFactory floatVar:_model];
//   }else{//we must be ordoublevar in this branch
//      res = [ORFactory doubleVar:_model];
//   }
//   [_model add:[res eq:[x mul:y]]];
//   return res;
   return [x mul:y];
}

-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x div:(id<ORExpr>)y
{
//   id<ORExpr> res;
//   if([(id)x conformsToProtocol:@protocol(ORFloatVar)]){
//      res = [ORFactory floatVar:_model];
//   }else{//we must be ordoublevar in this branch
//      res = [ORFactory doubleVar:_model];
//   }
//   [_model add:[res eq:[x div:y]]];
//   return res;
   return [x div:y];
}

#warning [hzi] we should define constant for exp width and mantissa
-(ConstantWrapper*) objcp_mk_fp_constant:(objcp_expr)ctx s:(ConstantWrapper*)s e:(ConstantWrapper*)e m:(ConstantWrapper*)m
{
   assert((e->_width == 8 && m->_width == 23) || (e->_width == 11 && m->_width == 52));
   if(e->_width == 8 && m->_width == 23){
      float f = floatFromParts([m uintValue],[e uintValue],[s uintValue]);
      NSLog(@"%16.16e",f);
      return [[ConstantWrapper alloc] initWithFloat:f];
   }
   if(e->_width == 11 && m->_width == 52){
      double f = doubleFromParts([m ulongValue],[e uintValue],[s uintValue]);
      NSLog(@"%16.16e",f);
      return [[ConstantWrapper alloc] initWithDouble:f];
   }
   return nil;
}
-(id<ORDoubleVar>) objcp_mk_to_fp:(id<ORFloatVar>)x
{
   id<ORFloatVar> var;
   if([(id)x conformsToProtocol:@protocol(ORFloatVar)]){
      var = (id<ORFloatVar>) x;
   }else{// expr
      var = [ORFactory floatVar:_model];
      [_model add:[var eq:x]];
   }
   id<ORDoubleVar> res = [ORFactory doubleVar:_model low:[var low] up:[var up] name:[NSString stringWithFormat:@"%@D*",([var prettyname] == nil) ? [NSString stringWithFormat:@"var<%d>",getId(var)]:[var prettyname]]];
   if([var low] != [var up]){
      [_model add:[ORFactory doubleCast:_model from:var res:res]];
   }
   return res;
}
@end
