/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORModeling/ORLSFlatten.h>
#import <ORFoundation/ORArrayI.h>
#import "ORModelI.h"
#import "ORDecompose.h"
#import "ORSetI.h"
#import "ORVarI.h"

@implementation ORLSFlatten
-(id)initORLSFlatten: (id<ORAddToModel>) into
{
   self = [super initORFlatten:into];
   return self;
}

-(void) visitMinimizeVar: (id<ORObjectiveFunctionVar>) v
{
   _result = [_into minimizeVar:[v var]];
}
-(void) visitMaximizeVar: (id<ORObjectiveFunctionVar>) v
{
   _result = [_into maximizeVar:[v var]];
}
-(void) visitMinimizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   _result = [_into minimize:e.expr]; // leave as an expression. Concretization does the rest.
//   switch ([e expr].vtype) {
//      case ORTInt: {
//         ORIntLinear* terms = [ORNormalizer intLinearFrom: [e expr] model: _into];
//         id<ORIntVar> alpha = [ORNormalizer intVarIn:terms for:_into];
//         _result = [_into minimizeVar: alpha];
//      }break;
//      case ORTFloat: {
//         @throw [[ORExecutionError alloc] initORExecutionError:"not implemented yet"];
//      }break;
//      default:
//         break;
//   }
}
-(void) visitMaximizeExpr: (id<ORObjectiveFunctionExpr>) e
{
   _result = [_into maximize:e.expr];
//   switch ([e expr].vtype) {
//      case ORTInt: {
//         ORIntLinear* terms = [ORNormalizer intLinearFrom: [e expr] model: _into];
//         id<ORIntVar> alpha = [ORNormalizer intVarIn:terms for:_into];
//         _result = [_into maximizeVar: alpha];
//      }break;
//      case ORTFloat:{
//         @throw [[ORExecutionError alloc] initORExecutionError:"not implemented yet"];
//      }break;
//      default: break;
//   }
}
-(void) visitMinimizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   id<ORIntVarArray> ca = [self flattenIt:[v array]];
   id<ORDoubleArray>  cc = [self flattenIt:[v coef]];
   _result = [_into minimize:ca coef:cc];
}
-(void) visitMaximizeLinear: (id<ORObjectiveFunctionLinear>) v
{
   id<ORIntVarArray> ca = [self flattenIt:[v array]];
   id<ORDoubleArray>  cc = [self flattenIt:[v coef]];
   _result = [_into maximize:ca coef:cc];
}
@end
