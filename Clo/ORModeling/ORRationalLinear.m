//
//  ORRationalLinear.m
//  ORModeling
//
//  Created by Rémy Garcia on 09/07/2018.
//

#import "ORRationalLinear.h"
#import "ORModeling/ORModeling.h"


@implementation ORRationalLinear {
   struct CPTerm {
      id<ORRationalVar>  _var;
      ORInt              _coef;
   };
   struct CPTerm* _terms;
   ORInt             _nb;
   ORInt            _max;
   id<ORRational>          _indep;
}
-(ORRationalLinear*)initORRationalLinear:(ORInt)mxs
{
   self = [super init];
   _max   = mxs;
   _terms = malloc(sizeof(struct CPTerm)*_max);
   _nb    = 0;
   _indep = [[ORRational alloc] init];
   [_indep setZero];
   return self;
}
-(void)dealloc
{
   free(_terms);
   [_indep release];
   [super dealloc];
}
-(BOOL)isZero
{
   return _nb == 0 && [_indep isZero];
}
-(BOOL)isOne
{
   return _nb== 0 && [_indep isOne];
}
-(BOOL)clausalForm
{
   BOOL cf = [_indep isZero];
   for(int i=0;i < _nb && cf; i++) {
      // TODO: look isBool
      cf = cf && _terms[i]._coef == 1; //&& [_terms[i]._var isBool];
   }
   return cf;
}
-(void)setIndependent:(id<ORRational>)idp
{
   [_indep set: idp];
}
-(void)addIndependent:(id<ORRational>)idp
{
   [_indep set: [_indep add: idp]];
}
-(id<ORRational>)independent
{
   return _indep;
}
-(id<ORRationalVar>)var:(ORInt)k
{
   return _terms[k]._var;
}
-(ORInt)coef:(ORInt)k
{
   return _terms[k]._coef;
}
-(void)addTerm:(id<ORRationalVar>)x by:(ORInt)c
{
   if (c==0) return;
   id<ORRationalRange> dom = [x domain];
   if ([dom.low eq: dom.up] && [dom.up isZero]) {
      //[dom release];
      return;
   }
   if ([dom.low eq: dom.up]) {
      id<ORRational> tmp = [ORRational rationalWith_d:c];
      [_indep set: [_indep add: [dom.low mul: tmp]]];
      //[dom release];
      [tmp release];
      return;
   }
   //[dom release];
   ORInt low = 0,up=_nb-1,mid=-1,kid;
   ORInt xid = [x  getId];
   BOOL found = NO;
   while (low <= up) {
      mid = (low+up)/2;
      kid = [_terms[mid]._var getId];
      found = kid == xid;
      if (found)
         break;
      else if (xid < kid)
         up = mid - 1;
      else low = mid + 1;
   }
   if (found) {
      _terms[mid]._coef += c;
      //assert(_terms[mid]._coef != 0);
      if (_terms[mid]._coef == 0) {
         for(ORInt k=mid+1;k<_nb;k++)
            _terms[k-1] = _terms[k];
         _nb--;
      }
   } else {
      if (_nb >= _max) {
         _terms = realloc(_terms, sizeof(struct CPTerm)*_max*2);
         _max <<= 1;
      }
      if (mid==-1)
         _terms[_nb++] = (struct CPTerm){x,c};
      else {
         if (xid > kid)
            mid++;
         for(int k=_nb-1;k>=mid;--k)
            _terms[k+1] = _terms[k];
         _terms[mid] = (struct CPTerm){x,c};
         _nb += 1;
      }
   }
}

-(void)addLinear:(ORRationalLinear*)lts
{
   for(ORInt k=0;k < lts->_nb;k++) {
      [self addTerm:lts->_terms[k]._var by:lts->_terms[k]._coef];
   }
   [self addIndependent:lts->_indep];
}
-(void)scaleBy:(ORInt)s
{
   id<ORRational> sr = [ORRational rationalWith_d:s];
   for(ORInt k=0;k<_nb;k++)
      _terms[k]._coef *= s;
   [_indep set: [_indep mul: sr]];
   [sr release];
}
-(ORBool)allPositive
{
   BOOL ap = YES;
   for(ORInt k=0;k<_nb;k++)
      ap &= _terms[k]._coef > 0;
   return ap;
}
-(ORBool)allNegative
{
   BOOL an = YES;
   for(ORInt k=0;k<_nb;k++)
      an &= _terms[k]._coef < 0;
   return an;
}
-(ORInt)nbPositive
{
   ORInt nbP = 0;
   for(ORInt k=0;k<_nb;k++)
      nbP += (_terms[k]._coef > 0);
   return nbP;
}
-(ORInt)nbNegative
{
   ORInt nbN = 0;
   for(ORInt k=0;k<_nb;k++)
      nbN += (_terms[k]._coef < 0);
   return nbN;
}
static int decCoef(const struct CPTerm* t1,const struct CPTerm* t2)
{
   return t2->_coef - t1->_coef;
}
-(void)positiveFirst  // sort by decreasing coefficient
{
   qsort(_terms, _nb, sizeof(struct CPTerm),(int(*)(const void*,const void*))&decCoef);
}

