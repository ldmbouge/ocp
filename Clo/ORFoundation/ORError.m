/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORError.h"


@implementation ORExecutionError
-(ORExecutionError*) initORExecutionError: (const char*) msg
{
	self = [super init];
	_message = msg;
	return self;
}
-(const char*) msg 
{
	return _message;
}
-(NSString *)description
{
   return [NSString stringWithCString:_message encoding:NSASCIIStringEncoding];
}
@end

@implementation ORSearchError
-(ORSearchError*) initORSearchError: (const char*) msg
{
	self = [super init];
	_message = msg;
	return self;
}
-(const char*) msg 
{
	return _message;
}
@end
