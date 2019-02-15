/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.3"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 1

/* Using locations.  */
#define YYLSP_NEEDED 1

/* Substitute the variable and function names.  */
#define yyparse smtlib2_parser_parse
#define yylex   smtlib2_parser_lex
#define yyerror smtlib2_parser_error
#define yylval  smtlib2_parser_lval
#define yychar  smtlib2_parser_char
#define yydebug smtlib2_parser_debug
#define yynerrs smtlib2_parser_nerrs
#define yylloc smtlib2_parser_lloc

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     BINCONSTANT = 258,
     HEXCONSTANT = 259,
     BVCONSTANT = 260,
     RATCONSTANT = 261,
     NUMERAL = 262,
     STRING = 263,
     SYMBOL = 264,
     KEYWORD = 265,
     TK_EOF = 266,
     TK_AS = 267,
     TK_UNDERSCORE = 268,
     TK_LET = 269,
     TK_BANG = 270,
     TK_FORALL = 271,
     TK_EXISTS = 272,
     TK_SET_LOGIC = 273,
     TK_DECLARE_SORT = 274,
     TK_DEFINE_SORT = 275,
     TK_DECLARE_FUN = 276,
     TK_DEFINE_FUN = 277,
     TK_PUSH = 278,
     TK_POP = 279,
     TK_ASSERT = 280,
     TK_CHECK_SAT = 281,
     TK_GET_ASSERTIONS = 282,
     TK_GET_UNSAT_CORE = 283,
     TK_GET_PROOF = 284,
     TK_SET_OPTION = 285,
     TK_GET_INFO = 286,
     TK_SET_INFO = 287,
     TK_GET_ASSIGNMENT = 288,
     TK_GET_MODEL = 289,
     TK_GET_VALUE = 290,
     TK_EXIT = 291,
     TK_INTERNAL_PARSE_TERMS = 292
   };
#endif
/* Tokens.  */
#define BINCONSTANT 258
#define HEXCONSTANT 259
#define BVCONSTANT 260
#define RATCONSTANT 261
#define NUMERAL 262
#define STRING 263
#define SYMBOL 264
#define KEYWORD 265
#define TK_EOF 266
#define TK_AS 267
#define TK_UNDERSCORE 268
#define TK_LET 269
#define TK_BANG 270
#define TK_FORALL 271
#define TK_EXISTS 272
#define TK_SET_LOGIC 273
#define TK_DECLARE_SORT 274
#define TK_DEFINE_SORT 275
#define TK_DECLARE_FUN 276
#define TK_DEFINE_FUN 277
#define TK_PUSH 278
#define TK_POP 279
#define TK_ASSERT 280
#define TK_CHECK_SAT 281
#define TK_GET_ASSERTIONS 282
#define TK_GET_UNSAT_CORE 283
#define TK_GET_PROOF 284
#define TK_SET_OPTION 285
#define TK_GET_INFO 286
#define TK_SET_INFO 287
#define TK_GET_ASSIGNMENT 288
#define TK_GET_MODEL 289
#define TK_GET_VALUE 290
#define TK_EXIT 291
#define TK_INTERNAL_PARSE_TERMS 292




/* Copy the first part of user declarations.  */
#line 28 "smtlib2bisonparser.y"

#include "smtlib2parserinterface.h"
#include "smtlib2bisonparser.h"
#include "smtlib2flexlexer.h"
#include <limits.h>
#include <assert.h>

#define YYMAXDEPTH LONG_MAX
#define YYLTYPE_IS_TRIVIAL 1

void smtlib2_parser_error(YYLTYPE *yylloc, yyscan_t scanner,
                          smtlib2_parser_interface *parser,
                          const char *s);

/*
 * Stores information about an identifier. Used to handle type annotations and
 * indexed identifiers, without supporting such things in the core solver
 */
typedef struct smtlib2_indexed_identifier {
    char *name;
    smtlib2_vector *idx;
    smtlib2_sort tp;
} smtlib2_indexed_identifier;

smtlib2_indexed_identifier *smtlib2_indexed_identifier_new(
    const char *n, smtlib2_vector *i, smtlib2_sort t);
void smtlib2_indexed_identifier_delete(smtlib2_indexed_identifier *i);

smtlib2_term smtlib2_make_term_from_identifier(
    smtlib2_parser_interface *parser,
    smtlib2_indexed_identifier *ident, smtlib2_vector *args);



/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 1
#endif

#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 73 "smtlib2bisonparser.y"
{
    char *string;
    smtlib2_vector *termlist;
    smtlib2_sort sort;
    smtlib2_vector *sortlist;
    smtlib2_vector *numlist;
    smtlib2_term term;
    void *identifier;
    smtlib2_charbuf *buf;
    char **attribute;
    smtlib2_vector *attributelist;
    smtlib2_vector *stringlist;
    smtlib2_vector *intlist;
}
/* Line 193 of yacc.c.  */
#line 227 "smtlib2bisonparser.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 252 "smtlib2bisonparser.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int i)
#else
static int
YYID (i)
    int i;
