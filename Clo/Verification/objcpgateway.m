//
//  OBJCPGateway.c
//  Clo
//
//  Created by Greg Johnson on 2/23/14.
//
//

#import "objcpgateway.h"
#include "/usr/local/include/gmp.h"

#include "objcp/CPBitConstraint.h"

@interface OBJCPType : NSObject{
@private
   NSString* _name;
   objcp_var_type _type;
   ORInt    _size;
}
-initExplicit:(NSString*)name withType:(objcp_var_type)type;
-initExplicitWithSize:(NSString*)name withType:(objcp_var_type)type andSize:(ORInt)size;
-(NSString*) getName;
-(objcp_var_type) getType;
-(id)copyWithZone:(NSZone *)zone;
@end

@implementation OBJCPType
-initExplicit:(NSString*)name withType:(objcp_var_type)type{
   self=[super init];
   _name = name;
   _type = type;
   _size = 1;
   return self;
}
-initExplicitWithSize:(NSString*)name withType:(objcp_var_type)type andSize:(ORInt)size{
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
   OBJCPType* newObject = [[OBJCPType alloc] initExplicitWithSize:_name withType:_type andSize:_size];
   return newObject;
}
@end

@interface OBJCPDecl : NSObject{
@private
   NSString* _name;
   OBJCPType* _type;
   ORInt    _size;
   id<ORBitVar> _var;
}
-initExplicit:(NSString*)name withType:(OBJCPType*)type;
-initExplicitWithSize:(NSString*)name withType:(OBJCPType*)type andSize:(ORInt)size;
-(NSString*) getName;
-(OBJCPType*) getType;
-(ORUInt) getSize;
-(id<ORBitVar>) getVariable;
-(void) setVariable:(id<ORBitVar>)v;
-(id)copyWithZone:(NSZone *)zone;
@end

@implementation OBJCPDecl
-(OBJCPDecl*)initExplicit:(NSString*)name withType:(OBJCPType*)type{
   self=[super init];
   _name = name;
   _type = (OBJCPType*)type;
   _size = 1;
   _var = NULL;
   return self;
}
-(OBJCPDecl*)initExplicitWithSize:(NSString*)name withType:(OBJCPType*)type andSize:(ORInt)size{
   self=[super init];
   _name = name;
   _type = (OBJCPType*)type;
   _size = size;
   _var = NULL;
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
-(OBJCPType*) getType{
   return _type;
}
-(ORUInt) getSize{
   return _size;
}
-(id<ORBitVar>) getVariable{
   return _var;
}
-(void)setVariable:(id<ORBitVar>)v{
   _var = v;
}
-(id) copyWithZone:(NSZone *)zone{
   OBJCPDecl* newObject = [[OBJCPDecl alloc] initExplicitWithSize:_name withType:_type andSize:_size];
   return newObject;
}
@end

@implementation OBJCPGateway:NSObject
+(OBJCPGateway*) initOBJCPGateway{
   OBJCPGateway* x = [[OBJCPGateway alloc]initExplicitOBJCPGateway];
   return x;
}

-(OBJCPGateway*) initExplicitOBJCPGateway{
   self = [super init];

   ORUInt* zero = alloca(sizeof(ORUInt));
   ORUInt* one = alloca(sizeof(ORUInt));

   _model = [ORFactory createModel];
   _declarations = [[NSMutableDictionary alloc] initWithCapacity:10];
   _instances = [[NSMutableDictionary alloc] initWithCapacity:10];
   _types = [[NSMutableDictionary alloc] initWithCapacity:10];

   *zero = 0;
   *one = 1;
   _false = [ORFactory bitVar:_model low:zero up:zero bitLength:1];
   _true = [ORFactory bitVar:_model low:one up:one bitLength:1];
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
//   NSLog(@"Make variable declaration. Name was %s and type was %ld", name, (long)type);

//   ORUInt* min;
//   ORUInt* max;
//   
//   min = alloca(sizeof(ORInt));
//   max = alloca(sizeof(ORInt));
//   min[0] = 0;
//   max[0] = 0xFFFFFFFF;
//   id<ORBitVar> bv = [ORFactory bitVar:_model low:min up:max bitLength:32];
//   NSString *key = [[NSString alloc] initWithUTF8String:name];
//   [_variables setObject:bv forKey:key];
//   return bv;
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
//   NSLog(@"Getting variable declaration from name. Name was %s",name);
   NSString *key = [[NSString alloc] initWithUTF8String:name];

   OBJCPDecl* d = [_declarations objectForKey:key];
   return d;
}

-(objcp_expr) objcp_mk_var_from_decl:(objcp_context) ctx withDecl:(objcp_var_decl) d{
//   NSLog(@"Make var from declaration.");
   OBJCPDecl* decl = d;

   id<ORBitVar> bv = [decl getVariable];
//   id<ORBitVar> bv;
   if (bv == NULL) {
      ORUInt size = [decl getSize];
      //NSLog(@"Making bit vector (from declaration) of size %d\n",size);
      ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD != 0) ? 1: 0);
      ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
      ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
      for(int i=0; i< wordlength;i++){
         low[i] = 0;
         up[i] = CP_UMASK;
      }
      if (size%BITSPERWORD != 0)
         up[0] >>= BITSPERWORD - (size % BITSPERWORD);

      bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
      [decl setVariable:bv];
   }
   return bv;
}

