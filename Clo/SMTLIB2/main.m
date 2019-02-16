//
//  main.m
//  SMTLIB2
//
//  Created by Greg Johnson on 2/24/14.
//
//
#import <mach/mach.h>

#import <Foundation/Foundation.h>
#import <Verification/Verification.h>


int main(int argc, const char * argv[])
{
   char fname[256];
   FILE* fp=NULL;
   
   if (argc > 1){
      fp = fopen(argv[1], "r");
      if (fp==NULL) {
         printf("Error opening file.\n");
         return false;
      }
   }
   else{
      fprintf(stdout, "Enter data file path and filename:");
      while (fp==NULL) {
         fscanf(stdin, "%s", fname);
         fp = fopen(fname, "r");
         if (fp==NULL) {
            printf("Error opening file.\n");
         }
      }
   }

   smtlib2_objcp_parser *objcp_parser = smtlib2_objcp_parser_new_with_opts((Options){argc, argv});
   smtlib2_abstract_parser_parse((smtlib2_abstract_parser *)objcp_parser, fp);
   smtlib2_objcp_parser_delete(objcp_parser);
   return 0;
   }
