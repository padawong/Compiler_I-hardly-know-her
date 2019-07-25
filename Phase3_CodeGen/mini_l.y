/* Section 2: */
/* error handling from https://www.gnu.org/software/bison/manual/bison.html#Error-Recovery */
%{
 #include <stdio.h>
 #include <iostream>
 #include <fstream>
 #include <iostream>
 #include <stdlib.h>
 #include <string>
 #include <string.h>
 #include <unordered_map>
 void yyerror(const char *msg);         /* function delcared at bottom */
 extern int currLine;                   /* from .lex file */
 extern int currPos;                    /* from .lex file */
 // Changed
 extern FILE * yyin; /* used to read tokens in from .lex file */
 extern int yylex(void);
 using namespace std;

 struct ExpStruct{
    const char* code;
    const char* result_id;
 } exp;

 unordered_map<string, ExpStruct> variables; // symbol table used for variable declarations (?)
 int label_num = 0;
 int temp_var_num = 0;
 int comp_var_num = 0;
 string make_label();
 string make_temp_var();
 string make_comp_var();
%}

%union{
  int ival;
  char* sval;

 struct ExpStruct{
    const char* code;
    const char* result_id;
 } exp;
}

%define parse.lac full
%define parse.error verbose
%start program                            /* start of grammar like S' */
%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN ASSIGN END
%token <ival> NUMBER
%token <sval> IDENT
%type <exp> /* NON-TERMINALS GO HERE */ program block identifiers declaration decl stmnt statement var expression bool_exp stmnt2 vars relation_and_exp rel_loop relation_exp rel_loop2 fork comp multiplicative_exp mult_loop term term_loop var_exp
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
                    os << $4.code;
                os.close();
            }
            ;

block: decl BEGIN_PROGRAM stmnt
            {
                string temp;
                temp.append($1.code);
                temp.append(": START\n");
                temp.append($3.code);
                $$.code = temp.c_str();
            }
            ;

decl: decl declaration SEMICOLON
            {
                string temp;
                temp.append($1.code);
                temp.append($2.code);
                $$.code = temp.c_str();
            }
            | declaration SEMICOLON
            {
                $$.code = $1.code;
            }
            ;

stmnt: stmnt statement SEMICOLON
            {
                string temp;
                temp.append($1.code);
                temp.append($2.code);
                $$.code = temp.c_str();
            }
            | statement SEMICOLON
            {
                $$.code = $1.code;
            }
            ;

declaration: identifiers COLON array_of INTEGER
            {
                // insert into map newly declared variables, jk
                // read: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                // write: reference map in write for values

                // identifiers: list of var names (n1 n2 n3...)

                string temp_ident;
                string temp;
                int i = 0, var_list_size = strlen($1.result_id);
                for (; i < var_list_size; i++) {
                    if ($1.result_id[i] == ' ' || i == var_list_size - 1 ) {
                        temp = "\t. _" + temp_ident + "\n";
                        $$.code = temp.c_str();
                        temp_ident.clear();
                    }
                    else {
                        temp_ident.push_back($1.result_id[i]);
                    }
                }
            }
            | identifiers error INTEGER
            {}
            ;

identifiers: identifiers COMMA IDENT
            {
                string temp;
                temp.append($1.result_id);
                temp.append(" ");
                temp.append($3);
                $$.result_id = temp.c_str();
            }
            | IDENT
            {
                string temp = $1;
                $$.result_id = $1;
            }
            ;

array_of: /* EMPTY */
            {}
            | ARRAY L_PAREN NUMBER R_PAREN OF
            {}
            ;

statement: var ASSIGN expression
            {
                string temp;
                string temp_code;
                string reversed_temp;
                // $1.result_id = $3.result_id; //x := 3 + 2;
                int commas = 2;
                for(int i = strlen($3.code) - 1; i > 0; i--){
                    if($3.code[i] == ','){
                      commas--;
                    }
                    if(commas == 0){
                      if($3.code[i] == ' '){
                        break;
                      }else{
                        reversed_temp.push_back($3.code[i]);
                      }
                    }
                }
                for(int i = 0; i < reversed_temp.size(); i++){
                  temp.push_back(reversed_temp[i]);
                }
                temp_code = string("\t=") + $1.code + ", " + temp + "\n";
                $$.code = temp_code.c_str();
            }
            | IF bool_exp THEN stmnt stmnt2 ENDIF
            {}
            | WHILE bool_exp BEGINLOOP stmnt ENDLOOP
            {
                string temp_result_id;
                string temp_code;
                string temp_comp_var;
                string temp_label_0;
                string temp_label_1;
                string temp;
            // Label
                temp_label_0 = make_label();
                temp_code.append(temp_label_0); // L0
            // bool
                temp = "\t";
                temp.append($2.code);
                temp_code.append(temp.c_str());
            // result of bool
                string bullshit;           // p0
                for(int i = 3; i < strlen($2.code); i++){
                    if($2.code[i] != ','){
                        bullshit.push_back($2.code[i]);
                    }else{ break; }
                }
                temp_comp_var = make_comp_var(); // p1
                temp = "\t";
                temp.append("== " + temp_comp_var + ", " + bullshit + ", 0\n");
                temp_code.append(temp.c_str());
            // ?:= goto
                temp_label_1 = make_label();    //L1
                temp = "\t";
                temp.append("?:= " + temp_label_1 + ", " + temp_comp_var + "\n");
                temp_code.append(temp.c_str());

            // body of while-loop
                temp_code.append($4.code); // assuming this ends with '\n'
            // goto Label
                temp = "\t";
                temp.append(":= " + temp_label_0 + "\n");
                temp_code.append(temp.c_str());
            // this bitch is done !!!
            // ok ;-;
            }
            | DO BEGINLOOP stmnt ENDLOOP WHILE bool_exp
            {}
            | READ identifiers
            {
                // NOTE: can add a check to see if key does not exist in map; if does not exist, throw error
                // see if the identifier is already in the map
                // if not, add entry
                // if so, change value
                // Separate each identifier
                string temp_ident;
                string temp;
                int i = 0, var_list_size = strlen($2.result_id);
                for (; i < var_list_size; i++) {
                    if ($2.result_id[i] == ' ' || i == var_list_size - 1 ) {
                        temp = "\t.< _" + temp_ident + "\n";
                        $$.code = temp.c_str();
                        temp_ident.clear();
                    }
                    else {
                        temp_ident.push_back($2.result_id[i]);
                    }
                }
            }
            | WRITE identifiers
            {
                string temp_ident;
                string temp;
                int i = 0, var_list_size = strlen($2.result_id);
                for (; i < var_list_size; i++) {
                    if ($2.result_id[i] == ' ' || i == var_list_size - 1 ) {
                        temp = "\t.> _" + temp_ident + "\n";
                        $$.code = temp.c_str();
                        temp_ident.clear();
                    }
                    else {
                        temp_ident.push_back($2.result_id[i]);
                    }
                }
            }
            | CONTINUE
            {}
            | error
            {}
            ;

