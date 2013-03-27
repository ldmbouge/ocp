//
//  ORCopy.h
//  Clo
//
//  Created by Daniel Fontaine on 1/22/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>



@interface ORCopy : NSObject<ORVisitor>
-(id)initORCopy: (NSZone*)zone;
-(id<ORModel>) copyModel: (id<ORModel>)model;
@end
