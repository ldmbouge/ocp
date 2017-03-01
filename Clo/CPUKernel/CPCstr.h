//
//  CPCstr.h
//  Clo
//
//  Created by Laurent Michel on 2/25/17.
//
//

#ifndef CPCstr_h
#define CPCstr_h

#import <ORFoundation/ORFoundation.h>

@protocol CPGroup;

@protocol CPConstraint <ORConstraint>
-(ORUInt)      getId;
-(void)        setGroup:(id<CPGroup>) g;
-(id<CPGroup>) group;
-(void) post;
@end


#endif /* CPCstr_h */
