//
//  SSCPLPInstanceParser.h
//  Clo
//
//  Created by Daniel Fontaine on 3/21/13.
//
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>

@interface SSCPLPInstance : NSObject {
   ORInt numberOfClients;
   ORInt numberOfPlants;
   ORFloat** cost;
   ORFloat* demand;
   ORFloat* openingCost;
   ORFloat* capacity;
}

@property(readwrite) ORInt numberOfClients;
@property(readwrite) ORInt numberOfPlants;
@property(readwrite) ORFloat** cost;
@property(readwrite) ORFloat* demand;
@property(readwrite) ORFloat* openingCost;
@property(readwrite) ORFloat* capacity;

-(id) initWithClients: (NSInteger)m plants: (NSInteger)n;

@end

@interface SSCPLPInstanceParser : NSObject
-(SSCPLPInstance*) parseInstanceFile: (NSString*)filePath;
-(SSCPLPInstance*) parseInstanceString: (NSString*)data;
@end
