test:
	flex m1_flex.l
	bison -d -v -t m2.y
	g++ -o output lex.yy.c m2.tab.c -lfl
	./output try.py > tokens.txt
	rm -f lex.yy.c m2.tab.c m2.tab.h output m2.output object_file.o

run_asm:
	gcc -c asm.s -o object_file.o
	gcc object_file.o -o milestone3
	./milestone3
	rm -f lex.yy.c m2.tab.c m2.tab.h output m2.output object_file.o

