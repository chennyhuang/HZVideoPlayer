//
//  InnerStyleViewController.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/18.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "InnerStyleViewController.h"
#import "HZVideoPlayer.h"
@interface InnerStyleViewController ()
@property (nonatomic,strong) HZVideoPlayer *playerView;
@end

@implementation InnerStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.playerView];
}


-(UIView *)playerView{
    if (!_playerView) {
        _playerView = [[HZVideoPlayer alloc] init];
        _playerView.frame = CGRectMake(0, 300, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * (9.0/16));
        _playerView.playerStyle = HZVideoPlayerStyleInner;
    }
    return _playerView;
}
@end
