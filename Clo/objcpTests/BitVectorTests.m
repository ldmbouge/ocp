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
   unsigned int one[1];
   unsigned int min[1];
   unsigned int min2[1];
   unsigned int max[1];
   
   zero[0] = 0x00000000;
   one[0] = 0x1;
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
//   id<ORBitVar> r1 = [ORFactory bitVar:m low:zero up:one bitLength:1];
//   id<ORBitVar> r2 = [ORFactory bitVar:m low:zero up:one bitLength:1];
//   id<ORBitVar> r3 = [ORFactory bitVar:m low:one up:one bitLength:1];
   
   [m add:[ORFactory bit:x1 xor:x2 eq:x3]];
//   [m add:[ORFactory bit:x1 rotateLBy:8 eq:x2]];
   [m add:[ORFactory bit:x3 rotateLBy:8 eq:x4]];
   [m add:[ORFactory bit:x3 xor:x1 eq:x4]];
   [m add:[ORFactory bit:x4 xor:x5 eq:x6]];
   [m add:[ORFactory bit:x5 rotateLBy:8 eq:x6]];
   [m add:[ORFactory bit:x5 xor:x6 eq:x7]];
//   [m add:[ORFactory bit:x1 equalb:x2 eval:r1]];
//   [m add:[ORFactory bit:x2 equalb:x3 eval:r2]];
//   [m add:[ORFactory bit:x3 equalb:x4 eval:r3]];
//   [m add:[ORFactory bit:x5 plus:x6 withCarryIn:cin eq:x8 withCarryOut:cout]];
//   [m add:[ORFactory bit:x2 eq:x8]];
   
   
   id<CPSemanticProgram,CPBV> cp = (id)[ORFactory createCPProgramBackjumpingDFS:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:6]];
   [o set:gamma[x1.getId] at:0];
   [o set:gamma[x2.getId] at:1];
   [o set:gamma[x3.getId] at:2];
   [o set:gamma[x4.getId] at:3];
   [o set:gamma[x5.getId] at:4];
   [o set:gamma[x6.getId] at:5];
   [o set:gamma[x7.getId] at:6];
//   [o set:gamma[r1.getId] at:7];
//   [o set:gamma[r2.getId] at:8];
//   [o set:gamma[r3.getId] at:9];
   //   [o set:gamma[x8.getId] at:7];
   
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"%lx x1 = %@\n", (unsigned long)gamma[x1.getId], gamma[x1.getId]);
         NSLog(@"%lx x2 = %@\n", (unsigned long)gamma[x2.getId], gamma[x2.getId]);
         NSLog(@"%lx x3 = %@\n", (unsigned long)gamma[x3.getId], gamma[x3.getId]);
         NSLog(@"%lx x4 = %@\n", (unsigned long)gamma[x4.getId], gamma[x4.getId]);
         NSLog(@"%lx x5 = %@\n", (unsigned long)gamma[x5.getId], gamma[x5.getId]);
         NSLog(@"%lx x6 = %@\n", (unsigned long)gamma[x6.getId], gamma[x6.getId]);
         NSLog(@"%lx x7 = %@\n", (unsigned long)gamma[x7.getId], gamma[x7.getId]);
//         NSLog(@"%lx r1 = %@\n", (unsigned long)gamma[r1.getId], gamma[r1.getId]);
//         NSLog(@"%lx r2 = %@\n", (unsigned long)gamma[r2.getId], gamma[r2.getId]);
//         NSLog(@"%lx r3 = %@\n", (unsigned long)gamma[r3.getId], gamma[r3.getId]);
//         NSLog(@"%lx x8 = %@\n", (unsigned long)gamma[x8.getId], gamma[x8.getId]);
//         NSLog(@"%lx cin = %@\n", (unsigned long)gamma[cin.getId], gamma[cin.getId]);
//         NSLog(@"%lx cout = %@\n", (unsigned long)gamma[cout.getId], gamma[cout.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x1 = %@\n", gamma[x1.getId]);
         NSLog(@"x2 = %@\n", gamma[x2.getId]);
         NSLog(@"x3 = %@\n", gamma[x3.getId]);
         NSLog(@"x4 = %@\n", gamma[x4.getId]);
         NSLog(@"x5 = %@\n", gamma[x5.getId]);
         NSLog(@"x6 = %@\n", gamma[x6.getId]);
         NSLog(@"x7 = %@\n", gamma[x7.getId]);
