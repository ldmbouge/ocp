//
//  Testfloat.m
//  Testfloat
//
//  Created by Zitoun on 26/10/2017.
//
//

#import <XCTest/XCTest.h>


#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <objcp/CPFloatVarI.h>
#import <ORProgram/CPSolver.h>


@interface Testfloat : XCTestCase

@end

@implementation Testfloat

- (void)setUp {
   [super setUp];
   // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
   // Put teardown code here. This method is called after the invocation of each test method in the class.
   [super tearDown];
}
-(void) testComputeAbsorbed
{
   @autoreleasepool {
      
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x_0 = [ORFactory floatVar:model low:0.f up:1.f];
      id<ORFloatVar> y_0 = [ORFactory floatVar:model low:-1e2f up:0.f];
      
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         
         fesetround(FE_TONEAREST);
         CPFloatVarI* xc = [cp concretize:x_0];
         CPFloatVarI* yc = [cp concretize:y_0];
         
         NSLog(@"xc : %@\n yx : %@",xc,yc);
         
         float_interval fx = computeAbsordedInterval(xc);
         float_interval fy = computeAbsordedInterval(yc);
         
         
         NSLog(@"fx : [%16.16e,%16.16e]",fx.inf,fx.sup);
         NSLog(@"fy : [%16.16e,%16.16e]",fy.inf,fy.sup);
         
         XCTAssertEqual([xc max]+fx.inf,[xc max]);
         XCTAssertEqual([xc max]-fx.inf,[xc max]);
         XCTAssertEqual([xc max]+fx.sup,[xc max]);
         XCTAssertEqual([xc max]-fx.sup,[xc max]);
         XCTAssertEqual([yc min]-fy.inf,[yc min]);
         XCTAssertEqual([yc min]+fy.inf,[yc min]);
         XCTAssertEqual([yc min]-fy.sup,[yc min]);
         XCTAssertEqual([yc min]+fy.sup,[yc min]);
         
      }];
   }
}

-(void) testNoAbsorptionNoOp
{
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x_0 = [ORFactory floatVar:model low:1e3f up:1e4f];
      id<ORFloatVar> y_0 = [ORFactory floatVar:model low:1e3f up:1e4f];
      id<ORFloatVar> res = [ORFactory floatVar:model];
      
      [model add:[x_0 gt: y_0]];
      [model add:[res eq:[x_0 mul:y_0]]];
      
      id<ORFloatVarArray> vars =[model floatVars];
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         NSMutableArray<ABSElement*>* Abs = [cp computeAbsorptionsQuantities:vars];
         for(ABSElement* v in Abs){
            XCTAssertEqual([v quantity],0.0f);
            XCTAssertEqual([v bestChoice],nil);
         }
      }];
   }
}
-(void) testNoAbsorption
{
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x_0 = [ORFactory floatVar:model low:1e3f up:1e4f];
      id<ORFloatVar> y_0 = [ORFactory floatVar:model low:1e3f up:1e4f];
      id<ORFloatVar> res = [ORFactory floatVar:model];
      
      [model add:[x_0 gt: y_0]];
      [model add:[res eq:[x_0 plus:y_0]]];
      
      id<ORFloatVarArray> vars =[model floatVars];
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         NSMutableArray<ABSElement*>* Abs = [cp computeAbsorptionsQuantities:vars];
         for(ABSElement* v in Abs){
            XCTAssertEqual([v quantity],0.0f);
            XCTAssertEqual([v bestChoice],nil);
         }
      }];
   }
}
-(void) testAbsorption
{
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x_0 = [ORFactory floatVar:model low:-1.f up:1e4f];
      id<ORFloatVar> y_0 = [ORFactory floatVar:model low:-1.f up:1e4f];
      id<ORFloatVar> res = [ORFactory floatVar:model];
      
      [model add:[x_0 gt: y_0]];
      [model add:[res eq:[x_0 plus:y_0]]];
      
      id<ORFloatVarArray> vars =[model floatVars];
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         NSMutableArray<ABSElement*>* Abs = [cp computeAbsorptionsQuantities:vars];
         
         XCTAssertTrue([Abs[0] quantity] > 0.0f);
         XCTAssertTrue([Abs[0] bestChoice] != nil);
         
         XCTAssertTrue([Abs[1] quantity] > 0.0f);
         XCTAssertTrue([Abs[1] bestChoice] != nil);
         
         XCTAssertFalse([Abs[2] quantity] > 0.0f);
         XCTAssertTrue([Abs[2] bestChoice] == nil);
         
      }];
      
   }
}
-(void) testAbsorptionRateNoOp
{
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x_0 = [ORFactory floatVar:model low:1e3f up:1e4f];
      id<ORFloatVar> y_0 = [ORFactory floatVar:model low:1e3f up:1e4f];
      id<ORFloatVar> res = [ORFactory floatVar:model];
      
      [model add:[x_0 gt: y_0]];
      [model add:[res eq:[x_0 mul:y_0]]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         XCTAssertEqual([cp computeAbsorptionRate:x_0],0.0);
         XCTAssertEqual([cp computeAbsorptionRate:y_0],0.0);
      }];
   }
}
-(void) testAbsorptionRateNoAbs
{
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x_0 = [ORFactory floatVar:model low:1e3f up:1e4f];
      id<ORFloatVar> y_0 = [ORFactory floatVar:model low:1e3f up:1e4f];
      id<ORFloatVar> res = [ORFactory floatVar:model];
      
      [model add:[x_0 gt: y_0]];
      [model add:[res eq:[x_0 plus:y_0]]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         XCTAssertEqual([cp computeAbsorptionRate:x_0],0.0);
         XCTAssertEqual([cp computeAbsorptionRate:y_0],0.0);
      }];
   }
}
-(void) testAbsorptionRateAbs
{
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x_0 = [ORFactory floatVar:model low:1e3f up:1e4f];
      id<ORFloatVar> y_0 = [ORFactory floatVar:model low:-1.f up:1.f];
      id<ORFloatVar> res = [ORFactory floatVar:model];
      
      [model add:[x_0 gt: y_0]];
      [model add:[res eq:[x_0 plus:y_0]]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         XCTAssertTrue([cp computeAbsorptionRate:x_0] > 0.0);
         XCTAssertFalse([cp computeAbsorptionRate:y_0] > 0.0);
      }];
   }
}

