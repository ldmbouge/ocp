//
//  main.m
//  solvecubic
//
//  Created by Zitoun on 25/07/2016.
//
//


#import <ORProgram/ORProgram.h>

void checkSolution(int a, int b, int c, int c_r, int c_q){
    double q = (a * a - 3 * b);
    double r = (2 * a * a * a - 9 * a * b + 27 * c);
    if(c_q != 0 || c_r !=0 || q != c_q || r != c_r){
        printf("Verification failed");
        abort();
    }
    double Q = q / 9;
    double R = r / 54;
    double Q3 = Q * Q * Q;
    double R2 = R * R;
    double CR2 = 729 * r * r;
    double CQ3 = 2916 * q * q * q;
    if(q != 0 || r != 0){
        printf("Verification failed");
        abort();
    }
}



int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> mdl = [ORFactory createModel];
        id<ORFloatVar> a = [ORFactory floatVar:mdl];
        id<ORFloatVar> b = [ORFactory floatVar:mdl];
        id<ORFloatVar> c = [ORFactory floatVar:mdl];
        id<ORFloatVar> q = [ORFactory floatVar:mdl];
        id<ORFloatVar> r = [ORFactory floatVar:mdl];
        id<ORFloatVar> Q = [ORFactory floatVar:mdl];
        id<ORFloatVar> R = [ORFactory floatVar:mdl];
        id<ORFloatVar> Q3 = [ORFactory floatVar:mdl];
        id<ORFloatVar> R2 = [ORFactory floatVar:mdl];
        id<ORFloatVar> CQ3 = [ORFactory floatVar:mdl];
        id<ORFloatVar> CR2 = [ORFactory floatVar:mdl];
      
        id<ORFloatVarArray> vars = [mdl floatVars];
        
        [mdl add:[a eq: @(15.0f)]];
        [mdl add:[b eq: @(75.0f)]];
        //double q = (a * a - 3 * b);
        //[mdl add:[q eq:[[a plus:@(2.f)] plus: b]]];
        [mdl add:[q eq:[[a mul:a] sub:[b mul:@(3.0f)]]]];
        //double r = (2 * a * a * a - 9 * a * b + 27 * c);
       [mdl add:[r eq:[[[[[a mul:@(2.0f)] mul:a] mul:a] sub:[[a mul:@(9.0f)] mul:b]] plus:[c mul:@(27.0f)]]]];
        //double Q = q / 9;
        [mdl add:[Q eq: [q div:@(9.0f)]]];
        //double R = r / 54
        [mdl add:[R eq: [r div:@(54.0f)]]];
        //model.add(Q3 = Q * Q * Q);
        [mdl add:[Q3 eq:[[Q mul:Q] mul:Q]]];
        //model.add(R2 = R * R);
        [mdl add:[R2 eq:[R mul:R]]];
        //double CR2 = 729 * r * r;
        [mdl add:[CR2 eq: [[r mul:@(729.0f)] mul:r]]];
        //double CQ3 = 2916 * q * q * q;
        [mdl add:[CQ3 eq: [[[q mul:@(2916.0f)] mul:q] mul:q]]];
        
        [mdl add:[Q eq: @(0.0f)]];
        [mdl add:[R eq: @(0.0f)]];
        
        NSLog(@"model: %@",mdl);
        ORFloat d = NAN;
        printf("\n\ntoto = %e %d %d\n\n",INFINITY, (NAN > INFINITY), isnan(d) );
        id<CPProgram> p = [ORFactory createCPProgram:mdl];
        [p solveAll:^{
           // [p floatSplitArray:vars];
            /*[p try:^{
                [p floatLthen:a with:15.0f];
            }
            alt:^{
                [p floatGEqual:a with:15.0f];
            }];*/
            NSLog(@"helloword %@ !",p);
            NSLog(@"a : %@ (%s)",[p concretize:a],[p bound:a] ? "YES" : "NO");
            NSLog(@"b : %@ (%s)",[p concretize:b],[p bound:b] ? "YES" : "NO");
            NSLog(@"c : %@ (%s)",[p concretize:c],[p bound:c] ? "YES" : "NO");
            NSLog(@"r : %@ (%s)",[p concretize:r],[p bound:r] ? "YES" : "NO");
            NSLog(@"q : %@ (%s)",[p concretize:q],[p bound:q] ? "YES" : "NO");
            NSLog(@"R : %@ (%s)",[p concretize:R],[p bound:R] ? "YES" : "NO");
            NSLog(@"Q : %@ (%s)",[p concretize:Q],[p bound:Q] ? "YES" : "NO");
            NSLog(@"Q3 : %@ (%s)",[p concretize:Q3],[p bound:Q3] ? "YES" : "NO");
            NSLog(@"R2 : %@ (%s)",[p concretize:R2],[p bound:R2] ? "YES" : "NO");
            NSLog(@"CQ3 : %@ (%s)",[p concretize:CQ3],[p bound:CQ3] ? "YES" : "NO");
            NSLog(@"CR2 : %@ (%s)",[p concretize:CR2],[p bound:CR2] ? "YES" : "NO");
           // checkSolution([p floatValue:a],[p floatValue:b],[p floatValue:c],[p floatValue:r],[p floatValue:q]);
        }];
    }
    return 0;
}
