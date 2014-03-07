//
//  main.m
//  SMTLIB2
//
//  Created by Greg Johnson on 2/24/14.
//
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORAVLTree.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORProgram.h>
#import <objcp/CPObjectQueue.h>
#import <objcp/CPFactory.h>

#import <objcp/CPConstraint.h>
#import <objcp/CPBitMacros.h>
#import <objcp/CPBitArray.h>
#import <objcp/CPBitArrayDom.h>
#import <objcp/CPBitConstraint.h>
//#import "../Verification/OBJCPGateway.h"
//#import "../smtlib2abstractparser_private.h"
//#import "../smtlib2abstractparser.h"
#import "smtlib2objcp.h"
#import "objcpgateway.h"

int main(int argc, const char * argv[])
{

   OBJCPGateway* cpgw = [[OBJCPGateway initOBJCPGateway] initExplicitOBJCPGateway];
   
         char fname[256];
      FILE* fp;
      
      
      if (argc > 1){
         fp = fopen(fname, "r");
         if (fp==NULL) {
            printf("Error opening file.\n");
            return false;
         }
      }
      else{
         fprintf(stdout, "Enter data file path and filename:");
         fscanf(stdin, "%s", fname);
         fp = fopen(fname, "r");
         if (fp==NULL) {
            printf("Error opening file.\n");
            return false;
         }
      }
   smtlib2_objcp_parser *objcp_parser = smtlib2_objcp_parser_new();
   smtlib2_abstract_parser_parse((smtlib2_abstract_parser *)objcp_parser, fp);
   smtlib2_objcp_parser_delete(objcp_parser);
   return 0;
   }
