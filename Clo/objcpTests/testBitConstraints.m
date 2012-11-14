//
//  testBitConstraints.m
//  Clo
//
//  Created by Greg Johnson on 6/10/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//
#import  "Foundation/NSDebug.h"
#import "testBitConstraints.h"
//#import "objcp/CP.h"
#import "objcp/CPConstraint.h"
#import "objcp/CPFactory.h"
//#import "objcp/CPController.h"
//#import "objcp/CPTracer.h"
#import "objcp/CPObjectQueue.h"
#import "objcp/CPLabel.h"
//#import "objcp/CPAVLTree.h"
#import "objcp/CPBitMacros.h"
#import "objcp/CPBitArray.h"
#import "objcp/CPBitArrayDom.h"
#import "objcp/CPBitConstraint.h"

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

-(void)testEqualityConstriant{
    NSLog(@"Begin testing bitwise equality constraint\n");
   
    id<CPSolver> m = [CPFactory createSolver];
    unsigned int min[2];
    unsigned int max[2];
   min[0] = min[1] = 0;
   max[0] = max[1] = CP_UMASK;
   
    id<CPBitVar> x = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    id<CPBitVar> y = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    min[1] = 8;
    max[1] = 12;
    id<CPBitVar> z = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    
   min[0] = 0xAAAAAAAA;
   min[1] = 0x55555555;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   id<CPBitVar> a = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
   min[0] = min[1] = 0;
   max[0] = max[1] = CP_UMASK;
   id<CPBitVar> b = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
   min[0] = min[1] = 0;
   max[0] = max[1] = CP_UMASK;
   id<CPBitVar> c = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
   
   
    
   NSLog(@"Initial values: a=b=c and x=y=z");
    NSLog(@"x = %@\n", x);
    NSLog(@"y = %@\n", y);
    NSLog(@"z = %@\n", z);
   [m add:[CPFactory bitEqual:x to:y]];
   [m add:[CPFactory bitEqual:y to:z]];

   NSLog(@"a = %@\n", a);
   NSLog(@"b = %@\n", b);
   NSLog(@"c = %@\n", c);
   [m add:[CPFactory bitEqual:a to:b]];
   [m add:[CPFactory bitEqual:b to:c]];

    [m solve: ^() {
       @try {
          NSLog(@"After Posting:");
          NSLog(@"a = %@\n", a);
          NSLog(@"b = %@\n", b);
          NSLog(@"c = %@\n", c);
          NSLog(@"x = %@\n", x);
          NSLog(@"y = %@\n", y);
          NSLog(@"z = %@\n", z);
          [CPLabel upFromLSB:x];
          [CPLabel upFromLSB:y];
          [CPLabel upFromLSB:z];
          [CPLabel upFromLSB:a];
          [CPLabel upFromLSB:b];
          [CPLabel upFromLSB:c];
          NSLog(@"Solution Found:");
          NSLog(@"a = %@\n", a);
          NSLog(@"b = %@\n", b);
          NSLog(@"c = %@\n", c);
          NSLog(@"x = %@\n", x);
          NSLog(@"y = %@\n", y);
          NSLog(@"z = %@\n", z);
          STAssertTrue([[x description] isEqualToString:[y description]], @"testBitEqualityConstraint: Bit Patterns for x and y should be equal.");
          STAssertTrue([[x description] isEqualToString:[z description]], @"testBitEqualityConstraint: Bit Patterns for x and z should be equal.");
          STAssertTrue([[a description] isEqualToString:[b description]], @"testBitEqualityConstraint: Bit Patterns for a and b should be equal.");
          STAssertTrue([[a description] isEqualToString:[c description]], @"testBitEqualityConstraint: Bit Patterns for a and c should be equal.");
       }
       @catch (NSException *exception) {
          
          NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
          
       }

    }];
    
    NSLog(@"End testing bitwise equality constraint.\n");
    
}

