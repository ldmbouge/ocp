/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORParallel.h>
#import <ORFoundation/ORError.h>

@implementation ORConcurrency (OR)
+(void) parall: (ORRange) R do: (ORInt2Void) closure untilNotifiedBy: (id<ORInformer>) informer
{
   ORInt2Void clo = [closure copy];
   __block ORBool done = NO;
   [ORConcurrency parall: R
                      do: ^void(ORInt i) {
                         [informer whenNotifiedDo: ^(void) {
                            printf("Notification\n");
                            done = YES;
                            @throw [[ORInterruptI alloc] initORInterruptI];
                         }];
                         if (done  == NO) {
                            @try {
                               clo(i);
                            }
                            @catch (ORInterruptI* e) {
                               [e release];
                            }
                         }
                      }
    ];
   [clo release];
}

@end
