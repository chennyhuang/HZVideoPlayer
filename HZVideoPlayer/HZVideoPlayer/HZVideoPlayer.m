//
//  HZVideoPlayer.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/17.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "HZVideoPlayer.h"
#import "HZPlayerView.h"
#import "Masonry.h"

@interface HZVideoPlayer()
@property (nonatomic,assign) CGRect selfOriginRect;//自身初始frame
@property (nonatomic,assign) CGRect containerOriginRect;
@property (nonatomic,assign) UIStatusBarStyle originStatusBarStyle;//记录状态栏初始style
@property (nonatomic,strong) UIWindow *keyWindow;

@property (nonatomic,strong) UIView *statusView;
@property (nonatomic,strong) UIButton *playButton;//播放暂停按钮
@property (nonatomic,strong) UIView *containerView;//放置播放界面，播放控制界面

@property (nonatomic,strong) HZPlayerView *playerView;

@end

@implementation HZVideoPlayer
- (void)dealloc{
    NSLog(@"放播放器的view 销毁");
    [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle];
    [self stop];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.statusView];
    [self addSubview:self.coverImageView];
    [self.coverImageView addSubview:self.playButton];

    self.statusView.backgroundColor = [UIColor blackColor];

    //设置播放器默认样式
    self.playerStyle = HZVideoPlayerStyleTop;
    if (self.playerStyle == HZVideoPlayerStyleTop) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)initFrame{
    CGFloat playerX = self.frame.origin.x;
    CGFloat playerY = self.frame.origin.y;
    CGFloat playerW = self.frame.size.width;
    CGFloat playerH = self.frame.size.height;
    
    CGFloat statusViewH = 0;
    if (self.playerStyle == HZVideoPlayerStyleTop) {
        statusViewH = kStatusBar_Height;
    } else {
        statusViewH = 0;
    }
    self.frame = CGRectMake(playerX, playerY, playerW, playerH + statusViewH);
    self.selfOriginRect = self.frame;
    self.statusView.frame = CGRectMake(0, 0, playerW, statusViewH);
    self.coverImageView.frame = CGRectMake(0, statusViewH, playerW, playerH);
    self.playButton.frame = CGRectMake((self.coverImageView.frame.size.width - 100)*0.5, (self.coverImageView.frame.size.height - 100)*0.5, 100, 100);
//    self.containerView.frame = CGRectMake(0, statusViewH, playerW, playerH);
    
//    self.containerOriginRect = self.containerView.frame;
    if (_playerView) {
        self.playerView.frame = CGRectMake(0, 0, self.containerOriginRect.size.width, self.containerOriginRect.size.height);
    }
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self initFrame];
}

#pragma mark getter setter
- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:HZPlayerImage(@"HZPlayer_pause") forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (void)setPlayerStyle:(HZVideoPlayerStyle)playerStyle{
    _playerStyle = playerStyle;
    if (self.playerStyle == HZVideoPlayerStyleTop) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle];
    }
}

- (UIWindow *)keyWindow{
    return [UIApplication sharedApplication].keyWindow;
}

- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor blackColor];
    }
    return _containerView;
}

//- (HZPlayerView *)playerView{
//    if (!_playerView) {
//        _playerView = [[HZPlayerView alloc] init];
////        _playerView.url = [NSURL URLWithString:@"http://220.249.115.46:18080/wav/day_by_day.mp4"];
//    }
//    return _playerView;
//}

- (UIView *)statusView{
    if (!_statusView) {
        _statusView = [[UIView alloc] init];
    }
    return _statusView;
}

- (UIImageView *)coverImageView{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.image = [UIImage imageNamed:@"placeHolder"];
        _coverImageView.backgroundColor = [UIColor blackColor];
    }
    return _coverImageView;
}

//- (void)setUrl:(NSURL *)url{
//    _url = url;
//}

#pragma mark private methods
- (void)tap{
//    [self manualPortrait];
    NSLog(@"tap");
}