//         NSLog(@"%lx r1 = %@\n", (unsigned long)gamma[r1.getId], gamma[r1.getId]);
//         NSLog(@"%lx r2 = %@\n", (unsigned long)gamma[r2.getId], gamma[r2.getId]);
//         NSLog(@"%lx r3 = %@\n", (unsigned long)gamma[r3.getId], gamma[r3.getId]);
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
-(void) testNoBackjumping
{
   NSLog(@"Begin Test of no backjumping search\n");
   
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
//   [m add:[ORFactory bit:x1 rotateLBy:8 eq:x2]];
   [m add:[ORFactory bit:x3 rotateLBy:8 eq:x4]];
   [m add:[ORFactory bit:x3 xor:x1 eq:x4]];
   [m add:[ORFactory bit:x4 xor:x5 eq:x6]];
   [m add:[ORFactory bit:x5 rotateLBy:8 eq:x6]];
   [m add:[ORFactory bit:x5 xor:x6 eq:x7]];
//   [m add:[ORFactory bit:x5 plus:x6 withCarryIn:cin eq:x8 withCarryOut:cout]];
//   [m add:[ORFactory bit:x2 eq:x8]];
   
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
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
   
   id<CPBitVarHeuristic> h = [cp createBitVarFF];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"%lx x1 = %@\n", (unsigned long)gamma[x1.getId], gamma[x1.getId]);
         NSLog(@"%lx x2 = %@\n", (unsigned long)gamma[x2.getId], gamma[x2.getId]);
         NSLog(@"%lx x3 = %@\n", (unsigned long)gamma[x3.getId], gamma[x3.getId]);
         NSLog(@"%lx x4 = %@\n", (unsigned long)gamma[x4.getId], gamma[x4.getId]);
         NSLog(@"%lx x5 = %@\n", (unsigned long)gamma[x5.getId], gamma[x5.getId]);
         NSLog(@"%lx x6 = %@\n", (unsigned long)gamma[x6.getId], gamma[x6.getId]);
         NSLog(@"%lx x7 = %@\n", (unsigned long)gamma[x7.getId], gamma[x7.getId]);
//         NSLog(@"%lx x8 = %@\n", (unsigned long)gamma[x8.getId], gamma[x8.getId]);
//         NSLog(@"%lx cin = %@\n", (unsigned long)gamma[cin.getId], gamma[cin.getId]);
//         NSLog(@"%lx cout = %@\n", (unsigned long)gamma[cout.getId], gamma[cout.getId]);
         [cp labelBitVarHeuristic:h];
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

