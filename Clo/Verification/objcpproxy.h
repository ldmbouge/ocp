//
//  objcpproxy.h
//  Clo
//
//  Created by zitoun on 5/28/19.
//
#import "objcpgateway.h"
#import "objcpgatewayI.h"
#import "objcpgatewayAux.h"


@interface OBJCPProxy : NSObject
+(id<OBJCPGateway>) initOBJCPGateway;
+(id<OBJCPGateway,OBJCPIntGateway,OBJCPBVGateway,OBJCPFloatGateway,OBJCPBoolGateway>) initOBJCPGateway:(ORCmdLineArgs*) opt;
+(objcp_var_type) sortName2Type:(const char *) name;
@end