#endif
{
  return i;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL \
	     && defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
    YYLTYPE yyls;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE) + sizeof (YYLTYPE)) \
      + 2 * YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  43
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   234

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  42
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  48
/* YYNRULES -- Number of rules.  */
#define YYNRULES  105
/* YYNRULES -- Number of states.  */
#define YYNSTATES  221

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   292

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      38,    39,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    40,     2,    41,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     5,     7,     9,    11,    13,    15,    17,
      19,    21,    23,    25,    27,    29,    31,    33,    35,    37,
      39,    41,    43,    45,    46,    51,    57,    65,    74,    82,
      91,   100,   110,   115,   120,   125,   129,   133,   137,   141,
     147,   153,   159,   165,   170,   176,   178,   180,   182,   184,
     188,   195,   199,   206,   208,   210,   216,   224,   232,   240,
     242,   244,   249,   251,   257,   259,   265,   267,   269,   271,
     273,   279,   281,   284,   287,   289,   291,   294,   298,   300,
     303,   305,   308,   310,   313,   315,   318,   323,   329,   331,
     333,   336,   341,   343,   348,   350,   353,   355,   361,   366,
     368,   371,   373,   375,   378,   380
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int8 yyrhs[] =
{
      43,     0,    -1,    44,    -1,    46,    -1,    47,    -1,    48,
      -1,    49,    -1,    50,    -1,    51,    -1,    52,    -1,    53,
      -1,    54,    -1,    55,    -1,    56,    -1,    57,    -1,    58,
      -1,    59,    -1,    60,    -1,    62,    -1,    63,    -1,    64,
      -1,    65,    -1,    45,    -1,    -1,    38,    18,    83,    39,
      -1,    38,    19,     9,     7,    39,    -1,    38,    20,     9,
      38,    39,    85,    39,    -1,    38,    20,     9,    38,    86,
      39,    85,    39,    -1,    38,    21,     9,    38,    39,    85,
      39,    -1,    38,    21,     9,    38,    84,    39,    85,    39,
      -1,    38,    22,     9,    38,    39,    85,    66,    39,    -1,
      38,    22,     9,    38,    79,    39,    85,    66,    39,    -1,
      38,    23,     7,    39,    -1,    38,    24,     7,    39,    -1,
      38,    25,    66,    39,    -1,    38,    26,    39,    -1,    38,
      27,    39,    -1,    38,    28,    39,    -1,    38,    29,    39,
      -1,    38,    30,    10,     7,    39,    -1,    38,    30,    10,
       6,    39,    -1,    38,    30,    10,     9,    39,    -1,    38,
      30,    10,     8,    39,    -1,    38,    31,    10,    39,    -1,
      38,    32,    10,    61,    39,    -1,     7,    -1,     6,    -1,
       9,    -1,     8,    -1,    38,    33,    39,    -1,    38,    35,
      38,    88,    39,    39,    -1,    38,    36,    39,    -1,    38,
      37,    38,    78,    39,    39,    -1,    67,    -1,    68,    -1,
      38,    15,    66,    72,    39,    -1,    38,    80,    38,    81,
      39,    66,    39,    -1,    38,    16,    38,    79,    39,    66,
      39,    -1,    38,    17,    38,    79,    39,    66,    39,    -1,
      71,    -1,    69,    -1,    38,    69,    78,    39,    -1,    70,
      -1,    38,    12,    70,    85,    39,    -1,     9,    -1,    38,
      13,     9,    76,    39,    -1,     7,    -1,     6,    -1,     3,
      -1,     4,    -1,    38,    13,     5,     7,    39,    -1,    73,
      -1,    72,    73,    -1,    10,    74,    -1,    61,    -1,    14,
      -1,    38,    39,    -1,    38,    75,    39,    -1,    74,    -1,
      75,    74,    -1,     7,    -1,    76,     7,    -1,     7,    -1,
      77,     7,    -1,    66,    -1,    78,    66,    -1,    38,     9,
      85,    39,    -1,    79,    38,     9,    85,    39,    -1,    14,
      -1,    82,    -1,    82,    81,    -1,    38,     9,    66,    39,
      -1,     9,    -1,     9,    40,     7,    41,    -1,    85,    -1,
      84,    85,    -1,     9,    -1,    38,    13,     9,    77,    39,
      -1,    38,     9,    84,    39,    -1,    87,    -1,    86,    87,
      -1,     9,    -1,    89,    -1,    88,    89,    -1,    74,    -1,
      10,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   171,   171,   178,   179,   180,   181,   182,   183,   184,
     185,   186,   187,   188,   189,   190,   191,   192,   193,   194,
     195,   196,   197,   201,   207,   215,   226,   231,   242,   248,
     261,   266,   276,   285,   295,   302,   309,   316,   323,   331,
     338,   345,   361,   370,   379,   389,   393,   397,   401,   408,
     415,   428,   435,   445,   449,   457,   474,   481,   491,   501,
     505,   511,   522,   524,   533,   538,   548,   553,   558,   564,
     570,   581,   586,   595,   605,   609,   613,   617,   652,   657,
     666,   673,   684,   692,   703,   708,   717,   727,   739,   747,
     748,   752,   761,   763,   774,   779,   788,   793,   799,   809,
     815,   823,   833,   838,   847,   851
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "BINCONSTANT", "HEXCONSTANT",
  "BVCONSTANT", "RATCONSTANT", "NUMERAL", "STRING", "SYMBOL", "KEYWORD",
  "TK_EOF", "\"as\"", "\"_\"", "\"let\"", "\"!\"", "\"forall\"",
  "\"exists\"", "\"set-logic\"", "\"declare-sort\"", "\"define-sort\"",
  "\"declare-fun\"", "\"define-fun\"", "\"push\"", "\"pop\"", "\"assert\"",
  "\"check-sat\"", "\"get-assertions\"", "\"get-unsat-core\"",
  "\"get-proof\"", "\"set-option\"", "\"get-info\"", "\"set-info\"",
  "\"get-assignment\"", "\"get-model\"", "\"get-value\"", "\"exit\"",
  "\".internal-parse-terms\"", "'('", "')'", "'['", "']'", "$accept",
  "single_command", "command", "cmd_error", "cmd_set_logic",
  "cmd_declare_sort", "cmd_define_sort", "cmd_declare_fun",
  "cmd_define_fun", "cmd_push", "cmd_pop", "cmd_assert", "cmd_check_sat",
  "cmd_get_assertions", "cmd_get_unsat_core", "cmd_get_proof",
  "cmd_set_option", "cmd_get_info", "cmd_set_info", "info_argument",
  "cmd_get_assignment", "cmd_get_value", "cmd_exit",
  "cmd_internal_parse_terms", "a_term", "annotated_term", "plain_term",
  "term_symbol", "term_unqualified_symbol", "term_num_constant",
  "term_attribute_list", "term_attribute", "attribute_value",
  "attribute_value_list", "num_list", "int_list", "term_list",
  "quant_var_list", "begin_let_scope", "let_bindings", "let_binding",
  "logic_name", "sort_list", "a_sort", "sort_param_list", "a_sort_param",
  "verbatim_term_list", "verbatim_term", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,    40,    41,
      91,    93
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    42,    43,    44,    44,    44,    44,    44,    44,    44,
      44,    44,    44,    44,    44,    44,    44,    44,    44,    44,
      44,    44,    44,    45,    46,    47,    48,    48,    49,    49,
      50,    50,    51,    52,    53,    54,    55,    56,    57,    58,
      58,    58,    58,    59,    60,    61,    61,    61,    61,    62,
      63,    64,    65,    66,    66,    67,    68,    68,    68,    68,
      68,    68,    69,    69,    70,    70,    71,    71,    71,    71,
      71,    72,    72,    73,    74,    74,    74,    74,    75,    75,
      76,    76,    77,    77,    78,    78,    79,    79,    80,    81,
      81,    82,    83,    83,    84,    84,    85,    85,    85,    86,
      86,    87,    88,    88,    89,    89
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     0,     4,     5,     7,     8,     7,     8,
       8,     9,     4,     4,     4,     3,     3,     3,     3,     5,
       5,     5,     5,     4,     5,     1,     1,     1,     1,     3,
       6,     3,     6,     1,     1,     5,     7,     7,     7,     1,
       1,     4,     1,     5,     1,     5,     1,     1,     1,     1,
       5,     1,     2,     2,     1,     1,     2,     3,     1,     2,
       1,     2,     1,     2,     1,     2,     4,     5,     1,     1,
       2,     4,     1,     4,     1,     2,     1,     5,     4,     1,
       2,     1,     1,     2,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
      23,     0,     0,     2,    22,     3,     4,     5,     6,     7,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     1,    92,     0,     0,     0,     0,     0,
       0,     0,    68,    69,    67,    66,    64,     0,     0,    53,
      54,    60,    62,    59,    35,    36,    37,    38,     0,     0,
       0,    49,     0,    51,     0,     0,    24,     0,     0,     0,
       0,    32,    33,     0,     0,    88,     0,     0,     0,     0,
       0,     0,    34,     0,     0,     0,     0,    43,    46,    45,
      48,    47,     0,   105,    75,     0,    74,   104,     0,   102,
      84,     0,     0,    25,   101,     0,     0,    99,    96,     0,
       0,     0,    94,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    40,    39,    42,    41,
      44,    76,    78,     0,     0,   103,     0,    85,    93,     0,
       0,   100,     0,     0,     0,     0,    95,     0,     0,     0,
       0,     0,     0,    80,     0,     0,     0,    71,     0,     0,
      61,     0,     0,    89,    77,    79,    50,    52,    26,     0,
       0,     0,    28,     0,     0,     0,     0,     0,    63,    70,
      81,    65,    73,    55,    72,     0,     0,     0,     0,    90,
      27,    98,    82,     0,    29,    86,    30,     0,     0,     0,
       0,     0,     0,    83,    97,    87,    31,    57,    58,    91,
      56
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     2,     3,     4,     5,     6,     7,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,   106,
      20,    21,    22,    23,   110,    59,    60,    61,    62,    63,
     166,   167,   107,   143,   164,   203,   111,   125,    91,   172,
     173,    45,   121,   122,   116,   117,   108,   109
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -115
static const yytype_int16 yypact[] =
{
     -30,   150,    23,  -115,  -115,  -115,  -115,  -115,  -115,  -115,
    -115,  -115,  -115,  -115,  -115,  -115,  -115,  -115,  -115,  -115,
    -115,  -115,  -115,  -115,     2,    17,    49,    55,    70,    74,
     108,    25,    62,    86,   100,   101,   131,   132,   133,   105,
     109,   110,   112,  -115,   106,   113,   141,   115,   117,   119,
     120,   121,  -115,  -115,  -115,  -115,  -115,   107,   122,  -115,
    -115,  -115,  -115,  -115,  -115,  -115,  -115,  -115,    83,   123,
     102,  -115,    88,  -115,    25,   144,  -115,   124,     3,     0,
      75,  -115,  -115,    -5,    56,  -115,    25,   146,   151,   116,
      25,   152,  -115,   149,   153,   154,   155,  -115,  -115,  -115,
    -115,  -115,   156,  -115,  -115,    45,  -115,  -115,    61,  -115,
    -115,    11,   157,  -115,  -115,     7,    21,  -115,  -115,    69,
       7,    35,  -115,   145,     7,    92,   178,     7,   189,   190,
     148,   161,   161,   191,    18,   163,  -115,  -115,  -115,  -115,
    -115,  -115,  -115,    79,   164,  -115,   165,  -115,  -115,   166,
       7,  -115,     7,   193,   167,     7,  -115,     7,    25,   198,
       7,   169,   170,  -115,    -4,    98,     9,  -115,    94,    96,
    -115,   201,   172,   163,  -115,  -115,  -115,  -115,  -115,   173,
      38,   206,  -115,   175,   176,   177,     7,    25,  -115,  -115,
    -115,  -115,  -115,  -115,  -115,    25,    25,    25,    25,  -115,
    -115,  -115,  -115,    -2,  -115,  -115,  -115,   179,   180,   181,
     182,   183,   184,  -115,  -115,  -115,  -115,  -115,  -115,  -115,
    -115
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -115,  -115,  -115,  -115,  -115,  -115,  -115,  -115,  -115,  -115,
    -115,  -115,  -115,  -115,  -115,  -115,  -115,  -115,  -115,   147,
    -115,  -115,  -115,  -115,   -31,  -115,  -115,   168,   143,  -115,
    -115,    58,  -103,  -115,  -115,  -115,   137,     6,  -115,    57,
    -115,  -115,    76,  -114,  -115,   118,  -115,   125
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const yytype_uint8 yytable[] =
{
      58,   149,   142,   190,    56,   213,   154,   156,     1,   118,
     158,    44,   114,   161,    52,    53,   118,    54,    55,   165,
      56,    52,    53,    43,    54,    55,    46,    56,    52,    53,
     114,    54,    55,   126,    56,   191,   179,   214,   119,   120,
     175,   183,   115,   184,   118,   119,   187,   118,   193,    57,
     146,    98,    99,   100,   101,   130,    57,   170,    47,   104,
     150,   128,   192,    57,    48,   129,   156,    98,    99,   100,
     101,   103,   207,   119,   155,   104,   119,   201,   152,    49,
     147,    50,   153,   105,   141,    98,    99,   100,   101,    93,
      94,    95,    96,   104,    98,    99,   100,   101,   103,   105,
     144,    64,   104,   147,    98,    99,   100,   101,    98,    99,
     100,   101,   104,   123,   124,    51,    56,   105,   174,    83,
      84,    85,    86,    87,    88,    65,   105,   185,    83,   133,
     159,   160,   159,   195,   159,   196,   105,   168,   169,    66,
      67,    68,    69,    70,    71,    89,    75,    72,    77,    73,
      74,   112,    76,    78,   157,    79,   208,    80,   165,    81,
      82,    92,    97,   113,   209,   210,   211,   212,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,   131,    40,    41,    42,   136,   132,
     135,   133,   137,   138,   139,   140,   162,   163,   148,   123,
     129,   171,   181,   176,   177,   178,   182,   186,   188,   189,
     197,   198,   200,   202,   204,   205,   206,   102,   215,   216,
     217,   218,   219,   220,   194,    90,   127,   134,   180,     0,
     199,     0,     0,   145,   151
};

static const yytype_int16 yycheck[] =
{
      31,   115,   105,     7,     9,     7,   120,   121,    38,     9,
     124,     9,     9,   127,     3,     4,     9,     6,     7,    10,
       9,     3,     4,     0,     6,     7,     9,     9,     3,     4,
       9,     6,     7,    38,     9,    39,   150,    39,    38,    39,
     143,   155,    39,   157,     9,    38,   160,     9,    39,    38,
      39,     6,     7,     8,     9,    86,    38,    39,     9,    14,
      39,     5,   165,    38,     9,     9,   180,     6,     7,     8,
       9,    10,   186,    38,    39,    14,    38,    39,     9,     9,
     111,     7,    13,    38,    39,     6,     7,     8,     9,     6,
       7,     8,     9,    14,     6,     7,     8,     9,    10,    38,
      39,    39,    14,   134,     6,     7,     8,     9,     6,     7,
       8,     9,    14,    38,    39,     7,     9,    38,    39,    12,
      13,    14,    15,    16,    17,    39,    38,   158,    12,    13,
      38,    39,    38,    39,    38,    39,    38,   131,   132,    39,
      39,    10,    10,    10,    39,    38,    40,    38,     7,    39,
      38,     7,    39,    38,     9,    38,   187,    38,    10,    39,
      39,    39,    39,    39,   195,   196,   197,   198,    18,    19,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    38,    35,    36,    37,    39,    38,
      38,    13,    39,    39,    39,    39,     7,     7,    41,    38,
       9,    38,     9,    39,    39,    39,    39,     9,    39,    39,
       9,    39,    39,     7,    39,    39,    39,    70,    39,    39,
      39,    39,    39,    39,   166,    57,    83,    90,   152,    -1,
     173,    -1,    -1,   108,   116
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,    38,    43,    44,    45,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    59,    60,
      62,    63,    64,    65,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      35,    36,    37,     0,     9,    83,     9,     9,     9,     9,
       7,     7,     3,     4,     6,     7,     9,    38,    66,    67,
      68,    69,    70,    71,    39,    39,    39,    39,    10,    10,
      10,    39,    38,    39,    38,    40,    39,     7,    38,    38,
      38,    39,    39,    12,    13,    14,    15,    16,    17,    38,
      69,    80,    39,     6,     7,     8,     9,    39,     6,     7,
       8,     9,    61,    10,    14,    38,    61,    74,    88,    89,
      66,    78,     7,    39,     9,    39,    86,    87,     9,    38,
      39,    84,    85,    38,    39,    79,    38,    70,     5,     9,
      66,    38,    38,    13,    78,    38,    39,    39,    39,    39,
      39,    39,    74,    75,    39,    89,    39,    66,    41,    85,
      39,    87,     9,    13,    85,    39,    85,     9,    85,    38,
      39,    85,     7,     7,    76,    10,    72,    73,    79,    79,
      39,    38,    81,    82,    39,    74,    39,    39,    39,    85,
      84,     9,    39,    85,    85,    66,     9,    85,    39,    39,
       7,    39,    74,    39,    73,    39,    39,     9,    39,    81,
      39,    39,     7,    77,    39,    39,    39,    85,    66,    66,
      66,    66,    66,     7,    39,    39,    39,    39,    39,    39,
      39
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (&yylloc, scanner, parser, YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (&yylval, &yylloc, YYLEX_PARAM)
#else
# define YYLEX yylex (&yylval, &yylloc, scanner)
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value, Location, scanner, parser); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp, yyscan_t scanner, smtlib2_parser_interface *parser)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep, yylocationp, scanner, parser)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    YYLTYPE const * const yylocationp;
    yyscan_t scanner;
    smtlib2_parser_interface *parser;
#endif
{
  if (!yyvaluep)
    return;
  YYUSE (yylocationp);
  YYUSE (scanner);
  YYUSE (parser);
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp, yyscan_t scanner, smtlib2_parser_interface *parser)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep, yylocationp, scanner, parser)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    YYLTYPE const * const yylocationp;
    yyscan_t scanner;
    smtlib2_parser_interface *parser;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  YY_LOCATION_PRINT (yyoutput, *yylocationp);
  YYFPRINTF (yyoutput, ": ");
  yy_symbol_value_print (yyoutput, yytype, yyvaluep, yylocationp, scanner, parser);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *bottom, yytype_int16 *top)
