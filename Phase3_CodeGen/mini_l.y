/* Section 2: */
/* error handling from https://www.gnu.org/software/bison/manual/bison.html#Error-Recovery */
%{
 #include <stdio.h>
 #include <stdlib.h>
 #include <string>
 #include <unordered_map>
 void yyerror(const char *msg);         /* function delcared at bottom */
 extern int currLine;                   /* from .lex file */
 extern int currPos;                    /* from .lex file */
 // Changed
 extern FILE * yyin; /* used to read tokens in from .lex file */
 extern int yylex(void);
 std::unordered_map<std::string, ExpStruct> variables; // symbol table used for variable declarations (?)
 int label_num = 0;
 int temp_var_num = 0;
 int comp_var_num = 0;
 std::string make_label();
 std::string make_temp_var();
 std::string make_comp_var();
%}

%union{
  int ival;
  char* sval;

  struct ExpStruct{
    char* code;
    char* result_id;
  } exp;

}

%define parse.lac full
%define parse.error verbose
%start program                            /* start of grammar like S' */
%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN ASSIGN END
%token <ival> NUMBER
%token <sval> IDENT
%type <sval> block
%type <ExpStruct> /* NON-TERMINALS GO HERE */ identifiers declaration decl stmnt statement var expression bool_exp stmnt2 vars relation_and_exp rel_loop relation_exp rel_loop2 fork comp multiplicative_exp mult_loop term term_loop var_exp
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


program: PROGRAM IDENT SEMICOLON block END_PROGRAM
            {
              ofstream os;
              os.open("mil_code.mil");
              os << $4;
            }
       ;

block: decl BEGIN_PROGRAM stmnt
            {
              std::string temp;
              temp.append($1.code);
              temp.append($3.code);
              $$ = temp.c_str();
            }
     ;

decl: decl declaration SEMICOLON
            {
              
            }
    | declaration SEMICOLON
            {
              
            }
    ;

stmnt: stmnt statement SEMICOLON
            {
                
            }
     | statement SEMICOLON
            {
             
            }
     ;

declaration: identifiers COLON array_of INTEGER
            {
                std::string vars($1.result_id);
                std::string temp;
                std::string variable;
                bool more_vars = true;

                while(more_vars){
                    
                }

                std::string temp;
                temp.append("\t. _");
                temp.append($1.result_id);
                temp.append('\n');
            }
           | identifiers error INTEGER
           ;

identifiers: identifiers COMMA IDENT
            {
                std::string temp;
                temp.append($1.result_id);
                temp.append(' ');
                temp.append($3);
                $$.result_id = temp.c_str();
                $$.code = '';
            }
           | IDENT
            {
                $$.result_id = $1;
                $$.code = '';
            }
           ;

array_of: /* EMPTY */
        | ARRAY L_PAREN NUMBER R_PAREN OF
        ;

statement: var ASSIGN expression
            {
              
            }
         | IF bool_exp THEN stmnt stmnt2 ENDIF
         | WHILE bool_exp BEGINLOOP stmnt ENDLOOP
            {
                // Label
                // bool
                // result of bool
                // ?:= goto
                // body of while-loop
                // goto Label
            }
         | DO BEGINLOOP stmnt ENDLOOP WHILE bool_exp
         | READ vars
            {
             
            }
         | WRITE vars
            {
             
            }
         | CONTINUE
         | error
         ;

stmnt2: /* EMPTY */
      | ELSE stmnt
      ;

vars: vars COMMA var
            {
                 
            }
    | var
            {
                $$.result_id = $1.result_id;
                $$.code = $1.code;
            }
    ;

bool_exp: relation_and_exp rel_loop
            {
                // Or should this be something else?
                $$.result_id = $1.result_id;
                $$.code = $1.code;
            }
        ;

rel_loop: /* EMPTY */
        | OR relation_and_exp rel_loop
        ;

relation_and_exp: relation_exp rel_loop2
            {
                $$.result_id = $1.result_id;
                $$.code = $1.code;
            }
                ;

rel_loop2: /* EMPTY */
         | AND relation_exp rel_loop2
         ;

relation_exp: fork
            {
                $$.result_id = $1.result_id;
                $$.code = $1.code;
            }
            | NOT fork
            ;

fork: expression comp expression
            {
                std::string compare; 
                std::string temp;

                if ($2.result_id == "<=") {
                    if (stoi($1.result_id) <= stoi($3.result_id)) {
                        compare = "true";
                    }
                    else {
                        compare = "false";
                    }
                }
                else if ($2.result_id == "==") {
                    if (stoi($1.result_id) == stoi($3.result_id)) {
                        compare = "true";
                    }
                    else {
                        compare = "false";
                    }
                }

                else {
                    // :'(
                }

                fork.result_id = compare.c_str();

                temp = $2.result_id + make_comp_var() + ", " + $1.code + ", " + $3.code + "\n";
                fork.code = temp.c_str();
            }
    | TRUE
    | FALSE
    | L_PAREN bool_exp R_PAREN
    ;

komp: EQ
            {
                std::string temp;
                $$.result_id = "==";
                $$.code = '';
            }
    | NEQ
    | LT
    | GT
    | LTE
            {
                std::string temp;
                $$.result_id = "<=";
                $$.code = '';
            }
    | GTE
    ;

expression: multiplicative_exp mult_loop
            { // include operand and code
                std::string temp;
                temp = std::to_string(stoi($1.result_id) + stoi($2.result_id));
                $$.result_id = temp.c_str();
                $$.code = '';
            }
          ;

mult_loop: /* EMPTY */
            {
                $$.result_id = "0";
            }
         | ADD multiplicative_exp mult_loop
            {
                std::string temp;
                temp = std::to_string(stoi($2.result_id) + stoi($3.result_id));
                $$.result_id = temp.c_str();
                $$.code = '';
            }
         | SUB multiplicative_exp mult_loop
         ;

multiplicative_exp: term term_loop
            {
                $$.result_id = $1.result_id;
                $$.code = '';
            }
                  ;

term_loop: /* EMPTY */
         | MULT term term_loop
         | DIV term term_loop
         | MOD term term_loop
         ;

term: SUB var %prec UMINUS
    | SUB NUMBER %prec UMINUS
    | SUB L_PAREN expression R_PAREN %prec UMINUS
    | var
            {
                $$.result_id = $1.result_id;
                $$.code = $1.code;
            }
    | NUMBER
            {
                $$.result_id = std::to_string($1).c_str();
                $$.code = $$.result_id;
            }
    | L_PAREN expression R_PAREN
    ;

var: IDENT var_exp
            {
                std::string temp;
                $$.result_id = std::to_string($1).c_str();
                temp = "_" + std::to_string($1);
                $$.code = temp.c_str(); 
            }
   ;

var_exp: /* EMPTY */
       | L_PAREN expression R_PAREN
       ;

%%

std::string make_label() {
    std::string temp;
    temp = ": L" + std::to_string(label_num);
    label_num++;
    return temp;
}
std::string make_temp_var() {
    std::string temp;
    temp = "t" + std::to_string(temp_var_num);
    temp_var_num++;
    return temp;
}
std::string make_comp_var() {
    std::string temp;
    temp = "p" + std::to_string(comp_var_num);
    comp_var_num++;
    return temp;
}

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
