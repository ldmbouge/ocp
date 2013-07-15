//
//  testBitConstraints.m
//  Clo
//
//  Created by Greg Johnson on 6/10/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//
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

#define BUF_SIZE 33

char *int2bin(int a, char *buffer, int buf_size) {
   buffer += (buf_size - 1);
   
   for (int i = 31; i >= 0; i--) {
      *buffer-- = (a & 1) + '0';
      
      a >>= 1;
   }
   
   return buffer;
}


@implementation testBitConstraints
- (void)setUp
{
    [super setUp];    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

-(void)testEqualityConstraint
{
    NSLog(@"Begin testing bitwise equality constraint\n");
   
    id<ORModel> m = [ORFactory createModel];
    unsigned int min[2];
    unsigned int max[2];
   min[0] = min[1] = 0;
   max[0] = max[1] = CP_UMASK;
   
    id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:64];
    id<ORBitVar> y = [ORFactory bitVar:m low:min up:max bitLength:64];
    min[1] = 8;
    max[1] = 12;
    id<ORBitVar> z = [ORFactory bitVar:m low:min up:max bitLength:64];
    
   min[0] = 0xAAAAAAAA;
   min[1] = 0x55555555;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   id<ORBitVar> a = [ORFactory bitVar:m low:min up:max bitLength:64];
   min[0] = min[1] = 0;
   max[0] = max[1] = CP_UMASK;
   id<ORBitVar> b = [ORFactory bitVar:m low:min up:max bitLength:64];
   min[0] = min[1] = 0;
   max[0] = max[1] = CP_UMASK;
   id<ORBitVar> c = [ORFactory bitVar:m low:min up:max bitLength:64];
       
   NSLog(@"Initial values: a=b=c and x=y=z");
    NSLog(@"x = %@\n", x);
    NSLog(@"y = %@\n", y);
    NSLog(@"z = %@\n", z);
   [m add:[ORFactory bit:x eq:y]];
   [m add:[ORFactory bit:y eq:z]];

   NSLog(@"a = %@\n", a);
   NSLog(@"b = %@\n", b);
   NSLog(@"c = %@\n", c);
   [m add:[ORFactory bit:a eq:b]];
   [m add:[ORFactory bit:b eq:c]];

   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
    [cp solve: ^() {
       @try {
          NSLog(@"After Posting:");
          NSLog(@"a = %@\n", [cp stringValue:a]);
          NSLog(@"b = %@\n", [cp stringValue:b]);
          NSLog(@"c = %@\n", [cp stringValue:c]);
          NSLog(@"x = %@\n", [cp stringValue:x]);
          NSLog(@"y = %@\n", [cp stringValue:y]);
          NSLog(@"z = %@\n", [cp stringValue:z]);
          [cp labelUpFromLSB:x];
          [cp labelUpFromLSB:y];
          [cp labelUpFromLSB:z];
          [cp labelUpFromLSB:a];
          [cp labelUpFromLSB:b];
          [cp labelUpFromLSB:c];
          NSLog(@"Solution Found:");
          NSLog(@"a = %@\n", [cp stringValue:a]);
          NSLog(@"b = %@\n", [cp stringValue:b]);
          NSLog(@"c = %@\n", [cp stringValue:c]);
          NSLog(@"x = %@\n", [cp stringValue:x]);
          NSLog(@"y = %@\n", [cp stringValue:y]);
          NSLog(@"z = %@\n", [cp stringValue:z]);
          STAssertTrue([[cp stringValue:x] isEqualToString:[cp stringValue:y]], @"testBitEqualityConstraint: Bit Patterns for x and y should be equal.");
          STAssertTrue([[cp stringValue:x] isEqualToString:[cp stringValue:z]], @"testBitEqualityConstraint: Bit Patterns for x and z should be equal.");
          STAssertTrue([[cp stringValue:a] isEqualToString:[cp stringValue:b]], @"testBitEqualityConstraint: Bit Patterns for a and b should be equal.");
          STAssertTrue([[cp stringValue:a] isEqualToString:[cp stringValue:c]], @"testBitEqualityConstraint: Bit Patterns for a and c should be equal.");
       }
       @catch (NSException *exception) {
          NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
       }
    }];
    
    NSLog(@"End testing bitwise equality constraint.\n");
}

- (void)testANDConstraint
{
    NSLog(@"Begin testing bitwise AND constraint\n");
    
    id<ORModel> m = [ORFactory createModel];
    unsigned int min[2];
    unsigned int max[2];
    
    max[0] = 0xEEEEEEEE;
    max[1] = 0xEEEEEEEE;
    min[0] = 0x88888888;
    min[1] = 0x88888888;
    
    id<ORBitVar> a = [ORFactory bitVar:m low:min up:max bitLength:64];
    max[0] = 0xFFF0FFF0;
    max[1] = 0xFFF0FFF0;
    min[0] = 0xF000F000;
    min[1] = 0xF000F000;
    id<ORBitVar> b = [ORFactory bitVar:m low:min up:max bitLength:64];
    max[0] = 0xFFFFFFFF;
    max[1] = 0xFFFF8000;
    min[0] = 0xEEE00000;
    min[1] = 0x00000000;
    id<ORBitVar> c = [ORFactory bitVar:m low:min up:max bitLength:64];
    
    
   NSLog(@"Initial values:");
    NSLog(@"a = %@\n", a);
    NSLog(@"b = %@\n", b);
    NSLog(@"c = %@\n", c);
    
   [m add:[ORFactory bit:a and:b eq:c]];
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   [cp solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"a = %@\n", [cp stringValue:a]);
         NSLog(@"b = %@\n", [cp stringValue:b]);
         NSLog(@"c = %@\n", [cp stringValue:c]);
         [cp labelUpFromLSB:a];
         [cp labelUpFromLSB:b];
         [cp labelUpFromLSB:c];
         NSLog(@"Solution Found:");
         NSLog(@"a = %@\n", [cp stringValue:a]);
         NSLog(@"b = %@\n", [cp stringValue:b]);
         NSLog(@"c = %@\n", [cp stringValue:c]);
         
         STAssertTrue([[cp stringValue:a] isEqualToString:@"1110111011101000100010001000100010001000100010001000100010001000"],
                      @"testBitANDConstraint: Bit Pattern for a is incorrect.");
         STAssertTrue([[cp stringValue:b] isEqualToString:@"1111111011100000111100000000000011110000000000001111000000000000"],
                      @"testBitANDConstraint: Bit Pattern for b is incorrect.");
         STAssertTrue([[cp stringValue:c] isEqualToString:@"1110111011100000100000000000000010000000000000001000000000000000"],
                      @"testBitANDConstraint: Bit Pattern for c is incorrect.");
      }
      @catch (NSException *exception) {
         
         NSLog(@"testANDConstraint: Caught %@: %@", [exception name], [exception reason]);
         
      }
   }];
    NSLog(@"End testing bitwise AND constraint.\n");
    
}

