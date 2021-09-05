#include <stdio.h>

extern int call_asm(void*);

typedef void (*F)();

void print_hello()
{
	printf("print hello \n");
}

int print_int(int a)
{
	printf("print int: %d\n", a);

	return -100;
}

void print_add(int a, int b)
{

	int c = a + b;

	printf("print add: %d\n", c);
}

int sub(int a, int b)
{

	int c = 100;

	int d = a - b;

	return c + d;
}

void call(void* v)
{
	F f = (F)v;
	f();
}

int main()
{

	int r = call_asm(print_hello);

	//r = 9;
	printf("--- --- %d \n", r);

	//call(print_hello);
}
