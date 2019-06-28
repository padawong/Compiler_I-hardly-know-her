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

 /*** Reserved Words ***/
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
"do"              	{printf("DO\n"); currPos += yyleng;}
"beginloop"       	{printf("BEGINLOOP\n"); currPos += yyleng;}
"endloop"           {printf("ENDLOOP\n"); currPos += yyleng;}
"continue"          {printf("CONTINUE\n"); currPos += yyleng;}
"read"              {printf("READ\n"); currPos += yyleng;}
"write"             {printf("WRITE\n"); currPos += yyleng;}
"and"               {printf("AND\n"); currPos += yyleng;}
"or"              	{printf("OR\n"); currPos += yyleng;}
"not"               {printf("NOT\n"); currPos += yyleng;}
"true"              {printf("TRUE\n"); currPos += yyleng;}
"false"             {printf("FALSE\n"); currPos += yyleng;}

 /*** Arithmetic Operators ***/
"-"					{printf("SUB\n"); currPos += yyleng;}
"+"					{printf("ADD\n"); currPos += yyleng;}
"*"					{printf("MULT\n"); currPos += yyleng;}
"/"					{printf("DIV\n"); currPos += yyleng;}
"%"					{printf("MOD\n"); currPos += yyleng;}

 /*** Comparison Operators ***/
"=="				{printf("EQ\n"); currPos += yyleng;}
"<>"				{printf("NEQ\n"); currPos += yyleng;}
"<"					{printf("LT\n"); currPos += yyleng;}
">"					{printf("GT\n"); currPos += yyleng;}
"<="				{printf("LTE\n"); currPos += yyleng;}
">="				{printf("GTE\n"); currPos += yyleng;}

 /*** Identifiers and Numbers ***/
{IDENTIFIER}		{printf("IDENT %s\n", yytext);}
{DIGIT}+			{printf("NUMBER %s\n", yytext);}

 /*** Other Special Symbols ***/
";"					{printf("SEMICOLON\n"); currPos += yyleng;}
":"					{printf("COLON\n"); currPos += yyleng;}
","					{printf("COMMA\n"); currPos += yyleng;}
"("					{printf("L_PAREN\n"); currPos += yyleng;}
")"					{printf("R_PAREN\n"); currPos += yyleng;}
":="				{printf("ASSIGN\n"); currPos += yyleng;}

{IDENT_DIGIT}       {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); currPos += yyleng;}
{IDENT_UNDERSCORE}  {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); currPos += yyleng;}

[ \t]+          {/* ignore spaces */ currPos += yyleng;}
"\n"            {currLine++; currPos = 1;}

.               {printf("Error at line %d, column %d, unrecognized symbol \"%s\"\n", currLine, currPos, yytext); currPos += yyleng;}
%%

main()
{
  yylex();
}

