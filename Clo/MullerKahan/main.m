#import <ORProgram/ORProgram.h>
#import "ORCmdLineArgs.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
        [args measure:^struct ORResult(){
            
        id<ORModel> model = [ORFactory createModel];
        
        id<ORFloatVar> x0_0 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_0 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_0 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_1 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_1 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_1 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_2 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_2 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_2 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_3 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_3 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_3 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_4 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_4 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_4 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_5 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_5 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_5 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_6 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_6 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_6 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_7 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_7 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_7 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_8 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_8 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_8 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_9 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_9 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_9 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_10 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_10 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_10 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_11 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_11 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_11 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_12 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_12 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_12 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_13 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_13 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_13 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_14 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_14 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_14 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_15 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_15 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_15 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_16 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_16 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_16 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_17 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_17 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_17 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_18 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_18 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_18 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_19 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_19 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_19 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_20 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_20 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_20 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_21 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_21 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_21 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_22 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_22 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_22 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_23 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_23 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_23 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_24 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_24 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_24 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_25 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_25 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_25 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_26 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_26 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_26 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_27 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_27 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_27 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_28 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_28 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_28 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_29 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_29 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_29 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_30 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_30 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_30 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_31 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_31 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_31 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_32 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_32 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_32 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_33 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_33 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_33 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_34 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_34 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_34 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_35 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_35 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_35 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_36 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_36 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_36 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_37 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_37 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_37 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_38 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_38 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_38 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_39 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_39 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_39 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_40 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_40 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_40 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_41 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_41 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_41 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_42 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_42 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_42 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_43 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_43 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_43 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_44 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_44 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_44 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_45 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_45 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_45 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_46 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_46 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_46 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_47 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_47 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_47 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_48 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_48 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_48 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_49 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_49 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_49 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_50 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_50 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_50 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_51 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_51 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_51 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_52 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_52 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_52 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_53 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_53 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_53 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_54 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_54 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_54 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_55 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_55 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_55 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_56 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_56 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_56 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_57 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_57 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_57 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_58 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_58 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_58 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_59 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_59 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_59 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_60 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_60 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_60 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_61 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_61 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_61 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_62 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_62 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_62 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_63 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_63 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_63 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_64 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_64 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_64 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_65 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_65 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_65 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_66 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_66 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_66 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_67 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_67 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_67 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_68 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_68 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_68 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_69 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_69 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_69 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_70 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_70 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_70 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_71 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_71 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_71 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_72 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_72 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_72 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_73 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_73 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_73 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_74 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_74 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_74 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_75 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_75 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_75 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_76 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_76 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_76 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_77 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_77 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_77 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_78 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_78 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_78 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_79 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_79 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_79 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_80 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_80 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_80 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_81 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_81 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_81 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_82 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_82 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_82 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_83 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_83 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_83 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_84 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_84 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_84 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_85 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_85 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_85 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_86 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_86 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_86 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_87 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_87 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_87 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_88 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_88 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_88 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_89 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_89 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_89 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_90 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_90 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_90 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_91 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_91 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_91 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_92 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_92 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_92 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_93 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_93 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_93 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_94 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_94 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_94 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_95 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_95 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_95 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_96 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_96 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_96 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_97 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_97 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_97 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_98 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_98 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_98 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_99 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_99 = [ORFactory floatVar:model];
        id<ORFloatVar> x2_99 = [ORFactory floatVar:model];
        id<ORFloatVar> x0_100 = [ORFactory floatVar:model];
        id<ORFloatVar> x1_100 = [ORFactory floatVar:model];
        
        id<ORExpr> expr_0 = [ORFactory float:model value:111.f];
        id<ORExpr> expr_1 = [ORFactory float:model value:1130.f];
        id<ORExpr> expr_2 = [ORFactory float:model value:3000.f];
        
        ORFloat v0 = (11.0f / 2.0f);
        ORFloat v1 = (61.0f / 11.0f);
        
        [model add:[x0_0  eq: @(v0)]];
        [model add:[x1_0  eq: @(v1)]];
        [model add:[x2_0  eq: [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_0 ]] div: x1_0]]]];
        [model add:[x0_1  eq: x1_0]];
        [model add:[x1_1  eq: x2_0]];
        [model add:[x2_1  eq: [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_1 ]] div: x1_1]]]];
        [model add:[x0_2  eq: x1_1]];
        [model add:[x1_2  eq: x2_1]];
        [model add:[x2_2  eq: [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_2 ]] div: x1_2]]]];
        [model add:[x0_3  eq: x1_2]];
        [model add:[x1_3  eq: x2_2]];
        [model add:[x2_3  eq: [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_3 ]] div: x1_3]]]];
        [model add:[x0_4  eq: x1_3]];
        [model add:[x1_4  eq: x2_3]];
        [model add:[x2_4  eq: [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_4 ]] div: x1_4]]]];
        [model add:[x0_5  eq: x1_4]];
        [model add:[x1_5  eq: x2_4]];
        [model add:[x2_5  eq: [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_5 ]] div: x1_5]]]];
        [model add:[x0_6  eq: x1_5]];
        [model add:[x1_6  eq: x2_5]];
        [model add:[x2_6  eq: [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_6 ]] div: x1_6]]]];
        [model add:[x0_7  eq: x1_6]];
        [model add:[x1_7  eq: x2_6]];
        [model add:[x2_7  eq: [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_7 ]] div: x1_7]]]];
        [model add:[x0_8  eq: x1_7]];
        [model add:[x1_8  eq: x2_7]];
        [model add:[x2_8  eq: [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_8 ]] div: x1_8]]]];
        [model add:[x0_9  eq: x1_8]];
        [model add:[x1_9  eq: x2_8]];
        [model add:[x2_9  eq: [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_9 ]] div: x1_9]]]];
        [model add:[x0_10 eq:  x1_9]];
        [model add:[x1_10 eq:  x2_9]];
        [model add:[x2_10 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_10 ]] div: x1_10]]]];
        [model add:[x0_11 eq:  x1_10]];
        [model add:[x1_11 eq:  x2_10]];
        [model add:[x2_11 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_11 ]] div: x1_11]]]];
        [model add:[x0_12 eq:  x1_11]];
        [model add:[x1_12 eq:  x2_11]];
        [model add:[x2_12 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_12 ]] div: x1_12]]]];
        [model add:[x0_13 eq:  x1_12]];
        [model add:[x1_13 eq:  x2_12]];
        [model add:[x2_13 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_13 ]] div: x1_13]]]];
        [model add:[x0_14 eq:  x1_13]];
        [model add:[x1_14 eq:  x2_13]];
        [model add:[x2_14 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_14 ]] div: x1_14]]]];
        [model add:[x0_15 eq:  x1_14]];
        [model add:[x1_15 eq:  x2_14]];
        [model add:[x2_15 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_15 ]] div: x1_15]]]];
        [model add:[x0_16 eq:  x1_15]];
        [model add:[x1_16 eq:  x2_15]];
        [model add:[x2_16 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_16 ]] div: x1_16]]]];
        [model add:[x0_17 eq:  x1_16]];
        [model add:[x1_17 eq:  x2_16]];
        [model add:[x2_17 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_17 ]] div: x1_17]]]];
        [model add:[x0_18 eq:  x1_17]];
        [model add:[x1_18 eq:  x2_17]];
        [model add:[x2_18 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_18 ]] div: x1_18]]]];
        [model add:[x0_19 eq:  x1_18]];
        [model add:[x1_19 eq:  x2_18]];
        [model add:[x2_19 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_19 ]] div: x1_19]]]];
        [model add:[x0_20 eq:  x1_19]];
        [model add:[x1_20 eq:  x2_19]];
        [model add:[x2_20 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_20 ]] div: x1_20]]]];
        [model add:[x0_21 eq:  x1_20]];
        [model add:[x1_21 eq:  x2_20]];
        [model add:[x2_21 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_21 ]] div: x1_21]]]];
        [model add:[x0_22 eq:  x1_21]];
        [model add:[x1_22 eq:  x2_21]];
        [model add:[x2_22 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_22 ]] div: x1_22]]]];
        [model add:[x0_23 eq:  x1_22]];
        [model add:[x1_23 eq:  x2_22]];
        [model add:[x2_23 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_23 ]] div: x1_23]]]];
        [model add:[x0_24 eq:  x1_23]];
        [model add:[x1_24 eq:  x2_23]];
        [model add:[x2_24 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_24 ]] div: x1_24]]]];
        [model add:[x0_25 eq:  x1_24]];
        [model add:[x1_25 eq:  x2_24]];
        [model add:[x2_25 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_25 ]] div: x1_25]]]];
        [model add:[x0_26 eq:  x1_25]];
        [model add:[x1_26 eq:  x2_25]];
        [model add:[x2_26 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_26 ]] div: x1_26]]]];
        [model add:[x0_27 eq:  x1_26]];
        [model add:[x1_27 eq:  x2_26]];
        [model add:[x2_27 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_27 ]] div: x1_27]]]];
        [model add:[x0_28 eq:  x1_27]];
        [model add:[x1_28 eq:  x2_27]];
        [model add:[x2_28 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_28 ]] div: x1_28]]]];
        [model add:[x0_29 eq:  x1_28]];
        [model add:[x1_29 eq:  x2_28]];
        [model add:[x2_29 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_29 ]] div: x1_29]]]];
        [model add:[x0_30 eq:  x1_29]];
        [model add:[x1_30 eq:  x2_29]];
        [model add:[x2_30 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_30 ]] div: x1_30]]]];
        [model add:[x0_31 eq:  x1_30]];
        [model add:[x1_31 eq:  x2_30]];
        [model add:[x2_31 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_31 ]] div: x1_31]]]];
        [model add:[x0_32 eq:  x1_31]];
        [model add:[x1_32 eq:  x2_31]];
        [model add:[x2_32 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_32 ]] div: x1_32]]]];
        [model add:[x0_33 eq:  x1_32]];
        [model add:[x1_33 eq:  x2_32]];
        [model add:[x2_33 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_33 ]] div: x1_33]]]];
        [model add:[x0_34 eq:  x1_33]];
        [model add:[x1_34 eq:  x2_33]];
        [model add:[x2_34 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_34 ]] div: x1_34]]]];
        [model add:[x0_35 eq:  x1_34]];
        [model add:[x1_35 eq:  x2_34]];
        [model add:[x2_35 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_35 ]] div: x1_35]]]];
        [model add:[x0_36 eq:  x1_35]];
        [model add:[x1_36 eq:  x2_35]];
        [model add:[x2_36 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_36 ]] div: x1_36]]]];
        [model add:[x0_37 eq:  x1_36]];
        [model add:[x1_37 eq:  x2_36]];
        [model add:[x2_37 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_37 ]] div: x1_37]]]];
        [model add:[x0_38 eq:  x1_37]];
        [model add:[x1_38 eq:  x2_37]];
        [model add:[x2_38 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_38 ]] div: x1_38]]]];
        [model add:[x0_39 eq:  x1_38]];
        [model add:[x1_39 eq:  x2_38]];
        [model add:[x2_39 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_39 ]] div: x1_39]]]];
        [model add:[x0_40 eq:  x1_39]];
        [model add:[x1_40 eq:  x2_39]];
        [model add:[x2_40 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_40 ]] div: x1_40]]]];
        [model add:[x0_41 eq:  x1_40]];
        [model add:[x1_41 eq:  x2_40]];
        [model add:[x2_41 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_41 ]] div: x1_41]]]];
        [model add:[x0_42 eq:  x1_41]];
        [model add:[x1_42 eq:  x2_41]];
        [model add:[x2_42 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_42 ]] div: x1_42]]]];
        [model add:[x0_43 eq:  x1_42]];
        [model add:[x1_43 eq:  x2_42]];
        [model add:[x2_43 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_43 ]] div: x1_43]]]];
        [model add:[x0_44 eq:  x1_43]];
        [model add:[x1_44 eq:  x2_43]];
        [model add:[x2_44 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_44 ]] div: x1_44]]]];
        [model add:[x0_45 eq:  x1_44]];
        [model add:[x1_45 eq:  x2_44]];
        [model add:[x2_45 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_45 ] ]div: x1_45]]]];
        [model add:[x0_46 eq:  x1_45]];
        [model add:[x1_46 eq:  x2_45]];
        [model add:[x2_46 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_46 ]] div: x1_46]]]];
        [model add:[x0_47 eq:  x1_46]];
        [model add:[x1_47 eq:  x2_46]];
        [model add:[x2_47 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_47 ]] div: x1_47]]]];
        [model add:[x0_48 eq:  x1_47]];
        [model add:[x1_48 eq:  x2_47]];
        [model add:[x2_48 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_48 ]] div: x1_48]]]];
        [model add:[x0_49 eq:  x1_48]];
        [model add:[x1_49 eq:  x2_48]];
        [model add:[x2_49 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_49 ]] div: x1_49]]]];
        [model add:[x0_50 eq:  x1_49]];
        [model add:[x1_50 eq:  x2_49]];
        [model add:[x2_50 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_50 ]] div: x1_50]]]];
        [model add:[x0_51 eq:  x1_50]];
        [model add:[x1_51 eq:  x2_50]];
        [model add:[x2_51 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_51 ]] div: x1_51]]]];
        [model add:[x0_52 eq:  x1_51]];
        [model add:[x1_52 eq:  x2_51]];
        [model add:[x2_52 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_52 ]] div: x1_52]]]];
        [model add:[x0_53 eq:  x1_52]];
        [model add:[x1_53 eq:  x2_52]];
        [model add:[x2_53 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_53 ]] div: x1_53]]]];
        [model add:[x0_54 eq:  x1_53]];
        [model add:[x1_54 eq:  x2_53]];
        [model add:[x2_54 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_54 ]] div: x1_54]]]];
        [model add:[x0_55 eq:  x1_54]];
        [model add:[x1_55 eq:  x2_54]];
        [model add:[x2_55 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_55 ]] div: x1_55]]]];
        [model add:[x0_56 eq:  x1_55]];
        [model add:[x1_56 eq:  x2_55]];
        [model add:[x2_56 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_56 ]] div: x1_56]]]];
        [model add:[x0_57 eq:  x1_56]];
        [model add:[x1_57 eq:  x2_56]];
        [model add:[x2_57 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_57 ]] div: x1_57]]]];
        [model add:[x0_58 eq:  x1_57]];
        [model add:[x1_58 eq:  x2_57]];
        [model add:[x2_58 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_58 ]] div: x1_58]]]];
        [model add:[x0_59 eq:  x1_58]];
        [model add:[x1_59 eq:  x2_58]];
        [model add:[x2_59 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_59 ]] div: x1_59]]]];
        [model add:[x0_60 eq:  x1_59]];
        [model add:[x1_60 eq:  x2_59]];
        [model add:[x2_60 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_60 ]] div: x1_60]]]];
        [model add:[x0_61 eq:  x1_60]];
        [model add:[x1_61 eq:  x2_60]];
        [model add:[x2_61 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_61 ]] div: x1_61]]]];
        [model add:[x0_62 eq:  x1_61]];
        [model add:[x1_62 eq:  x2_61]];
        [model add:[x2_62 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_62 ]] div: x1_62]]]];
        [model add:[x0_63 eq:  x1_62]];
        [model add:[x1_63 eq:  x2_62]];
        [model add:[x2_63 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_63 ]] div: x1_63]]]];
        [model add:[x0_64 eq:  x1_63]];
        [model add:[x1_64 eq:  x2_63]];
        [model add:[x2_64 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_64 ]] div: x1_64]]]];
        [model add:[x0_65 eq:  x1_64]];
        [model add:[x1_65 eq:  x2_64]];
        [model add:[x2_65 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_65 ]] div: x1_65]]]];
        [model add:[x0_66 eq:  x1_65]];
        [model add:[x1_66 eq:  x2_65]];
        [model add:[x2_66 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_66 ]] div: x1_66]]]];
        [model add:[x0_67 eq:  x1_66]];
        [model add:[x1_67 eq:  x2_66]];
        [model add:[x2_67 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_67 ]] div: x1_67]]]];
        [model add:[x0_68 eq:  x1_67]];
        [model add:[x1_68 eq:  x2_67]];
        [model add:[x2_68 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_68 ]] div: x1_68]]]];
        [model add:[x0_69 eq:  x1_68]];
        [model add:[x1_69 eq:  x2_68]];
        [model add:[x2_69 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_69 ]] div: x1_69]]]];
        [model add:[x0_70 eq:  x1_69]];
        [model add:[x1_70 eq:  x2_69]];
        [model add:[x2_70 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_70 ]] div: x1_70]]]];
        [model add:[x0_71 eq:  x1_70]];
        [model add:[x1_71 eq:  x2_70]];
        [model add:[x2_71 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_71 ]] div: x1_71]]]];
        [model add:[x0_72 eq:  x1_71]];
        [model add:[x1_72 eq:  x2_71]];
        [model add:[x2_72 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_72 ]] div: x1_72]]]];
        [model add:[x0_73 eq:  x1_72]];
        [model add:[x1_73 eq:  x2_72]];
        [model add:[x2_73 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_73 ]] div: x1_73]]]];
        [model add:[x0_74 eq:  x1_73]];
        [model add:[x1_74 eq:  x2_73]];
        [model add:[x2_74 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_74 ]] div: x1_74]]]];
        [model add:[x0_75 eq:  x1_74]];
        [model add:[x1_75 eq:  x2_74]];
        [model add:[x2_75 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_75 ]] div: x1_75]]]];
        [model add:[x0_76 eq:  x1_75]];
        [model add:[x1_76 eq:  x2_75]];
        [model add:[x2_76 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_76 ]] div: x1_76]]]];
        [model add:[x0_77 eq:  x1_76]];
        [model add:[x1_77 eq:  x2_76]];
        [model add:[x2_77 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_77 ]] div: x1_77]]]];
        [model add:[x0_78 eq:  x1_77]];
        [model add:[x1_78 eq:  x2_77]];
        [model add:[x2_78 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_78 ]] div: x1_78]]]];
        [model add:[x0_79 eq:  x1_78]];
        [model add:[x1_79 eq:  x2_78]];
        [model add:[x2_79 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_79 ]] div: x1_79]]]];
        [model add:[x0_80 eq:  x1_79]];
        [model add:[x1_80 eq:  x2_79]];
        [model add:[x2_80 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_80 ]] div: x1_80]]]];
        [model add:[x0_81 eq:  x1_80]];
        [model add:[x1_81 eq:  x2_80]];
        [model add:[x2_81 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_81 ]] div: x1_81]]]];
        [model add:[x0_82 eq:  x1_81]];
        [model add:[x1_82 eq:  x2_81]];
        [model add:[x2_82 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_82 ]] div: x1_82]]]];
        [model add:[x0_83 eq:  x1_82]];
        [model add:[x1_83 eq:  x2_82]];
        [model add:[x2_83 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_83 ]] div: x1_83]]]];
        [model add:[x0_84 eq:  x1_83]];
        [model add:[x1_84 eq:  x2_83]];
        [model add:[x2_84 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_84 ]] div: x1_84]]]];
        [model add:[x0_85 eq:  x1_84]];
        [model add:[x1_85 eq:  x2_84]];
        [model add:[x2_85 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_85 ]] div: x1_85]]]];
        [model add:[x0_86 eq:  x1_85]];
        [model add:[x1_86 eq:  x2_85]];
        [model add:[x2_86 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_86 ]] div: x1_86]]]];
        [model add:[x0_87 eq:  x1_86]];
        [model add:[x1_87 eq:  x2_86]];
        [model add:[x2_87 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_87 ]] div: x1_87]]]];
        [model add:[x0_88 eq:  x1_87]];
        [model add:[x1_88 eq:  x2_87]];
        [model add:[x2_88 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_88 ]] div: x1_88]]]];
        [model add:[x0_89 eq:  x1_88]];
        [model add:[x1_89 eq:  x2_88]];
        [model add:[x2_89 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_89 ]] div: x1_89]]]];
        [model add:[x0_90 eq:  x1_89]];
        [model add:[x1_90 eq:  x2_89]];
        [model add:[x2_90 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_90 ]] div: x1_90]]]];
        [model add:[x0_91 eq:  x1_90]];
        [model add:[x1_91 eq:  x2_90]];
        [model add:[x2_91 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_91 ]] div: x1_91]]]];
        [model add:[x0_92 eq:  x1_91]];
        [model add:[x1_92 eq:  x2_91]];
        [model add:[x2_92 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_92 ]] div: x1_92]]]];
        [model add:[x0_93 eq:  x1_92]];
        [model add:[x1_93 eq:  x2_92]];
        [model add:[x2_93 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_93 ]] div: x1_93]]]];
        [model add:[x0_94 eq:  x1_93]];
        [model add:[x1_94 eq:  x2_93]];
        [model add:[x2_94 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_94 ]] div: x1_94]]]];
        [model add:[x0_95 eq:  x1_94]];
        [model add:[x1_95 eq:  x2_94]];
        [model add:[x2_95 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_95 ]] div: x1_95]]]];
        [model add:[x0_96 eq:  x1_95]];
        [model add:[x1_96 eq:  x2_95]];
        [model add:[x2_96 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_96 ]] div: x1_96]]]];
        [model add:[x0_97 eq:  x1_96]];
        [model add:[x1_97 eq:  x2_96]];
        [model add:[x2_97 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_97 ]] div: x1_97]]]];
        [model add:[x0_98 eq:  x1_97]];
        [model add:[x1_98 eq:  x2_97]];
        [model add:[x2_98 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_98 ]] div: x1_98]]]];
        [model add:[x0_99 eq:  x1_98]];
        [model add:[x1_99 eq:  x2_98]];
        [model add:[x2_99 eq:  [expr_0 sub:[[expr_1 sub:[expr_2 div: x0_99 ]] div: x1_99]]]];
        [model add:[x0_100 eq: x1_99]];
        [model add:[x1_100 eq: x2_99]];
        
            id<ORFloatVarArray> vars = [model floatVars];
            id<CPProgram> cp = [args makeProgram:model];
            __block bool found = false;
            [cp solveOn:^(id<CPCommonProgram> p) {
                
                
                [args launchHeuristic:((id<CPProgram>)p) restricted:vars];
                for(id<ORFloatVar> v in vars){
                    found &= [p bound: v];
                    NSLog(@"%@ : %f (%s)",v,[p floatValue:v],[p bound:v] ? "YES" : "NO");
                }
                
            } withTimeLimit:[args timeOut]];
            struct ORResult r = REPORT(found, [[cp explorer] nbFailures],[[cp explorer] nbChoices], [[cp engine] nbPropagation]);
            return r;
        }];

    }
    return 0;
}