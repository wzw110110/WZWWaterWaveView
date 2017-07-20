//
//  ViewController.m
//  WZWWaterWaveView
//
//  Created by zhiwei wu on 2017/7/19.
//  Copyright © 2017年 wzw. All rights reserved.
//

#import "ViewController.h"
#import "WZWWaterWaveView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [WZWWaterWaveView show];
    
    // 延迟2秒执行：
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [WZWWaterWaveView dismiss];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
