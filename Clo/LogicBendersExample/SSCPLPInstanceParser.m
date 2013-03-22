//
//  SSCPLPInstanceParser.m
//  Clo
//
//  Created by Daniel Fontaine on 3/21/13.
//
//

#import "SSCPLPInstanceParser.h"

@implementation SSCPLPInstance

@synthesize numberOfClients;
@synthesize numberOfPlants;
@synthesize cost;
@synthesize capacity;
@synthesize demand;
@synthesize openingCost;

-(id) initWithClients: (NSInteger)m plants: (NSInteger)n {
   if((self = [super init]) != nil) {
      numberOfClients = m;
      numberOfPlants = n;
      cost = malloc(sizeof(ORFloat*) * m);
      for(NSInteger i = 0; i < m; i++) cost[i] = malloc(sizeof(ORFloat) * n);
      capacity = malloc(n * sizeof(ORFloat));
      demand = malloc(m * sizeof(ORFloat));
      openingCost = malloc(n * sizeof(ORFloat));
   }
   return self;
}

-(void) dealloc {
   NSInteger m = self.numberOfClients;
   for(NSInteger i = 0; i < m; i++) free(cost[i]);
   free(cost);
   free(demand);
   free(capacity);
   free(openingCost);
   [super dealloc];
}

@end

@implementation SSCPLPInstanceParser
-(SSCPLPInstance*) parseInstanceFile:(NSString *)filePath {
   NSString* data = [NSString stringWithContentsOfFile:filePath encoding: NSASCIIStringEncoding error:nil];
   SSCPLPInstance* instance = [self parseInstanceString: data];
   [data release];
   return instance;
}

-(SSCPLPInstance*) parseInstanceString: (NSString*)data {
   NSArray* components = [data componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
   NSArray* values = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
   ORInt index = 0;
   ORInt m = [values[index++] intValue];
   ORInt n = [values[index++] intValue];
   
   SSCPLPInstance* instance = [[SSCPLPInstance alloc] initWithClients: m plants: n];
   // Parse cost
   for(ORInt i = 0; i < m; i++)
      for(ORInt j = 0; j < n; j++)
         instance.cost[i][j] = [values[index++] doubleValue];
   // Parse demand
   for(ORInt i = 0; i < m; i++) instance.demand[i] = [values[index++] doubleValue];
   // Parse opening costs
   for(ORInt j = 0; j < n; j++) instance.openingCost[j] = [values[index++] doubleValue];
   // Parse plant capacity
   for(ORInt j = 0; j < n; j++) instance.capacity[j] = [values[index++] doubleValue];
   
   [components release];
   [values release];
   return instance;
}
@end