-(void) testSSA1WithoutSearch
{
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x_0 = [ORFactory floatVar:model low:7.f up:10.f];
      id<ORFloatVar> y_0 = [ORFactory floatVar:model];
      id<ORFloatVar> y_1 = [ORFactory floatVar:model];
      id<ORFloatVar> y_2 = [ORFactory floatVar:model];
      
      id<ORExpr> expr_0 = [ORFactory float:model value:5.f];
      id<ORExpr> expr_1 = [ORFactory float:model value:2.f];
      id<ORExpr> expr_2 = [ORFactory float:model value:0.f];
      
      id<ORExpr> c_0 = [x_0 gt: expr_0];
      id<ORIntVar> b_if0 = [ORFactory boolVar:model];
      id<ORIntVar> b_else0 = [ORFactory boolVar:model];
      
      [model add:[c_0  eq:b_if0]];
      [model add:[[b_if0 neg] eq:b_else0]];
      id<ORGroup> g_0 = [ORFactory group:model guard:b_if0];
      {
         [g_0 add:[y_1 eq: expr_1]];
      }
      id<ORGroup> g_1 = [ORFactory group:model guard:b_else0];
      {
         [g_1 add:[y_2 eq: expr_2]];
      }
      [model add:[ORFactory phi:model on_boolean:b_if0 var:y_0 with:y_1 or:y_2]];
      
      [model add:g_0];
      [model add:g_1];
      
      NSLog(@"%@",model);
      id<ORFloatVarArray> vars = [ORFactory floatVarArray:model range:RANGE(model, 0, 1) ];
      vars[0] = x_0;
      vars[1] = y_0;
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         
         id<CPFloatVar> xc = [cp concretize:x_0];
         id<CPFloatVar> yc = [cp concretize:y_0];
         
         XCTAssertFalse([xc bound]);
         XCTAssertTrue([yc bound]);
         
         XCTAssertEqual([xc min],7.f);
         XCTAssertEqual([xc max],10.f);
         
         XCTAssertEqual([yc max],2.f);
         XCTAssertEqual([yc max],2.f);
         
      }];
   }
}

