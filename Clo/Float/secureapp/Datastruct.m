#import "Datastruct.h"


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


@implementation Graph

-(id) initGraph
{
   self = [super init];
   _nodes = 0;
   _nbEdges = 0;
   _lists = [[NSMutableArray alloc] init];
   _in = [[NSMutableArray alloc] init];
   return self;
}
-(id) initWithNames:(NSArray*) names andEdges:(NSArray*) edges
{
   self = [super init];
   _nodes = (ORInt)[names count];
   _nbEdges = 0;
   _names = [[NSMutableArray alloc] initWithArray:names];
   _lists = [[NSMutableArray alloc] initWithArray:edges];
   _in = [[NSMutableArray alloc] init];
   for(ORInt i = 0; i < (ORInt) [_lists count]; i++){
      [_in addObject:[[NSMutableArray alloc] init]];
   }
   for(ORInt i = 0; i < (ORInt) [_lists count]; i++){
      for(ORInt j = 0; j < (ORInt) [_lists[i] count]; j++){
         [_in[[_lists[i][j] intValue]] addObject: @(i)];
         _nbEdges++;
      }
   }
   return self;
}
-(void) dealloc
{
   [_lists release];
   [_in release];
   if(_names != nil) [_names release];
   [super dealloc];
}
-(ORInt) size
{
   return _nodes;
}
-(ORInt) nbEdges
{
   return _nbEdges;
}
-(NSArray*) edges:(ORInt)node
{
   return _lists[node];
}
-(NSArray*) inEdges:(ORInt)node
{
   return _in[node];
}
-(void) addAdjacency:(NSArray*)l
{
   ORInt current = (ORInt)[_lists count];
   [_lists addObject:l];
   for(id n in l){
      _in[[n intValue]] = @(current);
      _nbEdges++;
   }
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
-(NSString*) name:(ORInt) node
{
   return _names[node];
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


@implementation Network{
   Graph* _graph;
   NSArray* _trafics;
   NSArray* _penalities;
   NSArray* _capacities;
   NSArray* _risk;
   NSArray* _demands;
   NSArray* _fwCosts;
   NSArray* _deviceMemory;
   NSArray* _desiredFlows;
   NSMutableArray* _ec;
   NSMutableArray* _networkDevices;
}
-(Network*) init:(NSArray*) deviceNames memories:(NSArray*) mem links:(NSArray*) lks trafics:(NSArray*) t flows:(NSArray*) df demands:(NSArray*) d penalities:(NSArray*) p risk:(NSArray*) r capacities:(NSArray*) capacities
{
   self = [super init];
   _graph = [[Graph alloc] initWithNames:deviceNames andEdges:lks];
   _trafics = t;
   _desiredFlows = df;
   _demands = d;
   _penalities = p;
   _risk = r;
   _deviceMemory = mem;
   _ec = [[NSMutableArray alloc] init];
   _networkDevices = [[NSMutableArray alloc] init];
   _capacities = capacities;
   for(ORInt i = 0; i < [deviceNames count]; i++){
      if([deviceNames[i] characterAtIndex:0] == 'h'){
         [_ec addObject:@(i)];
      } else if([deviceNames[i] characterAtIndex:0] == 'g' || [deviceNames[i] characterAtIndex:0] == 's' ){
         [_networkDevices addObject:@(i)];
      }
   }
   return self;
}
-(void) dealloc
{
   [_graph dealloc];
   [_ec dealloc];
   [_networkDevices dealloc];
   [super dealloc];
}

-(int)      size
{
   return [_graph size];
}
-(int)      nbEdges
{
   return [_graph nbEdges];
}
-(NSArray*) trafics
{
   return _trafics;
}
-(ORInt) penality:(ORInt) t for:(ORInt)n
{
   return [_penalities[n][t] intValue];
}
-(ORBool) isNetworkDevice:(ORInt) node;
{
   return [[self name:node] characterAtIndex:0] == 'g' || [[self name:node] characterAtIndex:0] == 's';
}
-(NSArray*) risk
{
   return _risk;
}
-(NSArray*) demands:(ORInt) T
{
   return _demands[T];
}
-(NSArray*) fwCosts
{
   return _fwCosts;
}
-(NSArray*) ec
{
   return _ec;
}
-(NSArray*) networkDevices
{
   return _networkDevices;
}
-(NSArray*) desiredFlows:(ORInt) T
{
   return _desiredFlows[T];
}
-(ORInt) memory:(ORInt)node
{
   return [_deviceMemory[node] intValue];
}
-(ORInt) capacity:(ORInt) src to:(ORInt) dst
{
   ORInt i = (ORInt)[[self edges:src] indexOfObject:@(dst)] ;
   return [_capacities[src][i] intValue];
}
-(NSString*) name:(ORInt) node
{
   return [_graph name:node];
}
-(NSArray*) edges:(ORInt) node
{
   return [_graph edges:node];
}
-(NSArray*) inEdges:(ORInt) node
{
   return [_graph inEdges:node];
}
+(NSMutableArray*) computePaths:(Network *) n source:(ORInt) startVertex dest:(ORInt) dstVertex maxpaths:(ORInt) nbP
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
      
      NSArray* nbhood = [n->_graph edges:last];
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


void mappingNP2(NSMutableArray* pNodes, NSMutableDictionary* allpath, ORInt nb)
{
   for(ORInt i = 0; i < nb; i++){
      pNodes[i] = [[NSMutableArray alloc] init];
   }
   [allpath enumerateKeysAndObjectsUsingBlock:^(NSArray* pair, NSArray* paths, BOOL * stop) {
      for(ORInt j = 0; j < [paths count]; j++){
         for(ORInt k = 0; k < [paths[j] count]; k++){
            ORInt node = [paths[j][k] intValue];
            [pNodes[node] addObject:@[pair,@(j)]];
         }
      }
   }];
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


void mappingEP2(NSMutableDictionary* res, NSMutableDictionary* allpath)
{
   [allpath enumerateKeysAndObjectsUsingBlock:^(NSArray* pair, NSArray* paths, BOOL * stop) {
      for(ORInt j = 0; j < [paths count]; j++){
         NSMutableArray* path = paths[j];
         for (ORInt s = 0, d = s + 1; d < [path count]; s++, d++) {
            NSArray* key = @[path[s],path[d]];
            NSMutableArray* ps = [res objectForKey:key];
            if(ps == nil){
               ps = [[NSMutableArray alloc] init];
            }
            [ps addObject:@[pair,@(j)]];
            [res setObject:ps forKey:key];
         }
      }
   }];
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