- (void)testANDConstraint{
    NSLog(@"Begin testing bitwise AND constraint\n");
    
    id<CPSolver> m = [CPFactory createSolver];
    unsigned int min[2];
    unsigned int max[2];
    
    max[0] = 0xEEEEEEEE;
    max[1] = 0xEEEEEEEE;
    min[0] = 0x88888888;
    min[1] = 0x88888888;
    
    id<CPBitVar> a = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    max[0] = 0xFFF0FFF0;
    max[1] = 0xFFF0FFF0;
    min[0] = 0xF000F000;
    min[1] = 0xF000F000;
    id<CPBitVar> b = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    max[0] = 0xFFFFFFFF;
    max[1] = 0xFFFF8000;
    min[0] = 0xEEE00000;
    min[1] = 0x00000000;
    id<CPBitVar> c = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    
    
   NSLog(@"Initial values:");
    NSLog(@"a = %@\n", a);
    NSLog(@"b = %@\n", b);
    NSLog(@"c = %@\n", c);
    
    [m add:[CPFactory bitAND:a and:b equals:c]];
   [m solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"a = %@\n", a);
         NSLog(@"b = %@\n", b);
         NSLog(@"c = %@\n", c);
         [CPLabel upFromLSB:a];
         [CPLabel upFromLSB:b];
         [CPLabel upFromLSB:c];
         NSLog(@"Solution Found:");
         NSLog(@"a = %@\n", a);
         NSLog(@"b = %@\n", b);
         NSLog(@"c = %@\n", c);
         
         STAssertTrue([[a description] isEqualToString:@"1110111011101000100010001000100010001000100010001000100010001000"],@"testBitANDConstraint: Bit Pattern for a is incorrect.");
         STAssertTrue([[b description] isEqualToString:@"1111111011100000111100000000000011110000000000001111000000000000"],@"testBitANDConstraint: Bit Pattern for b is incorrect.");
         STAssertTrue([[c description] isEqualToString:@"1110111011100000100000000000000010000000000000001000000000000000"],@"testBitANDConstraint: Bit Pattern for c is incorrect.");
      }
      @catch (NSException *exception) {
         
         NSLog(@"testANDConstraint: Caught %@: %@", [exception name], [exception reason]);
         
      }
   }];
    NSLog(@"End testing bitwise AND constraint.\n");
    
}

