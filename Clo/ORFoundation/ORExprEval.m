//
//  ORExprEval.m
//  Clo
//
//  Created by Daniel Fontaine on 9/18/13.
//
//

#import "ORExprEval.h"
#import "ORExprI.h"

@implementation ORIntExprEval {
    id<ORASolver> _solver;
    ORInt _value;
}

-(id) initORIntExprEval: (id<ORASolver>)solver;{
    self = [super init];
    if(self) _solver = solver;
    return self;
}

-(ORInt) intValue: (id<ORExpr>)e {
    _value = 0;
    [e visit: self];
    return _value;
}
-(void) visitIntVar: (id<ORIntVar>) v  {
    _value = [_solver intValue: v];
}
-(void) visitIntegerI: (id<ORInteger>) e {
    _value = [e intValue];
    
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e {
    _value = [e intValue];
}
-(void) visitExprPlusI: (id<ORExpr>) e {
    ORExprBinaryI* be = (ORExprBinaryI*)e;
    [[be left] visit: self];
    ORInt l = _value;
    [[be right] visit: self];
    ORInt r = _value;
    _value = l + r;
}
-(void) visitExprMinusI: (id<ORExpr>) e {
    ORExprBinaryI* be = (ORExprBinaryI*)e;
    [[be left] visit: self];
    ORInt l = _value;
    [[be right] visit: self];
    ORInt r = _value;
    _value = l - r;
}
-(void) visitExprMulI: (id<ORExpr>) e {
    ORExprBinaryI* be = (ORExprBinaryI*)e;
    [[be left] visit: self];
    ORInt l = _value;
    [[be right] visit: self];
    ORInt r = _value;
    _value = l * r;
}
-(void) visitExprSumI: (id<ORExpr>) e {
    ORExprSumI* sum = (ORExprSumI*)e;
    [[sum expr] visit: self];
}
-(void) visitExprProdI: (id<ORExpr>) e {
    ORExprProdI* prod = (ORExprProdI*)e;
    [[prod expr] visit: self];
}

@end

@implementation ORFloatExprEval {
    id<ORASolver> _solver;
    ORFloat _value;
}

-(id) initORFloatExprEval: (id<ORASolver>)solver;{
    self = [super init];
    if(self) _solver = solver;
    return self;
}

-(ORFloat) floatValue: (id<ORExpr>)e {
    _value = 0.0;
    [e visit: self];
    return _value;
}

-(void) visitIntVar: (id<ORIntVar>) v  {
    _value = [_solver intValue: v];
}
-(void) visitFloatVar: (id<ORFloatVar>) v  {
    _value = [_solver floatValue: v];
}
-(void) visitIntegerI: (id<ORInteger>) e {
    _value = [e value];
}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e {
    _value = [e intValue];
}
-(void) visitMutableFloatI: (id<ORMutableFloat>) e {
    _value = [e floatValue];
}
-(void) visitFloatI: (id<ORFloatNumber>) e {
    _value = [e value];
}
-(void) visitExprPlusI: (id<ORExpr>) e {
    ORExprBinaryI* be = (ORExprBinaryI*)e;
    [[be left] visit: self];
    ORInt l = _value;
    [[be right] visit: self];
    ORInt r = _value;
    _value = l + r;
}
-(void) visitExprMinusI: (id<ORExpr>) e {
    ORExprBinaryI* be = (ORExprBinaryI*)e;
    [[be left] visit: self];
    ORInt l = _value;
    [[be right] visit: self];
    ORInt r = _value;
    _value = l - r;
}
-(void) visitExprMulI: (id<ORExpr>) e {
    ORExprBinaryI* be = (ORExprBinaryI*)e;
    [[be left] visit: self];
    ORInt l = _value;
    [[be right] visit: self];
    ORInt r = _value;
    _value = l * r;
}
-(void) visitExprSumI: (id<ORExpr>) e {
    ORExprSumI* sum = (ORExprSumI*)e;
    [[sum expr] visit: self];
}
-(void) visitExprProdI: (id<ORExpr>) e {
    ORExprProdI* prod = (ORExprProdI*)e;
    [[prod expr] visit: self];
}

@end
