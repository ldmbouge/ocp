//
//  objcpUtils.m
//  Verification
//
//  Created by zitoun on 5/23/19.
//

#import "objcpUtils.h"

@class OBJCPDecl;


@implementation AbstractLogicHandler
{
@protected
   NSMutableDictionary* _declarations;
}
-(AbstractLogicHandler*) init:(id<ORModel>)m
{
   self = [self init:m withOptions:nil withDeclaration:nil];
   return self;
}
-(AbstractLogicHandler*) init:(id<ORModel>)m withOptions:(ORCmdLineArgs *)options withDeclaration:(NSMutableDictionary *)decl
{
   self = [super init];
   _model = m;
   _declarations = decl;
   if(options == nil){
      int argc = 2;
      const char* argv[] = {};
      _options = [ORCmdLineArgs newWith:argc argv:argv];
   }else{
      _options = options;
   }
   _program = [_options makeProgram:_model];
   _vars = [self getVariables];
   return self;
}
- (id<ORVarArray>)getVariables
{
   @throw [[ORExecutionError alloc] initORExecutionError: "AbstractLogicHandler is an abstract class"];
}
- (NSMutableDictionary*)getDeclarations
{
   return _declarations;
}
-(id<CPProgram>) getProgram
{
   return _program;
}
- (void)launchHeuristic
{
   @throw [[ORExecutionError alloc] initORExecutionError: "AbstractLogicHandler is an abstract class"];
}
-(ORInt) declSize
{
   return 0;
}
- (void)setOptions:(ORCmdLineArgs *)options
{
   _options = options;
}
-(void) printSolutions
{
   [self printSolutionsI];
   NSLog(@"Depth : %d",[[_program tracer] level]);
}
-(void) printSolutionsI
{
   @throw [[ORExecutionError alloc] initORExecutionError: "AbstractLogicHandler is an abstract class"];
}
-(ORBool) checkAllbound
{
   ORBool res = YES;
   NSArray* vars = [_model variables];
   for(id<ORVar> v in vars)
      if(![_program bound:v]){
         res = NO;
         NSLog(@"la variable %@ n'est pas bound : %@",v,[_program concretize:v]);
      }
   return res;
}
@end

