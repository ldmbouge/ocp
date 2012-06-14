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

#import "CPCreateI.h"
#import "CPDataI.h"
#import "CPI.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPAllDifferentDC.h"
#import "CPBasicConstraint.h"
#import "CPCardinality.h"

@implementation CPI (Create)
+(CPI*) create
{
    return [[CPI alloc] init];
}
+(CPI*) createRandomized
{
    [CPStreamManager setRandomized];
    return [[CPI alloc] init];
}
+(CPI*) createDeterministic
{
    return [[CPI alloc] init];
}

+(CPI*) createFor:(CPSolverI*)fdm
{
   return [[CPI alloc] initFor:fdm];
}
@end

@implementation SemCP(Create)
+(SemCP*) create
{
   return [[SemCP alloc] init];
}
+(SemCP*) createRandomized
{
   [CPStreamManager setRandomized];
   return [[SemCP alloc] init];
}
+(SemCP*) createDeterministic
{
   return [[SemCP alloc] init];
}

+(SemCP*) createFor:(CPSolverI*)fdm
{
   return [[SemCP alloc] initFor:fdm];
}
@end


