//
//  OBJCPGateway.c
//  Clo
//
//  Created by Greg Johnson on 2/23/14.
//
//

#import "objcpgatewayI.h"
#include "gmp.h"


@protocol OBJCPProxy;

@implementation ConstantWrapper
static id<OBJCPGateway> objcpgw;

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
         if([_strv containsString:@"."]){
            _type = OR_DOUBLE;
            _value.double_nb = atof(strv);
         }else
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
-(void) setType:(objcp_var_type) t
{
   _type = t;
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
+(void) setObjcpGateway:(id<OBJCPGateway>) obj
{
   objcpgw = obj;
}
@end

@implementation OBJCPType
-(OBJCPType*)initExplicit:(NSString*)name withType:(objcp_var_type)type{
   self = [self initExplicitWithName:name withType:type andSize:1];
   return self;
}
-(OBJCPType*)initExplicitWithName:(NSString*)name withType:(objcp_var_type)type andSize:(ORInt)size
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
   _isArg = NO;
   return self;
}
-(OBJCPDecl*)initExplicitWithSize:(NSString*)name withType:(OBJCPType*)type andSize:(ORInt)size isArg:(ORBool)isarg
{
   [self initExplicitWithSize:name withType:type andSize:size];
   _isArg = isarg;
   return self;
}
-(NSString*) description
{
   NSMutableString* string = [NSMutableString stringWithFormat:@"<OBJCPDecl> [name:%@,var:%@]",_name,_var];
   return string;
}
-(NSString*) getName{
   return _name;
}
-(OBJCPType*) getType
{
   return _type;
}
-(ORBool) isArg
{
   return _isArg;
}
-(id<ORExpr>) getVariable
{
   return _var;
}
-(ORUInt) getSize
{
   return _size;
}
-(void) setVar:(id<ORExpr>) var
{
   _var = var;
}
-(id) copyWithZone:(NSZone *)zone
{
   OBJCPDecl* newObject = [[OBJCPDecl alloc] initExplicitWithSize:_name withType:_type andSize:_size];
   return newObject;
}
@end