-(void) testBitORb
{
   NSLog(@"Begin Test of ORb with no backjumping search\n");
   
   id<ORModel> m = [ORFactory createModel];

   unsigned int zero[1];
   unsigned int one[1];
   unsigned int min[1];
   unsigned int min2[1];
   unsigned int max[1];
   
   zero[0] = 0x00000000;
   one[0] = 0x1;
   min[0] = 0xFF00FF00;
   min2[0] = 0x00FF00FF;
   max[0] = 0xFFFFFFFF;
   
   id<ORBitVar> x1 = [ORFactory bitVar:m low:zero up:one bitLength:1];
   id<ORBitVar> x2 = [ORFactory bitVar:m low:zero up:one bitLength:1];
   id<ORBitVar> x3 = [ORFactory bitVar:m low:zero up:one bitLength:1];
   id<ORBitVar> x4 = [ORFactory bitVar:m low:zero up:one bitLength:1];
   id<ORBitVar> x5 = [ORFactory bitVar:m low:zero up:one bitLength:1];
   id<ORBitVar> x6 = [ORFactory bitVar:m low:one up:one bitLength:1];
   id<ORBitVar> x7 = [ORFactory bitVar:m low:zero up:one bitLength:1];
   
   [m add:[ORFactory bit:x1 orb:x2 eval:x3]];
   [m add:[ORFactory bit:x4 orb:x5 eval:x6]];
   [m add:[ORFactory bit:x5 orb:x4 eval:x7]];

   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:6]];
   [o set:gamma[x1.getId] at:0];
   [o set:gamma[x2.getId] at:1];
   [o set:gamma[x3.getId] at:2];
   [o set:gamma[x4.getId] at:3];
   [o set:gamma[x5.getId] at:4];
   [o set:gamma[x6.getId] at:5];
   [o set:gamma[x7.getId] at:6];
   
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"%lx x1 = %@\n", (unsigned long)gamma[x1.getId], gamma[x1.getId]);
         NSLog(@"%lx x2 = %@\n", (unsigned long)gamma[x2.getId], gamma[x2.getId]);
         NSLog(@"%lx x3 = %@\n", (unsigned long)gamma[x3.getId], gamma[x3.getId]);
         NSLog(@"%lx x4 = %@\n", (unsigned long)gamma[x4.getId], gamma[x4.getId]);
         NSLog(@"%lx x5 = %@\n", (unsigned long)gamma[x5.getId], gamma[x5.getId]);
         NSLog(@"%lx x6 = %@\n", (unsigned long)gamma[x6.getId], gamma[x6.getId]);
         NSLog(@"%lx x7 = %@\n", (unsigned long)gamma[x7.getId], gamma[x7.getId]);
//         NSLog(@"%lx cout = %@\n", (unsigned long)gamma[cout.getId], gamma[cout.getId]);

         [cp labelBitVarHeuristic:h];

         NSLog(@"Solution Found:");
         NSLog(@"x1 = %@\n", gamma[x1.getId]);
         NSLog(@"x2 = %@\n", gamma[x2.getId]);
         NSLog(@"x3 = %@\n", gamma[x3.getId]);
         NSLog(@"x4 = %@\n", gamma[x4.getId]);
         NSLog(@"x5 = %@\n", gamma[x5.getId]);
         NSLog(@"x6 = %@\n", gamma[x6.getId]);
         NSLog(@"x7 = %@\n", gamma[x7.getId]);
//         NSLog(@"x8 = %@\n", gamma[x8.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"End Test of ORb with no backjumping search\n");
}

