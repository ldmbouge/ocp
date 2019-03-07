#import <ORFoundation/ORFoundation.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORProgram/ORProgram.h>

#define MAX_PATH 10
#define alpha0 10
#define alpha1 10
#define alpha2 0.01
#define beta0 1
#define beta1 1
#define beta2 4
#define beta3 1

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
+(ORBool) isNetWorkDevice:(NSString*) d;
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
+(ORBool) isNetWorkDevice:(NSString*) d
{
   return [d characterAtIndex:0] == 'g' || [d characterAtIndex:0] == 's';
}
@end

//for performance issue we should be compute both following function with bfs and store them in a data struct of the graph for instance
//map nodes to path
void mappingNP(NSMutableArray* pNodes, NSArray* allpath, ORInt nb)
{
   for(ORInt i = 0; i < nb; i++){
      pNodes[i] = [[NSMutableArray alloc] init];
   }
   for(ORInt i = 0; i < [allpath count]; i++){
      for(ORInt j = 0; j < [allpath[i] count]; j++){
         for(ORInt k = 0; k < [allpath[i][j] count]; k++){
            ORInt node = [allpath[i][j][k] intValue];
            [pNodes[node] addObject:@[@(i),@(j)]];
         }
      }
   }
}

//map edges to path
void mappingEP(NSMutableDictionary* res, NSArray* allpath)
{
   for(ORInt i = 0; i < [allpath count]; i++){
      for(ORInt j = 0; j < [allpath[i] count]; j++){
         NSMutableArray* path = allpath[i][j];
         for (ORInt s = 0, d = s + 1; d < [path count]; s++, d++) {
            NSArray* key = @[path[s],path[d]];
            NSMutableArray* ps = [res objectForKey:key];
            if(ps == nil){
               ps = [[NSMutableArray alloc] init];
            }
            [ps addObject:@[@(i),@(j)]];
            [res setObject:ps forKey:key];
         }
      }
   }
}

//risk
void riskCacl(NSMutableArray * res, NSArray* flowPath, NSArray* funR, ORInt traffic, ORInt nbNodes)
{
   NSMutableArray* neighboors = [[NSMutableArray alloc] initWithCapacity:nbNodes];
   for(ORInt i = 0; i < nbNodes; i++){
      neighboors[i] = [[NSMutableSet alloc] init];
   }
   ORInt u,v;
   for(NSArray* path in flowPath){
      for(ORInt i = 0, j = i + 1; j < [path count]; i++, j++){
         u = [path[i] intValue];
         v = [path[j] intValue];
         [neighboors[v] addObject:@(u)];
      }
   }
   NSMutableSet* ns ;
   for(NSArray* path in flowPath){
      ns = [[NSMutableSet alloc] init];
      ORInt size = (ORInt)[path count];
      for(ORInt i = 0; i < size; i++){
         [ns addObject:path[i]];
      }
      ORInt src = [path[0] intValue];
      ORInt dst = [path[size-1] intValue];
      for(NSNumber * n in neighboors[src]){
         [ns addObject:n];
         [ns unionSet:neighboors[[n intValue]]];
      }
      for(NSNumber * n in neighboors[dst]){
         [ns addObject:n];
         [ns unionSet:neighboors[[n intValue]]];
      }
      ORInt riskV = 0;
      for(NSNumber * n in ns){
         ORInt v = [funR[[n intValue]][traffic] intValue];
         riskV += v * v;
      }
      [res addObject:@(riskV)];
      [ns release];
   }
   for(ORInt i = 0; i < nbNodes; i++){
      [neighboors[i] release];
   }
   [neighboors release];
}
