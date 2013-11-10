//
//  main.m
//
//  Created by Eugene Kovalev on 10/2/13 with Prof. Laurent Michel.
/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgram.h>

id<ORIntMatrix> csv2matrix(NSString* filename, id<ORModel> tracker){
   NSMutableArray* matrix = [[NSMutableArray alloc] init];
   NSData *data = [NSData dataWithContentsOfFile:filename];
   NSString *string = [NSString stringWithUTF8String:[data bytes]];
   NSArray* transactionStrings = [string componentsSeparatedByString:@"\r"];
   for (NSString* transactionString in transactionStrings){
      //If its the first line, that's the name of the items, so it can be ignored.
      //printf("[%s]\n",[transactionString cStringUsingEncoding:NSASCIIStringEncoding]);
      if ([transactionString length] == 0) continue;
      if (![transactionString isEqualToString:[transactionStrings objectAtIndex:0]]){
         NSArray* transactionCharacters = [transactionString componentsSeparatedByString:@","];
         NSMutableArray* row = [[NSMutableArray alloc] init];
         for (NSString* itemString in transactionCharacters){
            if (![itemString isEqualToString:[transactionCharacters objectAtIndex:0]]){
               [row addObject:[[NSNumber alloc] initWithInt:itemString.intValue]];
            }
         }
         [matrix addObject:row];
      }
   }
   
   //Generate the ORIntMatrix
   id<ORIntMatrix> result = [ORFactory intMatrix:tracker
                                           range:RANGE(tracker, 0,((ORInt)[matrix count]-1))
                                                :RANGE(tracker, 0,((ORInt)[[matrix objectAtIndex:0] count]-1))];
   for (int r = 0; r < [matrix count]; r++){
      NSArray* row = [matrix objectAtIndex:r];
      for (int c = 0; c < [[matrix objectAtIndex:1] count]; c++){
         NSNumber* cell = [row objectAtIndex:c];
         [result set:[cell intValue] at:r :c];
      }
   }
   return result;
}

NSArray* csv2transactions(NSString* filename){
   NSMutableArray* transactions = [[NSMutableArray alloc] init];
   NSData *data = [NSData dataWithContentsOfFile:filename];
   NSString *string = [NSString stringWithUTF8String:[data bytes]];
   NSArray* transactionStrings = [string componentsSeparatedByString:@"\r"];
   for (NSString* transactionString in transactionStrings){
      if ([transactionString length] == 0) continue;
      //If its the first line, that's the name of the items, so it can be ignored.
      if (![transactionString isEqualToString:[transactionStrings objectAtIndex:0]]){
         NSArray* transactionCharacters = [transactionString componentsSeparatedByString:@","];
         [transactions addObject:[transactionCharacters objectAtIndex:0]];
      }
   }
   return transactions;
}

NSArray* csv2items(NSString* filename){
   NSMutableArray* items = [[NSMutableArray alloc] init];
   NSData *data = [NSData dataWithContentsOfFile:filename];
   NSString *string = [NSString stringWithUTF8String:[data bytes]];
   NSArray* transactionStrings = [string componentsSeparatedByString:@"\r"];
   NSString* transactionString = [transactionStrings objectAtIndex:0];
   NSArray* transactionCharacters = [transactionString componentsSeparatedByString:@","];
   for (NSString* itemString in transactionCharacters){
      if (![itemString isEqualToString:[transactionCharacters objectAtIndex:0]]){
         [items addObject:itemString];
      }
   }
   return items;
}

NSString* prettyTransaction(int transaction, NSArray* transactions, NSArray* items, id<ORIntMatrix> matrix){
   NSMutableString* result = [[NSMutableString alloc] init];
   [result appendFormat:@"%@ = {",[transactions objectAtIndex:transaction]];
   for (int i = 0; i < [items count] - 1; i++){
      int cellValue = [matrix at:transaction:i];
      if (cellValue == 1){
         [result appendFormat:@"%@,",[items objectAtIndex:i]];
      }
   }
   [result appendString:@"}"];
   return  result;
}

NSString* prettyItemset(id<ORIntArray> set, NSArray* items){
   NSMutableString* result = [[NSMutableString alloc] init];
   [result appendString:@"Frequent Itemset = {"];
   int count = 0;
   for (int i = 0; i < [items count]; i++){
      ORInt cellValue = [set at:i];
      if (cellValue == 1){
         [result appendFormat:@"%@,",[items objectAtIndex:i]];
         count++;
      }
   }
   [result appendFormat:@"} Set Size = %i",count];
   return  result;
}

