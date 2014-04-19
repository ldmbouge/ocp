/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>

@protocol ORActivity <ORObject>
-(ORInt) getId;
-(id<ORIntVar>) start;
-(ORInt) duration;
@end

@interface ORActivity : ORObject<ORActivity> 
-(id<ORActivity>) initORActivity: (id<ORTracker>) tracker horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;
@end