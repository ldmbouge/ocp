//
//  CPTable.h
//  Clo
//
//  Created by Pascal Van Hentenryck on 5/7/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPTable <NSObject>
-(void) insert: (CPInt) i : (CPInt) j : (CPInt) k;
-(void) addEmptyTuple;
-(void) fill: (CPInt) j with: (CPInt) val;
-(void) print;
-(void) close;
@end
