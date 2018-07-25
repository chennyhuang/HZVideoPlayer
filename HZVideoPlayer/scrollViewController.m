//
//  scrollViewController.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/25.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "scrollViewController.h"
#import "HZVideoPlayer.h"

@interface scrollViewController ()
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) HZVideoPlayer *playerView;
@end

@implementation scrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    NSURL *url = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    self.playerView.url = url;
    
    [self.scrollView addSubview:self.playerView];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.scrollView.frame = [UIScreen mainScreen].bounds;
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 2);
}

#pragma mark getter setter
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor yellowColor];
    }
    return _scrollView;
}

-(UIView *)playerView{
    if (!_playerView) {
        _playerView = [[HZVideoPlayer alloc] init];
        _playerView.frame = CGRectMake(30, 300, [UIScreen mainScreen].bounds.size.width - 60, [UIScreen mainScreen].bounds.size.width * (9.0/16));
        _playerView.playerStyle = HZVideoPlayerStyleInner;
        _playerView.autoPlay = YES;
        _playerView.enableAutoRotate = YES;
    }
    return _playerView;
}
@end
