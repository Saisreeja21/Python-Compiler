
%{

    #include <bits/stdc++.h>
    #include "AstNode.cpp"
    using namespace std;
    extern FILE *yyin;
    extern int yylex();
    extern long long ids;
    extern stack<long long> st;
    extern int yyparse();
    extern int func_flag;
    extern long long line_num;
    void yyerror(const char * s);


    long long int my_id = 0;
    long long int my_label = 0;
    string newId(){
        string id="t"+to_string(my_id); 
        my_id++;
        return id;
    }

    map<string,string> print_map;

    string newLabel(){
        string label="L"+to_string(my_label); 
        my_label++;
        return label;
    }

        long long L_count = 1;
    string new_label(){
        string label="L"+to_string(L_count); 
        L_count++;
        return label;
    }

      long long p_count = 1;
    string print_label(){
        string label="LC"+to_string(p_count); 
        p_count++;
        return label;
    }

    map<string,map<string,SymNode*>> mp;
    map<string,map<string,map<string,SymNode*>>> class_map;
    map<string,vector<SymNode*>> func;
    map<string,map<string,vector<SymNode*>>> class_func;
    
    map<int,string> str_num;

    vector<SymNode*> test_list;

    vector<string> asm_res;

    string source_file;

    string out1;
    long long func_offset = 0;
    string current=  "global" ;
        void print_symnode(struct SymNode * a){
                cout<<"Var_name: "<<a->Var_name<<endl;
                cout<<"Type: "<<a->type<<endl;
                cout<<"Line: "<<a->line<<endl;
                cout<<"ID: "<<a->id<<endl;
                cout<<"Offset: "<<a->offset<<endl;
                cout<<"Size: "<<a->size<<endl;
                cout<<"id: "<<a->id<<endl;
                for(auto i:a->value){
                        cout<<"Value: "<<i<<endl;
                }
                cout<<endl;
        }


    int type_check(struct SymNode * n1, struct SymNode * n2){
                string a = n1->type;
                string b = n2->type;

                if( a == b) return 1;

                if(a == "int"){
                        if(b != "int" && b != "bool" && b != "float"){
                                cout<<"Error: Type Mismatch. Line number: "<<line_num<<endl;
                                print_symnode(n1);
                                print_symnode(n2);
                                return 0;
                        }
                }else if(a == "float"){
                        if(b == "string" || b[0] == 'l'){
                                cout<<"Error: Type Mismatch. Line number: "<<line_num<<endl;
                                print_symnode(n1);
                                print_symnode(n2);
                                return 0;
                        }
                }else if(a == "string" || a[0] == 'l'){
                        if(a != b ){
                                cout<<"Error: Type Mismatch. Line number: "<<line_num<<endl;
                                print_symnode(n1);
                                print_symnode(n2);
                                return 0;
                        }
                }else if(a == "bool"){
                        if(b != "bool" && b != "int"){
                                cout<<"Error: Type Mismatch. Line number: "<<line_num<<endl;
                                print_symnode(n1);
                                print_symnode(n2);
                                return 0;
                        }
                }else{
                        cout<<"Error: Type Mismatch. Line number: "<<line_num<<endl;
                        print_symnode(n1);
                        print_symnode(n2);
                        return 0;
                }

                return 1;
        }

        void check(struct SymNode * a){

                if(a->Var_name!=""){
                        string temp = a->Var_name;
                        struct SymNode * temp1 = mp[current][temp];

                        if(temp1 == NULL){
                                temp1 = mp["global"][temp];
                        }

                        if(temp1 == NULL){
                                cout<<"Error: Variable not declared"<<endl;
                                exit(0);
                        }
                }
        }

        vector<string> final;
        int class_pres = 0;
        string current_class;

        vector<string> loop_in;
        vector<string> loop_out;

        vector<string> asm_loop_in;
        vector<string> asm_loop_out;

        long long loop_count = 0;
%}

%union {
    struct SymNode * info;
}

%token MAIN
%token<info> INT FLT STR BOOL
%token<info> ENDMARKER
%token<info> INDENT
%token<info> DEDENT
%token<info> NEWLINE
%token<info> ARROW
%token<info> OB __INIT__
%token<info> CB LEN
%token<info> SEMICOLON
%token<info> BREAK
%token<info> CONTINUE
%token<info> ASSIGNMENT_OPERATOR
%token<info> RETURN
%token<info> CLASS
%token<info> DEF
%token<info> IDENTIFIER
%token<info> GLOBAL NONLOCAL
%token<info> COMMA STOP COLON
%token<info> IF
%token<info> ELIF
%token<info> ELSE
%token<info> WHILE
%token<info> FOR __NAME__
%token<info> BOR BAND NOT
%token<info> OSB CSB
%token<info>  EQ DEQ NEQ LTE LT GTE GT IN IS 
%token<info> OR CAP AND LS RS
%token<info> PLUS MINUS MULTIPLY DIVIDE FLOORDIVIDE PERCENT TILDE POWER
%token<info> AWAIT
%token<info> TRUE FALSE NONE
%token<info> FLOAT INTEGER STRING
%token<info> LIST
%token<info> KEYWORD
%token<info> RANGE
%token ERROR

%type<info> comp_op OP
%type<info> file_input filemaker 
%type<info> funcdef parameters typedargslist statements simple_stmt suite stmt compound_stmt small_stmt
%type<info> expr_stmt elif_maker for_stmt while_stmt if_stmt 
%type<info>  return_stmt continue_stmt
%type<info> break_stmt flow_stmt testlist classdef
%type<info> expr xor_expr and_expr shift_expr lsrs_arith_expr arith_expr
%type<info> plus_minus term factor power atom_expr atom TYPE NUMBER strings 
%type<info> tfpdef_new test and_test not_test comparison 

%%

file_input: ENDMARKER {
                $$ = new SymNode();
        }
        | filemaker ENDMARKER {
                cout<<"Iam here -12334"<<endl;
                $$ = $1;
                final = $$->mycode;
                asm_res = $$->asm_code;
        }

statements: stmt { 
                cout<<"Iam here -1234"<<endl;
                $$=$1;
        }
          | statements stmt {
                cout<<"Iam here -123"<<endl;
                $$ = $1;
                for(auto x : $2->mycode){
                        $$->mycode.push_back(x);
                        
                }
                for(auto x : $2->asm_code){
                        $$->asm_code.push_back(x);
                }
          }
           
filemaker: NEWLINE {
                cout<<"Iam here 11\123"<<endl;
                $$ = new SymNode();
        }
        | stmt {
                cout<<"Iam here 11123"<<endl;
                $$ = new SymNode();
                cout<<$1<<endl;
                $$->mycode = $1->mycode;
                $$->asm_code = $1->asm_code;
        }
        | filemaker NEWLINE {
                cout<<"Iam here 1123"<<endl;
                $$ = new SymNode();
                $$->mycode = $1->mycode;
                $$->asm_code = $1->asm_code;
        }
        | filemaker stmt {
                cout<<"Iam here 123"<<endl;
                $$ = new SymNode();
                $$->mycode = $1->mycode;
                $$->asm_code = $1->asm_code;
                for(auto x : $2->mycode){
                        $$->mycode.push_back(x);
                        
                }
                for(auto x : $2->asm_code){
                        $$->asm_code.push_back(x);
                }
        }

funcdef: DEF IDENTIFIER {
                func_offset = 0;
                current = $2->Var_name;
                if(class_pres == 0){ 
                        if(mp.find(current) != mp.end()) {
                                cout<<"Error: Function already declared. line number: "<<line_num<<endl;
                                exit(0);
                        }
                }else{
                        if(class_map[current_class].find(current) != class_map[current_class].end()){
                                cout<<"Error: Function already declared in side the class. Line num: "<<line_num<<endl;
                                exit(0);
                        }
                }
        } parameters ARROW TYPE { 
                if(class_pres == 0) func[current].push_back($6);
                else{
                        class_func[current_class][current].push_back($6);
                }
                string print_name = print_label();
                print_map[current] = print_name;
        } COLON suite {
                
                $$ = new SymNode();
                $$->mycode.push_back(current+":");
                $$->mycode.push_back("beginfunc");

        
                $$->asm_code.push_back("."+print_map[current]+":");
                $$->asm_code.push_back(".string	\"%lld\\n\"");
                $$->asm_code.push_back(".text");
                $$->asm_code.push_back(".globl	" + current);
                $$->asm_code.push_back(".type	" + current + ", @function");

                $$->asm_code.push_back(current+":");
                for(auto x : $4->mycode){
                        $$->mycode.push_back(x);     
                }
                // for(auto x : $4->asm_code){
                //         $$->mycode.push_back(x);
                // }
                for(auto x : $9->mycode){
                        $$->mycode.push_back(x);
                }
                for(auto x : $9->asm_code){
                        $$->asm_code.push_back(x);
                }

                $$->mycode.push_back("endfunc");
                $$->asm_code.push_back("movq    $0, %rax");
                $$->asm_code.push_back("leave");
                $$->asm_code.push_back("ret");
                current = "global";
                func_offset = 0;
        }
        | DEF __INIT__ {current = current_class;} parameters ARROW TYPE {
                class_func[current_class][current].push_back($6);
        }COLON suite {
                $$ = new SymNode();
                $$->mycode.push_back(current+":");
                $$->mycode.push_back("beginfunc");

                for(auto x : $4->mycode){
                        $$->mycode.push_back(x);
                }

                for(auto x : $4->asm_code){
                        $$->asm_code.push_back(x);
                }

                for(auto x : $9->mycode){
                        $$->mycode.push_back(x);
                }

                for(auto x : $9->asm_code){
                        $$->asm_code.push_back(x);
                }

                $$->mycode.push_back("endfunc");
                current = "global";
                func_offset = 0;
        }
        

parameters: OB typedargslist CB { 
                $$ = new SymNode();
                $$->mycode = $2->mycode;
                $$->asm_code = $2->asm_code;
                $$->line = $2->line;
             }
            | OB CB {
                $$ = new SymNode();
            }

