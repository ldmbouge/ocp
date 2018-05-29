/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

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
#define ZERO 0x00000000;
#define ONE 0x00000001;
#define MASK 0xFFFFFFFF;

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
          XCTAssertTrue([[[cp stringValue:x] componentsSeparatedByString:@":"][1] isEqualToString:[[cp stringValue:y] componentsSeparatedByString:@":"][1]], @"testBitEqualityConstraint: Bit Patterns for x and y should be equal.");
          XCTAssertTrue([[[cp stringValue:x] componentsSeparatedByString:@":"][1] isEqualToString:[[cp stringValue:z] componentsSeparatedByString:@":"][1]], @"testBitEqualityConstraint: Bit Patterns for x and z should be equal.");
          XCTAssertTrue([[[cp stringValue:a] componentsSeparatedByString:@":"][1] isEqualToString:[[cp stringValue:b] componentsSeparatedByString:@":"][1]], @"testBitEqualityConstraint: Bit Patterns for a and b should be equal.");
          XCTAssertTrue([[[cp stringValue:a] componentsSeparatedByString:@":"][1] isEqualToString:[[cp stringValue:c] componentsSeparatedByString:@":"][1]], @"testBitEqualityConstraint: Bit Patterns for a and c should be equal.");
       }
       @catch (NSException *exception) {
          NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
       }
    }];
    //[haystack componentsSeparatedByString:@":"][1]
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
    
   [m add:[ORFactory bit:a band:b eq:c]];
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
         
         XCTAssertTrue([[[cp stringValue:a] componentsSeparatedByString:@":"][1] isEqualToString:@" 1110111011101000100010001000100010001000100010001000100010001000"],
                      @"testBitANDConstraint: Bit Pattern for a is incorrect.");
         XCTAssertTrue([[[cp stringValue:b] componentsSeparatedByString:@":"][1] isEqualToString:@" 1111111011100000111100000000000011110000000000001111000000000000"],
                      @"testBitANDConstraint: Bit Pattern for b is incorrect.");
         XCTAssertTrue([[[cp stringValue:c] componentsSeparatedByString:@":"][1] isEqualToString:@" 1110111011100000100000000000000010000000000000001000000000000000"],
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
    
   [m add:[ORFactory bit:d bor:e eq:f]];
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
         XCTAssertTrue([[cp stringValue:d] isEqualToString:@"1000100010001110100010001000100010001000100010001000100010001000"],
                      @"testBitORConstraint: Bit Pattern for d is incorrect.");
         XCTAssertTrue([[cp stringValue:e] isEqualToString:@"1111011101110000111100000000000011110000000000001111000000000000"],
                      @"testBitORConstraint: Bit Pattern for e is incorrect.");
         XCTAssertTrue([[cp stringValue:f] isEqualToString:@"1111111111111110111110001000100011111000100010001111100010001000"],
                      @"testBitORConstraint: Bit Pattern for f is incorrect.");

      }
      @catch (NSException *exception) {
         
         NSLog(@"testORConstraint: Caught %@: %@", [exception name], [exception reason]);
         
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
    
    
   [m add:[ORFactory bit:i bxor:j eq:k]];
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
         XCTAssertTrue([[[cp stringValue:i] componentsSeparatedByString:@":"][1] isEqualToString:@" 1000100010001110100010001000100010001000100010001110100010001000"],
                      @"testBitORConstraint: Bit Pattern for i is incorrect.");
         XCTAssertTrue([[[cp stringValue:j] componentsSeparatedByString:@":"][1] isEqualToString:@" 1111011101110000111100000000000011110000000000001111100010000000"],
                      @"testBitORConstraint: Bit Pattern for j is incorrect.");
         XCTAssertTrue([[[cp stringValue:k] componentsSeparatedByString:@":"][1] isEqualToString:@" 0111111111111110011110001000100001111000100010000001000000001000"],
                      @"testBitORConstraint: Bit Pattern for k is incorrect.");

      }
      @catch (NSException *exception) {
         NSLog(@"testXORConstraint: Caught %@: %@", [exception name], [exception reason]);
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
         XCTAssertTrue([[[cp stringValue:p] componentsSeparatedByString:@":"][1] isEqualToString:@" 1011011101111011111011111101111111011111111011111111101111111111"],
                      @"testBitORConstraint: Bit Pattern for p is incorrect.");
         XCTAssertTrue([[[cp stringValue:q] componentsSeparatedByString:@":"][1] isEqualToString:@" 1011101111011111011111101111111011111111011111111101111111111000"],
                      @"testBitORConstraint: Bit Pattern for q is incorrect.");
      }
         @catch (NSException *exception) {
         
         NSLog(@"testShiftLConstraint: Caught %@: %@", [exception name], [exception reason]);
         
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
         XCTAssertTrue([[[p stringValue] componentsSeparatedByString:@":"][1] isEqualToString:@" 1011011101111011111011111101111111011111111011111111101111111111"],@"testBitORConstraint: Bit Pattern for p is incorrect.");
         XCTAssertTrue([[[q stringValue] componentsSeparatedByString:@":"][1] isEqualToString:@" 1011101111011111011111101111111011111111011111111101111111111000"],@"testBitORConstraint: Bit Pattern for q is incorrect.");
      }
      @catch (NSException *exception) {
         
         NSLog(@"testShiftLConstraint: Caught %@: %@", [exception name], [exception reason]);
         
      }
      
   }];
   NSLog(@"End testing bitwise ShiftL constraint.\n");
}

-(void) testShiftRConstraint
{
   NSLog(@"Begin testing bitwise ShiftR constraint\n");
   
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
   
   [m add:[ORFactory bit:p shiftRBy:3 eq:q]];
   
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
         XCTAssertTrue([[[cp stringValue:p] componentsSeparatedByString:@":"][1] isEqualToString:@" 1011011101111011111011111101111111011111111011111111101111111111"],
                      @"testBitORConstraint: Bit Pattern for p is incorrect.");
         XCTAssertTrue([[[cp stringValue:q] componentsSeparatedByString:@":"][1] isEqualToString:@" 0001011011101111011111011111101111111011111111011111111101111111"],
                      @"testBitORConstraint: Bit Pattern for q is incorrect.");
      }
      @catch (NSException *exception) {
         
         NSLog(@"testShiftRConstraint: Caught %@: %@", [exception name], [exception reason]);
         
      }
      
   }];
   NSLog(@"End testing bitwise ShiftR constraint.\n");
}

