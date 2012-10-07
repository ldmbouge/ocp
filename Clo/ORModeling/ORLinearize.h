//
//  ORLinearize.h
//  Clo
//
//  Created by Daniel Fontaine on 10/6/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORModeling/ORModeling.h>
#import <ORFoundation/ORArrayI.h>

@interface ORLinearize : NSObject<ORModelTransformation>
-(id)initORLinearize;
-(id<ORModel>) apply:(id<ORModel>)m;
@end

