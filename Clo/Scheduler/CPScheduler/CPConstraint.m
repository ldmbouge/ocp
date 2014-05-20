/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPIntVarI.h>
#import "CPConstraint.h"


    // Single precedence propagator
    //
@implementation CPPrecedence

-(id) initCPPrecedence:(id<CPOptionalActivity>)before after:(id<CPOptionalActivity>)after {

    self = [super initCPCoreConstraint:before.startLB.engine];
    
    _before = before;
    _after  = after;
    
    NSLog(@"Create precedence constraint\n");
    
    return self;
}
-(void) dealloc {
    [super dealloc];
}
-(ORStatus) post {
    [self propagate];
    
    if (!_before.startLB.bound)
        [_before.startLB whenChangeMinPropagate:self];
    if (!_before.duration.bound)
        [_before.duration whenChangeMinPropagate:self];
    if (_before.isOptional) {
        if (!_before.top.bound)
            [_before.top whenBindPropagate:self];
    }
    if (!_after.startUB.bound)
        [_after.startUB whenChangeMinPropagate:self];
    if (_after.isOptional) {
        if (!_after.top.bound)
            [_after.top whenBindPropagate:self];
    }
    
    return ORSuspend;
}
-(void) propagate {
    if (_before.isAbsent || _after.isAbsent || _before.startUB.max + _before.duration.max <= _after.startLB.min) {
        assignTRInt(&_active, NO, _trail);
    }
    else if (_before.isPresent && _after.isPresent) {
        [_after updateStartMin:_before.startLB.min + _before.duration.min];
        [_before updateStartMax:_after.startUB.max - _before.duration.min];
        updateMaxDom((CPIntVar *)_before.duration, _after.startUB.max - _before.startLB.min);
    }
    else {
        if ([_before implyPresent:_after]) {
            [_before updateStartMax:_after.startUB.max - _before.duration.min];
            updateMaxDom((CPIntVar *)_before.duration, _after.startUB.max - _before.startLB.min);
        }
        if ([_after implyPresent:_before]) {
            [_after updateStartMin:_before.startLB.min + _before.duration.min];
        }
    }
}
-(NSSet*) allVars
{
    ORInt size = 0;
    size += (_before.isOptional ? 4 : 2);
    size += (_after .isOptional ? 3 : 1);
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:size];
    [rv addObject:_before.startLB ];
    [rv addObject:_after .startLB ];
    [rv addObject:_before.duration];
    if (_before.isOptional) {
        [rv addObject:_before.startUB];
        [rv addObject:_before.top    ];
    }
    if (_after.isOptional) {
        [rv addObject:_after.startUB];
        [rv addObject:_after.top    ];
    }
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    ORUInt nb = 0;
    if (!_before.startLB .bound) nb++;
    if (!_after .startLB .bound) nb++;
    if (!_before.duration.bound) nb++;
    if (!_after .duration.bound) nb++;
    if (_before.isOptional) {
        if (!_before.startUB.bound) nb++;
        if (!_before.top    .bound) nb++;
    }
    if (_after.isOptional) {
        if (!_after.startUB.bound) nb++;
        if (!_after.top    .bound) nb++;
    }
    return nb;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    assert(false);
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    assert(false);
}
@end
