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
@property int secProp1;
@property int secProp2;

- (id) initWithId: (int) secId
       secProp1: (int) secProp1
       secProp2: (int) secProp2;

@end
