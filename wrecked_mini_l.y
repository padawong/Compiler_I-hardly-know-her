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
%type <exp> /* NON-TERMINALS GO HERE */ program block identifiers declaration decl stmnt statement var expression bool_exp stmnt2 relation_and_exp rel_loop relation_exp rel_loop2 fork comp multiplicative_exp mult_loop term term_loop var_exp
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
                cout << "\n\n**************************************" << endl;
                cout << "program" << endl;
                string BITCHES = $4.code;
                cout << "bitches" << BITCHES << " were here" << endl;

                ofstream os;
                os.open("mil_code.mil");
                    os << BITCHES;
                os.close();
            }
            ;

block: decl BEGIN_PROGRAM stmnt
            {
                cout << "\n\n**************************************" << endl;
                cout << "block: decl BEGIN_PROGRAM stmnt" << endl;
                string temp;
                // decl.code is '!' for some reason (???)
                temp = strdup($1.code);
cout << "decl.code = " << temp << endl;

                temp.append(": START\n");
cout << "BLOCK TEMP = " << temp << endl;
                //$3.code is "!: START" for some reason

                temp.append($3.code);
cout << "stmnt.code = " << $3.code << endl;
                $$.code = temp.c_str();
                //cout << "$$.code = " << $$.code << endl;
            }
            ;

decl: decl declaration SEMICOLON
            {
                cout << "\n\n**************************************" << endl;
                cout << "decl: decl declaration SEMICOLON" << endl;
                string temp;
                temp.append(strdup($1.code));
cout << "decl.code = " << $1.code << endl;
                temp.append(strdup($2.code));
cout << "declaration.code = " << $2.code << endl;
                $$.code = strdup(temp.c_str());
                cout << "decl: " << $$.code << endl;
            }
            | declaration SEMICOLON
            {
                cout << "\n\n**************************************" << endl;
                cout << "decl: declaration SEMICOLON" << endl;
                $$.code = strdup($1.code);
                cout << "$$.code = " << $$.code << endl;
            }
            ;

stmnt: stmnt statement SEMICOLON
            {
                cout << "\n\n**************************************" << endl;
                cout << "stmnt: stmnt statement SEMICOLON" << endl;
                string temp;
		// code 1 -> _result
		// code 2 -> _i
		temp = "\t+ " + make_temp_var() + ", " + $1.code + ", " + $2.code + "\n";
                $$.result_id = strdup($1.code);
                $$.code = strdup($2.code);
                cout << "$$.result_id = " << $$.result_id << endl;
                cout << "$$.code = " << $$.code << endl; // make this: \t+ t0, _result, _i
            }
            | statement SEMICOLON
            {
                cout << "\n\n**************************************" << endl;
                cout << "stmnt: statement SEMICOLON" << endl;
                $$.code = strdup($1.code); // this fucks shit up :D
                cout << "$$.code = " << $$.code << endl;
            }
            ;

declaration: identifiers COLON array_of INTEGER
            {
                cout << "\n\n**************************************" << endl;
                cout << "declaration: identifiers COLON array_of INTEGER" << endl;

                string temp_final_ident;
                string temp_ident;
                string temp;
                string saved_result_id;
		saved_result_id = $1.result_id;
                int i = 0, var_list_size = saved_result_id.size();
                for (; i <= var_list_size; i++) {
                    if (!isalnum(saved_result_id[i]) || i == var_list_size) {
                        temp = "\t. _" + temp_ident + "\n";
                        temp_final_ident.append(temp);
                        temp_ident.clear();
                    }
                    else {
                        temp_ident.push_back(saved_result_id[i]);
                    }
                }
                $$.code = strdup(temp_final_ident.c_str());
                cout << "\n$$.code = " << $$.code << endl;
                cout << "\n AFTER CHANGES:\t$1.code = " << $1.code << endl;
                cout << "\t$1.result_id = " << $1.result_id << endl;
                cout << "$$.result_id = " << $$.result_id << endl;
            }
            | identifiers error INTEGER
            {}
            ;

identifiers: identifiers COMMA IDENT
            {
                cout << "\n\n**************************************" << endl;
                cout << "identifiers: identifiers COMMA IDENT" << endl;
                cout << "$1.code = " << $1.code << endl;
                cout << "$1.result_id = " << $1.result_id << endl;
                string temp;
                temp.append($1.result_id);
                temp.push_back(',');
                temp.append($3);
                $$.result_id = temp.c_str();

                cout << "\n AFTER CHANGES:\t$1.code = " << $1.code << endl;
                cout << "\t$1.result_id = " << $1.result_id << endl;
            }
            | IDENT
            {
                cout << "\n\n**************************************" << endl;
                cout << "identifiers: IDENT" << endl;
                $$.result_id = strdup($1);
            }
            ;

array_of: /* EMPTY */
            {}
            | ARRAY L_PAREN NUMBER R_PAREN OF
            {}
            ;

