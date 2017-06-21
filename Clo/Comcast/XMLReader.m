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

// model properties
@property int vMax;
@property int maxConn;

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

- (XMLReader *) initWithArrays:(NSMutableArray *)cnodeArray
         serviceArray:(NSMutableArray *)serviceArray
             secArray:(NSMutableArray *)secArray{
    self = [super init];    
    if (self){
        self.cnodeArray = cnodeArray;
        self.serviceArray = serviceArray;
        self.secArray = secArray;
    }
    
    return self;
}

- (void) parserDidStartDocument:(NSXMLParser *)parser{
}

- (void) parseXMLFile: (NSString*)path; {
    
    NSURL * xmlPath = [NSURL URLWithString: [NSString stringWithFormat: @"file://%@", path]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:xmlPath];
    NSString *_Nullable error;
    if ([xmlPath checkResourceIsReachableAndReturnError: &error]){
    } else {
        NSLog(@"Cant fnd XML");
    }
    
    NSError *err=nil;
    NSXMLDocument* xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL: xmlPath options: NSXMLDocumentTidyXML error: &err];
    
    NSXMLNode* maxConnNode = [[xmlDoc rootElement] nodesForXPath: @"maxConn" error: &err][0];
    ORInt maxConn = [[maxConnNode stringValue] intValue];
    
    NSArray* cnodes = [[xmlDoc rootElement] nodesForXPath: @"cnode" error: &err];
    for(NSXMLNode* node in cnodes) {
        NSXMLNode* n = [node nodesForXPath: @"id" error: &err][0];
        ORInt nodeId = [[n stringValue] intValue];
        n = [node nodesForXPath: @"cnodeMemory" error: &err][0];
        ORInt mem = [[n stringValue] intValue];
        n = [node nodesForXPath: @"cnodeBandwidth" error: &err][0];
        ORInt bw = [[n stringValue] intValue];
        [cnodeArray addObject: [[Cnode alloc] initWithId: nodeId cnodeMemory: mem cnodeBandwidth: bw]];
    }
    
    NSArray* services = [[xmlDoc rootElement] nodesForXPath: @"service" error: &err];
    for(NSXMLNode* node in services) {
        NSXMLNode* n = [node nodesForXPath: @"id" error: &err][0];
        ORInt nodeId = [[n stringValue] intValue];
        n = [node nodesForXPath: @"serviceFixMemory" error: &err][0];
        ORInt mem = [[n stringValue] intValue];
        n = [node nodesForXPath: @"serviceFixBandwidth" error: &err][0];
        ORInt bw = [[n stringValue] intValue];
        n = [node nodesForXPath: @"serviceZone" error: &err][0];
        ORInt zone = [[n stringValue] intValue];
        [serviceArray addObject: [[Service alloc] initWithId: nodeId serviceFixMemory:mem serviceScaledMemory: 1 serviceFixBandwidth: bw
                                    serviceScaledBandwidth: 1 serviceZone: zone serviceMaxConn: maxConn]];
    }
    
    NSArray* sec = [[xmlDoc rootElement] nodesForXPath: @"sec" error: &err];
    for(NSXMLNode* node in sec) {
        NSXMLNode* n = [node nodesForXPath: @"id" error: &err][0];
        ORInt nodeId = [[n stringValue] intValue];
        n = [node nodesForXPath: @"secFixedMemory" error: &err][0];
        ORInt memFix = [[n stringValue] intValue];
        n = [node nodesForXPath: @"secScaledMemory" error: &err][0];
        ORInt memScaled = [[n stringValue] intValue];
        n = [node nodesForXPath: @"secFixedBandwidth" error: &err][0];
        ORInt bwFix = [[n stringValue] intValue];
        n = [node nodesForXPath: @"secScaledBandwidth" error: &err][0];
        ORInt bwScaled = [[n stringValue] intValue];
        n = [node nodesForXPath: @"secZone" error: &err][0];
        ORInt zone = [[n stringValue] intValue];
        [secArray addObject: [[SecurityTech alloc] initWithId: nodeId secFixedMemory: memFix secFixedBandwidth: bwFix
            secScaledMemory: memScaled secScaledBandwidth: bwScaled secZone: zone]];

    }
//    bool xmlFile = [NSURLConnection sendSynchronousRequest:request
//                                    returningResponse:nil
//                                                error:nil];
//    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlPath];
//    self.parser.delegate = self;
//    [self.parser parse];
}

