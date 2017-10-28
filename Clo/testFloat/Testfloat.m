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

#import "fpi.h"



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


-(void) testInegality {
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
        
        id<CPFloatVar> xc = [cp concretize:x];
        id<CPFloatVar> yc = [cp concretize:y];
        
        XCTAssertEqual([x low], 2.0f, @"succes");
        XCTAssertEqual([x up], 8.0f, @"succes");
        
        XCTAssertEqual([y low], fp_next_float(2.0f), @"succes");
        XCTAssertEqual([y up], fp_previous_float(8.0f), @"succes");
        
        XCTAssertEqual([z low], [x low], @"succes");
        XCTAssertEqual([z up], [x up], @"succes");
        
        
        XCTAssertEqual([w low], fp_next_float([x low]), @"succes");
        XCTAssertEqual([w up], fp_previous_float([x up]), @"succes");
        
    }
}

@end