statement: var ASSIGN expression
            {
                cout << "\n\n**************************************" << endl;
                cout << "statement: var ASSIGN expression" << endl;
                string temp_code;
                string saved_code_1;
                string saved_code_3;
		saved_code_1 = $1.code;
		saved_code_3 = $3.code;
                //temp_code = string("\t= ") + saved_code_1 + ", " + saved_code_3 + "\n";
                $$.result_id = strdup($1.code); // _i
                $$.code = strdup($3.code); // \t+ t0, _result, _i
		// get _result from expression result_id and setup assign instruction
                cout << "$$.result_id = " << $$.result_id << endl;
                cout << "$$.code = " << $$.code << endl;
		// make this  (= 0) be this (= _result, 0) 
            }
            | IF bool_exp THEN stmnt stmnt2 ENDIF
            {}
            | WHILE bool_exp BEGINLOOP stmnt ENDLOOP
            {
                cout << "\n\n**************************************" << endl;
                cout << "statement: WHILE bool_exp BEGINLOOP stmnt ENDLOOP" << endl;
                string temp_result_id;
                string temp_code;
                string temp_comp_var;
                string temp_label_0;
                string temp_label_1;
                string temp;
                cout << "$2.code = " << $2.code << endl;
                cout << "$2.result_id = " << $2.result_id << endl;
                cout << "$4.code = " << $4.code << endl;
                cout << "$4.result_id = " << $4.result_id << endl;
            // Label
                temp_label_0 = make_label() + "\n";
                temp_code.append(": " + temp_label_0); // L0
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
                temp.append(":= " + temp_label_0 + ": " + temp_label_1 + "\n");
                temp_code.append(temp.c_str());
            // this bitch is done !!!
            // ok ;-;
		$$.code = strdup(temp_code.c_str());
		cout << "$$.code = " << $$.code << endl;
            }
            | DO BEGINLOOP stmnt ENDLOOP WHILE bool_exp
            {}
            | READ identifiers
            {
                cout << "\n\n**************************************" << endl;
                cout << "statement: READ identifiers" << endl;
                cout << "identifiers.code = " << $2.code << endl;
                // NOTE: can add a check to see if key does not exist in map; if does not exist, throw error
                // see if the identifier is already in the map
                // if not, add entry
                // if so, change value
                // Separate each identifier
                string temp_ident;
                string temp;
                string saved_result_id;
		saved_result_id = $2.result_id;
                int i = 0, var_list_size = saved_result_id.size();
                for (; i <= var_list_size; i++) {
                    if (saved_result_id[i] == ' ' || i == var_list_size) {
                        temp = "\t.< _" + temp_ident + "\n";
                        $$.code = strdup(temp.c_str());
                        cout << "$$.code = " << $$.code << endl;
                        temp_ident.clear();
                    }
                    else {
                        temp_ident.push_back(saved_result_id[i]);
                    }
                }
            }
            | WRITE identifiers
            {
                cout << "\n\n**************************************" << endl;
                cout << "statement: WRITE identifiers" << endl;
                string temp_ident;
                string temp;
                string saved_result_id;
		saved_result_id = $2.result_id;
                int i = 0, var_list_size = saved_result_id.size();
                for (; i <= var_list_size; i++) {
                    if (saved_result_id[i] == ' ' || i == var_list_size) {
                        temp = "\t.> _" + temp_ident + "\n";
                        $$.code = strdup(temp.c_str());
                        cout << "$$.code = " << $$.code << endl;
                        temp_ident.clear();
                    }
                    else {
                        temp_ident.push_back(saved_result_id[i]);
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

bool_exp: relation_and_exp rel_loop
            {
                cout << "\n\n**************************************" << endl;
                cout << "bool_exp: relation_and_exp rel_loop" << endl;
                // Or should this be something else?
                $$.result_id = strdup($1.result_id);
                $$.code = strdup($1.code);
                cout << "$$.code = " << $$.code << endl;
            }
            ;

rel_loop: /* EMPTY */
            {}
            | OR relation_and_exp rel_loop
            {}
            ;

relation_and_exp: relation_exp rel_loop2
            {
                cout << "\n\n**************************************" << endl;
                cout << "relation_and_exp: relation_exp rel_loop2" << endl;
                $$.result_id = strdup($1.result_id);
                $$.code = strdup($1.code);
                cout << "$$.code = " << $$.code << endl;
            }
            ;

rel_loop2: /* EMPTY */
            {}
            | AND relation_exp rel_loop2
            {}
            ;

relation_exp: fork
            {
                cout << "\n\n**************************************" << endl;
                cout << "relation_exp: fork" << endl;
                $$.result_id = strdup($1.result_id);
                $$.code = strdup($1.code);
                cout << "$$.code = " << $$.code << endl;
            }
            | NOT fork
            {}
            ;

fork: expression comp expression
            {
                cout << "\n\n**************************************" << endl;
                cout << "fork: expression comp expression" << endl;
                string compare; 
                string temp;
		string saved_result_id_1 = $1.result_id;
		string saved_result_id_2 = $2.result_id;
		string saved_result_id_3 = $3.result_id;
		cout << "saved_result_id_1: " << saved_result_id_1 << endl;
		cout << "saved_result_id_2: " << saved_result_id_2 << endl;
		cout << "saved_result_id_3: " << saved_result_id_3 << endl;
                if (saved_result_id_2 == "<=") {
                    if (saved_result_id_1 <= saved_result_id_3) {
                        compare = "true";
                    }
                    else {
                        compare = "false";
                    }
                }
                else if (saved_result_id_2 == "==") {
                    if (saved_result_id_1 == saved_result_id_3) {
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

                temp = string($2.result_id) + " " + make_comp_var() + ", " + $1.code + ", " + $3.code + "\n";
                $$.code = temp.c_str();
                cout << "$$.code = " << $$.code << endl;
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
                cout << "\n\n**************************************" << endl;
                cout << "comp: EQ" << endl;
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
                cout << "\n\n**************************************" << endl;
                cout << "comp: LTE" << endl;
                string temp;
                $$.result_id = "<=";
            }
            | GTE
            {}
            ;

expression: multiplicative_exp mult_loop
            { // include operand and code
                cout << "\n\n**************************************" << endl;
                cout << "expression: multiplicative_exp mult_loop" << endl;
                string temp;
                string saved_code;
                string saved_result_id_1;
                string saved_result_id_2;
		saved_code = $2.code;
		saved_result_id_1 = $1.result_id;
		saved_result_id_2 = $2.result_id;
                //string temp_var = make_temp_var();
		cout << "$1.result_id: " << $1.result_id << endl;
		cout << "$1.code: " << $1.code << endl;
		cout << "$2.result_id: " << $2.result_id << endl;
		cout << "$2.code: " << $2.code << endl;
                cout << "saved_result_id_1: " << saved_result_id_1 << endl;
                cout << "saved_result_id_2: " << saved_result_id_2 << endl;
		//temp = "\t+ ";
                //if (saved_code == temp) {
                	//temp.append(to_string(saved_result_id_2 + saved_result_id_1)); // temp = operand + operand
                //}
		// ------------ im going to ignore result_id and not care here :D
                //$$.result_id = strdup(temp.c_str()); // result_id = operand + operand numerical value
		// cout << "$$.result_id: " << $$.result_id << endl;
            
                //temp = saved_result_id_1 + ", " + saved_result_id_2 + "\n";
		//temp = "\t+ " +  make_temp_var() + ", " + $1.code + ", " + $2.code + "\n"; 
                //$$.result_id = strdup($1.result_id); // _result <--
                $$.code = strdup($1.code);
                cout << "$$.code: " << $$.code << endl;
		// pass only mult_exp id or code
            }
            ;

mult_loop: /* EMPTY */
            {
                cout << "\n\n**************************************" << endl;
                cout << "mult_loop: EMPTY" << endl;
		string temp;
		temp.clear();
                $$.result_id = temp.c_str();
                $$.code = temp.c_str();
                cout << "$$.code = " << $$.code << endl;
		
            }
            | ADD multiplicative_exp mult_loop
            {
                cout << "\n\n**************************************" << endl;
                cout << "mult_loop: ADD multiplicative_exp mult_loop" << endl;
                string a, b, temp;
                string temp_str;
                a = strdup($2.result_id);
                //b = $3.result_id;
                // NOTE: if we had looping additions, how would we separate the +s in the code?
                //temp = a + b;
                //$$.result_id = to_string(temp).c_str(); // result_id = operand (NUMBER or IDENT)
                //temp_str = "\t+ ";
                //$$.code = temp_str.c_str();
		$$.result_id = strdup(a.c_str());
		$$.code = strdup(a.c_str());
                cout << "$2.code = " << $2.code << endl;
                cout << "$3.code = " << $3.code << endl;
                cout << "$$.code = " << $$.code << endl;
            }
            | SUB multiplicative_exp mult_loop
            {}
            ;

multiplicative_exp: term term_loop
            {
                cout << "\n\n**************************************" << endl;
                cout << "multiplicative_exp: term term_loop" << endl;
                $$.result_id = strdup($1.result_id);
                $$.code = strdup($1.code);
                cout << "result_id: " << $$.result_id << endl;
                cout << "code: " << $$.code << endl;
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
                cout << "\n\n**************************************" << endl;
                cout << "term: var" << endl;
                $$.result_id = strdup($1.result_id);
                cout << "term.result_id = " << $$.result_id << endl;
                $$.code = strdup($1.code);
                cout << "term.code = " << $$.code << endl;
            }
            | NUMBER
            {
                cout << "\n\n**************************************" << endl;
                cout << "term: NUMBER" << endl;
                $$.result_id = to_string($1).c_str();
                $$.code = $$.result_id;
                cout << "$$.code = " << $$.code << endl;
            }
            | L_PAREN expression R_PAREN
            {}
            ;

var: IDENT var_exp
            {
                cout << "\n\n**************************************" << endl;
                cout << "var: IDENT var_exp" << endl;
                string temp_id, temp_code;
                temp_code = $1;
		temp_id = "_" + temp_code;
                $$.result_id = strdup(temp_id.c_str());
                $$.code = strdup(temp_id.c_str());
                cout << "1) var -> IDENT $$.result_id = " << $$.result_id << endl;
                cout << "2) var -> IDENT $$.code = " << $$.code << endl;
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
    temp = "L" + to_string(label_num);
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

