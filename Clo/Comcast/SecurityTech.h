//
//  SecurityTech.h
//  Clo
//
//  Created by Sarah Peck on 3/6/17.
//
//

#import <Foundation/Foundation.h>

@interface SecurityTech : NSObject

@property int secId;
@property NSString* secProp1;
@property NSString* secProp2;

- (id) initWithId: (int) secId
       secProp1: (NSString *) secProp1
       secProp2: (NSString *) secProp2;

@end
