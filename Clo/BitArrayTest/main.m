/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "objcp/CPSolver.h"
//#import <SenTestingKit/SenTestingKit.h>

#import "objcp/CPBitArray.h"
#import "objcp/CPBitArrayDom.h"

int main (int argc, const char * argv[])
{ 
   /*    
    unsigned int mask = 0xFFFFFFFF;
    unsigned int i2 = 0XAAAAAAAA;
    unsigned int i3 = 0x55555555;
    
    CPBitArray*  bv1 = [[CPBitArray alloc] initWithUnsignedValue:mask];
    CPBitArray*  bv2 = [[CPBitArray alloc] initWithUnsignedValue: i3];
    
    CPBitArray* bv3 = [bv1 bitwiseAND: bv2];
    CPBitArray* bv4 = [bv2 bitwiseShiftL: 1];
    CPBitArray* bv5 = [bv2 bitwiseNOT];
    
    NSLog( @"%@\t&\n",bv1);
    NSLog( @"%@\n",bv2);
    NSLog( @"--------------------\n");
    NSLog( @"%@\n\n\n", bv3);
    
    NSLog( @"%@\t<<1\n",bv2);
    NSLog( @"--------------------\n");    
    NSLog( @"%@\n\n\n",bv4);
    
    NSLog( @"%@\t~\n",bv2);
    NSLog( @"--------------------\n");
    NSLog( @"%@\n\n\n",bv5);
    
    unsigned int* array = malloc(sizeof(unsigned int)*8);
    for (int k = 0; k< 8; k++) 
    array[k] = i2;
    CPBitArray* longBitVector = [[CPBitArray alloc] initWithUnsignedArray:array 
    andLength: 8*32];
    //    [array release] ;
    CPBitArray* notLongBitVector = [longBitVector bitwiseNOT];
    
    NSLog( @"%@\t~\n",longBitVector);
    NSLog( @"--------------------\n");
    NSLog( @"%@\n\n\n",notLongBitVector);
    
    CPBitArray* longAndTest = [longBitVector bitwiseAND: notLongBitVector];
    NSLog( @"--------------------\n");
    NSLog( @"%@\t~\n", longBitVector);
    NSLog( @"%@\t~\n", notLongBitVector);
    NSLog( @"--------------------\n");
    NSLog( @"%@\t~\n\n\n", longAndTest);
    
    CPBitArray* longOrTest = [longBitVector bitwiseOR: notLongBitVector];
    NSLog( @"--------------------\n");
    NSLog( @"%@\t|\n", longBitVector );
    NSLog( @"%@\n", notLongBitVector);
    NSLog( @"--------------------\n");
    NSLog( @"%@\n\n\n", longOrTest);
    
    array = malloc(sizeof( unsigned int)*8);
    for (int k = 0; k< 8; k++) 
    array[k] = mask;
    
    CPBitArray* longMax = [[CPBitArray alloc] initWithUnsignedArray: (unsigned int*) array andLength: 8*32];
    //    [array release];
    
    
    CPBitArray* longBitShiftLeft = longMax;
    longBitShiftLeft = [longMax bitwiseShiftL: 7];
    NSLog( @"%@\t<<7\n", longMax);
    NSLog( @"--------------------\n");
    NSLog( @"%@\n\n\n", longBitShiftLeft);
    
    longMax = [longBitVector bitwiseShiftL: 7];
    NSLog( @"%@\t<<7\n", longBitVector);
    NSLog( @"--------------------\n");
    NSLog( @"%@\n\n\n", longMax);
    */
   
   CPTrail*   dummyTrail = [[CPTrail alloc] init];
   CPBitArrayDom*  bitDomain = [[CPBitArrayDom alloc] initWithLength:32 withTrail: dummyTrail];
   
   NSLog(@"%@\n", bitDomain);
   
   [bitDomain setBit:7 to:true];
   [bitDomain setBit:30 to:false];
   [bitDomain setBit:31 to:true];
   
   NSLog(@"%@\n", bitDomain);
   
   unsigned int* testvalue = malloc(sizeof (unsigned int)*2);
   *testvalue = 0x8FFFFFFF;
   
   if([bitDomain member:testvalue])
      NSLog(@"Passed member test");
   else
      NSLog(@"Failed member test");
   
   *testvalue = 0xFFFFFFFF;
   
   if([bitDomain member:testvalue])
      NSLog(@"Passed member test");
   else
      NSLog(@"Failed member test");
   
   *testvalue = 0x8FFFFFFF;
   unsigned long long int rank = [bitDomain getRank:testvalue];
   
   NSLog(@"Rank of %u is %llu.\n", *testvalue, rank);
   NSLog(@"Value at rank %llu is %u", rank, *[bitDomain atRank:rank]);
   NSLog(@"Size of int: %lu\n",sizeof(unsigned int));
   NSLog(@"Size of long: %lu\n",sizeof(unsigned long int));
   NSLog(@"Size of long long: %lu\n",sizeof(unsigned long long int));
   
}

