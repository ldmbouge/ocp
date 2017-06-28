////
////  XMLReader.m
////  Clo
////
////  Created by Sarah Peck on 2/23/17.
////
////

#import "XMLReader.h"
#import "Cnode.h"
#import "Service.h"
#import "SecurityTech.h"

@interface XMLReader ()

@property NSXMLParser *parser;
@property NSString *element;

// cnode properties
@property int currentCnodeId;
@property int currentCnodeMemory;
@property int currentCnodeBandwidth;

// service properties
@property int currentServiceId;
@property int currentServiceFixMemory;
@property double currentServiceScaledMemory;
@property int currentServiceFixBandwidth;
@property double currentServiceScaledBandwidth;
@property int currentServiceZone;
@property int currentServiceMaxConn;

// security technology properties
@property int currentSecId;
@property int currentSecFixedMemory;
@property int currentSecFixedBandwidth;
@property double currentSecScaledMemory;
@property double currentSecScaledBandwidth;
@property int currentSecZone;

@end

@implementation XMLReader

@synthesize cnodeArray;
@synthesize serviceArray;
@synthesize secArray;
@synthesize maxVMs;
@synthesize maxPerVM;
@synthesize maxCONN;
@synthesize vmMEM;
@synthesize C;
@synthesize D;

- (XMLReader *) initWithArrays:(NSMutableArray *)cnArr
         serviceArray:(NSMutableArray *)srvArr
             secArray:(NSMutableArray *)secArr{
    self = [super init];    
    if (self){
        self.cnodeArray = cnArr;
        self.serviceArray = srvArr;
        self.secArray = secArr;
    }
    
    return self;
}

- (void) parserDidStartDocument:(NSXMLParser *)parser{
}

- (NSString *)resolvePath:(NSString *)path {
   NSString *expandedPath = [[path stringByExpandingTildeInPath] stringByStandardizingPath];
   const char *cpath = [expandedPath cStringUsingEncoding:NSUTF8StringEncoding];
   char *resolved = NULL;
   char *returnValue = realpath(cpath, resolved);
   
   if (returnValue == NULL && resolved != NULL) {
      printf("Error with path: %s\n", resolved);
      // if there is an error then resolved is set with the path which caused the issue
      // returning nil will prevent further action on this path
      return nil;
   } else if (returnValue == NULL)
      return nil;
   return [NSString stringWithCString:returnValue encoding:NSUTF8StringEncoding];
}