-(void) testSSA2WithoutSearch
{
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x_0 = [ORFactory floatVar:model low:3.f up:4.f];
      id<ORFloatVar> y_0 = [ORFactory floatVar:model];
      id<ORFloatVar> y_1 = [ORFactory floatVar:model];
      id<ORFloatVar> y_2 = [ORFactory floatVar:model];
      
      id<ORExpr> expr_0 = [ORFactory float:model value:5.f];
      id<ORExpr> expr_1 = [ORFactory float:model value:2.f];
      id<ORExpr> expr_2 = [ORFactory float:model value:0.f];
      
      id<ORExpr> c_0 = [x_0 gt: expr_0];
      id<ORIntVar> b_if0 = [ORFactory boolVar:model];
      id<ORIntVar> b_else0 = [ORFactory boolVar:model];
      
      [model add:[c_0  eq:b_if0]];
      [model add:[[b_if0 neg] eq:b_else0]];
      id<ORGroup> g_0 = [ORFactory group:model guard:b_if0];
      {
         [g_0 add:[y_1 eq: expr_1]];
      }
      id<ORGroup> g_1 = [ORFactory group:model guard:b_else0];
      {
         [g_1 add:[y_2 eq: expr_2]];
      }
      [model add:[ORFactory phi:model on_boolean:b_if0 var:y_0 with:y_1 or:y_2]];
      
      [model add:g_0];
      [model add:g_1];
      
      NSLog(@"%@",model);
      id<ORFloatVarArray> vars = [ORFactory floatVarArray:model range:RANGE(model, 0, 1) ];
      vars[0] = x_0;
      vars[1] = y_0;
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         
         id<CPFloatVar> xc = [cp concretize:x_0];
         id<CPFloatVar> yc = [cp concretize:y_0];
         
         XCTAssertFalse([xc bound]);
         XCTAssertTrue([yc bound]);
         
         XCTAssertEqual([xc min],3.f);
         XCTAssertEqual([xc max],4.f);
         
         XCTAssertEqual([yc max],0.f);
         XCTAssertEqual([yc max],0.f);
         
      }];
   }
}

-(void) testSimpleEgality{
   @autoreleasepool {
      fesetround(FE_TONEAREST);
      
      id<ORModel> model = [ORFactory createModel];
      
      id<ORFloatVar> x = [ORFactory floatVar:model low:0.f up:10.f];
      id<ORFloatVar> y = [ORFactory floatVar:model low:0.f up:10.f];
      id<ORFloatVar> z = [ORFactory floatVar:model low:0.f up:10.f];
      id<ORFloatVar> w = [ORFactory floatVar:model low:3.f up:5.f];
      id<ORFloatVar> u = [ORFactory floatVar:model low:3.f up:4.f];
      id<ORFloatVar> t = [ORFactory floatVar:model low:0.f up:nextafterf(0.f, +INFINITY)];
      
      [model add:[x eq:@(3.0f)]];
      [model add:[y eq:x]];
      
      [model add:[t neq:@(0.f)]];
      
      [model add:[z eq:[w plus:u]]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         
         id<CPFloatVar> xc = [cp concretize:x];
         id<CPFloatVar> yc = [cp concretize:y];
         id<CPFloatVar> zc = [cp concretize:z];
         id<CPFloatVar> wc = [cp concretize:w];
         id<CPFloatVar> uc = [cp concretize:u];
         id<CPFloatVar> tc = [cp concretize:t];
         
         XCTAssertTrue([xc bound]);
         XCTAssertTrue([yc bound]);
         XCTAssertTrue([tc bound]);
         XCTAssertTrue(![zc bound]);
         XCTAssertTrue(![wc bound]);
         XCTAssertTrue(![uc bound]);
         
         XCTAssertEqual([xc min], 3.0f, @"succes");
         XCTAssertEqual([xc max], 3.0f, @"succes");
         
         XCTAssertEqual([yc min], 3.f, @"succes");
         XCTAssertEqual([yc max], 3.f, @"succes");
         
         XCTAssertEqual([tc min], nextafterf(0.f, +INFINITY) , @"succes");
         XCTAssertEqual([tc max], nextafterf(0.f, +INFINITY), @"succes");
         
         XCTAssertEqual([zc min], 6.f, @"succes");
         XCTAssertEqual([zc max], 9.f, @"succes");
         
         XCTAssertEqual([wc min], 3.f, @"succes");
         XCTAssertEqual([wc max], 5.f, @"succes");
         
         XCTAssertEqual([uc min], 3.f, @"succes");
         XCTAssertEqual([uc max], 4.f, @"succes");
         
         
      }];
   }
}

