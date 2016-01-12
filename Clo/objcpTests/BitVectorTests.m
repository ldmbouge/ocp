//
//  BitVectorTests.m
//  Clo
//
//  Created by Greg Johnson on 1/5/16.
//
//

#import <XCTest/XCTest.h>
#import  "Foundation/NSDebug.h"
#import "testBitConstraints.h"

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORAVLTree.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPObjectQueue.h>
#import <objcp/CPFactory.h>

#import <objcp/CPConstraint.h>
#import <objcp/CPBitMacros.h>
#import <objcp/CPBitArray.h>
#import <objcp/CPBitArrayDom.h>
#import <objcp/CPBitConstraint.h>

@interface BitVectorTests : XCTestCase

@end

@implementation BitVectorTests

-(void) testBackjumping
{
   NSLog(@"Begin Test of backjumping search\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int zero[1];
   unsigned int min[1];
   unsigned int min2[1];
   unsigned int max[1];
   
   zero[0] = 0x00000000;
   min[0] = 0xFF00FF00;
   min2[0] = 0x00FF00FF;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x1 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x2 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x3 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x4 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x5 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x6 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x7 = [ORFactory bitVar:m low:max up:max bitLength:32];
//   id<ORBitVar> x8 = [ORFactory bitVar:m low:zero up:max bitLength:32];
//   id<ORBitVar> cin = [ORFactory bitVar:m low:zero up:max bitLength:32];
//   id<ORBitVar> cout = [ORFactory bitVar:m low:zero up:max bitLength:32];
   
   [m add:[ORFactory bit:x1 xor:x2 eq:x3]];
   [m add:[ORFactory bit:x1 rotateLBy:8 eq:x2]];
   //   [m add:[ORFactory bit:x3 rotateLBy:8 eq:x4]];
   [m add:[ORFactory bit:x3 xor:x1 eq:x4]];
   [m add:[ORFactory bit:x4 xor:x5 eq:x6]];
   [m add:[ORFactory bit:x5 rotateLBy:8 eq:x6]];
   [m add:[ORFactory bit:x5 xor:x6 eq:x7]];
//   [m add:[ORFactory bit:x5 plus:x6 withCarryIn:cin eq:x8 withCarryOut:cout]];
//   [m add:[ORFactory bit:x2 eq:x8]];
   
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgramBackjumpingDFS:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:6]];
   [o set:gamma[x1.getId] at:0];
   [o set:gamma[x2.getId] at:1];
   [o set:gamma[x3.getId] at:2];
   [o set:gamma[x4.getId] at:3];
   [o set:gamma[x5.getId] at:4];
   [o set:gamma[x6.getId] at:5];
   [o set:gamma[x7.getId] at:6];
//   [o set:gamma[x8.getId] at:7];
   
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"%lx x1 = %@\n", gamma[x1.getId], gamma[x1.getId]);
         NSLog(@"%lx x2 = %@\n", gamma[x2.getId], gamma[x2.getId]);
         NSLog(@"%lx x3 = %@\n", gamma[x3.getId], gamma[x3.getId]);
         NSLog(@"%lx x4 = %@\n", gamma[x4.getId], gamma[x4.getId]);
         NSLog(@"%lx x5 = %@\n", gamma[x5.getId], gamma[x5.getId]);
         NSLog(@"%lx x6 = %@\n", gamma[x6.getId], gamma[x6.getId]);
         NSLog(@"%lx x7 = %@\n", gamma[x7.getId], gamma[x7.getId]);
//         NSLog(@"%lx x8 = %@\n", gamma[x8.getId], gamma[x8.getId]);
//         NSLog(@"%lx cin = %@\n", gamma[cin.getId], gamma[cin.getId]);
//         NSLog(@"%lx cout = %@\n", gamma[cout.getId], gamma[cout.getId]);
         [cp labelBitVarHeuristicCDCL:h];
         NSLog(@"Solution Found:");
         NSLog(@"x1 = %@\n", gamma[x1.getId]);
         NSLog(@"x2 = %@\n", gamma[x2.getId]);
         NSLog(@"x3 = %@\n", gamma[x3.getId]);
         NSLog(@"x4 = %@\n", gamma[x4.getId]);
         NSLog(@"x5 = %@\n", gamma[x5.getId]);
         NSLog(@"x6 = %@\n", gamma[x6.getId]);
         NSLog(@"x7 = %@\n", gamma[x7.getId]);
//         NSLog(@"x8 = %@\n", gamma[x8.getId]);
//         NSLog(@"cin = %@\n", gamma[cin.getId]);
//         NSLog(@"cout = %@\n", gamma[cout.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"Solver status: %@\n",cp);
   
   NSLog(@"End Test of backjumping search\n");
   
}
@end