- (void) parseXMLFile: (NSString*)path {
   NSURL* absPath = [NSURL URLWithString:[self resolvePath:path]];
   NSURL * xmlPath = [NSURL URLWithString: [NSString stringWithFormat: @"file://%@", absPath]];
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:xmlPath];
    NSError* _Nullable error;
    if ([xmlPath checkResourceIsReachableAndReturnError: &error]){
    } else {
        NSLog(@"Cant fnd XML");
    }
    
    NSError *err=nil;
    NSXMLDocument* xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL: xmlPath options: NSXMLDocumentTidyXML error: &err];
    
   
   maxVMs   =  [[[[xmlDoc rootElement] nodesForXPath: @"maxVMs" error: &err][0]  stringValue] intValue];
   maxPerVM =  [[[[xmlDoc rootElement] nodesForXPath: @"maxPerVM" error: &err][0]  stringValue] intValue];
   maxCONN  =  [[[[xmlDoc rootElement] nodesForXPath: @"maxCONN" error: &err][0]  stringValue] intValue];
   vmMEM    =  [[[[xmlDoc rootElement] nodesForXPath: @"vmMEM" error: &err][0]  stringValue] intValue];
   
    NSArray* cnodes = [[xmlDoc rootElement] nodesForXPath: @"cnode" error: &err];
    for(NSXMLNode* node in cnodes) {
        NSXMLNode* n = [node nodesForXPath: @"id" error: &err][0];
        int nodeId = [[n stringValue] intValue];
        n = [node nodesForXPath: @"cnodeMemory" error: &err][0];
        int mem = [[n stringValue] intValue];
        n = [node nodesForXPath: @"cnodeBandwidth" error: &err][0];
        int bw = [[n stringValue] intValue];
        [cnodeArray addObject: [[Cnode alloc] initWithId: nodeId cnodeMemory: mem cnodeBandwidth: bw]];
    }
    
    NSArray* services = [[xmlDoc rootElement] nodesForXPath: @"service" error: &err];
    for(NSXMLNode* node in services) {
        NSXMLNode* n = [node nodesForXPath: @"id" error: &err][0];
        int nodeId = [[n stringValue] intValue];
        n = [node nodesForXPath: @"serviceFixMemory" error: &err][0];
        int mem = [[n stringValue] intValue];
        n = [node nodesForXPath: @"serviceFixBandwidth" error: &err][0];
        int bw = [[n stringValue] intValue];
        n = [node nodesForXPath: @"serviceZone" error: &err][0];
        int zone = [[n stringValue] intValue];
        [serviceArray addObject: [[Service alloc] initWithId: nodeId serviceFixMemory:mem serviceScaledMemory: 1 serviceFixBandwidth: bw
                                    serviceScaledBandwidth: 1 serviceZone: zone serviceMaxConn: maxCONN]];
    }
    
    NSArray* sec = [[xmlDoc rootElement] nodesForXPath: @"sec" error: &err];
    for(NSXMLNode* node in sec) {
        NSXMLNode* n = [node nodesForXPath: @"id" error: &err][0];
        int nodeId = [[n stringValue] intValue];
        n = [node nodesForXPath: @"secFixedMemory" error: &err][0];
        int memFix = [[n stringValue] intValue];
        n = [node nodesForXPath: @"secScaledMemory" error: &err][0];
        int memScaled = [[n stringValue] intValue];
        n = [node nodesForXPath: @"secFixedBandwidth" error: &err][0];
        int bwFix = [[n stringValue] intValue];
        n = [node nodesForXPath: @"secScaledBandwidth" error: &err][0];
        int bwScaled = [[n stringValue] intValue];
        n = [node nodesForXPath: @"secZone" error: &err][0];
        int zone = [[n stringValue] intValue];
        [secArray addObject: [[SecurityTech alloc] initWithId: nodeId
                                               secFixedMemory: memFix
                                            secFixedBandwidth: bwFix
                                              secScaledMemory: memScaled
                                           secScaledBandwidth: bwScaled
                                                      secZone: zone]];
    }
   NSArray* conn = [[xmlDoc rootElement] nodesForXPath:@"conn/entry" error:&err];
   C = [NSMutableArray arrayWithCapacity:services.count];
   for(int i=0;i < services.count;i++)
      [C addObject:[NSMutableArray arrayWithCapacity:services.count]];
   for(NSXMLNode* node in conn) {
      NSXMLNode* n;
      n = [node nodesForXPath:@"row" error:&err][0];
      int row = [[n stringValue] intValue];
      n = [node nodesForXPath:@"col" error:&err][0];
      int col = [[n stringValue] intValue];
      n = [node nodesForXPath:@"value" error:&err][0];
      int value = [[n stringValue] intValue];
      C[row][col] = [NSNumber numberWithInt:value];
   }
   NSArray* demand = [[xmlDoc rootElement] nodesForXPath:@"demand/entry" error:&err];
   D = [NSMutableDictionary dictionaryWithCapacity:services.count];
   for(NSXMLNode* node in demand) {
      NSXMLNode* n;
      n = [node nodesForXPath:@"idx" error:&err][0];
      int idx = [[n stringValue] intValue];
      n = [node nodesForXPath:@"value" error:&err][0];
      int value = [[n stringValue] intValue];
      [D setObject:@(value) forKey:@(idx)];
   }
   NSLog(@"D = %@",D);
}

@end
