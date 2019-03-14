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

extern void mappingEP(NSMutableDictionary* res, NSArray* allpath);
extern void mappingNP2(NSMutableArray* pNodes, NSMutableDictionary* allpath, ORInt nb);
extern void mappingEP(NSMutableDictionary* res, NSArray* allpath);
extern void mappingEP2(NSMutableDictionary* res, NSMutableDictionary* allpath);
extern void riskCacl(NSMutableArray * res, NSArray* flowPath, NSArray* funR, ORInt traffic, ORInt nbNodes);

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


@interface Graph : NSObject
{
   ORInt _nodes;
   ORInt _nbEdges;
   NSMutableArray* _lists;
   NSMutableArray* _in;
   NSMutableArray* _names;
}

-(id) initGraph;
-(id) initWithNames:(NSArray*) names andEdges:(NSArray*) edges;
-(ORInt) size;
-(int)      nbEdges;
-(NSArray*) edges:(ORInt)node;
-(NSArray*) inEdges:(ORInt)node;
-(void) addAdjacency:(NSArray*)l;
-(void) addAdjacenyWithObject:(id) firstN,...;
-(NSString*)   name:(ORInt) node;
+(NSMutableArray*) bfs : (Graph*) graph source:(ORInt) startVertex dest:(ORInt) destVertex maxpaths:(ORInt) numberPaths;
+(ORBool) isNetWorkDevice:(NSString*) d;
@end



@interface Network : NSObject
-(Network*) init:(NSArray*) deviceNames memories:(NSArray*) mem links:(NSArray*) lks trafics:(NSArray*) t flows:(NSArray*) df demands:(NSArray*) d penalities:(NSArray*) p risk:(NSArray*) r capacities:(NSArray*) capacities;
-(int)      size;
-(int)      nbEdges;
-(NSArray*) trafics;
-(ORInt) penality:(ORInt) t for:(ORInt)n;
-(ORInt) memory:(ORInt) node;
-(ORInt) capacity:(ORInt) src to:(ORInt) dst;
-(ORBool) isNetworkDevice:(ORInt) node;
-(NSArray*) risk;
-(NSArray*) demands:(ORInt) T;
-(NSArray*) fwCosts;
-(NSArray*) ec;
-(NSArray*) networkDevices;
-(NSArray*) desiredFlows:(ORInt) T;
-(NSString*) name:(ORInt) node;
-(NSArray*) edges:(ORInt)node;
-(NSArray*) inEdges:(ORInt)node;
+(NSMutableArray*) computePaths : (Network*) graph source:(ORInt) startVertex dest:(ORInt) destVertex maxpaths:(ORInt) numberPaths;
@end
