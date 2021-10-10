#define _GNU_SOURCE

#include <errno.h>
#include <pthread.h>
#include <sched.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define N 10
#define P_SIZE 2
#define G_SIZE_PER_P 2
#define G_STACK_SIZE (1024)

#define CR(a)     \
	{             \
		new_g(a); \
	}

typedef struct G G;
typedef struct P P;
typedef struct M M;
typedef struct Gobuf Gobuf;
typedef struct Sched Sched;

typedef void (*Fn)(void);

void print_a();
void print_b();
void print_c();
void print_d();

extern void cr_call(Gobuf*, Fn) asm("cr_call");
extern void put_g(G* g);
extern P* get_idle_p();
extern void new_m(P*);

typedef struct GQueue {
	G* head;
	G* tail;
	int gsize;
} GQueue;

struct Sched {
	P* idle_p;
	GQueue global_q;

	M* m;

	pthread_mutex_t mutex;
	pthread_cond_t nonEmpty;
};

struct Gobuf {
	void* sp;
	void* pc;
};

struct G {
	void* stack_base;
	Gobuf gobuf;
	Fn f;
	G* next;
};

struct P {
	GQueue runq;

	P* next;

	pthread_mutex_t mutex;
	pthread_cond_t nonEmpty;
};

struct M {
	P* p;
};

void enqueue(GQueue* q, G* g)
{

	if (q->gsize == 0) {
		q->head = g;
		q->tail = g;
		q->gsize = 1;
	} else {
		q->tail->next = g;
		q->tail = g;
		g->next = NULL;
		q->gsize++;
	}
}

G* dequeue(GQueue* q)
{
	G* r = q->head;

	if (r != NULL) {
		q->head = r->next;
		q->gsize--;
	}

	return r;
}

Sched sched;

G* malloc_g(int stack_size)
{
	G* g = malloc(sizeof(G));

	void* mc = malloc(stack_size);
	g->stack_base = mc + stack_size;

	return g;
}

void new_g(Fn f)
{
	G* g = malloc_g(G_STACK_SIZE);

	g->f = f;
	g->gobuf.sp = g->stack_base;

	put_g(g);
}

G* get_g(P* p)
{

	G* g = dequeue(&p->runq);
	if (g != NULL) {
		return g;
	}

	pthread_mutex_lock(&sched.mutex);

	for (int i = 0; i < G_SIZE_PER_P; i++) {

		G* g = dequeue(&sched.global_q);
		while (g == NULL && i == 0) {
			pthread_cond_wait(&sched.nonEmpty, &sched.mutex);
			g = dequeue(&sched.global_q);
		}

		if (g == NULL) {
			break;
		}

		enqueue(&p->runq, g);
	}

	pthread_mutex_unlock(&sched.mutex);

	return dequeue(&p->runq);
}

void put_g(G* g)
{

	pthread_mutex_lock(&sched.mutex);

	enqueue(&sched.global_q, g);

	pthread_cond_signal(&sched.nonEmpty);
	pthread_mutex_unlock(&sched.mutex);

	P* idle_p = get_idle_p();
	if (idle_p != NULL) {
		new_m(idle_p);
	}
}

P* new_p()
{
	P* mp = (P*)malloc(sizeof(P));
	mp->runq.gsize = 0;

	pthread_mutex_init(&mp->mutex, NULL);
	pthread_cond_init(&mp->nonEmpty, NULL);

	return mp;
}

P* get_idle_p()
{
	pthread_mutex_lock(&sched.mutex);

	P* p = sched.idle_p;
	if (p != NULL) {
		sched.idle_p = p->next;
	}

	pthread_mutex_unlock(&sched.mutex);

	return p;
}

int clone_start(M* mm)
{
	P* p = mm->p;

	while (1) {
		G* g = get_g(p);
		cr_call(&g->gobuf, g->f);
	}

	return 0;
}

void new_m(P* p)
{
	M* mm = (M*)malloc(sizeof(M));
	mm->p = p;

	pthread_t t;
	int r = pthread_create(&t, NULL, (void*)clone_start, mm);
	if (r != 0) {
		printf("pthread create failed, r: %d\n", r);
		exit(-1);
	}
}

void init_sched()
{

	for (int i = 0; i < P_SIZE; i++) {

		P* mp = new_p();
		mp->next = sched.idle_p;
		sched.idle_p = mp;
	}

	pthread_mutex_init(&sched.mutex, NULL);
	pthread_cond_init(&sched.nonEmpty, NULL);
}

int main()
{
	puts("main start! \n");

	init_sched();

	CR(print_a);
	CR(print_b);
	CR(print_c);
	CR(print_d);

	sleep(2);

	puts("main end! \n");
	return 0;
}

void print_a()
{
	for (int i = 0; i < N; i++) {
		printf("AA_%d\n", i);
	}
}

void print_b()
{
	for (int i = 0; i < 2 * N; i++) {
		printf("BBB_%d\n", i);
	}
}

void print_c()
{
	for (int i = 0; i < N * 3 / 2; i++) {
		printf("CCCC_%d\n", i);
	}
}

void print_d()
{
	for (int i = 0; i < N / 3; i++) {
		printf("DDDDD_%d\n", i);
	}
}
