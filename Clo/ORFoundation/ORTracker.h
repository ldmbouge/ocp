/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORTypes.h>

@protocol ORTracker <NSObject>
-(id<ORTracker>) tracker;
-(id) trackObject: (id) obj;
-(id) trackMutable: (id) obj;      // for mutable
-(id) trackImmutable: (id) obj;   // for immutable
-(id) trackVariable: (id) obj;    // for variable
-(id) trackObjective:(id) obj;
-(id) trackConstraintInGroup:(id) obj;
@optional-(id) inCache:(id)obj;
@optional-(id) addToCache:(id)obj;
@optional-(id)memoize:(id) obj;
@end


