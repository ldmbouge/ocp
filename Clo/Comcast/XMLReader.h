////
////  XMLReader.h
////  Clo
////
////  Created by Sarah Peck on 2/23/17.
////
////

#import <Foundation/Foundation.h>

#if defined(__linux__)
#define _Nonnull
#define _Nullable
#endif

@interface XMLReader : NSObject <NSXMLParserDelegate>

@property (nonatomic,strong) NSMutableArray * _Nonnull cnodeArray;
@property (nonatomic,strong) NSMutableArray * _Nonnull serviceArray;
@property (nonatomic,strong) NSMutableArray * _Nonnull secArray;
@property (nonatomic,strong) NSMutableArray* _Nonnull  C;
@property (nonatomic,strong) NSMutableDictionary* _Nonnull  D;
@property (nonatomic) int maxVMs;
@property (nonatomic) int maxPerVM;
@property (nonatomic) int maxCONN;
@property (nonatomic) int vmMEM;

- (XMLReader * _Nonnull) initWithArrays: (NSMutableArray * _Nonnull) cnodeArray
         serviceArray: (NSMutableArray * _Nonnull) serviceArray
             secArray: (NSMutableArray * _Nonnull) secArray;

- (void) parserDidStartDocument:(NSXMLParser * _Nonnull)parser;

- (void) parseXMLFile: (NSString* _Nonnull)path;

/*- (void) parser:(NSXMLParser * _Nonnull)parser
 didStartElement:(NSString * _Nonnull)elementName
    namespaceURI:(nullable NSString *)namespaceURI
   qualifiedName:(nullable NSString *)qName
      attributes:(NSDictionary<NSString *, NSString *> * _Nullable)attributeDict;

- (void) parser:(NSXMLParser * _Nonnull)parser
 foundCharacters:(NSString * _Nullable)string;

- (void) parser:(NSXMLParser * _Nonnull) parser
   didEndElement:(nonnull NSString *) elementName
    namespaceURI:(nullable NSString *) namespaceURI
   qualifiedName:(nullable NSString *) qname;
*/

@end
