hello: hello.s
	as -arch arm64 -o hello.o hello.s

	ld -o hello hello.o
run: hello
	./hello

clean:
	rm -rf hello.o hello
