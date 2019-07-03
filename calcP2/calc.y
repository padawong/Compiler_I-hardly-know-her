/* calculator. */
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
}

%error-verbose
%start input                            /* start of grammar like S' */
%token MULT DIV PLUS MINUS EQUAL L_PAREN R_PAREN END
%token <dval> NUMBER
%type <dval> exp
%left PLUS MINUS                        /* lower precedence*/
%left MULT DIV                          /* higher precedence*/
%nonassoc UMINUS


%% 
/* creates grammar: (lines)* */
input:	
			| input line
			;

/* on each line an expression followed by equals followed by endline returned from END in .lex file */
line:		exp EQUAL END         { printf("\t%f\n", $1);}
			;

exp:		NUMBER                { $$ = $1; }
			| exp PLUS exp        { $$ = $1 + $3; }
			| exp MINUS exp       { $$ = $1 - $3; }
			| exp MULT exp        { $$ = $1 * $3; }
			| exp DIV exp         { if ($3==0) yyerror("divide by zero"); else $$ = $1 / $3; }
			| MINUS exp %prec UMINUS { $$ = -$2; }
			| L_PAREN exp R_PAREN { $$ = $2; }
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
