////
////  XMLReader.h
////  Clo
////
////  Created by Sarah Peck on 2/23/17.
////
////

#import <Foundation/Foundation.h>

@interface XMLReader : NSObject <NSXMLParserDelegate>

@property NSMutableArray *cnodeArray;
@property NSMutableArray *serviceArray;
@property NSMutableArray *secArray;

- (XMLReader *) initWithArrays: (NSMutableArray *) cnodeArray
         serviceArray: (NSMutableArray *) serviceArray
             secArray: (NSMutableArray *) secArray;

- (void) parserDidStartDocument:(NSXMLParser *)parser;

- (void) parseXMLFile;

- (void) parser:(NSXMLParser *)parser
 didStartElement:(NSString *)elementName
    namespaceURI:(nullable NSString *)namespaceURI
   qualifiedName:(nullable NSString *)qName
      attributes:(NSDictionary<NSString *, NSString *> *)attributeDict;

- (void) parser:(NSXMLParser *)parser
 foundCharacters:(NSString *)string;

- (void) parser:(NSXMLParser *) parser
   didEndElement:(nonnull NSString *) elementName
    namespaceURI:(nullable NSString *) namespaceURI
   qualifiedName:(nullable NSString *) qname;


@end