-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:128] autorelease];
   for(ORInt k=0;k<_nb;k++) {
      [buf appendFormat:@"(%d * %@) + ",_terms[k]._coef,[_terms[k]._var description]];
   }
   [buf appendFormat:@" (%@)", _indep];
   return buf;
}
-(id<ORVarArray>) variables: (id<ORAddToModel>) model
{
   return [ORFactory varArray: model range: RANGE(model,0,_nb-1) with:^id<ORVar>(ORInt i) { return _terms[i]._var; }];

}
-(id<ORRationalArray>) coefficients: (id<ORAddToModel>) model
{
   return [ORFactory rationalArray: model
                          range: RANGE(model,0,_nb-1)
                           with: ^id<ORRational>(ORInt i) {
                              id<ORRational> coef = [ORRational rationalWith_d:_terms[i]._coef];
                              [model trackMutable:coef];
                              return coef; }];
}

/*-(id<ORRationalVarArray>)scaledViews:(id<ORAddToModel>)model
{
   id<ORRationalVarArray> sx = [ORFactory rationalVarArray:model
                                           range:RANGE(model,0,_nb-1)
                                            with:^id<ORRationalVar>(ORInt i) {
                                               id<ORRationalVar> xi = _terms[i]._var;
                                               id<ORRationalVar> theView = [ORFactory intVar:model
                                                                                    var:xi
                                                                                  scale:_terms[i]._coef];
                                               return theView;
                                            }];
   return sx;
}
-(id<ORIntVar>)oneView:(id<ORAddToModel>)model
{
   id<ORIntVar> rv = [ORFactory intVar:model
                                   var:_terms[0]._var
                                 scale:_terms[0]._coef
                                 shift:_indep];
   return rv;
}*/
-(ORInt)size
{
   return _nb;
}
-(id<ORRational>)qmin
{
   id<ORRational> lb = [[ORRational alloc] init];
   id<ORRational> cr = [[ORRational alloc] init];
   id<ORRational> svlb = [[ORRational alloc] init];
   [lb set: _indep];
   for(ORInt k=0;k < _nb;k++) {
      ORInt c = _terms[k]._coef;
      [cr set_d: c];
      id<ORRationalRange> d = [_terms[k]._var domain];
      if(c > 0){
         [svlb set: [d.low mul: cr]];
      } else {
         [svlb set: [d.up mul: cr]];
      }
      [lb set: [lb add: svlb]];
      //[d release];
   }
   [svlb release];
   [cr release];
   [lb autorelease];
   return lb;
}
-(id<ORRational>)qmax
{
   id<ORRational> ub = [[ORRational alloc] init];
   id<ORRational> cr = [[ORRational alloc] init];
   id<ORRational> svub = [[ORRational alloc] init];
   [ub set: _indep];
   for(ORInt k=0;k < _nb;k++) {
      ORInt c = _terms[k]._coef;
      [cr set_d: c];
      id<ORRationalRange> d = [_terms[k]._var domain];
      if(c > 0){
         [svub set: [d.up mul: cr]];
      } else {
         [svub set: [d.low mul: cr]];
      }
      [ub set: [ub add: svub]];
      //[d release];
   }
   [cr release];
   [svub release];
   [ub autorelease];
   return ub;
}
-(id<ORConstraint>)postEQZ:(id<ORAddToModel>)model
{
   return [model addConstraint:[ORFactory rationalSum: model
                                              array: [self variables: model]
                                               coef: [self coefficients: model]
                                                 eq: [_indep neg]]];
}
-(id<ORConstraint>) postLTZ: (id<ORAddToModel>) model
{
   return [model addConstraint:[ORFactory rationalSum: model
                                             array: [self variables: model]
                                              coef: [self coefficients: model]
                                                lt: [_indep neg]]];
}
-(id<ORConstraint>) postGTZ: (id<ORAddToModel>) model
{
   return [model addConstraint:[ORFactory rationalSum: model
                                             array: [self variables: model]
                                              coef: [self coefficients: model]
                                                gt: [_indep neg]]];
}
-(id<ORConstraint>) postLEQZ: (id<ORAddToModel>) model
{
   assert(NO);
   return nil;
}
-(id<ORConstraint>) postGEQZ: (id<ORAddToModel>) model
{
   assert(NO);
   return nil;
}
-(id<ORConstraint>)postNEQZ:(id<ORAddToModel>)model
{
   return [model addConstraint:[ORFactory rationalSum:model
                                             array:[self variables:model]
                                              coef:[self coefficients:model]
                                               neq:[_indep neg]]];
}
-(id<ORConstraint>)postSET:(id<ORAddToModel>)model
{
   return [model addConstraint:[ORFactory rationalSum:model
                                             array:[self variables:model]
                                              coef:[self coefficients:model]
                                               set:[_indep neg]]];
}

