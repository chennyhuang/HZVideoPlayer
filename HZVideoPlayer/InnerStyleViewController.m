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
    self.playerView.frame = CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, 210);

    NSURL *url = [NSURL URLWithString:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"];

    self.playerView.url = url;
    
    [self.view addSubview:self.playerView];
}


-(UIView *)playerView{
    if (!_playerView) {
        _playerView = [[HZVideoPlayer alloc] init];
        _playerView.frame = CGRectMake(0, 300, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * (9.0/16));
        _playerView.playerStyle = HZVideoPlayerStyleInner;
        _playerView.autoPlay = NO;
    }
    return _playerView;
}
@end
