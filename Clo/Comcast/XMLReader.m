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

// security technology properties
@property int currentSecId;
@property int currentSecProp1;
@property int currentSecProp2;

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
    else if ([self.element isEqualToString:@"secId"]){
        self.currentSecId = string.intValue;
    }
    else if ([self.element isEqualToString:@"secProp1"]){
        self.currentSecProp1 = string.intValue;
    }
    else if ([self.element isEqualToString:@"secProp2"]){
        self.currentSecProp2 = string.intValue;
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
                                          serviceBandwidth:self.currentServiceBandwidth];
        int size;
        size = sizeof(self.serviceArray);
        [self.serviceArray[size] addObject:thisService];
    }
    
    else if ([elementName isEqualToString:@"sec"]){
        SecurityTech *thisSecurityTech = [[SecurityTech alloc] initWithId:self.currentSecId
                                                                 secProp1:self.currentSecProp1
                                                                 secProp2:self.currentSecProp2];
        int size;
        size = sizeof(self.secArray);
        [self.secArray[size] addObject:thisSecurityTech];
    }
    
    self.element = nil;
}

@end
