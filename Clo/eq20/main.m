/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>

#import "ORCmdLineArgs.h"

int main(int argc, const char * argv[])
{
   @autoreleasepool {
      ORCmdLineArgs* args = [ORCmdLineArgs newWith:argc argv:argv];
      [args measure:^struct ORResult(){
         id<ORModel> model = [ORFactory createModel];
         const ORInt nbC = 20;
         const ORInt nbV = 7;
         ORInt eqs[nbC][nbV+1] = {
            {876370, -16105, 62397, -6704, 43340, 95100, -68610, 58301},
            {533909, 51637, 67761, 95951, 3834, -96722, 59190, 15280},
            {915683, 1671, -34121, 10763, 80609, 42532, 93520, -33488},
            {129768, 71202, -11119, 73017, -38875, -14413, -29234, 72370},
            {752447, 8874, -58412, 73947, 17147, 62335, 16005, 8632},
            {90614, 85268, 54180, -18810, -48219, 6013, 78169, -79785},
            {1198280, -45086, 51830, -4578, 96120, 21231, 97919, 65651},
            {18465, -64919, 80460, 90840, -59624, -75542, 25145, -47935},
            {1503588, -43277, 43525, 92298, 58630, 92590, -9372, -60227},
            {1244857, -16835, 47385, 97715, -12640, 69028, 76212, -81102},
            {1410723, -60301, 31227, 93951, 73889, 81526, -72702, 68026},
            {25334, 94016, -82071, 35961, 66597, -30705, -44404, -38304},
            {277271, -67456, 84750, -51553, 21239, 81675, -99395, -4254},
            {249912, -85698, 29958, 57308, 48789, -78219, 4657, 34539},
            {373854, 85176, -95332, -1268, 57898, 15883, 50547, 83287},
            {740061, -10343, 87758, -11782, 19346, 70072, -36991, 44529},
            {146074, 49149, 52871, -7132, 56728, -33576, -49530, -62089},
            {251591, -60113, 29475, 34421, -76870, 62646, 29278, -15212},
            {22167, 87059, -29101, -5513, -21219, 22128, 7276, 57308},
            {821228, -76706, 98205, 23445, 67921, 24111, -48614, -41906}};
         
         id<ORIntRange> dom = RANGE(model,0,10);
         id<ORIntVarArray> x = [ORFactory intVarArray:model range:RANGE(model,1,7) domain:dom];
         for(ORInt i=0;i<nbC;i++) {
            ORInt* ri = eqs[i];
            [model add:[Sum(model, j, RANGE(model,1,nbV), [x[j] mul:@(ri[j])]) eq: @(eqs[i][0])]
            annotation: ValueConsistency];
         }
         //NSLog(@"MODEL: %@",model);
         id<CPProgram> cp = [args makeProgram:model];
         id<CPHeuristic> h = [args makeHeuristic:cp restricted:x];
         __block BOOL found = NO;
         [cp solveAll:^{
            NSLog(@"concrete: %@",[[cp engine] model]);
            [cp labelHeuristic:h];
            //[cp labelArray:x ];//  orderedBy:^ORFloat(ORInt i) { return [x[i] domsize];}];
            [cp labelArray:x orderedBy:^ORFloat(ORInt i) { return [cp domsize:x[i]];}];
            id<ORIntArray> sx = [ORFactory intArray:cp range:[x range] with:^ORInt(ORInt i) { return [cp intValue:x[i]];}];
            NSLog(@"Sol: %@",sx);
            found = YES;
         }];
         NSLog(@"Solver status: %@\n",cp);
         struct ORResult res = REPORT(found, [[cp explorer] nbFailures], [[cp explorer] nbChoices], [[cp engine] nbPropagation]);
         [cp release];
         [ORFactory shutdown];
         return res;
      }];
   }
   return 0;
}

