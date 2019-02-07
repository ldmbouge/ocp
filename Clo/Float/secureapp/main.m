//
//  main.m
//  security_app
//
//  Created by zitoun on 1/22/19.
//

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/ORProgramFactory.h>
#import <objcp/CPFactory.h>
//#import "../ORModeling/ORLinearize.h"
//#import "../ORModeling/ORFlatten.h"
//#import "ORRunnable.h"
//#import "ORLogicBenders.h"
//#import "SSCPLPInstanceParser.h"
//#import "CPEngineI.h"
//#import "CPRunnable.h"
//#import "MIPSolverI.h"
//#import "MIPRunnable.h"

#define MAX_PATH 10
#define alpha0 10
#define alpha1 10
#define alpha2 0.01

@interface Queue : NSObject  {
   @package
   ORInt      _mxs;
   ORInt*     _tab;
   ORInt    _enter;
   ORInt     _exit;
   ORInt     _mask;
}

-(id) initQueue: (ORInt) sz;
-(ORBool)empty;
-(void)enQueue:(int)obj;
-(id)deQueue;
@end

@interface NSMutableArray (Queue)

- (void) enqueue: (id)item;
- (id) dequeue;
- (BOOL) empty;
- (id) peek;

@end

@implementation NSMutableArray (Queue)

- (void) enqueue: (id)item {
   [self addObject:item];
}

- (id) dequeue {
   id item = nil;
   if ([self count] != 0) {
      item = [[[self objectAtIndex:0] retain] autorelease];
      [self removeObjectAtIndex:0];
   }
   return item;
}

- (id) peek {
   id item = nil;
   if ([self count] != 0) {
      item = [[[self objectAtIndex:0] retain] autorelease];
   }
   return item;
}

- (BOOL) empty
{
   return [self count] == 0;
}
@end



@interface Graph : NSObject
{
   ORInt _nodes;
   NSMutableArray* _lists;
}


-(id) initGraph;
-(ORInt) size;
-(void) addAdjacency:(NSArray*)l;
-(void) addAdjacenyWithObject:(id) firstN,...;
+(NSMutableArray*) bfs : (Graph*) graph source:(ORInt) startVertex dest:(ORInt) destVertex maxpaths:(ORInt) numberPaths;
@end


@implementation Graph

-(id) initGraph
{
   self = [super init];
   _nodes = 0;
   _lists = [[NSMutableArray alloc] init];
   return self;
}
-(void) dealloc
{
   [_lists release];
   [super dealloc];
}
-(ORInt) size
{
   return _nodes;
}
-(NSMutableArray*) edges:(ORInt)node
{
   return _lists[node];
}
-(void) addAdjacency:(NSArray*)l
{
   [_lists addObject:l];
   _nodes++;
}
-(void) addAdjacenyWithObject:(id) firstN,...
{
   NSMutableArray* list = [[NSMutableArray alloc] init];
   va_list args;
   va_start(args, firstN);
   for (id arg = firstN; arg != nil; arg = va_arg(args, id))
   {
      [list addObject:arg];
   }
   va_end(args);
   [_lists addObject:list];
   _nodes++;
}
-(NSString*)description
{
   NSMutableString* res = [NSMutableString stringWithFormat:@"G: #%d [",_nodes];
   for(ORInt i = 0; i < [_lists count] ; i++){
      [res appendFormat:@"\n%d : [ ",i];
      for (ORInt j = 0; j < [_lists[i] count]; j++){
         [res appendFormat:@"%@ ",[_lists[i] objectAtIndex:j]];
      }
      [res appendString:@"]"];
   }
   [res appendString:@"]"];
   return res;
}
+(NSMutableArray*) bfs : (Graph*) graph source:(ORInt) startVertex dest:(ORInt) dstVertex maxpaths:(ORInt) nbP
{
   NSMutableArray* allpaths = [[NSMutableArray alloc] init];
   NSMutableArray* q = [[NSMutableArray alloc] init];
   NSMutableArray* path = [[NSMutableArray alloc] initWithObjects:@(startVertex), nil];
   
   [q enqueue:path];
   while(![q empty]){
      path = [q dequeue];
      ORInt last = [[path lastObject] intValue];
      if(last == dstVertex) {
         //            NSLog(@"%@",path);
         [allpaths addObject:path];
         if([allpaths count] == 10) break;
      }
      
      NSMutableArray* nbhood = graph->_lists[last];
      for (int i = 0; i < [nbhood count]; i++) {
         if (![path containsObject:nbhood[i]]) {
            NSMutableArray* p = [[NSMutableArray alloc] initWithArray:path];
            [p addObject:nbhood[i]];
            [q enqueue:p];
         }
      }
   }
   
   return allpaths;
}
//all device starting by h
+(NSMutableArray*) getEC:(NSArray*)device with:(NSDictionary*)map
{
   NSMutableArray* res = [[NSMutableArray alloc] init];
   for(ORInt i = 0; i < [device count]; i++){
      if([device[i] characterAtIndex:0] == 'h'){
         [res addObject:[map valueForKey:device[i]]];
      }
   }
   return res;
}
//all device starting g or s
+(NSMutableArray*) getNetworkDevice:(NSArray*)device with:(NSDictionary*)map
{
   NSMutableArray* res = [[NSMutableArray alloc] init];
   for(ORInt i = 0; i < [device count]; i++){
      if([device[i] characterAtIndex:0] == 'g' || [device[i] characterAtIndex:0] == 's' ){
         [res addObject:[map valueForKey:device[i]]];
      }
   }
   return res;
}
@end