@implementation IntLogicHandler
-(IntLogicHandler*) init:(id<ORModel>) m withOptions:(ORCmdLineArgs *)options
{
   self = [super init:m withOptions:options withDeclaration:nil];
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

@implementation FloatLogicHandler{
   ORInt _declSize;
}
-(id<ORVarArray>) getVariables
{
   if(_vars == nil)
      [self initVariables];
   return [_options makeDisabledArray:_program from:_vars];
}
-(void) initVariables
{
   id<ORVarArray> allfpvars = [_model FPVars];
   NSMutableDictionary* dict = [self getDeclarations];
   NSMutableArray*  dictvars= [[NSMutableArray alloc] initWithCapacity:[dict count]];
   NSMutableArray* tmp = [[NSMutableArray alloc] initWithCapacity:[dict count]];
   __block ORInt i = 0;
   [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      if([[(OBJCPDecl*)obj getVariable] conformsToProtocol:@protocol(ORFloatVar)] || [[(OBJCPDecl*)obj getVariable] conformsToProtocol:@protocol(ORDoubleVar)])
         [dictvars addObject:[(OBJCPDecl*)obj getVariable]];
   }];
   _declSize = (ORInt)[dictvars count];
   if([dictvars count] > 0){
      for(id<ORVar> v in allfpvars){
         if([dictvars containsObject:v]){
            [tmp addObject:v];
         }
      }
      [dictvars release];
   }
   if([tmp count] && ([_options restricted] || [_options fullRestrict])){
      _vars = (id<ORVarArray>)[ORFactory idArray:_model range:RANGE(_model,0,(ORUInt)[tmp count] - 1)];
      for(i = 0; i <  [tmp count];i++){
         if(tmp[i] == nil)
            break;
         _vars[i] = tmp[i];
      }
      [tmp release];
   }else
      _vars =  [_model FPVars] ;
   
}
-(ORInt) declSize
{
   return _declSize;
}
- (void)launchHeuristic
{
   //just to force vars to be recompute.
   id<ORDisabledVarArray> old = (id<ORDisabledVarArray>) _vars;
   _vars = [self getVariables];
   id<ORDisabledVarArray> disVars = (id<ORDisabledVarArray>) _vars;
   for(ORInt i = [old low]; i <= [old up]; i++){
      ORInt p = [old parent:i];
      if(![disVars contains:old[i]] || ![disVars contains:old[p]]) continue;
      if(p != i)
         [disVars unionSet:i and:p];
   }
   printf("--------------------\n");
   printf("|vars|=%lu |restrict|=%d |full-r|=%lu\n",(unsigned long)[[_model FPVars] count],_declSize,(unsigned long)[_vars count]);
   for (id<ORVar> v in _vars)
      printf("%s\n",[[v description] UTF8String]);
   printf("--------------------\n");
   [_options launchHeuristic:_program restricted:_vars];
}
-(void) printSolutionsI
{
   ORInt efsize = E_SIZE+1;
   ORInt mfsize = M_SIZE+1;
   ORInt edsize = ED_SIZE+1;
   ORInt mdsize = MD_SIZE+1;
   char efstr[efsize];
   char mfstr[mfsize];
   char edstr[edsize];
   char mdstr[mdsize];
   id<ORVarArray> arr = [_model FPVars];
   NSLog(@"------------------");
   for(id<ORVar> v in arr){
      if([_program bound:v]){
         if([v.class conformsToProtocol:@protocol(ORFloatVar)])
            NSLog(@"%@ : %20.20e (YES)",v,[_program floatValue:v]);
         else if([v.class conformsToProtocol:@protocol(ORDoubleVar)])
            NSLog(@"%@ : %20.20e (YES)",v,[_program doubleValue:v]);
      }else{
         if([v.class conformsToProtocol:@protocol(ORFloatVar)])
            NSLog(@"%@ : %@ (NO)",v,[_program concretize:v]);
         else if([v.class conformsToProtocol:@protocol(ORDoubleVar)])
            NSLog(@"%@ : %@ (NO)",v,[_program concretize:v]);
      }
   }
   NSLog(@"------------------");
   for(id<ORVar> v in _vars){
      if([v.class conformsToProtocol:@protocol(ORFloatVar)])
         NSLog(@"%@ : %20.20e (%s)",v,[_program floatValue:v],[_program bound:v] ? "YES" : "NO");
      else if([v.class conformsToProtocol:@protocol(ORDoubleVar)])
         NSLog(@"%@ : %20.20e (%s)",v,[_program doubleValue:v],[_program bound:v] ? "YES" : "NO");
   }
   
   for(id<ORVar> v in _vars){
      if([v.class conformsToProtocol:@protocol(ORFloatVar)]){
         float_cast f;
         f.f = [_program floatValue:v];
         if(isinff(f.f)){
            printf("(assert (= %s (_ %soo 8 24)))\n",[[v prettyname] UTF8String], (f.f == +INFINITY) ? "+" : "-");
         }else{
            i2bs(efstr,efsize,f.parts.exponent);
            i2bs(mfstr,mfsize,f.parts.mantisa);
            printf("(assert (= %s (fp #b%d #b%s #b%s)))\n",[[v prettyname] UTF8String],f.parts.sign,efstr,mfstr);
         }
      }else if([v.class conformsToProtocol:@protocol(ORDoubleVar)]){
         double_cast f;
         f.f = [_program doubleValue:v];
         if(isinf(f.f)){
            printf("(assert (= %s (_ %soo 11 53)))\n",[[v prettyname] UTF8String], (f.f == +INFINITY) ? "+" : "-");
         }else{
            unsigned long m = f.parts.mantisa;
            i2bs(edstr,edsize,f.parts.exponent);
            i2bs(mdstr,mdsize,m);
            printf("(assert (= %s (fp #b%d #b%s #b%s)))\n",[[v prettyname] UTF8String],f.parts.sign,edstr,mdstr);
         }
      }
   }
}
@end

@implementation BVLogicHandler
-(BVLogicHandler*) init:(id<ORModel>) m withOptions:(ORCmdLineArgs *)options
{
   self = [super init];
   _model = m;
   if(options == nil){
      int argc = 2;
      const char* argv[] = {};
      _options = [ORCmdLineArgs newWith:argc argv:argv];
   }else{
      _options = options;
   }
   _program = [ORFactory createCPProgramBackjumpingDFS:_model];
   _vars = [self getVariables];
   _heuristic = [_program createDDeg];
   return self;
}
-(id<ORVarArray>) getVariables
{
   return [_model bitVars];
}
@end

