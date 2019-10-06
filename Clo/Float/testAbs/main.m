#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"


void check_it_d(double a) {
   double ma = 0.401; printf("ma = % 20.20e\n a = % 20.20e\n a+= % 20.20e\n", ma, a, nextafter(a, +INFINITY));
}


void carbonGas_d(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];\
        id<ORDoubleVar> a = [ORFactory doubleVar:mdl name:@"a"];
        id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"p"];
        id<ORDoubleVar> b = [ORFactory doubleVar:mdl name:@"b"];
        id<ORDoubleVar> t = [ORFactory doubleVar:mdl name:@"t"];
        id<ORDoubleVar> n = [ORFactory doubleVar:mdl name:@"n"];
        id<ORDoubleVar> k = [ORFactory doubleVar:mdl name:@"k"];
        id<ORDoubleVar> v = [ORFactory doubleVar:mdl low:0.1 up:0.5 name:@"v"];
        id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
        
        [mdl add:[a set: @(0.401)]];
        [mdl add:[p set: @(3.5e7)]];
        [mdl add:[b set: @(42.7e-6)]];
        [mdl add:[t set: @(300.0)]];
        [mdl add:[n set: @(1000.0)]];
        [mdl add:[k set: @(1.3806503e-23)]];
        
        [mdl add:[r set: [[[p plus: [[a mul: [n div: v]] mul: [n div: v]]] mul: [v sub: [n mul: b]]] sub: [[k mul: n] mul: t]]]];
        
        NSLog(@"model: %@",mdl);
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORDoubleVarArray> vs = [mdl doubleVars];
        id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
       
        [cp solve:^{
            if (search)
               [cp maxOccurencesSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
                    [cp floatSplit:i withVars:x];
                }];
            NSLog(@"%@",cp);
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
            NSLog(@"p : %@ (%s)",[cp concretize:p],[cp bound:p] ? "YES" : "NO");
            NSLog(@"a : %@ (%s)",[cp concretize:a],[cp bound:a] ? "YES" : "NO");
            NSLog(@"b : %@ (%s)",[cp concretize:b],[cp bound:b] ? "YES" : "NO");
            NSLog(@"t : %@ (%s)",[cp concretize:t],[cp bound:t] ? "YES" : "NO");
            NSLog(@"n : %@ (%s)",[cp concretize:n],[cp bound:n] ? "YES" : "NO");
            NSLog(@"k : %@ (%s)",[cp concretize:k],[cp bound:k] ? "YES" : "NO");
            NSLog(@"v : %@ (%s)",[cp concretize:v],[cp bound:v] ? "YES" : "NO");
            NSLog(@"r : %@ (%s)",[cp concretize:r],[cp bound:r] ? "YES" : "NO");
           check_it_d([cp doubleValue:a]);
        }];
    }
}




int main(int argc, const char * argv[]) {
  @autoreleasepool {
     carbonGas_d(1, argc, argv);
//    ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
//
//    id<ORModel> model = [ORFactory createModel];
//    id<ORFloatVar> a = [ORFactory floatVar:model low:-1000000.0f up:1000000.0f name:@"a"];
//    id<ORFloatVar> b = [ORFactory floatVar:model low:-1000000.0f up:0.0f name:@"b"];
//    id<ORFloatVar> c = [ORFactory floatVar:model low:-1000000.0f up:1000000.0f name:@"c"];
//
//    id<ORFloatVar> assoc1 = [ORFactory floatVar:model];
//    id<ORFloatVar> assoc2 = [ORFactory floatVar:model];
//    id<ORFloatVar> diffab = [ORFactory floatVar:model];
//    id<ORFloatVar> diffac = [ORFactory floatVar:model];
//    id<ORFloatVar> diffbc = [ORFactory floatVar:model];
//
//
//    id<ORFloatVar> delta = [ORFactory floatVar:model low:0.1f up:0.1f  name:@"delta"];
//    id<ORExpr> epsilon =  [ORFactory float:model value:0.0001f];
//
//
//    id<ORExpr> infinity = [ORFactory infinityf:model];
//    id<ORExpr> sub_infinity = [ORFactory float:model value:-INFINITY];
//
//    NSMutableArray* toadd = [[NSMutableArray alloc] init];
//
//
//    [toadd addObject:[delta gt:@(0.0f)]];
//    [toadd addObject:[epsilon gt:@(0.0f)]];
//
//    [toadd addObject:[a geq:b]];
//    [toadd addObject:[b geq:c]];
//
//
//    [toadd addObject:[diffab leq:delta]];
//    [toadd addObject:[diffac leq:delta]];
//    [toadd addObject:[diffbc leq:delta]];
//
//    [toadd addObject:[diffab eq:[a sub:b]]];
//    [toadd addObject:[diffac eq:[a sub:c]]];
//    [toadd addObject:[diffbc eq:[b sub:c]]];
//    [toadd addObject:[assoc1 eq:[[a plus:b] plus:c]]];
//    [toadd addObject:[assoc2 eq:[a plus:[b plus:c]]]];
//
//    [toadd addObject:[assoc1 neq:infinity]];
//    [toadd addObject:[assoc1 neq:sub_infinity]];
//    //
//    [toadd addObject:[assoc2 neq:infinity]];
//    [toadd addObject:[assoc2 neq:sub_infinity]];
//
//    [toadd addObject:[[assoc1 sub:assoc2] gt:epsilon]];
//
//    id<CPProgram> cp = [args makeProgramWithSimplification:model constraints:toadd];
//    [ORCmdLineArgs defaultRunner:args model:model program:cp  restricted:@[a,b,c]];
    
    
  }
  return 0;
}
