//
//  ORRationalDecompose.h
//  Clo
//
//  Created by Rémy Garcia on 09/07/2018.
//

#import <ORFoundation/ORFoundation.h>
#import "ORRationalLinear.h"

@interface ORRationalLinearizer : ORVisitor<NSObject> {
   id<ORRationalLinear>   _terms;
   id<ORAddToModel>  _model;
   id<ORRationalVar>       _eqto;
}
-(id)init:(id<ORRationalLinear>)t model:(id<ORAddToModel>)model equalTo:(id<ORRationalVar>)x;
-(id)init:(id<ORRationalLinear>)t model:(id<ORAddToModel>)model;
@end

@interface ORRationalSubst   : ORVisitor<NSObject> {
   id<ORRationalVar>      _rv;
   id<ORAddToModel> _model;
   ORCLevel             _c;
}
-(id)initORRationalSubst:(id<ORAddToModel>) model;
-(id)initORRationalSubst:(id<ORAddToModel>) model by:(id<ORRationalVar>)x;
-(id<ORRationalVar>)result;
@end
