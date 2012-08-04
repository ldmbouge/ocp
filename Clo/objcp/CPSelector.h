/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objcp/CPTypes.h>

@interface OPTSelect : NSObject {
    id<ORRandomStream> _stream;
    id<ORIntIterator>  _range;
    ORInt2Bool         _filter;
    CPInt2Int          _order;
    CPInt              _direction;
}
-(OPTSelect*) initOPTSelectWithRange: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (CPInt2Int) order;
-(void)           dealloc;
-(CPInt)              min;
-(CPInt)              max;
-(CPInt)              any;
-(CPInt)           choose;
@end

@interface CPSelect : NSObject {
    OPTSelect* _select;
}
-(CPSelect*) initCPSelect: (id<CP>) cp withRange: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (CPInt2Int) order;
-(void)           dealloc;
-(CPInt)              min;
-(CPInt)              max;
-(CPInt)              any;
@end

@interface CPSelectMinRandomized : NSObject {
  id<ORRandomStream> _stream;
  id<ORIntIterator>  _range;
  ORInt2Bool         _filter;
  CPInt2Int          _order;
}
-(CPSelectMinRandomized*) initWithRange: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (CPInt2Int) order;
-(void)            dealloc;
-(CPInt)           choose;
@end

@interface CPSelectMax : NSObject {
   id<ORIntIterator> _range;
   ORInt2Bool        _filter;
   CPInt2Int         _order;
}
-(CPSelectMax*) initSelectMax:(id<CP>)cp range: (id<ORIntIterator>) range suchThat: (ORInt2Bool) filter orderedBy: (CPInt2Int) order;
-(void)         dealloc;
-(CPInt)        choose;
@end
