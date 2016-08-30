//
//  main.m
//  OptimizedHeron
//
//  Created by Zitoun on 28/07/2016.
//
//
#import <ORProgram/ORProgram.h>

void check_solution(float a, float b, float c, float sa_c) {
    float squared_area;
    if(!(a > b && b > c && a + b > c && b + c > a && a + c > b)){
        printf("failed\n");
        abort();
    }
    squared_area = 0.0f;
    if (a <= b + c) {
        float num = ((a+(b+c))*(c-(a-b))*(c+(a-b))*(a+(b-c)));
        squared_area = num/16.0f;
        if(squared_area != sa_c){
            printf("squared_area failed\n");
            abort();
        }
    }
    printf("correct\n");
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORFloatRange> ra = [ORFactory floatRange:mdl low:5.0f up:10.0f];
        id<ORFloatRange> rb = [ORFactory floatRange:mdl low:0.f up:5.f];
        id<ORFloatRange> rc = [ORFactory floatRange:mdl low:0.f up:5.0f];
        id<ORFloatRange> rsquaredArea = [ORFactory floatRange:mdl];
        id<ORFloatVar> a = [ORFactory floatVar:mdl domain:ra];
        id<ORFloatVar> b = [ORFactory floatVar:mdl domain:rb];
        id<ORFloatVar> c = [ORFactory floatVar:mdl domain:rc];
        id<ORFloatVar> squaredArea = [ORFactory floatVar:mdl domain:rsquaredArea];
        
        id<ORFloatVarArray> vars = [mdl floatVars];
        
        // a > 0 & b > 0 & c > 0
        [mdl add:[a gt:@(0.f)]];
        [mdl add:[b gt:@(0.f)]];
        [mdl add:[c gt:@(0.f)]];

       
       //a + b > c & b + c > a & a + c > b
        [mdl add:[[a plus:c] gt:b]];
        [mdl add:[[a plus:b] gt:c]];
        [mdl add:[[b plus:c] gt:a]];

        //a > b > c
        
        [mdl add:[a gt:b]];
        [mdl add:[b gt:c]];
        
        //squared_area = (((a+(b+c))*(c-(a-b))*(c+(a-b))*(a+(b-c)))/16.0f)
      [mdl add:[squaredArea eq:[//[
                                    [[
                                      [a plus:[b plus:c]]
                                     mul:[c sub:[a sub:b]]]
                                     mul:[c plus:[a sub:b]]]
                                     mul:[a plus:[b sub:c]]]
         //                            div:@(16.0f)] 
                                ]];

        //squared_area > (156.25f + 1e-5)
        float v = 156.25f;
        id<ORExpr> fc = [ORFactory float:mdl value:v];
       // [mdl add:[squaredArea gt:[fc plus:@(1e-5f)]]]; /* */
        NSLog(@"model %@",mdl);
        id<CPProgram> p = [ORFactory createCPProgram:mdl];
        [p solve:^{
            NSLog(@"hello");
            [p floatSplitArray:vars];
             NSLog(@"Solver: %@",p);
             NSLog(@"a : %@ (%s)",[p concretize:a],[p bound:a] ? "YES" : "NO");
            NSLog(@"b : %@ (%s)",[p concretize:b],[p bound:b] ? "YES" : "NO");
            NSLog(@"c : %@ (%s)",[p concretize:c],[p bound:c] ? "YES" : "NO");
            NSLog(@"squaredArea : %@ (%s)",[p concretize:squaredArea],[p bound:squaredArea] ? "YES" : "NO");
            check_solution([p floatValue:a],[p floatValue:b], [p floatValue:c], [p floatValue:squaredArea]);
            
      /* */ }];
        NSLog(@"Solver: %@",p);;
        
    }
    return 0;
}
