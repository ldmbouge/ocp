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

- (id) initWithArrays:(NSMutableArray *)cnodeArray
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

- (void) parseXMLFile {
    NSURL *xmlPath = [[NSBundle mainBundle] URLForResource:@"sample"
                                             withExtension:@"xml"];
    
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
    
    if ([elementName isEqualToString:@"cnode"]){
        Cnode *thisCnode = [[Cnode alloc] initWithId:self.currentCnodeId
                                         cnodeMemory:self.currentCnodeMemory
                                      cnodeBandwidth:self.currentCnodeBandwidth];
        int size;
        size = sizeof(self.cnodeArray);
        [self.cnodeArray[size] addObject:thisCnode];
    }
    
    else if ([elementName isEqualToString:@"service"]){
        Service *thisService = [[Service alloc] initWithId:self.currentServiceId
                                             serviceMemory:self.currentServiceMemory
                                          serviceBandwidth:self.currentServiceBandwidth
                                               serviceZone:self.currentServiceZone
                                            serviceMaxConn:self.currentServiceMaxConn];
        int size;
        size = sizeof(self.serviceArray);
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
        size = sizeof(self.secArray);
        [self.secArray[size] addObject:thisSecurityTech];
    }
    
    self.element = nil;
}

@end