-(void) objcp_set_arith_only:(int) flag{
   NSLog(@"Set arith only not implemented");
}

-(objcp_type) objcp_mk_type:(objcp_context)ctx withName:(char*) name{
//   NSLog(@"Make type with name not implemented. Name was %s",name);
   return NULL;
}

-(objcp_type) objcp_mk_bitvector_type:(objcp_context)ctx withSize:(unsigned int) size{
//   NSLog(@"Making bit vector of size %d\n",size);
//   ORUInt wordlength = (size / 32) + ((size % 32 != 0) ? 1: 0);
//   ORUInt* low = alloca(sizeof(ORUInt)*wordlength);
//   ORUInt* up = alloca(sizeof(ORUInt)*wordlength);
//   for(int i=0; i< wordlength;i++){
//      low[i] = 0;
//      up[i] = CP_UMASK;
//   }
//   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
//   return bv;
   NSString* nameString =[[NSString alloc] initWithUTF8String:"unnamed"];
   OBJCPType* t = [[OBJCPType alloc] initExplicitWithSize:nameString withType:OR_BV andSize:size];
   [_types setObject:t forKey:(void*)t];
   return (void*)t;
}

-(objcp_type) objcp_mk_function_type:(objcp_context)ctx withDom:(objcp_type*)domain withDomSize:(unsigned long) size andRange:(objcp_type) range{
   NSLog(@"Make function type not implemented");
   return NULL;
}
/*
-(int)  objcp_get_mpq_value:(objcp_model) m withDecl:(objcp_var_decl) d andVal:(mpq_t) value{
   NSLog(@"Get mpq value not implemented");
   return 0;
}
*/

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



   /**
    \brief Assert a constraint that can be later retracted.
    
    \returns An id that can be used to retract the constraint.
    
    This is similar to #yices_assert_weighted, but the weight is considered to be infinite.
    
    \sa yices_retract
    */
-(assertion_id) objcp_assert_retractable:(objcp_context) ctx withExpr:(objcp_expr) expr{
   NSLog(@"Assert Retractable not implemented");
   return 0;
}
   
/**
 \brief Assert a constraint in the logical context.
 
 After an assertion, the logical context may become inconsistent.
 The method #yices_inconsistent may be used to check that.
 */
-(void) objcp_assert:(objcp_context) ctx withExpr:(objcp_expr) expr{
//   NSLog(@"Assert not implemented");
   ORUInt dom = 0x00000001;
   id<ORBitVar> trueVar = [ORFactory bitVar:_model low:&dom up:&dom bitLength:1];
//   [trueVar retain];
   [_model add:[ORFactory bit:trueVar eq:(id<ORBitVar>)expr]];
   return;
}

