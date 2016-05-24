#include "parser.hpp"
#include <iostream>
#include <iomanip>

Parser::Parser()
{
   _integral = false;
}

Parser::~Parser() {}

void Parser::run(const char* fn)
{
   extern int yyparse(Parser*);
   extern FILE* yyin;
   //extern int yydebug;
   //yydebug = 1;
   if (fn!=0) 
      yyin = fopen(fn,"r");
   yyparse(this);
   fclose(yyin);
}

extern "C" int yywrap()
{  /* This is to _chain_ scanning several files */
   return 1;
}

int yyerror(Parser* p,const char* s)
{
   extern int yylineno;
   std::cerr << "FILE:" << yylineno << ':' << s << std::endl;
   return 0;
}