-(void) testBitEqualb
{
   NSLog(@"Begin Test of Equalb with no backjumping search\n");
   
   id<ORModel> m = [ORFactory createModel];
   
   unsigned int zero[1];
   unsigned int one[1];
   unsigned int xff00[1];
   unsigned int x00ff[1];
   unsigned int max[1];
   
   zero[0] = 0x00000000;
   one[0] = 0x1;
   xff00[0] = 0xFF00FF00;
   x00ff[0] = 0x00FF00FF;
   max[0] = 0xFFFFFFFF;
   
   id<ORBitVar> x1 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x2 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x3 = [ORFactory bitVar:m low:x00ff up:x00ff bitLength:32];
   id<ORBitVar> x4 = [ORFactory bitVar:m low:xff00 up:xff00 bitLength:32];
   id<ORBitVar> x5 = [ORFactory bitVar:m low:zero up:one bitLength:1];
   id<ORBitVar> x6 = [ORFactory bitVar:m low:zero up:one bitLength:1];
   id<ORBitVar> x7 = [ORFactory bitVar:m low:one up:one bitLength:1];
   
   [m add:[ORFactory bit:x1 equalb:x2 eval:x7]];
   [m add:[ORFactory bit:x3 equalb:x1 eval:x7]];
   [m add:[ORFactory bit:x3 equalb:x4 eval:x6]];
   [m add:[ORFactory bit:x3 equalb:x2 eval:x5]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:6]];
   [o set:gamma[x1.getId] at:0];
   [o set:gamma[x2.getId] at:1];
   [o set:gamma[x3.getId] at:2];
   [o set:gamma[x4.getId] at:3];
   [o set:gamma[x5.getId] at:4];
   [o set:gamma[x6.getId] at:5];
   [o set:gamma[x7.getId] at:6];
   
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"0x%lx x1 = %@\n", (unsigned long)gamma[x1.getId], gamma[x1.getId]);
         NSLog(@"0x%lx x2 = %@\n", (unsigned long)gamma[x2.getId], gamma[x2.getId]);
         NSLog(@"0x%lx x3 = %@\n", (unsigned long)gamma[x3.getId], gamma[x3.getId]);
         NSLog(@"0x%lx x4 = %@\n", (unsigned long)gamma[x4.getId], gamma[x4.getId]);
         NSLog(@"0x%lx x5 = %@\n", (unsigned long)gamma[x5.getId], gamma[x5.getId]);
         NSLog(@"0x%lx x6 = %@\n", (unsigned long)gamma[x6.getId], gamma[x6.getId]);
         NSLog(@"0x%lx x7 = %@\n", (unsigned long)gamma[x7.getId], gamma[x7.getId]);
         //         NSLog(@"%lx cout = %@\n", (unsigned long)gamma[cout.getId], gamma[cout.getId]);
         
         [cp labelBitVarHeuristic:h];
         
         NSLog(@"Solution Found:");
         NSLog(@"x1 = %@\n", gamma[x1.getId]);
         NSLog(@"x2 = %@\n", gamma[x2.getId]);
         NSLog(@"x3 = %@\n", gamma[x3.getId]);
         NSLog(@"x4 = %@\n", gamma[x4.getId]);
         NSLog(@"x5 = %@\n", gamma[x5.getId]);
         NSLog(@"x6 = %@\n", gamma[x6.getId]);
         NSLog(@"x7 = %@\n", gamma[x7.getId]);
         //         NSLog(@"x8 = %@\n", gamma[x8.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"End Test of Equalb with no backjumping search\n");
}

//CPBitExtract
-(void) testBitExtract
{
   NSLog(@"Begin Test 1 of bit Extract constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   unsigned int yMin[1];
   unsigned int yMax[1];
   
   min[0] = 0xB77BEFDF;
   max[0] = 0xB77BEFDF;
   yMin[0] = 0x00000000;
   yMax[0] = 0x0000FFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:yMin up:yMax bitLength:16];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x from:0 to:15 eq:y]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[y.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", gamma[y.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
      NSLog(@"x = %@\n", [cp stringValue:x]);
      NSLog(@"y = %@\n", [cp stringValue:y]);
   }];
   XCTAssertTrue([[cp stringValue:x] isEqualToString:@"10110111011110111110111111011111"],
                 @"testBitORConstraint: Bit Pattern for x is incorrect.");
   NSLog(@"End Test 1 of bit Extract constraint.\n");
   
}
//CPBitExtract
-(void) testBitExtract2
{
   NSLog(@"Begin Test 2 of bit Extract constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   unsigned int yMin[1];
   unsigned int yMax[1];
   
   min[0] = 0xB77BEFDF;
   max[0] = 0xB77BEFDF;
   yMin[0] = 0x00000000;
   yMax[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:yMin up:yMax bitLength:16];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x from:16 to:31 eq:y]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[y.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 2 of bit Extract constraint.\n");
   
}
//CPBitExtract
-(void) testBitExtract3
{
   NSLog(@"Begin Test 3 of bit Extract constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   unsigned int yMin[1];
   unsigned int yMax[1];
   
   min[0] = 0xB77BEFDF;
   max[0] = 0xB77BEFDF;
   yMin[0] = 0x00000000;
   yMax[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:yMin up:yMax bitLength:3];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x from:23 to:25 eq:y]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[y.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 3 of bit Extract constraint.\n");
   
}
//CPBitExtract
-(void) testBitExtract4
{
   NSLog(@"Begin Test 4 of bit Extract constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[2];
   unsigned int max[2];
   
   unsigned int yMin[1];
   unsigned int yMax[1];
   
   min[0] = 0xB77BEFDF;
   min[1] = 0xDFEFFBFF;
   max[0] = 0xB77BEFDF;
   max[1] = 0xDFEFFBFF;
   yMin[0] = 0x00000000;
   yMax[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:64];
   id<ORBitVar> y = [ORFactory bitVar:m low:yMin up:yMax bitLength:3];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x from:55 to:57 eq:y]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[y.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 4 of bit Extract constraint.\n");
   
}
//CPBitExtract
-(void) testBitExtract5
{
   NSLog(@"Begin Test 5 of bit Extract constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[2];
   unsigned int max[2];
   
   unsigned int yMin[1];
   unsigned int yMax[1];
   
   min[0] = 0xB77BE00F;
   min[1] = 0xDFEFFBFF;
   max[0] = 0xB77BEFFF;
   max[1] = 0xDFEFFBFF;
   yMin[0] = 0x000000FD;
   yMax[0] = 0xFFFFFFFD;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:yMin up:yMax bitLength:8];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x from:3 to:11 eq:y]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[y.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 5 of bit Extract constraint.\n");
   
}

-(void) testBitExtract6
{
   NSLog(@"Begin Test 6 of bit Extract constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[2];
   unsigned int max[2];
   
   unsigned int yMin[1];
   unsigned int yMax[1];
   
   min[0] = 0xB77BEF0F;
   min[1] = 0xDFEFFBFF;
   max[0] = 0xB77BEFDF;
   max[1] = 0xDFEFFBFF;
   yMin[0] = 0x1;
   yMax[0] = 0x1;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:yMin up:yMax bitLength:1];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x from:6 to:6 eq:y]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:1]];
   [o set:gamma[y.getId] at:0];
   [o set:gamma[x.getId] at:1];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 6 of bit Extract constraint.\n");
   
}

