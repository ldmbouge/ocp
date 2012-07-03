/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>

@protocol CPError <NSObject>
-(char*) msg;
@end

@interface CPSearchError : NSObject <CPError>
{
@private
	const char* _message;
}
-(CPSearchError*) initCPSearchError: (const char*) msg;
-(const char*) msg;
@end  

@interface CPExecutionError : NSObject <CPError>
{
@private
	const char* _message;
}
-(CPExecutionError*) initCPExecutionError: (const char*) msg;
-(const char*) msg;
@end  


@interface CPInternalError : NSObject <CPError>
{
@private
	const char* _message;
}
-(CPInternalError*) initCPInternalError: (const char*) msg;
-(const char*) msg;
@end  

@interface CPRemoveOnDenseDomainError : CPExecutionError <CPError>
{
}
-(CPRemoveOnDenseDomainError*) initCPRemoveOnDenseDomainError;
@end  



