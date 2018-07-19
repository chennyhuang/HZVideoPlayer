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
@property (nonatomic,assign) CGRect ContainerOriginRect;
@property (nonatomic,assign) UIStatusBarStyle originStatusBarStyle;//记录状态栏初始style
@property (nonatomic,strong) UIWindow *keyWindow;

@property (nonatomic,strong) UIView *statusView;
@property (nonatomic,strong) UIButton *playButton;//播放暂停按钮
@property (nonatomic,strong) UIView *containerView;//放置播放界面，播放控制界面

@property (nonatomic,strong) HZPlayerView *playerView;

@end

@implementation HZVideoPlayer
- (void)dealloc{
    NSLog(@"view 销毁");
    [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle];
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
    self.ContainerOriginRect = [self convertRect:self.coverImageView.frame toView:self.superview];
//    self.containerOriginRect = self.containerView.frame;
    
    self.playerView.frame = CGRectMake(0, 0, self.ContainerOriginRect.size.width, self.ContainerOriginRect.size.height);
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self initFrame];
    
    NSLog(@"didMoveToSuperview--  %@",NSStringFromCGRect(self.frame));
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
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

- (HZPlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[HZPlayerView alloc] init];
//        _playerView.url = [NSURL URLWithString:@"http://220.249.115.46:18080/wav/day_by_day.mp4"];
    }
    return _playerView;
}

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
    //添加播放器
    [self.superview addSubview:self.containerView];
    
    self.containerView.frame = self.ContainerOriginRect;
    
    [self.superview addSubview:self.playerView];
    self.playerView.frame = self.ContainerOriginRect;
    
//    self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.superview).offset(0);
//        make.left.equalTo(self.superview).offset(0);
//        make.right.equalTo(self.superview).offset(0);
//        make.height.mas_equalTo(200);
//    }];
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rzjt" ofType:@"MP4"];
    NSURL *url = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    self.playerView.url = url;
}

#pragma mark orientation
////手动强制竖屏
//- (void)manualPortrait{
//    NSLog(@"手动竖屏");
////    self.keyWindow.windowLevel = UIWindowLevelNormal;
//    [UIView animateWithDuration:kRotateAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        self.containerView.transform = CGAffineTransformIdentity;
//        if (iPhoneX) {
//            self.containerView.frame = CGRectMake(0, kStatusBar_Height, self.playerW, self.playerH);
//        } else {
//            self.containerView.frame = CGRectMake(0, 0, self.playerW, self.playerH);
//        }
//        [self setNeedsLayout];
//        [self layoutIfNeeded];
//    } completion:^(BOOL finished) {
//    }];
//}
//
////手动强制横屏
//- (void)manualLandscape{
//    NSLog(@"手动横屏");
////    self.keyWindow.windowLevel = UIWindowLevelStatusBar+10.0f;//隐藏状态栏
//    [UIView animateWithDuration:kRotateAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        self.containerView.transform = CGAffineTransformMakeRotation(M_PI/2);
//        if (iPhoneX) {
//            self.containerView.frame = CGRectMake(0, kStatusBar_Height, kAPPWidth, KAppHeight - kStatusBar_Height);
//        } else {
//            NSLog(@"横屏");
//            NSLog(@"w -- %f h -- %f",kAPPWidth,KAppHeight);
//            self.containerView.frame = CGRectMake(0, 0, kAPPWidth, KAppHeight);
//        }
//        [self setNeedsLayout];
//        [self layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        
//    }];
//}
/*
 动画比较丑
-(void)onDeviceOrientationChange
{
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        
        
        self.keyWindow.windowLevel = UIWindowLevelStatusBar+10.0f;//隐藏状态栏
        [self.containerView hideSubViews];
        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.containerView.transform = (orientation==UIDeviceOrientationLandscapeRight)?CGAffineTransformMakeRotation(-M_PI/2):CGAffineTransformMakeRotation(M_PI/2);
        } completion:^(BOOL finished) {
            [self.containerView showSubViews];
        }];
        self.containerView.frame = self.keyWindow.bounds;

    } else if (orientation==UIDeviceOrientationPortrait){
        
        self.keyWindow.windowLevel = UIWindowLevelNormal;//展示状态栏
        [self.containerView hideSubViews];
        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.containerView.transform = (orientation==UIDeviceOrientationPortrait)?CGAffineTransformIdentity:CGAffineTransformMakeRotation(M_PI);
            
        } completion:^(BOOL finished) {
            [self.containerView showSubViews];
        }];
        self.containerView.frame = self.ContainerOriginRect;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}*/

-(void)onDeviceOrientationChange
{
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        self.keyWindow.windowLevel = UIWindowLevelStatusBar+10.0f;//隐藏状态栏
        self.containerView.hidden = NO;
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

        }];
        [self.playerView layoutIfNeeded];
        [UIView animateWithDuration:duration animations:^{
            self.playerView.transform = (orientation==UIDeviceOrientationLandscapeRight)?CGAffineTransformMakeRotation(-M_PI/2):CGAffineTransformMakeRotation(M_PI/2);
            [self.playerView layoutIfNeeded];
        }];
        
    } else if (orientation==UIDeviceOrientationPortrait){
        
        self.keyWindow.windowLevel = UIWindowLevelNormal;//展示状态栏
        self.containerView.hidden = YES;
        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.containerView.transform = (orientation==UIDeviceOrientationPortrait)?CGAffineTransformIdentity:CGAffineTransformMakeRotation(M_PI);
            self.playerView.transform = (orientation==UIDeviceOrientationPortrait)?CGAffineTransformIdentity:CGAffineTransformMakeRotation(M_PI);
            
            self.containerView.frame = self.ContainerOriginRect;
            self.playerView.frame = self.ContainerOriginRect;
        } completion:^(BOOL finished) {

        }];
        
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}



@end
