/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ***********************************************************************/

#import "CPSolutionI.h"
#import "CPSolver.h"

@implementation CPSolutionI
-(CPSolutionI*)initCPSolution:(id<CPSolver>)solver
{
   self = [super init];
   NSArray* av = [solver allVars];
   CPUInt sz = [av count];
   NSMutableArray* snapshots = [[NSMutableArray alloc] initWithCapacity:sz];
   [av enumerateObjectsUsingBlock:^(id<CPSavable> obj, NSUInteger idx, BOOL *stop) {
      id<CPSavable> shot = [obj snapshot];
      if (shot)
         [snapshots addObject: shot];
      [shot release];
   }];
   _shots = snapshots;
   return self;
}
-(void)dealloc
{
   [_shots release];
   [super dealloc];   
}
-(int)intValue:(id)var
{
   return [[_shots objectAtIndex:[var getId]] intValue];   
}
-(BOOL)boolValue:(id)var
{
   return [[_shots objectAtIndex:[var getId]] boolValue];
}
-(CPUInt)count
{
   return [_shots count];
}
-(void)restoreInto:(id<CPSolver>)solver
{
   NSArray* av = [solver allVars];
   [_shots enumerateObjectsUsingBlock:^(id<CPSnapshot> obj,NSUInteger idx,BOOL* stop) {
      [obj restoreInto:av];
   }];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_shots];
   
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _shots = [[aDecoder decodeObject] retain];
   return self;
}
@end