-(ORBool) objcp_check:(objcp_context) ctx{
   clock_t start;
   start = clock();

   __block ORBool sat = false;
   __block clock_t searchStart;
   __block clock_t searchFinish;
   double totalTime, searchTime;
   mallocWatch();

    id<CPSemanticProgram,CPBV> cp = (id)[ORFactory createCPProgramBackjumpingDFS:_model];
//    id<CPSemanticProgram,CPBV> cp = (id)[ORFactory createCPProgram:_model];
   id<ORBitVarArray> o = [ORFactory bitVarArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:(ORUInt)[_declarations count]-1]];
   ORInt k=0;
   for (id var in _declarations)
   {
      [o set:[[_declarations objectForKey:var]getVariable] at:k];
      k++;
   }
   
//    __block id<CPBitVarHeuristic> h =[cp createBitVarFF];
   __block id<CPBitVarHeuristic> h =[cp createBitVarVSIDS];
//        __block id<CPBitVarHeuristic> h =[cp createSDeg];
//   __block id<CPBitVarHeuristic> h =[cp createDDeg];
//        __block id<CPBitVarHeuristic> h =[cp createWDeg];
//        __block id<CPBitVarHeuristic> h =[cp createBitVarABS];

    __block NSMutableArray* engineVars = [[cp engine] variables];
//    NSLog(@"%@",engineVars);

    __block CPBitAntecedents* ants;
    __block CPBitAssignment** vars;
    __block id<CPBVConstraint> c;
   

   [cp solve:^{
      
        //        [cp repeat:^{
//        [cp limitTime:30000 in: ^{
//                    NSLog(@"%@", [[cp engine] model]);
//           for (id var in _declarations)
//              NSLog(@"%@, %@", [cp stringValue:[[_declarations objectForKey:var] getVariable]], var);

          searchStart = clock();
        [cp labelBitVarHeuristic:h];
          searchFinish = clock();
           for (id var in _declarations)
             NSLog(@"%@, %@", [cp stringValue:[[_declarations objectForKey:var] getVariable]], var);

          NSString *sep = @" ,";
          char binvalue[512];
          NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:sep];
          for (id var in _declarations){
              NSArray *temp=[[cp stringValue:[[_declarations objectForKey:var] getVariable]] componentsSeparatedByCharactersInSet:set];
              [temp[2] getCString:binvalue maxLength:512 encoding:NSUTF8StringEncoding];
              long int foo = strtol(binvalue,NULL, 2);
              printf("(assert (= %s (_ bv%ld %d)))\n",[[var description] cString], foo, [[_declarations objectForKey:var]getSize]);
          }
          sat = true;
//                           NSLog(@"%@", [[cp engine] model]);
//      }];
//        }onRepeat:^{
//            printf("Restarting...\n");
//        }];
   }];
   searchFinish = clock();
   NSLog(@"%@",mallocReport());
   totalTime =((double)(searchFinish - start))/CLOCKS_PER_SEC;
   searchTime = ((double)(searchFinish - searchStart))/CLOCKS_PER_SEC;
   NSLog(@"      Search Time (s): %f",searchTime);
   NSLog(@"       Total Time (s): %f\n\n",totalTime);
   NSLog(@"Solver status: %@\n",cp);

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

-(ORUInt) objcp_get_unsat_core:(objcp_context) ctx withId:(assertion_id*)a{
   NSLog(@"Get unsat core size not implemented");
   return 0;
}
-(ORUInt) objcp_get_unsat_core_size:(objcp_context) ctx{
   NSLog(@"Get unsat core size not implemented");
   return 0;
}

-(objcp_expr) objcp_mk_app:(objcp_context)ctx withFun:(objcp_expr)f withArgs:(objcp_expr*)arg andNumArgs:(ORULong)n{
   NSLog(@"Make bitvector not implemented");
   return NULL;
}

