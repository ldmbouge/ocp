#include "smtlib2abstractparser.h"
#include "smtlib2abstractparser_private.h"
#include <gmp.h>

int main(int argc, char* argv[]){
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
   smtlib2_abstract_parser aParser;
   smtlib2_abstract_parser_init(&aParser,0);
   smtlib2_abstract_parser_parse(&aParser, fp);
   return 0;
}
