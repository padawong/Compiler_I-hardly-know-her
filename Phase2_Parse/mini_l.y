/* Section 2: */
/* error handling from https://www.gnu.org/software/bison/manual/bison.html#Error-Recovery */
%{
 #include <stdio.h>
 #include <stdlib.h>
 void yyerror(const char *msg);         /* function delcared at bottom */
 extern int currLine;                   /* from .lex file */
 extern int currPos;                    /* from .lex file */
 FILE * yyin; /* used to read tokens in from .lex file */
%}

%union{
  int ival;
  char* sval;
}

%define parse.lac full
%define parse.error verbose
%start program                            /* start of grammar like S' */
%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN ASSIGN END
%token <ival> NUMBER
%token <sval> IDENT
%type <sval> block
%right ASSIGN                   /* lower precedence 9 */
%left OR                        /* middle precedence 8 */
%left AND                       /* middle precedence 7 */
%right NOT                      /* middle precedence 6 */
%left EQ NEQ LT GT LTE GTE      /* middle precedence 5 */
%left ADD SUB                   /* middle precedence 4 */
%left MULT DIV MOD              /* middle precedence 3 */
%nonassoc UMINUS                /* middle precedence 2 */
%left L_PAREN R_PAREN           /* higher precedence 1 */


%%


program: PROGRAM IDENT SEMICOLON block END_PROGRAM      {printf("program -> PROGRAM IDENT (%s) SEMICOLON block END_PROGRAM\n", $2);}
       ;

block: decl BEGIN_PROGRAM stmnt                         {printf("block -> decl BEGIN_PROGRAM stmnt\n");}
     ;

decl: decl declaration SEMICOLON                        {printf("decl -> decl declaration SEMICOLON\n");}
    | declaration SEMICOLON                             {printf("decl -> declaration SEMICOLON\n");}
    ;

stmnt: stmnt statement SEMICOLON                        {printf("stmnt -> stmnt statement SEMICOLON\n");}
     | statement SEMICOLON                              {printf("stmnt -> statement SEMICOLON\n");}
     ;

declaration: identifiers COLON array_of INTEGER         {printf("declaration -> identifiers COLON array_of INTEGER\n");}
           | identifiers error INTEGER                  {printf("declaration -> identifiers error INTEGER\n");}
           | identifiers error '\n'                     {printf("declaration -> identifiers error '\n'\n");}
           | identifiers error COMMA                    {printf("declaration -> identifiers error COMMA\n");}
           | identifiers error SEMICOLON                {printf("declaration -> identifiers error SEMICOLON\n");}
           ;

identifiers: identifiers COMMA IDENT                    {printf("identifiers -> identifiers COMMA IDENT (%s)\n", $3);}
           | IDENT                                      {printf("identifiers -> IDENT (%s)\n", $1);}
           ;

array_of: /* EMPTY */                                   {printf("array_of ->\n");}
        | ARRAY L_PAREN NUMBER R_PAREN OF               {printf("array_of -> ARRAY L_PAREN NUMBER R_PAREN OF\n");}
        ;

statement: var ASSIGN expression                        {printf("statement -> var ASSIGN expression\n");}
         | var error expression                         {printf("statement -> var error expression\n");}
                                                        // TODO: check for dangling else
         | IF bool_exp THEN stmnt stmnt2 ENDIF          {printf("statement -> IF bool_exp THEN stmnt ELSE stmnt ENDIF\n");}
         | WHILE bool_exp BEGINLOOP stmnt ENDLOOP       {printf("statement -> WHILE bool_exp BEGINLOOP stmnt ENDLOOP\n");}
         | DO BEGINLOOP stmnt ENDLOOP WHILE bool_exp    {printf("statement -> DO BEGINLOOP stmnt ENDLOOP WHILE bool_exp\n");}
         | READ vars                                    {printf("statement -> READ vars\n");}
         | WRITE vars                                   {printf("statement -> WRITE vars\n");}
         | CONTINUE                                     {printf("statement -> CONTINUE\n");}
         ;

