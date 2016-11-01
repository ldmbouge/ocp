//
//  testBitVarElement.m
//  Clo
//
//  Created by Nikolaj on 11/19/13.
//
//

#import "testBitVarElement.h"
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

@implementation testBitVarElement
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

-(void)testBVElmt {
    NSLog(@"Begin testing bv element constraint\n");
    
    id<ORModel> m = [ORFactory createModel];
    unsigned int minx[1];
    unsigned int maxx[1];
    minx[0] = 0;
    maxx[0] = 7;
    id<ORBitVar> x = [ORFactory bitVar:m low:minx up:maxx bitLength:32];
    
    unsigned int miny[1];
    unsigned int maxy[1];
    miny[0] = 1;
    maxy[0] = 15;
    id<ORBitVar> y = [ORFactory bitVar:m low:miny up:maxy bitLength:32];
    id<ORIdArray> arr = [ORFactory idArray:m range:RANGE(m, 1, 4)];
    
    unsigned int min1[1];
    unsigned int max1[1];
    min1[0] = 1;
    max1[0] = 7;
    id<ORBitVar> el1 = [ORFactory bitVar:m low:min1 up:max1 bitLength:32];
    [arr set:el1 at:1];
    
    unsigned int min2[1];
    unsigned int max2[1];
    min2[0] = 0;
    max2[0] = 7;
    id<ORBitVar> el2 = [ORFactory bitVar:m low:min2 up:max2 bitLength:32];
    [arr set:el2 at:2];
    
    unsigned int min3[1];
    unsigned int max3[1];
    min3[0] = 0;
    max3[0] = 1;
    id<ORBitVar> el3 = [ORFactory bitVar:m low:min3 up:max3 bitLength:32];
    [arr set:el3 at:3];
    
    unsigned int min4[1];
    unsigned int max4[1];
    min4[0] = 2;
    max4[0] = 2;
    id<ORBitVar> el4 = [ORFactory bitVar:m low:min4 up:max4 bitLength:32];
    [arr set:el4 at:4];
    
    [m add:[ORFactory element:m var:x idxBitVarArray:arr equal:y]];
    
    id<CPProgram,CPBV> cp = (id)[ORFactory createCPProgram:m];
    [cp solveAll: ^() {
        @try {
            NSLog(@"After Posting:");
            NSLog(@"x =  %@\n", [cp stringValue:x]);
            NSLog(@"y =  %@\n", [cp stringValue:y]);
            for (int e=[arr low];e<=[arr up];e++)
                NSLog(@"e%d = %@\n", e, [cp stringValue:arr[e]]);
            
            [cp labelUpFromLSB:x];
            [cp labelUpFromLSB:y];
            for (int e=[arr low];e<=[arr up];e++)
                [cp labelUpFromLSB:arr[e]];
            
            NSLog(@"Solution found:");
            NSLog(@"x  = %@\n", [cp stringValue:x]);
            NSLog(@"y  = %@\n", [cp stringValue:y]);
            for (int e=[arr low];e<=[arr up];e++)
                NSLog(@"e%d = %@\n", e, [cp stringValue:arr[e]]);
        }
        @catch (NSException *exception) {
            NSLog(@"testEqualityConstraint: Caught %@: %@", [exception name], [exception reason]);
        }
    }];
    
    NSLog(@"End testing bv element constraint\n");
}

@end