#else
static void
yy_stack_print (bottom, top)
    yytype_int16 *bottom;
    yytype_int16 *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, YYLTYPE *yylsp, int yyrule, yyscan_t scanner, smtlib2_parser_interface *parser)
#else
static void
yy_reduce_print (yyvsp, yylsp, yyrule, scanner, parser)
    YYSTYPE *yyvsp;
    YYLTYPE *yylsp;
    int yyrule;
    yyscan_t scanner;
    smtlib2_parser_interface *parser;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      fprintf (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       , &(yylsp[(yyi + 1) - (yynrhs)])		       , scanner, parser);
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, yylsp, Rule, scanner, parser); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, YYLTYPE *yylocationp, yyscan_t scanner, smtlib2_parser_interface *parser)
#else
static void
yydestruct (yymsg, yytype, yyvaluep, yylocationp, scanner, parser)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
    YYLTYPE *yylocationp;
    yyscan_t scanner;
    smtlib2_parser_interface *parser;
#endif
{
  YYUSE (yyvaluep);
  YYUSE (yylocationp);
  YYUSE (scanner);
  YYUSE (parser);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {
      case 3: /* "BINCONSTANT" */
#line 155 "smtlib2bisonparser.y"
	{ free((yyvaluep->string)); };
#line 1374 "smtlib2bisonparser.c"
	break;
      case 4: /* "HEXCONSTANT" */
#line 155 "smtlib2bisonparser.y"
	{ free((yyvaluep->string)); };
#line 1379 "smtlib2bisonparser.c"
	break;
      case 6: /* "RATCONSTANT" */
#line 155 "smtlib2bisonparser.y"
	{ free((yyvaluep->string)); };
#line 1384 "smtlib2bisonparser.c"
	break;
      case 7: /* "NUMERAL" */
#line 155 "smtlib2bisonparser.y"
	{ free((yyvaluep->string)); };
#line 1389 "smtlib2bisonparser.c"
	break;
      case 8: /* "STRING" */
#line 155 "smtlib2bisonparser.y"
	{ free((yyvaluep->string)); };
#line 1394 "smtlib2bisonparser.c"
	break;
      case 9: /* "SYMBOL" */
#line 155 "smtlib2bisonparser.y"
	{ free((yyvaluep->string)); };
#line 1399 "smtlib2bisonparser.c"
	break;
      case 10: /* "KEYWORD" */
#line 155 "smtlib2bisonparser.y"
	{ free((yyvaluep->string)); };
#line 1404 "smtlib2bisonparser.c"
	break;
      case 69: /* "term_symbol" */
#line 162 "smtlib2bisonparser.y"
	{ smtlib2_indexed_identifier_delete((smtlib2_indexed_identifier *)(yyvaluep->identifier)); };
#line 1409 "smtlib2bisonparser.c"
	break;
      case 70: /* "term_unqualified_symbol" */
#line 163 "smtlib2bisonparser.y"
	{ smtlib2_indexed_identifier_delete((smtlib2_indexed_identifier *)(yyvaluep->identifier)); };
#line 1414 "smtlib2bisonparser.c"
	break;
      case 72: /* "term_attribute_list" */
#line 164 "smtlib2bisonparser.y"
	{ smtlib2_vector_delete((yyvaluep->attributelist)); };
#line 1419 "smtlib2bisonparser.c"
	break;
      case 73: /* "term_attribute" */
#line 165 "smtlib2bisonparser.y"
	{ free((yyvaluep->attribute)[0]); free((yyvaluep->attribute)[1]); free((yyvaluep->attribute)); };
#line 1424 "smtlib2bisonparser.c"
	break;
      case 76: /* "num_list" */
#line 161 "smtlib2bisonparser.y"
	{ smtlib2_vector_delete((yyvaluep->numlist)); };
#line 1429 "smtlib2bisonparser.c"
	break;
      case 77: /* "int_list" */
#line 161 "smtlib2bisonparser.y"
	{ smtlib2_vector_delete((yyvaluep->intlist)); };
#line 1434 "smtlib2bisonparser.c"
	break;
      case 78: /* "term_list" */
#line 157 "smtlib2bisonparser.y"
	{ smtlib2_vector_delete((yyvaluep->termlist)); };
#line 1439 "smtlib2bisonparser.c"
	break;
      case 79: /* "quant_var_list" */
#line 160 "smtlib2bisonparser.y"
	{ smtlib2_vector_delete((yyvaluep->termlist)); };
#line 1444 "smtlib2bisonparser.c"
	break;
      case 83: /* "logic_name" */
#line 155 "smtlib2bisonparser.y"
	{ free((yyvaluep->string)); };
#line 1449 "smtlib2bisonparser.c"
	break;
      case 84: /* "sort_list" */
#line 158 "smtlib2bisonparser.y"
	{ smtlib2_vector_delete((yyvaluep->sortlist)); };
#line 1454 "smtlib2bisonparser.c"
	break;
      case 86: /* "sort_param_list" */
#line 159 "smtlib2bisonparser.y"
	{ smtlib2_vector_delete((yyvaluep->sortlist)); };
#line 1459 "smtlib2bisonparser.c"
	break;

      default:
	break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (yyscan_t scanner, smtlib2_parser_interface *parser);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */






/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (yyscan_t scanner, smtlib2_parser_interface *parser)
#else
int
yyparse (scanner, parser)
    yyscan_t scanner;
    smtlib2_parser_interface *parser;
#endif
#endif
{
  /* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;
/* Location data for the look-ahead symbol.  */
YYLTYPE yylloc;

  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;
#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  yytype_int16 yyssa[YYINITDEPTH];
  yytype_int16 *yyss = yyssa;
  yytype_int16 *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;

  /* The location stack.  */
  YYLTYPE yylsa[YYINITDEPTH];
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;
  /* The locations where the error started and ended.  */
  YYLTYPE yyerror_range[2];

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N), yylsp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
  YYLTYPE yyloc;

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;
  yylsp = yyls;
#if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
  /* Initialize the default location before parsing starts.  */
  yylloc.first_line   = yylloc.last_line   = 1;
  yylloc.first_column = yylloc.last_column = 0;
#endif

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;
	YYLTYPE *yyls1 = yyls;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yyls1, yysize * sizeof (*yylsp),
		    &yystacksize);
	yyls = yyls1;
	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);
	YYSTACK_RELOCATE (yyls);