@implementation OBJCPGatewayI : NSObject
-(OBJCPGatewayI*) initExplicitOBJCPGateway:(ORCmdLineArgs*) opt
{
   self = [super init];
   fesetround(FE_TONEAREST); // force rounding mode (ldm change the rounding mode when he load the real lib)
   _model = [ORFactory createModel];
   _toadd = [[NSMutableArray alloc] init];
   _declarations = [[NSMutableArray alloc] init];
   [_declarations addObject: [[NSMutableDictionary alloc] initWithCapacity:10]];
   _instances = [[NSMutableDictionary alloc] initWithCapacity:10];
   _types = [[NSMutableDictionary alloc] initWithCapacity:10];
   _options = opt;
   [ConstantWrapper setObjcpGateway:(id<OBJCPGateway>)self];
   _trueVar = [ORFactory intVar:_model value:1];
   return self;
}
-(void)dealloc {
   [_toadd removeAllObjects];
   [_toadd release];
   [_toadd removeAllObjects];
   [_declarations release];
   [_instances release];
  [super dealloc];
}
-(id<ORModel>) getModel
{
   return _model;
}
-(NSMutableDictionary*) getCurrentDeclarations
{
   return [_declarations lastObject];
}
-(objcp_context) objcp_mk_context{
   NSLog(@"Make context not implemented");
   return NULL;
}
-(void) objcp_del_context:(objcp_context) ctxt{
   NSLog(@"delete context not implemented");
}
-(objcp_expr) objcp_mk_app:(objcp_context) ctx expr:(objcp_expr) f args:(objcp_expr*) args num:(unsigned int)n
{
   NSLog(@"Make app not implemented");
   return NULL;
}
-(objcp_var_decl) objcp_mk_var_decl:(objcp_context) ctx withName:(char*) name andType:(objcp_type) type isArg:(ORBool) isarg
{
   NSString* nameString =[[NSString alloc] initWithUTF8String:name];
   OBJCPType* t = (OBJCPType*) type;
   OBJCPDecl* d = [[OBJCPDecl alloc] initExplicitWithSize:nameString withType:type andSize:[t getSize] isArg:isarg];
   [[self getCurrentDeclarations]  setObject:d forKey:nameString];
   return (void*)t;
}
-(objcp_var_decl) objcp_get_var_decl:(objcp_context) ctx withExpr:(objcp_expr)t{
   NSLog(@"Get variable declaration not implemented");
   return NULL;
}
-(objcp_var_decl) objcp_get_var_decl_from_name:(objcp_context) ctx withName:(const char*) name
{
   NSString *key = [[[NSString alloc] initWithUTF8String:name] autorelease];
   OBJCPDecl* d = [[self getCurrentDeclarations] objectForKey:key];
   return d;
}
//create or return variable from declaration
-(objcp_expr) objcp_mk_var_from_decl:(objcp_context) ctx withDecl:(objcp_var_decl) d
{
   OBJCPDecl* decl = d;
   NSString* name = [decl getName];
   ORUInt size = [decl getSize];
   objcp_var_type type = [[decl getType] getType];
   objcp_expr res = [decl getVariable];
   ORBool isArg = [decl isArg];
   if(res == nil){
      res = [self objcp_mk_var_from_type:type andName:name andSize:size isArg:isArg];
      [decl setVar:res];
   }
   return res;
}
-(objcp_expr) objcp_handle_function:(objcp_context) ctx withBody:(objcp_expr) e withArgs:(NSArray*)args
{
   ExprCloneAndSubstitue * v = [[[ExprCloneAndSubstitue alloc] initWithValues:args] autorelease];
   [(id<ORExpr>)e visit:v];
   id<ORExpr> rv = [v result];
   [v release];
   return rv;
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

-(objcp_expr) objcp_mk_var_from_type:(objcp_var_type) type andName:(NSString*) name andSize:(ORUInt) size isArg:(ORBool)isarg
{
   objcp_expr res = nil;
   if(isarg){
//      just a trick the index of the variable is the current size of the declaration structure
//      since we push a new declaration "context" before each new function
      res = [[ORExprPlaceHolderI alloc] initORExprPlaceHolderI:(ORInt)([[self getCurrentDeclarations] count] - 1) withTracker:_model];
   }else{
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
   }
   return res;
}
-(void) objcp_set_arith_only:(int) flag
{
   NSLog(@"Set arith only not implemented");
}
-(void) objcp_set_logic:(const char*) logic
{
   _logic = [OBJCPGatewayI logicFromString:logic];
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
   if(e == E_SIZE || m == M_SIZE + 1)
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
//   id<ORIntVar> trueVar = [ORFactory intVar:_model value:1];
//   [_toadd addObject:[(id<ORExpr>)expr eq:trueVar]];
   [_toadd addObject:[(id<ORExpr>)expr eq:_trueVar]];
}
-(void) addConstraints
{
   if([_options is3Bfiltering]){
      NSArray* arr = _toadd;
      id<ORGroup> g = [ORFactory group:_model type:Group3B];
      if([_options variationSearch]){
         arr = [ExprSimplifier simplifyAll:_toadd group:g];
      }
      for(id<ORExpr> e in arr){
         [g add:e];
      }
      [_model add:g];
   }else{
      NSArray* arr = _toadd;
      if([_options variationSearch]){
         arr = [ExprSimplifier simplifyAll:_toadd];
      }
      for(id<ORExpr> e in arr){
         [_model add:e];
      }
   }
}
-(ORBool) objcp_check:(objcp_context) ctx
{
   [self addConstraints];
   @autoreleasepool {
      if([_options printModel]){
         printf("%s\n",[[_model description] UTF8String]);
         fflush(stdout);
      }
      id<LogicHandler> lh ;
      @try {
         lh = [OBJCPGatewayI logicToHandler:_logic withModel:_model withOptions:_options withDeclaration:[self getCurrentDeclarations]];
      } @catch (ORExecutionError *exception) {
         printf("ERROR : %s\n",[exception msg]);
         return NO;
      }
      __block ORBool isSat;
      [_options measure:^struct ORResult(){
         id<CPProgram> cp = [lh getProgram];
         [_options registerStat:@"#Cvars" value:[NSNumber numberWithInt:[[cp engine] nbVars]]];
         [_options registerStat:@"#Ccst" value:[NSNumber numberWithInt:[[cp engine] nbConstraints]]];
         ORBool hascycle = NO;
         if([_options cycleDetection]){
            hascycle = [_options isCycle:_model];
            NSLog(@"%s",(hascycle)?"YES":"NO");
         }
         __block bool found = false;
         isSat = false;
         if(!hascycle){
            id<ORIntArray> locc = [VariableLocalOccCollector collect:[_model constraints] with:[_model variables] tracker:_model];
            [(CPCoreSolver*)cp setLOcc:locc];
            if([_options occDetails]){
               [_options printOccurences:_model with:cp restricted:[lh getVariables]];
//               [_options printMaxGOccurences:_model with:cp n:5];
//               [_options printMaxLOccurences:_model with:cp n:5];
            }
            [cp solveOn:^(id<CPCommonProgram> p) {
               if(![_options noSearch]){
                  [lh launchHeuristic];
               }
               NSLog(@"Valeurs solutions : \n");
               [lh printSolutions];
               NSLog(@"======================");
               isSat = [lh checkAllbound];
            } withTimeLimit:[_options timeOut]];
         }
         struct ORResult r = FULLREPORT(found, [[cp engine] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation],[[cp engine] nbStaticRewrites],[[cp engine] nbDynRewrites],[[_model FPVars] count], [[_model constraints] count],[lh declSize]);
         return r;
      }];
      [lh release];
      return isSat;
   }
}

+(id<LogicHandler>) logicToHandler:(logic) l withModel:(id<ORModel>) model withOptions:(ORCmdLineArgs*) options withDeclaration:(NSMutableDictionary*) decl
{
   switch(l){
      case  QF_BV    : return [[BVLogicHandler alloc] init:model withOptions:options withDeclaration:decl];
      case  QF_LIA     : return [[IntLogicHandler alloc] init:model withOptions:options  withDeclaration:decl];
      case QF_BVFP     :
      case  QF_FP     : return [[FloatLogicHandler alloc] init:model withOptions:options withDeclaration:decl];
      case QF_LRA    : //should return reallogichandler
      default         : return [[AbstractLogicHandler alloc] init:model withOptions:options withDeclaration:decl];
   }
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
-(void) countUsage:(const char*) n
{
   NSString * ns = [NSString stringWithUTF8String:n];
   ORInt cpt = 0;
   id obj = [_exprDeclarations objectForKey:ns];
   if(obj != nil){
      cpt = [obj intValue] + 1;
   }
   [_exprDeclarations setObject:@(cpt) forKey:ns];
   NSLog(@"<%s:%d>",n,cpt);
}
-(objcp_expr) objcp_mk_constant:(objcp_context)ctx fromString:(const char*) rep width:(ORUInt) width base:(ORUInt)base
{
   return [[[ConstantWrapper alloc] init:rep width:width base:base] autorelease];
}
-(id<ORVar>) getVariable:(objcp_expr)e
{
   if([(id)e isKindOfClass:[ConstantWrapper class]])
      return (id<ORVar>)[(ConstantWrapper*)e makeVariable];
   return  (id<ORVar>)e;
}

- (void)objcp_new_scope {
   [_declarations addObject:[[NSMutableDictionary alloc] init]];
}


- (void)objcp_pop_scope {
   [_declarations removeLastObject];
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
         return [self objcp_mk_fp:ctx x:lv assignTo:rv];
      id<ORIntVar> lvi = (id<ORIntVar>) lv;
      id<ORIntVar> rvi = (id<ORIntVar>) rv;
      if([lvi low] == [lvi up] && [rvi low] == [rvi up] && [lvi low] == [rvi low])
         return [ORFactory intVar:_model value:1];
   }
   if([lv vtype] == ORTFloat || [lv vtype] == ORTDouble)
      return [lv set:rv];
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
   return [lv plus:rv];
}
-(id<ORExpr>) objcp_mk_sub:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   return [lv sub:rv];
}
-(id<ORExpr>) objcp_mk_times:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   return [lv mul:rv];
}
-(id<ORExpr>) objcp_mk_div:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   return [lv div:rv];
}
-(id<ORExpr>) objcp_mk_geq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   return [lv geq:rv];
}
-(id<ORExpr>) objcp_mk_leq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   return [lv leq:rv];
}
-(id<ORExpr>) objcp_mk_gt:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   return [lv gt:rv];
}
-(id<ORExpr>) objcp_mk_lt:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
   id<ORExpr> lv = (id<ORExpr>)[self getVariable:left];
   id<ORExpr> rv = (id<ORExpr>)[self getVariable:right];
   return [lv lt:rv];
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
   return [b0 lor:b1];
}

