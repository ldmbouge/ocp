//
//  main.m
//  progressive
//
//  Created by Pascal Van Hentenryck on 7/14/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORSet.h>
#import <ORFoundation/ORArray.h>
#import <ORFoundation/ORFactory.h>
#import "objcp/CPFactory.h"
#import <objcp/CP.h>

int main(int argc, const char * argv[])
{
   ORInt nbConfigs = 6;
   ORRange Configs = (ORRange){1,nbConfigs};
   ORInt choiceConfig = 1;
  
   ORRange Hosts = (ORRange){1,13};
   ORRange Guests = (ORRange){1,29};
   ORInt nbPeriods = 6;
   ORRange Periods = (ORRange){1,nbPeriods};
   
   id<CP> cp = [CPFactory createSolver];
   
   id<ORIntSetArray> config = [ORFactory intSetArray: cp range: Configs];
   config[1] = COLLECT(cp,i,RANGE(1,12),i);
   [config[1] insert: 16];
   config[2] = COLLECT(cp,i,RANGE(1,13),i);
   config[3] = COLLECT(cp,i,RANGE(3,13),i);
   [config[3] insert: 1];
   [config[3] insert: 19];
   config[4] = COLLECT(cp,i,RANGE(3,13),i);
   [config[4] insert: 25];
   [config[4] insert: 26];
   config[5] = COLLECT(cp,i,RANGE(1,11),i);
   [config[5] insert: 19];
   [config[5] insert: 21];
   config[6] = COLLECT(cp,i,RANGE(1,9),i);
   for(ORInt i = 16; i <= 19; i++)
      [config[6] insert: i];
   
   NSLog(@"%@",config);
   
   FILE* dta = fopen("progressive.txt","r");
   int a, b, c;
   fscanf(dta, "%d",&a);
   fscanf(dta, "%d",&b);
   fscanf(dta, "%d",&c);
   printf("<%d,%d,%d>\n",a,b,c);

   @autoreleasepool {
       
       // insert code here...
       NSLog(@"Hello, World!");
       
   }
    return 0;
}

