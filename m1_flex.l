
%{
//follow kardhe mereko
#include <bits/stdc++.h>
#include "m2.tab.h"
#include "AstNode.cpp"
using namespace std;
stack<long long> st;
queue<long long> tokens;

extern "C" int yywrap() {
    // Indicate that there is no more input to scan
    return 1;
}

long long dedent_count = 0;
long long indent_count = 0;

int flag = 0;

long long ids = 0;
long long line_num = 1;

int func_flag = 0;


%}

digit [0-9]
nonzero_digit [1-9]
binary_digit [01]
octdigit [0-7]
hexdigit [0-9a-fA-F]
letter [a-zA-Z]

integer ("0"("x"|"X")([_]?{hexdigit})+|"0"("o"|"O")([_]?{octdigit})+|"0"("b"|"B")([_]?{binary_digit})+|"0"+([_]?{digit})*|{nonzero_digit}([_]?{digit})*)

digitpart {digit}(["_"]?{digit})*
fraction "."{digitpart}
pointfloat {digitpart}?{fraction}|{digitpart}"."
exponent ("e"|"E")[+\-]?{digitpart}
exponentfloat ({digitpart}|{pointfloat}){exponent}
floatnumber {pointfloat}|{exponentfloat}
 
identifier [A-Za-z_][A-Za-z_0-9]*

