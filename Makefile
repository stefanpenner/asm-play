hello: hello.s
	@printf "\033[34m- building... \033[32m./hello \033[0m\n"
	@as -arch arm64 -o hello.o hello.s

	@ld -o hello hello.o
run: hello
	./hello

clean:
	@printf "\033[34m- cleaning... \033[0m\n"
	@git clean -fdx > /dev/null

test: clean hello
	@printf "\033[34m- testing... \033[0m"
	@./hello > actual.txt && \
	diff actual.txt expected.txt && \
	echo "\033[32m ✓ Success\033[0m" || \
	echo "\033[31m ✗ Fail\033[0m"
