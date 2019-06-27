/* 
 * Tokenizer for Mini-L language: 
 * Description:  
 *              
 * Usage: (1) $ flex mini_l.lex
 *        (2) $ gcc -o lexer lex.yy.c -lfl
 *        (3) $ cat filename.min | lexer
 *         List of tokens should be printed out
 */

DIGIT   [0-9]
ALPHA   [a-zA-Z]
IDENTIFIER   {ALPHA}({DIGIT}|{ALPHA})*(_({DIGIT}|{ALPHA})+)*
INVALID_IDENT {DIGIT}{ALPHA}({DIGIT}|{ALPHA})*(_({DIGIT}|{ALPHA})+)*
  

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
"_"                 {printf("underscore\n"); currPos += yyleng;}
 /* complete words; focus on identifiers */

{DIGIT}+            {printf("NUMBER %s\n", yytext);}
{IDENTIFIER}        {printf("IDENT %s\n", yytext);}
%%

main()
{
  yylex();
}

