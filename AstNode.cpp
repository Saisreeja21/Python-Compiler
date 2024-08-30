#include <iostream>
#include <vector>
#include <string>
using namespace std;

struct SymNode{
        string Var_name;
        string addr;
        string type;
        long long line;
        string source_file;
        int size;
        int offset;
        string id;
        vector<string> value;
        vector<string> mycode;
        vector<string> asm_code;
        vector<SymNode*> tl;
         
};