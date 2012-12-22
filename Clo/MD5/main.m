//
//  main.m
//  MD5
//
//  Created by Greg Johnson on 12/17/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

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

int main(int argc, const char * argv[])
{
//
//   @autoreleasepool {
//      id<ORModel> m = [ORFactory createModel];
//      unsigned int min;
//      unsigned int max;
//      min = min = 0;
//      max = max = CP_UMASK;
//      
//      id<ORBitVar> x = [ORFactory bitVar:m low:&min up:&max bitLength:32];
//      id<ORBitVar> y = [ORFactory bitVar:m low:&min up:&max bitLength:32];
//      min[1] = 8;
//      max[1] = 12;
//      id<ORBitVar> z = [ORFactory bitVar:m low:&min up:&max bitLength:32];
//      
//      [m add:[ORFactory bit:x eq:y]];
//      [m add:[ORFactory bit:y eq:z]];
//
//      id<CPProgram,CPBV> cp = [ORFactory createCPProgram:m];
//      [cp solve: ^() {
//         @try {
//            NSLog(@"After Posting:");
//            NSLog(@"a = %@\n", a);
//            NSLog(@"b = %@\n", b);
//            NSLog(@"c = %@\n", c);
//            [cp labelUpFromLSB:a];
//            [cp labelUpFromLSB:b];
//            [cp labelUpFromLSB:c];
//            NSLog(@"Solution Found:");
//            NSLog(@"a = %@\n", a);
//            NSLog(@"b = %@\n", b);
//            NSLog(@"c = %@\n", c);
//            
//         }
//         @catch (NSException *exception) {
//            
//            NSLog(@"MD5: Caught %@: %@", [exception name], [exception reason]);
//            
//         }
//      }];
//      
//   }
//    return 0;
}