-(void) testShiftRConstraint2
{
   NSLog(@"Begin testing bitwise ShiftR constraint\n");
   
   char buffer[BUF_SIZE];
   char buffer2[BUF_SIZE];
   buffer[BUF_SIZE - 1] = '\0';
   buffer2[BUF_SIZE - 1] = '\0';
   id* gamma;
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min;
   unsigned int max;
   
   min = 0x00000000;
   max = 0xFFFFFFFF;
   
   id<ORBitVar> p = [ORFactory bitVar:m low:&min up:&max bitLength:32];
   min = 0x82082082;
   max = 0xDF7DF7DF;
   id<ORBitVar> q = [ORFactory bitVar:m low:&min up:&max bitLength:32];
   
   [m add:[ORFactory bit:p shiftRBy:3 eq:q]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   gamma = [cp gamma];
   NSLog(@"Initial values:");
   NSLog(@"p = %@\n", [cp stringValue:p]);
   NSLog(@"q = %@\n", [cp stringValue:q]);
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
                  XCTAssertTrue([[[p stringValue] componentsSeparatedByString:@":"][1] isEqualToString:@" 0001011011101111011111011111101111111011111111011111111101111111"],@"testBitORConstraint: Bit Pattern for p is incorrect.");
                  XCTAssertTrue([[[q stringValue] componentsSeparatedByString:@":"][1] isEqualToString:@" 1011011101111011111011111101111111011111111011111111101111111111"],@"testBitORConstraint: Bit Pattern for q is incorrect.");
      }
      @catch (NSException *exception) {
         
         NSLog(@"testShiftRConstraint: Caught %@: %@", [exception name], [exception reason]);
         
      }
      
   }];
   NSLog(@"End testing bitwise ShiftR constraint.\n");
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
   [m add:[ORFactory bit:q rotateLBy:7 eq:r]];
   
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
//         XCTAssertTrue([[p stringValue] isEqualToString:@"1011011101111011111011111101111111011111111011111111101111111111"],@"testBitORConstraint: Bit Pattern for p is incorrect.");
//         XCTAssertTrue([[q stringValue] isEqualToString:@"1011111111011111111101111111111101101110111101111101111110111111"],@"testBitORConstraint: Bit Pattern for q is incorrect.");
         XCTAssertTrue([[[cp stringValue:p]  componentsSeparatedByString:@":"][1] isEqualToString:@" 10110111011110111110111111011111"],
                      @"testBitORConstraint: Bit Pattern for p is incorrect.");
         XCTAssertTrue([[[cp stringValue:q] componentsSeparatedByString:@":"][1] isEqualToString:@" 10111101111101111110111111011011"],
                      @"testBitORConstraint: Bit Pattern for q is incorrect.");
         XCTAssertTrue([[[cp stringValue:r] componentsSeparatedByString:@":"][1] isEqualToString:@" 10110111011110111110111111011111"],
                      @"testBitORConstraint: Bit Pattern for p is incorrect.");

      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End testing ROTL bitwise constraint.\n");
}

