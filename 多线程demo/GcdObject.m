//
//  GcdObject.m
//  多线程demo
//
//  Created by 马旭 on 2018/6/26.
//  Copyright © 2018年 马旭. All rights reserved.
//

#import "GcdObject.h"
#import "TestObj.h"
static dispatch_queue_t queue;
static dispatch_queue_t seQueue;
static dispatch_semaphore_t semaphore;
@implementation GcdObject
- (id)init {
    if (self=[super init]) {
        [self initQueue];
    }
    return self;
}
- (void)initQueue {
    /*iOS中队列与线程的关系：
     队列是用来管理线程池的
     */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue =dispatch_queue_create("que.test", DISPATCH_QUEUE_CONCURRENT);//DISPATCH_QUEUE_CONCURRENT
        seQueue=dispatch_queue_create("selQueue", NULL);

    });
}
- (void)semaphoreTest {
    
    //创建信号量，参数：信号量的初值，如果小于0则会返回NULL
    semaphore=dispatch_semaphore_create(1);
    dispatch_async(queue, ^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{
            NSLog(@"currentThread===%@",[NSThread currentThread]);
            TestObj *obj=[[TestObj alloc] init];
            [obj testFunc];
            // 提高信号量， 使信号量加1并返回
            dispatch_semaphore_signal(semaphore);
        });
    });
    dispatch_async(seQueue, ^{
        // 等待降低信号量，接收一个信号和时间值(多为DISPATCH_TIME_FOREVER)
        // 若信号的信号量为0，则会阻塞当前线程，直到信号量大于0或者经过输入的时间值；
        // 若信号量大于0，则会使信号量减1并返回，程序继续住下执行
        dispatch_semaphore_wait(semaphore,  DISPATCH_TIME_FOREVER);
        NSLog(@"t0");
    });
    dispatch_async(seQueue, ^{
        dispatch_semaphore_wait(semaphore,  DISPATCH_TIME_FOREVER);
        NSLog(@"t1");
    });
    dispatch_async(seQueue, ^{
        dispatch_semaphore_wait(semaphore,  DISPATCH_TIME_FOREVER);
        NSLog(@"t3");
    });
    dispatch_async(seQueue, ^{
        dispatch_semaphore_wait(semaphore,  DISPATCH_TIME_FOREVER);
        NSLog(@"t4");
    });


//    dispatch_semaphore_wait(semaphore,  DISPATCH_TIME_FOREVER);
//    NSLog(@"t0");
}
- (void)testMehtod {
    sleep(3);
    NSLog(@"主线程睡眠结束");
}
- (void)queueAndTheadTest {
  /*  1. 开不开线程，取决于执行任务的函数，sync同步不开，async异步开。
    
    2. 开几条线程，取决于队列，串行开一条，并发开多条(异步)
    
    3. 主队列：  专门用来在主线程上调度任务的"队列"，主队列不能在其他线程中调度任务！
    
    4. 如果主线程上当前正在有执行的任务，主队列暂时不会调度任务的执行！主队列同步任务，会造成死锁。原因是循环等待
       主队列上同步任务：因为主队列的任务虽然会加到主线程中执行，但是如果主线程里也有任务就必须等主线程任务执行完才轮到主队列的，但是同步任务sync必须要等任务执行完毕才继续执行
   */
    [self performSelector:@selector(testMehtod)];
    
    switch (2) {
        case 0:{
            for (int i = 0; i<10; i++) {
                //串行队列，同步执行,默认在当前顺序执行
                dispatch_sync(seQueue, ^{
                    NSLog(@"串行队列，同步执行:\n%@ %d", [NSThread currentThread], i);
                });
            }
            NSLog(@"串行队列，同步执行\n\n");
        }
            break;
        case 1:{
                for (int i = 0; i<10; i++) {
                    //串行队列，异步执行,
                    dispatch_async(seQueue, ^{
                        NSLog(@"串行队列，异步执行:\n%@ %d", [NSThread currentThread], i);
                    });
                }
                NSLog(@"串行队列，异步执行\n\n");
        }
            
            break;
        case 2:{
            dispatch_queue_t othq=dispatch_queue_create("hhhh", NULL);
            dispatch_async(seQueue, ^{
                        dispatch_async(seQueue, ^{
//                            sleep(2);
                            NSLog(@"%@--1",[NSThread currentThread]);
                        });
                NSLog(@"%@--2",[NSThread currentThread]);
                dispatch_sync(othq, ^{
                    NSLog(@"%@--4",[NSThread currentThread]);
                });
                        dispatch_async(seQueue, ^{
                            NSLog(@"%@--3",[NSThread currentThread]);
                        });
            });
        }
            
            break;
        case 3:{
            for (int i = 0; i<10; i++) {
                //并发队列，异步执行,
                dispatch_async(queue, ^{
                    NSLog(@"并发队列，异步执行:\n%@ %d", [NSThread currentThread], i);
                });
            }
            NSLog(@"并发队列，异步执行\n\n");
        }
            
            break;
        case 4:{
            for (int i = 0; i<10; i++) {
                //并发队列，同步执行,
                dispatch_sync(queue, ^{
                    NSLog(@"并发队列，同步执行:\n%@ %d", [NSThread currentThread], i);
                });
            }
            NSLog(@"并发队列，同步执行\n\n");
        }
            
            break;
        case 5:{
            // 1. 主队列 － 程序启动之后已经存在主线程，主队列同样存在
            dispatch_queue_t q = dispatch_get_main_queue();
            // 2. 安排一个任务
            for (int i = 0; i<10; i++) {
                dispatch_async(q, ^{
                    NSLog(@"主队列，异步执行:%@ %d", [NSThread currentThread], i);
                });
            }
            //结果显示有点出人意料。主线程在睡会之后才打印，循环一直在等着。因为主队列的任务虽然会加到主线程中执行，但是如果主线程里也有任务就必须等主线程任务执行完才轮到主队列的
            NSLog(@"睡会");
            [NSThread sleepForTimeInterval:2.0];
            NSLog(@"主队列，异步执行\n\n");
        }
            
            break;
        case 6:{
            dispatch_async(queue, ^{
                dispatch_sync(seQueue, ^{
                    NSLog(@"xxxx===%@", [NSThread currentThread]);
                });
                // 2. 扣费
                dispatch_async(queue, ^{
                    NSLog(@"扣费 %@", [NSThread currentThread]);
                });
                // 3. 下载
                dispatch_async(queue, ^{
                    
                    NSLog(@"下载 %@", [NSThread currentThread]);
                });
            });
        }
            
            break;
        case 7:{
            
        }
            
            break;
        case 8:{
            
        }
            
            break;
            
        default:
            break;
    }
    
}
@end