-(objcp_expr) objcp_mk_not:(objcp_context)ctx expr:(id<ORExpr>)b0
{
   if([b0.class conformsToProtocol:@protocol(ORIntVar)]){
      if([(id<ORIntVar>)b0 low]) return [ORFactory intVar:_model value:0];
      if(![(id<ORIntVar>)b0 up]) return [ORFactory intVar:_model value:1];
   }
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
   return [b0 imply:b1];
}
@end


@implementation OBJCPGatewayI (BV)

-(objcp_context) objcp_mk_bv_eq:(objcp_context)ctx left:(objcp_expr)left right:(objcp_expr)right
{
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
   id<ORVar> tv = [self getVariable:t];
   id<ORVar> ev = [self getVariable:e];
   id<ORExpr> res = nil;
   ORVType type = [(id<ORExpr>) t vtype];
   switch(type){
      case ORTFloat:
         res = [ORFactory floatVar:_model];
         break;
      case ORTDouble:
         res = [ORFactory doubleVar:_model];
         break;
      case ORTBool:
         return [[(id<ORExpr>)c imply:t] land:[[(id<ORExpr>)c neg] imply:e]];
      case ORTInt:
         res = [ORFactory intVar:_model];
         break;
      case ORTBit:
      default:
         assert(NO);
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
-(objcp_expr) objcp_mk_bv_sle:(objcp_context)ctx x:(objcp_expr)x sle:(objcp_expr) y
{
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

@implementation OBJCPGatewayI (ORFloat)
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x eq:(id<ORExpr>)y
{
   return [x eq:y];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x assignTo:(id<ORExpr>)y
{
   return [x set:y];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x lt:(id<ORExpr>)y
{
   return [x lt:y];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x gt:(id<ORExpr>)y
{
   return [x gt:y];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x leq:(id<ORExpr>)y
{
   return [x leq:y];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x geq:(id<ORExpr>)y
{
   return [x geq:y];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx neg:(id<ORExpr>)x
{
   return [x minus];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx sqrt:(id<ORExpr>)x
{
   return [x sqrt];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx isZero:(id<ORExpr>)x
{
   return [x isZero];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx isPositive:(id<ORExpr>)x
{
   return [x isPositive];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx isNormal:(id<ORExpr>)x
{
   return [x isNormal];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx isSubnormal:(id<ORExpr>)x
{
   return [x isSubnormal];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx isInfinite:(id<ORExpr>)x
{
   return [x isInfinite];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx abs:(id<ORExpr>)x
{
   return [x abs];
}
-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x add:(id<ORExpr>)y
{
   return [x plus:y];
}

-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x sub:(id<ORExpr>)y
{
   return [x sub:y];
}

-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x mul:(id<ORExpr>)y
{
   return [x mul:y];
}

-(id<ORExpr>) objcp_mk_fp:(objcp_expr)ctx x:(id<ORExpr>)x div:(id<ORExpr>)y
{
   return [x div:y];
}

-(ConstantWrapper*) objcp_mk_fp_constant:(objcp_expr)ctx s:(ConstantWrapper*)s e:(ConstantWrapper*)e m:(ConstantWrapper*)m
{
   assert((e->_width == E_SIZE && m->_width == M_SIZE) || (e->_width == ED_SIZE && m->_width == MD_SIZE));
   if(e->_width == E_SIZE && m->_width == M_SIZE){
      float f = floatFromParts([m uintValue],[e uintValue],[s uintValue]);
      NSLog(@"%16.16e",f);
      return [[[ConstantWrapper alloc] initWithFloat:f] autorelease];
   }
   if(e->_width == ED_SIZE && m->_width == MD_SIZE){
      double f = doubleFromParts([m ulongValue],[e uintValue],[s uintValue]);
      NSLog(@"%20.20e",f);
      return [[[ConstantWrapper alloc] initWithDouble:f] autorelease];
   }
   return nil;
}
-(id<ORExpr>) objcp_mk_to_fp:(id<ORExpr>)x to:(objcp_var_type) t
{
   if([(id)x isKindOfClass:[ConstantWrapper class]]){
      objcp_var_type tp = [(ConstantWrapper*)x type];
      if(tp == OR_BV){
         [(ConstantWrapper*)x setType:t];
         return (id<ORExpr>)[(ConstantWrapper*)x makeVariable];
      }
      x = (id<ORExpr>)[(ConstantWrapper*)x makeVariable];
      if(tp == t)
         return x;
   }if(t == OR_DOUBLE)
      return [x toDouble];
   return [x toFloat];
}
@end

