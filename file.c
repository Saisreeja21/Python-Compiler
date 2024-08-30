#include<stdio.h>

long long sum(long long a, long long b){
    long long c = a + b;
    return c;
}



int main(){
    long long a = 1;
    long long b = 3;
    long long c = sum(a,b);
    printf("%lld\n",c);
    
}