//[hzi] for now I just decompose the different traffic as separate structure,
//I should aggregate those structure

int main(int argc, const char * argv[]) {
   @autoreleasepool {
      //-----------DEFINITION OF THE INSTANCE----------//
      NSArray* device = @[@"h8", @"h9", @"h2", @"h3", @"h1", @"h6", @"h7", @"h4", @"h5", @"sa7", @"sa5", @"sa20", @"g2", @"g1", @"sa9", @"sa8", @"sc4", @"sc1", @"sa6", @"sc3", @"sc2", @"h10", @"h11", @"h12", @"h13", @"h14", @"h15", @"h16", @"sa19", @"sa18", @"sa17", @"sa16", @"sa15", @"sa14", @"sa13", @"sa12", @"sa11", @"sa10"];
      NSMutableDictionary* device2ID = [[NSMutableDictionary alloc] init];
      for(ORInt i = 0; i < [device count];i++){
         [device2ID setObject:@(i) forKey:device[i]];
      }
      NSArray* flowWithA = @[@[@21,@1],@[@7,@3],@[@12,@27],@[@2,@4],@[@3,@7],@[@13,@7],@[@6,@0],@[@13,@4],@[@4,@13],@[@7,@13],@[@23,@22],@[@22,@23],@[@23,@12],@[@13,@0],@[@1,@21],@[@27,@12],@[@13,@8],@[@8,@13],@[@4,@2],@[@0,@13],@[@8,@5],@[@24,@12],@[@5,@8],@[@0,@6],@[@27,@26],@[@12,@23],@[@1,@12],@[@26,@27],@[@24,@25],@[@12,@1],@[@25,@24],@[@12,@24]];
      NSArray* flowWithB = @[@[@7,@3],@[@24,@25],@[@8,@5],@[@2,@4],@[@25,@2],@[@2,@21],@[@6,@3],@[@27,@26],@[@22,@23],@[@26,@27],@[@2,@5],@[@23,@22],@[@1,@21],@[@22,@3],@[@3,@7],@[@26,@3],@[@0,@6],@[@3,@6],@[@2,@25],@[@5,@8],@[@6,@0],@[@4,@2],@[@3,@22],@[@5,@2],@[@3,@26],@[@25,@24],@[@21,@1],@[@21,@2]];
      NSMutableDictionary* demandA = [[NSMutableDictionary alloc] initWithCapacity:[flowWithA count]];
      NSMutableDictionary* demandB = [[NSMutableDictionary alloc] initWithCapacity:[flowWithB count]];
      for(NSArray* flow in flowWithA){
         [demandA setObject:@(1) forKey:flow];
      }
      for(NSArray* flow in flowWithB){
         [demandB setObject:@(1) forKey:flow];
      }
      Graph *g = [[Graph alloc] initGraph];
      [g addAdjacency:@[@35]]; //node 0 -> 35
      [g addAdjacency:@[@32]]; //node 1 -> 32
      [g addAdjacency:@[@17]]; //node 2 -> 17
      [g addAdjacency:@[@15]]; //node 3 -> 15
      [g addAdjacency:@[@17]]; //node 4 -> 17
      [g addAdjacency:@[@36]]; //node 5 -> 36
      [g addAdjacency:@[@35]]; //node 6 -> 35
      [g addAdjacency:@[@15]]; //node 7 -> 15
      [g addAdjacency:@[@36]]; //node 8 -> 36
      [g addAdjacency:@[@10,@30,@34,@14]]; //node 9 -> { 10 , 30 , 34 , 14 }
      [g addAdjacency:@[@9,@15,@20,@17]]; //node 10 -> { 9 , 15 , 20 , 17 }
      [g addAdjacency:@[@26,@27,@29,@30]]; //node 11 -> { 26 , 27 , 29 , 30 }
      [g addAdjacency:@[@19,@20]]; //node 12 ->  { 19 , 20 }
      [g addAdjacency:@[@19,@20]]; //node 13 ->  { 19 , 20 }
      [g addAdjacency:@[@9,@35,@20,@36]]; //node 14 ->  { 9, 35 , 20 , 36 }
      [g addAdjacency:@[@18,@3,@10,@7]]; //node 15 -> { 18 , 3 , 10 , 7}
      [g addAdjacency:@[@33,@18,@37,@29]]; //node 16 -> { 33 , 18 , 37 , 29 }
      [g addAdjacency:@[@10,@18,@4,@2]]; //node 17 -> { 10 , 18 , 4 , 2  }
      [g addAdjacency:@[@16,@17,@19,@15]]; //node 18 -> { 16 , 17 , 19 , 15 }
      [g addAdjacency:@[@33,@37,@12,@13,@18,@29]]; //node 19 -> { 33 , 37 , 12 , 13 , 18 , 29 }
      [g addAdjacency:@[@34,@10,@12,@13,@14,@30]]; //node 20 -> { 34 , 10 , 12 , 13 , 18 , 30 }
      [g addAdjacency:@[@32]]; //node 21 -> 32
      [g addAdjacency:@[@31]]; //node 22 -> 31
      [g addAdjacency:@[@31]]; //node 23 -> 31
      [g addAdjacency:@[@28]]; //node 24 -> 28
      [g addAdjacency:@[@28]]; //node 25 -> 28
      [g addAdjacency:@[@11]]; //node 26 -> 11
      [g addAdjacency:@[@11]]; //node 27 -> 11
      [g addAdjacency:@[@24,@25,@29,@30]]; //node 28 -> { 24 , 25 , 29 , 30 }
      [g addAdjacency:@[@11,@16,@19,@28]]; //node 29 -> { 11 , 16 , 19 , 28 }
      [g addAdjacency:@[@20,@11,@28,@9]]; //node 30 -> { 20 , 11 , 28 , 9 }
      [g addAdjacency:@[@33,@34,@22,@23]]; //node 31 -> { 33 , 34 , 22 , 23 }
      [g addAdjacency:@[@1,@34,@21,@33]]; //node 32 -> { 1 , 34 , 21 , 33 }
      [g addAdjacency:@[@32,@16,@19,@31]]; //node 33 -> { 32 , 16 , 19 , 31 }
      [g addAdjacency:@[@32,@9,@20,@31]]; //node 34 -> { 32 , 9 , 20 , 31 }
      [g addAdjacency:@[@0,@6,@37,@14]]; //node 35 ->  { 0 , 6 , 37 , 14 }
      [g addAdjacency:@[@8,@5,@14,@37]]; //node 36 ->  { 8 , 5 , 14 , 37 }
      [g addAdjacency:@[@16,@19,@35,@36]]; //node 37 ->  { 16 , 19 , 35 , 36}
      //----------END OF THE INSTANCE-----------//
      NSLog(@"%@",g);
      //all two successive values are src-dst pair
      //Thoses pairs are sorted in increasing order.
      //4-13 pair, means, 13-4 is a desiredFlow too
      //        allpath should be computed for each pair in the desiredFlows
      //        if we compute 4-13, it's easy to get 13-4 because the graph is without direction just reverse the 4-13 it's enought
      NSArray* desiredFlowsOfA = @[@4,@13,@7,@13,@8,@13,@0,@13,@1,@12,@12,@23,@12,@24,@12,@27,@2,@4,@3,@7,@5,@8,@0,@6,@1,@21,@22,@23,@24,@25,@26,@27];
      NSArray* desiredFlowsOfB = @[@2,@4,@3,@7,@5,@8,@0,@6,@1,@21,@22,@23,@24,@25,@26,@27,@2,@5,@2,@21,@2,@25,@2,@21,@2,@25,@3,@6,@3,@22,@3,@26];
      NSArray* ec = [Graph getEC:device with:device2ID];
      NSArray* network = [Graph getNetworkDevice:device with:device2ID];
      
      
      NSMutableArray* allpathA = [[NSMutableArray alloc] init];
      NSMutableArray* allpathB = [[NSMutableArray alloc] init];
      
      ORInt src;
      ORInt dst;
      NSMutableArray* tmp;
      id<ORModel> model = [ORFactory createModel];
      ORInt i = 0;
      ORInt shift = (ORInt)[desiredFlowsOfA count]/2;
      //Still need to deal with inverse path D-S
      id<ORIdArray> isFlowA = [ORFactory idArray:model range:RANGE(model, 0, (ORInt)[desiredFlowsOfA count] - 1)];
      id<ORIdArray> flowA = [ORFactory idArray:model range:RANGE(model, 0, (ORInt)[desiredFlowsOfA count] - 1)];
      for(ORInt s = 0,d = s + 1; d < [desiredFlowsOfA count]; s+=2, d+=2){
         src = [desiredFlowsOfA[s] intValue];
         dst = [desiredFlowsOfA[d] intValue];
         tmp = [Graph bfs:g source:src dest:dst maxpaths:MAX_PATH];
         [allpathA addObject:tmp];
         isFlowA[i] = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) domain:RANGE(model, 0, 1) names:[NSString stringWithFormat:@"isFlowA[%d]",i]];
         flowA[i] = [ORFactory realVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) low:0.0 up:100.0 names:[NSString stringWithFormat:@"flowA[%d]",i]];
         //inverse dst and src
         isFlowA[i+shift] = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) domain:RANGE(model, 0, 1) names:[NSString stringWithFormat:@"isFlowA[%d]",i+shift]];
         flowA[i+shift] = [ORFactory realVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) low:0.0 up:100.0 names:[NSString stringWithFormat:@"flowA[%d]",i+shift]];
         i++;
      }
      
      i = 0;
      shift = (ORInt)[desiredFlowsOfB count]/2;
      ORInt nbPathB = 0;
      id<ORIdArray> isFlowB = [ORFactory idArray:model range:RANGE(model, 0, (ORInt)[desiredFlowsOfB count] - 1)];
      id<ORIdArray> flowB = [ORFactory idArray:model range:RANGE(model, 0, (ORInt)[desiredFlowsOfB count] - 1)];
      for(ORInt s = 0,d = s + 1; d < [desiredFlowsOfB count]; s+=2, d+=2){
         src = [desiredFlowsOfB[s] intValue];
         dst = [desiredFlowsOfB[d] intValue];
         tmp = [Graph bfs:g source:src dest:dst maxpaths:MAX_PATH];
         nbPathB += [tmp count] * 2;
         [allpathB addObject:tmp];
         isFlowB[i] = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) domain:RANGE(model, 0, 1) names:[NSString stringWithFormat:@"isFlowB[%d]",i]];
         flowB[i] = [ORFactory realVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) low:0.0 up:100.0 names:[NSString stringWithFormat:@"flowB[%d]",i]];
         //inverse dst and src
         isFlowB[i+shift] = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) domain:RANGE(model, 0, 1) names:[NSString stringWithFormat:@"isFlowB[%d]",i+shift]];
         flowB[i+shift] = [ORFactory realVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) low:0.0 up:100.0 names:[NSString stringWithFormat:@"flowB[%d]",i+shift]];
         i++;
      }
      
      NSMutableDictionary* P_edgesA = [[NSMutableDictionary alloc] init];
      NSMutableDictionary* P_edgesB = [[NSMutableDictionary alloc] init];
      
      //Just a dictionary to get all paths where a edges belong
      for(ORInt i = 0; i < [allpathA count]; i++){
         for(ORInt j = 0; j < [allpathA[i] count]; j++){
            NSMutableArray* path = allpathA[i][j];
            for (ORInt s = 0, d = s + 1; d < [path count]; s++, d++) {
               NSArray* key = @[path[s],path[d]];
               NSMutableArray* ps = [P_edgesA objectForKey:key];
               if(ps == nil){
                  ps = [[NSMutableArray alloc] init];
               }
               [ps addObject:@[@(i),@(j)]];
               [P_edgesA setObject:ps forKey:key];
            }
         }
      }
      for(ORInt i = 0; i < [allpathB count]; i++){
         for(ORInt j = 0; j < [allpathB[i] count]; j++){
            NSMutableArray* path = allpathB[i][j];
            for (ORInt s = 0, d = s + 1; d < [path count]; s++, d++) {
               NSArray* key = @[path[s],path[d]];
               NSMutableArray* ps = [P_edgesB objectForKey:key];
               if(ps == nil){
                  ps = [[NSMutableArray alloc] init];
               }
               [ps addObject:@[@(i),@(j)]];
               [P_edgesB setObject:ps forKey:key];
            }
         }
      }
      
      
      //        Just an array to get all paths where a node belong Ex: P_nodesA[0] -> [[ind0,ind1],[],[]] will return an array of array of indices
      //      each array of indices correspond to a path in allPath[ind0][ind1]
      NSMutableArray* P_nodesA = [[NSMutableArray alloc] initWithCapacity:[g size]];
      NSMutableArray* P_nodesB = [[NSMutableArray alloc] initWithCapacity:[g size]];
      for(ORInt i = 0; i < [g size]; i++){
         P_nodesA[i] = [[NSMutableArray alloc] init];
         P_nodesB[i] = [[NSMutableArray alloc] init];
      }
      for(ORInt i = 0; i < [allpathA count]; i++){
         for(ORInt j = 0; j < [allpathA[i] count]; j++){
            for(ORInt k = 0; k < [allpathA[i][j] count]; k++){
               ORInt node = [allpathA[i][j][k] intValue];
               [P_nodesA[node] addObject:@[@(i),@(j)]];
            }
         }
      }
      for(ORInt i = 0; i < [allpathB count]; i++){
         for(ORInt j = 0; j < [allpathB[i] count]; j++){
            for(ORInt k = 0; k < [allpathB[i][j] count]; k++){
               ORInt node = [allpathB[i][j][k] intValue];
               if(P_nodesB[node] == nil){
                  P_nodesB[node] = [[NSMutableArray alloc] init];
               }
               [P_nodesB[node] addObject:@[@(i),@(j)]];
            }
         }
      }
      
      id<ORIntVarArray> equiv = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)([ec count] * [network count])) domain:RANGE(model, 0, 1) names:@"equiv"];
      //        //equivClasses not used in original model
      id<ORIntVarArray> pathLensA = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)[flowA count]) domain:RANGE(model,0,MAXINT) names:@"pathLensA"];
      id<ORIntVarArray> pathLensB = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)[flowA count]) domain:RANGE(model,0,MAXINT) names:@"pathLensB"];
      id<ORIntVar> pathLens = [ORFactory intVar:model domain:RANGE(model, 0, MAXINT) name:@"pathLens"];
      id<ORIntVarArray> load = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt) [network count]- 1) domain:RANGE(model,0,MAXINT) names:@"load"];
      id<ORIntVar> loadSquareSum = [ORFactory intVar:model  domain:RANGE(model, 0, MAXINT) name:@"loadSquareSum"];
      
      
      for(ORInt i = 0; i < [isFlowA count]; i++){
         for(ORInt j = 0; j < [isFlowA[i] count]; j++){
            [model add:[[isFlowA[i][j] eq:@(0)] imply:[flowA[i][j] eq:@(0.0)]]];
            [model add:[[isFlowA[i][j] eq:@(1)] imply:[flowA[i][j] geq:@(1.0)]]];
         }
         [model add:[ORFactory sumbool:model array:isFlowA[i] eqi:1]];
      }
      
      for(ORInt i = 0; i < [isFlowB count]; i++){
         for(ORInt j = 0; j < [isFlowB[i] count]; j++){
            [model add:[[isFlowB[i][j] eq:@(0)] imply:[flowB[i][j] eq:@(0.0)]]];
            [model add:[[isFlowB[i][j] eq:@(1)] imply:[flowB[i][j] geq:@(1.0)]]];
         }
         [model add:[ORFactory sumbool:model array:isFlowB[0] eqi:1]];
      }
      NSMutableArray* l;
      id<ORDoubleArray> coefs;
      for (ORInt i = 0; i < [network count]; i++){
         ORInt n = [network[i] intValue];
         l = [[NSMutableArray alloc] init];
         for (ORInt path = 0; path < [P_nodesA[n] count]; path++){
            ORInt r = [P_nodesA[n][path][0] intValue];
            ORInt c = [P_nodesA[n][path][1] intValue];
            [l addObject:flowA[r][c]];
         }
         for (ORInt path = 0; path < [P_nodesB[n] count]; path++){
            ORInt r = [P_nodesB[n][path][0] intValue];
            ORInt c = [P_nodesB[n][path][1] intValue];
            [l addObject:flowB[r][c]];
         }
         coefs = [ORFactory doubleArray:model range:RANGE(model, 0, (ORInt)[l count]) value:1];
         // little trick to get the sum equals to load[index] rewrite the sum by passing the result in the other side
         [coefs set:-1.0 at:(ORInt)[l count]];
         [l addObject:load[i]];
         [model add:[ORFactory realSum:model array:(id<ORRealVarArray>)[ORFactory idArray:model array:l] coef:coefs eq:0.0]];
         [l release];
      }
