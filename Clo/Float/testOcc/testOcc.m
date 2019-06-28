//
//  testOcc.m
//  testOcc
//
//  Created by zitoun on 6/28/19.
//  Copyright © 2019 Laurent Michel. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPFactory.h>
#import <objcp/CPFloatVarI.h>
#import <ORProgram/CPSolver.h>
#import <ORFoundation/ORVar.h>

@interface testOcc : XCTestCase

@end

@implementation testOcc

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void) testOcc {
   @autoreleasepool {
      id<ORModel> model = [ORFactory createModel];
      id<ORGroup> g = [ORFactory group:model];
      
      id<ORFloatVar> x0 = [ORFactory floatVar:model name:@"x0"];
      id<ORFloatVar> x1 = [ORFactory floatVar:model name:@"x1"];
      id<ORFloatVar> x2 = [ORFactory floatVar:model name:@"x2"];
      
      [g add:[x0 eq:[x1 plus:@(2.f)]]];
      [g add:[x1 eq:[x2 plus:@(2.f)]]];
      
      [g add:[[x0 plus:x1] gt:@(4.f)]];
      [g add:[[x0 plus:x2] gt:@(4.f)]];
      [g add:[[x1 plus:x2] gt:@(4.f)]];
      
      [model add:g];
      NSLog(@"%@", model);
      id<CPProgram> cp = [ORFactory createCPProgram:model];
      [[cp source] occurences];
   }
}

@end
