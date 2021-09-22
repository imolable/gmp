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
#define G_STACK_SIZE (1024 * 8)

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

extern void* schedule();
extern void sys_write_call(char*, int) asm("sys_write_call");
extern void cr_call(Gobuf*, Fn) asm("cr_call");
extern void cr_switch(Gobuf*) asm("cr_switch");
extern void put_g(P* p, G* g);
extern P* get_idle_p();
extern void new_m(P*);
extern void* gexit();

typedef enum GStatus {
	Grunnable,
	Grunning,
	Gdead,
} GStatus;

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
	GStatus gs;
};

struct P {
	GQueue runq;

	P* next;

	pthread_mutex_t mutex;
	pthread_cond_t nonEmpty;
};

struct M {
	G* g0;
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

// current running m
__thread M* m;
// current running g
__thread G* g;

M m0;
G g0;

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
	g->gobuf.pc = gexit;
	g->gs = Grunnable;

	put_g(m->p, g);
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

void put_g(P* p, G* g)
{

	if (p->runq.gsize < G_SIZE_PER_P) {
		enqueue(&p->runq, g);
		return;
	}

	pthread_mutex_lock(&sched.mutex);

	enqueue(&sched.global_q, g);

	pthread_cond_signal(&sched.nonEmpty);
	pthread_mutex_unlock(&sched.mutex);

	P* idle_p = get_idle_p();
	if (idle_p != NULL) {
		new_m(idle_p);
	}
}

void* gexit()
{
	g->gs = Gdead;
	free(g);

	printf("--- g dead --- \n");
	schedule();

	return NULL;
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

void start_m(M* mm)
{
	m = mm;

	schedule();
}

void run_m()
{

	if (g != m->g0) {
		printf("bad run\n");
		exit(-1);
	}

	schedule();
}

int clone_start(M* mm)
{
	m = mm;
	g = mm->g0;

	run_m();

	return 0;
}

void new_m(P* p)
{

	M* mm = (M*)malloc(sizeof(M));
	mm->p = p;

	int thread_stack_size = 1024;
	G* g0 = malloc_g(thread_stack_size);

	mm->g0 = g0;

	pthread_attr_t attr;
	pthread_attr_init(&attr);
	pthread_attr_setstack(&attr, g0->stack_base, thread_stack_size);

	pthread_t t;
	int r = pthread_create(&t, &attr, (void*)clone_start, mm);
	if (r != 0) {
		printf("pthread create failed, r: %d\n", r);
		exit(-1);
	}
}

void init_sched()
{
	m->p = new_p();

	for (int i = 1; i < P_SIZE; i++) {

		P* mp = new_p();
		mp->next = sched.idle_p;
		sched.idle_p = mp;
	}

	pthread_mutex_init(&sched.mutex, NULL);
	pthread_cond_init(&sched.nonEmpty, NULL);
}

void* schedule()
{
	P* p = m->p;

	if (g != NULL && g->gs == Grunning) {
		g->gs = Grunnable;
		put_g(p, g);
	}

	G* rg = get_g(p);
	if (rg == NULL) {
		printf(" --- g is null, sleep \n");
		return NULL;
	}
	rg->gs = Grunning;
	g = rg;

	if (g->gobuf.pc == gexit) {
		cr_call(&g->gobuf, g->f);
	}

	cr_switch(&g->gobuf);

	return NULL;
}

int _main()
{

	printf("main start! \n");

	CR(print_a);
	CR(print_b);
	CR(print_c);
	CR(print_d);

	printf("main done! \n");
	return 0;
}

void print_a()
{
	for (int i = 0; i < N; i++) {
		char src[10];
		sprintf(src, "AA_%d\n", i);
		sys_write_call(src, strlen(src));
	}
}

void print_b()
{
	for (int i = 0; i < 2 * N; i++) {
		char src[10];
		sprintf(src, "BBB_%d\n", i);
		sys_write_call(src, strlen(src));
	}
}

void print_c()
{
	for (int i = 0; i < N * 3 / 2; i++) {
		char src[10];
		sprintf(src, "CCCC_%d\n", i);
		sys_write_call(src, strlen(src));
	}
}

void print_d()
{
	for (int i = 0; i < N / 3; i++) {
		printf("DDDDD_%d\n", i);
	}
}