//      ORInt loadsz =(ORInt) [load count];
//      id<ORRealVarArray> squareLoad = [ORFactory realVarArray:model range:RANGE(model, 0, loadsz) low:0.0 up:+INFINITY names:@"squareLoad"];
//      for (ORInt i = 0; i < [load count]; i++) {
//         [model add:[squareLoad[i] eq:[load[i] square]]];
//      }
//      squareLoad[loadsz] = loadSquareSum;
//      coefs = [ORFactory doubleArray:model range:RANGE(model, 0, loadsz) value:1];
//      [coefs set:-1.0 at:loadsz];
//      [model add:[ORFactory realSum:model array:squareLoad coef:coefs eq:0.0]];
      [model add:[Sum(model, i,RANGE(model, 0, (ORInt)[load count] - 1),[load[i] mul:load[i]]) eq:loadSquareSum]];
      
      for(ORInt i = 0; i < [flowA count]; i++){
         [model add:[Sum(model, p, RANGE(model, 0, (ORInt)[flowA[i] count]-1),[flowA[i][p] mul:@([allpathA[i%([desiredFlowsOfA count]/2)][p] count])]) eq:pathLensA[i]]];
      }
      for(ORInt i = 0; i < [flowB count]; i++){
         [model add:[Sum(model, p, RANGE(model, 0, (ORInt)[flowB[i] count]-1),[flowB[i][p] mul:@([allpathB[i%([desiredFlowsOfB count]/2)][p] count])]) eq:pathLensB[i]]];
      }
      [model add:[pathLens eq:[Sum(model,i,RANGE(model, 0, (ORInt)[pathLensA count] - 1), pathLensA[i]) plus:Sum(model,i,RANGE(model, 0, (ORInt)[pathLensB count]- 1), pathLensB[i])]]];
      
