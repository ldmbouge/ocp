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
@property int currentServiceMemory;
@property int currentServiceBandwidth;
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

- (XMLReader *) initWithArrays:(NSMutableArray *)cnodeArray
         serviceArray:(NSMutableArray *)serviceArray
             secArray:(NSMutableArray *)secArray{
    self = [super init];
    if (self){
        self.cnodeArray = cnodeArray;
        self.serviceArray = serviceArray;
        self.secArray = secArray;
    }
    NSLog(@"Initialized! \n");
    
    // Let's XML!
    [self parseXMLFile];
    
    return self;
}

- (void) parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"File found and parsing has begun");
}

- (void) parseXMLFile {
    
    NSURL * baseURL = [NSURL fileURLWithPath:@"/Users/sarah/DocumentsFolder/projects/objcp-private/Clo/Comcast"];
    NSURL * xmlPath = [NSURL URLWithString:@"./sample.xml" relativeToURL:baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:xmlPath];
    NSString * error;
    if ([xmlPath checkResourceIsReachableAndReturnError: &error]){
        NSLog(@"XML Reached!");
    }
    else {
        NSLog(@"Cant fnd XML");
    }
    bool xmlFile = [NSURLConnection sendSynchronousRequest:request
                                    returningResponse:nil
                                                error:nil];
    NSLog(@"Entering ParseXMLPath \n");
    
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlPath];
    //[self.parser setDelegate:self];
    self.parser.delegate = self;
    [self.parser parse];
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(nullable NSString *)namespaceURI
 qualifiedName:(nullable NSString *)qName
    attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    NSLog(@"entering parser the first \n");
    self.element = elementName;
}

- (void) parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string{
    NSLog(@"Entering parser the second \n");
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
    else if ([self.element isEqualToString:@"serviceMemory"]){
        self.currentServiceMemory = string.intValue;
    }
    else if ([self.element isEqualToString:@"serviceBandwidth"]){
        self.currentServiceBandwidth = string.intValue;
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
    NSLog(@"Entering parser the third \n");
    if ([elementName isEqualToString:@"cnode"]){
        Cnode *thisCnode = [[Cnode alloc] initWithId:self.currentCnodeId
                                         cnodeMemory:self.currentCnodeMemory
                                      cnodeBandwidth:self.currentCnodeBandwidth];
        NSLog(@"i read a cnode!");
        int size;
        size = (sizeof self.cnodeArray);
        NSLog(@"size: %i \n", size);
        [self.cnodeArray[size] addObject:thisCnode];
        NSLog(@"I added an object to cnodeArray!!");
        NSLog(@"New size: %lu \n", (sizeof self.cnodeArray));
    }
    
    else if ([elementName isEqualToString:@"service"]){
        Service *thisService = [[Service alloc] initWithId:self.currentServiceId
                                             serviceMemory:self.currentServiceMemory
                                          serviceBandwidth:self.currentServiceBandwidth
                                               serviceZone:self.currentServiceZone
                                            serviceMaxConn:self.currentServiceMaxConn];
        int size;
        size = (sizeof self.serviceArray);
        [self.serviceArray[size] addObject:thisService];
    }
    
    else if ([elementName isEqualToString:@"sec"]){
        SecurityTech *thisSecurityTech = [[SecurityTech alloc] initWithId:self.currentSecId
                                                           secFixedMemory:self.currentSecFixedMemory
                                                        secFixedBandwidth:self.currentSecFixedBandwidth
                                                          secScaledMemory:self.currentSecScaledMemory
                                                       secScaledBandwidth:self.currentSecScaledBandwidth
                                                                  secZone:self.currentSecZone];
        int size;
        size = (sizeof self.secArray);
        [self.secArray[size] addObject:thisSecurityTech];
    }
    
    self.element = nil;
}

- (void) parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"Parsing complete");
}

@end