-(void) testFail{
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      
      id<ORFloatVar> x = [ORFactory floatVar:model low:0.f up:0.f];
      id<ORFloatVar> y = [ORFactory floatVar:model low:0.f up:0.f];
      
      [model add:[x neq:y]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         XCTAssert(false);
      }];
   }
}

-(void) testSimpleInegality {
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      
      id<ORFloatVar> x = [ORFactory floatVar:model low:0.f up:10.f];
      id<ORFloatVar> y = [ORFactory floatVar:model low:0.f up:10.f];
      id<ORFloatVar> z = [ORFactory floatVar:model low:0.f up:10.f];
      id<ORFloatVar> w = [ORFactory floatVar:model low:-3.f up:15.f];
      
      
      [model add:[x geq:@(2.0f)]];
      [model add:[x leq:@(8.0f)]];
      
      [model add:[y gt:@(2.0f)]];
      [model add:[y lt:@(8.0f)]];
      
      [model add:[z geq:x]];
      [model add:[z leq:x]];
      
      [model add:[w gt:x]];
      [model add:[w lt:x]];
      
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         
         id<CPFloatVar> xc = [cp concretize:x];
         id<CPFloatVar> yc = [cp concretize:y];
         id<CPFloatVar> zc = [cp concretize:z];
         id<CPFloatVar> wc = [cp concretize:w];
         
         XCTAssertTrue(![xc bound]);
         XCTAssertTrue(![yc bound]);
         XCTAssertTrue(![zc bound]);
         XCTAssertTrue(![wc bound]);
         
         XCTAssertEqual([xc min], 2.0f, @"succes");
         XCTAssertEqual([xc max], 8.0f, @"succes");
         
         XCTAssertEqual([yc min], nextafterf(2.0, +INFINITY), @"succes");
         XCTAssertEqual([yc max], nextafterf(8.0, -INFINITY), @"succes");
         
         XCTAssertEqual([zc min], [xc min], @"succes");
         XCTAssertEqual([zc max], [xc max], @"succes");
         
         
         XCTAssertEqual([wc min], nextafterf([xc min], +INFINITY), @"succes");
         XCTAssertEqual([wc max], nextafterf([xc max], -INFINITY), @"succes");
         
      }];
   }
}
-(void) testComplexeInegality {
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      
      id<ORFloatVar> x = [ORFactory floatVar:model low:0.f up:10.f];
      id<ORFloatVar> y = [ORFactory floatVar:model low:5.f up:6.f];
      id<ORFloatVar> z = [ORFactory floatVar:model low:2.f up:3.f];
      
      
      [model add:[x geq:[y sub:z]]];
      [model add:[x leq:[y plus:z]]];
      
      //       NSLog(@"model: %@",model);
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [cp solve:^(){
         
         id<CPFloatVar> xc = [cp concretize:x];
         id<CPFloatVar> yc = [cp concretize:y];
         id<CPFloatVar> zc = [cp concretize:z];
         
         XCTAssertTrue(![xc bound]);
         XCTAssertTrue(![yc bound]);
         XCTAssertTrue(![zc bound]);
         
         XCTAssertEqual([xc min], 2.0f, @"succes");
         XCTAssertEqual([xc max], 9.0f, @"succes");
         
      }];
   }
}

