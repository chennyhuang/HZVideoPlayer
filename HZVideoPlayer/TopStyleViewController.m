//
//  TopStyleViewController.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/18.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "TopStyleViewController.h"
#import "HZVideoPlayer.h"
@interface TopStyleViewController ()
@property (nonatomic,strong) HZVideoPlayer *playerView;
@end

@implementation TopStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rzjt" ofType:@"MP4"];
        NSURL *url = [NSURL fileURLWithPath:filePath];
//    NSURL *url = [NSURL fileURLWithPath:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"];
//    NSURL *url = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    self.playerView.url = url;

    [self.view addSubview:self.playerView];
    NSLog(@"view -- %@",NSStringFromCGRect(self.view.frame));
    NSLog(@"window --%@",NSStringFromCGRect([UIApplication sharedApplication].keyWindow.frame));
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    playButton.frame = CGRectMake(50, 300, 60, 50);
    [self.view addSubview:playButton];
    
    UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    [pauseButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    pauseButton.frame = CGRectMake(150, 300, 60, 50);
    [self.view addSubview:pauseButton];
    
    UIButton *stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [stopButton setTitle:@"停止" forState:UIControlStateNormal];
    [stopButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    stopButton.frame = CGRectMake(240, 300, 60, 50);
    [self.view addSubview:stopButton];
    
    UIButton *rotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rotateButton addTarget:self action:@selector(rotateEnable) forControlEvents:UIControlEventTouchUpInside];
    [rotateButton setTitle:@"允许自动旋转" forState:UIControlStateNormal];
    [rotateButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    rotateButton.frame = CGRectMake(50, 400, 120, 50);
    [self.view addSubview:rotateButton];
    
    UIButton *norotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [norotateButton addTarget:self action:@selector(rotateDisenable) forControlEvents:UIControlEventTouchUpInside];
    [norotateButton setTitle:@"禁止自动旋转" forState:UIControlStateNormal];
    [norotateButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    norotateButton.frame = CGRectMake(200, 400, 120, 50);
    [self.view addSubview:norotateButton];
}


-(UIView *)playerView{
    if (!_playerView) {
        _playerView = [[HZVideoPlayer alloc] init];
        _playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * (9.0/16));
        _playerView.playerStyle = HZVideoPlayerStyleTop;
        _playerView.autoPlay = YES;
    }
    return _playerView;
}

- (void)play{
    [self.playerView play];
}

- (void)pause{
    [self.playerView pause];
}

- (void)stop{
    [self.playerView stop];
}

- (void)rotateEnable{
    self.playerView.enableAutoRotate = YES;
}

- (void)rotateDisenable{
    self.playerView.enableAutoRotate = NO;
}
@end