stringprefix    (r|u|R|U|f|F|fr|Fr|fR|FR|rf|rF|Rf|RF)
shortstringitem1   ([^\\^\n^\"]|\\.)
shortstringitem2   ([^\\^\n^\']|\\.)
longstringitem    ([^\\]|\\.) 
shortstring    (\'{shortstringitem2}*\'|\"{shortstringitem1}*\")
longstring    (\'\'\'{longstringitem}*\'\'\'|\"\"\"{longstringitem}*\"\"\")
stringliteral    ({stringprefix}{shortstring}|{shortstring}|{stringprefix}{longstring}|{longstring})



Arithmeticoperator  ("+"|"-"|"*"|"/"|"//"|"**"|"%")
Relationaloperator  ("<"|">"|"=="|">="|"<="|"!=")
logicaloperator  ("and"|"or"|"not")
bitwiseoperator ("&"|"|"|"^"|"~"|"<<"|">>")
assignmentoperator ("="|"+="|"-="|"*="|"/="|"%="|"**="|"&="|"|="|"^="|">>="|"<<=")

operator ({Arithmeticoperator}|{Relationaloperator}|{logicaloperator}|{bitwiseoperator}|{assignmentoperator})

%x state1
%s state2

%%

<<EOF>> {
    if(flag == 1){
        cout<<"Exiting"<<endl;
        return 0;
    }
    cout<<"EOF\n";
    
    flag++;

    unput('\n');
    BEGIN(state1);
    // printf("NEWLINE\n");
    // return NEWLINE;

}

^[ \t\r\f\v]*"#".*\n {
    printf("Blank comment\n");
    line_num++;
    BEGIN(INITIAL);
}

^[ \t\r\f\v]*\n {
    printf("Blank line\n");
    line_num++;
    BEGIN(INITIAL);
}

"#".*\n {
    BEGIN(INITIAL);
    line_num++;
    return NEWLINE;
}


<state1>. {

    string temp = yytext;
    if(dedent_count > 0){
        
        unput(temp.back());
        dedent_count--;
        indent_count--;
        printf("Dedent\n");
        return DEDENT;

    }else{
        
        BEGIN(state2);
        unput(temp.back());

    }

}

<state1>[\n] {

    if(indent_count > 0){
        indent_count--;
        unput('\n');
        printf("Dedent\n");

        return DEDENT;
    }
    else{
        BEGIN(INITIAL);
        printf("ENDMARK: \n");

        return ENDMARKER;
    }
}

<INITIAL>^[ \t\f\r\v]*. {

    string temp = yytext;
    // if(temp.back() == 'd') cout<<"Iam here\n";
    // cout<<"Iam here"<<endl;

    if(temp.back() == '#'){
        unput(temp.back());
        BEGIN(state2);
    }
    else{
        int x = temp.back();
        cout<<x<<endl;
        long long num = temp.length() - 1;

        if(st.top() != num){
            if(st.top() < num){
                st.push(num);
                printf("Indent\n");
                indent_count++;
                unput(temp.back());
                BEGIN(state2);
                return INDENT;

            }else{ 
                BEGIN(state1);

                while(st.top() > num){
                    dedent_count++;
                    st.pop();
                }
                if(st.top() != num) return ERROR;

                // for(long long i = temp.length() -1; i >= 0; i--){
                //     unput(temp[i]);
                // }

                unput(temp.back());

                // flag = 1;
                // printf("Dedent\n");
                // return DEDENT;
            }
        }else{

            cout<<"Equal - no indent"<<endl;
            unput(temp.back());
            BEGIN(state2);

        }
    }

}


<state2>[\n] {
    printf("Newline: \n");
    line_num++;
    BEGIN(INITIAL);
    return NEWLINE; 
}

<state2>\\.*\n {
    cout<<"Line - joining"<<endl;
    line_num++;
    // BEGIN(INITIAL);
}


<state2>list {
    printf("List: %s\n", yytext);
    yylval.info = new SymNode();
    yylval.info->type = "list";
    yylval.info->line = line_num;
    yylval.info->size = 0;
    return LIST;
}

<state2>"->" {
    printf("Arrow: %s\n", yytext);
    string temp = yytext;
    return ARROW;
}

<state2>";" {
    printf("Semicolon: %s\n", yytext);
    string temp = yytext; 
    return SEMICOLON;
}

<state2>":" {
    printf("Colon: %s\n", yytext);
    string temp = yytext; 
    return COLON;
}

<state2>"," {
    printf("Comma: %s\n", yytext);
    string temp = yytext; 
    return COMMA;
}

<state2>"." {
    printf("Dot: %s\n", yytext);
    string temp = yytext; 
    return STOP;
}

<state2>if {
    printf("If: %s\n", yytext);
    string temp = yytext; 
    return IF;
}

<state2>False {
    printf("False: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->type = "bool";
    yylval.info->line = line_num;
    yylval.info->size = 1;
    (yylval.info->value).push_back("0");
    return FALSE;
}

<state2>True {
    printf("True: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->type = "bool";
    yylval.info->line = line_num;
    yylval.info->size = 1;
    (yylval.info->value).push_back("1");
    return TRUE;
}

<state2>await {
    printf("Await: %s\n", yytext);
    string temp = yytext; 
    return AWAIT;
}

<state2>else {
    printf("Else: %s\n", yytext);
    string temp = yytext; 
    return ELSE;
}

<state2>None {
    printf("None: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->type = "None";
    yylval.info->line = line_num;
    return NONE;
}

<state2>break {
    printf("Break: %s\n", yytext);
    string temp = yytext; 
    return BREAK;
}

<state2>or {
    printf("Or: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->line = line_num;
    return BOR;
}

<state2>continue {
    printf("Continue: %s\n", yytext);
    string temp = yytext; 
    return CONTINUE;
}

<state2>int {
    printf("Int: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->type = "int";
    yylval.info->line = line_num;
    yylval.info->size = 4;
    return INT;
}

<state2>float {
    printf("Float: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->type = "float";
    yylval.info->line = line_num;
    yylval.info->size = 4;
    return FLT;
}

<state2>str {
    printf("String: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->type = "string";
    yylval.info->line = line_num;
    yylval.info->size = 4;
    return STR;
}

<state2>bool {
    printf("Bool: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->type = "bool";
    yylval.info->line = line_num;
    yylval.info->size = 1;
    return BOOL;
}

<state2>in {
    printf("In: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->line = line_num;
    return IN;
}

<state2>class {
    printf("Class: %s\n", yytext);
    string temp = yytext; 
    return CLASS;
}

<state2>is {
    printf("Is: %s\n", yytext);
    string temp = yytext;
    yylval.info = new SymNode();
    yylval.info->line = line_num;
    return IS;
}

<state2>return {
    printf("Return: %s\n", yytext);
    string temp = yytext; 
    return RETURN;
}

<state2>and {
    printf("And: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->line = line_num;
    return BAND;
}

<state2>for {
    printf("For: %s\n", yytext);
    string temp = yytext; 
    return FOR;
}

<state2>while {
    printf("While: %s\n", yytext);
    string temp = yytext; 
    return WHILE;
}

<state2>def {
    func_flag = 1;
    printf("Def: %s\n", yytext);
    string temp = yytext; 
    return DEF;
}

<state2>range {
    func_flag = 1;
    printf("Range: %s\n", yytext);
    string temp = yytext; 
    return RANGE;
}

<state2>len {
    printf("LEN : %s\n", yytext);
    return LEN;
}

<state2>global {
    printf("Global: %s\n", yytext);
    string temp = yytext; 
    return GLOBAL;
}

<state2>__name__ {
    printf("__name__ : %s\n", yytext);
    string temp = yytext; 
    return __NAME__;

}

<state2>self[ ]*"," {
    printf("Self: %s\n", yytext);
    string temp = yytext; 
}

<state2>self {
    printf("Self: %s\n", yytext);
    string temp = yytext; 
}

<state2>self"." {
    printf("Self: %s\n", yytext);
    string temp = yytext; 
}



<state2>not {
    printf("Not: %s\n", yytext);
    string temp = yytext;
    yylval.info = new SymNode(); 
    yylval.info->line = line_num;
    return NOT;
}

<state2>elif {
    printf ("Elif: %s\n", yytext);
    string temp = yytext; 
    return ELIF;
}

<state2>nonlocal {
    printf("Nonlocal: %s\n", yytext);
    string temp = yytext; 
    return NONLOCAL;
}

<state2>import|pass|except|raise|finally|lambda|try|from|assert|del|with|async|yield {
    printf("Keyword: %s\n", yytext);
    string temp = yytext; 
    return KEYWORD;
}

<state2>{floatnumber} {
    printf("Float: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->type = "float";
    (yylval.info->value).push_back(temp);
    yylval.info->line = line_num;
    yylval.info->size = 4;
    return FLOAT;
}

<state2>{integer} {
    printf("Integer: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->type = "int";
    (yylval.info->value).push_back(temp);
    yylval.info->line = line_num;
    yylval.info->size = 4;
    return INTEGER;
}

<state2>"["[^\]\n]*\n[^\]]*"]" {
    string temp = yytext;
    for(int i = temp.length() - 1; i>=0 ;i--){
        if(temp[i] != '\n'){
            // cout<<temp[i]<<endl;
            unput(temp[i]);
        }else{
            line_num++;
        }
    }
}

<state2>"[" {
    printf("[\n");
    string temp = yytext; 
    return OSB;
}

<state2>"]" {
    printf("]\n");
    string temp = yytext; 
    return CSB;
}

<state2>"(" {
    printf("(\n");
    string temp = yytext; 

    return OB;
}

<state2>")" {
    printf(")\n");
    string temp = yytext; 

    return CB;
}

<state2>{stringliteral} {
    printf("String: %s\n", yytext);
    string temp = yytext;

    yylval.info = new SymNode();
    yylval.info->type = "string";
    (yylval.info->value).push_back(temp);
    yylval.info->line = line_num;
    yylval.info->size = temp.size()-2;


    for(auto x : temp){
        if(x == '\n') line_num++;
    }

    return STRING;
}

<state2>{identifier} {
    printf("Identifier: %s\n", yytext);
    string temp = yytext; 
    yylval.info = new SymNode();
    yylval.info->Var_name = temp;
    yylval.info->line = line_num;
    return IDENTIFIER;
}

<state2>{operator} {
    cout<<"Operator : "<<yytext<<endl;
    string temp = yytext;
    yylval.info = new SymNode();
    yylval.info->value.push_back(temp);
    yylval.info->line = line_num;

if (temp == "+") {
    return PLUS;
} else if (temp == "-") {
    return MINUS;
} else if (temp == "*") {
    return MULTIPLY;
} else if (temp == "/") {
    return DIVIDE;
} else if (temp == "//") {
    return FLOORDIVIDE;
} else if (temp == "**") {
    return POWER;
} else if (temp == "%") {
    return PERCENT;
} else if (temp == "<") {
    return LT;
} else if (temp == ">") {
    return GT;
} else if (temp == "==") {
    return DEQ;
} else if (temp == ">=") {
    return GTE;
} else if (temp == "<=") {
    return LTE;
} else if (temp == "!=") {
    return NEQ;
} else if (temp == "and") {
    return BAND;
} else if (temp == "or") {
    return BOR;
} else if (temp == "not") {
    return NOT;
} else if (temp == "&") {
    return AND;
} else if (temp == "|") {
    return OR;
} else if (temp == "^") {
    return CAP;
} else if (temp == "~") {
    return TILDE;
} else if (temp == "<<") {
    return LS;
} else if (temp == ">>") {
    return RS;
} else if (temp == "=") {
    return EQ;
} else if (temp == "+=") {
    
    return ASSIGNMENT_OPERATOR;
} else if (temp == "-=") {
    
    return ASSIGNMENT_OPERATOR;
} else if (temp == "*=") {
    
    return ASSIGNMENT_OPERATOR;
} else if (temp == "/=") {
    
    return ASSIGNMENT_OPERATOR;
} else if (temp == "%=") {
    
    return ASSIGNMENT_OPERATOR;
} else if (temp == "&=") {
    
    return ASSIGNMENT_OPERATOR;
} else if (temp == "|=") {
   
    return ASSIGNMENT_OPERATOR;
} else if (temp == "^=") {
   
    return ASSIGNMENT_OPERATOR;
} else if (temp == ">>=") {
  
    return ASSIGNMENT_OPERATOR;
} else if (temp == "<<=") {
  
    return ASSIGNMENT_OPERATOR;
} else if (temp == "**=") {
   
    return ASSIGNMENT_OPERATOR;
} else if (temp == "//=") {
    
    return ASSIGNMENT_OPERATOR;
}

}

<state2>[ \t\r\f\v] {

}

<state2>. {
    printf("Iam not matched - %s\n",yytext);
    int c = yytext[0];
    cout<<c<<endl;
    return ERROR;
}

%%

