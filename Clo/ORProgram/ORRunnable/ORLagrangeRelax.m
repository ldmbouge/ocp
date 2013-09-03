//
//  ORLagrangeRelax.m
//  Clo
//
//  Created by Daniel Fontaine on 8/28/13.
//
//

#import "ORLagrangeRelax.h"

@implementation ORLagrangeRelax {
@protected
    id<ORModel> _srcModel;
    id<ORModel> _relaxModel;
    id<ORSignature> _sig;
}

-(id) initWithModel: (id<ORModel>)m
{
    return [self initWithModel: m relax: [m constraints]];
}

-(id) initWithModel: (id<ORModel>)m relax: (NSArray*)cstrs
{
    self = [super init];
    if(self) {
        _srcModel = m;
        _relaxModel = [m relaxConstraints: cstrs];
        _sig = nil;
    }
    return self;
}

-(id<ORSignature>) signature
{
    if(_sig == nil) {
        _sig = [ORFactory createSignature: @"complete.columnIn"];
    }
    return _sig;
}

-(id<ORModel>) model
{
    return _srcModel;
}

-(void) run {
    
}

@end
