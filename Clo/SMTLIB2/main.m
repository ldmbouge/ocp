//
//  main.m
//  SMTLIB2
//
//  Created by Greg Johnson on 2/24/14.
//
//
#import <mach/mach.h>

#import <Foundation/Foundation.h>
//#import <ORFoundation/ORFoundation.h>
//#import <ORFoundation/ORAVLTree.h>
//#import <ORModeling/ORModeling.h>
//#import <ORProgram/ORProgram.h>
//#import <objcp/CPObjectQueue.h>
//#import <objcp/CPFactory.h>

//#import <objcp/CPConstraint.h>
//#import <objcp/CPBitMacros.h>
//#import <objcp/CPBitArray.h>
//#import <objcp/CPBitArrayDom.h>
//#import <objcp/CPBitConstraint.h>
//#include <Verification/objcpgateway.h>
#import <Verification/objcpgateway.h>
#include <Verification/smtlib2abstractparser_private.h>
#include <Verification/smtlib2abstractparser.h>
#import <Verification/smtlib2objcp.h>

//#import "ORCmdLineArgs.h"

void report_memory(void) {
   struct task_basic_info info;
   mach_msg_type_number_t size = sizeof(info);
   kern_return_t kerr = task_info(mach_task_self(),
                                  TASK_BASIC_INFO,
                                  (task_info_t)&info,
                                  &size);
   if( kerr == KERN_SUCCESS ) {
      NSLog(@"Memory in use (in MB): %f", (double)info.resident_size/1048576);
   } else {
      NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
   }
}

int main(int argc, const char * argv[])
{
   char fname[256];
   FILE* fp;
      
   clock_t start,finish;
   
//   mallocWatch();
   
   start = clock();
   
   if (argc > 1){
      fp = fopen(argv[1], "r");
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
   finish = clock();
   double totalTime;
   totalTime =((double)(finish - start))/CLOCKS_PER_SEC;
   NSLog(@"     Overall Time (s): %f\n\n",totalTime);
   report_memory();
//   NSLog(@"%@",mallocReport());

   return 0;
   }
