#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
// #include <semaphore.h>

#define N 10
#define P_SIZE 3
#define G_STACK_SIZE 1024

#define CR(a)     \
	{             \
		new_g(a); \
	}

typedef void (*Fn)(void);
typedef struct Node Node;
typedef struct Queue Queue;

typedef struct G G;
typedef struct P P;
typedef struct M M;
typedef struct Gobuf Gobuf;
typedef struct Sched Sched;

void print_a();
void print_b();
void print_c();
void print_hello();

extern void* schedule();
extern void sys_write_call(char*, int) asm("sys_write_call");
extern void cr(Gobuf*, Fn) asm("cr");
extern void save_g_sp(void*);
extern void switch_to();
extern void _switch_to(Gobuf*) asm("_switch_to");
extern void put_g(P* p, G* g);

extern void* gexit();

typedef enum GStatus {
	Grunnable,
	Grunning,
	Gdead,
} GStatus;

struct Sched {
	P* idle_p;

	M* m;

	pthread_mutex_t mutex;
};

struct Gobuf {
	void* sp;
	void* exit;
};

struct G {
	char* stack[1024];
	Gobuf gobuf;
	Fn f;
	G* next;
	GStatus gs;
};

struct P {
	G* runq;

	P* next;

	pthread_mutex_t mutex;
	pthread_cond_t nonEmpty;
};

struct M {
	P* p;
	pthread_t t;

	void* (*process)(M*);
};

Sched sched;

M* m;
G* g;

M m0;

void save_g_sp(void* sp)
{
	g->gobuf.sp = sp;
	g->gobuf.exit = (void*)-1;
	//printf("---------- save sp:%p !!! ----- \n", sp);
}

void switch_to()
{
	schedule();
}

G* get_g(P* p)
{
	pthread_mutex_lock(&p->mutex);

	G* g = p->runq;
	while (1) {
		while (g == NULL) {
			//printf("------- mutex wait ----------------\n");
			//			pthread_cond_wait(&p->nonEmpty, &p->mutex);
			g = p->runq;
		}

		if (g->gs == Grunnable) {
			p->runq = g->next;
			break;
		} else {
			g = g->next;
		}
	}

	pthread_mutex_unlock(&p->mutex);

	return g;
}

void put_g(P* p, G* g)
{
	pthread_mutex_lock(&p->mutex);

	if (p->runq == NULL) {
		p->runq = g;
	} else {
		G* gp = p->runq;
		while (gp) {
			g->next = gp;
			gp = gp->next;
		}
		g->next->next = g;
		g->next = NULL;
	}

	pthread_mutex_unlock(&p->mutex);
}

void* schedule()
{
	P* p = m->p;

	if (g != NULL) {
		g->gs = Grunnable;
		put_g(p, g);
	}

	G* rg = get_g(p);
	rg->gs = Grunning;
	g = rg;

	// printf("g stack: %p \n", g->gobuf.sp);
	// printf("g stack: %p \n", g->stack);

	if (g->gobuf.exit == gexit) {
		cr(&g->gobuf, g->f);
	}
	//	printf("---------- done !!! -----\n");

	_switch_to(&g->gobuf);

	return NULL;
}

void* gexit()
{
	g->gs = Gdead;
	g = NULL;

	printf(" -------- done --- \n");
	schedule();

	return NULL;
}

void print_a()
{
	for (int i = 0; i < N; i++) {
		//printf("--------a:%d\n", i);
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
	printf("=== New === \n");
}

void new_g(Fn f)
{
	G* g = malloc(sizeof(G));

	g->f = f;
	g->gobuf.sp = g->stack + 1024;
	g->gobuf.exit = gexit;
	g->gs = Grunnable;

	put_g(m->p, g);
}

void print_hello()
{
	printf(" ---- hello --- \n");
}

P* new_p()
{
	P* mp = (P*)malloc(sizeof(P));

	pthread_mutex_init(&mp->mutex, NULL);
	pthread_cond_init(&mp->nonEmpty, NULL);

	return mp;
}

void init_sched()
{

	m->p = new_p();

	for (int i = 1; i < P_SIZE; i++) {

		P* mp = new_p();
		mp->next = sched.idle_p;
		sched.idle_p = mp;

		printf("--- --- init: %d\n", i);
	}

	pthread_mutex_init(&sched.mutex, NULL);
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

void new_m(P* p)
{

	M* mm = (M*)malloc(sizeof(M));
	mm->p = p;

	pthread_t t;
	pthread_create(&t, NULL, (void*)start_m, mm);
}

int _main()
{

	printf("G size: %d \n", (int)sizeof(G));

	printf("hello world\n");
	CR(print_a);
	CR(print_b);
	CR(print_c);

	sleep(2);
	CR(print_d);

	sleep(1);
	//getchar();

	return 0;
}