- (id<ORConstraint>)postDISJ:(id<ORAddToModel>)model {
   return 0;
}
- (id<ORConstraint>)postIMPLY:(id<ORAddToModel>)model {
   return 0;
}
//-(void) postMinimize: (id<ORAddToModel>) model
//{
//   [model minimize: [self variables: model] coef: [self coefficients: model]];
//}
//-(void) postMaximize: (id<ORAddToModel>) model
//{
//   [model maximize: [self variables: model] coef: [self coefficients: model]];
//}
@end

@implementation ORRationalLinearFlip {
   id<ORRationalLinear> _real;
}
-(ORRationalLinearFlip*) initORRationalLinearFlip: (id<ORRationalLinear>)r
{
   self = [super init];
   _real = r;
   return self;
}
-(BOOL)isZero
{
   return [_real isZero];
}
-(BOOL)isOne
{
   return [_real size] == 0 && [[_real independent] isMinusOne];
}
-(BOOL)clausalForm
{
   return NO;
}
-(void) setIndependent:(id<ORRational>)idp
{
   [_real setIndependent:[idp neg]];
}
-(void) addIndependent:(id<ORRational>)idp
{
   [_real addIndependent:[idp neg]];
}
-(void) addTerm:(id<ORRationalVar>) x by: (ORInt) c
{
   [_real addTerm: x by: -c];
}
-(void) addLinear: (id<ORRationalLinear>) lts
{
   for(ORInt k=0;k < [lts size];k++) {
      [_real addTerm:[lts var:k] by: - [lts coef:k]];
   }
   [_real addIndependent:[[lts independent] neg]];
}
-(void) scaleBy: (ORInt) s
{
   [_real scaleBy: -s];
}
-(ORInt) size
{
   return [_real size];
}
-(id<ORRationalVar>) var: (ORInt) k
{
   return [_real var: k];
}
-(ORInt)coef: (ORInt) k
{
   return [_real coef:k];
}
-(id<ORRational>)qmin
{
   return [_real qmin];
}
-(id<ORRational>)qmax
{
   return [_real qmax];
}
-(id<ORRational>) independent
{
   return [_real independent];
}
-(NSString*) description
{
   return [_real description];
}
-(id<ORConstraint>)postEQZ:(id<ORAddToModel>)model
{
   return [_real postEQZ:model];
}
-(id<ORConstraint>)postNEQZ:(id<ORAddToModel>)model
{
   return [_real postNEQZ:model];
}
-(id<ORConstraint>)postLEQZ:(id<ORAddToModel>)model
{
   return [_real postLEQZ:model];
}
-(id<ORConstraint>)postGEQZ:(id<ORAddToModel>)model
{
   return [_real postGEQZ:model];
}
-(id<ORConstraint>)postLTZ:(id<ORAddToModel>)model
{
   return [_real postLTZ:model];
}
-(id<ORConstraint>)postGTZ:(id<ORAddToModel>)model
{
   return [_real postGTZ:model];
}
-(id<ORConstraint>)postDISJ:(id<ORAddToModel>)model
{
   return [_real postDISJ:model];
}
-(id<ORConstraint>)postIMPLY:(id<ORAddToModel>)model
{
   return [_real postIMPLY:model];
}
-(id<ORConstraint>)postSET:(id<ORAddToModel>)model
{
   return [_real postSET:model];
}
@end
