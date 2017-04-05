#import <ORProgram/ORProgram.h>
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<ORModel> model = [ORFactory createModel];
        int h = atoi(argv[1]);
        id<ORFloatVar> c_0 = [ORFactory floatVar:model];
        id<ORFloatVar> r_0 = [ORFactory floatVar:model];
        id<ORFloatVar> a_0 = [ORFactory floatVar:model];
        id<ORFloatVar> Q_0 = [ORFactory floatVar:model];
        id<ORFloatVar> R2_0 = [ORFactory floatVar:model];
        id<ORFloatVar> CR2_0 = [ORFactory floatVar:model];
        id<ORFloatVar> CQ3_0 = [ORFactory floatVar:model];
        id<ORFloatVar> Q3_0 = [ORFactory floatVar:model];
        id<ORFloatVar> R_0 = [ORFactory floatVar:model];
        id<ORFloatVar> q_0 = [ORFactory floatVar:model];
        id<ORFloatVar> b_0 = [ORFactory floatVar:model];
        [model add:[q_0 eq: [[a_0 mul: a_0] sub: [b_0 mul:@(3.f)]]]];
        
        [model add:[r_0 eq: [[[[[a_0 mul:@(2.f)] mul: a_0] mul: a_0] sub: [[a_0 mul:@(9.f)] mul: b_0]] plus: [c_0 mul:@(27.f)]]]];
        
        
        [model add:[Q_0 eq: [q_0 div:@(9.f)]]];
        
        [model add:[R_0 eq: [r_0 div:@(54.f)]]];
        
        
        [model add:[Q3_0 eq: [[Q_0 mul:Q_0] mul:Q_0]]];
        
        [model add:[R2_0 eq: [R_0 mul:R_0]]];
        
        
        [model add:[CR2_0 eq: [[r_0 mul:@(729.f)] mul: r_0]]];
        
        [model add:[CQ3_0 eq: [[[q_0 mul:@(2916.f)] mul: q_0] mul: q_0]]];
        
        //assert(!(R == 0 && Q == 0));
        [model add:[R_0 eq:@(0.0f)]];
        [model add:[Q_0 eq:@(0.0f)]]];
        
        id<ORFloatVarArray> vars = [model floatVars];
        id<CPProgram> p = [ORFactory createCPProgram:model];
        [p solve:^{
            switch (h) {
                case 0:
                    [p maxwidthSearch:vars];
                    break;
                case 1:
                    [p minWidthSearch:vars];
                    break;
                case 2:
                    [p maxCardinalitySearch:vars];
                    break;
                case 3:
                    [p minCardinalitySearch:vars];
                    break;
                case 4:
                    [p maxDensitySearch:vars];
                    break;
                case 5:
                    [p minDensitySearch:vars];
                    break;
                case 6:
                    [p maxMagnitudeSearch:vars];
                    break;
                case 7:
                    [p minMagnitudeSearch:vars];
                    break;
                case 8:
                    [p alternateMagnitudeSearch:vars];
                    break;
                case 9:
                    [p floatSplitArrayOrderedByDomSize:vars];
                    break;
                default:
                    [p maxwidthSearch:vars];
                    break;
            };
            for(id<ORFloatVar> v in vars)
                NSLog(@"%@ : %f (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
        }];
    }
    return 0;
}