-(void) testFloatOk{
   @autoreleasepool {
      
      fesetround(FE_TONEAREST);
      id<ORModel> mdl = [ORFactory createModel];
      id<ORFloatRange> r0 = [ORFactory floatRange:mdl low:-1e8f up:1e8f];
      id<ORFloatVar> x = [ORFactory floatVar:mdl domain:r0];
      id<ORFloatVar> y = [ORFactory floatVar:mdl domain:r0];
      id<ORFloatVar> z = [ORFactory floatVar:mdl domain:r0];
      id<ORFloatVar> r = [ORFactory floatVar:mdl domain:r0];
      
      [mdl add:[x eq: @(1e7f)]];
      [mdl add:[y eq: [x plus:@(1.f)]]];
      [mdl add:[z eq: [x sub:@(1.f)]]];
      [mdl add:[r eq: [y sub:z]]];
      
      //      NSLog(@"model: %@",mdl);
      [mdl floatVars];
      id<CPProgram> p = [ORFactory createCPProgram:mdl];
      [p solve:^{
         id<CPFloatVar> xc = [p concretize:x];
         id<CPFloatVar> yc = [p concretize:y];
         id<CPFloatVar> zc = [p concretize:z];
         id<CPFloatVar> rc = [p concretize:r];
         XCTAssertTrue([xc bound]);
         XCTAssertTrue([yc bound]);
         XCTAssertTrue([zc bound]);
         XCTAssertTrue([rc bound]);
         XCTAssertEqual([xc min],1e7f);
         XCTAssertEqual([yc min],10000001.000000f);
         XCTAssertEqual([zc min],9999999.000000f);
         XCTAssertEqual([rc min],2.0f);
      }];
   }
   
}

-(void) testPropagationOnly
{
   @autoreleasepool {
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
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
      [model add:[Q_0 eq:@(0.0f)]];
      [model add:[a_0 eq:@(15.0f)]];
      
      id<CPProgram> p = [ORFactory createCPProgram:model];
      [p solve:^{
         id<CPFloatVar> cc = [p concretize:c_0];
         id<CPFloatVar> rc = [p concretize:r_0];
         id<CPFloatVar> ac = [p concretize:a_0];
         id<CPFloatVar> Qc = [p concretize:Q_0];
         id<CPFloatVar> R2c = [p concretize:R2_0];
         id<CPFloatVar> CR2c = [p concretize:CR2_0];
         id<CPFloatVar> CQ3c = [p concretize:CQ3_0];
         id<CPFloatVar> Q3c = [p concretize:Q3_0];
         id<CPFloatVar> qc = [p concretize:q_0];
         id<CPFloatVar> bc = [p concretize:b_0];
         XCTAssertTrue([cc bound]);
         XCTAssertTrue([rc bound]);
         XCTAssertTrue([ac bound]);
         XCTAssertTrue([Qc bound]);
         XCTAssertTrue([R2c bound]);
         XCTAssertTrue([CR2c bound]);
         XCTAssertTrue([CQ3c bound]);
         XCTAssertTrue([Q3c bound]);
         XCTAssertTrue([qc bound]);
         XCTAssertTrue([bc bound]);
         
         
         XCTAssertEqual([cc min],125.f);
         XCTAssertEqual([rc min],0.f);
         XCTAssertEqual([ac min],15.f);
         XCTAssertEqual([bc min],75.f);
         XCTAssertEqual([Qc min],0.0f);
         XCTAssertEqual([R2c min],0.0f);
         XCTAssertEqual([CR2c min],0.0f);
         XCTAssertEqual([CQ3c min],0.0f);
         XCTAssertEqual([Q3c min],0.0f);
         XCTAssertEqual([qc min],0.0f);
         
      }];
   }
}


