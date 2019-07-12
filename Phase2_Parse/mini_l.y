/* calculator. */

/* Section 1: */
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

%error-verbose
%start program                            /* start of grammar like S' */
%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN ASSIGN END
%token <ival> NUMBER
%token <sval> IDENT
%type <sval> block
%left ADD SUB                        /* lower precedence */
%left MULT DIV                          /* higher precedence */
/* %nonassoc SUB */


%% 
program: PROGRAM IDENT SEMICOLON block END_PROGRAM       {printf("program -> PROGRAM IDENT (%s) SEMICOLON block END_PROGRAM\n", $2);} 
         ;

block: decl BEGIN_PROGRAM stmnt                          {printf("block -> decl BEGIN_PROGRAM stmnt\n");}
       ;
decl: decl declaration SEMICOLON                        {printf("decl -> decl declaration SEMICOLON\n");}
      | declaration SEMICOLON                           {printf("decl -> declaration SEMICOLON\n");}
      ;
stmnt: stmnt statement SEMICOLON                        {printf("stmnt -> stmnt statement SEMICOLON\n");}
       | statement SEMICOLON                            {printf("stmnt -> statement SEMICOLON\n");}
       ;

declaration: identifiers COLON array_of INTEGER         {printf("declaration -> identifiers COLON array_of INTEGER\n");}
             ;
identifiers: identifiers COMMA IDENT                    {printf("identifiers -> identifiers COMMA IDENT (%s)\n", $3);}
             | IDENT                                    {printf("identifiers -> IDENT (%s)\n", $1);}
             ;
array_of: /* EMPTY */                                   {printf("array_of -> \n");}
          | ARRAY L_PAREN NUMBER R_PAREN OF             {printf("array_of -> ARRAY L_PAREN NUMBER R_PAREN OF\n");}
          ;
statement: var ASSIGN expression                        {printf("statement -> var ASSIGN expression\n");}
/*            | IF bool_exp THEN stmnt2 ENDIF */
           | IF bool_exp THEN stmnt ELSE stmnt ENDIF    {printf("statement -> IF bool_exp THEN stmnt ELSE stmnt ENDIF\n");}
           | WHILE bool_exp BEGINLOOP stmnt ENDLOOP    {printf("statement -> WHILE bool_exp BEGINLOOP stmnt ENDLOOP\n");}
           | DO BEGINLOOP stmnt ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP stmnt ENDLOOP WHILE bool_exp\n");}
           | READ vars                                  {printf("statement -> READ vars\n");}
           | WRITE vars                                 {printf("statement -> WRITE vars\n");}
           | CONTINUE                                   {printf("statement -> CONTINUE\n");}
           ;
/* stmnt2: stmnt stmnt3 */
/* stmnt3:  */
/*         | ELSE stmnt */
vars: vars COMMA var                                    {printf("vars -> vars COMMA var\n");}
      | var                                             {printf("vars -> var\n");}
      ;

bool_exp: relation_and_exp rel_loop                     {printf("bool_exp -> relation_and_exp rel_loop\n");}
          ;
rel_loop: OR relation_and_exp rel_loop                  {printf("rel_loop -> OR relation_and_exp rel_loop\n");}
          | /* EMPTY */                                 {printf("rel_loop -> \n");}
          ;

relation_and_exp: relation_exp rel_loop2                {printf("relation_and_exp -> relation_exp rel_loop2\n");}
                  ;
rel_loop2: AND relation_exp rel_loop2                   {printf("rel_loop2 -> AND relation_exp rel_loop2\n");}
           | /* EMPTY */                                {printf("rel_loop2 -> \n");}
           ;

relation_exp: not_exp fork                              {printf("relation_exp -> not_exp fork\n");}
              ;
not_exp: NOT                                            {printf("not_exp -> expression comp expression\n");}
         | /* EMPTY */                                  {printf("not_exp -> \n");}
         ;
fork: expression comp expression                        {printf("fork -> NOT\n");}
      | TRUE                                            {printf("fork -> TRUE\n");}
      | FALSE                                           {printf("fork -> FALSE\n");}
      | L_PAREN bool_exp R_PAREN                        {printf("fork -> L_PAREN bool_exp R_PAREN\n");}
      ;

comp: EQ                                                {printf("comp -> \n");}
      | NEQ                                             {printf("comp -> NEQ\n");}
      | LT                                              {printf("comp -> LT\n");}
      | GT                                              {printf("comp -> GT\n");}
      | LTE                                             {printf("comp -> LTE\n");}
      | GTE                                             {printf("comp -> GTE");}
      ;

expression: multiplicative_exp mult_loop                {printf("expression -> multiplicative_exp mult_loop\n");}
            ;
mult_loop: ADD multiplicative_exp mult_loop             {printf("mult_loop -> ADD multiplicative_exp mult_loop\n");}
           | SUB multiplicative_exp mult_loop           {printf("mult_loop -> SUB multiplicative_exp mult_loop\n");}
           | /* EMPTY */                                {printf("mult_loop -> \n");}
           ;

multiplicative_exp: term term_loop                      {printf("multiplicative_exp -> term term_loop\n");}
                    ;
term_loop: MULT term term_loop                          {printf("term_loop -> MULT term term_loop\n");}
           | DIV term term_loop                         {printf("term_loop -> DIV term term_loop\n");}
           | MOD term term_loop                         {printf("term_loop -> MOD term term_loop\n");}
           | /* EMPTY */                                {printf("term_loop -> \n");}
           ;

term: neg term_fork                                     {printf("term -> neg term_fork\n");}
      ;
neg: SUB                                                {printf("neg -> SUB\n");}
     | /* EMPTY */                                      {printf("neg -> \n");}
     ;
term_fork: var                                          {printf("term_fork -> var\n");}
           | NUMBER                                     {printf("term_fork -> NUMBER\n");}
           | L_PAREN expression R_PAREN                 {printf("term_fork -> L_PAREN expression R_PAREN\n");}
           ;

var: IDENT                                              {printf("var -> IDENT (%s)\n", $1);}
     | IDENT L_PAREN expression R_PAREN                 {printf("var -> IDENT (%s) L_PAREN expression R_PAREN\n", $1);}
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
