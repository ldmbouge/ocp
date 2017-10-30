//
//  TestVtype.m
//  TestVtype
//
//  Created by Zitoun on 25/10/2017.
//
//

#import <XCTest/XCTest.h>

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <ORProgram/CPSolver.h>



@interface TestVtype : XCTestCase

@end

@implementation TestVtype

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testRelationInt {
    id<ORModel> model = [ORFactory createModel];
    
    id<ORIntVar> x = [ORFactory intVar:model domain:RANGE(model,0,10)];
    id<ORIntVar> y = [ORFactory intVar:model domain:RANGE(model,0,10)];
    
    id<ORExpr> gt_expr_cst = [x gt:@(2)];
    id<ORExpr> lt_expr_cst = [x lt:@(2)];
    id<ORExpr> geq_expr_cst = [x geq:@(2)];
    id<ORExpr> leq_expr_cst = [x leq:@(2)];
    id<ORExpr> eq_expr_cst = [x eq:@(2)];
    id<ORExpr> neq_expr_cst = [x neq:@(2)];

    
    XCTAssertEqual(gt_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(lt_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(geq_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(leq_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(eq_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(neq_expr_cst.vtype, ORTBool, @"succes");
    
    id<ORExpr> gt_expr_var = [x gt:y];
    id<ORExpr> lt_expr_var = [x lt:y];
    id<ORExpr> geq_expr_var = [x geq:y];
    id<ORExpr> leq_expr_var = [x leq:y];
    id<ORExpr> eq_expr_var = [x eq:y];
    id<ORExpr> neq_expr_var = [x neq:y];
    
    
    XCTAssertEqual(gt_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(lt_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(geq_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(leq_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(eq_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(neq_expr_var.vtype, ORTBool, @"succes");
}

- (void) testRelationFloat {
    id<ORModel> model = [ORFactory createModel];
    
    id<ORFloatVar> x = [ORFactory floatVar:model];
    id<ORFloatVar> y = [ORFactory floatVar:model];
    
    id<ORExpr> gt_expr_cst = [x gt:@(2.f)];
    id<ORExpr> lt_expr_cst = [x lt:@(2.f)];
    id<ORExpr> geq_expr_cst = [x geq:@(2.f)];
    id<ORExpr> leq_expr_cst = [x leq:@(2.f)];
    id<ORExpr> eq_expr_cst = [x eq:@(2.f)];
    id<ORExpr> neq_expr_cst = [x neq:@(2.f)];
    
    
    XCTAssertEqual(gt_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(lt_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(geq_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(leq_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(eq_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(neq_expr_cst.vtype, ORTBool, @"succes");
    
    id<ORExpr> gt_expr_var = [x gt:y];
    id<ORExpr> lt_expr_var = [x lt:y];
    id<ORExpr> geq_expr_var = [x geq:y];
    id<ORExpr> leq_expr_var = [x leq:y];
    id<ORExpr> eq_expr_var = [x eq:y];
    id<ORExpr> neq_expr_var = [x neq:y];
    
    
    XCTAssertEqual(gt_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(lt_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(geq_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(leq_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(eq_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(neq_expr_var.vtype, ORTBool, @"succes");
}

- (void) testLogicalInt {
    id<ORModel> model = [ORFactory createModel];
    
    id<ORIntVar> b0 = [ORFactory intVar:model domain:RANGE(model,0,1)];
    id<ORIntVar> b1 = [ORFactory intVar:model domain:RANGE(model,0,1)];
    
    id<ORExpr> implyCsts = [b0 imply:b1];
    id<ORExpr> conjCsts = [b0 land:b1];
    id<ORExpr> disjCst = [b0 lor:b1];
    id<ORExpr> negCsts = [b0 neg];
    
    XCTAssertEqual(implyCsts.vtype, ORTBool, @"succes");
    XCTAssertEqual(conjCsts.vtype, ORTBool, @"succes");
    XCTAssertEqual(disjCst.vtype, ORTBool, @"succes");
    XCTAssertEqual(negCsts.vtype, ORTBool, @"succes");
}

- (void) testLogicalFloat {
    id<ORModel> model = [ORFactory createModel];
    
    id<ORFloatVar> x = [ORFactory floatVar:model];
    id<ORIntVar> b = [ORFactory intVar:model domain:RANGE(model,0,1)];
    
    
    id<ORExpr> implyCsts = [b imply:[x gt:@(2.f)]];
    id<ORExpr> conjCsts = [b land:[x gt:@(2.f)]];
    id<ORExpr> disjCst = [b lor:[x gt:@(2.f)]];
    id<ORExpr> negCsts = [[x gt:@(2.f)] neg];
    
    XCTAssertEqual(implyCsts.vtype, ORTBool, @"succes");
    XCTAssertEqual(conjCsts.vtype, ORTBool, @"succes");
    XCTAssertEqual(disjCst.vtype, ORTBool, @"succes");
    XCTAssertEqual(negCsts.vtype, ORTBool, @"succes");
}

- (void) testLogicalComplexeInt {
    id<ORModel> model = [ORFactory createModel];
    
    id<ORIntVar> x = [ORFactory intVar:model domain:RANGE(model,0,10)];
    id<ORIntVar> y = [ORFactory intVar:model domain:RANGE(model,0,10)];
    
    id<ORExpr> and_expr_cst = [[x gt:@(2)] land:[x lt:@(20)]];
    id<ORExpr> lor_expr_cst = [[x geq:@(2)] lor:[x leq:@(-2)]];
    id<ORExpr> imply_expr_cst = [[x eq:@(2)] imply:[x neq:@(2)]];
    id<ORExpr> neg_expr_cst = [[x eq:@(2)] neg];
    
    id<ORExpr> and_expr_var = [[x gt:y] land:[x lt:y]];
    id<ORExpr> lor_expr_var = [[x geq:y] lor:[x leq:y]];
    id<ORExpr> imply_expr_var = [[x eq:y] imply:[x neq:y]];
    id<ORExpr> neg_expr_var = [[x eq:y] neg];
    
    id<ORExpr> and_expr_arithm = [[x eq:[y plus:@(2)]] land:[x lt:y]];
    id<ORExpr> lor_expr_arithm = [[x eq:[y sub:@(2)]] lor:[x leq:y]];
    id<ORExpr> imply_expr_arithm = [[x eq:[y mul:@(2)]] imply:[x neq:y]];
    id<ORExpr> neg_expr_arithm = [[x neq:[y div:@(2)]] neg];
    
    
    XCTAssertEqual(and_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(lor_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(imply_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(neg_expr_cst.vtype, ORTBool, @"succes");
    
    XCTAssertEqual(and_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(lor_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(imply_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(neg_expr_var.vtype, ORTBool, @"succes");
    
    XCTAssertEqual(and_expr_arithm.vtype, ORTBool, @"succes");
    XCTAssertEqual(lor_expr_arithm.vtype, ORTBool, @"succes");
    XCTAssertEqual(imply_expr_arithm.vtype, ORTBool, @"succes");
    XCTAssertEqual(neg_expr_arithm.vtype, ORTBool, @"succes");
    
}

- (void) testLogicalComplexeFloat {
    id<ORModel> model = [ORFactory createModel];
    
    id<ORFloatVar> x = [ORFactory floatVar:model];
    id<ORFloatVar> y = [ORFactory floatVar:model];
    
    id<ORExpr> and_expr_cst = [[x gt:@(2.f)] land:[x lt:@(20.f)]];
    id<ORExpr> lor_expr_cst = [[x geq:@(2.f)] lor:[x leq:@(-2.f)]];
    id<ORExpr> imply_expr_cst = [[x eq:@(2.f)] imply:[x neq:@(2.f)]];
    id<ORExpr> neg_expr_cst = [[x eq:@(2.f)] neg];
    
    id<ORExpr> and_expr_var = [[x gt:y] land:[x lt:y]];
    id<ORExpr> lor_expr_var = [[x geq:y] lor:[x leq:y]];
    id<ORExpr> imply_expr_var = [[x eq:y] imply:[x neq:y]];
    id<ORExpr> neg_expr_var = [[x eq:y] neg];
    
    id<ORExpr> and_expr_arithm = [[x eq:[y plus:@(2.f)]] land:[x lt:y]];
    id<ORExpr> lor_expr_arithm = [[x eq:[y sub:@(2.f)]] lor:[x leq:y]];
    id<ORExpr> imply_expr_arithm = [[x eq:[y mul:@(2.f)]] imply:[x neq:y]];
    id<ORExpr> neg_expr_arithm = [[x neq:[y div:@(2.f)]] neg];
    
    
    XCTAssertEqual(and_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(lor_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(imply_expr_cst.vtype, ORTBool, @"succes");
    XCTAssertEqual(neg_expr_cst.vtype, ORTBool, @"succes");
    
    XCTAssertEqual(and_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(lor_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(imply_expr_var.vtype, ORTBool, @"succes");
    XCTAssertEqual(neg_expr_var.vtype, ORTBool, @"succes");
    
    XCTAssertEqual(and_expr_arithm.vtype, ORTBool, @"succes");
    XCTAssertEqual(lor_expr_arithm.vtype, ORTBool, @"succes");
    XCTAssertEqual(imply_expr_arithm.vtype, ORTBool, @"succes");
    XCTAssertEqual(neg_expr_arithm.vtype, ORTBool, @"succes");
    
}



- (void) testExprInt {
    id<ORModel> model = [ORFactory createModel];
    
    id<ORIntVar> x = [ORFactory intVar:model domain:RANGE(model,0,10)];
    id<ORIntVar> y = [ORFactory intVar:model domain:RANGE(model,0,10)];
    id<ORIntVar> z = [ORFactory intVar:model domain:RANGE(model,0,10)];
    id<ORIntVar> w = [ORFactory intVar:model domain:RANGE(model,0,10)];
    
    id<ORExpr> plus_expr_cst = [x plus:@(2)];
    id<ORExpr> sub_expr_cst = [x sub:@(2)];
    id<ORExpr> mul_expr_cst = [x mul:@(2)];
    id<ORExpr> div_expr_cst = [x div:@(2)];
    
    
    XCTAssertEqual(plus_expr_cst.vtype,ORTInt, @"succes");
    XCTAssertEqual(sub_expr_cst.vtype, ORTInt, @"succes");
    XCTAssertEqual(mul_expr_cst.vtype, ORTInt, @"succes");
    XCTAssertEqual(div_expr_cst.vtype, ORTInt, @"succes");
    
    
    id<ORExpr> plus_expr_var = [x plus:y];
    id<ORExpr> sub_expr_var = [x sub:y];
    id<ORExpr> mul_expr_var = [x mul:y];
    id<ORExpr> div_expr_var = [x div:y];
    
    XCTAssertEqual(plus_expr_var.vtype, ORTInt, @"succes");
    XCTAssertEqual(sub_expr_var.vtype, ORTInt, @"succes");
    XCTAssertEqual(mul_expr_var.vtype, ORTInt, @"succes");
    XCTAssertEqual(div_expr_var.vtype, ORTInt, @"succes");
    
    id<ORExpr> plus_complexe = [[[x plus:y] plus:z] plus:w];
    id<ORExpr> sub_complexe = [[[x sub:y] sub:z] sub:w];
    id<ORExpr> mul_complexe = [[[x mul:y] mul:z] mul:w];
    id<ORExpr> div_complexe = [[[x div:y] div:z] div:w];
    
    id<ORExpr> complexe = [[[[x plus:y] mul:z] div:w] sub:@(2)];
    
    XCTAssertEqual(plus_complexe.vtype, ORTInt, @"succes");
    XCTAssertEqual(sub_complexe.vtype, ORTInt, @"succes");
    XCTAssertEqual(mul_complexe.vtype, ORTInt, @"succes");
    XCTAssertEqual(div_complexe.vtype, ORTInt, @"succes");
    
    XCTAssertEqual(complexe.vtype, ORTInt, @"succes");
}

- (void) testExprFloat {
    id<ORModel> model = [ORFactory createModel];
    
    id<ORFloatVar> x = [ORFactory floatVar:model];
    id<ORFloatVar> y = [ORFactory floatVar:model];
    id<ORFloatVar> z = [ORFactory floatVar:model];
    id<ORFloatVar> w = [ORFactory floatVar:model];
    
    id<ORExpr> plus_expr_cst = [x plus:@(2.f)];
    id<ORExpr> sub_expr_cst = [x sub:@(2.f)];
    id<ORExpr> mul_expr_cst = [x mul:@(2.f)];
    id<ORExpr> div_expr_cst = [x div:@(2.f)];
    
    
    XCTAssertEqual(plus_expr_cst.vtype, ORTFloat, @"succes");
    XCTAssertEqual(sub_expr_cst.vtype, ORTFloat, @"succes");
    XCTAssertEqual(mul_expr_cst.vtype, ORTFloat, @"succes");
    XCTAssertEqual(div_expr_cst.vtype, ORTFloat, @"succes");
    
    
    id<ORExpr> plus_expr_var = [x plus:y];
    id<ORExpr> sub_expr_var = [x sub:y];
    id<ORExpr> mul_expr_var = [x mul:y];
    id<ORExpr> div_expr_var = [x div:y];
    
    XCTAssertEqual(plus_expr_var.vtype, ORTFloat, @"succes");
    XCTAssertEqual(sub_expr_var.vtype, ORTFloat, @"succes");
    XCTAssertEqual(mul_expr_var.vtype, ORTFloat, @"succes");
    XCTAssertEqual(div_expr_var.vtype, ORTFloat, @"succes");
    
    
    id<ORExpr> plus_complexe = [[[x plus:y] plus:z] plus:w];
    id<ORExpr> sub_complexe = [[[x sub:y] sub:z] sub:w];
    id<ORExpr> mul_complexe = [[[x mul:y] mul:z] mul:w];
    id<ORExpr> div_complexe = [[[x div:y] div:z] div:w];
    
    id<ORExpr> complexe = [[[[x plus:y] mul:z] div:w] sub:@(2.f)];
    
    XCTAssertEqual(plus_complexe.vtype, ORTFloat, @"succes");
    XCTAssertEqual(sub_complexe.vtype, ORTFloat, @"succes");
    XCTAssertEqual(mul_complexe.vtype, ORTFloat, @"succes");
    XCTAssertEqual(div_complexe.vtype, ORTFloat, @"succes");
    
    XCTAssertEqual(complexe.vtype, ORTFloat, @"succes");
}

- (void) testExprInt2Float {
    id<ORModel> model = [ORFactory createModel];
    
    id<ORFloatVar> x = [ORFactory floatVar:model];
    id<ORIntVar> y = [ORFactory intVar:model domain:RANGE(model,0,10)];
    
    id<ORExpr> plus_expr_cst = [x plus:@(2)];
    id<ORExpr> sub_expr_cst = [x sub:@(2)];
    id<ORExpr> mul_expr_cst = [x mul:@(2)];
    id<ORExpr> div_expr_cst = [x div:@(2)];
    
    
    XCTAssertEqual(plus_expr_cst.vtype, ORTFloat, @"succes");
    XCTAssertEqual(sub_expr_cst.vtype, ORTFloat, @"succes");
    XCTAssertEqual(mul_expr_cst.vtype, ORTFloat, @"succes");
    XCTAssertEqual(div_expr_cst.vtype, ORTFloat, @"succes");
    
    
    id<ORExpr> plus_expr_var = [x plus:y];
    id<ORExpr> sub_expr_var = [x sub:y];
    id<ORExpr> mul_expr_var = [x mul:y];
    id<ORExpr> div_expr_var = [x div:y];
    
    XCTAssertEqual(plus_expr_var.vtype, ORTFloat, @"succes");
    XCTAssertEqual(sub_expr_var.vtype, ORTFloat, @"succes");
    XCTAssertEqual(mul_expr_var.vtype, ORTFloat, @"succes");
    XCTAssertEqual(div_expr_var.vtype, ORTFloat, @"succes");
}

//Wait for changed
-(void) IgnoredtestInegality {
    @autoreleasepool {
        
        id<ORModel> model = [ORFactory createModel];
        
        id<ORFloatVar> x = [ORFactory floatVar:model low:0.f up:10.f];
        id<ORFloatVar> y = [ORFactory floatVar:model low:0.f up:10.f];
//        id<ORFloatVar> z = [ORFactory floatVar:model low:0.f up:10.f];
        
        [model add:[x geq:@(2.0f)]];
        [model add:[x leq:@(8.0f)]];
        
        [model add:[y gt:@(2.0f)]];
        [model add:[y lt:@(8.0f)]];
        
//        id<CPProgram> cp = [ORFactory createCPProgram:model];
        
        
    }
}

@end
