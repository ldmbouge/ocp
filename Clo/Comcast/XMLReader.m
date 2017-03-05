//
//  XMLReader.m
//  Clo
//
//  Created by Sarah Peck on 2/23/17.
//
//

#import "XMLReader.h"
#import "GDataXMLNode.h"

struct cnodes
{
    int cnode_id;
};

@implementation XMLReader

-(id) init {
    self = [super init];
    
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"xml"];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (doc == nil) {return nil;}
    
    NSLog(@"%@", doc.rootElement);
    /*
    [doc release];
    [xmlData release];
    */
    
    return self;
}

-(void) sayHi: (NSString*)name {
    NSLog(@"Hi, %@", name);
}

@end