//      # equiv constraints
      ORInt index=0;
      NSMutableArray* equivlist;
      for(ORInt i = 0; i < [ec count]; i++){
         equivlist = [[NSMutableArray alloc] init];
         for(ORInt j = 0; j < [network count]; j++){
            ORInt node = [ec[i] intValue];
            for(NSMutableArray* path in P_nodesA[node]){
               ORInt ind0 = [path[0] intValue];
               ORInt ind1 = [path[1] intValue];
               [allpathA[ind0][ind1] containsObject:network[j]];
               [equivlist addObject:isFlowA[ind0][ind1]];
            }
         }
         [equivlist addObject:equiv[index]];
         id<ORIntVarArray> equivArray = (id<ORIntVarArray>)[ORFactory idArray:model array:equivlist];
         id<ORIntArray> coefs = [ORFactory intArray:model range:equivArray.range value:1];
         [coefs setObject:@(-1) atIndexedSubscript:([coefs count] - 1)];
         [model add:[ORFactory sum:model array:equivArray coef:coefs eq:0]];
         [model add:[equiv[index++] geq:@(1)]];
         [equivlist release];
      }
      
      //demand constraints
      //trafic A
      for(ORInt s = 0, d = s + 1; d < [desiredFlowsOfA count]; s++,d++){
         ORInt demand = [[demandA objectForKey:@[desiredFlowsOfA[s],desiredFlowsOfA[d]]] intValue];
         [model add:[ORFactory sum:model array:flowA[s] eqi:demand]];
      }
      //demand constraints
      //trafic B
      for(ORInt s = 0, d = s + 1; d < [desiredFlowsOfB count]; s++,d++){
         ORInt demand = [[demandA objectForKey:@[desiredFlowsOfB[s],desiredFlowsOfB[d]]] intValue];
         [model add:[ORFactory sum:model array:flowB[s] eqi:demand]];
      }
      
      //arc capacity
      NSMutableArray* adj = nil;
      id<ORIntVarArray> arcFlow;
      ORInt sz = 0;
      for(ORInt n = 0; n < [g size]; n++){
         adj = [g edges:n];
         for(ORInt i = 0; i < [adj count]; i++){
            NSArray* key = @[@(n), adj[i]];
            NSArray* af = [P_edgesA objectForKey:key];
            NSArray* bf = [P_edgesB objectForKey:key];
            ORInt index = 0;
            sz = (ORInt)([af count]+[bf count] - 1);
            if(sz > 0){
               arcFlow = [ORFactory intVarArray:model range:RANGE(model, 0,sz)];
               for(NSArray* indexFlow in af){
                  ORInt ind0 = [indexFlow[0] intValue];
                  ORInt ind1 = [indexFlow[1] intValue];
                  arcFlow[index++] = flowA[ind0][ind1];
               }
               for(NSArray* indexFlow in bf){
                  ORInt ind0 = [indexFlow[0] intValue];
                  ORInt ind1 = [indexFlow[1] intValue];
                  arcFlow[index++] = flowB[ind0][ind1];
               }
               [model add:[ORFactory sum:model array:arcFlow geqi:100]];
            }
         }
      }
      
      //      NSLog(@"%@",model);
      
      [allpathA release];
      [allpathB release];
      [P_nodesA release];
      [P_nodesB release];
      [demandB release];
      [demandA release];
      //        [model objective];
      
      
      [model minimize: [[pathLens mul:@(alpha0)] plus:[loadSquareSum mul:@(alpha2)]]];
      
      printf("%s", [NSString stringWithFormat: @"%@", [model constraints]].UTF8String);
      
      id<MIPProgram> p = [ORFactory createMIPProgram:model];
      
   }
   return 0;
}

