hello: hello.s
	@echo "\033[32m✓ building: ./hello \033[0m"
	@as -arch arm64 -o hello.o hello.s

	@ld -o hello hello.o
run: hello
	./hello

clean:
	@echo "\033[32m✓ cleaning: \033[0m"
	@git clean -fdx > /dev/null

test: clean hello
	@./hello > actual.txt && \
	diff actual.txt expected.txt && \
	echo "\033[32m✓ Test Success\033[0m" || \
	echo "\033[31m✗ Test Fail\033[0m"
