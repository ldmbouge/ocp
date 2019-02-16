/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#ifndef Clo_ORError_h
#define Clo_ORError_h

#import <Foundation/Foundation.h>

@protocol ORError <NSObject>
-(char*) msg;
@end

@interface ORExecutionError : NSObject <ORError>
{
	const char* _message;
}
-(ORExecutionError*) initORExecutionError: (const char*) msg;
-(const char*) msg;
-(NSString *)description;
@end 

@interface ORSearchError : NSObject <ORError>
{
@private
	const char* _message;
}
-(ORSearchError*) initORSearchError: (const char*) msg;
-(const char*) msg;
@end
#endif