-(objcp_expr) objcp_mk_bv_constant_from_array:(objcp_context) ctx withSize:(ORUInt)size fromArray:(ORUInt*)bv{
//   NSMutableString* sourceArray = [[NSMutableString alloc] initWithCapacity:size];
//   for(int i=0;i<size;i++)
//      [sourceArray appendFormat:@"%d",bv[i]];
//   NSLog(@"%@",sourceArray);
   
//   NSLog(@"Making bitvector constant from array with size %u and pattern %@",size,sourceArray);
//   [sourceArray release];

   ORUInt wordLength = size/BITSPERWORD + ((size % BITSPERWORD ==0) ? 0 : 1);
      
   ORUInt* pattern = alloca(sizeof(ORUInt)*wordLength);
   for (int i = 0; i<wordLength; i++)
      pattern[i] = 0;

   for (int i=0; i<size; i++) {
      pattern[wordLength-(i/BITSPERWORD)-1] |= bv[i] << i%BITSPERWORD;
//      if ((size-i-1 != 0) && ((size-i-1)%BITSPERWORD != 0))
//         pattern[i/BITSPERWORD] <<= 1;
//      printf("%i",bv[i]);
   }
//   printf("\n");
//   for (int i=0; i<wordLength; i++) {
//      NSLog(@"%x",pattern[i]);
//   }
   id<ORBitVar> bitv = [ORFactory bitVar:_model low:pattern up:pattern bitLength:size];
   return bitv;
}



//ORUInt wordLength = size/BITSPERWORD + ((size%BITSPERWORD == 0) ? 0 : 1);
//ORUInt index;
//
//ORUInt* pattern = alloca(sizeof(ORUInt)*wordLength);
//
//for (int i=0; i<wordLength; i++) {
//   pattern[i] = 0;
//   for(int j=0;j<BITSPERWORD;j++){
//      index = (i*BITSPERWORD)+j;
//      if (index >= size)
//         break;
//      pattern[i] += bv[size-index];
//      if ((size-index != 0) && ((size-index)%BITSPERWORD != 0))
//         pattern[i] <<= 1;
//   }
//}



-(objcp_expr) objcp_mk_true:(objcp_context)ctx{
   ORUInt dom = 0x00000001;
   return [ORFactory bitVar:_model low:&dom up:&dom bitLength:1];
}

-(objcp_expr) objcp_mk_false:(objcp_context)ctx{
   ORUInt dom = 0x00000000;
   return [ORFactory bitVar:_model low:&dom up:&dom bitLength:1];
}

-(objcp_expr) objcp_mk_and:(objcp_context)ctx withArgs:(objcp_expr *)args andNumArgs:(ORULong)numArgs{
//   ORUInt* low = alloca(sizeof(ORUInt));
//   ORUInt* up = alloca(sizeof(ORUInt));
//   *low = 0;
//   *up = 0xFFFFFFFF;

   
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

-(objcp_expr) objcp_mk_or:(objcp_context)ctx withArgs:(objcp_expr *)args andNumArgs:(ORULong)numArgs{
//   ORUInt* low = alloca(sizeof(ORUInt));
//   ORUInt* up = alloca(sizeof(ORUInt));
//   *low = 0;
//   *up = 0x00000001;
   
   ORUInt* zero = alloca(sizeof(ORUInt));
   ORUInt* one = alloca(sizeof(ORUInt));
   
   *zero = 0;
   *one = 1;
   if(numArgs != 2)
      NSLog(@"ERROR - Boolean OR constraint defined with other than two arguments");
   id<ORBitVar> result = [ORFactory bitVar:_model low:zero up:one bitLength:1];
//   id<ORIntRange> range = [ORFactory intRange:_model low:0 up:numArgs-1];
//   id<ORBitVarArray> arguments = [ORFactory bitVarArray:_model range:range];
//   for (int i = 0; i<numArgs; i++)
//      arguments[i] = args[i];
//   [_model add:[ORFactory bit:arguments logicalAndEval:result]];

   [_model add:[ORFactory bit:(id<ORBitVar>)args[0] orb:(id<ORBitVar>)args[1] eval:result]];
   return result;
}
//objcp_mk_not
-(objcp_expr) objcp_mk_not:(objcp_context)ctx withArg:(objcp_expr)arg1{
   ORUInt* low = alloca(sizeof(ORUInt));
   ORUInt* up = alloca(sizeof(ORUInt));
   *low = 0;
   *up = 0x00000001;
   
   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:1];
   
   [_model add:[ORFactory bit:(id<ORBitVar>)arg1 notb:(id<ORBitVar>)bv]];
   return bv;
}


