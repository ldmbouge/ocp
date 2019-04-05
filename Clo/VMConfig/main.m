/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORProgram/ORProgram.h>

int main (int argc, const char * argv[])
{
   id<ORModel> model = [ORFactory createModel];
   id<ORIntRange> MODS  = RANGE(model,0,511);
   id<ORIntRange> HOSTS  = RANGE(model,0,63);
   id<ORIntVarArray> modules = [ORFactory intVarArray:model range: MODS domain:HOSTS];
   id<ORIntArray> modRAM = [ORFactory intArray: model range:MODS value:0];
//   id<ORIntVarArray> hostRAM = [ORFactory intVarArray:model range:HOSTS domain: RANGE(model,12,120)];

   id<ORIntVarArray> hostRAM = [ORFactory intVarArray:model range:HOSTS with: ^id<ORIntVar>(ORInt x){
      ORInt i = (((x+1)/8)+1)*16;
      return [ORFactory intVar:model domain:RANGE(model,i+16,i+96)];}];
   
   for(ORUInt i=0;i<512; i++)
      [modRAM set:(i%16+1)*2 at:i];
   
   [model add: [ORFactory packing:model item:modules itemSize:modRAM load:hostRAM]];
   
//   NSLog(@"ORIGINAL: %@",model);
   id<CPProgram> cp = [ORFactory createCPProgram: model];
   
   [cp solve:^ {
       [cp labelArray: modules];
      printf("VM Assignments: [");
       for(id<ORIntVar> mod in modules)
          printf("\t%d, ",[cp intValue:mod]);
      printf("]\n");
      printf("VM Resource Usage: [");
      for(id<ORIntVar> resource in hostRAM)
         printf("\t%d, ",[cp intValue:resource]);
       printf("]\n");
    }
    ];
   NSLog(@"Solver status: %@\n",cp);
   NSLog(@"Quitting");
   return 0;
}

