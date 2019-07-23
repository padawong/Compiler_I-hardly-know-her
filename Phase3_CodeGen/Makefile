parse: mini_l.lex mini_l.y
	bison -v -d --file-prefix=y mini_l.y
	flex mini_l.lex
	g++ -std=c++11 -g -o parser y.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c y.tab.* y.output *.o parser
output:
	sudo rsub output1.txt
	sudo rsub output2.txt
	sudo rsub output3.txt
testfiles:
	sudo rsub test1.txt
	sudo rsub test2.txt
	sudo rsub test3.txt
