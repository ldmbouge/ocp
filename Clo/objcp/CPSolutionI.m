/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPSolutionI.h"
#import <ORFoundation/ORFoundation.h>
#import "CPEngine.h"


// Not sure why this works if shot is null
@implementation CPSolutionI

-(CPSolutionI*) initCPSolution: (id<CPEngine>) solver
{
   self = [super init];
   NSArray* av = [solver allVars];
   ORULong sz = [av count];
   NSMutableArray* snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
   [av enumerateObjectsUsingBlock:^(id<ORSavable> obj, NSUInteger idx, BOOL *stop) {
      id<ORSavable> shot = [obj snapshot];
      if (shot)
         [snapshots addObject: shot];
      [shot release];
   }];
   _shots = snapshots;
   return self;
}
-(void) dealloc
{
   [_shots release];
   [super dealloc];   
}
-(int) intValue: (id) var
{
   return [[_shots objectAtIndex:[var getId]] intValue];   
}
-(BOOL) boolValue: (id) var
{
   return [[_shots objectAtIndex:[var getId]] boolValue];
}
-(ORULong) count
{
   return [_shots count];
}
-(void) restoreInto: (id<CPEngine>) engine
{
   NSArray* av = [engine allVars];
   [_shots enumerateObjectsUsingBlock:^(id<ORSnapshot> obj,NSUInteger idx,BOOL* stop) {
      [obj restoreInto:av];
   }];
}

- (void) encodeWithCoder: (NSCoder *)aCoder
{
   [aCoder encodeObject:_shots];
   
}
- (id) initWithCoder:(NSCoder *) aDecoder
{
   self = [super init];
   _shots = [[aDecoder decodeObject] retain];
   return self;
}
@end
