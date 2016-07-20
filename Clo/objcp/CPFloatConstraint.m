/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "CPFloatConstraint.h"
#import "CPFloatVarI.h"
#import "ORConstraintI.h"


@implementation CPFloatEqualc
-(id) init:(CPFloatVarI*)x and:(ORFloat)c
{
    self = [super initCPCoreConstraint: [x engine]];
    _x = x;
    _c = c;
    return self;
    
}
-(void) post
{
  //  [_x bind:_c];
}
-(NSSet*)allVars
{
    return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
    return ![_x bound];
}
-(NSString*)description
{
    return [NSString stringWithFormat:@"<x[%d] == %f>",[_x getId],_c];
}
@end

@implementation CPFloatNEqualc
-(id) init:(CPFloatVarI*)x and:(ORFloat)c
{
    self = [super initCPCoreConstraint: [x engine]];
    _x = x;
    _c = c;
    return self;
    
}
-(void) post
{
    //  [_x bind:_c];
}
-(NSSet*)allVars
{
    return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
-(ORUInt)nbUVars
{
    return ![_x bound];
}
-(NSString*)description
{
    return [NSString stringWithFormat:@"<x[%d] != %f>",[_x getId],_c];
}
@end


