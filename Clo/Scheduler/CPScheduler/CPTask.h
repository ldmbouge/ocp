/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>

@protocol CPTask <ORObject>
-(ORInt) getId;
-(ORInt) start;
-(ORInt) end;
-(ORInt) minDuration;
-(ORInt) maxDuration;
-(void) updateStart: (ORInt) newStart;
-(void) updateEnd: (ORInt) newEnd;
-(void) updateMinDuration: (ORInt) newMinDuration;
-(void) updateMaxDuration: (ORInt) newMaxDuration;
@end