-(objcp_expr) objcp_mk_eq:(objcp_context)ctx withArg:(objcp_expr)arg1 andArg:(objcp_expr)arg2{
   ORUInt* low = alloca(sizeof(ORUInt));
   ORUInt* up = alloca(sizeof(ORUInt));
   *low = 0;
   *up = 0x00000001;

   id<ORBitVar> bv = [ORFactory bitVar:_model low:low up:up bitLength:1];
  
   [_model add:[ORFactory bit:(id<ORBitVar>)arg1 equalb:(id<ORBitVar>)arg2 eval:(id<ORBitVar>)bv]];
//   [_model add:[ORFactory bit:(id<ORBitVar>)arg1 eq:(id<ORBitVar>)arg2]];
//   NSLog(@"Added Logical EQUAL Constraint\n");
   return bv;
}

//objcp_mk_sum
//objcp_mk_mul
//-(objcp_expr) objcp_mk_sub
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
-(objcp_expr) objcp_mk_ite:(objcp_context)ctx if:(objcp_expr)c then:(objcp_expr) t else:(objcp_expr)e //{return NULL;}
{
   id<ORBitVar> result;
   ORUInt thenSize = [(id<ORBitVar>)t bitLength];
   ORUInt elseSize = [(id<ORBitVar>)e bitLength];
   ORUInt resultSize = max(thenSize, elseSize);
   ORUInt resultWordLength = resultSize/BITSPERWORD + ((resultSize % BITSPERWORD != 0) ? 1: 0);
   ORUInt* low = alloca(sizeof(ORUInt)*resultWordLength);
   ORUInt* up = alloca(sizeof(ORUInt)*resultWordLength);
   for(int i = 0; i<resultWordLength;i++){
      low[i] = 0;
      up[i] = CP_UMASK;
   }
//   if (size%BITSPERWORD != 0)
//      up[0] >>= BITSPERWORD-(resultSize%BITSPERWORD);
   result = [ORFactory bitVar:_model low:low up:up bitLength:resultSize];
//   [_model add:[ORFactory bit:result trueIf:c equals:t zeroIfXEquals:e]];
   [_model add:[ORFactory bit:c then:t else:e result:result]];
   return result;
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

-(objcp_expr) objcp_mk_bv_not:(objcp_context) ctx withArg:(objcp_expr) a1{
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
//   NSLog(@"Added BVNOT Constraint\n");
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
//   NSLog(@"Added BVAND Constraint\n");
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
//   NSLog(@"Added BVOR Constraint\n");
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
//   NSLog(@"Added BVXOR Constraint\n");
   return bv;
}

-(objcp_expr) objcp_mk_bv_lt:(objcp_context)ctx x:(objcp_expr)x lt:(objcp_expr) y{
   ORUInt low = 0;
   ORUInt up = 1;

   id<ORBitVar> bv = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   [_model add:[ORFactory bit:(id<ORBitVar>)x LT:y eval:bv]];
   return bv;
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
//   NSLog(@"Added BitShiftL Constraint\n");
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
//   NSLog(@"Added BitShiftR Constraint\n");
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
   //   NSLog(@"Added BitShiftR Constraint\n");
   return bv;
}
-(objcp_expr) objcp_mk_bv_le:(objcp_context)ctx x:(objcp_expr)x le:(objcp_expr) y{
   ORUInt low = 0;
   ORUInt up = 1;

   id<ORBitVar> bv = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
   [_model add:[ORFactory bit:(id<ORBitVar>)x LE:(id<ORBitVar>)y eval:(id<ORBitVar>)bv]];
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
//   ORUInt low;
//   ORUInt up;
//   low = 0;
//   up = 0x1;
//
//   id<ORBitVar> bv = [ORFactory bitVar:_model low:&low up:&up bitLength:1];
//   [_model add:[ORFactory bit:(id<ORBitVar>)x SLT:(id<ORBitVar>)y eval:(id<ORBitVar>)bv]];
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



   [_model add:[ORFactory bit:(id<ORBitVar>)y LE:(id<ORBitVar>)x eval:(id<ORBitVar>)bv]];

   [_model add:[ORFactory bit:(id<ORBitVar>)x from:size-1 to:size-1 eq:xSign]];
   [_model add:[ORFactory bit:(id<ORBitVar>)y from:size-1 to:size-1 eq:ySign]];
   [_model add:[ORFactory bit:(id<ORBitVar>)xSign bxor:ySign eq:temp]];
   [_model add:[ORFactory bit:(id<ORBitVar>)bv notb:notbv]];
   [_model add:[ORFactory bit:(id<ORBitVar>)temp bxor:notbv eq:result]];

   return result;
}

//objcp_mk_bv_gt
//objcp_mk_bv_sgt
//objcp_mk_bv_ge
//objcp_mk_bv_sge
-(objcp_expr) objcp_mk_bv_constant:(objcp_context) ctx withSize:(ORUInt)size andValue:(ORUInt)value{
//   NSLog(@"Making bit vector of size %d\n",size);
   id<ORBitVar> bitv = [ORFactory bitVar:_model low:&value up:&value bitLength:size];
//   NSLog(@"Added BV Constant\n");
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

-(objcp_expr) objcp_mk_bv_add:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
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
   
//   if ((size%BITSPERWORD) == 0) {
      bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
      cin = [ORFactory bitVar:_model low:low up:cinUp bitLength:size];
      cout = [ORFactory bitVar:_model low:low up:up bitLength:size];
      [_model add:[ORFactory bit:(id<ORBitVar>)a1 plus:a2 withCarryIn:cin eq:bv withCarryOut:cout]];
//   }
//   else{
//   id<ORBitVar> res = [ORFactory bitVar:_model low:low up:up bitLength:wordlength*BITSPERWORD];
//      id<ORBitVar> x = [ORFactory bitVar:_model low:low up:up bitLength:wordlength*BITSPERWORD];
//      id<ORBitVar> y = [ORFactory bitVar:_model low:low up:up bitLength:wordlength*BITSPERWORD];
//      cin = [ORFactory bitVar:_model low:low up:up bitLength:wordlength*BITSPERWORD];
//      cout = [ORFactory bitVar:_model low:low up:up bitLength:wordlength*BITSPERWORD];
//      [_model add:[ORFactory bit:a1 zeroExtendTo:x]];
//      [_model add:[ORFactory bit:a2 zeroExtendTo:y]];
//      [_model add:[ORFactory bit:x plus:y withCarryIn:cin eq:res withCarryOut:cout]];
//      bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
//      [_model add:[ORFactory bit:res from:0 to:(size-1) eq:bv]];
//   }

   //   NSLog(@"Added BVAdd Constraint\n");
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
//   if ((size%BITSPERWORD) == 0) {
      bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
      [_model add:[ORFactory bit:a1 minus:a2 eq:bv]];
//   }
//   else{
//      id<ORBitVar> res = [ORFactory bitVar:_model low:low up:up bitLength:wordlength*BITSPERWORD];
//      id<ORBitVar> x = [ORFactory bitVar:_model low:low up:up bitLength:wordlength*BITSPERWORD];
//      id<ORBitVar> y = [ORFactory bitVar:_model low:low up:up bitLength:wordlength*BITSPERWORD];
//      [_model add:[ORFactory bit:a1 zeroExtendTo:x]];
//      [_model add:[ORFactory bit:a2 zeroExtendTo:y]];
//      [_model add:[ORFactory bit:x minus:y eq:res]];
//      bv = [ORFactory bitVar:_model low:low up:up bitLength:size];
//      [_model add:[ORFactory bit:res from:0 to:(size-1) eq:bv]];
//   }
   return bv;
}
-(objcp_expr) objcp_mk_bv_mul:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
   int size = [(id<ORBitVar>)a1 bitLength];
   
   ORUInt wordlength = (size / BITSPERWORD) + ((size % BITSPERWORD == 0) ? 0: 1);
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

//-(objcp_expr) objcp_mk_bv_rem:(objcp_context) ctx withArg:(objcp_expr) a1 andArg:(objcp_expr)a2{
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
   //[ORFactory bit:(id<ORBitVar>)arg1 from:lsb to:msb eq:bv];
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
//objcp_mk_bv_rotl
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
   //   NSLog(@"Added BVAdd Constraint\n");
   return bv;
}
//objcp_mk_bv_rotr
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