//- (void)parser:(NSXMLParser *)parser
//didStartElement:(NSString *)elementName
//  namespaceURI:(nullable NSString *)namespaceURI
// qualifiedName:(nullable NSString *)qName
//    attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
//    self.element = elementName;
//}
//
//- (void) parser:(NSXMLParser *)parser
//foundCharacters:(NSString *)string{
//    if ([self.element isEqualToString:@"cnodeId"]){
//        self.currentCnodeId = string.intValue;
//    }
//    else if ([self.element isEqualToString:@"cnodeMemory"]){
//        self.currentCnodeMemory = string.intValue;
//    }
//    else if ([self.element isEqualToString:@"cnodeBandwidth"]){
//        self.currentCnodeBandwidth = string.intValue;
//    }
//    else if ([self.element isEqualToString:@"serviceId"]){
//        self.currentServiceId = string.intValue;
//    }
//    else if ([self.element isEqualToString:@"serviceFixMemory"]){
//        self.currentServiceFixMemory = string.intValue;
//    }
//    else if ([self.element isEqualToString:@"serviceFixMemory"]){
//        self.currentServiceScaledMemory = string.doubleValue;
//    }
//    else if ([self.element isEqualToString:@"serviceFixBandwidth"]){
//        self.currentServiceFixBandwidth = string.intValue;
//    }
//    else if ([self.element isEqualToString:@"serviceFixMemory"]){
//        self.currentServiceScaledBandwidth = string.doubleValue;
//    }
//    else if ([self.element isEqualToString:@"serviceZone"]){
//        self.currentServiceZone = string.intValue;
//    }
//    else if ([self.element isEqualToString:@"serviceMaxConn"]){
//        self.currentServiceMaxConn = string.intValue;
//    }
//    else if ([self.element isEqualToString:@"secId"]){
//        self.currentSecId = string.intValue;
//    }
//    else if ([self.element isEqualToString:@"secFixedMemory"]){
//        self.currentSecFixedMemory = string.intValue;
//    }
//    else if ([self.element isEqualToString:@"secFixedBandwidth"]){
//        self.currentSecFixedBandwidth = string.intValue;
//    }
//    else if ([self.element isEqualToString:@"secScaledMemory"]){
//        self.currentSecScaledMemory = string.doubleValue;
//    }
//    else if ([self.element isEqualToString:@"secScaledBandwidth"]){
//        self.currentSecScaledBandwidth = string.doubleValue;
//    }
//    else if ([self.element isEqualToString:@"secZone"]){
//        self.currentSecZone = string.intValue;
//    }
//}
//
//- (void)parser:(NSXMLParser *)parser
// didEndElement:(nonnull NSString *)elementName
//  namespaceURI:(nullable NSString *)namespaceURI
// qualifiedName:(nullable NSString *)qName{
//    if ([elementName isEqualToString:@"cnode"]){
//        Cnode *thisCnode = [[Cnode alloc] initWithId:self.currentCnodeId
//                                         cnodeMemory:self.currentCnodeMemory
//                                      cnodeBandwidth:self.currentCnodeBandwidth];
//        int size = [cnodeArray[0] cnodeExtId];
//        size ++;
//        [self.cnodeArray addObject:thisCnode];
//        Cnode *sizeNode = [[Cnode alloc] initWithId:size cnodeMemory:0 cnodeBandwidth:0];
//        [self.cnodeArray removeObjectAtIndex:0];
//        [self.cnodeArray insertObject:sizeNode atIndex:0];
//    }
//    
//    else if ([elementName isEqualToString:@"service"]){
//        Service *thisService = [[Service alloc] initWithId:self.currentServiceId
//                                          serviceFixMemory:self.currentServiceFixMemory
//                                       serviceScaledMemory:self.currentServiceScaledMemory
//                                          serviceFixBandwidth:self.currentServiceFixBandwidth
//                                    serviceScaledBandwidth:self.currentServiceScaledBandwidth
//                                               serviceZone:self.currentServiceZone
//                                            serviceMaxConn:self.currentServiceMaxConn];
//        int size;
//        size = [serviceArray[0] serviceId];
//        size ++;
//        [self.serviceArray addObject:thisService];
//        Service *sizeNode = [[Service alloc] initWithId:size serviceFixMemory:0 serviceScaledMemory:0 serviceFixBandwidth:0 serviceScaledBandwidth:0 serviceZone:0 serviceMaxConn:0];
//        [self.serviceArray removeObjectAtIndex:0];
//        [self.serviceArray insertObject:sizeNode atIndex:0];
//    }
//    
//    else if ([elementName isEqualToString:@"sec"]){
//        SecurityTech *thisSecurityTech = [[SecurityTech alloc] initWithId:self.currentSecId
//                                                           secFixedMemory:self.currentSecFixedMemory
//                                                        secFixedBandwidth:self.currentSecFixedBandwidth
//                                                          secScaledMemory:self.currentSecScaledMemory
//                                                       secScaledBandwidth:self.currentSecScaledBandwidth
//                                                                  secZone:self.currentSecZone];
//        int size;
//        size = [secArray[0] secId];
//        size ++;
//        [self.secArray addObject:thisSecurityTech];
//        SecurityTech *sizeNode = [[SecurityTech alloc] initWithId:size secFixedMemory:0 secFixedBandwidth:0 secScaledMemory:0 secScaledBandwidth:0 secZone:0];
//        [self.secArray removeObjectAtIndex:0];
//        [self.secArray insertObject: sizeNode atIndex:0];
//    }
//    
//    self.element = nil;
//}
//
//- (void) parserDidEndDocument:(NSXMLParser *)parser{
//    NSLog(@"Parsing complete");
//}

@end