-(void) testORConstraint
{
    NSLog(@"Begin testing bitwise OR constraint\n");
    
   id<ORModel> m = [ORFactory createModel];
    unsigned int min[2];
    unsigned int max[2];
    
    max[0] = 0xEEEEEEEE;
    max[1] = 0xEEEEEEEE;
    min[0] = 0x88888888;
    min[1] = 0x88888888;
    id<ORBitVar> d = [ORFactory bitVar:m low:min up:max bitLength:64];
    max[0] = 0xFFF0FFF0;
    max[1] = 0xFFF0FFF0;
    min[0] = 0xF000F000;
    min[1] = 0xF000F000;
    id<ORBitVar> e = [ORFactory bitVar:m low:min up:max bitLength:64];
    max[0] = 0xFFFFFFFF;
    max[1] = 0xFFFFF888;
    min[0] = 0xFFFE0000;
    min[1] = 0x00000000;
    id<ORBitVar> f = [ORFactory bitVar:m low:min up:max bitLength:64];
   NSLog(@"Initial values:");
    NSLog(@"d = %@\n", d);
    NSLog(@"e = %@\n", e);
    NSLog(@"f = %@\n", f);
    
   [m add:[ORFactory bit:d or:e eq:f]];
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   [cp solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"d = %@\n", [cp stringValue:d]);
         NSLog(@"e = %@\n", [cp stringValue:e]);
         NSLog(@"f = %@\n", [cp stringValue:f]);
         [cp labelUpFromLSB:d];
         [cp labelUpFromLSB:e];
         [cp labelUpFromLSB:f];
         NSLog(@"Found Solution:");
         NSLog(@"d = %@\n", [cp stringValue:d]);
         NSLog(@"e = %@\n", [cp stringValue:e]);
         NSLog(@"f = %@\n", [cp stringValue:f]);
         STAssertTrue([[cp stringValue:d] isEqualToString:@"1000100010001110100010001000100010001000100010001000100010001000"],
                      @"testBitORConstraint: Bit Pattern for d is incorrect.");
         STAssertTrue([[cp stringValue:e] isEqualToString:@"1111011101110000111100000000000011110000000000001111000000000000"],
                      @"testBitORConstraint: Bit Pattern for e is incorrect.");
         STAssertTrue([[cp stringValue:f] isEqualToString:@"1111111111111110111110001000100011111000100010001111100010001000"],
                      @"testBitORConstraint: Bit Pattern for f is incorrect.");

      }
      @catch (NSException *exception) {
         
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
         
      }
      
   }];
    
//    NSLog(@"d = %@\n", d);
//    NSLog(@"e = %@\n", e);
//    NSLog(@"f = %@\n", f);
    
    
    NSLog(@"End testing bitwise OR constraint.\n");
    
}