-(void) testORConstraint{
    NSLog(@"Begin testing bitwise OR constraint\n");
    
    id<CPSolver> m = [CPFactory createSolver];
    unsigned int min[2];
    unsigned int max[2];
    
    max[0] = 0xEEEEEEEE;
    max[1] = 0xEEEEEEEE;
    min[0] = 0x88888888;
    min[1] = 0x88888888;
    id<CPBitVar> d = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    max[0] = 0xFFF0FFF0;
    max[1] = 0xFFF0FFF0;
    min[0] = 0xF000F000;
    min[1] = 0xF000F000;
    id<CPBitVar> e = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    max[0] = 0xFFFFFFFF;
    max[1] = 0xFFFFF888;
    min[0] = 0xFFFE0000;
    min[1] = 0x00000000;
    id<CPBitVar> f = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
   NSLog(@"Initial values:");
    NSLog(@"d = %@\n", d);
    NSLog(@"e = %@\n", e);
    NSLog(@"f = %@\n", f);
    
    [m add:[CPFactory bitOR:d or:e equals:f]];
   [m solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"d = %@\n", d);
         NSLog(@"e = %@\n", e);
         NSLog(@"f = %@\n", f);
         [CPLabel upFromLSB:d];
         [CPLabel upFromLSB:e];
         [CPLabel upFromLSB:f];
         NSLog(@"Found Solution:");
         NSLog(@"d = %@\n", d);
         NSLog(@"e = %@\n", e);
         NSLog(@"f = %@\n", f);
         STAssertTrue([[d description] isEqualToString:@"1000100010001110100010001000100010001000100010001000100010001000"],@"testBitORConstraint: Bit Pattern for d is incorrect.");
         STAssertTrue([[e description] isEqualToString:@"1111011101110000111100000000000011110000000000001111000000000000"],@"testBitORConstraint: Bit Pattern for e is incorrect.");
         STAssertTrue([[f description] isEqualToString:@"1111111111111110111110001000100011111000100010001111100010001000"],@"testBitORConstraint: Bit Pattern for f is incorrect.");

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

-(void) testNOTConstraint{
    NSLog(@"Begin testing bitwise NOT constraint\n");
    
    id<CPSolver> m = [CPFactory createSolver];
    unsigned int min[2];
    unsigned int max[2];
    
    min[1] = 0x000000AA;
    max[1] = 0xFFFFFFFF;
    id<CPBitVar> g = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    min[1] = 0x00000055;
    max[0] = 0xFFFFFFFF;
    max[1] = 0xFFFFFFFF;
    id<CPBitVar> h = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    
   NSLog(@"Initial values:");
    NSLog(@"g = %@\n", g);
    NSLog(@"h = %@\n", h);
    
    [m add:[CPFactory bitNOT:g equals:h]];
   [m solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"g = %@\n", g);
         NSLog(@"h = %@\n", h);
         [CPLabel upFromLSB:h];
         NSLog(@"Solution Found:");
         NSLog(@"g = %@\n", g);
         NSLog(@"h = %@\n", h);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
    NSLog(@"End testing bitwise NOT constraint.\n");
    
}

-(void) testXORConstraint{
    NSLog(@"Begin testing bitwise XOR constraint\n");
    
    id<CPSolver> m = [CPFactory createSolver];
    unsigned int min[2];
    unsigned int max[2];
    
    max[0] = 0xEEEEEEEE;
    max[1] = 0xEEEEEEEE;
    min[0] = 0x88888888;
    min[1] = 0x88888888;
    id<CPBitVar> i = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    max[0] = 0xFFF0FFF0;
    max[1] = 0xFFF0FFF0;
    min[0] = 0xF000F000;
    min[1] = 0xF000F000;
    id<CPBitVar> j = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    max[0] = 0xFFFFFFFF;
    max[1] = 0xFFFF1008;
    min[0] = 0x7FFE0000;
    min[1] = 0x00000000;
    id<CPBitVar> k = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    
   NSLog(@"Initial values:");
    NSLog(@"i = %@\n", i);
    NSLog(@"j = %@\n", j);
    NSLog(@"k = %@\n", k);
    
    
    [m add:[CPFactory bitXOR:i xor:j equals:k]];
   
   [m solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"i = %@\n", i);
         NSLog(@"j = %@\n", j);
         NSLog(@"k = %@\n", k);
         [CPLabel upFromLSB:i];
         [CPLabel upFromLSB:j];
         [CPLabel upFromLSB:k];
         NSLog(@"Solution Found:");
         NSLog(@"i = %@\n", i);
         NSLog(@"j = %@\n", j);
         NSLog(@"k = %@\n", k);
         STAssertTrue([[i description] isEqualToString:@"1000100010001110100010001000100010001000100010001110100010001000"],@"testBitORConstraint: Bit Pattern for i is incorrect.");
         STAssertTrue([[j description] isEqualToString:@"1111011101110000111100000000000011110000000000001111100010000000"],@"testBitORConstraint: Bit Pattern for j is incorrect.");
         STAssertTrue([[k description] isEqualToString:@"0111111111111110011110001000100001111000100010000001000000001000"],@"testBitORConstraint: Bit Pattern for k is incorrect.");

      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
    NSLog(@"End testing bitwise XOR constraint.\n");
    
}

-(void) testShiftLConstraint{
    NSLog(@"Begin testing bitwise ShiftL constraint\n");
    
   char buffer[BUF_SIZE];
   char buffer2[BUF_SIZE];
   buffer[BUF_SIZE - 1] = '\0';
   buffer2[BUF_SIZE - 1] = '\0';
   

    id<CPSolver> m = [CPFactory createSolver];
    unsigned int min[2];
    unsigned int max[2];
    
   min[0] = 0xB77BEFDF;
   min[1] = 0xDFEFFBFF;
   max[0] = 0xB77BEFDF;
   max[1] = 0xDFEFFBFF;
   
   id<CPBitVar> p = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
   min[1] = 0;
   min[0] = 0;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   id<CPBitVar> q = [CPFactory bitVar:m withLow:min andUp:max andLength:64];

    [m add:[CPFactory bitShiftL:p by:3 equals:q]];

   NSLog(@"Initial values:");
   NSLog(@"p = %@\n", p);
   NSLog(@"q = %@\n", q);
   [m solve: ^() {
      @try {

         NSLog(@"After Posting:");
         NSLog(@"p = %@\n", p);
         NSLog(@"q = %@\n", q);
         [CPLabel upFromLSB:p];
         [CPLabel upFromLSB:q];
         NSLog(@"Solution Found:");
         NSLog(@"p = %@\n", p);
         NSLog(@"q = %@\n", q);
         STAssertTrue([[p description] isEqualToString:@"1011011101111011111011111101111111011111111011111111101111111111"],@"testBitORConstraint: Bit Pattern for p is incorrect.");
         STAssertTrue([[q description] isEqualToString:@"1011101111011111011111101111111011111111011111111101111111111000"],@"testBitORConstraint: Bit Pattern for q is incorrect.");
      }
         @catch (NSException *exception) {
         
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
         
      }
      
   }];
    NSLog(@"End testing bitwise ShiftL constraint.\n");
}


-(void) testROTLConstraint{
   NSLog(@"Begin testing ROTL bitwise constraint\n");
   
   id<CPSolver> m = [CPFactory createSolver];
   unsigned int min[2];
   unsigned int max[2];
   
   min[0] = 0xB77BEFDF;
   min[1] = 0xDFEFFBFF;
   max[0] = 0xB77BEFDF;
   max[1] = 0xDFEFFBFF;
   id<CPBitVar> p = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
   min[0] = 0;
   min[1] = 0;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   id<CPBitVar> q = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
   
   [m add:[CPFactory bitRotateL:p by:33 equals:q]];
   
   NSLog(@"Initial values:");
   NSLog(@"p = %@\n", p);
   NSLog(@"q = %@\n", q);
   [m solve: ^() {
      @try {
         
         NSLog(@"After Posting:");
         NSLog(@"p = %@\n", p);
         NSLog(@"q = %@\n", q);
         [CPLabel upFromLSB:p];
         [CPLabel upFromLSB:q];
         NSLog(@"Solution Found:");
         NSLog(@"p = %@\n", p);
         NSLog(@"q = %@\n", q);
         STAssertTrue([[p description] isEqualToString:@"1011011101111011111011111101111111011111111011111111101111111111"],@"testBitORConstraint: Bit Pattern for p is incorrect.");
         STAssertTrue([[q description] isEqualToString:@"1011111111011111111101111111111101101110111101111101111110111111"],@"testBitORConstraint: Bit Pattern for q is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End testing ROTL bitwise constraint.\n");
}

-(void) testSumConstraint{
    NSLog(@"Begin testing bitwise Sum constraint\n");
        
     id<CPSolver> m = [CPFactory createSolver];
     unsigned int min[2];
     unsigned int max[2];

   min[0] = 0xFFFFFFFF;
   min[1] = 0xFFFFFFFF;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;

   id<CPBitVar> x = [CPFactory bitVar:m withLow: min andUp:max andLength:64];

   id<CPBitVar> y = [CPFactory bitVar:m withLow: min andUp:max andLength:64];

   min[0] = 0x00000000;//
   min[1] = 0x00000000;//
   max[0] = 0xFFFFFFFF;//
   max[1] = 0xFFFFFFFF;
   
   id<CPBitVar> ci = [CPFactory bitVar:m withLow: min andUp:max andLength:64];

   min[0] = 0x00000000;//
   min[1] = 0x00000000;
   max[0] = 0xFFFFFFFF;//
   max[1] = 0xFFFFFFFF;

   id<CPBitVar> z = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   id<CPBitVar> co = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   [m add:[CPFactory bitADD:x plus:y withCarryIn:ci equals:z withCarryOut:co]];
   NSLog(@"Added Sum constraint.\n");
   NSLog(@"Initial values:");
   NSLog(@"x    = %@\n", x);
   NSLog(@"y    = %@\n", y);
   NSLog(@"cin  = %@\n", ci);
   NSLog(@"z    = %@\n", z);
   NSLog(@"cout = %@\n", co);

   [m solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"cin  = %@\n", ci);
         NSLog(@"x    = %@\n", x);
         NSLog(@"y    = %@\n", y);
         NSLog(@"z    = %@\n", z);
         NSLog(@"cout = %@\n", co);
         [CPLabel upFromLSB:x];
         [CPLabel upFromLSB:y];
         [CPLabel upFromLSB:z];
         [CPLabel upFromLSB:ci];
         [CPLabel upFromLSB:co];
         NSLog(@"Solution Found:");
         NSLog(@"cin  = %@\n", ci);
         NSLog(@"x    = %@\n", x);
         NSLog(@"y    = %@\n", y);
         NSLog(@"z    = %@\n", z);
         NSLog(@"cout = %@\n", co);
         STAssertTrue([[ci description] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111110"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
         STAssertTrue([[x description] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
         STAssertTrue([[y description] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
         STAssertTrue([[z description] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111110"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
         STAssertTrue([[co description] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   
   min[0] = 0;//
   min[1] = 0;
   max[0] = 0xFFFFFFFF;//
   max[1] = 0xFFFFFFFF;
   id<CPBitVar> x1 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   id<CPBitVar> y1 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   
   id<CPBitVar> z1 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   id<CPBitVar> ci1 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   id<CPBitVar> co1 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   

   NSLog(@"Initial values:");
   NSLog(@"x    = %@\n", x1);
   NSLog(@"y    = %@\n", y1);
   NSLog(@"cin  = %@\n", ci1);
   NSLog(@"z    = %@\n", z1);
   NSLog(@"cout = %@\n", co1);
   [m add:[CPFactory bitADD:x1 plus:y1 withCarryIn:ci1 equals:z1 withCarryOut:co1]];
   NSLog(@"Added Sum constraint.\n");
   NSLog(@"Initial values:");
   NSLog(@"x    = %@\n", x1);
   NSLog(@"y    = %@\n", y1);
   NSLog(@"cin  = %@\n", ci1);
   NSLog(@"z    = %@\n", z1);
   NSLog(@"cout = %@\n", co1);
   
   [m solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"cin  = %@\n", ci1);
         NSLog(@"x    = %@\n", x1);
         NSLog(@"y    = %@\n", y1);
         NSLog(@"z    = %@\n", z1);
         NSLog(@"cout = %@\n", co1);
         [CPLabel upFromLSB:x1];
         [CPLabel upFromLSB:y1];
         [CPLabel upFromLSB:z1];
         [CPLabel upFromLSB:ci1];
         [CPLabel upFromLSB:co1];
         NSLog(@"Solution Found:");
         NSLog(@"cin  = %@\n", ci1);
         NSLog(@"x    = %@\n", x1);
         NSLog(@"y    = %@\n", y1);
         NSLog(@"z    = %@\n", z1);
         NSLog(@"cout = %@\n", co1);
         STAssertTrue([[ci1 description] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
         STAssertTrue([[x1 description] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
         STAssertTrue([[y1 description] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
         STAssertTrue([[z1 description] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
         STAssertTrue([[co1 description] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];

   min[0] = 0xAAAAAAAA;//
   min[1] = 0xAAAAAAAA;
   max[0] = 0xAAAAAAAA;//
   max[1] = 0xAAAAAAAA;
   id<CPBitVar> x2 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   min[0] = 0x55555555;//
   min[1] = 0x55555555;
   max[0] = 0x55555555;//
   max[1] = 0x55555555;
   id<CPBitVar> y2 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   
   min[0] = 0;//
   min[1] = 0;
   max[0] = 0xFFFFFFFF;//
   max[1] = 0xFFFFFFFF;

   id<CPBitVar> z2 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   id<CPBitVar> ci2 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   id<CPBitVar> co2 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x    = %@\n", x2);
   NSLog(@"y    = %@\n", y2);
   NSLog(@"cin  = %@\n", ci2);
   NSLog(@"z    = %@\n", z2);
   NSLog(@"cout = %@\n", co2);
   [m add:[CPFactory bitADD:x2 plus:y2 withCarryIn:ci2 equals:z2 withCarryOut:co2]];
   NSLog(@"Added Sum constraint.\n");
   NSLog(@"Initial values:");
   NSLog(@"x    = %@\n", x2);
   NSLog(@"y    = %@\n", y2);
   NSLog(@"cin  = %@\n", ci2);
   NSLog(@"z    = %@\n", z2);
   NSLog(@"cout = %@\n", co2);
   
   [m solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"cin  = %@\n", ci2);
         NSLog(@"x    = %@\n", x2);
         NSLog(@"y    = %@\n", y2);
         NSLog(@"z    = %@\n", z2);
         NSLog(@"cout = %@\n", co2);
         [CPLabel upFromLSB:x2];
         [CPLabel upFromLSB:y2];
         [CPLabel upFromLSB:z2];
         [CPLabel upFromLSB:ci2];
         [CPLabel upFromLSB:co2];
         NSLog(@"Solution Found:");
         NSLog(@"cin  = %@\n", ci2);
         NSLog(@"x    = %@\n", x2);
         NSLog(@"y    = %@\n", y2);
         NSLog(@"z    = %@\n", z2);
         NSLog(@"cout = %@\n", co2);
         STAssertTrue([[ci2 description] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
         STAssertTrue([[x2 description] isEqualToString:@"1010101010101010101010101010101010101010101010101010101010101010"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
         STAssertTrue([[y2 description] isEqualToString:@"0101010101010101010101010101010101010101010101010101010101010101"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
         STAssertTrue([[z2 description] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
         STAssertTrue([[co2 description] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];

   min[0] = 0;//
   min[1] = 0;
   max[0] = 0xFFFFFFFF;//
   max[1] = 0xFFFFFFFF;
   id<CPBitVar> x3 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   min[0] = 0xFEDCBA98;//
   min[1] = 0x76543210;
   max[0] = 0xFEDCBA98;//
   max[1] = 0x76543210;
   id<CPBitVar> y3 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   
   min[0] = 0xFFFFFFFF;//
   min[1] = 0xFFFFFFFF;
   max[0] = 0xFFFFFFFF;//
   max[1] = 0xFFFFFFFF;
   id<CPBitVar> z3 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   min[0] = 0;//
   min[1] = 0;
   max[0] = 0xFFFFFFFF;//
   max[1] = 0xFFFFFFFF;
   id<CPBitVar> ci3 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   min[0] = 0;//
   min[1] = 0;
   max[0] = 0;//
   max[1] = 0;
   id<CPBitVar> co3 = [CPFactory bitVar:m withLow: min andUp:max andLength:64];
   
   
   NSLog(@"Initial values:");
   NSLog(@"x    = %@\n", x3);
   NSLog(@"y    = %@\n", y3);
   NSLog(@"cin  = %@\n", ci3);
   NSLog(@"z    = %@\n", z3);
   NSLog(@"cout = %@\n", co3);
   [m add:[CPFactory bitADD:x3 plus:y3 withCarryIn:ci3 equals:z3 withCarryOut:co3]];
   NSLog(@"Added Sum constraint.\n");
   NSLog(@"Initial values:");
   NSLog(@"x    = %@\n", x3);
   NSLog(@"y    = %@\n", y3);
   NSLog(@"cin  = %@\n", ci3);
   NSLog(@"z    = %@\n", z3);
   NSLog(@"cout = %@\n", co3);
   
   [m solve: ^() {
      @try {
         NSLog(@"After Posting:");
         NSLog(@"cin  = %@\n", ci3);
         NSLog(@"x    = %@\n", x3);
         NSLog(@"y    = %@\n", y3);
         NSLog(@"z    = %@\n", z3);
         NSLog(@"cout = %@\n", co3);
         [CPLabel upFromLSB:x3];
         [CPLabel upFromLSB:y3];
         [CPLabel upFromLSB:z3];
         [CPLabel upFromLSB:ci3];
         [CPLabel upFromLSB:co3];
         NSLog(@"Solution Found:");
         NSLog(@"cin  = %@\n", ci3);
         NSLog(@"x    = %@\n", x3);
         NSLog(@"y    = %@\n", y3);
         NSLog(@"z    = %@\n", z3);
         NSLog(@"cout = %@\n", co3);
         STAssertTrue([[ci3 description] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
         STAssertTrue([[x3 description] isEqualToString:@"0000000100100011010001010110011110001001101010111100110111101111"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
         STAssertTrue([[y3 description] isEqualToString:@"1111111011011100101110101001100001110110010101000011001000010000"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
         STAssertTrue([[z3 description] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
         STAssertTrue([[co3 description] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];

   
   
    NSLog(@"End testing bitwise Sum constraint.\n");
}



/*
 -(void) testConstraint{
 NSLog(@"Begin testing bitwise constraint\n");
 
 id<CP> m = [CPFactory createSolver];
 unsigned int min[2];
 unsigned int max[2];
 
 
 
 NSLog(@"End testing bitwise constraint.\n");
 
 }
 */


@end