- (void)landClick{
//    [self manualLandscape];
    NSLog(@"landClick");
}

- (void)startPlay{
    //获取播放器相对于 keyWindow 的坐标
    self.containerOriginRect = [self convertRect:self.coverImageView.frame toView:self.keyWindow];
    //添加黑色遮罩
    [self.superview addSubview:self.containerView];
    self.containerView.frame = self.containerOriginRect;
    //添加播放器
    self.playerView = [[HZPlayerView alloc] init];
    [self.superview addSubview:self.playerView];
    @weakify(self);
    self.playerView.rotateToPortrait = ^{
        @strongify(self);
        [self rotateToPortrait:nil];
    };
    
    self.playerView.rotateToLandScape = ^{
        @strongify(self);
        [self rotateToLandScape:nil];
    };
    
    self.playerView.playEnd = ^{
        @strongify(self);
        [self rotateToPortrait:^{
            [self stop];
            if (self.playerView) {
                self.playerView = nil;
            }
            [self.containerView removeFromSuperview];
            if (self.containerView) {
                self.containerView = nil;
            }
        }];
    };
    
    self.playerView.frame = self.containerOriginRect;
    self.playerView.url = self.url;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark orientation
-(void)onDeviceOrientationChange
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [self rotateToLandScape:nil];
    } else if (orientation==UIDeviceOrientationPortrait){
        [self rotateToPortrait:nil];
    }
}

- (void)rotateToPortrait:(void(^)(void))completion{
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    self.keyWindow.windowLevel = UIWindowLevelNormal;//展示状态栏
    self.containerView.hidden = YES;
    self.playerView.playerOrientation = HZPlayerOrientationPortrait;
    [self.playerView rotateBeginHideItems];
    
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        self.containerView.transform = (orientation==UIDeviceOrientationPortrait)?CGAffineTransformIdentity:CGAffineTransformMakeRotation(M_PI);
//        self.playerView.transform = (orientation==UIDeviceOrientationPortrait)?CGAffineTransformIdentity:CGAffineTransformMakeRotation(M_PI);
        self.containerView.transform = CGAffineTransformIdentity;
        self.playerView.transform = CGAffineTransformIdentity;
        
        self.containerView.frame = self.containerOriginRect;
        self.playerView.frame = self.containerOriginRect;
    } completion:^(BOOL finished) {
        [self.playerView rotateEndShowItems];
        if (completion) {
            completion();
        }
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)rotateToLandScape:(void(^)(void))completion{
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    self.keyWindow.windowLevel = UIWindowLevelStatusBar+10.0f;//隐藏状态栏
    self.containerView.hidden = NO;
    self.playerView.playerOrientation = HZPlayerOrientationLandScape;
    [self.playerView rotateBeginHideItems];
    
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerView.transform = (orientation==UIDeviceOrientationLandscapeRight)?CGAffineTransformMakeRotation(-M_PI/2):CGAffineTransformMakeRotation(M_PI/2);
        self.playerView.transform = (orientation==UIDeviceOrientationLandscapeRight)?CGAffineTransformMakeRotation(-M_PI/2):CGAffineTransformMakeRotation(M_PI/2);
        self.containerView.frame = CGRectMake(0, 0, kAPPWidth, KAppHeight);
        if (iPhoneX) {
            self.playerView.frame = CGRectMake(0, kStatusBar_Height, kAPPWidth, KAppHeight - kStatusBar_Height - kBottomSafeHeight);
        } else {
            self.playerView.frame = CGRectMake(0, 0, kAPPWidth, KAppHeight);
        }
    } completion:^(BOOL finished) {
        [self.playerView rotateEndShowItems];
        if (completion) {
            completion();
        }
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark public methods
- (void)play{
    if (self.playerView) {
        [self.playerView play];
    }
}

- (void)pause{
    if (self.playerView) {
        [self.playerView pause];
    }
}

- (void)stop{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.playerView) {
        [self.playerView stop];
    }
}
@end