-(void) testOperationDom
{
   @autoreleasepool {
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      id<ORFloatVar> x = [ORFactory floatVar:model low:5.f up:10.f];
      id<ORFloatVar> y = [ORFactory floatVar:model low:6.f up:8.f];
      id<ORFloatVar> y1 = [ORFactory floatVar:model low:8.f up:12.f];
      id<ORFloatVar> y2 = [ORFactory floatVar:model low:4.f up:7.f];
      id<ORFloatVar> y3 = [ORFactory floatVar:model low:4.f up:6.f];
      id<ORFloatVar> y4 = [ORFactory floatVar:model low:10.f up:12.f];
      id<ORFloatVar> z = [ORFactory floatVar:model low:-1.f up:1.f];
      id<ORFloatVar> w = [ORFactory floatVar:model low:11.f up:12.f];
      
      id<CPProgram> p = [ORFactory createCPProgram:model];
      
      [p solve:^(){
         
         CPFloatVarI* cx = [p concretize:x];
         CPFloatVarI* cy = [p concretize:y];
         CPFloatVarI* cy1 = [p concretize:y1];
         CPFloatVarI* cy2 = [p concretize:y2];
         CPFloatVarI* cy3 = [p concretize:y3];
         CPFloatVarI* cy4 = [p concretize:y4];
         CPFloatVarI* cz = [p concretize:z];
         CPFloatVarI* cw = [p concretize:w];
         
         XCTAssertTrue(isIntersectingWith(cx,cy));
         XCTAssertTrue(isIntersectingWith(cx,cy1));
         XCTAssertTrue(isIntersectingWith(cx,cy2));
         XCTAssertTrue(isIntersectingWith(cx,cy3));
         XCTAssertTrue(isIntersectingWith(cx,cy4));
         XCTAssertFalse(isIntersectingWith(cx,cz));
         XCTAssertFalse(isIntersectingWith(cx,cw));
         
         XCTAssertFalse(isDisjointWith(cx,cy));
         XCTAssertFalse(isDisjointWith(cx,cy1));
         XCTAssertFalse(isDisjointWith(cx,cy2));
         XCTAssertFalse(isDisjointWith(cx,cy3));
         XCTAssertFalse(isDisjointWith(cx,cy4));
         XCTAssertTrue(isDisjointWith(cx,cz));
         XCTAssertTrue(isDisjointWith(cx,cw));
         
         XCTAssertFalse(canPrecede(cx,cy));
         XCTAssertFalse(canPrecede(cx,cy2));
         XCTAssertFalse(canPrecede(cx,cy3));
         XCTAssertFalse(canPrecede(cx,cz));
         XCTAssertFalse(canPrecede(cy4,cx));
         XCTAssertTrue(canPrecede(cx,cy4));
         XCTAssertTrue(canPrecede(cz,cx));
         XCTAssertTrue(canPrecede(cx,cy1));
         XCTAssertTrue(canPrecede(cy2,cx));
         
         XCTAssertFalse(canFollow(cx,cy));
         XCTAssertFalse(canFollow(cx,cy1));
         XCTAssertTrue(canFollow(cx,cy2));
         XCTAssertTrue(canFollow(cx,cy3));
         XCTAssertFalse(canFollow(cx,cy4));
         XCTAssertFalse(canFollow(cz,cx));
         XCTAssertTrue(canFollow(cx,cz));
      }];
   }
}

-(void) testSin1lex
{
   @autoreleasepool {
   fesetround(FE_TONEAREST);
   id<ORModel> model = [ORFactory createModel];
   
   id<ORFloatVar> IN = [ORFactory floatVar:model low:-1.57079632f up:1.57079632f];
   id<ORFloatVar> res = [ORFactory floatVar:model];
   
   [model add:[res eq:[[[IN sub:
                         [[IN mul:[IN mul:IN]] div:@(6.0f)]] plus:
                        [[IN mul:[IN mul:[IN mul:[IN mul:IN]]]] div:@(120.0f)]] plus:
                       [[IN mul:[IN mul:[IN mul:[IN mul:[IN mul:[IN mul:IN]]]]]] div:@(5040.0f)]]]];
   
   [model add:[[res geq:@(-0.99f)] land:[res lt:@(0.99f)]]];
   
   
   id<ORFloatVarArray> vars = [model floatVars];
   id<CPProgram> cp =  [ORFactory createCPProgram:model];
   [cp solve:^() {
      [cp lexicalOrderedSearch:vars do:^(id<ORFloatVar> x) {
         [cp floatSplit:x];
      }];
      for(id<ORFloatVar> v in vars){
         NSLog(@"%@ : %20.20e (%s) %@",v,[cp floatValue:v],[cp bound:v] ? "YES" : "NO",[cp concretize:v]);
      }
      float x = [cp floatValue:vars[0]];
      float result = x - (x*x*x)/6.0f + (x*x*x*x*x)/120.0f + (x*x*x*x*x*x*x)/5040.0f;
      XCTAssertTrue([cp bound:vars[0]]);
      XCTAssertTrue([cp bound:vars[1]]);
      XCTAssertTrue(x < 1.57079632f && x >= -1.57079632f);
      XCTAssertTrue(result < 0.99f && result >= -0.99f);
      XCTAssertTrue(result == [cp floatValue:vars[1]]);
   }];
   }
}