-(void) testROTLConstraint2
{
   NSLog(@"Begin test 2 of ROTL bitwise constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[2];
   unsigned int max[2];
   
   min[0] = 0x00000081;
   min[1] = 0x00000000;
   max[0] = 0x00000081;
   max[1] = 0x00000000;
   id<ORBitVar> p = [ORFactory bitVar:m low:min up:max bitLength:8];
   min[0] = 0;
   min[1] = 0;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   id<ORBitVar> q = [ORFactory bitVar:m low:min up:max bitLength:8];
   id<ORBitVar> r = [ORFactory bitVar:m low:min up:max bitLength:8];
   
   //   [m add:[CPFactory bitRotateL:p by:33 equals:q]];
   [m add:[ORFactory bit:p rotateLBy:2 eq:q]];
   [m add:[ORFactory bit:q rotateLBy:2 eq:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   
   NSLog(@"Initial values:");
   NSLog(@"p = %@\n", gamma[p.getId]);
   NSLog(@"q = %@\n", gamma[q.getId]);
   NSLog(@"r = %@\n", gamma[r.getId]);
   [cp solve: ^() {
      @try {
         
         NSLog(@"After Posting:");
         NSLog(@"p = %@\n", gamma[p.getId]);
         NSLog(@"q = %@\n", gamma[q.getId]);
         NSLog(@"r = %@\n", gamma[r.getId]);
         [cp labelUpFromLSB:p];
         [cp labelUpFromLSB:q];
         NSLog(@"Solution Found:");
         NSLog(@"p = %@\n", gamma[p.getId]);
         NSLog(@"q = %@\n", gamma[q.getId]);
         NSLog(@"r = %@\n", gamma[r.getId]);
         //         XCTAssertTrue([[p stringValue] isEqualToString:@"1011011101111011111011111101111111011111111011111111101111111111"],@"testBitORConstraint: Bit Pattern for p is incorrect.");
         //         XCTAssertTrue([[q stringValue] isEqualToString:@"1011111111011111111101111111111101101110111101111101111110111111"],@"testBitORConstraint: Bit Pattern for q is incorrect.");
//         XCTAssertTrue([[cp stringValue:p] isEqualToString:@"10110111011110111110111111011111"],
//                       @"testBitORConstraint: Bit Pattern for p is incorrect.");
//         XCTAssertTrue([[cp stringValue:q] isEqualToString:@"10111101111101111110111111011011"],
//                       @"testBitORConstraint: Bit Pattern for q is incorrect.");
//         XCTAssertTrue([[cp stringValue:r] isEqualToString:@"10110111011110111110111111011111"],
//                       @"testBitORConstraint: Bit Pattern for p is incorrect.");
         
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
////         XCTAssertTrue([[ci stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111110"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
////         XCTAssertTrue([[x stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
////         XCTAssertTrue([[y stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
////         XCTAssertTrue([[z stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111110"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
////         XCTAssertTrue([[co stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
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
//         XCTAssertTrue([[ci1 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
//         XCTAssertTrue([[x1 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
//         XCTAssertTrue([[y1 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
//         XCTAssertTrue([[z1 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
//         XCTAssertTrue([[co1 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
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
//         XCTAssertTrue([[ci2 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
//         XCTAssertTrue([[x2 stringValue] isEqualToString:@"1010101010101010101010101010101010101010101010101010101010101010"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
//         XCTAssertTrue([[y2 stringValue] isEqualToString:@"0101010101010101010101010101010101010101010101010101010101010101"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
//         XCTAssertTrue([[z2 stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
//         XCTAssertTrue([[co2 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
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
//         XCTAssertTrue([[ci3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
//         XCTAssertTrue([[x3 stringValue] isEqualToString:@"0000000100100011010001010110011110001001101010111100110111101111"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
//         XCTAssertTrue([[y3 stringValue] isEqualToString:@"1111111011011100101110101001100001110110010101000011001000010000"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
//         XCTAssertTrue([[z3 stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
//         XCTAssertTrue([[co3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
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
////         XCTAssertTrue([[ci3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
////         XCTAssertTrue([[x3 stringValue] isEqualToString:@"0000000100100011010001010110011110001001101010111100110111101111"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
////         XCTAssertTrue([[y3 stringValue] isEqualToString:@"1111111011011100101110101001100001110110010101000011001000010000"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
////         XCTAssertTrue([[z3 stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
////         XCTAssertTrue([[co3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
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
            id<CPBitVarHeuristic> h = [cp3 createBitVarFF];
            [cp3 labelBitVarHeuristic:h];
         }];
         [cp3 release];
         NSLog(@"Solution Found:");
         NSLog(@"cin  = %@\n", cin);
         NSLog(@"x    = %@\n", x);
         NSLog(@"y    = %@\n", y);
         NSLog(@"z    = %@\n", z);
         NSLog(@"cout = %@\n", co);
         //         XCTAssertTrue([[ci3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cin is incorrect.");
         //         XCTAssertTrue([[x3 stringValue] isEqualToString:@"0000000100100011010001010110011110001001101010111100110111101111"],@"testBitSUMConstraint: Bit Pattern for x is incorrect.");
         //         XCTAssertTrue([[y3 stringValue] isEqualToString:@"1111111011011100101110101001100001110110010101000011001000010000"],@"testBitSUMConstraint: Bit Pattern for y is incorrect.");
         //         XCTAssertTrue([[z3 stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for z is incorrect.");
         //         XCTAssertTrue([[co3 stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"testSumConstraint: Caught %@: %@", [exception name], [exception reason]);
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
         XCTAssertTrue([[w stringValue] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"],@"testBitIFConstraint: Bit Pattern for w is incorrect.");
//         XCTAssertTrue([[x stringValue] isEqualToString:@"0000000100100011010001010110011110001001101010111100110111101111"],@"testBitIFConstraint: Bit Pattern for x is incorrect.");
//         XCTAssertTrue([[y stringValue] isEqualToString:@"1111111011011100101110101001100001110110010101000011001000010000"],@"testBitIFConstraint: Bit Pattern for y is incorrect.");
//         XCTAssertTrue([[z stringValue] isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111111"],@"testBitIFConstraint: Bit Pattern for z is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   
   NSLog(@"End testing bitwise IF constraint.\n");
}

-(void) testCountConstraint
{
   NSLog(@"Begin testing bit Count (popcount) constraint\n");

   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORIntRange> r = [ORFactory intRange:m low:0 up:32];
   id<ORIntVar> p = [ORFactory intVar:m domain:r];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"p = %@\n", p);
   
   [m add:[ORFactory bit:x count:p]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[x.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End testing bit Count (popcount) constraint.\n");
   
}

-(void) testCountConstraint1
{
   NSLog(@"Begin Test1 of bit Count (popcount) constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   min[0] = 0xAAAAAAAA;
   max[0] = 0xAAAAAAAA;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORIntRange> r = [ORFactory intRange:m low:0 up:32];
   id<ORIntVar> p = [ORFactory intVar:m domain:r];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"p = %@\n", p);
   
   [m add:[ORFactory bit:x count:p]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[x.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 1 of bit Count (popcount) constraint.\n");
   
}

-(void) testCountConstraint2
{
   NSLog(@"Begin Test 2 of bit Count (popcount) constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORIntRange> r = [ORFactory intRange:m low:16 up:16];
   id<ORIntVar> p = [ORFactory intVar:m domain:r];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"p = %@\n", p);
   
   [m add:[ORFactory bit:x count:p]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[x.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 2 of bit Count (popcount) constraint.\n");
   
}

-(void) testCountConstraint3
{
   NSLog(@"Begin Test 3 of bit Count (popcount) constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   min[0] = 0xAAAAAAAA;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORIntRange> r = [ORFactory intRange:m low:32 up:32];
   id<ORIntVar> p = [ORFactory intVar:m domain:r];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"p = %@\n", p);
   
   [m add:[ORFactory bit:x count:p]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[x.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 3 of bit Count (popcount) constraint.\n");
   
}
-(void) testCountConstraint4
{
   NSLog(@"Begin Test 4 of bit Count (popcount) constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   min[0] = 0xAAAAAAAA;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORIntRange> r = [ORFactory intRange:m low:16 up:16];
   id<ORIntVar> p = [ORFactory intVar:m domain:r];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"p = %@\n", p);
   
   [m add:[ORFactory bit:x count:p]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[x.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 4 of bit Count (popcount) constraint.\n");
   
}
-(void) testCountConstraint5
{
   NSLog(@"Begin Test 5 of bit Count (popcount) constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   min[0] = 0xAAAAAAAA;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORIntRange> r = [ORFactory intRange:m low:0 up:32];
   id<ORIntVar> p = [ORFactory intVar:m domain:r];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"p = %@\n", p);
   
   [m add:[ORFactory bit:x count:p]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[x.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 5 of bit Count (popcount) constraint.\n");
   
}

//CPBitZeroExtend
-(void) testZeroExtend1
{
   NSLog(@"Begin Test 1 of bit zero extend constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int minlow[2];
   unsigned int min[1];
   unsigned int max[2];
   minlow[0]=0x00000000;
   minlow[1]=0x00000000;
   min[0] = 0xAAAAAAAA;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:minlow up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:minlow up:max bitLength:64];
   
   [m add:[ORFactory bit:x zeroExtendTo:y]];
   
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
   NSLog(@"End Test 1 of bit zero extend constraint.\n");
   
}
-(void) testZeroExtend2
{
   NSLog(@"Begin Test 2 of bit zero extend constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min64[2];
   unsigned int min[1];
   unsigned int max[2];
   min64[0]=0x00000000;
   min64[1]=0x00000000;
   min[0] = 0xAAAAAAAA;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:min64 up:max bitLength:64];
   
   [m add:[ORFactory bit:x zeroExtendTo:y]];
   
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
   NSLog(@"End Test 2 of bit zero extend constraint.\n");
   
}
-(void) testZeroExtend3
{
   NSLog(@"Begin Test 3 of bit zero extend constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min64[2];
   unsigned int min[1];
   unsigned int max[2];
   min64[0]=0x00000000;
   min64[1]=0x00000000;
   min[0] = 0xAAAAAAAA;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:16];
   id<ORBitVar> y = [ORFactory bitVar:m low:min64 up:max bitLength:32];
   
   [m add:[ORFactory bit:x zeroExtendTo:y]];
   
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
   NSLog(@"End Test 3 of bit zero extend constraint.\n");
   
}
-(void) testZeroExtend4
{
   NSLog(@"Begin Test 4 of bit zero extend constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min64[2];
   unsigned int min[1];
   unsigned int max[2];
   min64[0]=0x00000000;
   min64[1]=0x00000000;
   min[0] = 0xAAAAAAAA;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   
//   unsigned int min4 = 0x00000000;
   unsigned int min4A = 0x0000000A;
   unsigned int max4 = 0x0000000F;
//   unsigned int max8 = 0x000000FF;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:&min4A up:&max4 bitLength:4];
   id<ORBitVar> y = [ORFactory bitVar:m withLength:8];
   
   [m add:[ORFactory bit:x zeroExtendTo:y]];
   
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
   NSLog(@"End Test 4 of bit zero extend constraint.\n");
   
}

-(void) testZeroExtend5
{
   NSLog(@"Begin Test 5 of bit zero extend constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min64[2];
   unsigned int min[1];
   unsigned int max[2];
   min64[0]=0x00000000;
   min64[1]=0x00000000;
   min[0] = 0xAAAAAAAA;
   max[0] = 0xFFFFFFFF;
   max[1] = 0xFFFFFFFF;
   
//   unsigned int min4 = 0x00000000;
//   unsigned int min4A = 0x0000000A;
//   unsigned int max4 = 0x0000000F;
//   unsigned int max8 = 0x000000FF;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m withLength:33];
   
   [m add:[ORFactory bit:x zeroExtendTo:y]];
   
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
   NSLog(@"End Test 5 of bit zero extend constraint.\n");
   
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
   XCTAssertTrue([[[cp stringValue:x] componentsSeparatedByString:@":"][1] isEqualToString:@" 10110111011110111110111111011111"],
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

//CPBitConcat
-(void) testBitConcat
{
   NSLog(@"Begin Test 1 of bit concat constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[2];
   unsigned int max[2];
   
   unsigned int yMin[2];
   unsigned int yMax[2];
   
   min[0] = 0xB77BEFDF;
   min[1] = 0xDFEFFBFF;
   max[0] = 0xB77BEFDF;
   max[1] = 0xDFEFFBFF;
   
   yMin[0] = 0x00000000;
   yMax[0] = 0xFFFFFFFF;
   yMin[1] = 0x00000000;
   yMax[1] = 0xFFFFFFFF;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:&min[1] up:&max[1] bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:yMin up:yMax bitLength:64];
   
   [m add:[ORFactory bit:x concat:y eq:z]];
   
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
   NSLog(@"End Test 1 of bit concat constraint.\n");
   
}
//CPBitConcat
-(void) testBitConcat2
{
   NSLog(@"Begin Test 2 of bit concat constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[2];
   unsigned int max[2];
   
   unsigned int yMin[2];
   unsigned int yMax[2];
   
   min[0] = 0xB77BEFDF;
   min[1] = 0xDFEFFBFF;
   max[0] = 0xB77BEFDF;
   max[1] = 0xDFEFFBFF;
   
   yMin[0] = 0x00000000;
   yMax[0] = 0xFFFFFFFF;
   yMin[1] = 0x00000000;
   yMax[1] = 0xFFFFFFFF;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:yMin up:yMax bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:yMin up:yMax bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:min up:max bitLength:64];
   
   [m add:[ORFactory bit:x concat:y eq:z]];
   
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
   NSLog(@"End Test 2 of bit concat constraint.\n");
   
}
-(void) testBitConcat3
{
   NSLog(@"Begin Test 3 of bit concat constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   unsigned int yMin[1];
   unsigned int yMax[1];
   
   unsigned int zMin[1];
   unsigned int zMax[1];

   min[0] = 0x000000B7;
   max[0] = 0x000000B7;
   
   yMin[0] = 0x0000007B;
   yMax[0] = 0x0000007B;
   
   zMin[0] = 0x00000000;
   zMax[0] = 0x0000FFFF;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:8];
   id<ORBitVar> y = [ORFactory bitVar:m low:yMin up:yMax bitLength:8];
   id<ORBitVar> z = [ORFactory bitVar:m low:zMin up:zMax bitLength:16];
   
   [m add:[ORFactory bit:x concat:y eq:z]];
   
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
   NSLog(@"End Test 3 of bit concat constraint.\n");
   
}
-(void) testBitConcat4
{
   NSLog(@"Begin Test 4 of bit concat constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int zMin[2];
   unsigned int zMax[2];
   
   unsigned int yMin[2];
   unsigned int yMax[2];
   
   yMin[0] = 0x00000000;
   yMax[0] = 0x000000FF;
   
   zMin[0] = 0x0000B77B;
   zMax[0] = 0x0000B77B;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:yMin up:yMax bitLength:8];
   id<ORBitVar> y = [ORFactory bitVar:m low:yMin up:yMax bitLength:8];
   id<ORBitVar> z = [ORFactory bitVar:m low:zMin up:zMax bitLength:16];
   
   [m add:[ORFactory bit:x concat:y eq:z]];
   
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
   NSLog(@"End Test 4 of bit concat constraint.\n");
   
}
//CPBitLogicalEqual
//CPBitLogicalAND
//CPBitLogicalOR
//CPBitLT
//CPBitLTE

//CPBitITE
-(void) testITE
{
   NSLog(@"Begin Test 1 if ITE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   unsigned int trueBV[1];
   unsigned int pat[1];
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   
   trueBV[0] = 0x00000001;
   
   pat[0] = 0xAAAAAAAA;
   
   id<ORBitVar> i = [ORFactory bitVar:m low:trueBV up:trueBV bitLength:1];
   id<ORBitVar> t = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> e = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:pat up:pat bitLength:32];
   
   NSLog(@"Initial values:");
   NSLog(@"if = %@\n", i);
   NSLog(@"then = %@\n", t);
   NSLog(@"else = %@\n", e);
   NSLog(@"result = %@\n", r);
   
   [m add:[ORFactory bit:i then:t else:e result:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[r.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"if = %@\n", [cp stringValue:i]);
         NSLog(@"then = %@\n", [cp stringValue:t]);
         NSLog(@"else = %@\n", [cp stringValue:e]);
         NSLog(@"result = %@\n", [cp stringValue:r]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"if = %@\n", [cp stringValue:i]);
         NSLog(@"then = %@\n", [cp stringValue:t]);
         NSLog(@"else = %@\n", [cp stringValue:e]);
         NSLog(@"result = %@\n", [cp stringValue:r]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 1 of bit ITE constraint.\n");
   
}

-(void) testITE2
{
   NSLog(@"Begin Test 2 if ITE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   unsigned int falseBV[1];
   unsigned int pat[1];
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   
   falseBV[0] = 0x00000000;
   
   pat[0] = 0x0000FFFF;
   
   id<ORBitVar> i = [ORFactory bitVar:m low:falseBV up:falseBV bitLength:32];
   id<ORBitVar> t = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> e = [ORFactory bitVar:m low:pat up:pat bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:min up:max bitLength:32];
   
   NSLog(@"Initial values:");
   NSLog(@"if = %@\n", i);
   NSLog(@"then = %@\n", t);
   NSLog(@"else = %@\n", e);
   NSLog(@"result = %@\n", r);
   
   [m add:[ORFactory bit:i then:t else:e result:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[r.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"if = %@\n", gamma[i.getId]);
         NSLog(@"then = %@\n", gamma[t.getId]);
         NSLog(@"else = %@\n", gamma[e.getId]);
         NSLog(@"result = %@\n", gamma[r.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"if = %@\n", gamma[i.getId]);
         NSLog(@"then = %@\n", gamma[t.getId]);
         NSLog(@"else = %@\n", gamma[e.getId]);
         NSLog(@"result = %@\n", gamma[r.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 2 of bit ITE constraint.\n");
   
}

-(void) testITE3
{
   NSLog(@"Begin Test 3 if ITE constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   unsigned int trueBV[1];
   unsigned int pat[1];
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   
   trueBV[0] = 0x00100000;
   
   pat[0] = 0xFFFF0000;
   
   id<ORBitVar> i = [ORFactory bitVar:m low:trueBV up:trueBV bitLength:32];
   id<ORBitVar> t = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> e = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:pat up:pat bitLength:32];
   
   NSLog(@"Initial values:");
   NSLog(@"if = %@\n", i);
   NSLog(@"then = %@\n", t);
   NSLog(@"else = %@\n", e);
   NSLog(@"result = %@\n", r);
   
   [m add:[ORFactory bit:i then:t else:e result:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[r.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"if = %@\n", gamma[i.getId]);
         NSLog(@"then = %@\n", gamma[t.getId]);
         NSLog(@"else = %@\n", gamma[e.getId]);
         NSLog(@"result = %@\n", gamma[r.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"if = %@\n", gamma[i.getId]);
         NSLog(@"then = %@\n", gamma[t.getId]);
         NSLog(@"else = %@\n", gamma[e.getId]);
         NSLog(@"result = %@\n", gamma[r.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 3 of bit ITE constraint.\n");
   
}

-(void) testBitLogicalEQ
{
   NSLog(@"Begin Test 1 of bit logical equal constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   unsigned int pat[1];
   
   pat[0] = 0xAAAAAAAA;
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:pat up:pat bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:pat up:pat bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:min up:max bitLength:1];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   NSLog(@"r = %@\n", r);
   
   [m add:[ORFactory bit:x EQ:y eval:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 1 of bit logical equal constraint.\n");
   
}

-(void) testBitLogicalEQ2
{
   NSLog(@"Begin Test 2 of bit logical equal constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   unsigned int pat[1];
   unsigned int pat2[1];
   
   pat[0] = 0xAAAAAAAA;
   pat2[0] = 0xAAAAAAAB;
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:pat up:pat bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:pat2 up:pat2 bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:min up:max bitLength:1];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   NSLog(@"r = %@\n", r);
   
   [m add:[ORFactory bit:x EQ:y eval:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 2 of bit logical equal constraint.\n");
   
}
-(void) testBitLogicalEQ3
{
   NSLog(@"Begin Test 3 of bit logical equal constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   unsigned int pat[1];
   unsigned int pat2[1];
   
   pat[0] = 0xAAABAAAA;
   pat2[0] = 0xAAAAAAAA;
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:pat up:pat bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:pat2 up:pat2 bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:min up:max bitLength:1];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   NSLog(@"r = %@\n", r);
   
   [m add:[ORFactory bit:x EQ:y eval:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 3 of bit logical equal constraint.\n");
   
}
-(void) testBitLogicalEQ4
{
   NSLog(@"Begin Test 4 of bit logical equal constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   unsigned int pat[1];
   unsigned int pat2[1];
   
   pat[0] = 0xAAAAAAAA;
   pat2[0] = 0x2AAAAAAA;
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:pat up:pat bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:pat2 up:pat2 bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:min up:min bitLength:1];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   NSLog(@"r = %@\n", r);
   
   [m add:[ORFactory bit:x EQ:y eval:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 4 of bit logical equal constraint.\n");
   
}
-(void) testBitLogicalEQ5
{
   NSLog(@"Begin Test 5 of bit logical equal constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   unsigned int pat[1];
   unsigned int pat2[1];
   
   pat[0] = 0xAAAAAAAA;
   pat2[0] = 0xAAAAAAAB;
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:pat up:pat2 bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:pat up:pat bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:min up:min bitLength:1];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   NSLog(@"r = %@\n", r);
   
   [m add:[ORFactory bit:x EQ:y eval:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 5 of bit logical equal constraint.\n");
   
}
-(void) testBitLogicalEQ6
{
   NSLog(@"Begin Test 6 of bit logical equal constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   unsigned int pat[1];
   unsigned int pat2[1];
   
   pat[0] = 0xAAAAAAAA;
   pat2[0] = 0xBAAAAAAA;
   min[0] = 0x00000000;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:pat up:pat2 bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:pat up:pat bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:max up:max bitLength:1];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   NSLog(@"r = %@\n", r);
   
   [m add:[ORFactory bit:x EQ:y eval:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 6 of bit logical equal constraint.\n");
   
}
//CPBitRotateR
//CPBitShiftR
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
   id<ORBitVar> x1 = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> x2 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x3 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x4 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x5 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x6 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> x7 = [ORFactory bitVar:m low:max up:max bitLength:32];
   id<ORBitVar> x8 = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> cin = [ORFactory bitVar:m low:zero up:max bitLength:32];
   id<ORBitVar> cout = [ORFactory bitVar:m low:zero up:max bitLength:32];
   
   [m add:[ORFactory bit:x1 bxor:x2 eq:x3]];
   [m add:[ORFactory bit:x1 rotateLBy:8 eq:x2]];
//   [m add:[ORFactory bit:x3 rotateLBy:8 eq:x4]];
   [m add:[ORFactory bit:x3 bxor:x1 eq:x4]];
   [m add:[ORFactory bit:x4 bxor:x5 eq:x6]];
   [m add:[ORFactory bit:x5 rotateLBy:8 eq:x6]];
   [m add:[ORFactory bit:x5 bxor:x6 eq:x7]];
   [m add:[ORFactory bit:x5 plus:x6 withCarryIn:cin eq:x8 withCarryOut:cout]];
   [m add:[ORFactory bit:x2 eq:x8]];
   
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgramBackjumpingDFS:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:9]];
   [o set:gamma[x1.getId] at:0];
   [o set:gamma[x2.getId] at:1];
   [o set:gamma[x3.getId] at:2];
   [o set:gamma[x4.getId] at:3];
   [o set:gamma[x5.getId] at:4];
   [o set:gamma[x6.getId] at:5];
   [o set:gamma[x7.getId] at:6];
   [o set:gamma[x8.getId] at:7];
   [o set:gamma[cin.getId] at:8];
   [o set:gamma[cout.getId] at:9];
   
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solveAll: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"%lx x1 = %@\n", gamma[x1.getId], gamma[x1.getId]);
         NSLog(@"%lx x2 = %@\n", gamma[x2.getId], gamma[x2.getId]);
         NSLog(@"%lx x3 = %@\n", gamma[x3.getId], gamma[x3.getId]);
         NSLog(@"%lx x4 = %@\n", gamma[x4.getId], gamma[x4.getId]);
         NSLog(@"%lx x5 = %@\n", gamma[x5.getId], gamma[x5.getId]);
         NSLog(@"%lx x6 = %@\n", gamma[x6.getId], gamma[x6.getId]);
         NSLog(@"%lx x7 = %@\n", gamma[x7.getId], gamma[x7.getId]);
         NSLog(@"%lx x8 = %@\n", gamma[x8.getId], gamma[x8.getId]);
         NSLog(@"%lx cin = %@\n", gamma[cin.getId], gamma[cin.getId]);
         NSLog(@"%lx cout = %@\n", gamma[cout.getId], gamma[cout.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x1 = %@\n", gamma[x1.getId]);
         NSLog(@"x2 = %@\n", gamma[x2.getId]);
         NSLog(@"x3 = %@\n", gamma[x3.getId]);
         NSLog(@"x4 = %@\n", gamma[x4.getId]);
         NSLog(@"x5 = %@\n", gamma[x5.getId]);
         NSLog(@"x6 = %@\n", gamma[x6.getId]);
         NSLog(@"x7 = %@\n", gamma[x7.getId]);
         NSLog(@"x8 = %@\n", gamma[x8.getId]);
         NSLog(@"cin = %@\n", gamma[cin.getId]);
         NSLog(@"cout = %@\n", gamma[cout.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"Solver status: %@\n",cp);

   NSLog(@"End Test of backjumping search\n");
   
}

-(void) testBoolOR
{
   NSLog(@"Begin Test of bit boolean OR constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   min[0] = 0x0;
   max[0] = 0x1;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:1];
   id<ORBitVar> y = [ORFactory bitVar:m low:max up:max bitLength:1];
   id<ORBitVar> r1 = [ORFactory bitVar:m low:min up:max bitLength:1];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   NSLog(@"r = %@\n", r1);
   
   [m add:[ORFactory bit:x orb:y eval:r1]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgramBackjumpingDFS:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r1.getId] at:2];
   
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r1.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r1.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test of bit boolean OR constraint.\n");
   
}

-(void) testBoolEqual
{
   NSLog(@"Begin Test of bit boolean equality constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   min[0] = 0x0;
   max[0] = 0x1;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:1];
   id<ORBitVar> y = [ORFactory bitVar:m low:max up:max bitLength:1];
   id<ORBitVar> r1 = [ORFactory bitVar:m low:min up:max bitLength:1];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"y = %@\n", y);
   NSLog(@"r = %@\n", r1);
   
   [m add:[ORFactory bit:x equalb:y eval:r1]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgramBackjumpingDFS:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r1.getId] at:2];
   
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r1.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"y = %@\n", gamma[y.getId]);
         NSLog(@"r = %@\n", gamma[r1.getId]);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test of bit boolean Equality constraint.\n");
   
}


-(void) testBitLT
{
   NSLog(@"Begin Test bit Count < constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int min2[1];
   unsigned int max[1];
   unsigned int one[1];
   
   min[0] = 0xBBBBBBBB;
   max[0] = 0xFFFFFFFF;
   one[0] = ONE;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:min up:max bitLength:32];
   min2[0] = 0xAAAAAAAA;
   id<ORBitVar> z = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:min up:one bitLength:1];
   

   
   [m add:[ORFactory bit:x LT:y eval:r]];
   [m add:[ORFactory bit:y LT:z eval:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];

   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF];

   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", [cp stringValue:x]);
   NSLog(@"y = %@\n", [cp stringValue:y]);
   NSLog(@"z = %@\n", [cp stringValue:z]);
   NSLog(@"r = %@\n", [cp stringValue:r]);

   
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
         NSLog(@"%@", [cp engine]);
         NSLog(@"Solver status: %@\n",cp);
         //XCTAssertTrue([[x7 stringValue] isEqualToString:@"11111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test of bit < constraint.\n");
   
}

-(void) testBitLE
{
   NSLog(@"Begin Test bit Count <= constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int min2[1];
   unsigned int max[1];
   unsigned int one[1];
   unsigned int zero[1];
   
   
   min[0] = 0xBBBBBBBB;
   max[0] = 0xFFFFFFFF;
   one[0] = ONE;
   zero[0] = ZERO;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:min up:max bitLength:32];
   min2[0] = 0xAAAAAAAA;
   id<ORBitVar> z = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:zero up:zero bitLength:1];
   
   
   
   [m add:[ORFactory bit:x LE:y eval:r]];
   [m add:[ORFactory bit:y LE:z eval:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", [cp stringValue:x]);
   NSLog(@"y = %@\n", [cp stringValue:y]);
   NSLog(@"z = %@\n", [cp stringValue:z]);
   NSLog(@"r = %@\n", [cp stringValue:r]);
   
   
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
         NSLog(@"%@", [cp engine]);
         NSLog(@"Solver status: %@\n",cp);
         //XCTAssertTrue([[x7 stringValue] isEqualToString:@"11111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test of bit <= constraint.\n");
   
}

-(void) testBitSLT
{
   NSLog(@"Begin Test bit Count < constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int min2[1];
   unsigned int max[1];
   unsigned int one[1];
   
   min[0] = 0xBBBBBBBB;
   max[0] = 0xFFFFFFFF;
   one[0] = ONE;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:min up:max bitLength:32];
   min2[0] = 0xAAAAAAAA;
   id<ORBitVar> z = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:min up:one bitLength:1];
   
   
   
   [m add:[ORFactory bit:x SLT:y eval:r]];
   [m add:[ORFactory bit:y SLT:z eval:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", [cp stringValue:x]);
   NSLog(@"y = %@\n", [cp stringValue:y]);
   NSLog(@"z = %@\n", [cp stringValue:z]);
   NSLog(@"r = %@\n", [cp stringValue:r]);
   
   
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
         NSLog(@"%@", [cp engine]);
         NSLog(@"Solver status: %@\n",cp);
         //XCTAssertTrue([[x7 stringValue] isEqualToString:@"11111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test of bit < constraint.\n");
   
}

-(void) testBitSLE
{
   NSLog(@"Begin Test bit Count <= constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int min2[1];
   unsigned int max[1];
   unsigned int max2[1];
   unsigned int one[1];
   unsigned int zero[1];
   
   
   min[0] = 0xFFBBBBBB;
   
   max[0] = 0xFFFFFFFF;
   min2[0] = 0x00AAAAAA;
   max2[0] = 0x00FFFFFF;
   one[0] = ONE;
   zero[0] = ZERO;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:min2 up:max2 bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:min2 up:max2 bitLength:32];
   id<ORBitVar> r = [ORFactory bitVar:m low:zero up:one bitLength:1];
   
   
   
   [m add:[ORFactory bit:x SLE:y eval:r]];
   [m add:[ORFactory bit:y SLE:z eval:r]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[r.getId] at:2];
   id<CPBitVarHeuristic> h = [cp createBitVarFF];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", [cp stringValue:x]);
   NSLog(@"y = %@\n", [cp stringValue:y]);
   NSLog(@"z = %@\n", [cp stringValue:z]);
   NSLog(@"r = %@\n", [cp stringValue:r]);
   
   
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"r = %@\n", [cp stringValue:r]);
         NSLog(@"%@", [cp engine]);
         NSLog(@"Solver status: %@\n",cp);
         //XCTAssertTrue([[x7 stringValue] isEqualToString:@"11111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   

   NSLog(@"End Test of bit <= constraint.\n");
   
}

-(void) testBitLogicalEqual
{
   NSLog(@"Begin Test bit Logical Equal constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int min2[1];
   unsigned int max[1];
   unsigned int max2[1];
   unsigned int one[1];
   unsigned int zero[1];
   
   
   min[0] = 0xBBBBBBBB;
   max[0] = 0xFFFFFFFF;
   min2[0] = 0x00AAAAAA;
   max2[0] = 0xFFFFFFFF;
   one[0] = ONE;
   zero[0] = ZERO;
   
   id<ORBitVar> w = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:min2 up:max2 bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:min2 up:max2 bitLength:32];
   id<ORBitVar> r1 = [ORFactory bitVar:m low:zero up:zero bitLength:1];
   id<ORBitVar> r2 = [ORFactory bitVar:m low:zero up:one bitLength:1];
   id<ORBitVar> r3 = [ORFactory bitVar:m low:one up:one bitLength:1];
   
   
   [m add:[ORFactory bit:w EQ:x eval:r1]];
   [m add:[ORFactory bit:x EQ:y eval:r2]];
   [m add:[ORFactory bit:y EQ:z eval:r2]];
   [m add:[ORFactory bit:w EQ:z eval:r3]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   
   id<CPBitVarHeuristic> h = [cp createBitVarFF];
   
   NSLog(@"Initial values:");
   NSLog(@"w = %@\n", [cp stringValue:w]);
   NSLog(@"x = %@\n", [cp stringValue:x]);
   NSLog(@"y = %@\n", [cp stringValue:y]);
   NSLog(@"z = %@\n", [cp stringValue:z]);
   NSLog(@"r1 = %@\n", [cp stringValue:r1]);
   NSLog(@"r2 = %@\n", [cp stringValue:r2]);
   NSLog(@"r3 = %@\n", [cp stringValue:r3]);
   
   
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"w = %@\n", [cp stringValue:w]);
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"r1 = %@\n", [cp stringValue:r1]);
         NSLog(@"r2 = %@\n", [cp stringValue:r2]);
         NSLog(@"r3 = %@\n", [cp stringValue:r3]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"w = %@\n", [cp stringValue:w]);
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"r1 = %@\n", [cp stringValue:r1]);
         NSLog(@"r2 = %@\n", [cp stringValue:r2]);
         NSLog(@"r3 = %@\n", [cp stringValue:r3]);
         NSLog(@"%@", [cp engine]);
         NSLog(@"Solver status: %@\n",cp);
         //XCTAssertTrue([[x7 stringValue] isEqualToString:@"11111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   
   
   NSLog(@"End Test of bit <= constraint.\n");
   
}


-(void) testBitMultiply
{
   NSLog(@"Begin Test bit multiply constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int min2[1];
   unsigned int max[1];
   unsigned int max2[1];
   unsigned int one[1];
   unsigned int zero[1];
   
   
   min[0] = 0xFFBBBBBB;
   
   max[0] = 0xFFFFFFFF;
   min2[0] = 0x00AAAAAA;
   max2[0] = 0x00FFFFFF;
   one[0] = ONE;
   zero[0] = ZERO;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:min2 up:min2 bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:min2 up:min2 bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:zero up:max bitLength:32];
   
   
   
   [m add:[ORFactory bit:x times:y eq:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgramBackjumpingDFS:m];
   
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];

   id<CPBitVarHeuristic> h = [cp createBitVarFF];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", [cp stringValue:x]);
   NSLog(@"y = %@\n", [cp stringValue:y]);
   NSLog(@"z = %@\n", [cp stringValue:z]);
   
   
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"%@", [cp engine]);
         NSLog(@"Solver status: %@\n",cp);
         //XCTAssertTrue([[x7 stringValue] isEqualToString:@"11111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   
   
   NSLog(@"End Test of bit multiply constraint.\n");
   
}




-(void) testBitSubtract
{
   NSLog(@"Begin Test bit subtract constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int min2[1];
   unsigned int max[1];
   unsigned int max2[1];
   unsigned int one[1];
   unsigned int zero[1];
   
   
   min[0] = 0xFFBBBBBB;
   
   max[0] = 0xFFFFFFFF;
   min2[0] = 0x00AAAAAA;
   max2[0] = 0x00FFFFFF;
   one[0] = ONE;
   zero[0] = ZERO;
   
   id<ORBitVar> x = [ORFactory bitVar:m low:max2 up:max2 bitLength:32];
   id<ORBitVar> y = [ORFactory bitVar:m low:min2 up:min2 bitLength:32];
   id<ORBitVar> z = [ORFactory bitVar:m low:zero up:max bitLength:32];
   
   
   
   [m add:[ORFactory bit:x minus:y eq:z]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgramBackjumpingDFS:m];
   
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:2]];
   [o set:gamma[x.getId] at:0];
   [o set:gamma[y.getId] at:1];
   [o set:gamma[z.getId] at:2];
   
   id<CPBitVarHeuristic> h = [cp createBitVarFF];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", [cp stringValue:x]);
   NSLog(@"y = %@\n", [cp stringValue:y]);
   NSLog(@"z = %@\n", [cp stringValue:z]);
   
   
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", [cp stringValue:x]);
         NSLog(@"y = %@\n", [cp stringValue:y]);
         NSLog(@"z = %@\n", [cp stringValue:z]);
         NSLog(@"%@", [cp engine]);
         NSLog(@"Solver status: %@\n",cp);
         //XCTAssertTrue([[x7 stringValue] isEqualToString:@"11111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   
   
   NSLog(@"End Test of bit subtract constraint.\n");
   
}


-(void) test
{
   NSLog(@"Begin Test 5 of bit Count (popcount) constraint\n");
   
   id<ORModel> m = [ORFactory createModel];
   unsigned int min[1];
   unsigned int max[1];
   
   min[0] = 0xAAAAAAAA;
   max[0] = 0xFFFFFFFF;
   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
   id<ORIntRange> r = [ORFactory intRange:m low:0 up:32];
   id<ORIntVar> p = [ORFactory intVar:m domain:r];
   
   NSLog(@"Initial values:");
   NSLog(@"x = %@\n", x);
   NSLog(@"p = %@\n", p);
   
   [m add:[ORFactory bit:x count:p]];
   
   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
   id* gamma = [cp gamma];
   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
   [o set:gamma[x.getId] at:0];
   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
   [cp solve: ^(){
      @try {
         NSLog(@"After Posting:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
         [cp labelBitVarHeuristic:h];
         NSLog(@"Solution Found:");
         NSLog(@"x = %@\n", gamma[x.getId]);
         NSLog(@"p = %@\n", gamma[p.getId]);
         //XCTAssertTrue([[x7 stringValue] isEqualToString:@"11111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
   NSLog(@"End Test 5 of bit Count (popcount) constraint.\n");
   
}





//-(void) testBitLTx
//{
//   NSLog(@"Begin Exhaustive Test of bit less than constraint\n");
//   
//   id<ORModel> m = [ORFactory createModel];
//   unsigned int min[1];
//   unsigned int max[1];
//   
//   min[0] = 0xAAAAAAAA;
//   max[0] = 0xFFFFFFFF;
//   id<ORBitVar> x = [ORFactory bitVar:m low:min up:max bitLength:32];
//   id<ORIntRange> r = [ORFactory intRange:m low:0 up:32];
//   id<ORIntVar> p = [ORFactory intVar:m domain:r];
//   
//   NSLog(@"Initial values:");
//   NSLog(@"x = %@\n", x);
//   NSLog(@"p = %@\n", p);
//   
//   [m add:[ORFactory bit:x count:p]];
//   
//   id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
//   id* gamma = [cp gamma];
//   id<ORIdArray> o = [ORFactory idArray:[cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:0]];
//   [o set:gamma[x.getId] at:0];
//   id<CPBitVarHeuristic> h = [cp createBitVarFF:(id<CPBitVarArray>)o];
//   [cp solve: ^(){
//      @try {
//         NSLog(@"After Posting:");
//         NSLog(@"x = %@\n", gamma[x.getId]);
//         NSLog(@"p = %@\n", gamma[p.getId]);
//         [cp labelBitVarHeuristic:h];
//         NSLog(@"Solution Found:");
//         NSLog(@"x = %@\n", gamma[x.getId]);
//         NSLog(@"p = %@\n", gamma[p.getId]);
//         //XCTAssertTrue([[x7 stringValue] isEqualToString:@"11111111111111111111111111111111"],@"testBitSUMConstraint: Bit Pattern for Cout is incorrect.");
//      }
//      @catch (NSException *exception) {
//         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
//      }
//   }];
//   NSLog(@"End Test\n");
//   
//}
@end

