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
  double dval;
  int ival;
  char* sval;
}

%error-verbose
%start program                            /* start of grammar like S' */
%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN ASSIGN END
%token <ival> NUMBER
%token <sval> IDENT
%left ADD SUB                        /* lower precedence */
%left MULT DIV                          /* higher precedence */
/* %nonassoc SUB */


%% 
program: PROGRAM IDENT SEMICOLON block END_PROGRAM       {printf("program -> PROGRAM IDENT SEMICOLON block END_PROGRAM, ");} 
         ;

block: decl BEGIN_PROGRAM stmnt                          {printf("block -> decl BEGIN_PROGRAM stmnt");}
       ;
decl: decl declaration SEMICOLON                        {printf("decl -> decl declaration SEMICOLON");}
      | declaration SEMICOLON                           {printf("decl -> declaration SEMICOLON");}
      ;
stmnt: stmnt statement SEMICOLON                        {printf("stmnt -> stmnt statement SEMICOLON");}
       | statement SEMICOLON                            {printf("stmnt -> statement SEMICOLON");}
       ;

declaration: identifiers COLON array_of INTEGER         {printf("declaration -> identifiers COLON array_of INTEGER");}
             ;
identifiers: identifiers COMMA IDENT                    {printf("identifiers -> identifiers COMMA IDENT");}
             | IDENT                                    {printf("identifiers -> IDENT");}
             ;
array_of: /* EMPTY */                                   {printf("array_of -> /* EMPTY */");}
          | ARRAY L_PAREN NUMBER R_PAREN OF             {printf("array_of -> ARRAY L_PAREN NUMBER R_PAREN OF");}
          ;
statement: var ASSIGN expression                        {printf("statement -> var ASSIGN expression");}
/*            | IF bool_exp THEN stmnt2 ENDIF */
           | IF bool_exp THEN stmnt ELSE stmnt ENDIF    {printf("statement -> IF bool_exp THEN stmnt ELSE stmnt ENDIF");}
           | WHILE bool_exp BEGINLOOP stmnt ENDLOOP    {printf("statement -> WHILE bool_exp BEGINLOOP stmnt ENDLOOP");}
           | DO BEGINLOOP stmnt ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP stmnt ENDLOOP WHILE bool_exp");}
           | READ vars                                  {printf("statement -> READ vars");}
           | WRITE vars                                 {printf("statement -> WRITE vars");}
           | CONTINUE                                   {printf("statement -> CONTINUE");}
           ;
/* stmnt2: stmnt stmnt3 */
/* stmnt3:  */
/*         | ELSE stmnt */
vars: vars COMMA var                                    {printf("vars -> vars COMMA var");}
      | var                                             {printf("vars -> var");}
      ;

bool_exp: relation_and_exp rel_loop                     {printf("bool_exp -> relation_and_exp rel_loop");}
          ;
rel_loop: OR relation_and_exp rel_loop                  {printf("rel_loop -> OR relation_and_exp rel_loop");}
          | /* EMPTY */                                 {printf("rel_loop -> /* EMPTY */");}
          ;

relation_and_exp: relation_exp rel_loop2                {printf("relation_and_exp -> relation_exp rel_loop2");}
                  ;
rel_loop2: AND relation_exp rel_loop2                   {printf("rel_loop2 -> AND relation_exp rel_loop2");}
           | /* EMPTY */                                {printf("rel_loop2 -> /* EMPTY */");}
           ;

relation_exp: not_exp fork                              {printf("relation_exp -> not_exp fork");}
              ;
not_exp: NOT                                            {printf("not_exp -> expression comp expression");}
         | /* EMPTY */                                  {printf("not_exp -> /* EMPTY */");}
         ;
fork: expression comp expression                        {printf("fork -> NOT");}
      | TRUE                                            {printf("fork -> TRUE");}
      | FALSE                                           {printf("fork -> FALSE");}
      | L_PAREN bool_exp R_PAREN                        {printf("fork -> L_PAREN bool_exp R_PAREN");}
      ;

comp: EQ                                                {printf("comp -> /* EMPTY */");}
      | NEQ                                             {printf("comp -> NEQ");}
      | LT                                              {printf("comp -> LT");}
      | GT                                              {printf("comp -> GT");}
      | LTE                                             {printf("comp -> LTE");}
      | GTE                                             {printf("comp -> GTE");}
      ;

expression: multiplicative_exp mult_loop                {printf("expression -> multiplicative_exp mult_loop");}
            ;
mult_loop: ADD multiplicative_exp mult_loop             {printf("mult_loop -> ADD multiplicative_exp mult_loop");}
           | SUB multiplicative_exp mult_loop           {printf("mult_loop -> SUB multiplicative_exp mult_loop");}
           | /* EMPTY */                                {printf("mult_loop -> /* EMPTY */");}
           ;

multiplicative_exp: term term_loop                      {printf("multiplicative_exp -> term term_loop");}
                    ;
term_loop: MULT term term_loop                          {printf("term_loop -> MULT term term_loop");}
           | DIV term term_loop                         {printf("term_loop -> DIV term term_loop");}
           | MOD term term_loop                         {printf("term_loop -> MOD term term_loop");}
           | /* EMPTY */                                {printf("term_loop -> /* EMPTY */");}
           ;

term: neg term_fork                                     {printf("term -> neg term_fork");}
      ;
neg: SUB                                                {printf("neg -> SUB");}
     | /* EMPTY */                                      {printf("neg -> /* EMPTY */");}
     ;
term_fork: var                                          {printf("term_fork -> var");}
           | NUMBER                                     {printf("term_fork -> NUMBER");}
           | L_PAREN expression R_PAREN                 {printf("term_fork -> L_PAREN expression R_PAREN");}
           ;

var: IDENT                                              {printf("var -> IDENT");}
     | IDENT L_PAREN expression R_PAREN                 {printf("var -> IDENT L_PAREN expression R_PAREN");}
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
