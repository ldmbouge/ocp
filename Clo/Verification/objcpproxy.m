//
//  objcpproxy.m
//  Verification
//
//  Created by zitoun on 5/28/19.
//

#import "objcpproxy.h"
#import "objcpUtils.h"

@implementation OBJCPProxy : NSObject
+(id<OBJCPGateway>) initOBJCPGateway
{
   id<OBJCPGateway> x = [[OBJCPGatewayI alloc] initExplicitOBJCPGateway:nil];
   return x;
}
+(id<OBJCPGateway,OBJCPIntGateway,OBJCPBVGateway,OBJCPFloatGateway,OBJCPBoolGateway>) initOBJCPGateway:(ORCmdLineArgs*) opt
{
   id<OBJCPGateway,OBJCPIntGateway,OBJCPBVGateway,OBJCPFloatGateway,OBJCPBoolGateway> x;
   if([opt withAux])
      x = [[OBJCPGatewayAux alloc] initExplicitOBJCPGateway:opt];
   else
      x = [[OBJCPGatewayI alloc] initExplicitOBJCPGateway:opt];
   return x;
}
+(objcp_var_type) sortName2Type:(const char *) name
{
   ORInt i;
   for(i = 0; i < NB_TYPE; i++){
      if(strcmp(name,typeName[i]) == 0){
         break;
      }
   }
   return (i<NB_TYPE) ? typeObj[i] : 0;
}
@end
