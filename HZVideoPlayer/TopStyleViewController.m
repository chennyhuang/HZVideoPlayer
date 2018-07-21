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
    self.playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 210);
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rzjt" ofType:@"MP4"];
    //    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURL *url = [NSURL fileURLWithPath:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"];
    //    NSURL *url = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    self.playerView.url = url;
    
    [self.view addSubview:self.playerView];
}

-(UIView *)playerView{
    if (!_playerView) {
        _playerView = [[HZVideoPlayer alloc] init];
//        _playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * (9.0/16));
        _playerView.playerStyle = HZVideoPlayerStyleTop;
    }
    return _playerView;
}
@end
