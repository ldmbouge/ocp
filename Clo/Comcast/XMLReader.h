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

- (id) initWithArrays: (NSMutableArray *) cnodeArray
         serviceArray: (NSMutableArray *) serviceArray
             secArray: (NSMutableArray *) secArray;
- (void) parseXMLFile;

@end