stmnt2: /* EMPTY */
            {}
            | ELSE stmnt
            {}
            ;

vars: vars COMMA var
            {
                string temp;
                temp.append($1.result_id + ',');
                $$.result_id = temp.c_str(); 
                // .code ?
            }
            | var
            { 
                string temp;
                temp.append($1.result_id);
                $$.result_id = temp.c_str();
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
            {}
            | OR relation_and_exp rel_loop
            {}
            ;

relation_and_exp: relation_exp rel_loop2
            {
                $$.result_id = $1.result_id;
                $$.code = $1.code;
            }
            ;

rel_loop2: /* EMPTY */
            {}
            | AND relation_exp rel_loop2
            {}
            ;

relation_exp: fork
            {
                $$.result_id = $1.result_id;
                $$.code = $1.code;
            }
            | NOT fork
            {}
            ;

fork: expression comp expression
            {
                string compare; 
                string temp;

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

                $$.result_id = compare.c_str();

                temp = $2.result_id + make_comp_var() + ", " + $1.code + ", " + $3.code + "\n";
                $$.code = temp.c_str();
            }
            | TRUE
            {}
            | FALSE
            {}
            | L_PAREN bool_exp R_PAREN
            {}
            ;

comp: EQ
            {
                string temp;
                $$.result_id = "==";
            }
            | NEQ
            {}
            | LT
            {}
            | GT
            {}
            | LTE
            {
                string temp;
                $$.result_id = "<=";
            }
            | GTE
            {}
            ;

expression: multiplicative_exp mult_loop
            { // include operand and code
                string temp;
                string temp_var = make_temp_var();
                if ($2.code == "\t+ ") {
                    temp = to_string(stoi($2.result_id) + stoi($1.result_id)); // temp = operand + operand
                }
                $$.result_id = temp.c_str(); // result_id = operand + operand numerical value
            
                temp = $2.code + temp_var + "," + $1.result_id + ", " + $2.result_id + "\n";
                $$.code = temp.c_str();
            }
            ;

mult_loop: /* EMPTY */
            {
                $$.result_id = 0;
            }
            | ADD multiplicative_exp mult_loop
            {
                // NOTE: if we had looping additions, how would we separate the +s in the code?
                int temp = stoi($2.result_id) + stoi($3.result_id);
                $$.result_id = to_string(temp).c_str(); // result_id = operand (NUMBER or IDENT)
                string temp_str = "\t+ ";
                $$.code = temp_str.c_str();
            }
            | SUB multiplicative_exp mult_loop
            {}
            ;

multiplicative_exp: term term_loop
            {
                $$.result_id = $1.result_id;
                $$.code = $1.code;
            }
            ;

term_loop: /* EMPTY */
            {}
            | MULT term term_loop
            {}
            | DIV term term_loop
            {}
            | MOD term term_loop
            {}
            ;

term: SUB var %prec UMINUS
            {}
            | SUB NUMBER %prec UMINUS
            {}
            | SUB L_PAREN expression R_PAREN %prec UMINUS
            {}
            | var
            {
                $$.result_id = $1.result_id;
                $$.code = $1.code;
            }
            | NUMBER
            {
                $$.result_id = to_string($1).c_str();
                $$.code = $$.result_id;
            }
            | L_PAREN expression R_PAREN
            {}
            ;

var: IDENT var_exp
            {
                string temp_id, temp_code;
                temp_id = $1;
                $$.result_id = temp_id.c_str();
                temp_code = "_" + temp_id;
                $$.code = temp_code.c_str(); 
            }
            ;

var_exp: /* EMPTY */
            {}
            | L_PAREN expression R_PAREN
            {}
            ;

%%

string make_label() {
    string temp;
    temp = ": L" + to_string(label_num) + "\n";
    label_num++;
    return temp;
}
string make_temp_var() {
    string temp;
    temp = "t" + to_string(temp_var_num);
    temp_var_num++;
    return temp;
}
string make_comp_var() {
    string temp;
    temp = "p" + to_string(comp_var_num);
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
