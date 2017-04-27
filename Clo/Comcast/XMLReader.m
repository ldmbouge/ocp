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
    
    // Let's XML!
    [self parseXMLFile];
    
    return self;
}

- (void) parserDidStartDocument:(NSXMLParser *)parser{
}

- (void) parseXMLFile {
    
    NSURL * baseURL = [NSURL fileURLWithPath:@"/Users/sarah/DocumentsFolder/projects/objcp-private/Clo/Comcast"];
    NSURL * xmlPath = [NSURL URLWithString:@"./sample.xml" relativeToURL:baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:xmlPath];
    NSString * error;
    if ([xmlPath checkResourceIsReachableAndReturnError: &error]){
    } else {
        NSLog(@"Cant fnd XML");
    }
    bool xmlFile = [NSURLConnection sendSynchronousRequest:request
                                    returningResponse:nil
                                                error:nil];
    
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlPath];
    self.parser.delegate = self;
    [self.parser parse];
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(nullable NSString *)namespaceURI
 qualifiedName:(nullable NSString *)qName
    attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    self.element = elementName;
}

- (void) parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string{
    if ([self.element isEqualToString:@"cnodeId"]){
        self.currentCnodeId = string.intValue;
    }
    else if ([self.element isEqualToString:@"cnodeMemory"]){
        self.currentCnodeMemory = string.intValue;
    }
    else if ([self.element isEqualToString:@"cnodeBandwidth"]){
        self.currentCnodeBandwidth = string.intValue;
    }
    else if ([self.element isEqualToString:@"serviceId"]){
        self.currentServiceId = string.intValue;
    }
    else if ([self.element isEqualToString:@"serviceFixMemory"]){
        self.currentServiceFixMemory = string.intValue;
    }
    else if ([self.element isEqualToString:@"serviceFixMemory"]){
        self.currentServiceScaledMemory = string.doubleValue;
    }
    else if ([self.element isEqualToString:@"serviceFixBandwidth"]){
        self.currentServiceFixBandwidth = string.intValue;
    }
    else if ([self.element isEqualToString:@"serviceFixMemory"]){
        self.currentServiceScaledBandwidth = string.doubleValue;
    }
    else if ([self.element isEqualToString:@"serviceZone"]){
        self.currentServiceZone = string.intValue;
    }
    else if ([self.element isEqualToString:@"serviceMaxConn"]){
        self.currentServiceMaxConn = string.intValue;
    }
    else if ([self.element isEqualToString:@"secId"]){
        self.currentSecId = string.intValue;
    }
    else if ([self.element isEqualToString:@"secFixedMemory"]){
        self.currentSecFixedMemory = string.intValue;
    }
    else if ([self.element isEqualToString:@"secFixedBandwidth"]){
        self.currentSecFixedBandwidth = string.intValue;
    }
    else if ([self.element isEqualToString:@"secScaledMemory"]){
        self.currentSecScaledMemory = string.doubleValue;
    }
    else if ([self.element isEqualToString:@"secScaledBandwidth"]){
        self.currentSecScaledBandwidth = string.doubleValue;
    }
    else if ([self.element isEqualToString:@"secZone"]){
        self.currentSecZone = string.intValue;
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(nonnull NSString *)elementName
  namespaceURI:(nullable NSString *)namespaceURI
 qualifiedName:(nullable NSString *)qName{
    if ([elementName isEqualToString:@"cnode"]){
        Cnode *thisCnode = [[Cnode alloc] initWithId:self.currentCnodeId
                                         cnodeMemory:self.currentCnodeMemory
                                      cnodeBandwidth:self.currentCnodeBandwidth];
        int size = [cnodeArray[0] cnodeExtId];
        size ++;
        [self.cnodeArray addObject:thisCnode];
        Cnode *sizeNode = [[Cnode alloc] initWithId:size cnodeMemory:0 cnodeBandwidth:0];
        [self.cnodeArray removeObjectAtIndex:0];
        [self.cnodeArray insertObject:sizeNode atIndex:0];
    }
    
    else if ([elementName isEqualToString:@"service"]){
        Service *thisService = [[Service alloc] initWithId:self.currentServiceId
                                          serviceFixMemory:self.currentServiceFixMemory
                                       serviceScaledMemory:self.currentServiceScaledMemory
                                          serviceFixBandwidth:self.currentServiceFixBandwidth
                                    serviceScaledBandwidth:self.currentServiceScaledBandwidth
                                               serviceZone:self.currentServiceZone
                                            serviceMaxConn:self.currentServiceMaxConn];
        int size;
        size = [serviceArray[0] serviceId];
        size ++;
        [self.serviceArray addObject:thisService];
        Service *sizeNode = [[Service alloc] initWithId:size serviceMemory:0 serviceBandwidth:0 serviceZone:0 serviceMaxConn:0];
        [self.serviceArray removeObjectAtIndex:0];
        [self.serviceArray insertObject:sizeNode atIndex:0];
    }
    
    else if ([elementName isEqualToString:@"sec"]){
        SecurityTech *thisSecurityTech = [[SecurityTech alloc] initWithId:self.currentSecId
                                                           secFixedMemory:self.currentSecFixedMemory
                                                        secFixedBandwidth:self.currentSecFixedBandwidth
                                                          secScaledMemory:self.currentSecScaledMemory
                                                       secScaledBandwidth:self.currentSecScaledBandwidth
                                                                  secZone:self.currentSecZone];
        int size;
        size = [secArray[0] secId];
        size ++;
        [self.secArray addObject:thisSecurityTech];
        SecurityTech *sizeNode = [[SecurityTech alloc] initWithId:size secFixedMemory:0 secFixedBandwidth:0 secScaledMemory:0 secScaledBandwidth:0 secZone:0];
        [self.secArray removeObjectAtIndex:0];
        [self.secArray insertObject: sizeNode atIndex:0];
    }
    
    self.element = nil;
}

- (void) parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"Parsing complete");
}

@end
