   /* cs152-fall08 */
   /* A flex scanner specification for the calculator language */
   /* Written by Dennis Jeffrey */

%{   
   #include "y.tab.h"
   int currLine = 1, currPos = 1;
   int numNumbers = 0;
   int numOperators = 0;
   int numParens = 0;
   int numEquals = 0;
%}

DIGIT    [0-9]
   
%%

"-"            {currPos += yyleng; numOperators++; return MINUS;}
"+"            {currPos += yyleng; numOperators++; return PLUS;}
"*"            {currPos += yyleng; numOperators++; return MULT;}
"/"            {currPos += yyleng; numOperators++; return DIV;}
"="            {currPos += yyleng; numEquals++; return EQUAL;}
"("            {currPos += yyleng; numParens++; return L_PAREN;}
")"            {currPos += yyleng; numParens++; return R_PAREN;}

(\.{DIGIT}+)|({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?)   {currPos += yyleng; yylval.dval = atof(yytext); numNumbers++; return NUMBER;}

[ \t]+         {/* ignore spaces */ currPos += yyleng;}

"\n"|"\r\n"           {currLine++; currPos = 1; return END;} /* ANOTHER THING TO CARE ABOUT, "\r\n", files can be identical even on an external diff viewer and have every line be different due to ending \r followed by \n ... i believe */
	/* ALSO COULD ADD A CATCH FOR ENDLINE WHEN ITS THE END OF THE FILE, for now make sure your test file ends with an extra endline, this is due to the grammar setup by lines and lines ending with END*/
.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%