stmnt2: /* EMPTY */                                     {printf("stmnt2 ->\n");}
      | ELSE stmnt                                      {printf("stmnt2 -> ELSE stmnt\n");}
      ;

vars: vars COMMA var                                    {printf("vars -> vars COMMA var\n");}
    | var                                               {printf("vars -> var\n");}
    ;

bool_exp: relation_and_exp rel_loop                     {printf("bool_exp -> relation_and_exp rel_loop\n");}
        ;

rel_loop: /* EMPTY */                                   {printf("rel_loop ->\n");}
        | OR relation_and_exp rel_loop                  {printf("rel_loop -> OR relation_and_exp rel_loop\n");}
        ;

relation_and_exp: relation_exp rel_loop2                {printf("relation_and_exp -> relation_exp rel_loop2\n");}
                ;

rel_loop2: /* EMPTY */                                  {printf("rel_loop2 ->\n");}
         | AND relation_exp rel_loop2                   {printf("rel_loop2 -> AND relation_exp rel_loop2\n");}
         ;

relation_exp: fork                                      {printf("relation_exp -> fork\n");}
            | NOT fork                                  {printf("relation_exp -> NOT fork\n");}
            ;

fork: expression comp expression                        {printf("fork -> expression comp expression\n");}
    | TRUE                                              {printf("fork -> TRUE\n");}
    | FALSE                                             {printf("fork -> FALSE\n");}
    | L_PAREN bool_exp R_PAREN                          {printf("fork -> L_PAREN bool_exp R_PAREN\n");}
    ;

comp: EQ                                                {printf("comp -> EQ\n");}
    | NEQ                                               {printf("comp -> NEQ\n");}
    | LT                                                {printf("comp -> LT\n");}
    | GT                                                {printf("comp -> GT\n");}
    | LTE                                               {printf("comp -> LTE\n");}
    | GTE                                               {printf("comp -> GTE");}
    ;

expression: multiplicative_exp mult_loop                {printf("expression -> multiplicative_exp mult_loop\n");}
          ;

mult_loop: /* EMPTY */                                  {printf("mult_loop ->\n");}
         | ADD multiplicative_exp mult_loop             {printf("mult_loop -> ADD multiplicative_exp mult_loop\n");}
         | SUB multiplicative_exp mult_loop             {printf("mult_loop -> SUB multiplicative_exp mult_loop\n");}
         ;

multiplicative_exp: term term_loop                      {printf("multiplicative_exp -> term term_loop\n");}
                  ;

term_loop: /* EMPTY */                                  {printf("term_loop ->\n");}
         | MULT term term_loop                          {printf("term_loop -> MULT term term_loop\n");}
         | DIV term term_loop                           {printf("term_loop -> DIV term term_loop\n");}
         | MOD term term_loop                           {printf("term_loop -> MOD term term_loop\n");}
         ;

term: SUB var %prec UMINUS                              {printf("term -> SUB var\n");}
    | SUB NUMBER %prec UMINUS                           {printf("term -> SUB NUMBER\n");}
    | SUB L_PAREN expression R_PAREN %prec UMINUS       {printf("term -> SUB L_PAREN expression R_PAREN\n");}
    | var                                               {printf("term -> var\n");}
    | NUMBER                                            {printf("term -> NUMBER\n");}
    | L_PAREN expression R_PAREN                        {printf("term -> L_PAREN expression R_PAREN\n");}
    ;

var: IDENT var_exp                                      {printf("var -> IDENT (%s) var_exp\n", $1);}
   ;

var_exp: /* EMPTY */                                    {printf("var_exp ->\n");}
       | L_PAREN expression R_PAREN                     {printf("var_exp -> L_PAREN expression R_PAREN\n");}
       ;

%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}
