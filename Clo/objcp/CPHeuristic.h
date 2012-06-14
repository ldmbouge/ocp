//
//  CPHeuristic.h
//  Clo
//
//  Created by Laurent Michel on 5/15/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objcp/CPSolver.h>
#import <objcp/CPData.h>
#import <objcp/CPArray.h>

@protocol CPHeuristic <NSObject>
-(float)varOrdering:(id<CPIntVar>)x;
-(float)valOrdering:(int)v forVar:(id<CPIntVar>)x;
-(void)initHeuristic:(id<CPIntVar>*)t length:(CPInt)l;
-(void)initHeuristic:(NSMutableArray*)array;
-(id<CPIntVarArray>)allIntVars;
@end
