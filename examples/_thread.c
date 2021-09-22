#include <pthread.h>
#include <sched.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef struct M {

	int a;
	int b;
	int c;
} M;

__thread M* pm;

void* routine()
{

	M n;
	n.a = 3;
	n.b = 4;
	n.c = 5;
	pm = &n;
	printf("--- m.a %d, %d, %d \n", pm->a, pm->b, pm->c);
}

int main()
{

	M n;
	n.a = 1;
	n.b = 10;
	n.c = 100;
	pm = &n;
	printf("m.a %d, %d, %d \n", pm->a, pm->b, pm->c);

	sleep(1);

	pthread_t t;
	pthread_create(&t, NULL, routine, NULL);

	sleep(1);
	printf("m.a %d, %d, %d \n", pm->a, pm->b, pm->c);
	return 0;
}
