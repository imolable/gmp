#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
// #include <semaphore.h>

#define N 10

#define CR(a)      \
	{              \
		put_Fn(a); \
	}

typedef void (*Fn)(void);
typedef struct Node Node;
typedef struct Queue Queue;

typedef struct G G;
typedef struct P P;
typedef struct M M;

struct G {
	Fn f;
	G* next;
};

struct P {

	G* gfree;

	pthread_mutex_t mutex;
	pthread_cond_t nonEmpty;
};

void p_init(P* p)
{
	pthread_mutex_init(&p->mutex, NULL);
	pthread_cond_init(&p->nonEmpty, NULL);
}

G* get_g(P* p)
{

	pthread_mutex_lock(&p->mutex);

	while (p->gfree == NULL) {
		printf("------- mutex wait ----------------\n");
		pthread_cond_wait(&p->nonEmpty, &p->mutex);
	}

	G* g = p->gfree;
	p->gfree = g->next;

	pthread_mutex_unlock(&p->mutex);

	return g;
}

void put_g(P* p, G* g)
{
	pthread_mutex_lock(&p->mutex);

	if (p->gfree == NULL) {
		p->gfree = g;
	} else {
		G* gp = p->gfree;
		while (gp) {
			g->next = gp;
			gp = gp->next;
		}
		g->next->next = g;
		g->next = NULL;
	}

	pthread_cond_signal(&p->nonEmpty);
	pthread_mutex_unlock(&p->mutex);
}

struct M {
	P* p;
	pthread_t t;

	void* (*process)(M*);
};

void* process(M*);
void m_init(M* m, P* p)
{
	m->p = p;
	m->process = process;
	pthread_create(&m->t, NULL, (void*)m->process, m);
};

void* process(M* m)
{

	while (1) {
		G* g = get_g(m->p);
		(g->f)();
		free(g);
	}

	return NULL;
}
void print_a()
{
	for (int i = 0; i < N; i++) {
		printf("AA_%d\n", i);
	}
}

void print_b()
{

	for (int i = 0; i < N; i++) {
		printf("BBB_%d\n", i);
	}
}

void print_c()
{

	for (int i = 0; i < N; i++) {
		printf("CCCC_%d\n", i);
	}
}

P p;

void put_Fn(Fn f)
{
	G* g = malloc(sizeof(G));
	g->f = f;

	put_g(&p, g);
}

int main()
{
	printf("hello world\n");

	p_init(&p);

	M m;
	m_init(&m, &p);

	sleep(1);

	CR(print_a);
	CR(print_b);
	CR(print_c);

	sleep(1);
	getchar();

	return 0;
}