-(void) testSin1Dens
{
   @autoreleasepool {
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      
      id<ORFloatVar> IN = [ORFactory floatVar:model low:-1.57079632f up:1.57079632f];
      id<ORFloatVar> res = [ORFactory floatVar:model];
      
      [model add:[res eq:[[[IN sub:
                            [[IN mul:[IN mul:IN]] div:@(6.0f)]] plus:
                           [[IN mul:[IN mul:[IN mul:[IN mul:IN]]]] div:@(120.0f)]] plus:
                          [[IN mul:[IN mul:[IN mul:[IN mul:[IN mul:[IN mul:IN]]]]]] div:@(5040.0f)]]]];
      
      [model add:[[res geq:@(-0.99f)] land:[res lt:@(0.99f)]]];
      
      
      id<ORFloatVarArray> vars = [model floatVars];
      id<CPProgram> cp =  [ORFactory createCPProgram:model];
      [cp solve:^() {
         [cp maxDensitySearch:vars do:^(id<ORFloatVar> x) {
            [cp floatSplit:x];
         }];
         for(id<ORFloatVar> v in vars){
            NSLog(@"%@ : %20.20e (%s) %@",v,[cp floatValue:v],[cp bound:v] ? "YES" : "NO",[cp concretize:v]);
         }
         float x =[cp floatValue:vars[0]];
         float result = x - (x*x*x)/6.0f + (x*x*x*x*x)/120.0f + (x*x*x*x*x*x*x)/5040.0f;
         XCTAssertTrue([cp bound:vars[0]]);
         XCTAssertTrue([cp bound:vars[1]]);
         XCTAssertTrue(x < 1.57079632f && x >= -1.57079632f);
         XCTAssertTrue(result < 0.99f && result >= -0.99f);
         XCTAssertTrue(result == [cp floatValue:vars[1]]);
      }];
   }
}


-(void) testSin1Abs
{
   @autoreleasepool {
      fesetround(FE_TONEAREST);
      id<ORModel> model = [ORFactory createModel];
      
      id<ORFloatVar> IN = [ORFactory floatVar:model low:-1.57079632f up:1.57079632f];
      id<ORFloatVar> res = [ORFactory floatVar:model];
      
      [model add:[res eq:[[[IN sub:
                            [[IN mul:[IN mul:IN]] div:@(6.0f)]] plus:
                           [[IN mul:[IN mul:[IN mul:[IN mul:IN]]]] div:@(120.0f)]] plus:
                          [[IN mul:[IN mul:[IN mul:[IN mul:[IN mul:[IN mul:IN]]]]]] div:@(5040.0f)]]]];
      
      [model add:[[res geq:@(-0.99f)] land:[res lt:@(0.99f)]]];
      
      
      id<ORFloatVarArray> vars = [model floatVars];
      id<CPProgram> cp =  [ORFactory createCPProgram:model];
      [cp solve:^() {
         [cp maxAbsorptionSearch:vars do:^(id<ORFloatVar> x) {
            [cp floatSplit:x];
         }];
         for(id<ORFloatVar> v in vars){
            NSLog(@"%@ : %20.20e (%s) %@",v,[cp floatValue:v],[cp bound:v] ? "YES" : "NO",[cp concretize:v]);
         }
         float x =[cp floatValue:vars[0]];
         float result = x - (x*x*x)/6.0f + (x*x*x*x*x)/120.0f + (x*x*x*x*x*x*x)/5040.0f;
         XCTAssertTrue([cp bound:vars[0]]);
         XCTAssertTrue([cp bound:vars[1]]);
         XCTAssertTrue(x < 1.57079632f && x >= -1.57079632f);
         XCTAssertTrue(result < 0.99f && result >= -0.99f);
         XCTAssertTrue(result == [cp floatValue:vars[1]]);
      }];
   }
}


@end
