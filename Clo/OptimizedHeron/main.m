//
//  main.m
//  OptimizedHeron
//
//  Created by Zitoun on 28/07/2016.
//
//
#import <ORProgram/ORProgram.h>


extern float check_solution(float a, float b, float c, float c_aire);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORFloatRange> ra = [ORFactory floatRange:mdl low:5.0f up:10.0f];
        id<ORFloatRange> rb = [ORFactory floatRange:mdl low:0.f up:5.f];
        id<ORFloatRange> rc = [ORFactory floatRange:mdl low:0.f up:5.0f];
        id<ORFloatVar> a = [ORFactory floatVar:mdl domain:ra];
        id<ORFloatVar> b = [ORFactory floatVar:mdl domain:rb];
        id<ORFloatVar> c = [ORFactory floatVar:mdl domain:rc];
        id<ORFloatVar> squaredArea = [ORFactory floatVar:mdl];
        
        //id<ORFloatVarArray> vars = [mdl floatVars];
        id<ORFloatVarArray> vars = [ORFactory floatVarArray:mdl range:RANGE(mdl, 0, 2)];
        vars[0] = a;
        vars[1] = b;
        vars[2] = c;
        
        
      /*   [mdl add:[a eq:@(5.798607349395751953e+00)]];
        [mdl add:[b eq:@(3.982201576232910156e+00)]];
        [mdl add:[c eq:@(1.816406250000000000e+00)]];
        //*/
        // a > 0 & b > 0 & c > 0
       ///*
        [mdl add:[a gt:@(0.f)]];
        [mdl add:[b gt:@(0.f)]];
        [mdl add:[c gt:@(0.f)]];
/**/
       
       //a + b > c & b + c > a & a + c > b
       ///*
        [mdl add:[[a plus:c] gt:b]];
        [mdl add:[[a plus:b] gt:c]];
        [mdl add:[[b plus:c] gt:a]];
        /**/
        
        //a > b > c
        [mdl add:[a gt:b]];
        [mdl add:[b gt:c]];
        /**/
        
        //squared_area = (((a+(b+c))*(c-(a-b))*(c+(a-b))*(a+(b-c)))//*16.0f)
        [mdl add:[squaredArea eq:[[
                                    [[
                                      [a plus:[b plus:c]]
                                     mul:[c sub:[a sub:b]]]
                                     mul:[c plus:[a sub:b]]]
                                     mul:[a plus:[b sub:c]]]
                           div:@(16.0f)]
                ]];

       [mdl add:[squaredArea lt:@(1e-5f)]]; /* */
        NSLog(@"model %@",mdl);
        id<CPProgram> p = [ORFactory createCPProgram:mdl];
        [p solveAll:^{
            NSLog(@"hello");
            [p floatSplitArrayOrderedByDomSize: vars];
            //[p floatSplitArray:vars];
            NSLog(@"Solver: %@",p);
             NSLog(@"a : %@ (%s)",[p concretize:a],[p bound:a] ? "YES" : "NO");
            NSLog(@"b : %@ (%s)",[p concretize:b],[p bound:b] ? "YES" : "NO");
            NSLog(@"c : %@ (%s)",[p concretize:c],[p bound:c] ? "YES" : "NO");
            NSLog(@"squaredArea : %@ (%s)",[p concretize:squaredArea],[p bound:squaredArea] ? "YES" : "NO");
           /*
            printf("\nObjective CP \n\na = %16.16e [%4X]\nb = %16.16e [%4X]\nc = %16.16e [%4X]\nsquared_area = %16.16e [%4X]n\n\n", aa, *aptr, bb, *bptr,cc, *cptr, sq, *sqptr);
            */
            check_solution([p floatValue:a],[p floatValue:b], [p floatValue:c], [p floatValue:squaredArea]);
        }];
        NSLog(@"Solver: %@",p);;
        
    }
    return 0;
}
