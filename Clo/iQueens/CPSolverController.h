/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "CPFirstViewController.h"
#import "CPSecondViewController.h"

@interface CPEngineController : NSObject {
   CPFirstViewController* _view1;
   CPSecondViewController* _view2;
}
-(id)bindControllerOne:(CPSecondViewController*)svc;
-(id)bindControllerTwo:(CPSecondViewController*)svc;
@end
