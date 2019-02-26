//
//  main.m
//  security_app
//
//  Created by zitoun on 1/22/19.
//

#import <ORFoundation/ORFoundation.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORProgram/ORProgram.h>

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
      NSArray* device = @[@"h8",  @"h9",  @"h2",  @"h3",  @"h1",  @"h6",  @"h7",  @"h4",  @"h5",  @"sc1",  @"sa5",  @"sa20",  @"g2",  @"g1",  @"sa9",  @"sa8",  @"sc4",  @"sa7",  @"sa6",  @"sc3",  @"sc2",  @"h10",  @"h11",  @"h12",  @"h13",  @"h14",  @"h15",  @"h16",  @"sa19",  @"sa18",  @"sa17",  @"sa16",  @"sa15",  @"sa14",  @"sa13",  @"sa12",  @"sa11", @"sa10"];
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
      //      NSLog(@"%@",g);
      //all two successive values are src-dst pair
      //Thoses pairs are sorted in increasing order.
      //4-13 pair, means, 13-4 is a desiredFlow too
      //        allpath should be computed for each pair in the desiredFlows
      //        if we compute 4-13, it's easy to get 13-4 because the graph is without direction just reverse the 4-13 it's enought
      NSArray* desiredFlowsOfA = @[@4,@13,@13,@4,@7,@13,@13,@7,@8,@13,@13,@8,@0,@13,@13,@0,@1,@12,@12,@1,@12,@23,@23,@12,@12,@24,@24,@12,@12,@27,@27,@12,@2,@4,@4,@2,@3,@7,@7,@3,@5,@8,@8,@5,@0,@6,@6,@0,@1,@21,@21,@1,@22,@23,@23,@22,@24,@25,@25,@24,@26,@27,@27,@26];
      NSArray* desiredFlowsOfB = @[@2,@4,@4,@2,@3,@7,@7,@3,@5,@8,@8,@5,@0,@6,@6,@0,@1,@21,@21,@1,@22,@23,@23,@22,@24,@25,@25,@24,@26,@27,@27,@26,@2,@5,@5,@2,@2,@21,@21,@2,@2,@25,@25,@2,@3,@6,@6,@3,@3,@22,@22,@3,@3,@26,@26,@3];
      
      NSArray* ec = [Graph getEC:device with:device2ID];
      NSArray* network = [Graph getNetworkDevice:device with:device2ID];
      
      
      //      NSMutableArray* allpathA = [[NSMutableArray alloc] init];
      NSArray* allpathA = @[ @[ @[@4,@17,@18,@19,@13] , @[@4,@17,@10,@20,@13] , @[@4,@17,@18,@16,@33,@19,@13] , @[@4,@17,@18,@16,@37,@19,@13] , @[@4,@17,@18,@16,@29,@19,@13] , @[@4,@17,@18,@15,@10,@20,@13] , @[@4,@17,@10,@15,@18,@19,@13] , @[@4,@17,@10,@9,@30,@20,@13] , @[@4,@17,@10,@9,@14,@20,@13] , @[@4,@17,@10,@9,@34,@20,@13]  ],@[ @[@13,@19,@18,@17,@4] , @[@13,@20,@10,@17,@4] , @[@13,@19,@29,@16,@18,@17,@4] , @[@13,@19,@33,@16,@18,@17,@4] , @[@13,@19,@18,@15,@10,@17,@4] , @[@13,@19,@37,@16,@18,@17,@4] , @[@13,@20,@14,@9,@10,@17,@4] , @[@13,@20,@30,@9,@10,@17,@4] , @[@13,@20,@34,@9,@10,@17,@4] , @[@13,@20,@10,@15,@18,@17,@4]  ],@[ @[@7,@15,@10,@20,@13] , @[@7,@15,@18,@19,@13] , @[@7,@15,@10,@17,@18,@19,@13] , @[@7,@15,@10,@9,@30,@20,@13] , @[@7,@15,@10,@9,@14,@20,@13] , @[@7,@15,@10,@9,@34,@20,@13] , @[@7,@15,@18,@16,@33,@19,@13] , @[@7,@15,@18,@16,@37,@19,@13] , @[@7,@15,@18,@16,@29,@19,@13] , @[@7,@15,@18,@17,@10,@20,@13]  ],@[ @[@13,@19,@18,@15,@7] , @[@13,@20,@10,@15,@7] , @[@13,@19,@29,@16,@18,@15,@7] , @[@13,@19,@33,@16,@18,@15,@7] , @[@13,@19,@18,@17,@10,@15,@7] , @[@13,@19,@37,@16,@18,@15,@7] , @[@13,@20,@14,@9,@10,@15,@7] , @[@13,@20,@30,@9,@10,@15,@7] , @[@13,@20,@34,@9,@10,@15,@7] , @[@13,@20,@10,@17,@18,@15,@7]  ],@[ @[@8,@36,@14,@20,@13] , @[@8,@36,@37,@19,@13] , @[@8,@36,@14,@9,@30,@20,@13] , @[@8,@36,@14,@9,@34,@20,@13] , @[@8,@36,@14,@9,@10,@20,@13] , @[@8,@36,@14,@35,@37,@19,@13] , @[@8,@36,@37,@16,@33,@19,@13] , @[@8,@36,@37,@16,@18,@19,@13] , @[@8,@36,@37,@16,@29,@19,@13] , @[@8,@36,@37,@35,@14,@20,@13]  ],@[ @[@13,@19,@37,@36,@8] , @[@13,@20,@14,@36,@8] , @[@13,@19,@29,@16,@37,@36,@8] , @[@13,@19,@33,@16,@37,@36,@8] , @[@13,@19,@18,@16,@37,@36,@8] , @[@13,@19,@37,@35,@14,@36,@8] , @[@13,@20,@14,@35,@37,@36,@8] , @[@13,@20,@30,@9,@14,@36,@8] , @[@13,@20,@34,@9,@14,@36,@8] , @[@13,@20,@10,@9,@14,@36,@8]  ],@[ @[@0,@35,@14,@20,@13] , @[@0,@35,@37,@19,@13] , @[@0,@35,@14,@9,@30,@20,@13] , @[@0,@35,@14,@9,@34,@20,@13] , @[@0,@35,@14,@9,@10,@20,@13] , @[@0,@35,@14,@36,@37,@19,@13] , @[@0,@35,@37,@16,@33,@19,@13] , @[@0,@35,@37,@16,@18,@19,@13] , @[@0,@35,@37,@16,@29,@19,@13] , @[@0,@35,@37,@36,@14,@20,@13]  ],@[ @[@13,@19,@37,@35,@0] , @[@13,@20,@14,@35,@0] , @[@13,@19,@29,@16,@37,@35,@0] , @[@13,@19,@33,@16,@37,@35,@0] , @[@13,@19,@18,@16,@37,@35,@0] , @[@13,@19,@37,@36,@14,@35,@0] , @[@13,@20,@14,@36,@37,@35,@0] , @[@13,@20,@30,@9,@14,@35,@0] , @[@13,@20,@34,@9,@14,@35,@0] , @[@13,@20,@10,@9,@14,@35,@0]  ],@[ @[@1,@32,@34,@20,@12] , @[@1,@32,@33,@19,@12] , @[@1,@32,@34,@31,@33,@19,@12] , @[@1,@32,@34,@9,@30,@20,@12] , @[@1,@32,@34,@9,@14,@20,@12] , @[@1,@32,@34,@9,@10,@20,@12] , @[@1,@32,@33,@31,@34,@20,@12] , @[@1,@32,@33,@16,@18,@19,@12] , @[@1,@32,@33,@16,@37,@19,@12] , @[@1,@32,@33,@16,@29,@19,@12]  ],@[ @[@12,@19,@33,@32,@1] , @[@12,@20,@34,@32,@1] , @[@12,@19,@29,@16,@33,@32,@1] , @[@12,@19,@33,@31,@34,@32,@1] , @[@12,@19,@18,@16,@33,@32,@1] , @[@12,@19,@37,@16,@33,@32,@1] , @[@12,@20,@14,@9,@34,@32,@1] , @[@12,@20,@30,@9,@34,@32,@1] , @[@12,@20,@34,@31,@33,@32,@1] , @[@12,@20,@10,@9,@34,@32,@1]  ],@[ @[@23,@31,@33,@19,@12] , @[@23,@31,@34,@20,@12] , @[@23,@31,@33,@32,@34,@20,@12] , @[@23,@31,@33,@16,@18,@19,@12] , @[@23,@31,@33,@16,@37,@19,@12] , @[@23,@31,@33,@16,@29,@19,@12] , @[@23,@31,@34,@32,@33,@19,@12] , @[@23,@31,@34,@9,@30,@20,@12] , @[@23,@31,@34,@9,@14,@20,@12] , @[@23,@31,@34,@9,@10,@20,@12]  ],@[ @[@12,@19,@33,@31,@23] , @[@12,@20,@34,@31,@23] , @[@12,@19,@29,@16,@33,@31,@23] , @[@12,@19,@33,@32,@34,@31,@23] , @[@12,@19,@18,@16,@33,@31,@23] , @[@12,@19,@37,@16,@33,@31,@23] , @[@12,@20,@14,@9,@34,@31,@23] , @[@12,@20,@30,@9,@34,@31,@23] , @[@12,@20,@34,@32,@33,@31,@23] , @[@12,@20,@10,@9,@34,@31,@23]  ],@[ @[@24,@28,@30,@20,@12] , @[@24,@28,@29,@19,@12] , @[@24,@28,@30,@11,@29,@19,@12] , @[@24,@28,@30,@9,@14,@20,@12] , @[@24,@28,@30,@9,@34,@20,@12] , @[@24,@28,@30,@9,@10,@20,@12] , @[@24,@28,@29,@16,@33,@19,@12] , @[@24,@28,@29,@16,@18,@19,@12] , @[@24,@28,@29,@16,@37,@19,@12] , @[@24,@28,@29,@11,@30,@20,@12]  ],@[ @[@12,@19,@29,@28,@24] , @[@12,@20,@30,@28,@24] , @[@12,@19,@29,@11,@30,@28,@24] , @[@12,@19,@33,@16,@29,@28,@24] , @[@12,@19,@18,@16,@29,@28,@24] , @[@12,@19,@37,@16,@29,@28,@24] , @[@12,@20,@14,@9,@30,@28,@24] , @[@12,@20,@30,@11,@29,@28,@24] , @[@12,@20,@34,@9,@30,@28,@24] , @[@12,@20,@10,@9,@30,@28,@24]  ],@[ @[@27,@11,@30,@20,@12] , @[@27,@11,@29,@19,@12] , @[@27,@11,@30,@9,@14,@20,@12] , @[@27,@11,@30,@9,@34,@20,@12] , @[@27,@11,@30,@9,@10,@20,@12] , @[@27,@11,@30,@28,@29,@19,@12] , @[@27,@11,@29,@16,@33,@19,@12] , @[@27,@11,@29,@16,@18,@19,@12] , @[@27,@11,@29,@16,@37,@19,@12] , @[@27,@11,@29,@28,@30,@20,@12]  ],@[ @[@12,@19,@29,@11,@27] , @[@12,@20,@30,@11,@27] , @[@12,@19,@29,@28,@30,@11,@27] , @[@12,@19,@33,@16,@29,@11,@27] , @[@12,@19,@18,@16,@29,@11,@27] , @[@12,@19,@37,@16,@29,@11,@27] , @[@12,@20,@14,@9,@30,@11,@27] , @[@12,@20,@30,@28,@29,@11,@27] , @[@12,@20,@34,@9,@30,@11,@27] , @[@12,@20,@10,@9,@30,@11,@27]  ],@[ @[@4,@17,@2]  ],@[ @[@2,@17,@4]  ],@[ @[@7,@15,@3]  ],@[ @[@3,@15,@7]  ],@[ @[@8,@36,@5]  ],@[ @[@5,@36,@8]  ],@[ @[@0,@35,@6]  ],@[ @[@6,@35,@0]  ], @[ @[@1,@32,@21]  ], @[ @[@21,@32,@1]  ], @[ @[@23,@31,@22]  ], @[ @[@22,@31,@23]  ], @[ @[@24,@28,@25]  ], @[ @[@25,@28,@24]  ], @[ @[@27,@11,@26]  ],@[ @[@26,@11,@27]  ]];
      //      NSMutableArray* allpathB = [[NSMutableArray alloc] init];
      NSArray* allpathB = @[ @[ @[@4,@17,@2]  ], @[ @[@2,@17,@4]  ], @[ @[@7,@15,@3]  ], @[ @[@3,@15,@7]  ], @[ @[@8,@36,@5]  ], @[ @[@5,@36,@8]  ], @[ @[@0,@35,@6]  ], @[ @[@6,@35,@0]  ], @[ @[@1,@32,@21]  ], @[ @[@21,@32,@1]  ], @[ @[@23,@31,@22]  ], @[ @[@22,@31,@23]  ], @[ @[@24,@28,@25]  ], @[ @[@25,@28,@24]  ], @[ @[@27,@11,@26]  ], @[ @[@26,@11,@27]  ], @[ @[@2,@17,@18,@16,@37,@36,@5] , @[@2,@17,@18,@19,@37,@36,@5] , @[@2,@17,@10,@9,@14,@36,@5] , @[@2,@17,@10,@20,@14,@36,@5] , @[@2,@17,@18,@16,@33,@19,@37,@36,@5] , @[@2,@17,@18,@16,@37,@35,@14,@36,@5] , @[@2,@17,@18,@16,@29,@19,@37,@36,@5] , @[@2,@17,@18,@15,@10,@9,@14,@36,@5] , @[@2,@17,@18,@15,@10,@20,@14,@36,@5] , @[@2,@17,@18,@19,@29,@16,@37,@36,@5]  ], @[ @[@5,@36,@14,@9,@10,@17,@2] , @[@5,@36,@14,@20,@10,@17,@2] , @[@5,@36,@37,@16,@18,@17,@2] , @[@5,@36,@37,@19,@18,@17,@2] , @[@5,@36,@14,@9,@30,@20,@10,@17,@2] , @[@5,@36,@14,@9,@34,@20,@10,@17,@2] , @[@5,@36,@14,@9,@10,@15,@18,@17,@2] , @[@5,@36,@14,@35,@37,@16,@18,@17,@2] , @[@5,@36,@14,@35,@37,@19,@18,@17,@2] , @[@5,@36,@14,@20,@30,@9,@10,@17,@2]  ], @[ @[@2,@17,@18,@16,@33,@32,@21] , @[@2,@17,@18,@19,@33,@32,@21] , @[@2,@17,@10,@9,@34,@32,@21] , @[@2,@17,@10,@20,@34,@32,@21] , @[@2,@17,@18,@16,@33,@31,@34,@32,@21] , @[@2,@17,@18,@16,@37,@19,@33,@32,@21] , @[@2,@17,@18,@16,@29,@19,@33,@32,@21] , @[@2,@17,@18,@15,@10,@9,@34,@32,@21] , @[@2,@17,@18,@15,@10,@20,@34,@32,@21] , @[@2,@17,@18,@19,@29,@16,@33,@32,@21]  ], @[ @[@21,@32,@34,@9,@10,@17,@2] , @[@21,@32,@34,@20,@10,@17,@2] , @[@21,@32,@33,@19,@18,@17,@2] , @[@21,@32,@33,@16,@18,@17,@2] , @[@21,@32,@34,@31,@33,@19,@18,@17,@2] , @[@21,@32,@34,@31,@33,@16,@18,@17,@2] , @[@21,@32,@34,@9,@30,@20,@10,@17,@2] , @[@21,@32,@34,@9,@14,@20,@10,@17,@2] , @[@21,@32,@34,@9,@10,@15,@18,@17,@2] , @[@21,@32,@34,@20,@14,@9,@10,@17,@2]  ], @[ @[@2,@17,@18,@16,@29,@28,@25] , @[@2,@17,@18,@19,@29,@28,@25] , @[@2,@17,@10,@9,@30,@28,@25] , @[@2,@17,@10,@20,@30,@28,@25] , @[@2,@17,@18,@16,@33,@19,@29,@28,@25] , @[@2,@17,@18,@16,@37,@19,@29,@28,@25] , @[@2,@17,@18,@16,@29,@11,@30,@28,@25] , @[@2,@17,@18,@15,@10,@9,@30,@28,@25] , @[@2,@17,@18,@15,@10,@20,@30,@28,@25] , @[@2,@17,@18,@19,@29,@11,@30,@28,@25]  ], @[ @[@25,@28,@30,@9,@10,@17,@2] , @[@25,@28,@30,@20,@10,@17,@2] , @[@25,@28,@29,@16,@18,@17,@2] , @[@25,@28,@29,@19,@18,@17,@2] , @[@25,@28,@30,@11,@29,@16,@18,@17,@2] , @[@25,@28,@30,@11,@29,@19,@18,@17,@2] , @[@25,@28,@30,@9,@14,@20,@10,@17,@2] , @[@25,@28,@30,@9,@34,@20,@10,@17,@2] , @[@25,@28,@30,@9,@10,@15,@18,@17,@2] , @[@25,@28,@30,@20,@14,@9,@10,@17,@2]  ], @[ @[@3,@15,@10,@9,@14,@35,@6] , @[@3,@15,@10,@20,@14,@35,@6] , @[@3,@15,@18,@16,@37,@35,@6] , @[@3,@15,@18,@19,@37,@35,@6] , @[@3,@15,@10,@17,@18,@16,@37,@35,@6] , @[@3,@15,@10,@17,@18,@19,@37,@35,@6] , @[@3,@15,@10,@9,@30,@20,@14,@35,@6] , @[@3,@15,@10,@9,@14,@36,@37,@35,@6] , @[@3,@15,@10,@9,@34,@20,@14,@35,@6] , @[@3,@15,@10,@20,@14,@36,@37,@35,@6]  ], @[ @[@6,@35,@14,@9,@10,@15,@3] , @[@6,@35,@14,@20,@10,@15,@3] , @[@6,@35,@37,@16,@18,@15,@3] , @[@6,@35,@37,@19,@18,@15,@3] , @[@6,@35,@14,@9,@30,@20,@10,@15,@3] , @[@6,@35,@14,@9,@34,@20,@10,@15,@3] , @[@6,@35,@14,@9,@10,@17,@18,@15,@3] , @[@6,@35,@14,@36,@37,@16,@18,@15,@3] , @[@6,@35,@14,@36,@37,@19,@18,@15,@3] , @[@6,@35,@14,@20,@30,@9,@10,@15,@3]  ], @[ @[@3,@15,@10,@9,@34,@31,@22] , @[@3,@15,@10,@20,@34,@31,@22] , @[@3,@15,@18,@16,@33,@31,@22] , @[@3,@15,@18,@19,@33,@31,@22] , @[@3,@15,@10,@17,@18,@16,@33,@31,@22] , @[@3,@15,@10,@17,@18,@19,@33,@31,@22] , @[@3,@15,@10,@9,@30,@20,@34,@31,@22] , @[@3,@15,@10,@9,@14,@20,@34,@31,@22] , @[@3,@15,@10,@9,@34,@32,@33,@31,@22] , @[@3,@15,@10,@20,@14,@9,@34,@31,@22]  ], @[ @[@22,@31,@33,@19,@18,@15,@3] , @[@22,@31,@33,@16,@18,@15,@3] , @[@22,@31,@34,@9,@10,@15,@3] , @[@22,@31,@34,@20,@10,@15,@3] , @[@22,@31,@33,@32,@34,@9,@10,@15,@3] , @[@22,@31,@33,@32,@34,@20,@10,@15,@3] , @[@22,@31,@33,@19,@29,@16,@18,@15,@3] , @[@22,@31,@33,@19,@18,@17,@10,@15,@3] , @[@22,@31,@33,@19,@37,@16,@18,@15,@3] , @[@22,@31,@33,@16,@18,@17,@10,@15,@3]  ], @[ @[@3,@15,@10,@9,@30,@11,@26] , @[@3,@15,@10,@20,@30,@11,@26] , @[@3,@15,@18,@16,@29,@11,@26] , @[@3,@15,@18,@19,@29,@11,@26] , @[@3,@15,@10,@17,@18,@16,@29,@11,@26] , @[@3,@15,@10,@17,@18,@19,@29,@11,@26] , @[@3,@15,@10,@9,@30,@28,@29,@11,@26] , @[@3,@15,@10,@9,@14,@20,@30,@11,@26] , @[@3,@15,@10,@9,@34,@20,@30,@11,@26] , @[@3,@15,@10,@20,@14,@9,@30,@11,@26]  ], @[ @[@26,@11,@30,@9,@10,@15,@3] , @[@26,@11,@30,@20,@10,@15,@3] , @[@26,@11,@29,@16,@18,@15,@3] , @[@26,@11,@29,@19,@18,@15,@3] , @[@26,@11,@30,@9,@14,@20,@10,@15,@3] , @[@26,@11,@30,@9,@34,@20,@10,@15,@3] , @[@26,@11,@30,@9,@10,@17,@18,@15,@3] , @[@26,@11,@30,@28,@29,@16,@18,@15,@3] , @[@26,@11,@30,@28,@29,@19,@18,@15,@3] , @[@26,@11,@30,@20,@14,@9,@10,@15,@3]  ]];
      ORInt src;
      ORInt dst;
      NSMutableArray* tmp;
      id<ORModel> model = [ORFactory createModel];
      ORInt i = 0;
      //Still need to deal with inverse path D-S
      id<ORIdArray> isFlowA = [ORFactory idArray:model range:RANGE(model, 0, ((ORInt)[desiredFlowsOfA count]/2) - 1 )];
      id<ORIdArray> flowA = [ORFactory idArray:model range:RANGE(model, 0, ((ORInt)[desiredFlowsOfA count]/2) - 1)];
      for(ORInt s = 0,d = s + 1; d < [desiredFlowsOfA count]; s+=2, d+=2){
         src = [desiredFlowsOfA[s] intValue];
         dst = [desiredFlowsOfA[d] intValue];
         tmp = [Graph bfs:g source:src dest:dst maxpaths:MAX_PATH];
         //         [allpathA addObject:tmp];
         isFlowA[i] = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) domain:RANGE(model, 0, 1) names:[NSString stringWithFormat:@"isFlowA[%d]",i]];
         flowA[i] = [ORFactory realVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) low:0.0 up:100.0 names:[NSString stringWithFormat:@"FlowA[%d]",i]];
         i++;
      }
      
      i = 0;
      ORInt nbPathB = 0;
      id<ORIdArray> isFlowB = [ORFactory idArray:model range:RANGE(model, 0, ((ORInt)[desiredFlowsOfB count]/2) - 1)];
      id<ORIdArray> flowB = [ORFactory idArray:model range:RANGE(model, 0, ((ORInt)[desiredFlowsOfB count]/2) - 1)];
      for(ORInt s = 0,d = s + 1; d < [desiredFlowsOfB count]; s+=2, d+=2){
         src = [desiredFlowsOfB[s] intValue];
         dst = [desiredFlowsOfB[d] intValue];
         tmp = [Graph bfs:g source:src dest:dst maxpaths:MAX_PATH];
         nbPathB += [tmp count] * 2;
         //         [allpathB addObject:tmp];
         isFlowB[i] = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) domain:RANGE(model, 0, 1) names:[NSString stringWithFormat:@"isFlowB[%d]",i]];
         flowB[i] = [ORFactory realVarArray:model range:RANGE(model, 0, (ORInt)[tmp count]- 1) low:0.0 up:100.0 names:[NSString stringWithFormat:@"FlowB[%d]",i]];
         i++;
      }
      
      for(ORInt i = 0; i < [isFlowA count]; i++){
         for(ORInt j = 0; j < [isFlowA[i] count]; j++){
            [model add:[isFlowA[i][j] geq:flowA[i][j]]];
         }
         [model add:[ORFactory sumbool:model array:isFlowA[i] eqi:1]];
      }
      
      for(ORInt i = 0; i < [isFlowB count]; i++){
         for(ORInt j = 0; j < [isFlowB[i] count]; j++){
            [model add:[isFlowB[i][j] geq:flowB[i][j]]];
         }
         [model add:[ORFactory sumbool:model array:isFlowB[i] eqi:1]];
      }
      id<ORIdArray> equiv = [ORFactory idArray:model range:RANGE(model, 0, (ORInt)([ec count])-1)];
      id<ORRealVarArray> load = [ORFactory realVarArray:model range:RANGE(model, 0, (ORInt) [network count]- 1)];
      id<ORRealVar> loadSquareSum = [ORFactory realVar:model name:@"loadSquareSum"];
      for(ORInt i = 0; i < [network count];i++){
         load[i] = [ORFactory realVar:model name:[NSString stringWithFormat:@"load[%@]",device[[network[i] intValue]]]];
      }
      
      for(ORInt i = 0; i < [ec count]; i++){
         equiv[i] = [ORFactory intVarArray:model range:RANGE(model, 0, (ORInt)([network count])-1)];
         for(ORInt j = 0; j < [network count];j++){
            //equiv should be a boolean variable and constraint related should be the max (OR)
            equiv[i][j] = [ORFactory intVar:model domain:RANGE(model, 0, MAXINT) name:[NSString stringWithFormat:@"equiv[%@,%@]",device[[ec[i] intValue]],device[[network[j] intValue]]]];
         }
      }
      //may be ok
      [model add:[Sum(model, i,RANGE(model, 0, (ORInt)[load count] - 1),[load[i] square]) eq:loadSquareSum]];
      //demand constraints
      //trafic A
      for(ORInt s = 0, d = s + 1; d < [desiredFlowsOfA count]; s+=2,d+=2){
         ORInt demand = [[demandA objectForKey:@[desiredFlowsOfA[s],desiredFlowsOfA[d]]] intValue];
         [model add:[ORFactory sum:model array:flowA[s/2] geqi:demand]];
      }
      //demand constraints
      //trafic B
      for(ORInt s = 0, d = s + 1; d < [desiredFlowsOfB count]; s+=2,d+=2){
         ORInt demand = [[demandB objectForKey:@[desiredFlowsOfB[s],desiredFlowsOfB[d]]] intValue];
         [model add:[ORFactory sum:model array:flowB[s/2] geqi:demand]];
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
      //capacity flow
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
               [model add:[ORFactory sum:model array:arcFlow leqi:100]];
            }
         }
      }
      
      
      NSMutableArray* equivlist;
      for(ORInt i = 0; i < [ec count]; i++){
         ORInt node = [ec[i] intValue];
         for(ORInt j = 0; j < [network count]; j++){
            equivlist = [[NSMutableArray alloc] init];
            for(NSMutableArray* path in P_nodesA[node]){
               ORInt ind0 = [path[0] intValue];
               ORInt ind1 = [path[1] intValue];
               if([allpathA[ind0][ind1] containsObject:network[j]]){
                  [equivlist addObject:isFlowA[ind0][ind1]];
               }
            }
            for(NSMutableArray* path in P_nodesB[node]){
               ORInt ind0 = [path[0] intValue];
               ORInt ind1 = [path[1] intValue];
               if([allpathB[ind0][ind1] containsObject:network[j]])
                  [equivlist addObject:isFlowB[ind0][ind1]];
            }
            if([equivlist count] > 1){
               [equivlist addObject:equiv[i][j]];
               id<ORIntVarArray> equivArray = (id<ORIntVarArray>)[ORFactory idArray:model array:equivlist];
               id<ORIntArray> coefs = [ORFactory intArray:model range:equivArray.range value:-1];
               [coefs setObject:@(1) atIndexedSubscript:([coefs count] - 1)];
               //or is an affectation over variables
               [model add:[ORFactory sum:model array:equivArray coef:coefs eq:0]];
            }
            [equivlist release];
         }
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
         coefs = [ORFactory doubleArray:model range:RANGE(model, 0, (ORInt)[l count]) value:-1];
         // little trick to get the sum equals to load[index] rewrite the sum by passing the result in the other side
         [coefs set:1.0 at:(ORInt)[l count]];
         [l addObject:load[i]];
         [model add:[ORFactory realSum:model array:(id<ORRealVarArray>)[ORFactory idArray:model array:l] coef:coefs eq:0.0]];
         [l release];
      }
      //
      id<ORExpr> e = Sum(model, p, RANGE(model, 0, (ORInt)[flowA[0] count]-1),[flowA[0][p] mul:@([allpathA[0][p] count] - 1)]);
      for(ORInt i = 1; i < [flowA count]; i++){
         e = [e plus:Sum(model, p, RANGE(model, 0, (ORInt)[flowA[i] count]-1),[flowA[i][p] mul:@([allpathA[i][p] count] - 1)])];
      }
      for(ORInt i = 0; i < [flowB count]; i++){
         e = [e plus:Sum(model, p, RANGE(model, 0, (ORInt)[flowB[i] count]-1),[flowB[i][p] mul:@([allpathB[i][p] count] - 1)])];
      }
      
      printf("%s", [NSString stringWithFormat: @"%@", [model constraints]].UTF8String);
      
      //            [allpathA release];
      //            [allpathB release];
      [P_nodesA release];
      [P_nodesB release];
      [demandB release];
      [demandA release];
      
      [model minimize: [[e mul:@(alpha0)] plus:[loadSquareSum mul:@(alpha2)]]];
      
      
      id<MIPProgram> mip = [ORFactory createMIPProgram: model];
      [mip solve];
   }
   return 0;
}

