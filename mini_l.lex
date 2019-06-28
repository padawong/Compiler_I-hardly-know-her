/* 
 * Tokenizer for Mini-L language: 
 * Description:  
 *              
 * Usage: (1) $ flex mini_l.lex
 *        (2) $ gcc -o lexer lex.yy.c -lfl
 *        (3) $ cat filename.min | lexer
 *         List of tokens should be printed out
 */

%option full

DIGIT   [0-9]
ALPHA   [a-zA-Z]
IDENTIFIER   {ALPHA}({DIGIT}|{ALPHA})*(_*({DIGIT}|{ALPHA})+)*
IDENT_DIGIT {DIGIT}{ALPHA}({DIGIT}|{ALPHA})*(_({DIGIT}|{ALPHA})+)*|{DIGIT}{ALPHA}({DIGIT}|{ALPHA})*(_({DIGIT}|{ALPHA})+)*_
IDENT_UNDERSCORE {ALPHA}({DIGIT}|{ALPHA})*(_({DIGIT}|{ALPHA})+)*_+

%{
// C variable declarations must occur between these two brackets
    int currLine = 1, currPos = 1;
%}

%%
"program"           {printf("PROGRAM\n"); currPos += yyleng;}
"beginprogram"      {printf("BEGIN_PROGRAM\n"); currPos += yyleng;}
"endprogram"        {printf("END_PROGRAM\n"); currPos += yyleng;}  
"integer"           {printf("INTEGER\n"); currPos += yyleng;}
"array"             {printf("ARRAY\n"); currPos += yyleng;}
"of"                {printf("OF\n"); currPos += yyleng;}
"if"                {printf("IF\n"); currPos += yyleng;}
"then"              {printf("THEN\n"); currPos += yyleng;}
"endif"             {printf("ENDIF\n"); currPos += yyleng;}
"else"              {printf("ELSE\n"); currPos += yyleng;}
"while"             {printf("WHILE\n"); currPos += yyleng;}
 /* complete words; focus on identifiers */

{DIGIT}+            {printf("NUMBER %s\n", yytext);}
{IDENTIFIER}        {printf("IDENT %s\n", yytext);}
{IDENT_DIGIT}       {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); currPos += yyleng;}
{IDENT_UNDERSCORE}  {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); currPos += yyleng;}

[ \t]+          {/* ignore spaces */ currPos += yyleng;}
"\n"            {currLine++; currPos = 1;}


%%

main()
{
  yylex();
}

