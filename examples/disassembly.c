#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef struct Demo {
	int a;
	void* b;
	int c;
} Demo;

int bb;
int aa = 22;
int cc = 33;

int* ap;

int* (*fn)();

Demo demo;

int* get_bb()
{
	int* a = &aa;
	int* c = &cc;

	ap = a;

	return &bb;
}

int getbb()
{
	fn = get_bb;
	return bb + aa + cc;
}

int* get_demo()
{
	return &demo.c;
}

void print_hello()
{
	printf("hello world:%d\n", bb);
}
