#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int bb;
int aa = 22;
int cc = 33;

int* ap;

int* (*fn)();

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

// void *consume(void * nop)
// {
//     printf("hello consume:%d\n", bb);
//     return NULL;
// }

void print_hello()
{
	printf("hello world:%d\n", bb);
}