int sumColumn(int column, int numRows, id<ORIntMatrix> matrix, NSArray* items){
   int sum = 0;
   for (int i = 0; i < numRows; i++){
      sum += [matrix at:i :column];
   }
   //NSLog(@"%@: %i", [items objectAtIndex:column],sum);
   return sum;
}

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      id<ORModel> model = [ORFactory createModel];
      id<ORIntRange> binary = RANGE(model, 0, 1);
      
      //Input Data
      NSString* file = @"test1.csv";
      NSArray* transactions;
      NSArray* items;
      id<ORIntMatrix> matrix;
      @autoreleasepool {
         matrix = csv2matrix(file, model);
         transactions = csv2transactions(file);
         items = csv2items(file);
      }
      
      ORInt numOfItems = (int)[items count];
      ORInt numOfTransactions = (int)[transactions count];
      id<ORIntRange> itemRange = RANGE(model, 0, numOfItems - 1);
      id<ORIntRange> transactionRange = RANGE(model, 0, numOfTransactions - 1);
      
      //Variables
      id<ORIntVarArray> itemset = [ORFactory intVarArray:model range:itemRange domain:binary];
      id<ORIntVarArray> trans = [ORFactory intVarArray:model range:transactionRange domain:binary];
      
      //A value is 1 in transactionsContainingItemsets iff that transaction contains all of the items in the itemset
      for (ORInt t = [transactionRange low]; t <= [transactionRange up]; t++){
         ORInt nbnz = 0;
         for(ORInt i = itemRange.low;i <= itemRange.up;i++)
            nbnz += ![matrix at:t :i];
         id<ORIntVarArray> nz = (id)[ORFactory idArray:model range:RANGE(model,0,nbnz-1)];
         nbnz = 0;
         for(ORInt i = itemRange.low;i <= itemRange.up;i++) {
            if ([matrix at:t :i]!=0) continue;
            nz[nbnz++] = itemset[i];
         }
         id<ORExpr> cov = [Sum(model, i, nz.range, nz[i]) eq:@0];
         [model add:[trans[t] eq:cov]];
      }
      
      //Sum of transactionsContainingItemset must be greater than the threshold
      //[model add:[Sum(model, k, transactionRange, [transactionsContainingItemset at:k]) gt:@(2)]];
      for(ORInt i =itemRange.low;i <= itemRange.up;i++) {
         ORInt nbnz = 0;
         for(ORInt t=transactionRange.low;t <= transactionRange.up; t++)
            nbnz += [matrix at:t :i];
         id<ORIntVarArray> nz = (id)[ORFactory idArray:model range:RANGE(model,0,nbnz-1)];
         nbnz = 0;
         for(ORInt t=transactionRange.low;t <= transactionRange.up; t++) {
            if ([matrix at:t :i] == 0) continue;
            nz[nbnz++] = trans[t];
         }
         //id<ORExpr> thr = Sum(model, t, transactionRange, [trans[t] and:@([matrix at:t :i])]);
         //id<ORExpr> thr = Sum(model, t, nz.range, nz[t]);
         //[model add:[itemset[i] imply:[thr geq:@2]]];
         [model add:[ORFactory hreify:model boolean:itemset[i] sumbool:nz geqi:2]];
      }
      
      [model add:[Sum(model, k, itemRange, [itemset at:k]) gt:@(0)]];
      
      id<CPProgram> cpp = [ORFactory createCPProgram:model];
      [cpp solveAll:
       ^() {
          [cpp labelArray: [model intVars]];
          id<ORIntArray> freqItemset = [ORFactory intArray:cpp range:itemset.range with:^ORInt(ORInt i) {
             return [cpp intValue:itemset[i]];
          }];
          
          NSLog(@"%@",prettyItemset(freqItemset, items));
       }];
      NSLog(@"Solver status: %@\n",cpp);
      NSLog(@"Statistics: %d - %d - %d",[[cpp explorer] nbFailures],[[cpp explorer] nbChoices],
            [[cpp engine] nbPropagation]);
      [cpp release];
      [ORFactory shutdown];
   }
   return 0;
}

