//
//  ViewController.m
//  多线程demo
//
//  Created by 马旭 on 2018/6/26.
//  Copyright © 2018年 马旭. All rights reserved.
//

#import "ViewController.h"
#import "GcdObject.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   GcdObject *obj= [[GcdObject alloc] init];
//    [obj semaphoreTest];
    [obj queueAndTheadTest];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