-(void) testBitSubtract
{
   NSLog(@"Begin Test of bit Subtract constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   unsigned int xmin[1];
   unsigned int ymin[1];
   
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   xmin[0] = 0x7FFFFFFF;
   ymin[0] = 0x00000001;
   id<ORBitVar> x = [ORFactory bitVar:m low:xmin up:xmin bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:ymin up:ymin bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:min up:max bitLength:32];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x minus:y eq:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test of bit Subtract constraint.\n");
   
}

-(void) testBitMultiply
{
   NSLog(@"Begin Test of bit Multiply constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[2];
   unsigned int max[2];
   
   unsigned int xmin[1];
   unsigned int ymin[1];
   
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   min[1] = 0x00000000;
   max[1] = 0xFFFFFFFF;
   xmin[0] = 0xFFFFFFFF;
   ymin[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:xmin up:xmin bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:ymin up:ymin bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:min up:max bitLength:64];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x times:y eq:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test of bit Multiply constraint.\n");
   
}

-(void) testBitShiftL
{
   NSLog(@"Begin Test of bit Shift L constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[2];
   unsigned int max[2];
   
//   unsigned int xmin[2];
   unsigned int ymin[2];
   unsigned int ymax[2];
   
   unsigned int rmin[2];
   unsigned int rmax[2];

   min[0] =0xFFDFF7FB;//0xFFDFF7FBFBF7DEED
   max[0] = 0xFFDFF7FB;
   min[1] = 0xFBF7DE00;
   max[1] = 0xFBF7DEFF;
   ymax[0] = 0xFFFFFFFF;
   ymax[1] = 0xFFFFFFFF;
   ymin[0] = 0x00000000;
   ymin[1] = 0x00000000;
   rmin[0] = 0x00000ED0;
   rmin[1] = 0x00000000;
   rmax[0] = 0xFFFFFEDF;
   rmax[1] = 0xFFFFFFFF;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:64];
   id<ORBitVar> y = [ORFactory bitVar:m low:rmin up:rmax bitLength:64];
//   id<ORBitVar> z = [ORFactory bitVar:m low:ymin up:ymax bitLength:64];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x shiftLBy:36 eq:y]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:1]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test of bit ShiftL constraint.\n");
   
}

-(void) testBitSLE
{
   NSLog(@"Begin Test of bit Signed LE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   
   unsigned int min[2];
   unsigned int max[2];
   
//   unsigned int xmin[2];
   unsigned int ymin[2];
   unsigned int ymax[2];
   
   unsigned int rmin[2];
   unsigned int rmax[2];
   
   min[0] =0x0FDFF7FB;//0xFFDFF7FBFBF7DEED
   max[0] = 0x0FDFF7FB;
   min[1] = 0x0FDFF7FB;
   max[1] = 0x0FDFF7FB;
   ymax[0] = 0xFFDFF7FB;
   ymax[1] = 0xFFDFF7FB;
   ymin[0] = 0xFFDFF7FB;
   ymin[1] = 0xFFDFF7FB;
   rmin[0] = 0x00000000;
   rmin[1] = 0x00000000;
   rmax[0] = 0xFFFFFFFF;
   rmax[1] = 0xFFFFFFFF;
   
//   unsigned int zero = 0;
//   unsigned int one = 1;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:ymin up:ymax bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:rmin up:rmax bitLength:1];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x SLE:y eval:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test of bit Signed LE constraint.\n");
   
}

-(void) testBitSLE2
{
   NSLog(@"Begin Test 2 of bit Signed LE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   
   unsigned int min[2];
   unsigned int max[2];
   
//   unsigned int xmin[2];
   unsigned int ymin[2];
   unsigned int ymax[2];
   
   unsigned int rmin[2];
   unsigned int rmax[2];
   
   min[0] =0xB77BEFDF;//0xFFDFF7FBFBF7DEED
   max[0] = 0xB77BEFDF;
   min[1] = 0xDFEFFBFF;
   max[1] = 0xDFEFFBFF;
   ymax[0] = 0xFFDFF7FB;
   ymax[1] = 0xFFDFF7FB;
   ymin[0] = 0xFFDFF7FB;
   ymin[1] = 0xFFDFF7FB;
   rmin[0] = 0x00000000;
   rmin[1] = 0x00000000;
   rmax[0] = 0xFFFFFFFF;
   rmax[1] = 0xFFFFFFFF;
   
//   unsigned int zero = 0;
//   unsigned int one = 1;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:rmax up:rmax bitLength:1];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x SLE:y eval:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 2 of bit Signed LE constraint.\n");
   
}

-(void) testBitSLE3
{
   NSLog(@"Begin Test 3 of bit Signed LE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   
   unsigned int min[2];
   unsigned int max[2];
   
//   unsigned int xmin[2];
   unsigned int ymin[2];
   unsigned int ymax[2];
   
   unsigned int rmin[2];
   unsigned int rmax[2];
   
   min[0] =0x700FF7FB;//0xFFDFF7FBFBF7DEED
   max[0] = 0x700FF7FB;
   min[1] = 0xFFFFF7FB;
   max[1] = 0xFFFFF7FB;
   ymax[0] = 0x7FDFF7FB;
   ymax[1] = 0xFFDFF7FB;
   ymin[0] = 0x7FDFF7FB;
   ymin[1] = 0xFFDFF7FB;
   rmin[0] = 0x00000000;
   rmin[1] = 0x00000000;
   rmax[0] = 0x00000001;
   rmax[1] = 0x00000001;
   
//   unsigned int zero = 0;
//   unsigned int one = 1;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:ymin up:ymax bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:rmin up:rmax bitLength:1];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x SLE:y eval:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 3 of bit Signed LE constraint.\n");
   
}

-(void) testBitSLE4
{
   NSLog(@"Begin Test 4 of bit Signed LE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   
   unsigned int min[2];
   unsigned int max[2];
   
//   unsigned int xmin[2];
   unsigned int ymin[2];
   unsigned int ymax[2];
   
   unsigned int rmin[2];
   unsigned int rmax[2];
   
   min[0] =0x700FF7FB;//0xFFDFF7FBFBF7DEED
   max[0] = 0x700FF7FB;
   min[1] = 0x0FDFF7FB;
   max[1] = 0x0FDFF7FB;
   ymax[0] = 0xFFFFFFFF;
   ymax[1] = 0xFFFFFFFF;
   ymin[0] = 0x00000000;
   ymin[1] = 0x00000000;
   rmin[0] = 0x00000000;
   rmin[1] = 0x00000000;
   rmax[0] = 0x00000001;
   rmax[1] = 0x00000000;
   
//   unsigned int zero = 0;
//   unsigned int one = 1;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:ymin up:ymax bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:rmin up:rmax bitLength:1];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x SLE:y eval:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 4 of bit Signed LE constraint.\n");
   
}

-(void) testBitSLE5
{
   NSLog(@"Begin Test 5 of bit Signed LE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   
   unsigned int min[2];
   unsigned int max[2];
   
//   unsigned int xmin[2];
   unsigned int ymin[2];
   unsigned int ymax[2];
   
   unsigned int rmin[2];
   unsigned int rmax[2];
   
   min[0] =0x700FF7FB;//0xFFDFF7FBFBF7DEED
   max[0] = 0x700FF7FB;
   min[1] = 0x0FDFF7FB;
   max[1] = 0x0FDFF7FB;
   ymax[0] = 0xFFFFFFFF;
   ymax[1] = 0xFFFFFFFF;
   ymin[0] = 0x00000000;
   ymin[1] = 0x00000000;
   rmin[0] = 0x00000001;
   rmin[1] = 0x00000000;
   rmax[0] = 0x00000001;
   rmax[1] = 0x00000001;

   
//   unsigned int zero = 0;
//   unsigned int one = 1;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:ymin up:ymax bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:rmin up:rmax bitLength:1];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x SLE:y eval:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 5 of bit Signed LE constraint.\n");
   
}

-(void) testBitSLE6
{
   NSLog(@"Begin Test 6 of bit Signed LE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   
   unsigned int min[2];
   unsigned int max[2];
   
//   unsigned int xmin[2];
   unsigned int ymin[2];
   unsigned int ymax[2];
   
   unsigned int rmin[2];
   unsigned int rmax[2];
   
   min[0] =0x0FDFF7FB;//0xFFDFF7FBFBF7DEED
   max[0] = 0x0FDFF7FB;
   min[1] = 0x0FDFF7FB;
   max[1] = 0x0FDFF7FB;
   ymax[0] = 0xFFDFF7FB;
   ymax[1] = 0xFFDFF7FB;
   ymin[0] = 0xFFDFF7FB;
   ymin[1] = 0xFFDFF7FB;
   rmin[0] = 0x00000000;
   rmin[1] = 0x00000000;
   rmax[0] = 0xFFFFFFFF;
   rmax[1] = 0xFFFFFFFF;
   
//   unsigned int zero = 0;
//   unsigned int one = 1;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:ymin up:ymax bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:rmin up:rmax bitLength:1];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x SLE:y eval:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 6 of bit Signed LE constraint.\n");
   
}

-(void) testBitNOT1
{
   NSLog(@"Begin Test 1 of Bit NOT constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   
   unsigned int min[2];
   unsigned int max[2];
   
//   unsigned int xmin[2];
   unsigned int ymin[2];
   unsigned int ymax[2];
   
   unsigned int rmin[2];
   unsigned int rmax[2];
   
   min[0] =0xB77BEFDF;//0xFFDFF7FBFBF7DEED
   max[0] = 0xB77BEFDF;
   min[1] = 0xDFEFFBFF;
   max[1] = 0xDFEFFBFF;
   ymax[0] = 0xFFFFFFFF;
   ymax[1] = 0xFFFFFFFF;
   ymin[0] = 0x00000000;
   ymin[1] = 0x00000000;
   rmin[0] = 0x00000000;
   rmin[1] = 0x00000000;
   rmax[0] = 0xFFFFFFFF;
   rmax[1] = 0xFFFFFFFF;

   
//   unsigned int zero = 0;
//   unsigned int one = 1;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:ymin up:ymax bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:rmin up:rmax bitLength:1];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x not:y]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 1 of Bit NOT constraint.\n");
   
}

-(void) testBitLE
{
   NSLog(@"Begin Test of bit LE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   
   unsigned int min[2];
   unsigned int max[2];
   
//   unsigned int xmin[2];
   unsigned int ymin[2];
   unsigned int ymax[2];
   
   unsigned int rmin[2];
   unsigned int rmax[2];
   
   min[0] =0x0FDFF7FB;//0xFFDFF7FBFBF7DEED
   max[0] = 0x0FDFF7FB;
   min[1] = 0x0FDFF7FB;
   max[1] = 0x0FDFF7FB;
   ymax[0] = 0xFFDFF7FB;
   ymax[1] = 0xFFDFF7FB;
   ymin[0] = 0xFFDFF7FB;
   ymin[1] = 0xFFDFF7FB;
   rmin[0] = 0x00000000;
   rmin[1] = 0x00000000;
   rmax[0] = 0xFFFFFFFF;
   rmax[1] = 0xFFFFFFFF;
   
//   unsigned int zero = 0;
//   unsigned int one = 1;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:ymin up:ymax bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:rmin up:rmax bitLength:1];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x LE:y eval:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test of bit  LE constraint.\n");
   
}

-(void) testBitLE2
{
   NSLog(@"Begin Test 2 of bit  LE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   
   unsigned int min[2];
   unsigned int max[2];
   
//   unsigned int xmin[2];
   unsigned int ymin[2];
   unsigned int ymax[2];
   
   unsigned int rmin[2];
   unsigned int rmax[2];
   
   min[0] =0xB77BEFDF;//0xFFDFF7FBFBF7DEED
   max[0] = 0xB77BEFDF;
   min[1] = 0xDFEFFBFF;
   max[1] = 0xDFEFFBFF;
   ymax[0] = 0xFFDFF7FB;
   ymax[1] = 0xFFDFF7FB;
   ymin[0] = 0xFFDFF7FB;
   ymin[1] = 0xFFDFF7FB;
   rmin[0] = 0x00000000;
   rmin[1] = 0x00000000;
   rmax[0] = 0xFFFFFFFF;
   rmax[1] = 0xFFFFFFFF;
   
//   unsigned int zero = 0;
//   unsigned int one = 1;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:rmax up:rmax bitLength:1];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x LE:y eval:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 2 of bit LE constraint.\n");
   
}

-(void) testBitLE3
{
   NSLog(@"Begin Test 3 of bit LE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   
   unsigned int min[2];
   unsigned int max[2];
   
//   unsigned int xmin[2];
   unsigned int ymin[2];
   unsigned int ymax[2];
   
   unsigned int rmin[2];
   unsigned int rmax[2];
   
   min[0] =0x700FF7FB;//0xFFDFF7FBFBF7DEED
   max[0] = 0x700FF7FB;
   min[1] = 0xFFFFF7FB;
   max[1] = 0xFFFFF7FB;
   ymax[0] = 0x7FDFF7FB;
   ymax[1] = 0xFFDFF7FB;
   ymin[0] = 0x7FDFF7FB;
   ymin[1] = 0xFFDFF7FB;
   rmin[0] = 0x00000000;
   rmin[1] = 0x00000000;
   rmax[0] = 0x00000001;
   rmax[1] = 0x00000001;
   
//   unsigned int zero = 0;
//   unsigned int one = 1;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:ymin up:ymax bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:rmin up:rmax bitLength:1];
   unsigned int test[1];
   test[0] = 0xFFFFFFFE;
//   id<ORBitVar> a = [ORFactory bitVar:m low:test up:test bitLength:32];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   
   [m add:[ORFactory bit:x LE:y eval:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"z = %@\n", gamma[z.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 3 of bit LE constraint.\n");
   
}


@end
