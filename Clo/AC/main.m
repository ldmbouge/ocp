//
//  main.m
//  SafetyPlanner
//
//  Created by Matthew Desmarais on 4/19/16.
//  Copyright © 2016 Laurent Michel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>

#define REGION_COUNT 161
#define AIRCRAFT_COUNT 12
#define TIME_STEPS 20

#define RAMP_ID 161
#define NOGO_PENALTY 100

/* These are the steps in the BDL paths
 */
#define STEP(start) (steps[((start)-1)*2+1])
const int steps[REGION_COUNT * 2] = {
   1, 107,
   2, 91,
   3, 108,
   4, 92,
   5, 108,
   6, 93,
   7, 110,
   8, 94,
   9, 111,
   10, 95,
   11, 101,
   12, 96,
   13, 0,
   14, 0,
   15, 0,
   16, 0,
   17, 0,
   18, 0,
   19, 0,
   20, 117,
   21, 55,
   22, 31,
   23, 59,
   24, 37,
   25, 55,
   26, 38,
   27, 50,
   28, 40,
   29, 48,
   30, 48,
   31, 35,
   32, 0,
   33, 0,
   34, 0,
   35, 36,
   36, 120,
   37, 120,
   38, 39,
   39, 122,
   40, 122,
   41, 0,
   42, 0,
   43, 0,
   44, 0,
   45, 0,
   46, 0,
   47, 0,
   48, 130,
   49, 0,
   50, 51,
   51, 131,
   52, 0,
   53, 0,
   54, 134,
   55, 56,
   56, 57,
   57, 54,
   58, 0,
   59, 60,
   60, 61,
   61, 138,
   62, 0,
   63, 0,
   64, 0,
   65, 0,
   66, 138,
   67, 138,
   68, 139,
   69, 139,
   70, 0,
   71, 0,
   72, 0,
   73, 0,
   74, 66,
   75, 67,
   76, 68,
   77, 69,
   78, 0,
   79, 0,
   80, 0,
   81, 0,
   82, 74,
   83, 75,
   84, 76,
   85, 77,
   86, 0,
   87, 142,
   88, 142,
   89, 0,
   90, 0,
   91, 82,
   92, 83,
   93, 84,
   94, 85,
   95, 87,
   96, 88,
   97, 0,
   98, 0,
   99, 0,
   100, 144,
   101, 100,
   102, 0,
   103, 0,
   104, 0,
   105, 0,
   106, 0,
   107, 149,
   108, 149,
   109, 0,
   110, 150,
   111, 112,
   112, 113,
   113, 147,
   114, 0,
   115, 0,
   116, 0,
   117, 118,
   118, 119,
   119, 120,
   120, 121,
   121, 123,
   122, 123,
   123, 125,
   124, 0,
   125, 161,
   126, 0,
   127, 0,
   128, 0,
   129, 0,
   130, 159,
   131, 159,
   132, 0,
   133, 159,
   134, 135,
   135, 133,
   136, 158,
   137, 0,
   138, 135,
   139, 136,
   140, 0,
   141, 156,
   142, 141,
   143, 0,
   144, 156,
   145, 0,
   146, 156,
   147, 146,
   148, 0,
   149, 150,
   150, 151,
   151, 147,
   152, 0,
   153, 0,
   154, 0,
   155, 0,
   156, 157,
   157, 158,
   158, 159,
   159, 160,
   160, 161,
   161, -1
};

