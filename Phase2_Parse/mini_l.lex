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
COMMENT ["##"].*

IDENTIFIER   {ALPHA}({DIGIT}|{ALPHA})*(_*({DIGIT}|{ALPHA})+)*
IDENT_DIGIT {DIGIT}{ALPHA}({DIGIT}|{ALPHA})*(_({DIGIT}|{ALPHA})+)*|{DIGIT}{ALPHA}({DIGIT}|{ALPHA})*(_({DIGIT}|{ALPHA})+)*_
IDENT_UNDERSCORE {ALPHA}({DIGIT}|{ALPHA})*(_({DIGIT}|{ALPHA})+)*_+

%{
// C variable declarations must occur between these two brackets
   #include "y.tab.h"
    int currLine = 1, currPos = 1;
%}

%%

 /*** Reserved Words ***/
"program"           {currPos += yyleng; return PROGRAM;}
"beginprogram"      {currPos += yyleng; return BEGIN_PROGRAM;}
"endprogram"        {currPos += yyleng; return END_PROGRAM;}  
"integer"           {currPos += yyleng; return INTEGER;}
"array"             {currPos += yyleng; return ARRAY;}
"of"                {currPos += yyleng; return OF;}
"if"                {currPos += yyleng; return IF;}
"then"              {currPos += yyleng; return THEN;}
"endif"             {currPos += yyleng; return ENDIF;}
"else"              {currPos += yyleng; return ELSE;}
"while"             {currPos += yyleng; return WHILE;}
"do"                {currPos += yyleng; return DO;}
"beginloop"         {currPos += yyleng; return BEGINLOOP;}
"endloop"           {currPos += yyleng; return ENDLOOP;}
"continue"          {currPos += yyleng; return CONTINUE;}
"read"              {currPos += yyleng; return READ;}
"write"             {currPos += yyleng; return WRITE;}
"and"               {currPos += yyleng; return AND;}
"or"                {currPos += yyleng; return OR;}
"not"               {currPos += yyleng; return NOT;}
"true"              {currPos += yyleng; return TRUE;}
"false"             {currPos += yyleng; return FALSE;}

 /*** Arithmetic Operators ***/
"-"                 {currPos += yyleng; return SUB;}
"+"                 {currPos += yyleng; return ADD;}
"*"                 {currPos += yyleng; return MULT;}
"/"                 {currPos += yyleng; return DIV;}
"%"                 {currPos += yyleng; return MOD;}

 /*** Comparison Operators ***/
"=="                {currPos += yyleng; return EQ;}
"<>"                {currPos += yyleng; return NEQ;}
"<"                 {currPos += yyleng; return LT;}
">"                 {currPos += yyleng; return GT;}
"<="                {currPos += yyleng; return LTE;}
">="                {currPos += yyleng; return GTE;}

 /*** Identifiers and Numbers ***/
{IDENTIFIER}        {currPos += yyleng; yylval.sval = strdup(yytext); return IDENT;}
{DIGIT}+            {currPos += yyleng; yylval.ival = atof(yytext); return NUMBER;}

 /*** Other Special Symbols ***/
";"                 {currPos += yyleng; return SEMICOLON;}
":"                 {currPos += yyleng; return COLON;}
","                 {currPos += yyleng; return COMMA;}
"("                 {currPos += yyleng; return L_PAREN;}
")"                 {currPos += yyleng; return R_PAREN;}
":="                {currPos += yyleng; return ASSIGN;}

{IDENT_DIGIT}       {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); currPos += yyleng;}
{IDENT_UNDERSCORE}  {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); currPos += yyleng;}

["\t"|" "]          {/* ignore spaces */ currPos += yyleng;}
["\n"|"\r\n"]         {currLine++; currPos = 1;}

{COMMENT}           {currPos += yyleng;}

.                   {printf("Error at line %d, column %d, unrecognized symbol \"%s\"\n", currLine, currPos, yytext); currPos += yyleng;}
%%
