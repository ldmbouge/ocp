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

//#import "fpi.h"
//hzi test SSA

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

-(void) testSimpleEgality{
   @autoreleasepool {
      
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

@end