#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
      yylsp = yyls + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     look-ahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to look-ahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;
  *++yylsp = yylloc;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];

  /* Default location.  */
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 172 "smtlib2bisonparser.y"
    {
      YYACCEPT;
  ;}
    break;

  case 23:
#line 201 "smtlib2bisonparser.y"
    {
      YYERROR;
  ;}
    break;

  case 24:
#line 208 "smtlib2bisonparser.y"
    {
      parser->set_logic(parser, (yyvsp[(3) - (4)].string));
      free((yyvsp[(3) - (4)].string));
  ;}
    break;

  case 25:
#line 216 "smtlib2bisonparser.y"
    {
      int n = atoi((yyvsp[(4) - (5)].string));
      parser->declare_sort(parser, (yyvsp[(3) - (5)].string), n);
      free((yyvsp[(4) - (5)].string));
      free((yyvsp[(3) - (5)].string));
  ;}
    break;

  case 26:
#line 227 "smtlib2bisonparser.y"
    {
      parser->define_sort(parser, (yyvsp[(3) - (7)].string), NULL, (yyvsp[(6) - (7)].sort));
      free((yyvsp[(3) - (7)].string));
  ;}
    break;

  case 27:
#line 232 "smtlib2bisonparser.y"
    {
      parser->define_sort(parser, (yyvsp[(3) - (8)].string), (yyvsp[(5) - (8)].sortlist), (yyvsp[(7) - (8)].sort));
      parser->pop_sort_param_scope(parser);
      smtlib2_vector_delete((yyvsp[(5) - (8)].sortlist));
      free((yyvsp[(3) - (8)].string));
  ;}
    break;

  case 28:
#line 243 "smtlib2bisonparser.y"
    {
      smtlib2_sort tp = (yyvsp[(6) - (7)].sort);
      parser->declare_function(parser, (yyvsp[(3) - (7)].string), tp);
      free((yyvsp[(3) - (7)].string));
  ;}
    break;

  case 29:
#line 249 "smtlib2bisonparser.y"
    {
      smtlib2_sort tp = (yyvsp[(7) - (8)].sort);
      assert(smtlib2_vector_size((yyvsp[(5) - (8)].sortlist)) > 0);
      smtlib2_vector_push((yyvsp[(5) - (8)].sortlist), (intptr_t)tp);
      tp = parser->make_function_sort(parser, (yyvsp[(5) - (8)].sortlist));
      parser->declare_function(parser, (yyvsp[(3) - (8)].string), tp);
      free((yyvsp[(3) - (8)].string));
      smtlib2_vector_delete((yyvsp[(5) - (8)].sortlist));
  ;}
    break;

  case 30:
#line 262 "smtlib2bisonparser.y"
    {
      parser->define_function(parser, (yyvsp[(3) - (8)].string), NULL, (yyvsp[(6) - (8)].sort), (yyvsp[(7) - (8)].term));
      free((yyvsp[(3) - (8)].string));
  ;}
    break;

  case 31:
#line 267 "smtlib2bisonparser.y"
    {
      parser->define_function(parser, (yyvsp[(3) - (9)].string), (yyvsp[(5) - (9)].termlist), (yyvsp[(7) - (9)].sort), (yyvsp[(8) - (9)].term));
      parser->pop_quantifier_scope(parser);
      free((yyvsp[(3) - (9)].string));
      smtlib2_vector_delete((yyvsp[(5) - (9)].termlist));
  ;}
    break;

  case 32:
#line 277 "smtlib2bisonparser.y"
    {
      int n = atoi((yyvsp[(3) - (4)].string));
      free((yyvsp[(3) - (4)].string));
      parser->push(parser, n);
  ;}
    break;

  case 33:
#line 286 "smtlib2bisonparser.y"
    {
      int n = atoi((yyvsp[(3) - (4)].string));
      free((yyvsp[(3) - (4)].string));
      parser->pop(parser, n);
  ;}
    break;

  case 34:
#line 296 "smtlib2bisonparser.y"
    {
      parser->assert_formula(parser, (yyvsp[(3) - (4)].term));
  ;}
    break;

  case 35:
#line 303 "smtlib2bisonparser.y"
    {
      parser->check_sat(parser);
  ;}
    break;

  case 36:
#line 310 "smtlib2bisonparser.y"
    {
      parser->get_assertions(parser);
  ;}
    break;

  case 37:
#line 317 "smtlib2bisonparser.y"
    {
      parser->get_unsat_core(parser);
  ;}
    break;

  case 38:
#line 324 "smtlib2bisonparser.y"
    {
      parser->get_proof(parser);
  ;}
    break;

  case 39:
#line 332 "smtlib2bisonparser.y"
    {
      int n = atoi((yyvsp[(4) - (5)].string));
      parser->set_int_option(parser, (yyvsp[(3) - (5)].string), n);
      free((yyvsp[(4) - (5)].string));
      free((yyvsp[(3) - (5)].string));
  ;}
    break;

  case 40:
#line 339 "smtlib2bisonparser.y"
    {
      double n = atof((yyvsp[(4) - (5)].string));
      parser->set_rat_option(parser, (yyvsp[(3) - (5)].string), n);
      free((yyvsp[(4) - (5)].string));
      free((yyvsp[(3) - (5)].string));
  ;}
    break;

  case 41:
#line 346 "smtlib2bisonparser.y"
    {
      if (strcmp((yyvsp[(4) - (5)].string), "true") == 0) {
          parser->set_int_option(parser, (yyvsp[(3) - (5)].string), 1);
      } else if (strcmp((yyvsp[(4) - (5)].string), "false") == 0) {
          parser->set_int_option(parser, (yyvsp[(3) - (5)].string), 0);
      } else if (strcmp((yyvsp[(4) - (5)].string), "none") == 0) {
          parser->set_rat_option(parser, (yyvsp[(3) - (5)].string), 0);
      } else {
          free((yyvsp[(4) - (5)].string));
          free((yyvsp[(3) - (5)].string));
          YYERROR;
      }
      free((yyvsp[(4) - (5)].string));
      free((yyvsp[(3) - (5)].string));
  ;}
    break;

  case 42:
#line 362 "smtlib2bisonparser.y"
    {
      parser->set_str_option(parser, (yyvsp[(3) - (5)].string), (yyvsp[(4) - (5)].string));
      free((yyvsp[(4) - (5)].string));
      free((yyvsp[(3) - (5)].string));
  ;}
    break;

  case 43:
#line 371 "smtlib2bisonparser.y"
    {
      parser->get_info(parser, (yyvsp[(3) - (4)].string));
      free((yyvsp[(3) - (4)].string));
  ;}
    break;

  case 44:
#line 380 "smtlib2bisonparser.y"
    {
      parser->set_info(parser, (yyvsp[(3) - (5)].string), (yyvsp[(4) - (5)].string));
      free((yyvsp[(4) - (5)].string));
      free((yyvsp[(3) - (5)].string));
  ;}
    break;

  case 45:
#line 390 "smtlib2bisonparser.y"
    {
      (yyval.string) = (yyvsp[(1) - (1)].string);
  ;}
    break;

  case 46:
#line 394 "smtlib2bisonparser.y"
    {
      (yyval.string) = (yyvsp[(1) - (1)].string);
  ;}
    break;

  case 47:
#line 398 "smtlib2bisonparser.y"
    {
      (yyval.string) = (yyvsp[(1) - (1)].string);
  ;}
    break;

  case 48:
#line 402 "smtlib2bisonparser.y"
    {
      (yyval.string) = (yyvsp[(1) - (1)].string);
  ;}
    break;

  case 49:
#line 409 "smtlib2bisonparser.y"
    {
      parser->get_assignment(parser);
  ;}
    break;

  case 50:
#line 416 "smtlib2bisonparser.y"
    {
      size_t i;
      parser->get_value(parser, (yyvsp[(4) - (6)].stringlist));
      for (i = 0; i < smtlib2_vector_size((yyvsp[(4) - (6)].stringlist)); ++i) {
          char *s = (char *)smtlib2_vector_at((yyvsp[(4) - (6)].stringlist), i);
          free(s);
      }
      smtlib2_vector_delete((yyvsp[(4) - (6)].stringlist));
  ;}
    break;

  case 51:
#line 429 "smtlib2bisonparser.y"
    {
      parser->exit(parser);
  ;}
    break;

  case 52:
#line 436 "smtlib2bisonparser.y"
    {
      parser->set_internal_parsed_terms(parser, (yyvsp[(4) - (6)].termlist));
      smtlib2_vector_delete((yyvsp[(4) - (6)].termlist));
  ;}
    break;

  case 53:
#line 446 "smtlib2bisonparser.y"
    {
      (yyval.term) = (yyvsp[(1) - (1)].term);
  ;}
    break;

  case 54:
#line 450 "smtlib2bisonparser.y"
    {
      (yyval.term) = (yyvsp[(1) - (1)].term);
  ;}
    break;

  case 55:
#line 458 "smtlib2bisonparser.y"
    {
      size_t i;
      (yyval.term) = (yyvsp[(3) - (5)].term);
      parser->annotate_term(parser, (yyval.term), (yyvsp[(4) - (5)].attributelist));
      for (i = 0; i < smtlib2_vector_size((yyvsp[(4) - (5)].attributelist)); ++i) {
          char **pair = (char **)smtlib2_vector_at((yyvsp[(4) - (5)].attributelist), i);
          free(pair[0]);
          free(pair[1]);
          free(pair);
      }
      smtlib2_vector_delete((yyvsp[(4) - (5)].attributelist));
  ;}
    break;

  case 56:
#line 475 "smtlib2bisonparser.y"
    {
      (yyval.term) = parser->pop_let_scope(parser);
      if (! (yyval.term)) {
          (yyval.term) = (yyvsp[(6) - (7)].term);
      }
  ;}
    break;

  case 57:
#line 482 "smtlib2bisonparser.y"
    {
      smtlib2_term tmp;
      (yyval.term) = parser->make_forall_term(parser, (yyvsp[(6) - (7)].term));
      tmp = parser->pop_quantifier_scope(parser);
      if (tmp) {
          (yyval.term) = tmp;
      }
      smtlib2_vector_delete((yyvsp[(4) - (7)].termlist));
  ;}
    break;

  case 58:
#line 492 "smtlib2bisonparser.y"
    {
      smtlib2_term tmp;
      (yyval.term) = parser->make_exists_term(parser, (yyvsp[(6) - (7)].term));
      tmp = parser->pop_quantifier_scope(parser);
      if (tmp) {
          (yyval.term) = tmp;
      }
      smtlib2_vector_delete((yyvsp[(4) - (7)].termlist));
  ;}
    break;

  case 59:
#line 502 "smtlib2bisonparser.y"
    {
      (yyval.term) = (yyvsp[(1) - (1)].term);
  ;}
    break;

  case 60:
#line 506 "smtlib2bisonparser.y"
    {
      smtlib2_indexed_identifier *id = (smtlib2_indexed_identifier *)(yyvsp[(1) - (1)].identifier);
      (yyval.term) = smtlib2_make_term_from_identifier(parser, id, NULL);
      smtlib2_indexed_identifier_delete(id);
  ;}
    break;

  case 61:
#line 512 "smtlib2bisonparser.y"
    {
      smtlib2_indexed_identifier *id = (smtlib2_indexed_identifier *)(yyvsp[(2) - (4)].identifier);
      (yyval.term) = smtlib2_make_term_from_identifier(parser, id, (yyvsp[(3) - (4)].termlist));
      smtlib2_indexed_identifier_delete(id);
      smtlib2_vector_delete((yyvsp[(3) - (4)].termlist));
  ;}
    break;

  case 62:
#line 523 "smtlib2bisonparser.y"
    { (yyval.identifier) = (yyvsp[(1) - (1)].identifier); ;}
    break;

  case 63:
#line 525 "smtlib2bisonparser.y"
    {
      (yyval.identifier) = (yyvsp[(3) - (5)].identifier);
      ((smtlib2_indexed_identifier *)(yyval.identifier))->tp = (yyvsp[(4) - (5)].sort);
  ;}
    break;

  case 64:
#line 534 "smtlib2bisonparser.y"
    {
      (yyval.identifier) = smtlib2_indexed_identifier_new((yyvsp[(1) - (1)].string), NULL, NULL);
      free((yyvsp[(1) - (1)].string));
  ;}
    break;

  case 65:
#line 539 "smtlib2bisonparser.y"
    {
      (yyval.identifier) = smtlib2_indexed_identifier_new((yyvsp[(3) - (5)].string), (yyvsp[(4) - (5)].numlist), NULL);
      free((yyvsp[(3) - (5)].string));
      /* $$ takes ownership of $4, so we don't delete it here */
  ;}
    break;

  case 66:
#line 549 "smtlib2bisonparser.y"
    {
      (yyval.term) = parser->make_number_term(parser, (yyvsp[(1) - (1)].string), 0, 10);
      free((yyvsp[(1) - (1)].string));
  ;}
    break;

  case 67:
