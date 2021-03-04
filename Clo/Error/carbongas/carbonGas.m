//
//  carbonGas.m
//
//  Created by Remy Garcia on 06/03/2018.
//
#import <ORProgram/ORProgram.h>
#include "gmp.h"

#define LOO_MEASURE_TIME(__message) \
for (CFAbsoluteTime startTime##__LINE__ = CFAbsoluteTimeGetCurrent(), endTime##__LINE__ = 0.0; endTime##__LINE__ == 0.0; \
NSLog(@"'%@' took %.3fs", (__message), (endTime##__LINE__ = CFAbsoluteTimeGetCurrent()) - startTime##__LINE__))

#define printFvar(name, var) NSLog(@""name" : [% 20.20e, % 20.20e]f (%s)",[(id<CPFloatVar>)[cp concretize:var] min],[(id<CPFloatVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 20.20e, % 20.20e]q",[(id<CPFloatVar>)[cp concretize:var] minErrF],[(id<CPFloatVar>)[cp concretize:var] maxErrF]);
#define getFmin(var) [(id<CPFloatVar>)[cp concretize:var] min]
#define getFminErr(var) *[(id<CPFloatVar>)[cp concretize:var] minErr]

#define printDvar(name, var) NSLog(@""name" : [% 24.24e, % 24.24e]d (%s)",[(id<CPDoubleVar>)[cp concretize:var] min],[(id<CPDoubleVar>)[cp concretize:var] max],[cp bound:var] ? "YES" : "NO"); NSLog(@"e"name": [% 1.2e, % 1.2e]q",[(id<CPDoubleVar>)[cp concretize:var] minErrF],[(id<CPDoubleVar>)[cp concretize:var] maxErrF]);
#define getDmin(var) [(id<CPDoubleVar>)[cp concretize:var] min]
#define getDminErr(var) *[(id<CPDoubleVar>)[cp concretize:var] minErr]

void check_it_d(double p, double a, double b, double t, double n, double k, double v, double r, id<ORRational> er) {
    double cr = (((p + ((a * (n/v)) * (n/v))) * (v - (n * b))) - ((k * n) * t));
    mpq_t pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1;
    
    if (cr != r)
        printf("WRONG: r = % 24.24e while cr = % 24.24e\n", r, cr);
    
    mpq_inits(pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1, NULL);
    mpq_set_d(pq, p);
    mpq_set_d(aq, a);
    mpq_set_d(bq, b);
    mpq_set_d(tq, t);
    mpq_set_d(nq, n);
    mpq_set_d(kq, k);
    mpq_set_d(vq, v);
    mpq_div(tmp0, nq, vq);
    mpq_mul(tmp1, tmp0, tmp0);
    mpq_mul(rq, tmp1, aq);
    mpq_add(rq, rq, pq);
    mpq_mul(tmp0, nq, bq);
    mpq_sub(tmp1, vq, tmp0);
    mpq_mul(rq, rq, tmp1);
    mpq_mul(tmp0, kq, nq);
    mpq_mul(tmp1, tmp0, tq);
    mpq_sub(rq, rq, tmp1);
    mpq_set_d(tmp0, r);
    mpq_sub(tmp1, rq, tmp0);
    if (mpq_cmp(tmp1, er.rational) != 0)
        printf("WRONG: er = % 20.20e while cer = % 20.20e\n", mpq_get_d(er.rational), mpq_get_d(tmp1));
    mpq_clears(pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1, NULL);
}

void motivating_d_c(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        /* Creation of model */
        id<ORModel> mdl = [ORFactory createModel];
        
        /* Declaration of rational numbers */
        id<ORRational> zero = [[ORRational alloc] init];
        
        /* Initialization of rational numbers */
        [zero setZero];
        
        /* Declaration of model variables */
        id<ORDoubleVar> x = [ORFactory doubleInputVar:mdl low:7.0 up:9.0 name:@"x"];
        id<ORDoubleVar> y = [ORFactory doubleInputVar:mdl low:3.0 up:5.0 name:@"y"];
       id<ORDoubleVar> w = [ORFactory doubleInputVar:mdl low:2.6666666666666666666 up:4.0 name:@"w"];
        id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"p"];
        //id<ORDoubleVar> k = [ORFactory doubleConstantVar:mdl value:1.11 string:@"111/100" name:@"k"];
        id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
        id<ORRationalVar> er = [ORFactory errorVar:mdl of:r];
        id<ORRationalVar> erAbs = [ORFactory rationalVar:mdl name:@"erAbs"];
        
        /* Initialization of constants */
        [mdl add:[p set: @(3.0)]];
        
        /* Declaration of constraints */
        [mdl add:[r set:[[[x mul: p] plus: y] div: w]]];
        //[mdl add:[r leq:@(10.0)]];
       
        NSLog(@"model: %@",mdl);
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORDoubleVarArray> vs = [mdl doubleVars];
        id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
       
        [cp solve:^{
            if (search)
               [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
                    [cp floatSplit:i withVars:x];
                }];
            NSLog(@"%@",cp);
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
           NSLog(@"x : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:x],[cp maxD:x],[cp minDQ:x],[cp maxDQ:x],[cp bound:x] ? "YES" : "NO");
           NSLog(@"y : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:y],[cp maxD:y],[cp minDQ:y],[cp maxDQ:y],[cp bound:y] ? "YES" : "NO");
           NSLog(@"w : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:w],[cp maxD:w],[cp minDQ:w],[cp maxDQ:w],[cp bound:w] ? "YES" : "NO");
           NSLog(@"r : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:r],[cp maxD:r],[cp minDQ:r],[cp maxDQ:r],[cp bound:r] ? "YES" : "NO");
            //if (search)
                //check_it_d(getDmin(p), getDmin(a), getDmin(b), getDmin(t), getDmin(n), getDmin(k), getDmin(v), getDmin(r), [cp minErrorDQ:r]);
        }];
    }
}

void carbonGas_d_c(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        /* Creation of model */
        id<ORModel> mdl = [ORFactory createModel];
        
        /* Declaration of rational numbers */
        id<ORRational> zero = [[ORRational alloc] init];
        
        /* Initialization of rational numbers */
        [zero setZero];
        
        /* Declaration of model variables */
        id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:0.1 up:0.5 name:@"v"];
        id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"p"];
        id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:0.401 string:@"401/1000" name:@"a"];
        id<ORDoubleVar> b = [ORFactory doubleConstantVar:mdl value:42.7e-6 string:@"427/10000000" name:@"b"];
        id<ORDoubleVar> t = [ORFactory doubleVar:mdl name:@"t"];
        id<ORDoubleVar> n = [ORFactory doubleVar:mdl name:@"n"];
        id<ORDoubleVar> k = [ORFactory doubleConstantVar:mdl value:1.3806503e-23 string:@"13806503/1000000000000000000000000000000" name:@"k"];
        id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
        id<ORRationalVar> er = [ORFactory errorVar:mdl of:r];
       id<ORRationalVar> erUlp = [ORFactory rationalVar:mdl name:@"t"];
       id<ORRationalVar> rQ = [ORFactory rationalVar:mdl from:r];
        
        /* Initialization of constants */
        [mdl add:[p set: @(3.5e7)]];
        [mdl add:[t set: @(300.0)]];
        [mdl add:[n set: @(1000.0)]];
        
        /* Declaration of constraints */
        [mdl add:[r set: [[[p plus: [[a mul: [n div: v]] mul: [n div: v]]] mul: [v sub: [n mul: b]]] sub: [[k mul: n] mul: t]]]];
       
       [zero set_d:0];
       //[mdl add: [r gt: @(1.0e+07)]];
       //[mdl add:[er eq: zero]];
       [mdl add: [[rQ plus: er] eq: rQ]];

        NSLog(@"model: %@",mdl);
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORDoubleVarArray> vs = [mdl doubleVars];
        id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
       
        [cp solve:^{
            if (search)
               [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
                    [cp floatSplit:i withVars:x];
                }];
            NSLog(@"%@",cp);
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
           NSLog(@"p : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:p],[cp maxD:p],[cp minDQ:p],[cp maxDQ:p],[cp bound:p] ? "YES" : "NO");
           NSLog(@"a : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:a],[cp maxD:a],[cp minDQ:a],[cp maxDQ:a],[cp bound:a] ? "YES" : "NO");
           NSLog(@"b : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:b],[cp maxD:b],[cp minDQ:b],[cp maxDQ:b],[cp bound:b] ? "YES" : "NO");
           NSLog(@"t : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:t],[cp maxD:t],[cp minDQ:t],[cp maxDQ:t],[cp bound:t] ? "YES" : "NO");
           NSLog(@"n : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:n],[cp maxD:n],[cp minDQ:n],[cp maxDQ:n],[cp bound:n] ? "YES" : "NO");
           NSLog(@"k : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:k],[cp maxD:k],[cp minDQ:k],[cp maxDQ:k],[cp bound:k] ? "YES" : "NO");
           NSLog(@"v : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:v],[cp maxD:v],[cp minDQ:v],[cp maxDQ:v],[cp bound:v] ? "YES" : "NO");
           NSLog(@"r : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:r],[cp maxD:r],[cp minDQ:r],[cp maxDQ:r],[cp bound:r] ? "YES" : "NO");
           NSLog(@"er: [%@;%@] (%s)",[cp minQ:er],[cp maxQ:er],[cp bound:er] ? "YES" : "NO");
           NSLog(@"ul: [%@;%@] (%s)",[cp minQ:erUlp],[cp maxQ:erUlp],[cp bound:erUlp] ? "YES" : "NO");
            if (search)
                check_it_d(getDmin(p), getDmin(a), getDmin(b), getDmin(t), getDmin(n), getDmin(k), getDmin(v), getDmin(r), [cp minErrorDQ:r]);
        }];
    }
}


void carbonGas_d(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORRational> zero = [ORRational rationalWith_d:0.0];
        id<ORDoubleVar> a = [ORFactory doubleVar:mdl name:@"a"];
        id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"p"];
        id<ORDoubleVar> b = [ORFactory doubleVar:mdl name:@"b"];
        id<ORDoubleVar> t = [ORFactory doubleVar:mdl name:@"t"];
        id<ORDoubleVar> n = [ORFactory doubleVar:mdl name:@"n"];
        id<ORDoubleVar> k = [ORFactory doubleVar:mdl name:@"k"];
        id<ORDoubleVar> v = [ORFactory doubleVar:mdl low:0.1 up:0.5 elow:zero eup:zero name:@"v"];
        id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
       [zero release];
        
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
               [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
                    [cp floatSplit:i withVars:x];
                }];
            NSLog(@"%@",cp);
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
           NSLog(@"p : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:p],[cp maxD:p],[cp minDQ:p],[cp maxDQ:p],[cp bound:p] ? "YES" : "NO");
           NSLog(@"a : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:a],[cp maxD:a],[cp minDQ:a],[cp maxDQ:a],[cp bound:a] ? "YES" : "NO");
           NSLog(@"b : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:b],[cp maxD:b],[cp minDQ:b],[cp maxDQ:b],[cp bound:b] ? "YES" : "NO");
           NSLog(@"t : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:t],[cp maxD:t],[cp minDQ:t],[cp maxDQ:t],[cp bound:t] ? "YES" : "NO");
           NSLog(@"n : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:n],[cp maxD:n],[cp minDQ:n],[cp maxDQ:n],[cp bound:n] ? "YES" : "NO");
           NSLog(@"k : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:k],[cp maxD:k],[cp minDQ:k],[cp maxDQ:k],[cp bound:k] ? "YES" : "NO");
           NSLog(@"v : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:v],[cp maxD:v],[cp minDQ:v],[cp maxDQ:v],[cp bound:v] ? "YES" : "NO");
           NSLog(@"r : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:r],[cp maxD:r],[cp minDQ:r],[cp maxDQ:r],[cp bound:r] ? "YES" : "NO");
            if (search)
                check_it_d(getDmin(p), getDmin(a), getDmin(b), getDmin(t), getDmin(n), getDmin(k), getDmin(v), getDmin(r), [cp minErrorDQ:r]);
        }];
    }
}

void carbonGas_d_QF(int search, int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      id<ORRational> zero = [ORRational rationalWith_d:0.0];
      id<ORDoubleVar> a = [ORFactory doubleVar:mdl name:@"a"];
      id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"p"];
      id<ORDoubleVar> b = [ORFactory doubleVar:mdl name:@"b"];
      id<ORDoubleVar> t = [ORFactory doubleVar:mdl name:@"t"];
      id<ORDoubleVar> n = [ORFactory doubleVar:mdl name:@"n"];
      id<ORDoubleVar> k = [ORFactory doubleVar:mdl name:@"k"];
      id<ORDoubleVar> v = [ORFactory doubleVar:mdl low:0.1 up:0.5 elow:zero eup:zero name:@"v"];
      id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"r"];
      
      id<ORRationalVar> aQ = [ORFactory rationalVar:mdl name:@"aQ"];
      id<ORRationalVar> pQ = [ORFactory rationalVar:mdl name:@"pQ"];
      id<ORRationalVar> bQ = [ORFactory rationalVar:mdl name:@"bQ"];
      id<ORRationalVar> tQ = [ORFactory rationalVar:mdl name:@"tQ"];
      id<ORRationalVar> nQ = [ORFactory rationalVar:mdl name:@"nQ"];
      id<ORRationalVar> kQ = [ORFactory rationalVar:mdl name:@"kQ"];
      id<ORRationalVar> vQ = [ORFactory rationalVar:mdl name:@"vQ"];
      id<ORRationalVar> rQ = [ORFactory rationalVar:mdl name:@"rQ"];
      id<ORRationalVar> rq = [ORFactory rationalVar:mdl name:@"rq"];
      id<ORRationalVar> er = [ORFactory rationalVar:mdl name:@"er"];
      id<ORRationalVar> eR = [ORFactory errorVar:mdl of:r];
      
      [mdl add:[ORFactory channel:a with:aQ]];
      [mdl add:[ORFactory channel:p with:pQ]];
      [mdl add:[ORFactory channel:b with:bQ]];
      [mdl add:[ORFactory channel:t with:tQ]];
      [mdl add:[ORFactory channel:n with:nQ]];
      [mdl add:[ORFactory channel:k with:kQ]];
      [mdl add:[ORFactory channel:v with:vQ]];
      [mdl add:[ORFactory channel:r with:rq]];

      
      [mdl add:[a set: @(0.401)]];
      [mdl add:[p set: @(3.5e7)]];
      [mdl add:[b set: @(42.7e-6)]];
      [mdl add:[t set: @(300.0)]];
      [mdl add:[n set: @(1000.0)]];
      [mdl add:[k set: @(1.3806503e-23)]];
      
      [mdl add:[r set: [[[p plus: [[a mul: [n div: v]] mul: [n div: v]]] mul: [v sub: [n mul: b]]] sub: [[k mul: n] mul: t]]]];
      
      [mdl add:[rQ set: [[[pQ plus: [[aQ mul: [nQ div: vQ]] mul: [nQ div: vQ]]] mul: [vQ sub: [nQ mul: bQ]]] sub: [[kQ mul: nQ] mul: tQ]]]];
      
      [mdl add:[er set: [rQ sub: rq]]];

      [zero set_d:0];
      [mdl add:[er eq:eR]];
      [mdl add:[[er abs] geq:zero]];
      [zero release];
      
      
      NSLog(@"model: %@",mdl);
      id<CPProgram> cp = [ORFactory createCPProgram:mdl];
      id<ORDoubleVarArray> vs = [mdl doubleVars];
      id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
      
      [cp solve:^{
         if (search)
            [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
               [cp floatSplit:i withVars:x];
            }];
         NSLog(@"%@",cp);
         /* format of 8.8e to have the same value displayed as in FLUCTUAT */
         /* Use printRational(ORRational r) to print a rational inside the solver */
         NSLog(@"p : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:p],[cp maxD:p],[cp minDQ:p],[cp maxDQ:p],[cp bound:p] ? "YES" : "NO");
         NSLog(@"a : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:a],[cp maxD:a],[cp minDQ:a],[cp maxDQ:a],[cp bound:a] ? "YES" : "NO");
         NSLog(@"b : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:b],[cp maxD:b],[cp minDQ:b],[cp maxDQ:b],[cp bound:b] ? "YES" : "NO");
         NSLog(@"t : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:t],[cp maxD:t],[cp minDQ:t],[cp maxDQ:t],[cp bound:t] ? "YES" : "NO");
         NSLog(@"n : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:n],[cp maxD:n],[cp minDQ:n],[cp maxDQ:n],[cp bound:n] ? "YES" : "NO");
         NSLog(@"k : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:k],[cp maxD:k],[cp minDQ:k],[cp maxDQ:k],[cp bound:k] ? "YES" : "NO");
         NSLog(@"v : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:v],[cp maxD:v],[cp minDQ:v],[cp maxDQ:v],[cp bound:v] ? "YES" : "NO");
         NSLog(@"r : [%20.20e;%20.20e]±[%@;%@] (%s)",[cp minD:r],[cp maxD:r],[cp minDQ:r],[cp maxDQ:r],[cp bound:r] ? "YES" : "NO");
         NSLog(@"");
         NSLog(@"pQ: [%@;%@] (%s)",[cp minQ:pQ],[cp maxQ:pQ],[cp bound:pQ] ? "YES" : "NO");
         NSLog(@"aQ: [%@;%@] (%s)",[cp minQ:aQ],[cp maxQ:aQ],[cp bound:aQ] ? "YES" : "NO");
         NSLog(@"bQ: [%@;%@] (%s)",[cp minQ:bQ],[cp maxQ:bQ],[cp bound:bQ] ? "YES" : "NO");
         NSLog(@"tQ: [%@;%@] (%s)",[cp minQ:tQ],[cp maxQ:tQ],[cp bound:tQ] ? "YES" : "NO");
         NSLog(@"nQ: [%@;%@] (%s)",[cp minQ:nQ],[cp maxQ:nQ],[cp bound:nQ] ? "YES" : "NO");
         NSLog(@"kQ: [%@;%@] (%s)",[cp minQ:kQ],[cp maxQ:kQ],[cp bound:kQ] ? "YES" : "NO");
         NSLog(@"vQ: [%@;%@] (%s)",[cp minQ:vQ],[cp maxQ:vQ],[cp bound:vQ] ? "YES" : "NO");
         NSLog(@"rQ: [%@;%@] (%s)",[cp minQ:rQ],[cp maxQ:rQ],[cp bound:rQ] ? "YES" : "NO");
         NSLog(@"er: [%@;%@] (%s)",[cp minQ:er],[cp maxQ:er],[cp bound:er] ? "YES" : "NO");

         if (search)
            check_it_d(getDmin(p), getDmin(a), getDmin(b), getDmin(t), getDmin(n), getDmin(k), getDmin(v), getDmin(r), [cp minErrorDQ:r]);
      }];
   }
}

void check_it_f(float p, float a, float b, float t, float n, float k, float v, float r, id<ORRational> er) {
    float cr = (((p + ((a * (n/v)) * (n/v))) * (v - (n * b))) - ((k * n) * t));
    mpq_t pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1;
    
    if (cr != r)
        printf("WRONG: r = % 20.20e while cr = % 20.20e\n", r, cr);
    
    mpq_inits(pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1, NULL);
    mpq_set_d(pq, p);
    mpq_set_d(aq, a);
    mpq_set_d(bq, b);
    mpq_set_d(tq, t);
    mpq_set_d(nq, n);
    mpq_set_d(kq, k);
    mpq_set_d(vq, v);
    mpq_div(tmp0, nq, vq);
    mpq_mul(tmp1, tmp0, tmp0);
    mpq_mul(rq, tmp1, aq);
    mpq_add(rq, rq, pq);
    mpq_mul(tmp0, nq, bq);
    mpq_sub(tmp1, vq, tmp0);
    mpq_mul(rq, rq, tmp1);
    mpq_mul(tmp0, kq, nq);
    mpq_mul(tmp1, tmp0, tq);
    mpq_sub(rq, rq, tmp1);
    mpq_set_d(tmp0, r);
    mpq_sub(tmp1, rq, tmp0);
    if (mpq_cmp(tmp1, er.rational) != 0)
        printf("WRONG: er = % 20.20e while cer = % 20.20e\n", mpq_get_d(er.rational), mpq_get_d(tmp1));
    mpq_clears(pq, aq, bq, tq, nq, kq, vq, rq, tmp0, tmp1, NULL);
}

void carbonGas_f(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORRational> zero = [ORRational rationalWith_d:0.0];
        id<ORFloatVar> p = [ORFactory floatVar:mdl name:@"p"];
        id<ORFloatVar> a = [ORFactory floatVar:mdl name:@"a"];
        id<ORFloatVar> b = [ORFactory floatVar:mdl name:@"b"];
        id<ORFloatVar> t = [ORFactory floatVar:mdl name:@"t"];
        id<ORFloatVar> n = [ORFactory floatVar:mdl name:@"n"];
        id<ORFloatVar> k = [ORFactory floatVar:mdl name:@"k"];
        id<ORFloatVar> v = [ORFactory floatVar:mdl  low:0.1f up:0.5f elow:zero eup:zero name:@"v"];
        id<ORFloatVar> r = [ORFactory floatVar:mdl name:@"r"];
        [zero release];
        
        //[mdl add:[v set: @(0.5f)]];
        [mdl add:[p set: @(35000000.0f)]];
        [mdl add:[a set: @(0.401f)]];
        [mdl add:[b set: @(4.27e-05f)]];
        [mdl add:[t set: @(300.0f)]];
        [mdl add:[n set: @(1000.0f)]];
        [mdl add:[k set: @(1.3806503e-23f)]];
        
        [mdl add:[r set: [[[p plus: [[a mul: [n div: v]] mul: [n div: v]]] mul: [v sub: [n mul: b]]] sub: [[k mul: n] mul: t]]]];
        
        NSLog(@"model: %@",mdl);
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORFloatVarArray> vs = [mdl floatVars];
        id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
       
        [cp solve:^{
            if (search)
               [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
                    [cp floatSplit:i withVars:x];
                }];
            NSLog(@"%@",cp);
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
           NSLog(@"p : [%8.8e;%8.8e]±[%@;%@] (%s)",[cp minF:p],[cp maxF:p],[cp minFQ:p],[cp maxFQ:p],[cp bound:p] ? "YES" : "NO");
           NSLog(@"a : [%8.8e;%8.8e]±[%@;%@] (%s)",[cp minF:a],[cp maxF:a],[cp minFQ:a],[cp maxFQ:a],[cp bound:a] ? "YES" : "NO");
           NSLog(@"b : [%8.8e;%8.8e]±[%@;%@] (%s)",[cp minF:b],[cp maxF:b],[cp minFQ:b],[cp maxFQ:b],[cp bound:b] ? "YES" : "NO");
           NSLog(@"t : [%8.8e;%8.8e]±[%@;%@] (%s)",[cp minF:t],[cp maxF:t],[cp minFQ:t],[cp maxFQ:t],[cp bound:t] ? "YES" : "NO");
           NSLog(@"n : [%8.8e;%8.8e]±[%@;%@] (%s)",[cp minF:n],[cp maxF:n],[cp minFQ:n],[cp maxFQ:n],[cp bound:n] ? "YES" : "NO");
           NSLog(@"k : [%8.8e;%8.8e]±[%@;%@] (%s)",[cp minF:k],[cp maxF:k],[cp minFQ:k],[cp maxFQ:k],[cp bound:k] ? "YES" : "NO");
           NSLog(@"v : [%8.8e;%8.8e]±[%@;%@] (%s)",[cp minF:v],[cp maxF:v],[cp minFQ:v],[cp maxFQ:v],[cp bound:v] ? "YES" : "NO");
           NSLog(@"r : [%8.8e;%8.8e]±[%@;%@] (%s)",[cp minF:r],[cp maxF:r],[cp minFQ:r],[cp maxFQ:r],[cp bound:r] ? "YES" : "NO");
           if (search)
                check_it_f(getFmin(p), getFmin(a), getFmin(b), getFmin(t), getFmin(n), getFmin(k), getFmin(v), getFmin(r), [cp minErrorFQ:r]);
        }];
    }
}


void simple(int search, int argc, const char * argv[]) {
    @autoreleasepool {
        /* Creation of model */
        id<ORModel> mdl = [ORFactory createModel];
        
        /* Declaration of rational numbers */
        id<ORRational> zero = [[ORRational alloc] init];
        
        /* Initialization of rational numbers */
        [zero setZero];
        
        /* Declaration of model variables */
        id<ORDoubleVar> v = [ORFactory doubleInputVar:mdl low:1 up:2 name:@"x"];
        id<ORDoubleVar> p = [ORFactory doubleVar:mdl name:@"a"];
        id<ORDoubleVar> a = [ORFactory doubleConstantVar:mdl value:0.2 string:@"2/10" name:@"b"];
        id<ORDoubleVar> r = [ORFactory doubleVar:mdl name:@"z"];
        id<ORRationalVar> er = [ORFactory errorVar:mdl of:r];
       id<ORRationalVar> erUlp = [ORFactory rationalVar:mdl name:@"t"];
       id<ORRationalVar> rQ = [ORFactory rationalVar:mdl from:r];
        
        /* Initialization of constants */
        [mdl add:[p set: @(4.0)]];
        
        /* Declaration of constraints */
       [mdl add:[r set: [[p mul: v] div: [a plus: v]]]];
       
       [zero set_d:0];
       //[mdl add: [r gt: @(1.0e+07)]];
       //[mdl add:[er eq: zero]];
       [mdl add: [[rQ plus: er] eq: rQ]];

        NSLog(@"model: %@",mdl);
        id<CPProgram> cp = [ORFactory createCPProgram:mdl];
        id<ORDoubleVarArray> vs = [mdl doubleVars];
        id<ORDisabledVarArray> vars = [ORFactory disabledFloatVarArray:vs engine:[cp engine]];
       
        [cp solve:^{
            if (search)
               [cp lexicalOrderedSearch:vars do:^(ORUInt i, id<ORDisabledVarArray> x) {
                    [cp floatSplit:i withVars:x];
                }];
            NSLog(@"%@",cp);
            /* format of 8.8e to have the same value displayed as in FLUCTUAT */
            /* Use printRational(ORRational r) to print a rational inside the solver */
           NSLog(@"a : [%1.10e;%1.10e]±[%@;%@] (%s)",[cp minD:p],[cp maxD:p],[cp minDQ:p],[cp maxDQ:p],[cp bound:p] ? "YES" : "NO");
           NSLog(@"b : [%1.10e;%1.10e]±[%@;%@] (%s)",[cp minD:a],[cp maxD:a],[cp minDQ:a],[cp maxDQ:a],[cp bound:a] ? "YES" : "NO");
           NSLog(@"x : [%1.10e;%1.10e]±[%@;%@] (%s)",[cp minD:v],[cp maxD:v],[cp minDQ:v],[cp maxDQ:v],[cp bound:v] ? "YES" : "NO");
           NSLog(@"z : [%1.10e;%1.10e]±[%@;%@] (%s)",[cp minD:r],[cp maxD:r],[cp minDQ:r],[cp maxDQ:r],[cp bound:r] ? "YES" : "NO");
        }];
    }
}

int main(int argc, const char * argv[]) {
   LOO_MEASURE_TIME(@"foo"){
      //carbonGas_f(0, argc, argv);
      //carbonGas_d(0, argc, argv);
//      carbonGas_d_c(0, argc, argv);
      simple(0, argc, argv);
      //motivating_d_c(0, argc, argv);
      //carbonGas_d_QF(1, argc, argv);
   }
    return 0;
}
