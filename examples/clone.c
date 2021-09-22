#define _GNU_SOURCE

#include <pthread.h>
#include <sched.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

int pt(void* nop)
{

	int a[1024] = {};

	//sleep(1);
	int pid = getpid();
	int tid = gettid();
	printf("hello ccccc: %d, %d\n", pid, tid);
	//	printf("hello world : %d, %d\n", getpid(), getppid());
	//	pthread_t t = pthread_self();
	//	printf("hello world: %d\n", (int)t);
	return 0;
}

int main()
{
	int size = 1024 * 8;

	int pid = getpid();

	printf("hello pid:%d, %d\n", pid, gettid());

	void* stack = malloc(size);
	int flags = CLONE_VM /* share memory */
						 //		| CLONE_FS		 /* share cwd, etc */
						 //		| CLONE_FILES	 /* share fd table */
		| CLONE_SIGHAND	 /* share sig handler table */
		| CLONE_THREAD;

	pid = clone(pt, size + stack, flags, NULL);

	printf("clone pid:%d \n", pid);

	sleep(1);
	return 0;
}