#line 554 "smtlib2bisonparser.y"
    {
      (yyval.term) = parser->make_number_term(parser, (yyvsp[(1) - (1)].string), 0, 10);
      free((yyvsp[(1) - (1)].string));
  ;}
    break;

  case 68:
#line 559 "smtlib2bisonparser.y"
    {
      const char *s = (yyvsp[(1) - (1)].string) + 2; /* skip the "#b" prefix */
      (yyval.term) = parser->make_number_term(parser, s, strlen(s), 2);
      free((yyvsp[(1) - (1)].string));
  ;}
    break;

  case 69:
#line 565 "smtlib2bisonparser.y"
    {
      const char *s = (yyvsp[(1) - (1)].string) + 2; /* skip the "#x" prefix */
      (yyval.term) = parser->make_number_term(parser, s, 4 * strlen(s), 16);
      free((yyvsp[(1) - (1)].string));
  ;}
    break;

  case 70:
#line 571 "smtlib2bisonparser.y"
    {
      const char *s = (yyvsp[(3) - (5)].string) + 2; /* skip the "bv" prefix */
      (yyval.term) = parser->make_number_term(parser, s, atoi((yyvsp[(4) - (5)].string)), 10);
      free((yyvsp[(4) - (5)].string));
      free((yyvsp[(3) - (5)].string));
  ;}
    break;

  case 71:
#line 582 "smtlib2bisonparser.y"
    {
      (yyval.attributelist) = smtlib2_vector_new();
      smtlib2_vector_push((yyval.attributelist), (intptr_t)(yyvsp[(1) - (1)].attribute));
  ;}
    break;

  case 72:
#line 587 "smtlib2bisonparser.y"
    {
      (yyval.attributelist) = (yyvsp[(1) - (2)].attributelist);
      smtlib2_vector_push((yyval.attributelist), (intptr_t)(yyvsp[(2) - (2)].attribute));
  ;}
    break;

  case 73:
#line 596 "smtlib2bisonparser.y"
    {
      (yyval.attribute) = (char **)malloc(sizeof(char *) * 2);
      (yyval.attribute)[0] = (yyvsp[(1) - (2)].string);
      (yyval.attribute)[1] = (yyvsp[(2) - (2)].string);
  ;}
    break;

  case 74:
#line 606 "smtlib2bisonparser.y"
    {
      (yyval.string) = (yyvsp[(1) - (1)].string);
  ;}
    break;

  case 75:
#line 610 "smtlib2bisonparser.y"
    {
      (yyval.string) = smtlib2_strdup("let");
  ;}
    break;

  case 76:
#line 614 "smtlib2bisonparser.y"
    {
      (yyval.string) = smtlib2_strdup("()");
  ;}
    break;

  case 77:
#line 618 "smtlib2bisonparser.y"
    {
      size_t howmany = 0;
      size_t i;
      char *s;
      
      for (i = 0; i < smtlib2_vector_size((yyvsp[(2) - (3)].stringlist)); ++i) {
          howmany += strlen((char *)smtlib2_vector_at((yyvsp[(2) - (3)].stringlist), i));
      }
      howmany += 2 /* '(' and ')' */ +
          (smtlib2_vector_size((yyvsp[(2) - (3)].stringlist))-1) /* ' 's */ + 1; /* '\0' */
      (yyval.string) = (char *)malloc(sizeof(char) * howmany);

      /* concatenate everything together */
      s = (yyval.string);
      s[0] = '(';
      ++s;
      for (i = 0; i < smtlib2_vector_size((yyvsp[(2) - (3)].stringlist)); ++i) {
          char *s2 = (char *)smtlib2_vector_at((yyvsp[(2) - (3)].stringlist), i);
          char *s3 = s2;
          while (*s2) {
              *s++ = *s2++;
          }
          *s++ = ' ';
          free(s3);
      }
      *(s-1) = ')';
      *s = '\0';
      
      smtlib2_vector_delete((yyvsp[(2) - (3)].stringlist));
  ;}
    break;

  case 78:
#line 653 "smtlib2bisonparser.y"
    {
      (yyval.stringlist) = smtlib2_vector_new();
      smtlib2_vector_push((yyval.stringlist), (intptr_t)(yyvsp[(1) - (1)].string));
  ;}
    break;

  case 79:
#line 658 "smtlib2bisonparser.y"
    {
      (yyval.stringlist) = (yyvsp[(1) - (2)].stringlist);
      smtlib2_vector_push((yyval.stringlist), (intptr_t)(yyvsp[(2) - (2)].string));
  ;}
    break;

  case 80:
#line 667 "smtlib2bisonparser.y"
    {
      (yyval.numlist) = smtlib2_vector_new();
      int n = atoi((yyvsp[(1) - (1)].string));
      smtlib2_vector_push((yyval.numlist), n);
      free((yyvsp[(1) - (1)].string));
  ;}
    break;

  case 81:
#line 674 "smtlib2bisonparser.y"
    {
      int n = atoi((yyvsp[(2) - (2)].string));
      smtlib2_vector_push((yyvsp[(1) - (2)].numlist), n);
      (yyval.numlist) = (yyvsp[(1) - (2)].numlist);
      free((yyvsp[(2) - (2)].string));
  ;}
    break;

  case 82:
#line 685 "smtlib2bisonparser.y"
    {
      int n;
      (yyval.intlist) = smtlib2_vector_new();
      n = atoi((yyvsp[(1) - (1)].string));
      smtlib2_vector_push((yyval.intlist), n);
      free((yyvsp[(1) - (1)].string));
  ;}
    break;

  case 83:
#line 693 "smtlib2bisonparser.y"
    {
      int n = atoi((yyvsp[(2) - (2)].string));
      smtlib2_vector_push((yyvsp[(1) - (2)].intlist), n);
      (yyval.intlist) = (yyvsp[(1) - (2)].intlist);
      free((yyvsp[(2) - (2)].string));
  ;}
    break;

  case 84:
#line 704 "smtlib2bisonparser.y"
    {
      (yyval.termlist) = smtlib2_vector_new();
      smtlib2_vector_push((yyval.termlist), (intptr_t)(yyvsp[(1) - (1)].term));
  ;}
    break;

  case 85:
#line 709 "smtlib2bisonparser.y"
    {
      smtlib2_vector_push((yyvsp[(1) - (2)].termlist), (intptr_t)(yyvsp[(2) - (2)].term));
      (yyval.termlist) = (yyvsp[(1) - (2)].termlist);
  ;}
    break;

  case 86:
#line 718 "smtlib2bisonparser.y"
    {
      intptr_t t;
      parser->push_quantifier_scope(parser);
      (yyval.termlist) = smtlib2_vector_new();
      parser->declare_variable(parser, (yyvsp[(2) - (4)].string), (yyvsp[(3) - (4)].sort));
      t = (intptr_t)parser->make_term(parser, (yyvsp[(2) - (4)].string), (yyvsp[(3) - (4)].sort), NULL, NULL);
      smtlib2_vector_push((yyval.termlist), t);
      free((yyvsp[(2) - (4)].string));
  ;}
    break;

  case 87:
