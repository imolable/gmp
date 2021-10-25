# GMP Draft

## 关于本文

本文只是简单模拟了Golang中GMP的基本调度方案，并不是真正Golang的实现原理。demo只在Ubuntu(20.04, intel x64平台)物理机，和Ubuntu镜像(tag:20.04，mac物理机)下测试通过。demo并不是一气呵成实现了gmp的调度方案，而是循序渐进的方式，每次迭代都在不同的分支。

## 关于Golang GMP

虽然demo是关于GMP的是实现，但这里并不打算详细讲解GMP的调度原理（详细的关于GMP介绍的文章最后会给出链接），现在只是简单解释一下GMP的概念。
G:代表的是Coroutine，可执行的Go程序。M: 代表的是OS Thread。P:代表的是Logical Processor也可以理解成Context。


## feat/demo-0.0.1

第一个最简单的版本代码在分支`feat/demo-0.0.1` 。这个版本总体来说其实是一个`生产者-消费者`模型。    
G: 就是一个可执行的`func`。    
P: 只维护了一个LRQ(Local Run Queue)队列，G 会 enqueue/dequeue。   
M: 相当于一个工作线程，与P绑定。   
Sched： 维护了一个GRQ(Global Run Queue)。   
生产者: 主线程M生产G，并放入GRQ队列中。   
消费者: 消费线程M从LRQ获取G，若LRQ没有，则从GRQ中获取G并放入LRQ中，最终还是从LRQ中获取G，并执行，若没有G，则阻塞。

![0.0.1](./images/0.0.1.png)

可通过下面的命令进行编译执行
> gcc -pthread hello.c -o hello   
>  ./hello

这个版本的G还是运行在线程M的栈空间，并不是自己的栈空间上。下个版本实现让G运行在自己的栈空间。   
请切到分支`feat/demo-0.0.2`

## feat/demo-0.0.2

这个版本只修改了一点逻辑。将执行G的函数执行方式 `g->f()`，换成了`cr_call`。然后给每个G分配了一块内存区域。

```c
// feat/demo-0.0.1
int clone_start(M* mm)
{
	P* p = mm->p;

	while (1) {
		G* g = get_g(p);
		g->f();
	}

	return 0;
}

//  feat/demo-0.0.2
void* schedule()
{
	G* g = get_g(m->p);

	cr_call(&g->gobuf, g->f);

	return NULL;
}
```

想要G运行在自己的栈空间，得给G分配一块内存区域供G作为栈来使用，并用`stack_base`指针指向分配空间的高地址（栈底是高地址，栈顶是低地址）。在执行G的函数时，我们将寄存器`SP`（栈顶指针）,`BP`（栈底指针）设置成`stack_base`的值，这样G的函数执行时，就运行在了自己的栈空间上，栈底是`stack_base`。汇编函数`cr_call(Gobuf*, Fn)`实现了这个的功能。


```
cr_call:

movq (%rdi), %rax
movq %rax, %rsp
movq %rsp, %rbp

// push buf.pc
movq 8(%rdi), %rax
pushq %rax

movq %rsi, %rax
// call f
jmp *%rax

ret
```

根据C语言函数调用规约，前6个参数依次通过寄存器传递`rdi`,`rsi`,`rdx`,`rcx`,`r8`,`r9`（x64 平台）。因此参数`Gobuf*`的值在`rdi`寄存器，`Fn`的值在`rsi`寄存器。

1. 将`rsp`, `rbp`设置成`stack_base`的值。
2. 将`Gobuf.pc`的值压栈，即将`gexit`函数地址压栈。
3. 执行函数`Fn`。即`jmp`到函数`Fn`的地址。`jmp`会修改`pc`的值。


对第2项进行解释。将`gexit`函数地址压栈，是待函数`Fn`执行完成后，然后再执行`gexit`。因为函数`Fn`的最后一条指令一定是`ret`，它的作用相当于是出栈，执行。因此在`Fn`执行完后，会弹出`gexit`，然后执行`gexit`，进行调度，执行下一个G，这样就到达了`feat/demo-0.0.1`分支里面的`while(1)`的功能。

![0.0.2](./images/0.0.2.png)


这个版本只是在函数`Fn`执行完成后进行调度。并不是像Golang的协作式调度，进入系统调用时调度。下个版本实现*协作式调度*。

请切到分支`feat/demo-0.0.3`








### Ref

- 图片用 [draw.io](https://app.diagrams.net/) 绘制
- https://qcrao91.gitbook.io/go/goroutine-tiao-du-qi
- https://draveness.me/golang/docs/part3-runtime/ch06-concurrency/golang-goroutine/
- https://morsmachine.dk/go-scheduler
- https://morsmachine.dk/netpoller
- https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part1.html
- https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part2.html
- https://www.ardanlabs.com/blog/2018/12/scheduling-in-go-part3.html
- 《深入理解计算机系统》第3版
- 《操作系统真象还原》郑钢著