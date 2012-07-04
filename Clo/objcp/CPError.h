/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORFoundation/ORError.h"

@interface CPSearchError : NSObject <ORError>
{
@private
	const char* _message;
}
-(CPSearchError*) initCPSearchError: (const char*) msg;
-(const char*) msg;
@end  

@interface CPInternalError : NSObject <ORError>
{
@private
	const char* _message;
}
-(CPInternalError*) initCPInternalError: (const char*) msg;
-(const char*) msg;
@end  

@interface CPRemoveOnDenseDomainError : ORExecutionError <ORError>
{
}
-(CPRemoveOnDenseDomainError*) initCPRemoveOnDenseDomainError;
@end  