unsigned int distanceFromRamp(int regionID) {
   int location = regionID;
   unsigned int distance = 0;
   while (location != RAMP_ID) {
      if (location == 0) {
         return NOGO_PENALTY;
      }
      
      distance++;
      location = STEP(location);
   }
   return distance;
}

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      id<ORModel> mdl = [ORFactory createModel];
      
      id<ORIntRange> aircraft = RANGE(mdl, 0, AIRCRAFT_COUNT);
      id<ORIntRange> regions = RANGE(mdl, 1, REGION_COUNT);
      id<ORIntRange> t = RANGE(mdl, 1, TIME_STEPS);
      id<ORIntVarMatrix> aircraftLocationsAtTime = [ORFactory intVarMatrix: mdl range:t :regions domain: aircraft];
      
      // Establish that 0 may appear in many regions, but each
      // aircraft may appear in only 1.
      NSMutableArray * lowerArray = [NSMutableArray array];
      for (int i=0; i<AIRCRAFT_COUNT+1; i++) {
         [lowerArray addObject: @(0)];
      }
      NSMutableArray * upperArray = [NSMutableArray array];
      [upperArray addObject: @(REGION_COUNT)];
      for (int i=1; i<AIRCRAFT_COUNT+1; i++) {
         [upperArray addObject: @(1)];
      }
      id<ORIntArray> lowerBounds = [ORFactory intArray: mdl array: lowerArray];
      id<ORIntArray> upperBounds = [ORFactory intArray: mdl array: upperArray];
      for (int i=1; i<TIME_STEPS+1; i++) {
         id<ORIntVarArray> regionsAtTime = All(mdl, ORIntVar, r, regions, [aircraftLocationsAtTime at: i :r]);
         id<ORConstraint> cardinalityConstraint = [ORFactory cardinality: regionsAtTime low: lowerBounds up: upperBounds];
         [mdl add: cardinalityConstraint];
      }
      
      // Establish the paths
      for (int time=1; time<TIME_STEPS; time++) {
         for (int region=1; region<REGION_COUNT+1; region++) {
            id<ORIntVar> thisPosition = [aircraftLocationsAtTime at: time :region];
            int nextRegion = STEP(region);
            if (nextRegion > 0) {
               id<ORIntVar> thisPositionNextTime = [aircraftLocationsAtTime at: time+1 :region];
               id<ORIntVar> nextPositionNextTime = [aircraftLocationsAtTime at: time+1 :nextRegion];
               id<ORConstraint> nextStep = [[thisPosition geq: @(1)] //[ORFactory integer:mdl value:1]]
                                            imply: [[thisPositionNextTime eq: thisPosition]
                                                    lor: [nextPositionNextTime eq: thisPosition]]];
               [mdl add: nextStep];
            } else if (nextRegion == 0) {
               [mdl add: [ORFactory equalc: mdl
                                       var: [aircraftLocationsAtTime at: time :region]
                                        to: 0]];
            }
         }
      }
      
      // If all of the regions that feed a region are empty at some time, then that region must be empty
      // at the next time slot.
      int feeders[REGION_COUNT][REGION_COUNT];
      int feederLengths[REGION_COUNT];
      for (int region=1; region<=REGION_COUNT; region++) {
         feederLengths[region] = 0;
      }
      for (int region=1; region<=REGION_COUNT; region++) {
         int nextRegion = STEP(region);
         if (nextRegion > 0) {
            feeders[nextRegion][feederLengths[nextRegion]++] = region;
         }
      }
      //        for (int region=1; region<=REGION_COUNT; region++) {
      //            NSLog(@"Region: %d", region);
      //            for (int i=0; i<feederLengths[region]; i++) {
      //                NSLog(@"Feeder: %d", feeders[region][i]);
      //            }
      //        }
      
      for (int time=2; time<=TIME_STEPS; time++) {
         for (int region=1; region<REGION_COUNT+1; region++) {
            id<ORIntVar> thisPosition = [aircraftLocationsAtTime at: time :region];
            if (feederLengths[region] > 0) {
               id<ORRelation> feedersEmpty = [[aircraftLocationsAtTime at: time-1 :feeders[region][0]] eq: @(0)];
               for (int feederIndex=1; feederIndex<feederLengths[region]; feederIndex++) {
                  id<ORRelation> nextFeederEmpty = [[aircraftLocationsAtTime at: time-1 :feeders[region][feederIndex]] eq: @(0)];
                  feedersEmpty = [feedersEmpty land: nextFeederEmpty];
               }
               id<ORConstraint> emptyFeeders = [feedersEmpty imply: [thisPosition eq: @(0)]];
               //                    NSLog(@"emptyFeeders: %@", emptyFeeders);
               [mdl add: emptyFeeders];
            }
         }
      }
      
      // Our objective function is the sum of the distances from the ramp.
      id<ORExpr> objective = [ORFactory sum: mdl over: t over: regions
                                   suchThat: ^ORBool(ORInt time, ORInt region) {
                                      int distance = distanceFromRamp(region);
                                      return distance != MAXINT;
                                   }
                                         of: ^id<ORExpr>(ORInt time, ORInt region) {
                                            return [[[aircraftLocationsAtTime at:time :region]
                                                     min: @(1)]
                                                    mul: @(distanceFromRamp(region))];
                                         }
                              ];
      [mdl minimize: objective];
      
      // Setup the aircraft starting locations
      for (int region=1; region<=12; region++) {
         [mdl add: [ORFactory equalc: mdl var: [aircraftLocationsAtTime at: 1 :region] to: region]];
      }
      id<ORIntVarArray> fx = [mdl intVars];
      
      //        NSLog(@"Model: %@", mdl);
      
      id<CPProgram> cp = [ORFactory createCPProgram: mdl];
      //id<CPProgram> cp = [ORFactory createCPParProgram:mdl nb:4 with:[ORSemDFSController proto]];
      [cp solve: ^{
         NSLog(@"Searching ...");
         //            [cp labelArrayFF:[mdl intVars]];
         [cp labelArray: fx orderedBy: ^ORDouble(ORInt v) {
            int region = (v % REGION_COUNT) + 1;
            int distance = distanceFromRamp(region);
            //                NSLog(@"Ordering %d(%d) as %d", region, v, distance);
            if (distance == NOGO_PENALTY) {
               return NOGO_PENALTY;
            } else {
               return distance;
            }
         }];
         id<ORSolution> sol = [cp captureSolution];
         NSLog(@"SOLUTION:%@", [sol objectiveValue]);
      }
       ];//end of solve
      
      id<ORSolution> optimalSolution = [[cp solutionPool] best];
      for (int time=[t low]; time<=[t up]; time++) {
         for (int region=[regions low]; region<[regions up]; region++) {
            printf("%d,", [[optimalSolution value: [aircraftLocationsAtTime at:time :region]] intValue]);
         }
         printf("%d\n", [[optimalSolution value: [aircraftLocationsAtTime at:time :[regions up]]] intValue]);
      }
   }
   return 0;
}