-(void) testNOTConstraint
{
    NSLog(@"Begin testing bitwise NOT constraint\n");
    
   id<ORModel> m = [ORFactory createModel];
    unsigned int min[2];
    unsigned int max[2];
    
    min[1] = 0x000000AA;
    max[1] = 0xFFFFFFFF;
    id<ORBitVar> g = [ORFactory bitVar:m low:min up:max bitLength:64];
    min[1] = 0x00000055;
    max[0] = 0xFFFFFFFF;
    max[1] = 0xFFFFFFFF;
    id<ORBitVar> h = [ORFactory bitVar:m low:min up:max bitLength:64];
    
   NSLog(@"Initial values:");
    NSLog(@"g = %@\n", g);
    NSLog(@"h = %@\n", h);
    
   [m add:[ORFactory bit:g not:h]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   [cp solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"g = %@\n", [cp stringValue:g]);
         NSLog(@"h = %@\n", [cp stringValue:h]);
         [cp labelUpFromLSB:g];
         [cp labelUpFromLSB:h];
         NSLog(@"Solution Found:");
         NSLog(@"g = %@\n", [cp stringValue:g]);
         NSLog(@"h = %@\n", [cp stringValue:h]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
    NSLog(@"End testing bitwise NOT constraint.\n");
    
}

-(void) testXORConstraint
{
    NSLog(@"Begin testing bitwise XOR constraint\n");
    
   id<ORModel> m = [ORFactory createModel];
    unsigned int min[2];
    unsigned int max[2];
    
    max[0] = 0xEEEEEEEE;
    max[1] = 0xEEEEEEEE;
    min[0] = 0x88888888;
    min[1] = 0x88888888;
    id<ORBitVar> i = [ORFactory bitVar:m low:min up:max bitLength:64];
    max[0] = 0xFFF0FFF0;
    max[1] = 0xFFF0FFF0;
    min[0] = 0xF000F000;
    min[1] = 0xF000F000;
    id<ORBitVar> j = [ORFactory bitVar:m low:min up:max bitLength:64];
    max[0] = 0xFFFFFFFF;
    max[1] = 0xFFFF1008;
    min[0] = 0x7FFE0000;
    min[1] = 0x00000000;
    id<ORBitVar> k = [ORFactory bitVar:m low:min up:max bitLength:64];
    
   NSLog(@"Initial values:");
    NSLog(@"i = %@\n", i);
    NSLog(@"j = %@\n", j);
    NSLog(@"k = %@\n", k);
    
    
   [m add:[ORFactory bit:i xor:j eq:k]];
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   [cp solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"i = %@\n", [cp stringValue:i]);
         NSLog(@"j = %@\n", [cp stringValue:j]);
         NSLog(@"k = %@\n", [cp stringValue:k]);
         [cp labelUpFromLSB:i];
         [cp labelUpFromLSB:j];
         [cp labelUpFromLSB:k];
         NSLog(@"Solution Found:");
         NSLog(@"i = %@\n", [cp stringValue:i]);
         NSLog(@"j = %@\n", [cp stringValue:j]);
         NSLog(@"k = %@\n", [cp stringValue:k]);
         STAssertTrue([[cp stringValue:i] isEqualToString:@"1000100010001110100010001000100010001000100010001110100010001000"],
                      @"testBitORConstraint: Bit Pattern for i is incorrect.");
         STAssertTrue([[cp stringValue:j] isEqualToString:@"1111011101110000111100000000000011110000000000001111100010000000"],
                      @"testBitORConstraint: Bit Pattern for j is incorrect.");
         STAssertTrue([[cp stringValue:k] isEqualToString:@"0111111111111110011110001000100001111000100010000001000000001000"],
                      @"testBitORConstraint: Bit Pattern for k is incorrect.");

      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
    NSLog(@"End testing bitwise XOR constraint.\n");
    
}

-(void) testShiftLConstraint
{
    NSLog(@"Begin testing bitwise ShiftL constraint\n");
    
   char buffer[BUF_SIZE];
   char buffer2[BUF_SIZE];
   buffer[BUF_SIZE - 1] = '\0';
   buffer2[BUF_SIZE - 1] = '\0';
   

   id<ORModel> m = [ORFactory createModel];
    unsigned int min[2];
    unsigned int max[2];
    
   min[0] = 0xB77BEFDF;
   min[1] = 0xDFEFFBFF;
   max[0] = 0xB77BEFDF;
   max[1] = 0xDFEFFBFF;
   
   id<ORBitVar> p = [ORFactory bitVar:m low:min up:max bitLength:64];
   min[1] = 0;
   min[0] = 0;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   id<ORBitVar> q = [ORFactory bitVar:m low:min up:max bitLength:64];

   [m add:[ORFactory bit:p shiftLBy:3 eq:q]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   NSLog(@"Initial values:");
   NSLog(@"p = %@\n", p);
   NSLog(@"q = %@\n", q);
   [cp solve: ^() {
      @try {

         NSLog(@"After Posting:");
         NSLog(@"p = %@\n", [cp stringValue:p]);
         NSLog(@"q = %@\n", [cp stringValue:q]);
         [cp labelUpFromLSB:p];
         [cp labelUpFromLSB:q];
         NSLog(@"Solution Found:");
         NSLog(@"p = %@\n", [cp stringValue:p]);
         NSLog(@"q = %@\n", [cp stringValue:q]);
         STAssertTrue([[cp stringValue:p] isEqualToString:@"1011011101111011111011111101111111011111111011111111101111111111"],
                      @"testBitORConstraint: Bit Pattern for p is incorrect.");
         STAssertTrue([[cp stringValue:q] isEqualToString:@"1011101111011111011111101111111011111111011111111101111111111000"],
                      @"testBitORConstraint: Bit Pattern for q is incorrect.");
      }
         @catch (NSException *exception) {
         
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
         
      }
      
   }];
    NSLog(@"End testing bitwise ShiftL constraint.\n");
}

-(void) testShiftLConstraint2
{
   NSLog(@"Begin testing bitwise ShiftL constraint\n");
   
   char buffer[BUF_SIZE];
   char buffer2[BUF_SIZE];
   buffer[BUF_SIZE - 1] = '\0';
   buffer2[BUF_SIZE - 1] = '\0';
   
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min;
   unsigned int max;
   
   min = 0x00000000;
   max = 0xFFFFFFFF;
   
   id<ORBitVar> p = [ORFactory bitVar:m low:&min up:&max bitLength:32];
   min = 0x82082082;
   max = 0xDF7DF7DF;
   id<ORBitVar> q = [ORFactory bitVar:m low:&min up:&max bitLength:32];
   
   [m add:[ORFactory bit:p shiftLBy:3 eq:q]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   NSLog(@"Initial values:");
   NSLog(@"p = %@\n", p);
   NSLog(@"q = %@\n", q);
   [cp solve: ^() {
      @try {
         
         NSLog(@"After Posting:");
         NSLog(@"p = %@\n", p);
         NSLog(@"q = %@\n", q);
         [cp labelUpFromLSB:p];
         [cp labelUpFromLSB:q];
         NSLog(@"Solution Found:");
         NSLog(@"p = %@\n", p);
         NSLog(@"q = %@\n", q);
//         STAssertTrue([[p stringValue] isEqualToString:@"1011011101111011111011111101111111011111111011111111101111111111"],@"testBitORConstraint: Bit Pattern for p is incorrect.");
//         STAssertTrue([[q stringValue] isEqualToString:@"1011101111011111011111101111111011111111011111111101111111111000"],@"testBitORConstraint: Bit Pattern for q is incorrect.");
      }
      @catch (NSException *exception) {
         
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
         
      }
      
   }];
   NSLog(@"End testing bitwise ShiftL constraint.\n");
}
-(void) testROTLConstraint
{
   NSLog(@"Begin testing ROTL bitwise constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[2];
   unsigned int max[2];
   
   min[0] = 0xB77BEFDF;
   min[1] = 0xDFEFFBFF;
   max[0] = 0xB77BEFDF;
   max[1] = 0xDFEFFBFF;
   id<ORBitVar> p = [ORFactory bitVar:m low:min up:max bitLength:32];
   min[0] = 0;
   min[1] = 0;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   id<ORBitVar> q = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:min up:max bitLength:32];
   
//   [m add:[CPFactory bitRotateL:p by:33 equals:q]];
   [m add:[ORFactory bit:p rotateLBy:7 eq:q]];
   [m add:[ORFactory bit:r rotateLBy:7 eq:q]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   
   NSLog(@"Initial values:");
   NSLog(@"p = %@\n", p);
   NSLog(@"q = %@\n", q);
   [cp solve: ^() {
      @try {
         
         NSLog(@"After Posting:");
         NSLog(@"p = %@\n", p);
         NSLog(@"q = %@\n", q);
         [cp labelUpFromLSB:p];
         [cp labelUpFromLSB:q];
         NSLog(@"Solution Found:");
         NSLog(@"p = %@\n", p);
         NSLog(@"q = %@\n", q);
//         STAssertTrue([[p stringValue] isEqualToString:@"1011011101111011111011111101111111011111111011111111101111111111"],@"testBitORConstraint: Bit Pattern for p is incorrect.");
//         STAssertTrue([[q stringValue] isEqualToString:@"1011111111011111111101111111111101101110111101111101111110111111"],@"testBitORConstraint: Bit Pattern for q is incorrect.");
         STAssertTrue([[cp stringValue:p] isEqualToString:@"10110111011110111110111111011111"],
                      @"testBitORConstraint: Bit Pattern for p is incorrect.");
         STAssertTrue([[cp stringValue:q] isEqualToString:@"10111101111101111110111111011011"],
                      @"testBitORConstraint: Bit Pattern for q is incorrect.");
         STAssertTrue([[cp stringValue:r] isEqualToString:@"10110111011110111110111111011111"],
                      @"testBitORConstraint: Bit Pattern for p is incorrect.");

      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End testing ROTL bitwise constraint.\n");
}

//-(void) testSumConstraint
//{
//    NSLog(@"Begin testing bitwise Sum constraint\n");
//        
//   id<ORModel> m = [ORFactory createModel];
//   unsigned int min[2];
//   unsigned int max[2];
//   
//
//   min[0] = 0xFFFFFFFF;
//   min[1] = 0xFFFFFFFF;
//   max[0] = 0xFFFFFFFF;
//   max[1] = 0xFFFFFFFF;
//
//   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:64];
//
//   id<ORBitVar> y = [ORFactory bitVar:m low:min up:max bitLength:64];
//
//   min[0] = 0x00000000;//
//   min[1] = 0x00000000;//
//   max[0] = 0xFFFFFFFF;//
//   max[1] = 0xFFFFFFFF;
//   
//   id<ORBitVar> ci = [ORFactory bitVar:m low:min up:max bitLength:64];
//
//   min[0] = 0x00000000;//
//   min[1] = 0x00000000;
//   max[0] = 0xFFFFFFFF;//
//   max[1] = 0xFFFFFFFF;
//
//   id<ORBitVar> z = [ORFactory bitVar:m low:min up:max bitLength:64];
//   id<ORBitVar> co = [ORFactory bitVar:m low:min up:max bitLength:64];
//   
////   [m add:[CPFactory bitADD:x plus:y withCarryIn:ci equals:z withCarryOut:co]];
//   [m add:[ORFactory bit:x plus:y withCarryIn:ci eq:z withCarryOut:co]];
//
//   id<CPProgram,CPBV> cp = [ORFactory createCPProgram:m];
//
//   NSLog(@"Added Sum constraint.\n");
//   NSLog(@"Initial values:");
//   NSLog(@"x    = %@\n", x);
//   NSLog(@"y    = %@\n", y);
//   NSLog(@"cin  = %@\n", ci);
//   NSLog(@"z    = %@\n", z);
//   NSLog(@"cout = %@\n", co);
//
//   [cp solve: ^() {
//      @try {
//         NSLog(@"After Posting:");
//         NSLog(@"cin  = %@\n", ci);
//         NSLog(@"x    = %@\n", x);
//         NSLog(@"y    = %@\n", y);
//         NSLog(@"z    = %@\n", z);
//         NSLog(@"cout = %@\n", co);
//         [cp labelUpFromLSB:x];
//         [cp labelUpFromLSB:y];
//         [cp labelUpFromLSB:z];
//         [cp labelUpFromLSB:ci];
//         [cp labelUpFromLSB:co];
//         NSLog(@"Solution Found:");
//         NSLog(@"cin  = %@\n", ci);
//         NSLog(@"x    = %@\n", x);
//         NSLog(@"y    = %@\n", y);
//         NSLog(@"z    = %@\n", z);
//         NSLog(@"cout = %@\n", co);
////         STAssertTrue([[ci stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111110"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
////         STAssertTrue([[x stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
////         STAssertTrue([[y stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
////         STAssertTrue([[z stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111110"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
////         STAssertTrue([[co stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
//      }
//      @catch (NSException *exception) {
//         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
//      }
//   }];
//}
//-(void) testSumConstraint1
//{
//   NSLog(@"Begin testing bitwise Sum constraint\n");
//   
//
//   id<ORModel> m1 = [ORFactory createModel];
//   unsigned int min[2];
//   unsigned int max[2];
//   
//   min[0] = 0;//
//   min[1] = 0;
//   max[0] = 0xFFFFFFFF;//
//   max[1] = 0xFFFFFFFF;
//   id<ORBitVar> x1 = [ORFactory bitVar:m1 low:min up:max bitLength:64];
//   id<ORBitVar> y1 = [ORFactory bitVar:m1 low:min up:max bitLength:64];
//   
//   id<ORBitVar> z1 =  [ORFactory bitVar:m1 low:min up:max bitLength:64];
//   id<ORBitVar> ci1 = [ORFactory bitVar:m1 low:min up:max bitLength:64];
//   id<ORBitVar> co1 = [ORFactory bitVar:m1 low:min up:max bitLength:64];
//   
//
//   NSLog(@"Initial values:");
//   NSLog(@"x    = %@\n", x1);
//   NSLog(@"y    = %@\n", y1);
//   NSLog(@"cin  = %@\n", ci1);
//   NSLog(@"z    = %@\n", z1);
//   NSLog(@"cout = %@\n", co1);
//   [m1 add:[ORFactory bit:x1 plus:y1 withCarryIn:ci1 eq:z1 withCarryOut:co1]];
//   
//   id<CPProgram,CPBV> cp1 = [ORFactory createCPProgram:m1];
//   NSLog(@"Added Sum constraint.\n");
//   NSLog(@"Initial values:");
//   NSLog(@"x    = %@\n", x1);
//   NSLog(@"y    = %@\n", y1);
//   NSLog(@"cin  = %@\n", ci1);
//   NSLog(@"z    = %@\n", z1);
//   NSLog(@"cout = %@\n", co1);
//   
//   [cp1 solve: ^() {
//      @try {
//         NSLog(@"After Posting:");
//         NSLog(@"cin  = %@\n", ci1);
//         NSLog(@"x    = %@\n", x1);
//         NSLog(@"y    = %@\n", y1);
//         NSLog(@"z    = %@\n", z1);
//         NSLog(@"cout = %@\n", co1);
//         [cp1 labelUpFromLSB:x1];
//         [cp1 labelUpFromLSB:y1];
//         [cp1 labelUpFromLSB:z1];
//         [cp1 labelUpFromLSB:ci1];
//         [cp1 labelUpFromLSB:co1];
//         NSLog(@"Solution Found:");
//         NSLog(@"cin  = %@\n", ci1);
//         NSLog(@"x    = %@\n", x1);
//         NSLog(@"y    = %@\n", y1);
//         NSLog(@"z    = %@\n", z1);
//         NSLog(@"cout = %@\n", co1);
//         STAssertTrue([[ci1 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
//         STAssertTrue([[x1 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
//         STAssertTrue([[y1 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
//         STAssertTrue([[z1 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
//         STAssertTrue([[co1 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
//      }
//      @catch (NSException *exception) {
//         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
//      }
//   }];
//
//}
//-(void) testSumConstraint2
//{
//   NSLog(@"Begin testing bitwise Sum constraint\n");
//   
//
//   id<ORModel> m2 = [ORFactory createModel];
//   unsigned int min[2];
//   unsigned int max[2];
//   
//   min[0] = 0xAAAAAAAA;//
//   min[1] = 0xAAAAAAAA;
//   max[0] = 0xAAAAAAAA;//
//   max[1] = 0xAAAAAAAA;
//   id<ORBitVar> x2 = [ORFactory bitVar:m2 low:min up:max bitLength:64];
//   min[0] = 0x55555555;//
//   min[1] = 0x55555555;
//   max[0] = 0x55555555;//
//   max[1] = 0x55555555;
//   id<ORBitVar> y2 = [ORFactory bitVar:m2 low:min up:max bitLength:64];
//   
//   min[0] = 0;//
//   min[1] = 0;
//   max[0] = 0xFFFFFFFF;//
//   max[1] = 0xFFFFFFFF;
//
//   id<ORBitVar> z2 = [ORFactory bitVar:m2 low:min up:max bitLength:64];
//   id<ORBitVar> ci2 = [ORFactory bitVar:m2 low:min up:max bitLength:64];
//   id<ORBitVar> co2 =  [ORFactory bitVar:m2 low:min up:max bitLength:64];
//   
//   
//   NSLog(@"Initial values:");
//   NSLog(@"x    = %@\n", x2);
//   NSLog(@"y    = %@\n", y2);
//   NSLog(@"cin  = %@\n", ci2);
//   NSLog(@"z    = %@\n", z2);
//   NSLog(@"cout = %@\n", co2);
//   [m2 add:[ORFactory bit:x2 plus:y2 withCarryIn:ci2 eq:z2 withCarryOut:co2]];
//   id<CPProgram,CPBV> cp2 = [ORFactory createCPProgram:m2];
//   NSLog(@"Added Sum constraint.\n");
//   NSLog(@"Initial values:");
//   NSLog(@"x    = %@\n", x2);
//   NSLog(@"y    = %@\n", y2);
//   NSLog(@"cin  = %@\n", ci2);
//   NSLog(@"z    = %@\n", z2);
//   NSLog(@"cout = %@\n", co2);
//   
//   [cp2 solve: ^() {
//      @try {
//         NSLog(@"After Posting:");
//         NSLog(@"cin  = %@\n", ci2);
//         NSLog(@"x    = %@\n", x2);
//         NSLog(@"y    = %@\n", y2);
//         NSLog(@"z    = %@\n", z2);
//         NSLog(@"cout = %@\n", co2);
//         [cp2 labelUpFromLSB:x2];
//         [cp2 labelUpFromLSB:y2];
//         [cp2 labelUpFromLSB:z2];
//         [cp2 labelUpFromLSB:ci2];
//         [cp2 labelUpFromLSB:co2];
//         NSLog(@"Solution Found:");
//         NSLog(@"cin  = %@\n", ci2);
//         NSLog(@"x    = %@\n", x2);
//         NSLog(@"y    = %@\n", y2);
//         NSLog(@"z    = %@\n", z2);
//         NSLog(@"cout = %@\n", co2);
//         STAssertTrue([[ci2 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
//         STAssertTrue([[x2 stringValue] isEqualToString:@"1010101010101010101010101010101010101010101010101010101010101010"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
//         STAssertTrue([[y2 stringValue] isEqualToString:@"0101010101010101010101010101010101010101010101010101010101010101"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
//         STAssertTrue([[z2 stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
//         STAssertTrue([[co2 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
//      }
//      @catch (NSException *exception) {
//         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
//      }
//   }];
//}
//
//-(void) testSumConstraint3
//{
//   NSLog(@"Begin testing bitwise Sum constraint\n");
//   
//   id<ORModel> m3 = [ORFactory createModel];
//   unsigned int min[2];
//   unsigned int max[2];
//   
//   min[0] = 0;//
//   min[1] = 0;
//   max[0] = 0xFFFFFFFF;//
//   max[1] = 0xFFFFFFFF;
//   id<ORBitVar> x3 =  [ORFactory bitVar:m3 low:min up:max bitLength:64];
//   min[0] = 0xFEDCBA98;//
//   min[1] = 0x76543210;
//   max[0] = 0xFEDCBA98;//
//   max[1] = 0x76543210;
//   id<ORBitVar> y3 = [ORFactory bitVar:m3 low:min up:max bitLength:64];
//   
//   min[0] = 0xFFFFFFFF;//
//   min[1] = 0xFFFFFFFF;
//   max[0] = 0xFFFFFFFF;//
//   max[1] = 0xFFFFFFFF;
//   id<ORBitVar> z3 = [ORFactory bitVar:m3 low:min up:max bitLength:64];
//   min[0] = 0;//
//   min[1] = 0;
//   max[0] = 0xFFFFFFFF;//
//   max[1] = 0xFFFFFFFF;
//   id<ORBitVar> ci3 = [ORFactory bitVar:m3 low:min up:max bitLength:64];
//   min[0] = 0;//
//   min[1] = 0;
//   max[0] = 0;//
//   max[1] = 0;
//   id<ORBitVar> co3 = [ORFactory bitVar:m3 low:min up:max bitLength:64];
//   
//   
//   NSLog(@"Initial values:");
//   NSLog(@"x    = %@\n", x3);
//   NSLog(@"y    = %@\n", y3);
//   NSLog(@"cin  = %@\n", ci3);
//   NSLog(@"z    = %@\n", z3);
//   NSLog(@"cout = %@\n", co3);
////   [m add:[CPFactory bitADD:x3 plus:y3 withCarryIn:ci3 equals:z3 withCarryOut:co3]];
////   NSLog(@"Added Sum constraint.\n");
////   NSLog(@"Initial values:");
////   NSLog(@"x    = %@\n", x3);
////   NSLog(@"y    = %@\n", y3);
////   NSLog(@"cin  = %@\n", ci3);
////   NSLog(@"z    = %@\n", z3);
////   NSLog(@"cout = %@\n", co3);
//   [m3 add:[ORFactory bit:x3 plus:y3 withCarryIn:ci3 eq:z3 withCarryOut:co3]];
//   
//   id<CPProgram,CPBV> cp3 = [ORFactory createCPProgram:m3];
//
//   [cp3 solve: ^() {
//      @try {
//         NSLog(@"After Posting:");
//         NSLog(@"cin  = %@\n", ci3);
//         NSLog(@"x    = %@\n", x3);
//         NSLog(@"y    = %@\n", y3);
//         NSLog(@"z    = %@\n", z3);
//         NSLog(@"cout = %@\n", co3);
//         [cp3 labelUpFromLSB:x3];
//         [cp3 labelUpFromLSB:y3];
//         [cp3 labelUpFromLSB:z3];
//         [cp3 labelUpFromLSB:ci3];
//         [cp3 labelUpFromLSB:co3];
//         NSLog(@"Solution Found:");
//         NSLog(@"cin  = %@\n", ci3);
//         NSLog(@"x    = %@\n", x3);
//         NSLog(@"y    = %@\n", y3);
//         NSLog(@"z    = %@\n", z3);
//         NSLog(@"cout = %@\n", co3);
//         STAssertTrue([[ci3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
//         STAssertTrue([[x3 stringValue] isEqualToString:@"0000000100100011010001010110011110001001101010111100110111101111"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
//         STAssertTrue([[y3 stringValue] isEqualToString:@"1111111011011100101110101001100001110110010101000011001000010000"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
//         STAssertTrue([[z3 stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
//         STAssertTrue([[co3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
//      }
//      @catch (NSException *exception) {
//         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
//      }
//   }];
//   
//    NSLog(@"End testing bitwise Sum constraint.\n");
//}
//-(void) testSumConstraint4
//{
//   NSLog(@"Begin testing bitwise Sum constraint\n");
//   
//   id<ORModel> m3 = [ORFactory createModel];
//   unsigned int min[2];
//   unsigned int max[2];
//   
//   min[0] = 0;//
//   min[1] = 0;
//   max[0] = 0xFFFFFFFF;//
//   max[1] = 0xFFFFFFFF;
//   id<ORBitVar> x3 =  [ORFactory bitVar:m3 low:min up:max bitLength:64];
//   id<ORBitVar> y3 = [ORFactory bitVar:m3 low:min up:max bitLength:64];
//   
//   min[0] = 0xFFFFFFFF;//
//   min[1] = 0xFFFFFFFE;
//   max[0] = 0xFFFFFFFF;//
//   max[1] = 0xFFFFFFFE;
//   id<ORBitVar> z3 = [ORFactory bitVar:m3 low:min up:max bitLength:64];
//   min[1] = 0xFFFFFFFF;
//   max[1] = 0xFFFFFFFF;
//   id<ORBitVar> co3 = [ORFactory bitVar:m3 low:min up:max bitLength:64];
//   min[0] = 0;//
//   min[1] = 0;
//   max[0] = 0xFFFFFFFF;//
//   max[1] = 0xFFFFFFFF;
//   id<ORBitVar> ci3 = [ORFactory bitVar:m3 low:min up:max bitLength:64];
//   
//   
//   NSLog(@"Initial values:");
//   NSLog(@"x    = %@\n", x3);
//   NSLog(@"y    = %@\n", y3);
//   NSLog(@"cin  = %@\n", ci3);
//   NSLog(@"z    = %@\n", z3);
//   NSLog(@"cout = %@\n", co3);
//   //   [m add:[CPFactory bitADD:x3 plus:y3 withCarryIn:ci3 equals:z3 withCarryOut:co3]];
//   //   NSLog(@"Added Sum constraint.\n");
//   //   NSLog(@"Initial values:");
//   //   NSLog(@"x    = %@\n", x3);
//   //   NSLog(@"y    = %@\n", y3);
//   //   NSLog(@"cin  = %@\n", ci3);
//   //   NSLog(@"z    = %@\n", z3);
//   //   NSLog(@"cout = %@\n", co3);
//   [m3 add:[ORFactory bit:x3 plus:y3 withCarryIn:ci3 eq:z3 withCarryOut:co3]];
//   
//   id<CPProgram,CPBV> cp3 = [ORFactory createCPProgram:m3];
//   
//   [cp3 solve: ^() {
//      @try {
//         NSLog(@"After Posting:");
//         NSLog(@"cin  = %@\n", ci3);
//         NSLog(@"x    = %@\n", x3);
//         NSLog(@"y    = %@\n", y3);
//         NSLog(@"z    = %@\n", z3);
//         NSLog(@"cout = %@\n", co3);
//         [cp3 labelUpFromLSB:x3];
//         [cp3 labelUpFromLSB:y3];
//         [cp3 labelUpFromLSB:z3];
//         [cp3 labelUpFromLSB:ci3];
//         [cp3 labelUpFromLSB:co3];
//         NSLog(@"Solution Found:");
//         NSLog(@"cin  = %@\n", ci3);
//         NSLog(@"x    = %@\n", x3);
//         NSLog(@"y    = %@\n", y3);
//         NSLog(@"z    = %@\n", z3);
//         NSLog(@"cout = %@\n", co3);
////         STAssertTrue([[ci3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
////         STAssertTrue([[x3 stringValue] isEqualToString:@"0000000100100011010001010110011110001001101010111100110111101111"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
////         STAssertTrue([[y3 stringValue] isEqualToString:@"1111111011011100101110101001100001110110010101000011001000010000"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
////         STAssertTrue([[z3 stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
////         STAssertTrue([[co3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
//      }
//      @catch (NSException *exception) {
//         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
//      }
//   }];
//   
//   NSLog(@"End testing bitwise Sum constraint.\n");
//}


//CinLow  0x00000000 0x00000000 0x00000000 0x2AA      0xAAAAAAAA
//CinUp   0xD5       0x55555555 0x5FFFFFFF 0xFFFFFFFF 0xFFFFFFFF
//Ylow    0x00000000 0x2AA      0xA0000000 0x2AAA800  0xAAA
//YUp     0xD5       0x57FFFFFF 0xF5555FFF 0xFFFFFD55 0x5FFFFFFF
//Zlow    0x00000000 0x28002800 0xA000A000 0xA800A800 0xA002A00A
//Zup     0xD7       0xFD5FFD7F 0xF57FF57F 0xFD7FFD7F 0xF5FFF5FF
//CoLow   0x00000000 0x208082   0x820082   0x8820882  0x2082222
//CoUp    0xDD       0xDDF7DFDF 0x77DF77DF 0x7FDF7FDF 0x7F7DFFFF
//Xlow    0x00000000 0x28208282 0x820000   0x8000A82  0x200A
//Xup     0xD7       0xFDFFFFDF 0x57FFF7FF 0xFFDF7FDF 0x5F7DF5FF

-(void) testSumConstraint5
{
   NSLog(@"Begin testing bitwise Sum constraint\n");
   
   id<ORModel> m3 = [ORFactory createModel];
   unsigned int min[5];
   unsigned int max[5];
   
   //CinLow  0x00000000 0x00000000 0x00000000 0x2AA      0xAAAAAAAA
   //CinUp   0xD5       0x55555555 0x5FFFFFFF 0xFFFFFFFF 0xFFFFFFFF
   
   min[0] = 0x00000000;//
   min[1] = 0x00000000;
   min[2] = 0x00000000;//
   min[3] = 0x2AA;
   min[4] = 0xAAAAAAAA;//

   max[0] = 0xFFFFFFD5;//
   max[1] = 0x55555555;
   max[2] = 0xFFFFFFFF;//
   max[3] = 0xFFFFFFFF;
   max[4] = 0xFFFFFFFF;//
//   min[0] = 0;
//   max[0] = 0xFFFFFFFF;

   id<ORBitVar> cin =  [ORFactory bitVar:m3 low:min up:max bitLength:160];

   //Ylow    0x00000000 0x2AA      0xA0000000 0x2AAA800  0xAAA
   //YUp     0xD5       0x57FFFFFF 0xF5555FFF 0xFFFFFD55 0x5FFFFFFF
   
   min[0] = 0x00000000;//
   min[1] = 0x2AA;
   min[2] = 0xA0000000;//
   min[3] = 0x2AAA800;
   min[4] = 0xAAA;//
   
   max[0] = 0xFFFFFFD5;//
   max[1] = 0x57FFFFFF;
   max[2] = 0xF5555FFF;//
   max[3] = 0xFFFFFD55;
   max[4] = 0x5FFFFFFF;//
   id<ORBitVar> y = [ORFactory bitVar:m3 low:min up:max bitLength:160];
   
   //Zlow    0x00000000 0x28002800 0xA000A000 0xA800A800 0xA002A00A
   //Zup     0xD7       0xFD5FFD7F 0xF57FF57F 0xFD7FFD7F 0xF5FFF5FF
   
   min[0] = 0x00000000;//
   min[1] = 0x28002800;
   min[2] = 0xA000A000;//
   min[3] = 0xA800A800;
   min[4] = 0xA002A00A;//
   
   max[0] = 0xFFFFFFD7;//
   max[1] = 0xFD5FFD7F;
   max[2] = 0xF57FF57F;//
   max[3] = 0xFD7FFD7F;
   max[4] = 0xF5FFF5FF;//
   id<ORBitVar> z = [ORFactory bitVar:m3 low:min up:max bitLength:160];
   
   //CoLow   0x00000000 0x208082   0x820082   0x8820882  0x2082222
   //CoUp    0xDD       0xDDF7DFDF 0x77DF77DF 0x7FDF7FDF 0x7F7DFFFF
   
   min[0] = 0x00000000;//
   min[1] = 0x00208082;
   min[2] = 0x00820082;//
   min[3] = 0x08820882;
   min[4] = 0x02082222;//
   
   max[0] = 0xFFFFFFDD;//
   max[1] = 0xDDF7DFDF;
   max[2] = 0x77DF77DF;//
   max[3] = 0x7FDF7FDF;
   max[4] = 0x7F7DFFFF;//

   id<ORBitVar> co = [ORFactory bitVar:m3 low:min up:max bitLength:160];

   //Xlow    0x00000000 0x28208282 0x820000   0x8000A82  0x200A
   //Xup     0xD7       0xFDFFFFDF 0x57FFF7FF 0xFFDF7FDF 0x5F7DF5FF

   min[0] = 0x00000000;//
   min[1] = 0x28208282;
   min[2] = 0x820000;//
   min[3] = 0x8000A82;
   min[4] = 0x200A;//
   
   max[0] = 0xFFFFFFD7;//
   max[1] = 0xFDFFFFDF;
   max[2] = 0x57FFF7FF;//
   max[3] = 0xFFDF7FDF;
   max[4] = 0x5F7DF5FF;//
//   min[0] = 0;
//   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m3 low:min up:max bitLength:160];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x    = %@\n", x);
   NSLog(@"y    = %@\n", y);
   NSLog(@"cin  = %@\n", cin);
   NSLog(@"z    = %@\n", z);
   NSLog(@"cout = %@\n", co);
   //   [m add:[CPFactory bitADD:x3 plus:y3 withCarryIn:ci3 equals:z3 withCarryOut:co3]];
   //   NSLog(@"Added Sum constraint.\n");
   //   NSLog(@"Initial values:");
   //   NSLog(@"x    = %@\n", x3);
   //   NSLog(@"y    = %@\n", y3);
   //   NSLog(@"cin  = %@\n", ci3);
   //   NSLog(@"z    = %@\n", z3);
   //   NSLog(@"cout = %@\n", co3);
   [m3 add:[ORFactory bit:x plus:y withCarryIn:cin eq:z withCarryOut:co]];
   
   id<CPProgram,CPBV> cp3 = (id)[ORFactory createCPProgram:m3];
   
   [cp3 solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"cin  = %@\n", cin);
         NSLog(@"x    = %@\n", x);
         NSLog(@"y    = %@\n", y);
         NSLog(@"z    = %@\n", z);
         NSLog(@"cout = %@\n", co);
//         [cp3 labelUpFromLSB:x];
//         [cp3 labelUpFromLSB:y];
//         [cp3 labelUpFromLSB:z];
//         [cp3 labelUpFromLSB:cin];
//         [cp3 labelUpFromLSB:co];
         [cp3 solve: ^{
            id<CPHeuristic> h = [cp3 createBitVarABS];
            [cp3 labelBitVarHeuristic:h];
         }];
         [cp3 release];
         NSLog(@"Solution Found:");
         NSLog(@"cin  = %@\n", cin);
         NSLog(@"x    = %@\n", x);
         NSLog(@"y    = %@\n", y);
         NSLog(@"z    = %@\n", z);
         NSLog(@"cout = %@\n", co);
         //         STAssertTrue([[ci3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
         //         STAssertTrue([[x3 stringValue] isEqualToString:@"0000000100100011010001010110011110001001101010111100110111101111"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
         //         STAssertTrue([[y3 stringValue] isEqualToString:@"1111111011011100101110101001100001110110010101000011001000010000"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
         //         STAssertTrue([[z3 stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
         //         STAssertTrue([[co3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   
   NSLog(@"End testing bitwise Sum constraint.\n");
}

-(void) testIFConstraint
{
   NSLog(@"Begin testing bitwise IF constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[2];
   unsigned int max[2];
   
   min[0] = 0;//
   min[1] = 0;
   max[0] = 0xFFFFFFFF;//
   max[1] = 0xFFFFFFFF;
   id<ORBitVar> w = [ORFactory bitVar:m low:min up:max bitLength:64];
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:64];
   id<ORBitVar> y = [ORFactory bitVar:m low:min up:max bitLength:64];
   id<ORBitVar> z = [ORFactory bitVar:m low:min up:max bitLength:64];
   
   
   NSLog(@"Initial values:");
   NSLog(@"w = %@\n", w);
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   NSLog(@"z = %@\n", z);
   //   [m add:[CPFactory bitADD:x3 plus:y3 withCarryIn:ci3 equals:z3 withCarryOut:co3]];
   //   NSLog(@"Added Sum constraint.\n");
   //   NSLog(@"Initial values:");
   //   NSLog(@"x    = %@\n", x3);
   //   NSLog(@"y    = %@\n", y3);
   //   NSLog(@"cin  = %@\n", ci3);
   //   NSLog(@"z    = %@\n", z3);
   //   NSLog(@"cout = %@\n", co3);
   [m add:[ORFactory bit:w trueIf:x equals:y zeroIfXEquals:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   
   [cp solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"w = %@\n", w);
         NSLog(@"x = %@\n", x);
         NSLog(@"y = %@\n", y);
         NSLog(@"z = %@\n", z);
         [cp labelUpFromLSB:w];
         [cp labelUpFromLSB:x];
         [cp labelUpFromLSB:y];
         [cp labelUpFromLSB:z];
         NSLog(@"Solution Found:");
         NSLog(@"w = %@\n", w);
         NSLog(@"x = %@\n", x);
         NSLog(@"y = %@\n", y);
         NSLog(@"z = %@\n", z);
//         STAssertTrue([[w stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitIFConstraint: Bit Pattern for w is incorrect.");
//         STAssertTrue([[x stringValue] isEqualToString:@"0000000100100011010001010110011110001001101010111100110111101111"],@"testBitIFConstraint: Bit Pattern for x is incorrect.");
//         STAssertTrue([[y stringValue] isEqualToString:@"1111111011011100101110101001100001110110010101000011001000010000"],@"testBitIFConstraint: Bit Pattern for y is incorrect.");
//         STAssertTrue([[z stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitIFConstraint: Bit Pattern for z is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   
   NSLog(@"End testing bitwise IF constraint.\n");
}

@end
