//
//  ORFlatten.m
//  Clo
//
//  Created by Laurent Michel on 10/5/12.
//  Copyright (c) 2012 CSE. All rights reserved.
//

#import "ORFlatten.h"
#import "ORModelI.h"

@interface ORFlattenConstraint : NSObject<ORVisitor>
-(id)init:(ORModelI*)m;
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr;
-(void) visitCardinality: (id<ORCardinality>) cstr;
-(void) visitBinPacking: (id<ORBinPacking>) cstr;
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr;
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr;
-(void) visitEqualc: (id<OREqualc>)c;
-(void) visitNEqualc: (id<ORNEqualc>)c;
-(void) visitLEqualc: (id<ORLEqualc>)c;
-(void) visitEqual: (id<OREqual>)c;
-(void) visitNEqual: (id<ORNEqual>)c;
-(void) visitLEqual: (id<ORLEqual>)c;
-(void) visitEqual3: (id<OREqual3>)c;
-(void) visitMult: (id<ORMult>)c;
-(void) visitAbs: (id<ORAbs>)c;
-(void) visitOr: (id<OROr>)c;
-(void) visitAnd:( id<ORAnd>)c;
-(void) visitImply: (id<ORImply>)c;
-(void) visitElementCst: (id<ORElementCst>)c;
-(void) visitElementVar: (id<ORElementVar>)c;
@end


@implementation ORFlatten
-(id)initORFlatten
{
   self = [super init];
   return self;
}
-(id<ORModel>)apply:(id<ORModel>)m
{
   ORModelI* out = [ORFactory createModel];  
   [m applyOnVar:^(id<ORVar> x) {
      [out captureVariable:x];
   } onObjects:^(id<ORObject> x) {
      NSLog(@"Got an object: %@",x);
   } onConstraints:^(id<ORConstraint> c) {
      ORFlattenConstraint* fc = [[ORFlattenConstraint alloc] init:out];
      [c visit:fc];
      [fc release];
   } onObjective:^(id<ORObjective> o) {
      NSLog(@"Got an objective: %@",o);
   }];
   return out;
}
@end

@implementation ORFlattenConstraint {
   ORModelI* _theModel;
}
-(id)init:(ORModelI*)m
{
   self = [super init];
   _theModel = m;
   return self;
}
-(void) visitAlldifferent: (id<ORAlldifferent>) cstr
{
   [_theModel add:cstr];
}
-(void) visitCardinality: (id<ORCardinality>) cstr
{
   [_theModel add:cstr];
}
-(void) visitBinPacking: (id<ORBinPacking>) cstr
{
   [_theModel add:cstr];   
}
-(void) visitAlgebraicConstraint: (id<ORAlgebraicConstraint>) cstr
{
   
}
-(void) visitTableConstraint: (id<ORTableConstraint>) cstr
{
   [_theModel add:cstr];   
}
-(void) visitEqualc: (id<OREqualc>)c
{
   [_theModel add:c];
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   [_theModel add:c];
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   [_theModel add:c];
}
-(void) visitEqual: (id<OREqual>)c
{
   [_theModel add:c];
}
-(void) visitNEqual: (id<ORNEqual>)c
{
   [_theModel add:c];
}
-(void) visitLEqual: (id<ORLEqual>)c
{
   [_theModel add:c];
}
-(void) visitEqual3: (id<OREqual3>)c
{
   [_theModel add:c];
}
-(void) visitMult: (id<ORMult>)c
{
   [_theModel add:c];
}
-(void) visitAbs: (id<ORAbs>)c
{
   [_theModel add:c];
}
-(void) visitOr: (id<OROr>)c
{
   [_theModel add:c];
}
-(void) visitAnd:( id<ORAnd>)c
{
   [_theModel add:c];
}
-(void) visitImply: (id<ORImply>)c
{
   [_theModel add:c];
}
-(void) visitElementCst: (id<ORElementCst>)c
{
   [_theModel add:c];
}
-(void) visitElementVar: (id<ORElementVar>)c
{
   [_theModel add:c];
}
@end