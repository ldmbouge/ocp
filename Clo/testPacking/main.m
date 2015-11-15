/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>

#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>

#import <ORProgram/ORProgramFactory.h>

int main (int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> R  = RANGE(model,0,4);
   id<ORIntRange> D  = RANGE(model,0,1);
   id<ORIntVarArray> item = [ORFactory intVarArray:model range: R domain: D];
   id<ORIntArray> itemSize = [ORFactory intArray: model range: R value: 0];
   id<ORIntVarArray> binSize = [ORFactory intVarArray:model range: RANGE(model,0,1) domain: RANGE(model,12,27)];
   [itemSize set: 9 at: 4];
   [itemSize set: 9 at: 3];
   [itemSize set: 5 at: 2];
   [itemSize set: 2 at: 1];
   [itemSize set: 1 at: 0];
   [model add: [ORFactory packing: item itemSize: itemSize load: binSize]];

   NSLog(@"ORIGINAL: %@",model);
   id<CPProgram> cp = [ORFactory createCPProgram: model];

   [cp solve:
    ^ {
       [cp labelArray: item];
       NSLog(@"%@",item);
       NSLog(@"%@",binSize);
       printf("\n");
    }
    ];
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   return 0;
}

