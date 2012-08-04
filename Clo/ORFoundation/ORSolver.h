//
//  ORSolver.h
//  Clo
//
//  Created by Pascal Van Hentenryck on 8/3/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ORSolver <NSObject,ORTracker>
-(void)            saveSolution;
-(void)            restoreSolution;
-(ORStatus)        close;
-(bool)            closed;
-(void)            trackObject:(id)obj;
-(NSMutableArray*) allVars;
@end