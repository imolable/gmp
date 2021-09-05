#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
// #include <semaphore.h>

#define N 10

#define CR(a)      \
	{              \
		put_Fn(a); \
	}

#define SAVE_G_BUF     \
	pushq % rax;       \
	pushq % rdx;       \
	pushq % rdi;       \
	pushq % rsi;       \
	pushq % rbp;       \
	movq % rsp, % rdi; \
	call save_g_sp;

typedef void (*Fn)(void);
typedef struct Node Node;
typedef struct Queue Queue;

typedef struct G G;
typedef struct P P;
typedef struct M M;
typedef struct Gobuf Gobuf;
typedef enum Gstatus Gstatus;

void print_a();
void print_b();
void print_c();

extern void *schedule();
extern void sys_write_call(char *, int) asm("sys_write_call");
extern void cr(Gobuf *, Fn) asm("cr");
extern void save_g_sp(void *);
extern void switch_to();
extern void _switch_to(Gobuf *) asm("_switch_to");
extern void put_g(P *p, G *g);

extern void *gexit();

typedef enum GState
{
	Grunnable,
	Grunning,
	Gdead,
} GState;

struct Gobuf
{
	void *sp;
	void *exit;
};

struct G
{
	char *stack[1024];
	Gobuf gobuf;
	Fn f;
	G *next;
	GState gs;
};

struct P
{
	G *gfree;

	pthread_mutex_t mutex;
	pthread_cond_t nonEmpty;
};

struct M
{
	P *p;
	pthread_t t;

	void *(*process)(M *);
};

P p;
G *_g;

void save_g_sp(void *sp)
{
	_g->gobuf.sp = sp;
	_g->gobuf.exit = (void *)-1;
	//printf("---------- save sp:%p !!! ----- \n", sp);
}

void switch_to()
{
	schedule();
}

void p_init(P *p)
{
	pthread_mutex_init(&p->mutex, NULL);
	pthread_cond_init(&p->nonEmpty, NULL);
}

G *get_g(P *p)
{
	pthread_mutex_lock(&p->mutex);

	G *g = p->gfree;
	while (1)
	{
		while (g == NULL)
		{
			printf("------- mutex wait ----------------\n");
			pthread_cond_wait(&p->nonEmpty, &p->mutex);
			g = p->gfree;
		}

		if (g->gs == Grunnable)
		{
			p->gfree = g->next;
			break;
		}
		else
		{
			g = g->next;
		}
	}

	pthread_mutex_unlock(&p->mutex);

	return g;
}

void put_g(P *p, G *g)
{
	pthread_mutex_lock(&p->mutex);

	if (p->gfree == NULL)
	{
		p->gfree = g;
	}
	else
	{
		G *gp = p->gfree;
		while (gp)
		{
			g->next = gp;
			gp = gp->next;
		}
		g->next->next = g;
		g->next = NULL;
	}

	pthread_cond_signal(&p->nonEmpty);
	pthread_mutex_unlock(&p->mutex);
}

void *schedule()
{
	if (_g != NULL)
	{
		_g->gs = Grunnable;
		put_g(&p, _g);
	}

	G *g = get_g(&p);
	g->gs = Grunning;
	_g = g;

	// printf("g stack: %p \n", g->gobuf.sp);
	// printf("g stack: %p \n", g->stack);

	if (g->gobuf.exit == gexit)
	{
		cr(&g->gobuf, g->f);
	}
	//	printf("---------- done !!! -----\n");

	_switch_to(&g->gobuf);

	return NULL;
}

void *gexit()
{
	_g->gs = Gdead;
	_g = NULL;

	schedule();
}

void *process(M *m)
{
	schedule();

	return NULL;
}

void m_init(M *m, P *p)
{
	m->p = p;
	m->process = process;
	pthread_create(&m->t, NULL, (void *)m->process, m);
};

void print_a()
{
	for (int i = 0; i < N; i++)
	{
		//printf("--------a:%d\n", i);
		char src[10];
		sprintf(src, "AA_%d\n", i + 1);
		sys_write_call(src, strlen(src));
	}
}

void print_b()
{
	for (int i = 0; i < N; i++)
	{
		char src[10];
		sprintf(src, "BBB_%d\n", i + 1);
		sys_write_call(src, strlen(src));
	}
}

void print_c()
{
	for (int i = 0; i < N; i++)
	{
		char src[10];
		sprintf(src, "CCCC_%d\n", i + 1);
		sys_write_call(src, strlen(src));
	}
}

void print_d()
{
	printf("=== New === \n");
}

void put_Fn(Fn f)
{
	G *g = malloc(sizeof(G));

	g->f = f;
	g->gobuf.sp = g->stack + 1024;
	g->gobuf.exit = gexit;
	g->gs = Grunnable;

	put_g(&p, g);
}

int main()
{
	printf("hello world\n");

	p_init(&p);

	M m;
	m_init(&m, &p);

	G g;
	printf("G size: %d \n", (int)sizeof(g));

	sleep(1);

	CR(print_a);
	CR(print_b);
	CR(print_c);

	sleep(2);
	CR(print_d);

	sleep(1);
	getchar();

	return 0;
}
