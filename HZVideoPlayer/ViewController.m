//
//  ViewController.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/17.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "ViewController.h"
#import "TopStyleViewController.h"
#import "InnerStyleViewController.h"

@interface ViewController ()
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [topBtn setTitle:@"顶部样式" forState:UIControlStateNormal];
    [topBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    topBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    topBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 100)*0.5, 200, 100, 50);
    [topBtn addTarget:self action:@selector(topStyleClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBtn];
    
    UIButton *innerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [innerBtn setTitle:@"内部样式" forState:UIControlStateNormal];
    [innerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    innerBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    innerBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 100)*0.5, 300, 100, 50);
    [innerBtn addTarget:self action:@selector(innerStyleClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:innerBtn];
    
}

- (void)topStyleClick{
    TopStyleViewController *vc = [[TopStyleViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)innerStyleClick{
    InnerStyleViewController *vc = [[InnerStyleViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
