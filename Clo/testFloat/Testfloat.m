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
#import <ORProgram/CPSolver.h>

//#import "fpi.h"



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

@end
