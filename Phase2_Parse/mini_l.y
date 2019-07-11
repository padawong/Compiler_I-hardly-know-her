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
%start input                            /* start of grammar like S' */
%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN ASSIGN END
%token <ival> NUMBER
%type <sval> IDENT
%left ADD SUB                        /* lower precedence */
%left MULT DIV                          /* higher precedence */
/* %nonassoc SUB */


%% 
/* creates grammar: (lines)* */
input:  
            | input line
            ;

/* on each line an expression followed by equals followed by endline returned from END in .lex file */
line:       exp EQUAL END         { printf("\t%f\n", $1);}
            ;

exp:        NUMBER                { $$ = $1; }
            | exp PLUS exp        { $$ = $1 + $3; }
            | exp MINUS exp       { $$ = $1 - $3; }
            | exp MULT exp        { $$ = $1 * $3; }
            | exp DIV exp         { if ($3==0) yyerror("divide by zero"); else $$ = $1 / $3; }
            | MINUS exp %prec UMINUS { $$ = -$2; }
            | L_PAREN exp R_PAREN { $$ = $2; }
            ;















program: PROGRAM IDENT SEMICOLON block ENDPROGRAM       {printf("PROGRAM IDENT SEMICOLON block ENDPROGRAM, ");} 
         ;

block: decl BEGINPROGRAM stmnt                          {printf("decl BEGINPROGRAM stmnt");}
       ;
decl: decl declaration SEMICOLON 
      | declaration SEMICOLON
      ;
stmnt: stmnt statement SEMICOLON 
       | statement SEMICOLON
       ;

declaration: identifiers COLON array_of INTEGER
             ;
identifiers: identifiers COMMA IDENT 
             | IDENT
             ;
array_of: /* EMPTY */
          | ARRAY L_PAREN NUMBER R_PAREN OF
          ;

statement: var ASSIGN expression
/*            | IF bool_exp THEN stmnt2 ENDIF */
           | IF bool_exp THEN stmnt ELSE stmnt ENDIF
           | WHILE bool_exp BEGIN_LOOP stmnt ENDLOOP
           | DO BEGIN_LOOP stmnt ENDLOOP WHILE bool_exp
           | READ vars
           | WRITE vars
           | CONTINUE
           ;
/* stmnt2: stmnt stmnt3 */
/* stmnt3:  */
/*         | ELSE stmnt */
vars: vars COMMA var
      | var
      ;

bool_exp: relation_and_exp rel_loop
          ;
rel_loop: OR relation_and_exp rel_loop 
          | /* EMPTY */
          ;

relation_and_exp: relation_exp rel_loop2
                  ;
rel_loop2: AND relation_exp rel_loop2
           | /* EMPTY */
           ;

relation_exp: not_exp fork
              ;
not_exp: NOT
         | /* EMPTY */
         ;
fork: expression comp expression
      | TRUE
      | FALSE
      | L_PAREN bool_exp R_PAREN
      ;

comp: EQ
      | NEQ
      | LT
      | GT
      | LTE
      | GTE
      ;

expression: multiplicative_exp mult_loop
            ;
mult_loop: ADD multiplicative_exp mult_loop
           | SUB multiplicative_exp mult_loop
           | /* EMPTY */
           ;

multiplicative_exp: term term_loop
                    ;
term_loop: MULT term term_loop
           | DIV term term_loop
           | MOD term term_loop
           | /* EMPTY */
           ;

term: neg term_fork
      ;
neg: SUB
     | /* EMPTY */
     ;
term_fork: var
           | NUMBER
           | L_PAREN expression R_PAREN
           ;

var: IDENT
     | IDENT L_PAREN expression R_PAREN
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