typedargslist: typedargslist COMMA tfpdef_new {
                        $$ = new SymNode();
                        $$->mycode = $1->mycode;
                        $$->asm_code = $1->asm_code;
                        for(auto x : $3->mycode){
                                $$->mycode.push_back(x); 
                        }
                        for(auto x : $3->asm_code){
                                $$->asm_code.push_back(x);
                        }
                }
               | tfpdef_new {
                        $$ = new SymNode();
                        $$->mycode = $1->mycode;   
                        $$->asm_code = $1->asm_code;     
                }


tfpdef_new: IDENTIFIER COLON TYPE EQ test {  // check type casting here  !!!!!!
                
                if($3->type == "int"){
                        if($5->type != "int" && $5->type != "bool"){
                                cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }
                else if($3->type == "float"){
                        if($5->type == "string" || $5->type[0] == 'l'){
                                cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }
                else if($3->type == "string" || $3->type[0] == 'l'){
                        if($3->type != $5->type ){
                                cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }
                else if($3->type == "bool"){
                        if($5->type != "bool" && $5->type != "int"){
                                cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }else{

                }
                $1->value = $5->value;
                $1->type = $3->type;
                $1->id = "identifier";
                $1->addr = newId();
                if(mp[current].find($1->Var_name) == mp[current].end()) mp[current][$1->Var_name] = $1;
                else {
                        cout<<"Error: Variable already declared. Line number:"<<line_num<<endl;
                        exit(0);
                }

                func[current].push_back($1);
                $$ = new SymNode();
                $$->addr = $1->addr;
                $$->line = line_num;
                $$->mycode.push_back($$->addr + " = " + "popparam" );

            }
            | IDENTIFIER COLON TYPE {
                cout<<"Iam here -2"<<endl;
                $1->type = $3->type;
                $1->id = "identifier";
                $1->line = line_num;
                $1->addr = newId();
                

                
                $$ = new SymNode();
                $$->addr = $1->addr;
                $$->line = line_num;
                $$->mycode.push_back($$->addr + " = " + "popparam" );
                $$->asm_code.push_back("subq         $16, %rsp");
                func_offset = func_offset + 8;
                $1->offset = func_offset;
                $1->size = 8;
                $$->asm_code.push_back("movq         -" + to_string($1->offset) + "(%rbp)");

                $$->asm_code.push_back("movq         ");




                if(mp[current].find($1->Var_name) == mp[current].end()) mp[current][$1->Var_name] = $1;
                else {
                        cout<<"Error: Variable already declared. Line number:"<<line_num<<endl;
                        exit(0);
                }
                func[current].push_back($1);
            }


stmt: simple_stmt {
        cout<<"iam here -14"<<endl;
        $$ = $1;
    }
    | compound_stmt {
        $$ = $1;
    }
    

simple_stmt: small_stmt NEWLINE {cout<<"Iam here -601"<<endl;$$ = $1;}
           | small_stmt SEMICOLON simple_stmt {
                cout<<"Iam here -6969"<<endl; 
                $$ = $1;
                for(auto x : $3->mycode){
                        $$->mycode.push_back(x);
                        
                }
                for(auto x : $3->asm_code){
                        $$->asm_code.push_back(x);
                }
            }
           | small_stmt SEMICOLON NEWLINE {
                cout<<"Iam here -69"<<endl;
                $$ = $1;
            }
           

small_stmt: expr_stmt { $$ = $1; }
            | flow_stmt { $$ = $1;}
 
expr_stmt: IDENTIFIER COLON TYPE{
                //declaration
                cout<<"Iam here -4"<<endl;
                if(class_pres == 0){
                        if(mp[current].find($1->Var_name) != mp[current].end()){
                                cout<<"Error: Variable already declared. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                        $$ = new SymNode();
                        $1->type = $3->type;
                        $1->id = "identifier";
                        $1->line = line_num;
                        if($3->type == "int"){
                                $1->offset = func_offset + 4;
                                func_offset = func_offset+4;
                                $1->size = 4;
                        }else if($3->type == "bool"){
                                $1->offset = func_offset + 1;
                                func_offset = func_offset+1;
                                $1->size = 1;
                        }else if($3->type == "string"){
                                $1->offset = func_offset + 4;
                                func_offset = func_offset+4;
                                $1->size = 4;
                        }else if($3->type[0] == 'l'){
                                $1->offset = func_offset + 4;
                                func_offset = func_offset+4;
                                $1->size = 4;
                        }else{
                                // need to implement class
                        }
                        mp[current][$1->Var_name] = $1;
                        
                }else{
                        if(class_map[current_class][current].find($1->Var_name) != class_map[current_class][current].end()){
                                cout<<"Error: Variable already declared. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                        $$ = new SymNode();
                        $1->type = $3->type;
                        $1->id = "identifier";
                        $1->line = line_num;
                        class_map[current_class][current][$1->Var_name] = $1;
                }
        }
        | IDENTIFIER COLON TYPE EQ test{
                //declaration and assignment
                cout<<"Okay till expr statement"<<endl;
                if(class_pres == 0){
                        if(mp[current].find($1->Var_name) != mp[current].end()){
                                cout<<"Error: Variable already declared. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }
                else{
                        if(class_map[current_class][current].find($1->Var_name) != class_map[current_class][current].end()){
                                cout<<"Error: Variable already declared. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }

                $1->addr = $1->Var_name;

                if($3->type == "None"){
                        cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                        exit(0);
                }

                if($3->type == "int"){
                        if($5->type != "int" && $5->type != "bool"){
                                cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }

                if($3->type == "float"){
                        if($5->type == "string" || $5->type[0] == 'l'){
                                cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }

                if($3->type == "string" || $3->type[0] == 'l'){
                        if($3->type != $5->type ){
                                cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }

                if($3->type == "bool"){
                        if($5->type != "bool"){
                                cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }

                $1->id = "identifier";
                $1->type = $3->type;

                if($3->id == "classobject"){
                        if(class_map.find($3->Var_name) != class_map.end()){
                                cout<<"Error: Class Not defined. Line num : "<<line_num<<endl;
                                exit(0);
                        }
                        $1->type = $3->Var_name;
                        $1->id = "classobject";
                }
                cout<<"Iam here - 5 - 1"<<endl;
                if($3->type == "int"){
                        $1->offset = func_offset + 8;
                        func_offset = func_offset+8;
                        $1->size = 8;
                }else if($3->type == "bool"){
                        $1->offset = func_offset + 8;
                        func_offset = func_offset+8;
                        $1->size = 8;
                }else if($3->type == "string"){
                        // $1->offset = func_offset + 4;
                        // func_offset = func_offset+4;
                        // $1->size = 4;

                        // need to think
                }else if($3->type[0] == 'l'){
                        // $1->offset = func_offset + 4;
                        // func_offset = func_offset+4;
                        // $1->size = 4;

                        // need to think
                }else{
                        // need to implement class
                }
                cout<<"Iam here - 5 - 2"<<endl;
                $1->value = $5->value;
                $1->line = line_num;

                if(class_pres == 0) mp[current][$1->Var_name] = $1;
                else class_map[current_class][current][$1->Var_name] = $1;

                $$ = new SymNode();
                $$->mycode = $5->mycode;
                $$->asm_code = $5->asm_code;
                $$->mycode.push_back($1->Var_name + " = " + $5->addr);
                // cout<<$1->Var_name + " = " + $5->addr<<endl;
                cout<<"Iam here - 5 - 3"<<endl;
                if($1->type == "int" || $1->type == "bool"){
                        $$->asm_code.push_back("subq	 $16, %rsp");
                        $$->asm_code.push_back("movq	 -" + to_string($5->offset) + "(%rbp) ,%r9");
                        $$->asm_code.push_back("movq	 %r9, -" + to_string($1->offset) + "(%rbp)");
                }
                cout<<"Going out of expr statement"<<endl;

        }
        | test ASSIGNMENT_OPERATOR test {
                cout<<"Iam here -5"<<endl;

                if($1->id != "identifier"){
                        cout<<"Error: Invalid Assignment. Line number:"<<line_num<<endl;
                        exit(0);
                }

                if($3->id == "classobject"){
                        cout<<"Error: Invalid Assignment. Line number:"<<line_num<<endl;
                        exit(0);
                }

                int re = type_check($1,$3);
                if(re == 0){
                        exit(0);
                }  
                $$ = new SymNode();
                $$->mycode = $1->mycode;
                $$->asm_code = $1->asm_code;
                for(auto x : $3->mycode){
                        $$->mycode.push_back(x);
                        $$->asm_code.push_back(x);
                }
                $$->mycode.push_back($1->Var_name + " " +$2->value[0]+ " "+ $3->addr);
                $$->addr = $1->Var_name;
               //  $$->asm_code.push_back("movq	 -" + to_string($3->offset) + "(%rbp)" + ",-" + to_string($1->offset) + "(%rbp)");
                // left to do
//############################
        }
        | test EQ test {
                cout<<"Iam here -6"<<endl;
                if($1->id != "identifier"){
                        print_symnode($1);
                        cout<<"Error: Invalid Assignment. Line number:"<<line_num<<endl;
                        exit(0);
                }

                if($3->id == "classobject"){
                        cout<<"Error: Invalid Assignment. Line number:"<<line_num<<endl;
                        exit(0);
                }

                int re = type_check($1,$3);
                if(re == 0){
                        exit(0);
                }

                $$ = new SymNode();
                $$->mycode = $1->mycode;
                $$->asm_code = $1->asm_code;
                for(auto x : $3->mycode){
                        $$->mycode.push_back(x);
                        
                }
                for(auto x : $3->asm_code){
                        $$->asm_code.push_back(x);
                }
                $$->mycode.push_back($1->Var_name + " = "+ $3->addr);
                if($1->type=="int" || $1->type=="bool"){
                        $$->asm_code.push_back("movq	 -" + to_string($3->offset) + "(%rbp) ,%r9");
                        $$->asm_code.push_back("movq	 %r9, -" + to_string($1->offset) + "(%rbp)");
                }
        }
        | test {
                $$ = $1;
                cout<<"Iam here - 709"<<endl;
                // for(auto x : $$->mycode){
                //         cout<<x<<endl;
                // }

        }     

flow_stmt: break_stmt {$$ = $1;} | continue_stmt { $$ = $1;} | return_stmt { $$ = $1;} 


break_stmt: BREAK { 
                if(loop_count > 0){
                        $$ = new SymNode();
                        $$->mycode.push_back("goto "+ loop_out.back());
                        $$->asm_code.push_back("jmp           ." + asm_loop_out.back());
                }else{
                        cout<<"Error: Break statement outside loop. Line number:"<<line_num<<endl;
                        exit(0);
                }
          } 
continue_stmt: CONTINUE {
                if(loop_count > 0){
                        $$ = new SymNode();
                        $$->mycode.push_back("jump "+ loop_in.back());
                        $$->asm_code.push_back("jmp           ." + asm_loop_in.back());
                }else{
                        cout<<"Error: Continue statement outside loop. Line number:"<<line_num<<endl;
                        exit(0);
                }
             } 


return_stmt: RETURN NONE {
                cout<<"Iam here -100"<<endl;
                struct SymNode * last;
                if(class_pres == 0) last = func[current].back();
                else last = class_func[current_class][current].back();

                if(last->type != "None"){
                        cout<<"Error: Return Type Mismatch. Line number:"<<line_num<<endl;
                        exit(0);
                }
                $$ = new SymNode;
                $$->mycode.push_back("return");
           }
           |RETURN test {
                // check
                cout<<"Iam here -7"<<endl;
                struct SymNode * last ;
                if(class_pres == 0) last = func[current].back();
                else last = class_func[current_class][current].back();

                if(last->type != $2->type){
                        cout<<"Error: Return Type Mismatch. Line number:"<<line_num<<endl;
                        exit(0);
                }
                $$ = new SymNode();
                $$->mycode = $2->mycode;
                $$->mycode.push_back("push " + $2->addr);
                $$->mycode.push_back("return");
           }
           | RETURN {        
                cout<<"Iam here -8"<<endl;
                struct SymNode * last;
                if(class_pres == 0) last = func[current].back();
                else last = class_func[current_class][current].back();

                if(last->type != "None"){
                        cout<<"Error: Return Type Mismatch. Line number:"<<line_num<<endl;
                        exit(0);
                }
                $$ = new SymNode();
                $$->mycode.push_back("return");
           } 


                
compound_stmt: if_stmt{ $$ = $1;}  
                | while_stmt{ $$ = $1;}  
                | for_stmt{ $$ = $1;}  
                | funcdef{
                        cout<<"yes func"<<endl;
                        // cout<<$1<<endl;
                        $$ = $1;
                 }  
                | classdef {$$ = $1; } 

if_stmt: IF __NAME__ DEQ STRING COLON suite{
                $$ = new SymNode();
               
        }
        |IF test COLON suite{
                $$ = new SymNode();
                $$->mycode = $2->mycode;
                string l = newLabel();
                $$->mycode.push_back("if !" + $2->addr + " goto " + l);
                for(auto x : $4->mycode){
                        $$->mycode.push_back(x);
                }
                $$->mycode.push_back(l + ":");


                $$->asm_code = $2->asm_code;
                $$->asm_code.push_back("movq         -" + to_string($2->offset) + "(%rbp), %rax");
                $$->asm_code.push_back("cmpq         $0, %rax");
                string a1 = new_label();
                $$->asm_code.push_back("jle           ." + a1);
                for(auto x : $4->asm_code){
                        $$->asm_code.push_back(x);
                }
                $$->asm_code.push_back("." + a1 + ":");

        }
        | IF test COLON suite ELSE COLON suite {
                $$ = new SymNode();
                $$->mycode = $2->mycode;
                string l = newLabel();
                $$->mycode.push_back("if !" + $2->addr + " goto " + l);
                for(auto x : $4->mycode){
                        $$->mycode.push_back(x);
                }
                string l2 = newLabel();
                $$->mycode.push_back("goto " + l2);
                $$->mycode.push_back(l + ":");
                for(auto x : $7->mycode){
                        $$->mycode.push_back(x);
                }
                $$->mycode.push_back("goto " + l2);
                $$->mycode.push_back(l2 + ":");


                $$->asm_code = $2->asm_code;
                $$->asm_code.push_back("movq         -" + to_string($2->offset) + "(%rbp), %rax");
                $$->asm_code.push_back("cmpq         $0, %rax");
                string a1 = new_label();  
                $$->asm_code.push_back("jle           ." + a1);
                for(auto x : $4->asm_code){
                        $$->asm_code.push_back(x);
                }
                string a2 = new_label();
                $$->asm_code.push_back("jmp           ." + a2);
                $$->asm_code.push_back("." + a1 + ":");
                for(auto x : $7->asm_code){
                        $$->asm_code.push_back(x);
                }
                $$->asm_code.push_back("." + a2 + ":");

        }
        | IF test COLON suite elif_maker ELSE COLON suite{
                $$ = new SymNode();
                $$->mycode = $2->mycode;
                string l = newLabel();
                $$->mycode.push_back("if !" + $2->addr + " goto " + l);
                for(auto x : $4->mycode){
                        $$->mycode.push_back(x);
                }
                out1 = newLabel();
                $$->mycode.push_back("goto " + out1);
                $$->mycode.push_back(l + ":");
                for(auto x : $5->mycode){
                        $$->mycode.push_back(x);
                }
                for(auto x : $8->mycode){
                        $$->mycode.push_back(x);
                }
                $$->mycode.push_back("goto " + out1);
                $$->mycode.push_back(out1 + ":");

        }
        | IF test COLON suite elif_maker{
                $$ = new SymNode();
                $$->mycode = $2->mycode;
                string l = newLabel();
                $$->mycode.push_back("if !" + $2->addr + " goto " + l);
                for(auto x : $4->mycode){
                        $$->mycode.push_back(x);
                }
                out1 = newLabel();
                $$->mycode.push_back("goto " + out1);
                $$->mycode.push_back(l + ":");
                for(auto x : $5->mycode){
                        $$->mycode.push_back(x);
                }
                $$->mycode.push_back("goto " + out1);
                $$->mycode.push_back(out1 + ":");




        }
         

elif_maker: ELIF test COLON suite {
                $$ = new SymNode();
                $$->mycode = $2->mycode;
                string l = newLabel();
                $$->mycode.push_back("if !" + $2->addr + " goto " + l);
                for(auto x : $4->mycode){
                        $$->mycode.push_back(x);
                }
                $$->mycode.push_back("goto " + out1);
                $$->mycode.push_back(l + ":");
           }
          | ELIF test COLON suite elif_maker {
                $$ = new SymNode();
                $$->mycode = $2->mycode;
                string l = newLabel();
                $$->mycode.push_back("if !" + $2->addr + " goto " + l);
                for(auto x : $4->mycode){
                        $$->mycode.push_back(x);
                }
                $$->mycode.push_back("goto " + out1);
                $$->mycode.push_back(l + ":");
                for(auto x : $5->mycode){
                        $$->mycode.push_back(x);
                }
          }

while_stmt:WHILE test COLON{
        loop_count++;
        loop_in.push_back(newLabel());
        loop_out.push_back(newLabel());
        asm_loop_in.push_back(new_label());
        asm_loop_out.push_back(new_label());
} suite{
                $$ = new SymNode();
                for(auto x : $2->mycode){
                        $$->mycode.push_back(x);
                }

                $$->mycode.push_back("goto "+loop_in.back());
                $$->mycode.push_back(loop_in.back() + ":");
                $$->mycode.push_back("if !" + $2->addr + " goto " + loop_out.back());
                for(auto x : $5->mycode){
                        $$->mycode.push_back(x);
                }

                $$->mycode.push_back(" jump "+ loop_in.back());
                $$->mycode.push_back(loop_out.back() + ":");
                loop_count--;
                loop_in.pop_back();
                loop_out.pop_back();

                
                $$->asm_code.push_back("jmp     ." + asm_loop_in.back());
                string suite = new_label();
                $$->asm_code.push_back("." + suite + ":");
                for(auto x : $5->asm_code){
                        $$->asm_code.push_back(x);
                }

                $$->asm_code.push_back("." + asm_loop_in.back() + ":");
                for(auto x : $2->asm_code){
                        $$->asm_code.push_back(x);
                }
                $$->asm_code.push_back("movq         -" + to_string($2->offset) + "(%rbp), %rax");
                $$->asm_code.push_back("cmpq         $0, %rax");
                $$->asm_code.push_back("jle           ." + suite);
                $$->asm_code.push_back("jmp           ." + asm_loop_out.back());
                $$->asm_code.push_back("." + asm_loop_out.back() + ":");

                asm_loop_in.pop_back();
                asm_loop_out.pop_back();

        }

for_stmt: FOR IDENTIFIER IN RANGE OB test CB COLON{
        loop_count++;
        loop_in.push_back(newLabel());
        loop_out.push_back(newLabel());
        asm_loop_in.push_back(new_label());
        asm_loop_out.push_back(new_label());

} suite{
        // check if the variables in the exprlist are declared
                cout<<"Iam here -99"<<endl;
                string a = $2->Var_name;
                
                $2 = mp[current][a];
                print_symnode($2);
                print_symnode($6);
                if($2 == NULL){
                        $2 = mp["global"][a];
                }
                if($2 == NULL){
                        cout<<"Error: Variable not declared. line number:"<<line_num<<endl;
                        exit(0);
                }
                if($2->id == "identifier"){
                        if($2->type != "int"){
                                print_symnode($6);
                                cout<<"Error: Type Mismatch. line number:"<<line_num<<endl;
                                exit(0);
                        } 
                }else{
                        cout<<"Error: Variable should be int. line number:"<<line_num<<endl;
                        exit(0);
                }

                if($6->id == "identifier"){
                        // check($6);
                        string a = $6->Var_name;
                        $6 = mp[current][a];
                        if($6 == NULL){
                                $6 = mp["global"][a];
                        }
                        if($6 == NULL){
                                cout<<"Error: Variable not declared. line number:"<<line_num<<endl;
                                exit(0);
                        }
                        if($6->type != "int"){
                                print_symnode($6);
                                cout<<"Error: Type Mismatch. line number:"<<line_num<<endl;
                                exit(0);
                        } 
                
                }else {
                        if($6->type != "int"){
                                print_symnode($6);
                                cout<<"Error: Type Mismatch. line number:"<<line_num<<endl;
                                exit(0);
                        }

                }

                $$ = new SymNode();
                for (auto x : $6->mycode){
                        $$->mycode.push_back(x);
                }
                $$->mycode.push_back($2->addr+" = "+ "0");
                $$->mycode.push_back("if " + $2->addr + " >= " + $6->addr + " goto " + loop_out.back());
                $$->mycode.push_back(loop_in.back() + ":");
                for(auto x : $10->mycode){
                        $$->mycode.push_back(x);
                }
                $$->mycode.push_back($2->addr+" = " + $2->addr + "+" + "1");
                $$->mycode.push_back("if " + $2->addr + " < " + $6->addr + " jump " + loop_in.back());
                $$->mycode.push_back(loop_out.back() + ":");
                loop_count--;
                loop_in.pop_back();
                loop_out.pop_back();

                $$->asm_code.push_back("movq         $0, -" + to_string($2->offset) + "(%rbp)");
                $$->asm_code.push_back("jmp             " + asm_loop_in.back());
                string suite = new_label();
                $$->asm_code.push_back("." + suite + ":");
                for(auto x : $10->asm_code){
                        $$->asm_code.push_back(x);
                }
                $$->asm_code.push_back("addq            $1,-"+to_string($2->offset)+"(%rbp)");
                $$->asm_code.push_back("." + asm_loop_in.back() + ":");
                $$->asm_code.push_back("movq         -" + to_string($2->offset) + "(%rbp), %rax");
                $$->asm_code.push_back("cmpq         -" + to_string($6->offset) + "(%rbp), %rax");
                $$->asm_code.push_back("jge           ." + loop_out.back());
                $$->asm_code.push_back("jmp           ." + suite);
                $$->asm_code.push_back("." + loop_out.back() + ":");

                asm_loop_in.pop_back();
                asm_loop_out.pop_back();
        }
        |FOR IDENTIFIER IN RANGE OB test COMMA test CB COLON{
                loop_count++;
                loop_in.push_back(newLabel());
                loop_out.push_back(newLabel());
                asm_loop_in.push_back(new_label());
                asm_loop_out.push_back(new_label());
        } suite{
        // check if the variables in the exprlist are declared
                string a = $2->Var_name;
                $2 = mp[current][a];
                if($2 == NULL){
                        $2 = mp["global"][a];
                }
                if($2 == NULL){
                        cout<<"Error: Variable not declared. line number:"<<line_num<<endl;
                        exit(0);
                }
                if($2->id == "identifier"){
                        if($2->type != "int"){
                                print_symnode($6);
                                cout<<"Error: Type Mismatch. line number:"<<line_num<<endl;
                                exit(0);
                        } 
                }else{
                        cout<<"Error: Variable should be int. line number:"<<line_num<<endl;
                        exit(0);
                }

                if($2->id == "identifier"){
                        if($2->type != "int"){
                                cout<<"Error: Type Mismatch. line number:"<<line_num<<endl;
                                exit(0);
                        } 
                }else{
                        cout<<"Error: Identifier expected. line number:"<<line_num<<endl;
                        exit(0);
                }

                if($6->id == "identifier" && $8->id == "identifier"){   
                        // check($6);
                        string a = $6->Var_name;
                        string b = $8->Var_name;
                        $6 = mp[current][a];
                        $8 = mp[current][b];
                        if($6 == NULL){
                                $6 = mp["global"][a];
                        }
                        if($8 == NULL){
                                $8 = mp["global"][b];
                        }
                        if($6 == NULL || $8 == NULL){
                                cout<<"Error: Variable not declared. line number:"<<line_num<<endl;
                                exit(0);
                        }
                        if($6->type != "int" || $8->type != "int"){
                                cout<<"Error: Type Mismatch. line number:"<<line_num<<endl;
                                exit(0);
                        } 
                
                }else {
                        if($6->type != "int" || $8->type != "int"){
                                cout<<"Error: Type Mismatch. line number:"<<line_num<<endl;
                                exit(0);
                        }

                }

                $$ = new SymNode();
                for (auto x : $6->mycode){
                        $$->mycode.push_back(x);
                }

                for (auto x : $8->mycode){
                        $$->mycode.push_back(x);
                }

                $$->mycode.push_back($2->addr+" = "+ $6->addr);
                
                $$->mycode.push_back("if " + $2->addr + " >= " + $8->addr + " goto " + loop_out.back());
                $$->mycode.push_back(loop_in.back() + ":");
                for(auto x : $12->mycode){
                        $$->mycode.push_back(x);
                }
                $$->mycode.push_back($2->addr+" = " + $2->addr + "+" + "1");
                $$->mycode.push_back("if " + $2->addr + " < " + $8->addr + " jump " + loop_in.back());
                $$->mycode.push_back(loop_out.back() + ":");
                loop_count--;
                loop_in.pop_back();
                loop_out.pop_back();

                $$->asm_code.push_back("movq         -" + to_string($6->offset) + "(%rbp), %r9");
                $$->asm_code.push_back("movq         %r9,-" + to_string($2->offset) + "(%rbp)");
                $$->asm_code.push_back("jmp             " + asm_loop_in.back());
                string suite = new_label();
                $$->asm_code.push_back("." + suite + ":");
                for(auto x : $10->asm_code){
                        $$->asm_code.push_back(x);
                }
                $$->asm_code.push_back("addq            $1,-"+to_string($2->offset)+"(%rbp)");
                $$->asm_code.push_back("." + asm_loop_in.back() + ":");
                $$->asm_code.push_back("movq         -" + to_string($2->offset) + "(%rbp), %rax");
                $$->asm_code.push_back("cmpq         -" + to_string($6->offset) + "(%rbp), %rax");
                $$->asm_code.push_back("jge           ." + loop_out.back());
                $$->asm_code.push_back("jmp           ." + suite);
                $$->asm_code.push_back("." + loop_out.back() + ":");

                asm_loop_in.pop_back();
                asm_loop_out.pop_back();
        }



suite: simple_stmt {
        $$ = $1;
        if(current == "global") $$ = new SymNode();
 }  
     | NEWLINE INDENT statements DEDENT{
        
        $$  = new SymNode();
        if(current != "global"){
                for(auto x : $3->mycode){
                        $$->mycode.push_back(x);     
                }

                for(auto x : $3->asm_code){
                        $$->asm_code.push_back(x);
                }
        }

     }

test: test BOR and_test{
                cout<<"okay till test"<<endl;
              $$ = new SymNode;
              $$->type = "bool";
              $$->line = line_num;
              $$->addr = newId();
              $$->mycode = $1->mycode;
              $$->asm_code = $1->asm_code;
              for(auto x : $3->mycode){
                      $$->mycode.push_back(x);
              }
                for(auto x : $3->asm_code){
                        $$->asm_code.push_back(x);
                }
              $$->mycode.push_back($$->addr + " = " + $1->addr+ $2->value[0] + $3->addr);
              // offset 
              $$->asm_code.push_back("cmpl        $0,-" +to_string($1->offset)+"(%rbp)");
              string a = new_label();
              $$->asm_code.push_back("jne          ."+a);
              $$->asm_code.push_back("cmpl        $0,-" +to_string($3->offset)+"(%rbp)");
              string b = new_label();
	      $$->asm_code.push_back("je           ."+b);
              $$->asm_code.push_back("."+a+":");
              $$->asm_code.push_back("movl	$1, %eax");
              string c = new_label();
              $$->asm_code.push_back("jmp	."+c);
              $$->asm_code.push_back("."+b+":");
              $$->asm_code.push_back("movl	$0, %eax");
              $$->asm_code.push_back("."+c+":");
              func_offset = func_offset + 8;
              $$->offset = func_offset;
              $$->size = 8;
              $$->asm_code.push_back("subq        $16, %rsp");
              $$->asm_code.push_back("movq	%eax, -"+to_string(func_offset)+"(%rbp)");       
              $$->asm_code.push_back("movl	$0, %eax");   
	        
        } 
        | and_test{
                cout<<"okay till test"<<endl;
                $$ = $1;
        } 

and_test: and_test BAND not_test{
                cout<<"okay till andtest"<<endl;
                $$ = new SymNode;
                $$->type = "bool";
                $$->line = line_num;
                $$->addr = newId();
                $$->mycode = $1->mycode;
                $$->asm_code = $1->asm_code;
                for(auto x : $3->mycode){
                        $$->mycode.push_back(x);
                }
                for(auto x : $3->asm_code){
                        $$->asm_code.push_back(x);
                }
                $$->mycode.push_back($$->addr + " = " + $1->addr+ $2->value[0] + $3->addr);

              $$->asm_code.push_back("cmpl        $0,-" +to_string($1->offset)+"(%rbp)");
              string a = new_label();
              $$->asm_code.push_back("je          ."+a);
              $$->asm_code.push_back("cmpl        $0,-" +to_string($3->offset)+"(%rbp)");
	      $$->asm_code.push_back("je           ."+a);
              $$->asm_code.push_back("movl	$1, %eax");
              string b = new_label();
              $$->asm_code.push_back("jmp	."+b);
              $$->asm_code.push_back("."+a+":");
              $$->asm_code.push_back("movl	$0, %eax");
              $$->asm_code.push_back("."+b+":");
              $$->asm_code.push_back("cltq");
              func_offset = func_offset + 8;
              $$->offset = func_offset;
              $$->size = 8;
              $$->asm_code.push_back("subq        $16, %rsp");
              $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");       
              $$->asm_code.push_back("movl	$0, %eax");   
        } 
        | not_test{$$ = $1;}

not_test: NOT not_test{
              $$ = new SymNode();
              $$->type = "bool";
              $$->line = line_num;
              $$->addr = newId();
              $$->mycode = $2->mycode;
              $$->asm_code = $2->asm_code;
              $$->mycode.push_back($$->addr + " = " + " not " + $2->addr);
              $$->asm_code.push_back("cmpq        $0,-" +to_string($2->offset)+"(%rbp)");
              $$->asm_code.push_back("sete	%al");
              $$->asm_code.push_back("movzbl	%al, %eax");
              func_offset = func_offset + 8;
              $$->offset = func_offset;
              $$->size = 8;
              $$->asm_code.push_back("subq        $16, %rsp");
              $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");
              $$->asm_code.push_back("movl	$0, %eax");
        }
        | comparison{
             $$ = $1;   
        } 

comparison: comparison comp_op  expr {
                        cout<<"Iam here -11"<<endl;
                        $$ = new SymNode();
                        if($3->type == "string" && $1->type == "string"){
                                $$->type = "bool";
                        }else if($1->type == "string" || $3->type == "string"){
                                cout<<"Error: Type Mismatch.line number:"<<line_num<<endl;
                                exit(0);
                        }else{
                                if($2->value[0] == "IN" || $2->value[0]  == "NOT IN"){
                                        cout<<"Error: Type Mismatch.line number:"<<line_num<<endl;
                                        exit(0);
                                }
                                
                                $$->type = "bool";
                                
                        }
                        $$->addr=newId();
                        $$->line = line_num;
                        $$->mycode = $1->mycode;
                        $$->asm_code = $1->asm_code;
                        for(auto x : $3->mycode){
                                $$->mycode.push_back(x);
                        }

                        for(auto x : $3->asm_code){
                                $$->asm_code.push_back(x);
                        }

                        $$->mycode.push_back($$->addr + " = " + $1->addr+ $2->value[0] + $3->addr);
                        $$->asm_code.push_back("movq	-"+to_string($1->offset)+"(%rbp), %rax");
                        $$->asm_code.push_back("cmpq	-"+to_string($3->offset)+"(%rbp), %rax");
                        $$->asm_code.push_back($2->asm_code[0]);
                        $$->asm_code.push_back("movzbl	%al, %eax");
                        func_offset = func_offset + 8;
                        $$->offset = func_offset;
                        $$->size = 8;
                        $$->asm_code.push_back("subq        $16, %rsp");
                        $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");
                        $$->asm_code.push_back("movl	$0, %eax");
        }
        | expr{$$ = $1;}

comp_op: LT{ 
                $$ = $1; 
                $$->asm_code.push_back("setl	%al");
        } 
        |GT{
                $$ = $1; 
                $$->asm_code.push_back("setg	%al");
        }       
        |DEQ{ 
                $$ = $1;
                $$->asm_code.push_back("sete	%al");
        }       
        |GTE{
                $$ = $1; 
                $$->asm_code.push_back("setge	%al");
        } 
        |LTE{
                $$ = $1; 
                $$->asm_code.push_back("setle	%al");
        } 
        |NEQ{
                $$ = $1;
                $$->asm_code.push_back("setne	%al");
                
        } 
        |IN{
                $$ = $1; 
        } 
        |NOT IN{
                $$ = new SymNode();
                $$->line = line_num;
                $$->value.push_back("NOT IN");
       } 
       | IS {
                $$ = $1;
       } 
       |IS NOT {
                $$ = new SymNode();
                $$->line = line_num;
                $$->value.push_back("NOT IN");
        }

expr: expr OR xor_expr {
        cout<<"Iam here -13"<<endl;
        $$ = new SymNode();
        if(($3->type == "int" || $3->type == "bool") && ($1->type == "int" || $1->type == "bool")){
            $$->type = "int";
            $$->type = "int";
        } else{
                cout<<"Error: Type Mismatch.Line number:"<<line_num<<endl;
                exit(0);
        }
        $$->addr=newId();
        $$->line = line_num;
        $$->mycode = $1->mycode;
        $$->asm_code = $1->asm_code;
        for(auto x : $3->mycode){
                $$->mycode.push_back(x);
                
        }
        for(auto x : $3->asm_code){
                $$->asm_code.push_back(x);     
        }

        $$->mycode.push_back($$->addr + " = " + $1->addr+ $2->value[0] + $3->addr);
        $$->asm_code.push_back("movq	-"+to_string($1->offset)+"(%rbp), %rax");
        $$->asm_code.push_back("orq	-"+to_string($3->offset)+"(%rbp), %rax");
        func_offset = func_offset + 8;
        $$->offset = func_offset;
        $$->size = 8;
        $$->asm_code.push_back("subq        $16, %rsp");
        $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");
    } 
    | xor_expr {
        $$ = $1;
    }
    

xor_expr: xor_expr CAP and_expr {
                cout<<"Iam here -16"<<endl;
                $$=new SymNode();
                if(($3->type == "int" || $3->type == "bool") && ($1->type == "int" || $1->type == "bool")){
                        $$->type = "int";
                        $$->type = "int";
                } else{
                        cout<<"Error: Type Mismatch.Line number:"<<line_num<<endl;
                        exit(0);
                }
                $$->addr=newId();
                $$->line = line_num;
                $$->mycode = $1->mycode;
                $$->asm_code = $1->asm_code;
                for(auto x : $3->mycode){
                        $$->mycode.push_back(x);
                }
                for(auto x : $3->asm_code){
                        $$->asm_code.push_back(x);
                }

                $$->mycode.push_back($$->addr + " = " + $1->addr+ $2->value[0] + $3->addr);
                $$->mycode.push_back($$->addr + " = " + $1->addr+ $2->value[0] + $3->addr);
                $$->asm_code.push_back("movq	-"+to_string($1->offset)+"(%rbp), %rax");
                $$->asm_code.push_back("xorq	-"+to_string($3->offset)+"(%rbp), %rax");
                func_offset = func_offset + 8;
                $$->offset = func_offset;
                $$->size = 8;
                $$->asm_code.push_back("subq        $16, %rsp");
                $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");

        } 
        | and_expr{
                $$ = $1;
        }
       

and_expr: and_expr AND shift_expr{
                cout<<"Iam here -19"<<endl;
                $$ = new SymNode();
                if(($3->type == "int" || $3->type == "bool") && ($1->type == "int" || $1->type == "bool")){
                        $$->type = "int";
                } else{
                        cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                        exit(0);
                }
                $$->addr=newId();
                $$->line = line_num;
                $$->mycode = $1->mycode;
                for(auto x : $3->mycode){
                        $$->mycode.push_back(x);
                }
                for(auto x : $3->asm_code){
                        $$->asm_code.push_back(x);
                }
                $$->mycode.push_back($$->addr + " = " + $1->addr+ $2->value[0] + $3->addr);
                $$->mycode.push_back($$->addr + " = " + $1->addr+ $2->value[0] + $3->addr);
                $$->asm_code.push_back("movq	-"+to_string($1->offset)+"(%rbp), %rax");
                $$->asm_code.push_back("andq	-"+to_string($3->offset)+"(%rbp), %rax");
                func_offset = func_offset + 8;
                $$->offset = func_offset;
                $$->size = 8;
                $$->asm_code.push_back("subq        $16, %rsp");
                $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");
        } 
        | shift_expr{
                $$ = $1;
        }
        

shift_expr: shift_expr lsrs_arith_expr arith_expr {
                cout<<"Iam here -22"<<endl;
                $$=new SymNode();
                if(($1->type == "int" || $1->type == "bool") && ($3->type == "int" || $3->type == "bool")){
                        $$->type = "int"; 
                } else {
                        cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                        exit(0);
                }
                $$->addr=newId();
                $$->line = line_num;
                $$->mycode = $1->mycode;
                $$->asm_code = $1->asm_code;
                for(auto x : $3->mycode){
                        $$->mycode.push_back(x);
                        
                }
                for(auto x : $3->asm_code){
                        $$->asm_code.push_back(x);
                }
                $$->mycode.push_back($$->addr + " = " + $1->addr+ $2->value[0] + $3->addr);
                $$->asm_code.push_back("movq	-"+to_string($1->offset)+"(%rbp), %rax");
                $$->asm_code.push_back("movl	%eax, %edx");
                $$->asm_code.push_back("movq	-"+to_string($3->offset)+"(%rbp), %rax");
                $$->asm_code.push_back("movl	%edx, %ecx");
                $$->asm_code.push_back($3->asm_code[0]);
                func_offset = func_offset + 8;
                $$->offset = func_offset;
                $$->size = 8;
                $$->asm_code.push_back("subq        $16, %rsp");
                $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");

          }
          | arith_expr{
                $$ = $1;
          }
          
lsrs_arith_expr: LS {
                        $$ = $1;
                        $$->asm_code.push_back("salq	%cl, %rax");
                }
                | RS {
                        $$ = $1;
                        $$->asm_code.push_back("sarq	%cl, %rax");

                }        

arith_expr: term{$$=$1;} 
        | arith_expr plus_minus term{
                cout<<"Iam here ytgghgff 3"<<endl;
                cout<<"Iam here yhjnbvfrtyuj 3"<<endl;
                $$ = new SymNode();
                cout<<"Iam here 3"<<endl;
                print_symnode($1);
                print_symnode($3);
                if(($1->type == "int" || $1->type == "float" || $1->type == "bool" )&&($3->type == "int" || $3->type == "float" || $3->type == "bool")){
                        cout<<"Iam here 3"<<endl;
                        if($1->type == "float" || $3->type == "float"){
                                $$->type = "float";
                                
                        }else{
                                $$->type = "int";     
                        }
                }else{
                        cout<<"Iam here 3"<<endl;
                        cout<<"Error: Type Mismatch.Line number:"<<line_num<<endl;
                        exit(0);
                }
                cout<<"Iam here 3"<<endl;
                $$->addr=newId();
                cout<<"Iam here 3"<<endl;
                $$->mycode = $1->mycode;
                cout<<"Iam here 3"<<endl;
                $$->asm_code = $1->asm_code;
                cout<<"Iam here 3"<<endl;
                $$->line = line_num;
                for(auto x : $3->mycode){
                        $$->mycode.push_back(x);
                        
                }
                for(auto x : $3->asm_code){
                        $$->asm_code.push_back(x);
                }

                cout<<"Iam here 3-1"<<endl;
                $$->mycode.push_back($$->addr + " = " + $1->addr+ $2->value[0] + $3->addr);
                $$->asm_code.push_back("movq	-"+to_string($1->offset)+"(%rbp), %r8");
                $$->asm_code.push_back("movq	-"+to_string($3->offset)+"(%rbp), %r9");
                $$->asm_code.push_back($2->asm_code[0]);
                cout<<"Iam here 3"<<endl;
                func_offset = func_offset + 8;
                $$->offset = func_offset;
                $$->size = 8;
                $$->asm_code.push_back("subq        $16, %rsp");
                $$->asm_code.push_back("movq	%r8, -"+to_string(func_offset)+"(%rbp)");
                cout<<"Iam here 3-1"<<endl;
        }
plus_minus : PLUS{ 
                $$ = $1; 
                $$->asm_code.push_back("addq	%r9, %r8");
        } 
        | MINUS{ 
                $$ = $1; 
                $$->asm_code.push_back("subq	%r9, %r8");
        }
                  
                
term: factor{$$=$1;} 
    | term OP factor{
        cout<<"Iam here 8"<<endl;
        if($1->type == "string" || $1->type[0] == 'l'){
                cout<<"Type Mismatch. Line number:"<<line_num<<endl;
                exit(0);
        }
        if($3->type == "string" || $3->type[0] == 'l'){
                cout<<"Type Mismatch. Line number:"<<line_num<<endl;
                exit(0);
        }
        $$ = new SymNode();
        if($1->type == "float" || $3->type == "float"){
                $$->type = "float";
        }else{
                $$->type = "int";
        }
        $$->addr=newId();
        $$->mycode = $1->mycode;
        $$->asm_code = $1->asm_code;
        $$->line = line_num;
        for(auto x : $3->mycode){
                $$->mycode.push_back(x);
                
        }
        for(auto x : $3->asm_code){
                $$->asm_code.push_back(x);
        }
        $$->mycode.push_back($$->addr + " = " + $1->addr + $2->value[0] + $3->addr);
        $$->asm_code.push_back("movq	-"+to_string($1->offset)+"(%rbp), %rax");
        if($2->Var_name == "DIVIDE" || $2->Var_name == "FLOORDIVIDE"){
                $$->asm_code.push_back("cqto");
                $$->asm_code.push_back("idivq	-"+to_string($3->offset)+"(%rbp)");
        }else if($2->Var_name == "PERCENT"){
                $$->asm_code.push_back("cqto");
                $$->asm_code.push_back("idivq	-"+to_string($3->offset)+"(%rbp)");
                $$->asm_code.push_back("movq	%rdx, %rax");
        }else{
                $$->asm_code.push_back("imulq	-"+to_string($3->offset)+"(%rbp)");
        }

        func_offset = func_offset + 8;
        $$->offset = func_offset;
        $$->size = 8;
        $$->asm_code.push_back("subq        $16, %rsp");
        $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");

    }

OP: MULTIPLY{
        $$ = $1;
        $$->Var_name = "MULTIPLY";
 }
  | DIVIDE{
        $$ = $1;
        $$->Var_name = "DIVIDE";
  }
  | PERCENT{
        $$ = $1;
        $$->Var_name = "PERCENT";
  }
  | FLOORDIVIDE{
        $$ = $1;
        $$->Var_name = "FLOORDIVIDE";
  }


factor: power{
                $$ = $1;
        } 
        | PLUS factor{
                cout<<"Iam here 17"<<endl;
                if($2->type == "int" || $2->type == "float" || $2->type == "bool"){
                        $$ = new SymNode();
                        $$->type = $2->type;
                        if($$->type == "bool") $$->type = "int";
                }else{
                        cout<<"Error: Type Mismatch .Line number:"<<line_num<<endl;
                        exit(0);
                }
                $$->addr = newId();
                $$->line = line_num;
                $$->mycode = $2->mycode;
                $$->asm_code = $2->asm_code;
                $$->mycode.push_back($$->addr + " = " + $1->addr);
                
        } 
        | MINUS factor{
                cout<<"Iam here 18"<<endl;
                if($2->type == "int" || $2->type == "float" || $2->type == "bool"){
                        $$ = new SymNode();
                        $$->type = $2->type;
                        if($$->type == "bool") $$->type = "int";
                }else{
                        cout<<"Error: Type Mismatch.Line number:"<<line_num<<endl;
                        exit(0);
                }
                $$->addr = newId();
                $$->line = line_num;
                $$->mycode = $2->mycode;
                $$->asm_code = $2->asm_code;
                $$->mycode.push_back($$->addr + " = " + " - "+$1->addr);
                $$->asm_code.push_back("movq	-"+to_string($2->offset)+"(%rbp), %rax");
                $$->asm_code.push_back("negq	%rax");
                func_offset = func_offset + 8;
                $$->offset = func_offset;
                $$->size = 8;
                $$->asm_code.push_back("subq        $16, %rsp");
                $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");
                
        } 
        | TILDE factor{
                cout<<"Iam here 19"<<endl;
                if($2->type == "int" || $2->type == "bool"){
                        $$ = new SymNode();
                        $$->type = "int";
                }else{
                        cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                        exit(0);
                }
                $$->addr = newId();
                $$->line = line_num;
                $$->mycode = $2->mycode;
                $$->asm_code = $2->asm_code;
                $$->mycode.push_back($$->addr + " = " + " ~ "+$1->addr);
                $$->asm_code.push_back("movq	-"+to_string($2->offset)+"(%rbp), %rax");
                $$->asm_code.push_back("notq	%rax");
                func_offset = func_offset + 8;
                $$->offset = func_offset;
                $$->size = 8;
                $$->asm_code.push_back("subq        $16, %rsp");
                $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");

        }

                        
power:  atom_expr POWER factor{
                cout<<"Iam here 20"<<endl;
                if(($3->type == "int" || $3->type == "float" || $3->type == "bool")&&($1->type == "int" || $1->type == "float" || $1->type == "bool")){
                        $$ = new SymNode();
                        if($1->type=="float" || $3->type == "float"){
                                $$->type = "float";
                        } 
                        else{
                                $$->type = "int";
                        } 
                }
                else{
                        cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                        exit(0);
                }
                $$->addr = newId();
                $$->line = line_num;
                $$->mycode = $1->mycode;
                $$->asm_code = $1->asm_code;
                for(auto x : $3->mycode){
                        $$->mycode.push_back(x);
                }

                for(auto x : $3->asm_code){
                        $$->asm_code.push_back(x);
                }

                $$->mycode.push_back($$->addr + " = " + $1->addr+ $2->value[0] + $3->addr);
                // need to implement power function here
                $$->asm_code.push_back("pxor        %xmm0, %xmm0");
                $$->asm_code.push_back("cvtsi2sdq	-"+to_string($3->offset)+"(%rbp), %xmm0");
                $$->asm_code.push_back("pxor        %xmm2, %xmm2");
                $$->asm_code.push_back("cvtsi2sdq	-"+to_string($1->offset)+"(%rbp), %xmm2");
                $$->asm_code.push_back("movq	%xmm2, %rax");
                $$->asm_code.push_back("movapd	%xmm0, %xmm1");
                $$->asm_code.push_back("movq	%rax, %xmm0");
                $$->asm_code.push_back("call	pow@PLT");
                $$->asm_code.push_back("cvttsd2siq	%xmm0, %rax");
                func_offset = func_offset + 8;
                $$->offset = func_offset;
                $$->size = 8;
                $$->asm_code.push_back("subq        $16, %rsp");
                $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");
                
        } 
        | atom_expr{
                $$ = $1; 
        }


atom_expr: LEN OB atom CB {
                $$ = new SymNode;
                $$->type = "int";
                $$->mycode = $3->mycode;
                $$->line = line_num;
                cout<<"inside len function"<<endl;


        
        }
        |IDENTIFIER OB CB{
                //here atom is function name
                cout<<"Iam here 21"<<endl;
                if($1->Var_name == "main"){
                        $$ = new SymNode();
                }else{
                        if(func.find($1->Var_name) == func.end()){
                                cout<<"Error: Function not declared . Line number:"<<line_num<<endl;
                                exit(0);
                        }

                        if(func[$1->Var_name].size() == 1){
                                $$ = new SymNode();
                                $$->type = func[$1->Var_name][0]->type;
                        }else{
                                cout<<"Error: Function parameters does not match with same size. Line number: "<<line_num<<endl;
                                exit(0);
                        }

                        $$->mycode.push_back("stackpointer +xxx");
                        $$->mycode.push_back("call "+ $1->Var_name);
                        $$->mycode.push_back("stackpointer -xxx");
                        $$->addr = newId();
                        $$->mycode.push_back($$->addr+ " = " + "popparam");

                        $$->asm_code.push_back("pushq	%rbp");
                        $$->asm_code.push_back("movq	%rsp, %rbp");

                        $$->asm_code.push_back("call	"+$1->Var_name);

                        $$->asm_code.push_back("popq	%rbp");
                        func_offset = func_offset + 8;
                        $$->offset = func_offset;
                        $$->size = 8;
                        $$->asm_code.push_back("subq        $16, %rsp");
                        $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");
                }


                
          }
         | IDENTIFIER OB testlist CB{
                // here atom is function name
                $$ = new SymNode();
                
                for(auto x : $3->tl){
                        for(auto y : x->mycode){
                                $$->mycode.push_back(y);
                        }
                }

                if($1->Var_name == "print"){
                        cout<<"Iam here 202"<<endl;
                        struct SymNode * temp = $3->tl[0];
                        $$->mycode.push_back("print "+temp->addr);
                        $$->type = "None";     
                        $$->line = line_num;
                        $$->asm_code.push_back("movq	-"+to_string(temp->offset)+"(%rbp), %rax");
                        $$->asm_code.push_back("movq	%rax, %rsi");
                        $$->asm_code.push_back("leaq        ."+print_map[current]+"(%rip), %rax");
                        $$->asm_code.push_back("movq	%rax, %rdi");
                        $$->asm_code.push_back("movl	$0, %eax");
                        $$->asm_code.push_back("call	printf@PLT");
                        // $$->asm_code.push_back("movl	$0, %eax");f
                }
                else{
                        cout<<"Iam here 22"<<endl;
                        if(func.find($1->Var_name) == func.end()){
                                cout<<"Error: Function not declared. Line number: "<<line_num<<endl;
                                exit(0);
                        }
                       
                       
                        if(func[$1->Var_name].size() - 1 != $3->tl.size()){
                                cout<<"Error: Function parameters does not match with same size. Line number: "<<line_num<<endl;
                                exit(0);
                        }

                        for(int i=0;i<$3->tl.size();i++){
                                if(func[$1->Var_name][i]->type != $3->tl[i]->type){
                                        print_symnode($3->tl[i]);
                                        print_symnode(func[$1->Var_name][i]);
                                        cout<<"Error: Function parameters does not match. Line number: "<<line_num<<endl;
                                        exit(0);
                                }else{
                                        $$->mycode.push_back(  "param "+ $3->tl[i]->addr);
                                }
                        }

                        $$->mycode.push_back("stackpointer +xxx");
                        $$->mycode.push_back("call "+ $1->Var_name + ", " + to_string($3->tl.size()));
                        $$->mycode.push_back("stackpointer -xxx");
                        $$->type = func[$1->Var_name].back()->type;
                        $$->line = line_num;
                        $$->addr  =newId();
                        $$->mycode.push_back($$->addr+ " = " + "popparam");

                        $$->asm_code.push_back("pushq	%rbp");
                        $$->asm_code.push_back("movq	%rsp, %rbp");

                        for(int i=0;i<$3->asm_code.size();i++){
                                $$->asm_code.push_back($3->asm_code[i]);
                        }

                        $$->asm_code.push_back("call	"+$1->Var_name);

                        $$->asm_code.push_back("popq	%rbp");
                        func_offset = func_offset + 8;
                        $$->offset = func_offset;
                        $$->size = 8;
                        $$->asm_code.push_back("subq        $16, %rsp");
                        $$->asm_code.push_back("movq	%rax, -"+to_string(func_offset)+"(%rbp)");
                }


                
         }
         | IDENTIFIER STOP IDENTIFIER{
                // here atom is class name
                cout<<"Iam here 203"<<endl;
                string a = $1->Var_name;
                struct SymNode * obj = NULL;
                if(class_pres == 1){
                        obj = class_map[current_class][current][a];
                        if(obj == NULL){
                                obj = class_map[current_class]["global"][a];
                        }
                        if(obj == NULL){
                                obj = mp[current][a];
                        }

                        if(obj == NULL){
                                cout<<"Error: Object not declared.line number:"<<line_num<<endl;
                        }
                }else{
                        obj = mp[current][a];
                        if(obj == NULL){
                                obj = mp["global"][a];
                        }
                        if(obj == NULL){
                                cout<<"Error: Object not declared.line number:"<<line_num<<endl;
                        }
                }

                string classname = obj->type;
                if(class_map.find(classname) == class_map.end()){
                        cout<<"Error: Class not declared.line number : "<<line_num<<endl;
                        exit(0);
                }

                if(class_map[classname]["global"][a] == NULL){
                        cout<<"Error: attribute not declared in class .line number:"<<line_num<<endl;
                        exit(0);
                }else{
                        // $$ = class_map[classname]["global"][a]
                        // $$->line = line_num;
                        $$ = new SymNode();
                        $$->type = class_map[classname]["global"][a]->type;
                        $$->line = line_num;
                }

         }
         | IDENTIFIER STOP IDENTIFIER OB CB{
                // here atom is class name // normal class function call
                cout<<"Iam here 24"<<endl;
                string a = $1->Var_name;
                struct SymNode * obj = NULL;
                if(class_pres == 1){
                        obj = class_map[current_class][current][a];
                        if(obj == NULL){
                                obj = class_map[current_class]["global"][a];
                        }
                        if(obj == NULL){
                                obj = mp[current][a];
                        }

                        if(obj == NULL){
                                cout<<"Error: Object not declared.line number:"<<line_num<<endl;
                        }
                }else{
                        obj = mp[current][a];
                        if(obj == NULL){
                                obj = mp["global"][a];
                        }
                        if(obj == NULL){
                                cout<<"Error: Object not declared.line number:"<<line_num<<endl;
                        }
                }

                string classname = obj->type;
                if(class_map.find(classname) == class_map.end()){
                        cout<<"Error: Class not declared.line number : "<<line_num<<endl;
                        exit(0);
                }

                if(class_func[classname].find($3->Var_name) == class_func[classname].end()){
                        cout<<"Error: Function not declared in class.line number:"<<line_num<<endl;
                        exit(0);
                }else{
                        if(class_func[classname][$3->Var_name].size() !=1){
                                cout<<"Error: class - Function parameter doesnt match.line number:"<<line_num<<endl;
                                exit(0);
                        }
                        $$ = new SymNode();
                        $$->type = class_func[classname][$3->Var_name].back()->type;
                        $$->line = line_num;
                }

                
         }
         | IDENTIFIER STOP IDENTIFIER OB testlist CB{
                //here atom is class name
                cout<<"Iam here 25"<<endl;
                string a = $1->Var_name;
                struct SymNode * obj = NULL;
                if(class_pres == 1){
                        obj = class_map[current_class][current][a];
                        if(obj == NULL){
                                obj = class_map[current_class]["global"][a];
                        }
                        if(obj == NULL){
                                obj = mp[current][a];
                        }

                        if(obj == NULL){
                                cout<<"Error: Object not declared.line number:"<<line_num<<endl;
                        }
                }else{
                        obj = mp[current][a];
                        if(obj == NULL){
                                obj = mp["global"][a];
                        }
                        if(obj == NULL){
                                cout<<"Error: Object not declared.line number:"<<line_num<<endl;
                        }
                }

                string classname = obj->type;

                if(class_map.find(classname) == class_map.end()){
                        cout<<"Error: Class not declared.line number : "<<line_num<<endl;
                        exit(0);
                }

                if(class_func[classname].find($3->Var_name) == class_func[classname].end()){
                        cout<<"Error: Function not declared in class.line number:"<<line_num<<endl;
                        exit(0);
                }

                if($5->tl.size() != class_func[classname][$3->Var_name].size()-1){
                        cout<<"Error: Function parameter doesnt match.line number:"<<line_num<<endl;
                        exit(0);
                }

                for(int i = 0;i<class_func[classname][$3->Var_name].size()-1;i++){
                        if(class_func[classname][$3->Var_name][i]->type != $5->tl[i]->type){
                                cout<<"Error: Type Mismatch. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }

                $$ = new SymNode();
                $$->type = class_func[classname][$3->Var_name].back()->type;
                $$->line = line_num;

         }
         | atom {  

                $$=$1;
                cout<<"Iam here 26 "<<endl;
                if($1->id == "identifier") {
                        // check($1);
                        string a = $1->Var_name;

                        if(class_pres==1)$1=class_map[current_class][current][a];
                        else $1 = mp[current][a];

                        if($1 == NULL){
                                if(class_pres == 0){
                                        $1 = mp["global"][a];
                                }else{
                                        $1 = class_map[current_class]["global"][a];
                                        if($1 == NULL){
                                                $1 = mp["global"][a];
                                        }
                                }
                                
                                if($1 == NULL){
                                        cout<<"Error: Variable not declared. Line number:"<<line_num<<endl;
                                        exit(0);
                                }
                        }
                        $$ = $1;

                }else{
                        $$ = $1;
                }
                print_symnode($$);
                $$->addr = $1->addr;
                $$->mycode = $1->mycode;


                
         }
         | atom OSB atom CSB {
                cout<<"Iam here 29"<<endl;
                if($1->id != "identifier"){
                        cout<<"Error: Invalid Assignment. Line number:"<<line_num<<endl;
                        exit(0);
                }
                string a = $1->Var_name;

                if(class_pres==1)$1=class_map[current_class][current][a];
                else $1 = mp[current][a];

                if($1 == NULL){
                        if(class_pres == 0){
                                $1 = mp["global"][a];
                        }else{
                                $1 = class_map[current_class]["global"][a];
                                if($1 == NULL){
                                        $1 = mp["global"][a];
                                }
                        }
                        
                        if($1 == NULL){
                                cout<<"Error: Variable not declared. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }
                

                if($1->type[0] != 'l'){
                        cout<<"Error: Not a list. Line number:"<<line_num<<endl;
                        exit(0);
                }

                if($3->id != "identifier"){
                        if($3->type != "int"){
                                cout<<"Index inside List is not int. Line number:"<<line_num<<endl;
                                exit(0);
                        }
                }else{
                       
                        string b = $3->Var_name;
                        if(class_pres==1)$3=class_map[current_class][current][b];
                        else $3 = mp[current][b];
                        if($3 == NULL){
                                if(class_pres == 0){
                                        $3 = mp["global"][b];
                                }else{
                                        $3 = class_map[current_class]["global"][b];
                                        if($3 == NULL){
                                                $3 = mp["global"][b];
                                        }
                                }
                                
                                if($3 == NULL){
                                        cout<<"Error: Variable not declared1. Line number:"<<line_num<<endl;
                                        exit(0);
                                }
                        }
                
                }

                $$ = new SymNode();
                $$->type = $1->type.substr(4);
                $$->addr = newId();
                $$->mycode = $1->mycode;
                for(auto x : $3->mycode){
                        $$->mycode.push_back(x);
                }
                $$->mycode.push_back($$->addr + " = " + $1->addr + "[" + $3->addr + "]");
                print_symnode($$);

         }

atom: NUMBER{
                $$ = $1;
                $$->addr = newId();
                $$->mycode.push_back($$->addr+" = "+$1->value[0]);
        } 
    | strings{
        $$ = $1;
        $$->addr = newId();
        $$->mycode.push_back($$->addr + " = " + $1->value[0]);
        
    } 
    | TRUE{
        $$ = $1;
        $$->addr = newId();
        $$->mycode.push_back($$->addr + " = " + $1->value[0]);
    } 
    | FALSE{
        $$ = $1;
        $$->addr = newId();
        $$->mycode.push_back($$->addr + " = " + $1->value[0]);
    } 
    | IDENTIFIER {
        $$ = $1;
        $$->addr = $1->Var_name;
        $$->id = "identifier";
     }
    | OSB testlist CSB {
        cout<<"Iam here 27"<<endl;
        
        string prev = $2->tl[0]->type;
        for(int i = 1;i<$2->tl.size();i++){
                if($2->tl[i]->type != prev){
                        cout<<"Error: Type Mismatch. Line number : "<<line_num<<endl;
                        exit(0);
                }
        }


        $$ = new SymNode();
        $$->type = "list" + prev;
        string t = $2->tl[0]->addr;
        for(auto x : $2->tl){
                for(auto y : x->mycode){
                        $$->mycode.push_back(y);
                }
        }

        for(int i = 1;i<$2->tl.size();i++){
                t += "," + $2->tl[i]->addr;
        }

        $$->addr = newId();
        $$->mycode.push_back($$->addr + " = " + "[" + t + "]");

    }


TYPE: INT{ $$ = $1; $$->type = "int";}
    | FLT{ $$ = $1; $$->type = "float";}
    | STR{ $$ = $1; $$->type = "string";}
    | BOOL{ $$ = $1; $$->type = "bool";}
    | NONE{ $$ = $1; $$->type = "None";}
    | IDENTIFIER{ 
        $$ = $1;
        $$->type = $$->Var_name;
        $$->id = "classobject";
     }
    | LIST OSB TYPE CSB {
        $$ = new SymNode();
        $$->type = "list" + $3->type;
    }

NUMBER: INTEGER{ 
        $$ = $1; $$->type = "int";
        func_offset = func_offset + 8;
        $$->offset = func_offset;
        $$->asm_code.push_back("subq       $16, %rsp");
        $$->asm_code.push_back("movq       $"+$1->value[0]+", -"+to_string(func_offset)+"(%rbp)");
      } 
      | FLOAT{ $$ = $1; $$->type = "float";}

strings: STRING{ 
                $$ = $1;
                $$->type = "string";
                int i = str_num.size()+1;
                str_num[i] = $$->value[0];
                $$->Var_name = "str"+to_string(i);
        }
        | strings STRING{ 
               $$ = $1;
               $$->size += $2->size;
               $$->value[0] += $2->value[0];

               for(auto x : $2->mycode){
                       $$->mycode.push_back(x);
               }
               $$->type = "string";
               int i = str_num.size()+1;
               str_num[i] = $$->value[0];
               $$->Var_name = "str"+to_string(i);
        }

testlist: testlist COMMA test{
                $$ = $1;
                $$->tl.push_back($3);
                if($3->type!="string" && $3->type[0]!='l'){
                        func_offset = func_offset + 8;
                        $$->offset = func_offset;
                        $$->size = 8;
                        $$->asm_code.push_back("subq        $16, %rsp");
                        $$->asm_code.push_back("movq        -"+to_string($3->offset)+"(%rbp),%r9");
                        $$->asm_code.push_back("movq        %r9,-"+to_string(func_offset)+"(%rbp)");
                }
                else if($3->type[0]=='l'){
                        for(int i=0;i<$3->tl.size();i++){
                                func_offset = func_offset + 8;
                                $$->offset = func_offset;
                                $$->size = 8;
                                $$->asm_code.push_back("subq        $16, %rsp");
                                $$->asm_code.push_back("movq        -"+to_string($3->tl[i]->offset)+"(%rbp),%r9");
                                $$->asm_code.push_back("movq        %r9,-"+to_string(func_offset)+"(%rbp)");
                        }
                }
                
        }
        | test{
                $$ = new SymNode();
                $$->tl.push_back($1);
                if($1->type!="string" && $1->type[0]!='l'){
                        func_offset = func_offset + 8;
                        $$->offset = func_offset;
                        $$->size = 8;
                        $$->asm_code.push_back("subq        $16, %rsp");
                        $$->asm_code.push_back("movq        -"+to_string($1->offset)+"(%rbp),%r9");
                        $$->asm_code.push_back("movq        %r9,-"+to_string(func_offset)+"(%rbp)");
                }
                else if($1->type[0]=='l'){
                        for(int i=0;i<$1->tl.size();i++){
                                func_offset = func_offset + 8;
                                $$->offset = func_offset;
                                $$->size = 8;
                                $$->asm_code.push_back("subq        $16, %rsp");
                                $$->asm_code.push_back("movq        -"+to_string($1->tl[i]->offset)+"(%rbp),%r9");
                                $$->asm_code.push_back("movq        %r9,-"+to_string(func_offset)+"(%rbp)");
                        }
                }

        }


classdef: CLASS IDENTIFIER OB IDENTIFIER CB{
                class_pres = 1;
                for(auto x : func){
                        string t = x.first;
                        if(t == $2->Var_name){
                                cout<<"Error: Class Name matches with function name. "<<"line number:"<<line_num<<endl;
                                exit(0);
                        }
                }
                for(auto x : class_map){
                        string t = x.first;
                        if(t == $2->Var_name){
                                cout<<"Error: Class Name already declared. "<<"line number:"<<line_num<<endl;
                                exit(0);
                        }       
                }
                int f = 0;
                for(auto x : class_map){
                        string t = x.first;
                        if(t == $4->Var_name){
                            f = 1;
                            break;    
                        }       
                }

                if(f == 0){
                        cout<<"Error: Class Name to Inherit Doesnt exist. "<<"line number:"<<line_num<<endl;
                        exit(0);
                }

                // you need to add elements of inherited class to the class_map
                for(auto x : class_map[$4->Var_name]){
                        auto it = x.second;
                        class_map[$2->Var_name][x.first] = it;
                }

                for(auto x : class_func[$4->Var_name]){
                        auto it = x.second;
                        class_func[$2->Var_name][x.first] = it;
                }
                current_class = $2->Var_name;


        } COLON suite{
                class_pres = 0;
                $$ = $8;

        }
        | CLASS IDENTIFIER OB CB{
                class_pres = 1;
                for(auto x : func){
                        string t = x.first;
                        if(t == $2->Var_name){
                                cout<<"Error: Class Name matches with function name. "<<"line number:"<<line_num<<endl;
                                exit(0);
                        }
                }
                for(auto x : class_map){
                        string t = x.first;
                        if(t == $2->Var_name){
                                cout<<"Error: Class Name already declared. "<<"line number:"<<line_num<<endl;
                                exit(0);
                        }       
                }

                current_class = $2->Var_name;
        } COLON suite{
                $$ = $7;
                class_pres = 0;
        }
        | CLASS IDENTIFIER{
                class_pres = 1;
                for(auto x : func){
                        string t = x.first;
                        if(t == $2->Var_name){
                                cout<<"Error: Class Name matches with function name. "<<"line number:"<<line_num<<endl;
                                exit(0);
                        }
                }
                for(auto x : class_map){
                        string t = x.first;
                        if(t == $2->Var_name){
                                cout<<"Error: Class Name already declared. "<<"line number:"<<line_num<<endl;
                                exit(0);
                        }       
                }

                current_class = $2->Var_name;
        } COLON suite{
                $$ = $4;
                class_pres = 0;
        }

////need to think and also need to check
//suite param,identifer,testlist role - what checkings should be done, declerations of variables and functions inside class
//role of global variables
//class objects creation???!!!

%%

void yyerror(const char *s){ 
    
    cout<<"Syntax Error"<<endl;
}


int main(int argc, char *argv[]) {

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return EXIT_FAILURE;
    }

//     mp["main"];

    yyin = fopen(argv[1], "r");
    source_file = argv[1];

    if (!yyin) {
        perror("Error opening input file");
        return EXIT_FAILURE;
    }
    
    st.push(0);
    struct SymNode * temp = new SymNode();
    temp->type = "None";
    func["print"].push_back(temp);
    func["range"].push_back(temp);
    temp->type = "int";

    cout<<"Parsing Started"<<endl;

    yyparse();
    cout<<"Parsing Done"<<endl;
    fclose(yyin);

    cout<<"Printing Symbol Table"<<endl;

    cout<<final.size()<<endl;

    ofstream outfile ("test.txt");
    for(auto line:final){
        outfile<<line<<endl;
    }
    outfile.close();

    cout<<"Printing Assembly Code"<<endl;

    ofstream outfile1 ("asm.s");
    for(auto line:asm_res){
        outfile1<<line<<endl;
    }
    outfile1.close();

//     string filer = "f";
    

    for(auto x : class_map){
        // if(x.second.size() == 0) continue;
        for(auto y : x.second){
            if(y.second.size()!=0){
                string temp = x.first + "-"+ y.first + ".csv";
                ofstream outfile(temp);
                outfile<<"TOKEN,"<<"LEXEME,"<<"TYPE,"<<"LINE NUMBER"<<endl;
                for(auto z : y.second){
                        // cout<<typeid(z.second).name()<<endl;
                        if(z.second!=NULL)outfile<<"Variable,"<<z.second->Var_name<<","<<z.second->type<<","<<z.second->line<<endl;
                }
            }
        }
    }
    
    for(auto x : mp){
        if(x.second.size()!=0){
                string temp = x.first + ".csv";
                ofstream outfile(temp);
                outfile<<"TOKEN,"<<"LEXEME,"<<"TYPE,"<<"LINE NUMBER"<<endl;
                for(auto y : x.second){
                        if(y.second!=NULL)outfile<<"Variable,"<<y.second->Var_name<<","<<y.second->type<<","<<y.second->line<<endl;
                }
        }
    }

    



    return 0;
}

///type casting