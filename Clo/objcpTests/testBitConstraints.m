//
//  testBitConstraints.m
//  Clo
//
//  Created by Greg Johnson on 6/10/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

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
   max[0] = max[1] = CP_UMASK;
   
    id<CPBitVar> x = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    min[0] = 0;
    min[1] = 4;
    max[0] = 0xFFFFFFFF;
    max[1] = 13;
    id<CPBitVar> y = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    min[1] = 8;
    max[1] = 12;
    id<CPBitVar> z = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    
    
    NSLog(@"x = %@\n", x);
    NSLog(@"y = %@\n", y);
    NSLog(@"z = %@\n", z);
   [m add:[CPFactory bitEqual:x to:y]];
   [m add:[CPFactory bitEqual:y to:z]];
    [m solve: ^() {
       @try {
/*          while(![y bound])
          {
             unsigned int i = [(CPBitVarI*)y lsFreeBit];
             [CPLabel bit: i ofVar:y];
          }
 */
          [CPLabel upFromLSB:y];
       }
       @catch (NSException *exception) {
          
          NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
          
       }
         NSLog(@"x = %@\n", x);
         NSLog(@"y = %@\n", y);
         NSLog(@"z = %@\n", z);
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
    
    
    NSLog(@"a = %@\n", a);
    NSLog(@"b = %@\n", b);
    NSLog(@"c = %@\n", c);
    
    [m add:[CPFactory bitAND:a and:b equals:c]];
   [m solve: ^() {
      @try {
         [CPLabel upFromLSB:c];
/*         while(![c bound])
         {
            unsigned int i = [(CPBitVarI*)c lsFreeBit];
            NSLog(@"Labeling bit %d of %@.\n", i, c);
            [CPLabel bit: i ofVar:c];
         }
*/
      }
      @catch (NSException *exception) {
         
         NSLog(@"testANDConstraint: Caught %@: %@", [exception name], [exception reason]);
         
      }
      NSLog(@"a = %@\n", a);
      NSLog(@"b = %@\n", b);
      NSLog(@"c = %@\n", c);
   }];
    
    NSLog(@"a = %@\n", a);
    NSLog(@"b = %@\n", b);
    NSLog(@"c = %@\n", c);
    
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
    
    NSLog(@"d = %@\n", d);
    NSLog(@"e = %@\n", e);
    NSLog(@"f = %@\n", f);
    
    [m add:[CPFactory bitOR:d or:e equals:f]];
    
    NSLog(@"d = %@\n", d);
    NSLog(@"e = %@\n", e);
    NSLog(@"f = %@\n", f);
    
    
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
    
    NSLog(@"g = %@\n", g);
    NSLog(@"h = %@\n", h);
    
    [m add:[CPFactory bitNOT:g equals:h]];
   [m solve: ^() {
      @try {
         [CPLabel upFromLSB:h];
         NSLog(@"g = %@\n", g);
         NSLog(@"h = %@\n", h);
      }
      @catch (NSException *exception) {
         NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
      }
   }];
    
//    NSLog(@"g = %@\n", g);
//    NSLog(@"h = %@\n", h);
    
    
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
    
    NSLog(@"i = %@\n", i);
    NSLog(@"j = %@\n", j);
    NSLog(@"k = %@\n", k);
    
    
    [m add:[CPFactory bitXOR:i xor:j equals:k]];
    NSLog(@"i = %@\n", i);
    NSLog(@"j = %@\n", j);
    NSLog(@"k = %@\n", k);
    
    NSLog(@"End testing bitwise XOR constraint.\n");
    
}

-(void) testShiftLConstraint{
    NSLog(@"Begin testing bitwise ShiftL constraint\n");
    
    id<CPSolver> m = [CPFactory createSolver];
    unsigned int min[2];
    unsigned int max[2];
    
    min[0] = 0;
    min[1] = 7;
    max[0] = 0xFFFFFFFF;
    max[1] = 0xFFFFFF0F;
    id<CPBitVar> p = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    min[1] = 0;
    min[0] = 0x70;
    max[1] = 0x0FFFFFFF;
    id<CPBitVar> q = [CPFactory bitVar:m withLow:min andUp:max andLength:64];
    
    NSLog(@"p = %@\n", p);
    NSLog(@"q = %@\n", q);
    [m add:[CPFactory bitShiftL:p by:3 equals:q]];

    NSLog(@"p = %@\n", p);
    NSLog(@"q = %@\n", q);
    
    NSLog(@"End testing bitwise ShiftL constraint.\n");
    
}

-(void) testSumConstraint{
    NSLog(@"Begin testing bitwise Sum constraint\n");
        
     id<CPSolver> m = [CPFactory createSolver];
     unsigned int min[4];
     unsigned int max[4];
     
     min[0] = 0x00000000;//
     min[1] = 0x00005FFF; 
     min[2] = 0xFFFFFFFF;
     min[3] = 0xF0000000;
     
     max[0] = 0x00000000;//
     max[1] = 0x00005FFF;
     max[2] = 0xFFFFFFFF;
     max[3] = 0xFFFFFF00;
     
     id<CPBitVar> x = [CPFactory bitVar:m withLow: min andUp:max andLength:128];
     
     min[0] = 0x0003FFF8;//
     min[1] = 0x00F00000;
     min[2] = 0x7FFD0000;
     min[3] = 0x00000000;
     
     max[0] = 0x0D03FFFF;//
     max[1] = 0xFFFFC000;
     max[2] = 0x7FFFFFFF;
     max[3] = 0xF0000000;
     
     id<CPBitVar> y = [CPFactory bitVar:m withLow: min andUp:max andLength:128];     
     
     min[0] = 0x0F003C00;//
     min[1] = 0x1FC003C0;
     min[2] = 0x078003F0;
     min[3] = 0x003F8000;
     
     max[0] = 0x0FFC3FF8;//
     max[1] = 0x1FFFC3FF;
     max[2] = 0x87FD03FF;
     max[3] = 0xF03FFF00;
     
     id<CPBitVar> ci = [CPFactory bitVar:m withLow: min andUp:max andLength:128];
     
     min[0] = 0x0C3C00C1;//
     min[1] = 0x8606300C; 
     min[2] = 0x061860C3; 
     min[3] = 0x830C0C00;
     
     max[0] = 0x3F3FCCF9;//
     max[1] = 0xE7C7FCCF;
     max[2] = 0x9F9D7CF3;
     max[3] = 0xF3CF8F00;

     id<CPBitVar> z = [CPFactory bitVar:m withLow: min andUp:max andLength:128];

     
     min[0] = 0x00002A10;//
     min[1] = 0x109082A1;
     min[2] = 0x55550AA9;
     min[3] = 0x40212100;
     
     max[0] = 0x55557F5A;//
     max[1] = 0xBCDAD7F5;
     max[2] = 0xFFFFAFFD;
     max[3] = 0xB575B500;
     
     id<CPBitVar> co = [CPFactory bitVar:m withLow: min andUp:max andLength:128];
    
    NSLog(@"x    = %@\n", x);
    NSLog(@"y    = %@\n", y);
    NSLog(@"cin  = %@\n", ci);
    NSLog(@"z    = %@\n", z);
    NSLog(@"cout = %@\n", co);
    //[m add:[CPFactory ]];
    NSLog(@"x    = %@\n", x);
    NSLog(@"y    = %@\n", y);
    NSLog(@"cin  = %@\n", ci);
    NSLog(@"z    = %@\n", z);
    NSLog(@"cout = %@\n", co);

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