#line 728 "smtlib2bisonparser.y"
    {
      intptr_t t;
      parser->declare_variable(parser, (yyvsp[(3) - (5)].string), (yyvsp[(4) - (5)].sort));
      t = (intptr_t)parser->make_term(parser, (yyvsp[(3) - (5)].string), (yyvsp[(4) - (5)].sort), NULL, NULL);
      smtlib2_vector_push((yyvsp[(1) - (5)].termlist), t);
      free((yyvsp[(3) - (5)].string));
      (yyval.termlist) = (yyvsp[(1) - (5)].termlist);
  ;}
    break;

  case 88:
#line 740 "smtlib2bisonparser.y"
    {
      parser->push_let_scope(parser);
  ;}
    break;

  case 89:
#line 747 "smtlib2bisonparser.y"
    {;}
    break;

  case 90:
#line 748 "smtlib2bisonparser.y"
    {;}
    break;

  case 91:
#line 753 "smtlib2bisonparser.y"
    {
      parser->define_let_binding(parser, (yyvsp[(2) - (4)].string), (yyvsp[(3) - (4)].term));
      free((yyvsp[(2) - (4)].string));
  ;}
    break;

  case 92:
#line 762 "smtlib2bisonparser.y"
    { (yyval.string) = (yyvsp[(1) - (1)].string); ;}
    break;

  case 93:
#line 764 "smtlib2bisonparser.y"
    {
      (yyval.string) = (char *)(malloc(strlen((yyvsp[(1) - (4)].string)) + strlen((yyvsp[(3) - (4)].string)) + 2 + 1));
      sprintf((yyval.string), "%s[%s]", (yyvsp[(1) - (4)].string), (yyvsp[(3) - (4)].string));
      free((yyvsp[(1) - (4)].string));
      free((yyvsp[(3) - (4)].string));
  ;}
    break;

  case 94:
#line 775 "smtlib2bisonparser.y"
    {
      (yyval.sortlist) = smtlib2_vector_new();
      smtlib2_vector_push((yyval.sortlist), (intptr_t)(yyvsp[(1) - (1)].sort));
  ;}
    break;

  case 95:
#line 780 "smtlib2bisonparser.y"
    {
      (yyval.sortlist) = (yyvsp[(1) - (2)].sortlist);
      smtlib2_vector_push((yyval.sortlist), (intptr_t)(yyvsp[(2) - (2)].sort));
  ;}
    break;

  case 96:
#line 789 "smtlib2bisonparser.y"
    {
      (yyval.sort) = parser->make_sort(parser, (yyvsp[(1) - (1)].string), NULL);
      free((yyvsp[(1) - (1)].string));
  ;}
    break;

  case 97:
#line 794 "smtlib2bisonparser.y"
    {
      (yyval.sort) = parser->make_sort(parser, (yyvsp[(3) - (5)].string), (yyvsp[(4) - (5)].intlist));
      smtlib2_vector_delete((yyvsp[(4) - (5)].intlist));
      free((yyvsp[(3) - (5)].string));
  ;}
    break;

  case 98:
#line 800 "smtlib2bisonparser.y"
    {
      (yyval.sort) = parser->make_parametric_sort(parser, (yyvsp[(2) - (4)].string), (yyvsp[(3) - (4)].sortlist));
      smtlib2_vector_delete((yyvsp[(3) - (4)].sortlist));
      free((yyvsp[(2) - (4)].string));
  ;}
    break;

  case 99:
#line 810 "smtlib2bisonparser.y"
    {
      parser->push_sort_param_scope(parser);
      (yyval.sortlist) = smtlib2_vector_new();
      smtlib2_vector_push((yyval.sortlist), (intptr_t)(yyvsp[(1) - (1)].sort));
  ;}
    break;

  case 100:
#line 816 "smtlib2bisonparser.y"
    {
      (yyval.sortlist) = (yyvsp[(1) - (2)].sortlist);
      smtlib2_vector_push((yyval.sortlist), (intptr_t)(yyvsp[(2) - (2)].sort));
  ;}
    break;

  case 101:
#line 824 "smtlib2bisonparser.y"
    {
      parser->declare_sort(parser, (yyvsp[(1) - (1)].string), 0);
      (yyval.sort) = parser->make_sort(parser, (yyvsp[(1) - (1)].string), NULL);
      free((yyvsp[(1) - (1)].string));
  ;}
    break;

  case 102:
#line 834 "smtlib2bisonparser.y"
    {
      (yyval.stringlist) = smtlib2_vector_new();
      smtlib2_vector_push((yyval.stringlist), (intptr_t)(yyvsp[(1) - (1)].string));
  ;}
    break;

  case 103:
#line 839 "smtlib2bisonparser.y"
    {
      (yyval.stringlist) = (yyvsp[(1) - (2)].stringlist);
      smtlib2_vector_push((yyval.stringlist), (intptr_t)(yyvsp[(2) - (2)].string));
  ;}
    break;

  case 104:
#line 848 "smtlib2bisonparser.y"
    {
      (yyval.string) = (yyvsp[(1) - (1)].string);
  ;}
    break;

  case 105:
#line 852 "smtlib2bisonparser.y"
    {
      (yyval.string) = (yyvsp[(1) - (1)].string);
  ;}
    break;


/* Line 1267 of yacc.c.  */
#line 2537 "smtlib2bisonparser.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;
  *++yylsp = yyloc;

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (&yylloc, scanner, parser, YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (&yylloc, scanner, parser, yymsg);
	  }
	else
	  {
	    yyerror (&yylloc, scanner, parser, YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }

  yyerror_range[0] = yylloc;

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval, &yylloc, scanner, parser);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  yyerror_range[0] = yylsp[1-yylen];
  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;

      yyerror_range[0] = *yylsp;
      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp, yylsp, scanner, parser);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;

  yyerror_range[1] = yylloc;
  /* Using YYLLOC is tempting, but would change the location of
     the look-ahead.  YYLOC is available though.  */
  YYLLOC_DEFAULT (yyloc, (yyerror_range - 1), 2);
  *++yylsp = yyloc;

  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (&yylloc, scanner, parser, YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval, &yylloc, scanner, parser);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp, yylsp, scanner, parser);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}


#line 858 "smtlib2bisonparser.y"



smtlib2_indexed_identifier *smtlib2_indexed_identifier_new(
    const char *n, smtlib2_vector *i, smtlib2_sort t)
{
    smtlib2_indexed_identifier *ret = (smtlib2_indexed_identifier *)malloc(
        sizeof(smtlib2_indexed_identifier));
    ret->name = smtlib2_strdup(n);
    ret->idx = i;
    ret->tp = t;

    return ret;
}


void smtlib2_indexed_identifier_delete(smtlib2_indexed_identifier *i)
{
    free(i->name);
    free(i);
}


smtlib2_term smtlib2_make_term_from_identifier(
    smtlib2_parser_interface *parser,
    smtlib2_indexed_identifier *ident, smtlib2_vector *args)
{
    return parser->make_term(parser, ident->name, ident->tp, ident->idx, args);
}


void smtlib2_parser_error(YYLTYPE *yylloc, yyscan_t scanner,
                          smtlib2_parser_interface *parser,
                          const char *s)
{
    parser->handle_error(parser, s);
}

